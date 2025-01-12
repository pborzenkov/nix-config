#!/usr/bin/env bash

usage() {
  echo >&2 "wofi-sound-menu [-w|--wofi-args ARGS] <output|input>"
}

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -w|--wofi-args)
      WOFI_ARGS="$2"
      shift
      shift
      ;;
    -*|--*)
      usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

case $1 in
  output)
    TARGET="sink"
    ;;
  input)
    TARGET="source"
    ;;
  *)
    usage
    exit 1
esac

CURRENT_TARGET="$(pactl get-default-${TARGET})"
TARGETS="$(pactl --format json list ${TARGET}s | jq '. | map({id: .name, name: .description})')"
NUM_TARGETS="$(echo ${TARGETS} | jq -r '. | length + 1')"

CHOSEN=$(echo "${TARGETS}" | \
  jq --arg current "${CURRENT_TARGET}" -r '
    .[] | "\u200e<span font_size=\"large\">" +
    if .id == $current
    then
      "\u2731"
    else
      " "
    end +
    "</span>  \u2068<span font_size=\"large\">" +
    .name +
    "</span>\u2069"
  ' | \
  wofi --prompt "Sound $1" --lines ${NUM_TARGETS} \
    --allow-markup ${WOFI_ARGS} \
    -Ddmenu-print_line_num=true --dmenu \
)

if [ -n "${CHOSEN}" ]; then
  ID=$(echo "${TARGETS}" | jq --argjson chosen "${CHOSEN}" -r '.[$chosen].id')
  echo $ID
  pactl set-default-${TARGET} ${ID}
fi
