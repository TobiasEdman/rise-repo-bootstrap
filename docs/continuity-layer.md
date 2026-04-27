# The continuity layer (`~/.claude/`)

The kit produces a great new repo on its own. To get the *full* continuity-layer experience — where rules are enforced, not just documented — you also install a small global layer under `~/.claude/`. This document walks you through it.

## TL;DR

```bash
# Clone the agentic_workflow repo (where the layer was originally built)
git clone https://github.com/TobiasEdman/agentic_workflow.git ~/Developer/agentic_workflow

# Read the implementation plan
open ~/Developer/agentic_workflow/docs/implementation_plan.md

# Manually replicate ~/.claude/ structure (see below) — there is no installer in v1
```

There is deliberately **no auto-installer**. The continuity layer touches your global Claude Code configuration (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`, hooks) and you should know exactly what's happening. Manual install ≈ 20 minutes.

## What the layer is

Five components:

### 1. Global rules — `~/.claude/CLAUDE.md`

Seven rules that apply to every Claude Code session:

| § | Rule | Source failure |
|---|---|---|
| 1 | Diagnosis vs. directive — don't act, ask | Live fetch code edited mid-status-question |
| 2 | Echo-back discipline | Rule stated once, violated 18 turns later |
| 3 | Running code is read-only | "Sluta ändra i fetchkoden!!!" |
| 4 | Mid-session re-anchor at ~50 turns | 22 corrections in one 130k-word session |
| 5 | Front-load turn 0 | Briefing-prompt is the load-bearing pattern |
| 6 | Verify work before declaring done | "Highest-leverage thing you can do" |
| 7 | Co-Authored-By trailer on every commit | `git blame` + `git log --author=` integrity |

Full text: see `~/Developer/agentic_workflow/docs/conversation_log/08_continuity_rollout.md` for the install record, or the actual file at `~/.claude/CLAUDE.md` after you populate it.

### 2. Skills — `~/.claude/skills/<name>/SKILL.md`

Five user-invokable skills:

| Skill | Use when |
|---|---|
| `/brief` | Starting non-trivial work — expands a one-liner into the full briefing template |
| `/checkpoint` | Every ~50 turns in long sessions, or after a milestone |
| `/recall` | Starting a fresh session in a repo where you've worked before |
| `/spec` | Ambiguous features needing AskUserQuestion-driven interview |
| `/review` | Writer/reviewer second pass with fresh-context subagent |

`/checkpoint` is dual-mode (drift vs milestone) — see the SKILL.md for the cadence rules.

### 3. Hooks — `~/.claude/hooks/*.sh`

Two PreToolUse hooks turn advisory rules into deterministic enforcement:

- **`co-authored-by.sh`** — fires on `Bash` matcher when a `git commit` lacks the §7 trailer. Returns `permissionDecision: "ask"` so the UI surfaces a prompt before the commit lands.
- **`active-jobs-guard.sh`** — fires on `Edit|Write` matcher when the target file matches a glob in any `~/.claude/active-jobs/<slug>.json` sentinel. Returns `permissionDecision: "ask"` to enforce §3 ("running code is read-only").

Hook output schemas: `permissionDecision: "ask"` surfaces a UI confirmation; `permissionDecision: "deny"` blocks the call; exit code 0 with no output = silent pass. Both hooks are fail-open by design — a hook bug must never block legitimate work.

The 2026-04-25 audit measured: text-only §7 rule had 35% compliance in ImintEngine. After `co-authored-by.sh` landed, post-hook compliance jumped to 87% across all repos. That 52-point gap is the case for installing hooks.

### 4. Subagents — `~/.claude/agents/`

One agent so far: `savant-reviewer.md` (extracted from the rise-pax CLAUDE.md §9 pattern). Used by the `/review` skill. Add more as patterns emerge.

### 5. Checkpoint store — `~/.claude/checkpoints/<repo>/<date>_<slug>_turn<N>.md`

Where `/checkpoint` writes snapshots and `/recall` reads them. Layout: one directory per repo, one markdown file per checkpoint. Indexed into Qdrant by `omni-rag` (formerly `des-agent`) for semantic retrieval — see W3.7 in agentic_workflow/docs/rollout_plan.md.

## Manual install

(Until someone writes an installer.) From your `~/Developer/agentic_workflow` clone:

```bash
mkdir -p ~/.claude/{skills,hooks,agents,checkpoints,active-jobs,scripts}

# 1. Copy the global rules — read the file in agentic_workflow first; it's small
# (the file isn't versioned in agentic_workflow because it's user-config, but the
# install record in docs/conversation_log/08_continuity_rollout.md tells you what
# to put in it). Or copy from this kit's docs/rules-reference.md (TODO).

# 2. Skills + hooks + agents are versioned in agentic_workflow's predecessor
# session record. The 2026-04-24 commits in agentic_workflow walk through
# what each file contains. For v1 of this kit, copy them by hand.

# 3. Register hooks in ~/.claude/settings.json:
cat > ~/.claude/settings.json <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "bash $HOME/.claude/hooks/co-authored-by.sh" }] },
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "bash $HOME/.claude/hooks/active-jobs-guard.sh" }] }
    ]
  }
}
JSON
```

A future kit version may include a `scripts/install-continuity-layer.sh` that does this automatically. For now, manual is intentional — you should read each file before sourcing.

## Verifying install

```bash
# Skills discoverable?
ls ~/.claude/skills/   # → brief checkpoint recall review spec

# Hooks executable?
[ -x ~/.claude/hooks/co-authored-by.sh ] && echo "co-authored-by ok"
[ -x ~/.claude/hooks/active-jobs-guard.sh ] && echo "active-jobs ok"

# Hooks fire correctly?
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: x\""}}' | \
    bash ~/.claude/hooks/co-authored-by.sh
# Should output JSON containing "permissionDecision": "ask"

echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.py"}}' | \
    bash ~/.claude/hooks/active-jobs-guard.sh
# Should output nothing (no active jobs locked)
```

If all three checks pass, the continuity layer is live. Open a fresh Claude Code session and try `/brief` — if the slash command resolves, you're set.

## Without the continuity layer

The kit's templates still produce a working repo. Specifically:

- `CLAUDE.md` references `~/.claude/CLAUDE.md` §1–§7 but doesn't depend on it being there
- The bootstrap prompt (`prompts/bootstrap.md`) is self-contained — Claude Code can run it without any local skills
- The CLI (`scripts/new-repo.sh`) has zero dependency on the layer

You just lose the deterministic enforcement and the cross-session retrieval. Plan to install the layer when the cost of *not* having it (forgotten trailers, drift in long sessions) starts to bite.

## Source

The full implementation history is in [`TobiasEdman/agentic_workflow`](https://github.com/TobiasEdman/agentic_workflow):

- `docs/rollout_plan.md` — the original 4-wave plan
- `docs/rollout_progress.md` — what shipped, with commit hashes
- `docs/conversation_log/08_continuity_rollout.md` — the install record
- `docs/conversation_log/09_continuity_month1.md` — the rollout-day audit (the empirical case for hooks)
