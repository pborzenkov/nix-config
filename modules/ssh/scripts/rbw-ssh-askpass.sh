IS_CONFIRM="${SSH_ASKPASS_PROMPT:-}"

if [ "${IS_CONFIRM}" == "confirm" ]; then
  mapfile -t LINES <<< "$@"
  zenity --question --title "${LINES[0]}" --text "${LINES[@]:1}"
  exit $?
fi

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
