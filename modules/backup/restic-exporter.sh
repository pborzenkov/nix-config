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
             'B')
                 factor=1
                 ;;
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
    local files_line=$(echo "$LOGS" | grep 'Files:' | cut -d':' -f2-)
    local new_files=$(echo $files_line | awk '{ print $2 }')
    local changed_files=$(echo $files_line | awk '{ print $4 }')
    local unmodified_files=$(echo $files_line | awk '{ print $6 }')
    if [ -z "$new_files" ] || [ -z "$changed_files" ] || [ -z "$unmodified_files" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "# HELP restic_backup_snapshot_files Shows number of new/changed/unmodified files in backup snapshot"
    echo "restic_backup_snapshot_files{${COMMON_LABELS},state=\"new\"} $new_files"
    echo "restic_backup_snapshot_files{${COMMON_LABELS},state=\"changed\"} $changed_files"
    echo "restic_backup_snapshot_files{${COMMON_LABELS},state=\"unmodified\"} $unmodified_files"
}

function analyze_dirs_line() {
    # Dirs:            0 new,     1 changed,     1 unmodified
    local files_line=$(echo "$LOGS" | grep 'Dirs:' | cut -d':' -f2-)
    local new_dirs=$(echo $files_line | awk '{ print $2 }')
    local changed_dirs=$(echo $files_line | awk '{ print $4 }')
    local unmodified_dirs=$(echo $files_line | awk '{ print $6 }')
    if [ -z "$new_dirs" ] || [ -z "$changed_dirs" ] || [ -z "$unmodified_dirs" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "# HELP restic_backup_snapshot_dirs Shows number of new/changed/unmodified dirs in backup snapshot"
    echo "restic_backup_snapshot_dirs{${COMMON_LABELS},state=\"new\"} $new_dirs"
    echo "restic_backup_snapshot_dirs{${COMMON_LABELS},state=\"changed\"} $changed_dirs"
    echo "restic_backup_snapshot_dirs{${COMMON_LABELS},state=\"unmodified\"} $unmodified_dirs"
}

function analyze_added_line() {
    # Added to the repo: 223.291 MiB
    local added_line=$(echo "$LOGS" | grep 'Added to the repository:' | cut -d':' -f2-)
    local added_value=$(echo $added_line | awk '{ print $5 }')
    local added_unit=$(echo $added_line | awk '{ print $6 }')
    local added_bytes=$(convert_to_bytes $added_value $added_unit)
    if [ -z "$added_bytes" ]; then
        # this line should be present, fail if its not
        return 1
    fi
    echo "# HELP restic_backup_snapshot_size_bytes Shows the amount of data added in backup snapshot"
    echo "restic_backup_snapshot_size_bytes{${COMMON_LABELS},state=\"new\"} $added_bytes"
}

function write_backup_failure_state() {
    local failure="${1:-}"

    write_metrics "# HELP restic_backup_failure Indicates that the backup has failed"
    write_metrics "restic_backup_failure{${COMMON_LABELS}} $failure"
    rotate_metric_file
}

function main() {
    local unit="${1:-}"
    if [ -z "$unit" ]; then
        echo "Unit is not specified"
        return 1
    fi

    LOGS="$(journalctl -o short-unix INVOCATION_ID=${INVOCATION_ID} + _SYSTEMD_INVOCATION_ID=${INVOCATION_ID})"
    METRICS_FILE="/var/lib/prometheus-node-exporter/${unit}.prom"
    TMP_FILE="$(mktemp ${METRICS_FILE}.XXXXXXX)"
    COMMON_LABELS="unit=\"${unit}\""

    # check if unit failed
    if echo "$LOGS" | grep -F "systemd[1]: ${unit}: Failed with result"; then
        write_backup_failure_state "1"
        return 1
    fi

    write_metrics "$(analyze_files_line)"
    write_metrics "$(analyze_added_line)"
    write_metrics "$(analyze_dirs_line)"

    # everything ok
    write_backup_failure_state "0"

    return 0
}

main "$@"
