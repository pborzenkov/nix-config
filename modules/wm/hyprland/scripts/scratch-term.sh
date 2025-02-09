current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
node=$(hyprctl clients -j | jq -r '.[] | try select(.class == "scratch-term")')
if [ -z "${node}" ]; then
  exec foot -a scratch-term
fi
node_workspace=$(echo "${node}" | jq -r '.workspace.id')
if [ "${current_workspace}" == "${node_workspace}" ]; then
  hyprctl dispatch movetoworkspacesilent special:scratch-term,class:scratch-term
else
  hyprctl dispatch movetoworkspacesilent "${current_workspace}",class:scratch-term
  hyprctl dispatch hy3:togglefocuslayer
fi


