# Examples

Real repos that demonstrate the principles this kit operationalizes. Look here for "what good looks like" before you bootstrap your own.

## Repos that influenced the kit

These predate the kit but are the source material. Useful for seeing the patterns at full maturity in real production code.

| Repo | License | What to study |
|---|---|---|
| [`TobiasEdman/imintengine`](https://github.com/TobiasEdman/imintengine) | CC0-1.0 | The CLAUDE.md structure (the kit's `templates/CLAUDE.md.tmpl` is distilled from this). The `THIRD_PARTY_LICENSES.md` pattern for projects with mixed-license dependencies. RISE's CC0 default for research output. |
| [`TobiasEdman/swedish-space-ecosystem-v2`](https://github.com/TobiasEdman/swedish-space-ecosystem-v2) | (private) | The 4 path-scoped rules in `.claude/rules/` (contract.md, etl.md, files.md, deploy.md) — the cleanest example of W2.4 in production. Strict ETL dependency direction. |
| [`TobiasEdman/swedish-space-ecosystem-viz`](https://github.com/TobiasEdman/swedish-space-ecosystem-viz) | Apache-2.0 | The Apache-2.0 LICENSE + NOTICE split that GitHub correctly identifies. Pure HTML/JS frontend with no build system. |
| [`TobiasEdman/des-chatbot`](https://github.com/TobiasEdman/des-chatbot) | Apache-2.0 | Same Apache-2.0 pattern as viz. FastAPI backend + WordPress integration. OpenTelemetry fail-open instrumentation per W2.2. |
| [`TobiasEdman/des-contracts`](https://github.com/TobiasEdman/des-contracts) | MIT | Shared-contracts pattern — extracted package consumed by 5 sister repos. CI matrix testing. v0.1.0 git tag → consumers pin to it. |
| [`TobiasEdman/agentic_workflow`](https://github.com/TobiasEdman/agentic_workflow) | (private) | The retrospective. Read `docs/lessons/multi_angle_report.md` first; that's where most of this kit's principles come from. |

## Repos bootstrapped *with* the kit

(Empty for now — first ones land soon. PRs welcome to add yours here.)

| Repo | Bootstrapped | Stack | Notes |
|---|---|---|---|
| TBD |  |  |  |

## How to read these

Don't try to copy any of these wholesale. Each has accumulated repo-specific decisions over months that don't apply to your new repo. The kit's templates are *distillations* — they capture the parts that travel.

For a *new* repo, run the kit. For *understanding* the principles, read these.
