# rise-repo-bootstrap

A starter kit for new RISE repositories that follow the **continuity-layer** principles distilled from a year of Claude Code sessions across the RISE / Digital Earth Sweden portfolio.

> "Every high-cost failure mode was a continuity failure" — `agentic_workflow/docs/lessons/multi_angle_report.md`. This kit is the prospective answer.

## What you get

A new repo, in 60 seconds, with:

- **CLAUDE.md** — repo-identity, verify-work convention, hooks into the global `~/.claude/CLAUDE.md` rules (§1–§7).
- **LICENSE + NOTICE** — picked via decision tree (RISE-direct → CC0, sub-project → Apache-2.0, personal → MIT).
- **`.gitignore`** — Python + Node + macOS + RISE patterns (`.env`, `data/`, `secrets/`).
- **`pyproject.toml`** — pinned deps, `[dev]` + `[observability]` extras (Python stack only).
- **GitHub Actions CI** — matrix testing, smoke gate.
- **`.claude/rules/`** — placeholder for path-scoped rules (per W2.4 of the rollout plan).
- **`tests/test_smoke.py`** — minimal pytest so CI lands green from commit 1.

## 60-second quickstart

```bash
git clone https://github.com/TobiasEdman/rise-repo-bootstrap.git
cd rise-repo-bootstrap
bash scripts/new-repo.sh my-new-thing
```

The script asks classification questions (name, domain, stack, license, public/private) and produces `./my-new-thing/` ready to push.

For non-interactive use:

```bash
bash scripts/new-repo.sh my-new-thing \
    --domain "Geospatial coastal monitoring" \
    --stack python \
    --license apache \
    --private \
    --ci
```

## Or use Claude Code

Open a fresh Claude Code session in the directory above where you want the new repo, paste the contents of [`prompts/bootstrap.md`](prompts/bootstrap.md), and follow the interview. Claude does the same thing the CLI does, but with explanations as you go.

## What's in here

| Path | What |
|---|---|
| [`docs/principles.md`](docs/principles.md) | Why these templates exist (condensed from the agentic_workflow retrospective) |
| [`docs/continuity-layer.md`](docs/continuity-layer.md) | What `~/.claude/` is, what to install, why |
| [`docs/license-decision.md`](docs/license-decision.md) | RISE-flavored license decision tree |
| [`docs/verify-work.md`](docs/verify-work.md) | Rule §6 deep dive — verification per repo type |
| [`templates/`](templates/) | The actual template files (`.tmpl` = `{{vars}}` substituted) |
| [`prompts/`](prompts/) | Copy-paste prompts for Claude Code |
| [`scripts/new-repo.sh`](scripts/new-repo.sh) | The CLI |
| [`examples/`](examples/) | Links to bootstrapped repos |

## Requirements

- bash 4+
- `gh` CLI (for `--create-github`); not required if you skip GitHub creation
- Python 3.11+ (only if `--stack python`)
- macOS or Linux (Windows: WSL works)

## Recommended (not required)

The kit produces a great starting repo on its own. To get the full continuity-layer experience, install [Claude Code](https://docs.anthropic.com/claude-code) and the `~/.claude/` continuity layer — see [`docs/continuity-layer.md`](docs/continuity-layer.md).

## Origin

This kit was built 2026-04-27 from the principles in [`TobiasEdman/agentic_workflow`](https://github.com/TobiasEdman/agentic_workflow), which is the retrospective analysis of 31 archived Claude Code sessions across the RISE / Digital Earth Sweden / Imint Engine portfolio (Feb–Sep 2026). Where `agentic_workflow` is *retrospective* (what happened, what we learned), this kit is *prospective* (apply the lessons to a new repo from day 1).

## License

Apache-2.0 (RISE Research Institutes of Sweden AB). The kit is meant to be forked and adapted; Apache-2.0 lets you do that with explicit patent grant + NOTICE-attribution path.

The license that the kit *produces for your new repo* is your choice (CC0, Apache-2.0, or MIT) — see [`docs/license-decision.md`](docs/license-decision.md).
