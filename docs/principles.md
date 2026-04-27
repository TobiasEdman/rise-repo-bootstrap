# Principles

This kit operationalizes findings from a year of Claude Code work analyzed in [`TobiasEdman/agentic_workflow`](https://github.com/TobiasEdman/agentic_workflow). The findings are documented in detail there; this file is the condensed *what* and *why* — enough to motivate every choice you'll see in the templates.

## The one-line takeaway

> Every high-cost failure mode was a continuity failure.

Long-session drift, rule violations, rediscovery at session open, intent lost between turns, tool-preference drift, bus-factor risk — all are continuity problems wearing different clothes. The kit's job is to make the continuity-supporting habits *the path of least resistance* in a new repo.

## What worked (carry forward)

The four analytical lenses (Engineer / Partner / Portfolio / Person) of the retrospective independently named the same patterns:

### 1. The briefing-driven opener

The single most reliable pattern. A first turn that includes:

- **Absolute paths** — project root, venv, key files
- **What you already tried** — and why each attempted fix is suspect
- **Plan before code** — explicit ask, not "solve this now"
- **Tool preferences** — stated up front, asked to be echoed back
- **Non-goals** — what's out of scope for this session

In the kit: [`prompts/briefing-opener.md`](../prompts/briefing-opener.md), and the `/brief` skill if you have the continuity layer installed.

### 2. Verify work before declaring done

Anthropic Best Practices: *"Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."*

In the kit: every produced repo gets a `tests/test_smoke.py` so CI lands green from commit 1 — a gate exists before you've even written code. Repo-specific verification convention goes in `CLAUDE.md`.

### 3. Per-task commits

Small commits during the session, tidy-up at the end if needed. Bundling everything into one commit makes git history illegible and fights the rules that depend on commit-as-checkpoint (`/checkpoint`, drift metric).

In the kit: produced repos get a `CLAUDE.md` that references global rule §10. Hooks enforce the §7 trailer.

### 4. Front-load the first turn

For non-trivial work, pay heavily for planning clarity at the start. A 500-word briefing at turn 0 costs less than 10 mis-steered turns later.

In the kit: [`prompts/bootstrap.md`](../prompts/bootstrap.md) is itself a front-loaded prompt. The kit teaches the pattern by demonstrating it.

### 5. Mid-session re-anchor (every ~50 turns)

Long sessions drift. The 130k-word ImintEngine session accumulated 22 corrections, many undoing work on the wrong sub-topic. Mid-session checkpoints at ~50 turn boundaries catch drift before it compounds.

In the kit: produced repos get path-scoped rules in `.claude/rules/` (per W2.4 of the rollout) so guidance lives close to the code it governs, instead of bloating CLAUDE.md.

### 6. Hooks beat advisory rules

The 2026-04-25 audit measured a 52-point compliance gap on the same rule going from text-only (35%) to deterministic hook (87%) inside one repo on one day. Lesson: any rule worth writing twice is worth converting to a hook.

In the kit: `templates/.claude/settings.json.tmpl` shows the hook pattern (Co-Authored-By trailer, active-jobs-guard) without forcing it. Strongly recommended; not mandatory.

## Anti-patterns to avoid

The retrospective documented 13 specific anti-patterns. Three matter most:

### Diagnosis read as directive

"The bug is X" → Claude starts fixing X. Sometimes you wanted that; sometimes you were thinking out loud. Worse in Swedish (where imperative and interrogative forms sit closer than in English).

**Mitigation in the kit:** rule §1 in the global `~/.claude/CLAUDE.md` explicitly handles this. The kit assumes that rule is in effect; produced `CLAUDE.md` files reference it.

### Long-session drift

Sessions past ~1000 turns without re-anchor drift across 4+ sub-topics. The 130k-word session is the canonical example.

**Mitigation in the kit:** every produced repo gets a `CLAUDE.md` that prescribes the `/checkpoint` cadence (drift mode every ~50 turns; milestone mode at task boundaries).

### Editing live code while user asks status

The most expensive single failure mode in the corpus. Cost: real production risk on a Kubernetes cluster.

**Mitigation in the kit:** `.claude/settings.json.tmpl` shows the `active-jobs-guard.sh` PreToolUse hook pattern. With the guard installed and a sentinel file in `~/.claude/active-jobs/`, Edit/Write operations on running code surface a UI confirmation prompt instead of going through silently.

## What this kit deliberately does *not* do

- **Doesn't enforce a stack.** Default templates are Python, but `--stack none` produces a doc-only repo and `.gitignore` covers Node patterns.
- **Doesn't force `~/.claude/`.** Templates reference the continuity layer as a *recommendation*. A colleague who hasn't installed Claude Code can still use the kit.
- **Doesn't replicate W4 productization patterns by default.** FastAPI/K8s/Docker patterns from the rollout are out-of-scope for v1 — they get added when someone needs them.
- **Doesn't gate on RISE membership.** Apache-2.0 license on the kit, generic structure. Useful inside RISE; not exclusive to it.

## Source documents

- `agentic_workflow/docs/lessons/multi_angle_report.md` — four-lens synthesis (the strongest section)
- `agentic_workflow/docs/lessons/what_worked.md` — patterns to keep
- `agentic_workflow/docs/lessons/pitfalls.md` — patterns to avoid
- `agentic_workflow/docs/lessons/instruction_adherence.md` — where rules bent
- `agentic_workflow/docs/conversation_log/09_continuity_month1.md` — the rollout-day audit measuring hook vs advisory
