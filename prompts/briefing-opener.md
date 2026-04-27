# Briefing opener — for non-trivial work in any repo

The single highest-leverage pattern from the agentic_workflow retrospective: a heavy first turn that front-loads paths, env, prior attempts, non-goals, tool preferences. Pay 5 minutes here, save 50 minutes of mis-steered tool calls later.

Use this when:

- A task touches >2 files
- A task needs >3 tool calls
- The bug or feature is non-trivial enough that you'd want a plan before code

For trivial work (typo fix, single-file edit, one-command shell), skip this and just ask. The briefing is not always-on; it's a tool for the cases that benefit.

If you have the `~/.claude/` continuity layer installed, use `/brief` instead — it asks the questions interactively. This file is the standalone fallback.

---

## The template — copy, fill in, paste as your first message

```
I need help with: <one-line task description>

## Project location
- Project root: <absolute path>
- Python env / runtime: <absolute path or "n/a">
- Key files:
  - <path> — <one-line role>
  - <path> — <one-line role>

## What I already tried (and why it's suspect)
- <attempted approach 1> — suspect because: <why>
- <attempted approach 2> — suspect because: <why>

## What I want from this session
[ ] A plan before any code is written
[ ] A specific bug fixed in <file:line>
[ ] An explanation of <X>
[ ] Other: <describe>

## Non-goals (out of scope this session)
- <thing the model might pattern-match to but shouldn't pursue>
- <feature that's tangentially related but not on the table>

## Tool preferences
- <e.g. "use the preview tool, not Chrome DevTools">
- <e.g. "no agent delegation; main thread only">

## Constraints
- <e.g. "production fetch is running on the cluster — read-only">
- <e.g. "this is for a customer demo Friday">
```

---

## Why each section earns its keep

### "What I already tried"

The single most valuable section. Without it, Claude pattern-matches to "the obvious fix" and proposes things you've already ruled out. Listing what you tried *and why each suspect* lets Claude challenge each suspect rather than re-derive them.

Source: `agentic_workflow/docs/lessons/what_worked.md` — the `here.txt` exemplar (vhr-lab Arkösund alignment) is 790 words at turn 0 and produced the cleanest planning of the whole corpus.

### "What I want from this session"

Stops the most common drift: you ask "how does this work?", Claude reads it as "fix it", and starts editing. Explicitly checking *plan / fix / explain* keeps the response in the right mode.

Source: `pitfalls.md` §1 (diagnosis-read-as-directive). Cost: three explicit STOPs in one session.

### "Non-goals"

Especially valuable in long sessions. The 130k-word ImintEngine session drifted across 4 sub-topics partly because the original boundary was never stated. State it.

Source: `pitfalls.md` §2.

### "Tool preferences"

Stated once *and asked to be echoed back* (per global rule §2) — preferences then carry across the session instead of re-drifting. Without this, "use the preview tool" gets reverted to Chrome DevTools within ~10 turns.

Source: `instruction_adherence.md` case 3.

### "Constraints"

Catches the high-cost case where Claude edits live code while you ask status questions. State explicitly that production fetches / running training jobs / live customers exist.

Source: `pitfalls.md` §5.

---

## Mini version (for medium-trivial work)

If the full template feels heavy, a 4-line version still helps:

```
Task: <what>
Files: <where>
Tried: <briefly>
Want: plan / fix / explain (pick one)
```

Anything is better than a one-line ask for non-trivial work.
