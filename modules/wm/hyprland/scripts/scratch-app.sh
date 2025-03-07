usage() {
  echo >&2 "scratch-app [-c|--class CLASS] -- [app]"
  exit 1
}

CLASS="term"
while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--class)
      CLASS="$2"
      shift
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
    esac
done

CLASS="scratch-${CLASS}"

current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
node=$(hyprctl clients -j | jq --arg class "${CLASS}" -r '.[] | try select(.class == $class)')
if [ -z "${node}" ]; then
  exec foot -a "${CLASS}" "$@"
fi

node_workspace=$(echo "${node}" | jq -r '.workspace.id')
if [ "${current_workspace}" == "${node_workspace}" ]; then
  hyprctl dispatch movetoworkspacesilent special:"${CLASS}",class:"${CLASS}"
else
  hyprctl dispatch movetoworkspacesilent "${current_workspace}",class:"${CLASS}"
  hyprctl dispatch hy3:togglefocuslayer
fi


