usage() {
  echo >&2 "CONFIGURED_APPS='<comma-separated list of apps>' wofi-scratch-app"
  exit 1
}

run_app() {
  COMMANDS=("dtach" "-A" "/tmp/$1.dtach" "-r" "winch" "${1}")
  exec footclient -a scratch-app "${COMMANDS[@]}"
}

if [ -z "${CONFIGURED_APPS}" ]; then
  usage
fi

mapfile -t ENABLED_APPS < <(echo -ne "${CONFIGURED_APPS//,/\\n}")

if [ "${#ENABLED_APPS[@]}" == "0" ]; then
  usage
elif [ "${#ENABLED_APPS[@]}" == "1" ]; then
  run_app "${ENABLED_APPS[0]}"
else
  WITH_MARKUP=()
  for a in "${ENABLED_APPS[@]}"; do
    WITH_MARKUP+=("<span font_size=\"large\">${a}</span>")
  done

  CHOSEN=$(
    printf "%s\n" "${WITH_MARKUP[@]}" | \
    wofi --dmenu \
      -Ddmenu-print_line_num=true \
      --allow-markup \
      --columns 1 \
      -p "Apps" \
      -L $(("${#ENABLED_APPS[@]}" + 1)) \
      -W 20% \
  )

  [ -z "${CHOSEN}" ] && exit 0

  run_app "${ENABLED_APPS[${CHOSEN}]}"
fi
