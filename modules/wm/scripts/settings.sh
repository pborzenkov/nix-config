PROVIDERS='{
  "sound": {
    "text": "Sound",
    "command": ["ncpamixer", "-t", "o"],
    "icon": ""
  },
  "services": {
    "text": "Services",
    "command": ["systemctl-tui"],
    "icon": ""
  }
}'

list_providers() {
  echo "${PROVIDERS}" | jq -r 'keys | join (", ")'
}

has_provider() {
  result=$(echo "${PROVIDERS}" | jq --arg provider "$1" -r 'has($provider)')
  [ "$result" = "true" ]
}

get_text() {
  echo "${PROVIDERS}" | jq --arg provider "$1" -r '.[$provider].text'
}

get_icon() {
  echo "${PROVIDERS}" | jq --arg provider "$1" -r '.[$provider].icon'
}

run_provider() {
  mapfile -t COMMANDS < <(echo "${PROVIDERS}" | jq --arg provider "$1" -r -c '.[$provider].command[]')
  exec footclient -a settings "${COMMANDS[@]}"
}

usage() {
  echo >&2 "CONFIGURED_PROVIDER='<comma-separated list of providers>' wofi-settings"
  echo >&2 "Available providers: $(list_providers)"
  exit 1
}

if [ -z "${CONFIGURED_PROVIDERS}" ]; then
  usage
fi

mapfile -t CONFIGURED_PROVIDERS < <(echo -ne "${CONFIGURED_PROVIDERS//,/\\n}")

ENABLED_PROVIDERS=()
for p in "${CONFIGURED_PROVIDERS[@]}"; do
  echo "${p}"
  has_provider "$p" && ENABLED_PROVIDERS+=("$p")
done

if [ "${#ENABLED_PROVIDERS[@]}" == "0" ]; then
    usage
elif [ "${#ENABLED_PROVIDERS[@]}" == "1" ]; then
  run_provider "${ENABLED_PROVIDERS[0]}"
else
  WITH_MARKUP=()
  for p in "${ENABLED_PROVIDERS[@]}"; do
    icon=$(get_icon "${p}")
    text=$(get_text "${p}")
    WITH_MARKUP+=("<span font_size=\"large\">${icon}</span> <span font_size=\"large\">${text}</span>")
  done

  CHOSEN=$(
    printf "%s\n" "${WITH_MARKUP[@]}" | \
    wofi --dmenu \
      -Ddmenu-print_line_num=true \
      --allow-markup \
      --columns 1 \
      -p "Settings" \
      -L $(("${#ENABLED_PROVIDERS[@]}" + 1)) \
      -W 20% \
  )

  [ -z "${CHOSEN}" ] && exit 0

  run_provider "${ENABLED_PROVIDERS[${CHOSEN}]}"
fi
