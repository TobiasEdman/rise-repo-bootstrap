#!/usr/bin/env bash
#
# classify.sh — collect classification answers (interactive or via flags)
#
# Sets these variables in the calling scope:
#   NAME, DOMAIN, STACK, LICENSE_KEY, VISIBILITY, ENABLE_CI, CREATE_GITHUB
#
# Usage (sourced from new-repo.sh):
#   source scripts/lib/classify.sh
#   classify_interactive  # or classify_from_flags "$@"

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

_ask() {
    # _ask "Question?" default_value -> echoes the answer
    local q="$1" default="${2:-}"
    local prompt="$q"
    [[ -n "$default" ]] && prompt+=" [$default]"
    prompt+=" "
    local ans=""
    read -r -p "$prompt" ans
    echo "${ans:-$default}"
}

_yesno() {
    # _yesno "Question?" default -> 0 if yes, 1 if no
    local q="$1" default="${2:-Y}"
    local hint="[Y/n]"
    [[ "$default" == "N" || "$default" == "n" ]] && hint="[y/N]"
    local ans=""
    read -r -p "$q $hint " ans
    ans="${ans:-$default}"
    [[ "$ans" =~ ^[Yy]$ ]]
}

_validate_name() {
    [[ "$1" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]] || {
        echo "name must be kebab-case: lowercase, alphanumeric + dash, no leading/trailing dash" >&2
        return 1
    }
}

# ── interactive classification ───────────────────────────────────────────────

classify_interactive() {
    [[ -z "${NAME:-}" ]] && {
        while true; do
            NAME="$(_ask "Repo name (kebab-case)?")"
            _validate_name "$NAME" && break
        done
    }
    [[ -z "${DOMAIN:-}" ]] && DOMAIN="$(_ask "Domain (one sentence describing what this repo does)?")"

    [[ -z "${STACK:-}" ]] && {
        while true; do
            STACK="$(_ask "Stack? [python/none]" "python")"
            case "$STACK" in
                python|none) break ;;
                node) echo "node not supported in v1; use 'none' and add Node manually" >&2 ;;
                *) echo "must be 'python' or 'none'" >&2 ;;
            esac
        done
    }

    [[ -z "${LICENSE_KEY:-}" ]] && {
        echo
        echo "License classification:"
        echo "  rise      — RISE-direct research output    → CC0-1.0"
        echo "  sub       — Sub-project (DES, Vinnova, etc) → Apache-2.0"
        echo "  personal  — Personal work outside RISE     → MIT"
        echo "  none      — Proprietary (no LICENSE)       → suitable only for private repos"
        local cls=""
        while true; do
            cls="$(_ask "Classification? [rise/sub/personal/none]" "sub")"
            case "$cls" in
                rise) LICENSE_KEY="cc0"; break ;;
                sub)  LICENSE_KEY="apache"; break ;;
                personal) LICENSE_KEY="mit"; break ;;
                none) LICENSE_KEY="none"; break ;;
                *) echo "must be rise/sub/personal/none" >&2 ;;
            esac
        done
        # Allow override
        local override=""
        override="$(_ask "Override license to specific (cc0/apache/mit/none)?" "$LICENSE_KEY")"
        case "$override" in
            cc0|apache|mit|none) LICENSE_KEY="$override" ;;
        esac
    }

    [[ -z "${VISIBILITY:-}" ]] && {
        if _yesno "Public repo?" "N"; then
            VISIBILITY="public"
        else
            VISIBILITY="private"
        fi
    }

    if [[ "$VISIBILITY" == "public" && "$LICENSE_KEY" == "none" ]]; then
        echo
        echo "WARN: public + no license is strictly worse than private + no license."
        echo "      Anyone discovering it has no idea what they're allowed to do."
        echo "      Consider switching to apache or staying private."
        if ! _yesno "Continue anyway?" "N"; then
            return 1
        fi
    fi

    if [[ -z "${ENABLE_CI:-}" ]]; then
        case "$STACK" in
            python) _yesno "Add CI scaffold (GitHub Actions, pytest+ruff)?" "Y" && ENABLE_CI=1 || ENABLE_CI=0 ;;
            *) ENABLE_CI=0 ;;
        esac
    fi

    [[ -z "${CREATE_GITHUB:-}" ]] && {
        if _yesno "Create on GitHub now?" "Y"; then
            CREATE_GITHUB=1
        else
            CREATE_GITHUB=0
        fi
    }
}

# ── flag-based classification (already-set vars are kept) ────────────────────
# Flags are parsed by new-repo.sh main; this just validates what got set.

classify_validate() {
    [[ -n "${NAME:-}" ]] || { echo "NAME not set" >&2; return 1; }
    _validate_name "$NAME" || return 1
    [[ -n "${STACK:-}" ]] || STACK="python"
    case "$STACK" in python|none) ;; *) echo "stack must be python or none" >&2; return 1 ;; esac
    [[ -n "${LICENSE_KEY:-}" ]] || LICENSE_KEY="apache"
    case "$LICENSE_KEY" in cc0|apache|mit|none) ;; *) echo "license must be cc0/apache/mit/none" >&2; return 1 ;; esac
    [[ -n "${VISIBILITY:-}" ]] || VISIBILITY="private"
    case "$VISIBILITY" in public|private) ;; *) echo "visibility must be public/private" >&2; return 1 ;; esac
    [[ -n "${ENABLE_CI:-}" ]] || ENABLE_CI=$([[ "$STACK" == "python" ]] && echo 1 || echo 0)
    [[ -n "${CREATE_GITHUB:-}" ]] || CREATE_GITHUB=0
}
