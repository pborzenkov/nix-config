if [[ $# != 1 ]]; then
  echo "Usage: get-hba-temp <serial>"
  exit 1
fi

promql --output json \
  "
    megaraid_temperature{}
      * on (controller)
    megaraid_controller_info{serial='${1}'}
  " | jq -r '.[0].value[1] | tonumber * 1000'
