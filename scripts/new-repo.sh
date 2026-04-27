#!/usr/bin/env bash
#
# new-repo.sh — bootstrap a new repo from rise-repo-bootstrap templates
#
# Usage:
#   bash new-repo.sh <name> [opts]
#   bash new-repo.sh           # interactive (asks all questions)
#
# Options:
#   --domain "<text>"      one-sentence project description
#   --stack python|none    default: python
#   --license cc0|apache|mit|none   default: apache
#   --public | --private   default: private
#   --ci | --no-ci         default: ci if stack=python
#   --create-github | --no-create-github   default: ask
#   --target-dir <path>    parent dir for the new repo (default: $PWD)
#   --copyright-holder "<name>"   default: "RISE Research Institutes of Sweden AB"
#   --copyright-year <yyyy>       default: current year
#   -h | --help
#
# Example:
#   bash new-repo.sh my-thing \
#       --domain "Geospatial coastal monitoring" \
#       --stack python --license apache --private --ci --create-github
#
# Verification (per agentic_workflow rule §6): after generation, this script
# confirms no {{vars}} remain, runs pytest if Python, and reports.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$KIT_ROOT/templates"

# shellcheck source=lib/substitute.sh
source "$SCRIPT_DIR/lib/substitute.sh"
# shellcheck source=lib/classify.sh
source "$SCRIPT_DIR/lib/classify.sh"

# ── defaults ─────────────────────────────────────────────────────────────────

NAME=""
DOMAIN=""
STACK=""
LICENSE_KEY=""
VISIBILITY=""
ENABLE_CI=""
CREATE_GITHUB=""
TARGET_PARENT="$PWD"
COPYRIGHT_HOLDER="RISE Research Institutes of Sweden AB"
COPYRIGHT_YEAR="$(date +%Y)"

usage() {
    sed -n '3,24p' "${BASH_SOURCE[0]}" | sed 's/^# //; s/^#$//'
    exit "${1:-0}"
}

# ── parse flags ──────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain) DOMAIN="$2"; shift 2 ;;
        --stack)  STACK="$2"; shift 2 ;;
        --license) LICENSE_KEY="$2"; shift 2 ;;
        --public) VISIBILITY="public"; shift ;;
        --private) VISIBILITY="private"; shift ;;
        --ci) ENABLE_CI=1; shift ;;
        --no-ci) ENABLE_CI=0; shift ;;
        --create-github) CREATE_GITHUB=1; shift ;;
        --no-create-github) CREATE_GITHUB=0; shift ;;
        --target-dir) TARGET_PARENT="$2"; shift 2 ;;
        --copyright-holder) COPYRIGHT_HOLDER="$2"; shift 2 ;;
        --copyright-year) COPYRIGHT_YEAR="$2"; shift 2 ;;
        -h|--help) usage 0 ;;
        --*) echo "unknown flag: $1" >&2; usage 2 ;;
        *) [[ -z "$NAME" ]] && NAME="$1" && shift || { echo "unexpected arg: $1" >&2; usage 2; } ;;
    esac
done

# ── classify ────────────────────────────────────────────────────────────────

if [[ -z "$NAME" || -z "$DOMAIN" || -z "$STACK" || -z "$LICENSE_KEY" || -z "$VISIBILITY" || -z "${ENABLE_CI}" || -z "${CREATE_GITHUB}" ]]; then
    classify_interactive
else
    classify_validate
fi

TARGET="$TARGET_PARENT/$NAME"

if [[ -e "$TARGET" ]]; then
    echo "error: target already exists: $TARGET" >&2
    exit 1
fi

# ── derive license-related vars ──────────────────────────────────────────────

LICENSE_FILE=""
LICENSE_SPDX=""
LICENSE_NAME=""
NEEDS_NOTICE=0

case "$LICENSE_KEY" in
    cc0)
        LICENSE_FILE="$TEMPLATES_DIR/LICENSE-CC0-1.0"
        LICENSE_SPDX="CC0-1.0"
        LICENSE_NAME="Creative Commons Zero v1.0 Universal"
        ;;
    apache)
        LICENSE_FILE="$TEMPLATES_DIR/LICENSE-Apache-2.0"
        LICENSE_SPDX="Apache-2.0"
        LICENSE_NAME="Apache License 2.0"
        NEEDS_NOTICE=1
        ;;
    mit)
        LICENSE_FILE="$TEMPLATES_DIR/LICENSE-MIT"
        LICENSE_SPDX="MIT"
        LICENSE_NAME="MIT License"
        ;;
    none)
        LICENSE_FILE=""
        LICENSE_SPDX="UNLICENSED"
        LICENSE_NAME="Proprietary"
        ;;
esac

# ── derive verify-work section by stack ──────────────────────────────────────

case "$STACK" in
    python)
        VERIFY_WORK_SECTION="- Code change: \`pytest tests/\` passes (existing + new tests for the change).
- Public interface change: bump version in pyproject.toml + CHANGELOG line.
- Smoke: \`python -c \"import ${NAME//-/_}\"\` succeeds (catches import-time failures)."
        VERIFY_COMMAND="pytest tests/"
        SETUP_SECTION="\`\`\`bash
python -m venv .venv
source .venv/bin/activate
pip install -e \".[dev]\"
\`\`\`"
        ;;
    none)
        VERIFY_WORK_SECTION="- Markdown change: GitHub renders correctly, no broken internal links.
- Diagrams: regenerate from source; commit both source + rendered version.
- For \"fresh write\" requests: do NOT carry old draft forward; start from structured findings (per pitfalls.md §7)."
        VERIFY_COMMAND="# (no automated verify for doc-only repos — see CLAUDE.md)"
        SETUP_SECTION="No build step. Open the markdown files in your editor or browser."
        ;;
esac

# License-line for README
case "$LICENSE_KEY" in
    cc0)    LICENSE_LINE="CC0-1.0 (public domain dedication). See [LICENSE](LICENSE)." ;;
    apache) LICENSE_LINE="Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE)." ;;
    mit)    LICENSE_LINE="MIT. See [LICENSE](LICENSE)." ;;
    none)   LICENSE_LINE="Proprietary. All rights reserved." ;;
esac

# ── show plan + confirm ──────────────────────────────────────────────────────

cat <<EOF

╭────────────────────────────────────────────────────────────────────╮
│ rise-repo-bootstrap — plan                                         │
├────────────────────────────────────────────────────────────────────┤
│ name              $NAME
│ domain            $DOMAIN
│ stack             $STACK
│ license           $LICENSE_KEY  ($LICENSE_NAME)
│ visibility        $VISIBILITY
│ ci scaffold       $([[ $ENABLE_CI -eq 1 ]] && echo "yes" || echo "no")
│ create on github  $([[ $CREATE_GITHUB -eq 1 ]] && echo "yes" || echo "no")
│ target            $TARGET
│ copyright         $COPYRIGHT_YEAR $COPYRIGHT_HOLDER
╰────────────────────────────────────────────────────────────────────╯

EOF

# ── generate ────────────────────────────────────────────────────────────────

DATE_TODAY="$(date +%Y-%m-%d)"
TARGET_DOTCLAUDE="$TARGET/.claude/rules"

mkdir -p "$TARGET" "$TARGET_DOTCLAUDE"

# Common substitution vars
COMMON_VARS=(
    "NAME=$NAME"
    "DOMAIN=$DOMAIN"
    "DATE=$DATE_TODAY"
    "COPYRIGHT_YEAR=$COPYRIGHT_YEAR"
    "COPYRIGHT_HOLDER=$COPYRIGHT_HOLDER"
    "LICENSE_SPDX=$LICENSE_SPDX"
    "LICENSE_NAME=$LICENSE_NAME"
    "LICENSE_LINE=$LICENSE_LINE"
    "VERIFY_WORK_SECTION=$VERIFY_WORK_SECTION"
    "VERIFY_COMMAND=$VERIFY_COMMAND"
    "SETUP_SECTION=$SETUP_SECTION"
)

substitute_file "$TEMPLATES_DIR/CLAUDE.md.tmpl" "$TARGET/CLAUDE.md" "${COMMON_VARS[@]}"
substitute_file "$TEMPLATES_DIR/README.md.tmpl" "$TARGET/README.md" "${COMMON_VARS[@]}"
cp "$TEMPLATES_DIR/.gitignore" "$TARGET/.gitignore"
cp "$TEMPLATES_DIR/.claude/rules/README.md" "$TARGET_DOTCLAUDE/README.md"

# License
if [[ -n "$LICENSE_FILE" ]]; then
    substitute_file "$LICENSE_FILE" "$TARGET/LICENSE" "${COMMON_VARS[@]}"
fi

# NOTICE for Apache
if [[ "$NEEDS_NOTICE" -eq 1 ]]; then
    NOTICE_BODY="This product includes software developed by ${COPYRIGHT_HOLDER}."
    substitute_file "$TEMPLATES_DIR/NOTICE.tmpl" "$TARGET/NOTICE" "${COMMON_VARS[@]}" "NOTICE_BODY=$NOTICE_BODY"
fi

# Stack-specific
if [[ "$STACK" == "python" ]]; then
    substitute_file "$TEMPLATES_DIR/pyproject.toml.tmpl" "$TARGET/pyproject.toml" "${COMMON_VARS[@]}"
    mkdir -p "$TARGET/tests"
    substitute_file "$TEMPLATES_DIR/tests/test_smoke.py.tmpl" "$TARGET/tests/test_smoke.py" "${COMMON_VARS[@]}"
fi

# CI
if [[ "$ENABLE_CI" -eq 1 ]]; then
    mkdir -p "$TARGET/.github/workflows"
    substitute_file "$TEMPLATES_DIR/.github/workflows/ci.yml.tmpl" "$TARGET/.github/workflows/ci.yml" "${COMMON_VARS[@]}"
fi

echo "✓ files generated in $TARGET"

# ── verify per rule §6: no {{ residue ──────────────────────────────────────
# Match {{ that is NOT preceded by $ — GitHub Actions syntax (${{ matrix.x }})
# legitimately contains {{ and we must not flag it as a template-leak.

residue="$(grep -rln -P '(?<!\$)\{\{' "$TARGET" 2>/dev/null || true)"
if [[ -n "$residue" ]]; then
    echo "✗ VERIFY FAILED: template variables still present in:" >&2
    echo "$residue" >&2
    exit 1
fi
echo "✓ no template variables remain"

# ── git init + first commit ─────────────────────────────────────────────────

cd "$TARGET"
git init -q -b main
git add .
TRAILER="Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
COMMIT_MSG="chore: initial scaffold from rise-repo-bootstrap

Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) using rise-repo-bootstrap.
Stack: $STACK. License: $LICENSE_NAME. CI: $([[ $ENABLE_CI -eq 1 ]] && echo yes || echo no).

$TRAILER"

git commit -q -m "$COMMIT_MSG"
echo "✓ git init + first commit (with §7 Co-Authored-By trailer)"

# ── stack verify ────────────────────────────────────────────────────────────

if [[ "$STACK" == "python" ]]; then
    if command -v python3 >/dev/null 2>&1; then
        if python3 -m pytest tests/ --collect-only -q >/dev/null 2>&1; then
            echo "✓ pytest can collect tests/test_smoke.py (run \"pytest\" in $NAME/ to actually execute)"
        else
            echo "⚠  pytest could not collect tests — check tests/test_smoke.py"
        fi
    fi
fi

# ── GitHub create ───────────────────────────────────────────────────────────

if [[ "$CREATE_GITHUB" -eq 1 ]]; then
    if ! command -v gh >/dev/null 2>&1; then
        echo "⚠  gh CLI not installed — skipping GitHub create. Push manually." >&2
    else
        local_visibility="--$VISIBILITY"
        gh_args=(repo create "$NAME" "$local_visibility" --description "$DOMAIN" --source=. --remote=origin)
        if gh "${gh_args[@]}" 2>/dev/null; then
            echo "✓ GitHub repo created"
            git push -q -u origin main
            echo "✓ pushed to origin/main"
        else
            echo "⚠  gh repo create failed — repo created locally only" >&2
        fi
    fi
fi

# ── done ────────────────────────────────────────────────────────────────────

cat <<EOF

✓ done.

next:
  cd $NAME
  cat README.md      # check the scaffolded README
  cat CLAUDE.md      # check the scaffolded CLAUDE.md and edit identity / rules

if you don't have ~/.claude/ continuity layer installed:
  see $KIT_ROOT/docs/continuity-layer.md

EOF
