usage() {
  echo >&2 "Usage: $0 new|finalize"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

case "$1" in
  "toggle")
    node=$(swaymsg -t get_tree | jq -r '.. | try select(.marks[] | contains("scratch-term"))')
    if [ -z "${node}" ]; then
      exec foot -a scratch-term
    fi

    focused=$(echo "${node}" | jq -r '.. | try select(.focused == true)')
    if [ -z "${focused}" ]; then
      exec swaymsg '[con_mark="scratch-term"] move window to workspace current, move scratchpad, scratchpad show'
    fi

    swaymsg 'focus mode_toggle' || true
    exec swaymsg '[con_mark="scratch-term"] move scratchpad'
    ;;

  "finalize")
    con_id="$(
      swaymsg -t get_tree | \
      jq '.. | select(.type? == "con" and .nodes[0].app_id == "scratch-term") | .id' \
    )"
    swaymsg "[con_id=${con_id}] mark scratch-term, floating enable"
    swaymsg '[app_id="scratch-term"] unmark scratch-term-finalize'
    ;;
  *)
    usage
    ;;
esac
