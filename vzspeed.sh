#!/bin/bash

_vzid=$1
_units=$2

_die() {
    printf '%s\n' "$@"
    exit 1
}

_get_bytes_in() {
    vzctl exec $1 "grep venet0 /proc/net/dev" |cut -f2 -d: | awk '{printf"%s", $1}'
}

_get_bytes_out() {
    vzctl exec $1 "grep venet0 /proc/net/dev" |cut -f2 -d: | awk '{printf"%s", $9}'
}

[[ ${_vzid} ]] || _die 'Usage: vzspeed [vzid] [units(B/KB/Mb)]'

_vzid_bytes_in_old=$(_get_bytes_in $_vzid)
_vzid_bytes_out_old=$(_get_bytes_out $_vzid)

printf '\n\n'

while sleep 1; do
    _vzid_bytes_in_new=$(_get_bytes_in $_vzid)
    _vzid_bytes_out_new=$(_get_bytes_out $_vzid)

    # Move cursor back up and delete previous output
    printf "\033[1A"
    printf "\033[K"
    printf "\033[1A"
    printf "\033[K"

    if [[ $2 = 'B' ]]; then
        printf '%s: %s\n' 'Bytes in/sec'  "$(( _vzid_bytes_in_new - _vzid_bytes_in_old ))" \
                          'Bytes out/sec' "$(( _vzid_bytes_out_new - _vzid_bytes_out_old ))"
    fi

    if [[ $2 = 'KB' ]] || [[ -z $2 ]]; then
        printf '%s: %s\n' 'Kilobytes in/sec'  "$(( ( _vzid_bytes_in_new - _vzid_bytes_in_old ) / 1024 ))" \
                          'Kilobytes out/sec' "$(( ( _vzid_bytes_out_new - _vzid_bytes_out_old ) / 1024 ))"
    fi

    if [[ $2 = 'Mb' ]]; then
        printf '%s: %s\n' 'Megabits in/sec'  "$(( ( _vzid_bytes_in_new - _vzid_bytes_in_old ) / 131072 ))" \
                          'Megabits out/sec' "$(( ( _vzid_bytes_out_new - _vzid_bytes_out_old ) / 131072 ))"
    fi

    _vzid_bytes_in_old=${_vzid_bytes_in_new}
    _vzid_bytes_out_old=${_vzid_bytes_out_new}
done
