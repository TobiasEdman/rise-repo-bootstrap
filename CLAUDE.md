# Claude Code Instructions — rise-repo-bootstrap

## Repo-identitet

- **Namn:** rise-repo-bootstrap
- **Domän:** Starter kit / template-repo för nya RISE-repon. Distillerar continuity-layer-principerna från `agentic_workflow` så de kan appliceras prospektivt.
- **Nyckelgränssnitt:** `bash scripts/new-repo.sh <name> [opts]` (CLI) och `prompts/bootstrap.md` (Claude Code interview).
- **Beroenden:** Inga runtime. Mall-templates förutsätter att slutanvändaren har bash 4+, `gh` CLI (om GitHub-skapande), och Python 3.11+ (om stack=python).

---

## Detta repo dogfoodar sig självt

Filerna i topp-nivån (`README.md`, `LICENSE`, `NOTICE`, `CLAUDE.md`, `.gitignore`) skapades genom att tillämpa kit:ets egna mallar på sig självt. Om något ser konstigt ut i topp-nivån — kolla först om motsvarande mall i `templates/` har samma problem.

---

## Globala regler

Detta repo följer reglerna i `~/.claude/CLAUDE.md` §1–§7 (diagnos vs direktiv, echo-back, running code is read-only, mid-session re-anchor, front-load turn 0, verify_work, attribution).

Om du läser detta utan att ha `~/.claude/CLAUDE.md` installerad: se [`docs/continuity-layer.md`](docs/continuity-layer.md) för installation.

---

## Verifierings-konvention (repo-specifik tolkning av rule §6)

Detta är ett kit-repo. Verifiering = "kit:et fungerar end-to-end på ett wegwerf-target":

1. **Lint:** `shellcheck scripts/new-repo.sh scripts/lib/*.sh` passerar.
2. **Smoke:** `bash scripts/new-repo.sh /tmp/bootstrap-smoke-$(date +%s) --domain "test" --stack python --license apache --private --no-create-github` skapar en mapp utan fel.
3. **Substitution complete:** `grep -r "{{" /tmp/bootstrap-smoke-*` returnerar inget.
4. **Producerad repo bygger:** `cd /tmp/bootstrap-smoke-* && pytest` passerar (smoke-test grön).
5. **Produced LICENSE detekterbar:** efter `gh repo create` säger `gh repo view --json licenseInfo` rätt licens.

Om alla 5 passerar: kit:et fungerar. Cleanup `/tmp/bootstrap-smoke-*` efter.

---

## Arkitekturregler

- **Templates har {{vars}}, inte magiska placeholders.** Substitution sker via `scripts/lib/substitute.sh`. Synligt = lätt att felsöka.
- **Kit:et antar inte ~/.claude/.** Mallar refererar till global continuity-layer som *rekommendation*, inte *requirement*. En kollega utan Claude Code ska kunna använda kit:et.
- **Inga runtime-deps.** Bash + sed + grep. Inget pip, inget node_modules. Den enda externa CLI:n vi anropar är `gh` (för GitHub-skapande), och bara om användaren bett om det.
- **Stack-agnostisk default.** Python är default-stack (matchar 80% av RISE-repon), men `--stack none` ska producera ett doc-only repo som funkar.

---

## Kodgranskningsstandard

Detta repo har inga produktionskonsumenter — det producerar bara nya repon. Kodstandard:

- Bash-mallar måste passera shellcheck.
- Markdown-filer ska vara läsbara på GitHub (inga brutna länkar, inga misformade tabeller).
- Templates som producerar Python-kod ska producera kod som passerar `python -m py_compile`.
- LICENSE-filerna är *exakt* identiska boilerplate för att GitHub:s license-detector ska klassificera dem korrekt — modifiera inte.

---

## Filer som måste matcha andra filer

- `templates/CLAUDE.md.tmpl` — mall som *liknar* (men inte är identisk med) detta repos CLAUDE.md. Strukturen ska följa, men de lokala detaljerna är annorlunda.
- `LICENSE` (Apache-2.0) — ska vara byte-för-byte identisk med `templates/LICENSE-Apache-2.0`.
- `templates/NOTICE.tmpl` — ska producera NOTICEs i samma format som detta repos NOTICE.

<!-- agentic-task:coordination:start -->
## Cross-runtime coordination mechanics

Shared policy lives in `AGENTS.md`. Claude-specific hooks may enforce it but
must not weaken or duplicate that policy. Use a Claude worktree for every
writing session and the vendor-neutral `agentic-task` CLI for task claims.
<!-- agentic-task:coordination:end -->
