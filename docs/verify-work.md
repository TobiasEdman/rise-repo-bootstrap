# Verify work — rule §6 deep dive

> "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do." — Anthropic Best Practices

The single most-cited finding from the agentic_workflow retrospective. Every produced repo gets a verification convention in its `CLAUDE.md`. This document explains what to put there, by repo type.

## The shape

Every CLAUDE.md should answer: *what concrete artifact proves a non-trivial change works?* The answer is type-specific.

```markdown
## Verifierings-konvention (repo-specifik tolkning av rule §6)

For each non-trivial change, provide a verification artifact:

- <type-1 changes>: <verification command/process>
- <type-2 changes>: <verification command/process>
- <fallback>: <something the human can run manually if the above don't apply>

Without a verification artifact: no commit.
If verification is impossible in this environment, say so explicitly
and ask the user to verify before closing the task.
```

## Per-stack templates

The `new-repo.sh` CLI fills `{{VERIFY_WORK_SECTION}}` based on `--stack`:

### Python library

```markdown
- Code change: `pytest tests/` passes (existing + new tests for the change).
- Schema/contract change: `pytest tests/test_schema.py -v` passes — all regression tests green.
- Public interface change: bump version in pyproject.toml + CHANGELOG line.
- Smoke: `python -c "import {{NAME}}"` succeeds (catches import-time failures).
```

### Python service / API

```markdown
- Code change: `pytest tests/` passes.
- Endpoint change: `curl` against running instance returns expected shape; capture in `tests/test_api.py`.
- Schema change: `make export && make test` (or equivalent) — exporter produces valid output against contract.
- K8s manifest change: `kubectl apply --dry-run=server -f <manifest>` validates.
- Smoke: `<service> --help` runs without traceback.
```

### Python ML / training

```markdown
- Code change: `pytest tests/` passes.
- Loss function / model architecture change: 1-epoch smoke-test locally before K8s submit.
- Data pipeline change: re-run on a known tile, compare bit-equality against cached reference.
- Schema change: regression tests against historical training_log.json must pass.
- Tile fetch change: verify against known tile, no behavior change to existing tiles.
- Without a smoke-test that actually trains for ≥1 step: no commit.
```

### Web visualization (HTML/JS)

```markdown
- Visual change: screenshot before + after; no unintended diffs in unrelated regions.
- Data change: load data file in browser, verify rendering works end-to-end.
- New feature: dashboard renders in <2s, no console errors.
- Layout change: test at 3 viewport sizes (mobile/tablet/desktop).
```

### Documentation-only / governance

```markdown
- Markdown change: `markdown-lint` clean, no broken internal links, GitHub renders correctly.
- Diagrams: regenerate from source; commit both source + rendered version.
- Decision changes: cite the meeting / Slack thread / source where the decision was made.
- For "fresh write" requests: do NOT carry old draft forward; start from structured findings (per pitfalls.md §7).
```

### Mixed stack / no specific stack

```markdown
- Make a one-line note in the commit message about *how* you verified.
  Examples: "verified: tests pass", "verified: opened in browser, layout OK",
  "verified: schema-validated against contract.py".
- If verification is impossible (typo fix, comment change), state that
  in the commit message: "trivial; no verification needed."
- Without either: no commit.
```

## Choosing a verification, by change type

| Change | What to verify | How |
|---|---|---|
| Bug fix | The bug doesn't reproduce | Add a regression test that fails before, passes after |
| New feature | Happy path works | Test or screenshot capturing the new behavior |
| Refactor | Old behavior preserved | Existing tests pass; bonus: add a test that locks the contract |
| Performance | Baseline didn't regress | Microbenchmark or `time` measurement, before/after |
| Dependency bump | Nothing broken | Full test suite passes; smoke any binaries the dep affects |
| Schema/contract | Backward compatibility (or explicit version bump) | Schema regression tests; if breaking, bump version |
| Config/manifest | Validates against schema | `kubectl apply --dry-run=server` or equivalent |
| Documentation | Links work, examples run | Markdown linter; copy-run any code blocks |

## Anti-patterns

- **"It compiles" is not verification.** That's a syntax check, not a behavior check.
- **"Looks right" is not verification.** Eye-balling code is fine for review; not for declaring done.
- **Mocking what you're trying to test.** If you're testing the database integration, hit a real database. The 2026 lesson: "we got burned last quarter when mocked tests passed but the prod migration failed."
- **Skipping verification on "trivial" changes that touch >2 files.** A typo in one file is trivial. A typo across three files is grep-and-replace, which can introduce errors. Verify those.

## When you genuinely can't verify

State it explicitly:

```
This change cannot be verified in this environment because:
- requires a running Neo4j cluster
- requires Vinnova API access
- requires a GPU

Asking user to verify by running: <command>
```

This is honest and gives the user the information they need to do the check themselves. It's strictly better than committing silently and hoping.

## Source

`agentic_workflow/docs/lessons/external_patterns.md` §C2 (Convergence 02 — Verification is the highest-leverage move). Anthropic Best Practices §1. Multiple sessions across the corpus where missing verification cost rework.
