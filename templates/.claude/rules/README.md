# Path-scoped rules

This directory holds **path-scoped rules** — Claude Code guidance that loads only when working in specific paths. Per agentic_workflow rollout W2.4 and the lessons in `pitfalls.md` §12 (bloated CLAUDE.md = ignored CLAUDE.md), prefer keeping CLAUDE.md under ~200 lines and putting topic-specific guidance here.

## Format

Each rule file has frontmatter declaring its path scope:

```markdown
---
paths:
  - "etl/**/*.py"
  - "export/**/*.py"
---

# Rule title

Rule body. Loads only when Claude is editing a file matching one of the paths.
```

## Examples to learn from

The `swedish-space-ecosystem-v2` repo has 4 path-scoped rules that were extracted from a previously-bloated CLAUDE.md as part of W2.4:

- `.claude/rules/contract.md` — Pydantic contract + versioning rules; loads on `export/contract.py` + `export/view_exporter.py`
- `.claude/rules/etl.md` — ETL pipeline strict rules (extractor / loader / resolver / exporter); loads on `etl/**/*.py`
- `.claude/rules/files.md` — curated YAML invariants; loads on `curated/**/*.yaml`
- `.claude/rules/deploy.md` — destructive command guard; loads on `scripts/deploy_viz.sh` + Makefile

## When to add a rule here

Add a rule file when:

1. A topic in CLAUDE.md is large enough that it pushes the file past 200 lines
2. Rule content only matters when working in specific paths (an ETL rule isn't useful when editing the README)
3. A rule needs to *override* a more general CLAUDE.md statement for a specific subsystem

Don't add a rule here if:

- It applies repo-wide (keep it in CLAUDE.md)
- It's a one-time decision (put it in a commit message or a doc, not in agent guidance)
- It's a comment about "how things used to be" (use git log)
