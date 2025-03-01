IS_CONFIRM="${SSH_ASKPASS_PROMPT:-}"

if [ "${IS_CONFIRM}" == "confirm" ]; then
  mapfile -t LINES <<< "$@"
  ANSWER=$(echo -e "Yes\nNo" | wofi -p "${LINES[0]}" --dmenu -W 20% -L 3)
  WOFI_EXIT_CODE=$?
  [ $WOFI_EXIT_CODE -eq 0 ] && [ "${ANSWER}" == "Yes" ] && exit 0
  exit 1
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
