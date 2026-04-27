# Bootstrap prompt — paste this into a fresh Claude Code session

Copy the everything-below-the-line and paste it as your first message in a Claude Code session opened in the directory **above** where you want the new repo to live (e.g. open Claude Code in `~/Developer/`, not in `~/Developer/my-new-thing/`).

This prompt assumes the user (you) has already cloned `rise-repo-bootstrap` somewhere reachable. If not, do that first:

```bash
git clone https://github.com/TobiasEdman/rise-repo-bootstrap.git ~/Developer/rise-repo-bootstrap
```

The prompt is self-contained — it works whether or not you've installed the `~/.claude/` continuity layer. It will tell you what's missing if anything matters.

---

## The prompt

You are Claude Code helping the user bootstrap a new repository following the principles distilled in `rise-repo-bootstrap`. The kit lives at `~/Developer/rise-repo-bootstrap` (clone if needed: `git clone https://github.com/TobiasEdman/rise-repo-bootstrap.git ~/Developer/rise-repo-bootstrap`).

## Goal

Produce a new repo at `./<NAME>/` that follows the continuity-layer principles from day 1: CLAUDE.md, LICENSE+NOTICE, .gitignore, optional pyproject + CI, optional GitHub repo created.

## Step 1 — interview the user via AskUserQuestion

Ask, in this order. Use AskUserQuestion (not free-form text):

1. **Repo name** (kebab-case, no path). Validate: lowercase, alphanumeric + dashes only, no leading/trailing dash.

2. **Domain** — one sentence describing what this repo does. This becomes the project description in pyproject.toml + README.

3. **Stack:**
   - `python` (default — pyproject.toml + pytest + ruff + CI)
   - `node` (skipped in v1 — falls back to `none`)
   - `none` (doc-only / governance repo, no language scaffold)

4. **License classification** — read from `~/Developer/rise-repo-bootstrap/docs/license-decision.md` first if uncertain. Ask:
   - "Is this RISE-direct research output, a sub-project (DES, Vinnova-funded thread, etc.), or personal work outside RISE?"
   - Map: RISE-direct → `cc0`, sub-project → `apache`, personal → `mit`.
   - Show the suggestion. Let the user override.

5. **Visibility:** public or private. If public + license is "none" (proprietary), warn that public-without-license is strictly worse than private-without-license (per the 2026-04-26 audit finding) — ask if they want to pick a license or keep private.

6. **CI scaffold?** Default Y for stack=python, N for stack=none. (CI for HTML/JS not in v1.)

7. **Create on GitHub now?** Y/N. If Y: confirm `gh auth status` is logged in.

## Step 2 — show the command, wait for "kör"

Show the exact `bash scripts/new-repo.sh ...` command you'd run. Show *all* the flags. Wait for explicit user approval (Swedish "kör" or English "go" or "run") before executing. Do NOT auto-run.

This matches global rule §3 — even though the user said "bootstrap a repo", concrete shell execution gets one final confirmation.

## Step 3 — execute and verify

Run the script. Then verify:

1. Target directory exists: `ls <NAME>/`
2. No template variables leaked: `grep -r "{{" <NAME>/` returns nothing
3. If stack=python: `cd <NAME> && pytest tests/` passes
4. If GitHub creation: `gh repo view <user>/<NAME> --json licenseInfo` returns the right license
5. First commit has the §7 Co-Authored-By trailer

If any verification fails: stop, report, ask the user how to proceed. Do not silently retry.

## Step 4 — wrap-up

Report:

- Repo created at `./<NAME>/` (or `<github-url>` if pushed)
- License set to `<license>`
- CI status (if applicable)
- Next steps the user should consider:
  - Edit `<NAME>/README.md` to flesh out the description
  - Edit `<NAME>/CLAUDE.md` to fill in repo-identity and architecture rules as they emerge
  - If they don't yet have `~/.claude/` continuity layer installed, suggest reading `~/Developer/rise-repo-bootstrap/docs/continuity-layer.md`

## Constraints — global rules apply

This is a Claude Code session, so all the rules in `~/.claude/CLAUDE.md` apply:

- **§1 (diagnosis vs directive)**: if the user is asking about how the kit works, *don't* start running scripts. Answer the question, wait for an imperative.
- **§5 (front-load)**: this prompt itself is the front-loaded turn 0. If the user asks for a non-trivial customization mid-flow ("can you also set up Docker?"), stop and ask whether they want to scope-creep this session or finish the bootstrap first.
- **§6 (verify work)**: every command run gets verified. No "should be fine" without evidence.
- **§7 (Co-Authored-By trailer)**: the first commit (made by the script) includes the trailer. If the hook is installed, it will catch missing trailers automatically.

## If the user has *not* installed the continuity layer

Run the bootstrap anyway. After completion, include in the wrap-up: "I noticed `~/.claude/CLAUDE.md` doesn't exist on this machine. The repo I just created references it — that's fine, it's just a documentation hook. To get the deterministic enforcement (Co-Authored-By trailer, running-code guard, /brief and /checkpoint skills), see `~/Developer/rise-repo-bootstrap/docs/continuity-layer.md`."

Don't try to install the continuity layer yourself — that's a separate, deliberate decision the user should make consciously.

---

End of prompt. Paste it into your Claude Code session and follow.
