#!/usr/bin/env bash

for i in {1..15}; do
    if ping -c 1 -W 1 wttr.in >/dev/null 2>&1; then
	break
    fi
    sleep 2
done

TEXT=$(curl -fGsS -H "Accept-Language: ${LANG%_*}" "wttr.in/?format=%c+%t")

WTTR_PARAMS="T"

if [[ -t 1 ]] && [[ "$(tput cols)" -lt 125 ]]; then
    WTTR_PARAMS+='n'
fi 2> /dev/null

for _token in $( locale LC_MEASUREMENT ); do
  case $_token in
    1) WTTR_PARAMS+='m' ;;
    2) WTTR_PARAMS+='u' ;;
  esac
done 2> /dev/null

TOOLTIP=$(curl -fGsS -H "Accept-Language: ${LANG%_*}" "wttr.in/?${WTTR_PARAMS}")

ESCAPED_TOOLTIP="${TOOLTIP//\\/\\\\}"
ESCAPED_TOOLTIP="${ESCAPED_TOOLTIP//\"/\\\"}"
ESCAPED_TOOLTIP="${ESCAPED_TOOLTIP//$'\n'/\\n}"

ESCAPED_TEXT="${TEXT//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s"}\n' "$ESCAPED_TEXT" "$ESCAPED_TOOLTIP"
