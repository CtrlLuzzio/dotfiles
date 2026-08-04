#!/usr/bin/env bash

TEXT=$(curl -fGsS -H "Accept-Language: ${LANG%_*}" "wttr.in/Cabudare?format=%c+%t")

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

TOOLTIP=$(curl -fGsS -H "Accept-Language: ${LANG%_*}" "wttr.in/Cabudare?${WTTR_PARAMS}")

ESCAPED_TOOLTIP="${TOOLTIP//\\/\\\\}"
ESCAPED_TOOLTIP="${ESCAPED_TOOLTIP//\"/\\\"}"
ESCAPED_TOOLTIP="${ESCAPED_TOOLTIP//$'\n'/\\n}"

ESCAPED_TEXT="${TEXT//\"/\\\"}"

printf '{"text": "%s", "tooltip": "%s"}\n' "$ESCAPED_TEXT" "$ESCAPED_TOOLTIP"
