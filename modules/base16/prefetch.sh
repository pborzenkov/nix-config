#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-git

generate() {
	what=$1
	curl "https://raw.githubusercontent.com/chriskempson/base16-${what}-source/master/list.yaml" | \
		grep -Ev '^#|^$' | while IFS=":" read name repo
		do
			echo "{\"key\":\"$name\",\"value\":"
			nix-prefetch-git $repo
			echo "}"
		done | jq -s '.|from_entries' > $what.json
}

generate templates
