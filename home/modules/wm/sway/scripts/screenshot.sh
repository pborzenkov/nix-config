usage() {
  echo >&2 "Usage: $0 select-copy|select-file|fullscreen-copy|fullscreen-file"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

case "$1" in
  "select-copy")
    grim -g "$(slurp -d)" - | wl-copy
    ;;
  "select-file")
    echo "grim dir $GRIM_DEFAULT_DIR" > /tmp/aaa
    grim -g "$(slurp -d)"
    ;;
  "fullscreen-copy")
    grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" - | wl-copy
    ;;
  "fullscreen-file")
    grim -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')"
    ;;
  *)
    usage
    ;;
esac
