IS_CONFIRM="${SSH_ASKPASS_PROMPT:-}"

mapfile -t LINES <<< "$@"

if [ "${IS_CONFIRM}" == "confirm" ]; then
  ANSWER=$(echo -e "yes\nno" | wofi -p "${LINES[0]}" --dmenu -W 20% -L 3)
  WOFI_EXIT_CODE=$?
  [ $WOFI_EXIT_CODE -eq 0 ] && [ "${ANSWER}" == "yes" ] && exit 0
fi

exit 1
