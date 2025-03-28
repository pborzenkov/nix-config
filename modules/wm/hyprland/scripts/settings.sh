PROVIDERS='{
  "sound": {
    "text": "Sound",
    "command": ["ncpamixer", "-t", "o"],
    "icon": ""
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
  echo >&2 "settings [-p|--provider PROVIDER]"
  echo >&2 "Available providers: $(list_providers)"
  exit 1
}

ENABLED_PROVIDERS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--providers)
      has_provider "$2" && ENABLED_PROVIDERS+=("$2")
      shift
      shift
      ;;
    *)
      shift
      usage
      ;;
    esac
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
