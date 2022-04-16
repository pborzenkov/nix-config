set -eEuo pipefail

METRICS_FILE=
TMP_FILE=
COMMON_LABELS=
LOGS=

function write_metrics() {
    local text="$1"
    echo -e "$text" >> "$TMP_FILE"
}

function rotate_metric_file() {
    mv "$TMP_FILE" "$METRICS_FILE"
    chmod a+r "$METRICS_FILE"
}

function convert_to_bytes() {
    local value=$1
    local unit=$2
    local factor

    case $unit in
             'KiB')
                 factor=1024
                 ;;
             'KB')
                 factor=1000
                 ;;
             'MiB')
                 factor=1048576
                 ;;
             'MB')
                 factor=1000000
                 ;;
             'GiB')
                 factor=1073741824
                 ;;
             'GB')
                 factor=1000000000
                 ;;
             'TiB')
                 factor=1099511627776
                 ;;
             'TB')
                 factor=1000000000000
                 ;;
             *)
                 echo "Unsupported unit $unit"
                 return 1
    esac

    echo $(awk 'BEGIN {printf "%.0f", '"${value}*${factor}"'}')
}

function analyze_files_line() {
    # example line:
    # Files:          68 new,    38 changed, 109657 unmodified
    local files_line=$(echo "$LOGS" | grep 'Files:' | cut -d':' -f4-)
    local new_files=$(echo $files_line | awk '{ print $2 }')
    local changed_files=$(echo $files_line | awk '{ print $4 }')
    local unmodified_files=$(echo $files_line | awk '{ print $6 }')
    if [ -z "$new_files" ] || [ -z "$changed_files" ] || [ -z "$unmodified_files" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "restic_repo_files{${COMMON_LABELS},state=\"new\"} $new_files"
    echo "restic_repo_files{${COMMON_LABELS},state=\"changed\"} $changed_files"
    echo "restic_repo_files{${COMMON_LABELS},state=\"unmodified\"} $unmodified_files"
}

function analyze_dirs_line() {
    # Dirs:            0 new,     1 changed,     1 unmodified
    local files_line=$(echo "$LOGS" | grep 'Dirs:' | cut -d':' -f4-)
    local new_dirs=$(echo $files_line | awk '{ print $2 }')
    local changed_dirs=$(echo $files_line | awk '{ print $4 }')
    local unmodified_dirs=$(echo $files_line | awk '{ print $6 }')
    if [ -z "$new_dirs" ] || [ -z "$changed_dirs" ] || [ -z "$unmodified_dirs" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "restic_repo_dirs{${COMMON_LABELS},state=\"new\"} $new_dirs"
    echo "restic_repo_dirs{${COMMON_LABELS},state=\"changed\"} $changed_dirs"
    echo "restic_repo_dirs{${COMMON_LABELS},state=\"unmodified\"} $unmodified_dirs"
}

function analyze_added_line() {
    # Added to the repo: 223.291 MiB
    local added_line=$(echo "$LOGS" | grep 'Added to the repo:' | cut -d':' -f4-)
    local added_value=$(echo $added_line | awk '{ print $5 }')
    local added_unit=$(echo $added_line | awk '{ print $6 }')
    local added_bytes=$(convert_to_bytes $added_value $added_unit)
    if [ -z "$added_bytes" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "restic_repo_size_bytes{${COMMON_LABELS},state=\"new\"} $added_bytes"
}

function main() {
    local unit="${1:-}"
    if [ -z "$unit" ]; then
        echo "Unit is not specified"
        return 1
    fi

    local log_file="${2:-}"
    if [ -n "${log_file}" ]; then
        # get logs from file (useful for debugging / testing)
        LOGS="$(cat $log_file)"
    else
        # get last invocation id
        # from: https://unix.stackexchange.com/a/506887/214474
        local id=$(systemctl show -p InvocationID --value "$unit")

        # get logs from last invocation
        LOGS="$(journalctl -o short-iso INVOCATION_ID=${id} + _SYSTEMD_INVOCATION_ID=${id})"
    fi
    METRICS_FILE="/var/lib/prometheus-node-exporter/${unit}.prom"
    TMP_FILE="$(mktemp ${METRICS_FILE}.XXXXXXX)"
    COMMON_LABELS="unit=\"${unit}\""

    # check if unit failed
    if echo "$LOGS" | grep -F "systemd[1]: ${unit}: Failed with result"; then
        write_metrics "restic_backup_failure{${COMMON_LABELS}} 1"
        rotate_metric_file
	return 1
    fi

    write_metrics "$(analyze_files_line)"
    write_metrics "$(analyze_added_line)"
    write_metrics "$(analyze_dirs_line)"

    # everything ok
    write_metrics "restic_backup_failure{${COMMON_LABELS}} 0"
    rotate_metric_file

    return 0
}

main "$@"
