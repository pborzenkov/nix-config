if [[ $# != 1 ]]; then
  echo "Usage: get-http-temp <serial>"
  exit 1
fi

promql --output json \
  "
    smartctl_device_temperature{temperature_type='current'}
      * on (device)
    smartctl_device{serial_number='${1}'}
  " | jq -r '.[0].value[1] | tonumber * 1000'
