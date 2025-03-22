LAST_ACTIVE_WINDOW="";

function unmap-tab-keys {
  echo "Unmapping Alt-1..Alt-0 keys..."
  hyprctl -q --batch "
    keyword unbind alt,1 ; 
    keyword unbind alt,2 ; 
    keyword unbind alt,3 ; 
    keyword unbind alt,4 ; 
    keyword unbind alt,5 ; 
    keyword unbind alt,6 ; 
    keyword unbind alt,7 ; 
    keyword unbind alt,8 ; 
    keyword unbind alt,9 ; 
    keyword unbind alt,0
  "
}

function map-tab-keys {
  echo "Mapping Alt-1..Alt-0 keys..."
  hyprctl -q --batch "
    keyword bind alt,1,hy3:focustab,index,01 ;
    keyword bind alt,2,hy3:focustab,index,02 ;
    keyword bind alt,3,hy3:focustab,index,03 ;
    keyword bind alt,4,hy3:focustab,index,04 ;
    keyword bind alt,5,hy3:focustab,index,05 ;
    keyword bind alt,6,hy3:focustab,index,06 ;
    keyword bind alt,7,hy3:focustab,index,07 ;
    keyword bind alt,8,hy3:focustab,index,08 ;
    keyword bind alt,9,hy3:focustab,index,09 ;
    keyword bind alt,0,hy3:focustab,index,10
  "
}

function handle_line {
  mapfile -d '>' -t CMD_AND_ARGS <<< "${1//>>/>}"

  case ${CMD_AND_ARGS[0]} in
    activewindow)
      mapfile -d ',' -t ARGS <<< "${CMD_AND_ARGS[1]}"
      case "${ARGS[0]}" in
        scratch-mail)
          [ "${LAST_ACTIVE_WINDOW}" != "scratch-mail" ] && unmap-tab-keys
          ;;
        *)
          [ "${LAST_ACTIVE_WINDOW}" == "scratch-mail" ] && map-tab-keys
          ;;
      esac
      LAST_ACTIVE_WINDOW="${ARGS[0]}"
      ;;
    *)
      ;;
  esac          
}

socat -u UNIX-CONNECT:"${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock",retry,interval=.1,forever STDOUT | \
  while read -r line; do
    handle_line "${line}"
  done
