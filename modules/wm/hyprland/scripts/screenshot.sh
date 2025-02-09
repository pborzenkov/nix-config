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
    grim -g "$(slurp -d)"
    ;;
  "fullscreen-copy")
    grim -o "$(hyprctl activeworkspace -j | jq -r .monitor)" - | wl-copy
    ;;
  "fullscreen-file")
    grim -o "$(hyprctl activeworkspace -j | jq -r .monitor)"
    ;;
  *)
    usage
    ;;
esac
