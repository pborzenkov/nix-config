IS_CONFIRM="${SSH_ASKPASS_PROMPT:-}"

mapfile -t LINES <<< "$@"

if [ "${IS_CONFIRM}" == "confirm" ]; then
  ANSWER=$(echo -e "yes\nno" | wofi -p "${LINES[0]}" --dmenu -W 20% -L 3)
  WOFI_EXIT_CODE=$?
  [ $WOFI_EXIT_CODE -eq 0 ] && [ "${ANSWER}" == "yes" ] && exit 0
  exit 1
fi

case "${LINES[0]}" in
  "Enter passphrase for"*)
    PASS=$(
      for fd in /proc/"$$"/fd/*; do
        fd="${fd##*/}"
        [ "$fd" -gt 2 ] && exec {fd}<&-
      done

      rbw get --folder SSH ssh-key-"$(hostname)"
      exit $?
    )
    RBW_EXIT_CODE=$?
    if [ $RBW_EXIT_CODE -ne 0 ]; then
      exit $RBW_EXIT_CODE
    fi

    echo -n "${PASS}"
    exit 0
    ;;

  "The authenticity of host"*)
    ANSWER=$(echo -e "yes\nno\nfingerprint" | wofi -p "${LINES[0]}" --dmenu -W 50% -L 4)
    WOFI_EXIT_CODE=$?
    echo "${ANSWER}"
    exit $WOFI_EXIT_CODE
    ;;

  *)
    exit 1
esac
