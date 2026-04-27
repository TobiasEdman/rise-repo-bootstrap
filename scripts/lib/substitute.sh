#!/usr/bin/env bash
#
# substitute.sh — replace {{VARS}} in template files
#
# Usage:
#   substitute_file <input> <output> [VAR=value] [VAR=value] ...
#
# Example:
#   substitute_file CLAUDE.md.tmpl CLAUDE.md NAME=foo DOMAIN="bar baz"
#
# Reads <input>, replaces every {{VAR}} with its value, writes to <output>.
# Multiple = signs in a value are fine ("VERIFY_COMMAND=pytest tests/ -v").
# Unset {{VARS}} stay as-is — that's a feature, surfaces template bugs to
# the user as visible {{NAME}} strings rather than silent empty strings.

set -euo pipefail

substitute_file() {
    local input="$1"
    local output="$2"
    shift 2

    if [[ ! -f "$input" ]]; then
        echo "substitute: input file not found: $input" >&2
        return 1
    fi

    # Build sed expression by collecting all KEY=VALUE pairs
    local sed_expr=""
    for kv in "$@"; do
        local key="${kv%%=*}"
        local val="${kv#*=}"
        # Escape sed special chars in the value: / \ &
        # (We use | as the sed delimiter so / doesn't need escaping there.)
        val="${val//\\/\\\\}"
        val="${val//|/\\|}"
        val="${val//&/\\&}"
        # Newlines in values: replace with sed's \n escape
        val="${val//$'\n'/\\n}"
        sed_expr+="s|{{${key}}}|${val}|g;"
    done

    # macOS sed needs an empty string after -i for in-place; we're writing to
    # a different file so we just pipe.
    if [[ -n "$sed_expr" ]]; then
        sed "$sed_expr" "$input" > "$output"
    else
        cp "$input" "$output"
    fi
}

# Allow this file to be sourced (function only) or called directly:
#   substitute.sh CLAUDE.md.tmpl CLAUDE.md NAME=foo DOMAIN="my proj"
if [[ "${BASH_SOURCE[0]}" == "${0:-}" ]]; then
    substitute_file "$@"
fi
