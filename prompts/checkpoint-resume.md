# Checkpoint resume — start a session that continues from a previous one

The cross-session continuity move. Instead of opening Claude Code in a repo and asking "what was I doing?", paste a previous checkpoint as your opener and Claude resumes intent, not just files.

Requires you to have written a checkpoint at the end of a previous session — see [`prompts/briefing-opener.md`](briefing-opener.md) and the `/checkpoint` skill if installed.

If you have the `~/.claude/` continuity layer with `omni-rag` ingesting your checkpoint store, use `/recall` instead of this file — it does the lookup automatically. This file is the standalone fallback.

---

## Template

```
Resume from this checkpoint:

<paste contents of ~/.claude/checkpoints/<repo>/<latest-file>.md>

We were working in <repo>. The "Active goal" above is what we should pick
back up.

Before doing anything, please:
1. Confirm the active goal in your own words.
2. Cite the "Files that must NOT change" section verbatim.
3. Ask if the next 3 steps from the checkpoint are still the right ones,
   or if anything has shifted since the checkpoint was written.

Do not start editing until I confirm.
```

---

## Why each instruction earns its keep

### "Confirm the active goal in your own words"

Forces Claude to read the goal section, not just have it in context. If Claude paraphrases incorrectly, you catch the misunderstanding immediately rather than 10 turns into wrong work.

### "Cite 'Files that must NOT change' verbatim"

Same purpose. The off-limits list is the most important and least likely-to-be-followed part of a checkpoint.

### "Ask if the next 3 steps are still right"

Time has passed between checkpoint write and resume. Maybe a customer pivoted, maybe you decided overnight to skip step 2. Asking before assuming saves rework.

### "Do not start editing until I confirm"

Final §3 enforcement. The checkpoint says we *were* working on X — not that you should resume and edit X right now. Wait for the imperative.

---

## If you don't have a checkpoint to paste

You haven't written one yet. Either:

1. Use `prompts/briefing-opener.md` instead (treat this as a fresh session — it is)
2. Open the previous session's transcript (if you have one) and reconstruct what the active goal was
3. Look at `git log --oneline -20` and write a quick checkpoint by hand based on the recent commits

The cost of writing checkpoints is small (~20 words) compared to the cost of rediscovery at session open. Write them.

---

## What omni-rag would do for you

If you've installed the continuity layer and have the omni-rag CLI:

```bash
# Find a relevant checkpoint
omni-rag query --repo claude-checkpoints --no-llm "what was the active goal in <repo> last week"

# Read the top hit
cat ~/.claude/checkpoints/<repo>/<top-hit>.md

# Then paste-and-resume per template above
```

Or, in a Claude Code session with the `/recall` skill:

```
/recall <repo>
```

That's the full continuity loop closed. See `docs/continuity-layer.md`.
