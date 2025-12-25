FAN=0

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--fan)
      FAN="$2"
      shift
      shift
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}"

case $1 in
  "set")
    PWM=$2
    DUTY=$((PWM*100/255))
    framework_tool --fansetduty "${FAN}" "${DUTY}"
    ;;
  "get-rpm")
    framework_tool --thermal | awk "/Fan Speed/ { count++; if (count == $((FAN+1))) { print \$3; exit } }"
    ;;
  *)
    echo "Unknown command $1"
    exit 1
esac
