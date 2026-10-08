#!/bin/bash
#
# Report whether /etc/default/scheduled-reboot can be restored to the
# package's pristine copy without losing a setting.
#
# Usage: conffile-status.sh REFERENCE CONFFILE [MANAGED_KEY...]
#
# Prints exactly one line:
#   missing      CONFFILE does not exist
#   pristine     CONFFILE matches REFERENCE byte for byte
#   restorable   every setting that differs is one the role now writes to
#                local.conf (a MANAGED_KEY), and nothing else was edited
#   keep: ...    something would be lost by restoring; leave it alone
#
# A setting absent from CONFFILE (an older conffile predating that setting)
# counts as matching: the scripts' built-in default equals the shipped value.

set -euo pipefail

reference=$1
conffile=$2
shift 2
managed=" $* "

known_keys=(
    scheduled_reboots_disabled
    email_when_disabled
    upgrade_at_shutdown
    script_timeout_seconds
    package_manager_timeout_seconds
    max_output_bytes
    mailto
    alert_mailsubject
    scripts_dir
    logs_dir
)

if [[ ! -e $conffile ]]; then
    echo missing
    exit 0
fi

if cmp -s -- "$reference" "$conffile"; then
    echo pristine
    exit 0
fi

# Anything besides comments, blank lines and known assignments is a local
# edit this script can't reason about.
key_pattern="^[[:space:]]*($(IFS='|'; echo "${known_keys[*]}"))="
other_lines() {
    grep -vE '^[[:space:]]*(#|$)' -- "$1" | grep -vE "$key_pattern" || true
}

if [[ $(other_lines "$reference") != "$(other_lines "$conffile")" ]]; then
    echo 'keep: lines other than known settings differ from the shipped file'
    exit 0
fi

value_of() {
    (
        set +eu
        source "$1" >/dev/null 2>&1
        if [[ -v $2 ]]; then printf 'set:%s' "${!2}"; else printf unset; fi
    )
}

unmanaged=()
for key in "${known_keys[@]}"; do
    current=$(value_of "$conffile" "$key")
    shipped=$(value_of "$reference" "$key")
    [[ $current == unset || $current == "$shipped" ]] && continue
    [[ $managed == *" $key "* ]] || unmanaged+=("$key")
done

if ((${#unmanaged[@]})); then
    echo "keep: locally set, not managed by the role: ${unmanaged[*]}"
else
    echo restorable
fi
