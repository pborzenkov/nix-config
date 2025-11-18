shopt -s nocasematch
shopt -s extglob
export LC_ALL=C

INTERFACE="$1"
ENDPOINT="$2"
PUBKEY="$3"

process_peer() {
	[[ $(wg show "$INTERFACE" latest-handshakes) =~ ${PUBKEY//+/\\+}\	([0-9]+) ]] || return 0
	(( (EPOCHSECONDS - BASH_REMATCH[1]) > 135 )) || return 0
	wg set "$INTERFACE" peer "$PUBKEY" endpoint "$ENDPOINT"
}

process_peer
