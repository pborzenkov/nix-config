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

function unmap-new-term-key {
  echo "Unmapping Super+Enter key..."
  hyprctl -q --batch "
    keyword unbind super,Return
  "
}

function map-new-term-key {
  echo "Mapping Super+Enter key..."
  hyprctl -q --batch "
    keyword bind super,Return,exec,uwsm app -- footclient
  "
}

# Scratch term
function activate-scratch-term {
  unmap-tab-keys
  unmap-new-term-key
}

function deactivate-scratch-term {
  map-new-term-key
  map-tab-keys
}

# Scratch mail
function activate-scratch-mail {
  unmap-tab-keys
}

function deactivate-scratch-mail {
  map-tab-keys
}

function handle_line {
  mapfile -d '>' -t CMD_AND_ARGS <<< "${1//>>/>}"

  case ${CMD_AND_ARGS[0]} in
    activewindow)
      mapfile -d ',' -t ARGS <<< "${CMD_AND_ARGS[1]}"
      local to_deactivate="deactivate-${LAST_ACTIVE_WINDOW}"
      local to_activate="activate-${ARGS[0]}"

      if [[ "${LAST_ACTIVE_WINDOW}" != "${ARGS[0]}" ]]; then
        if [[ $(type -t "${to_deactivate}") == "function" ]]; then
          "${to_deactivate}"
        fi
        if [[ $(type -t "${to_activate}") == "function" ]]; then
          "${to_activate}"
        fi
      fi
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
