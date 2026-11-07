#!/usr/bin/env bash

# Organize loose files in F/Raw and F/Raw/junk by extension.
# Usage: organize-raw.sh [--dry-run] [--yes]

set -euo pipefail

BASE="/media/Yosa/windows/F/Raw"
TARGETS=("$BASE" "$BASE/junk")
DRY_RUN=0
YES=0

for arg in "$@"; do
	case "$arg" in
		--dry-run) DRY_RUN=1 ;;
		--yes) YES=1 ;;
	esac
done

# special-case compound extensions: pattern -> folder
special() {
	local name="$1"
	case "$name" in
		*.tar.gz) echo "tar.gz"; return 0 ;;
	esac
	return 1
}

ext_of() {
	local name="$1" ext
	ext="${name##*.}"
	if [[ "$name" != *.* ]]; then
		ext=""
	fi
	echo "$ext"
}

	declare -A moved
	move_file() {
		local dir="$1" file="$2" name ext folder target i
		name="$(basename "$file")"
		if special "$name" >/dev/null; then
			folder="$(special "$name")"
		else
			ext="$(ext_of "$name")"
			if [[ -z "$ext" ]]; then
				folder="misc"
			else
				folder="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
			fi
		fi

	mkdir -p "$dir/$folder"
	target="$dir/$folder/$name"
	# collision handling
	if [[ -e "$target" ]]; then
		if [[ -z "${moved[$file]:-}" ]] && [[ "$(realpath "$target")" != "$(realpath "$file")" ]]; then
			base="${name%.*}"
			# for compound like .tar.gz, base stripping only removes last ext
			i=1
			while [[ -e "$dir/$folder/${base} ($i).${name##*.}" ]]; do
				i=$((i + 1))
			done
			target="$dir/$folder/${base} ($i).${name##*.}"
		fi
	fi

	if [[ -z "${moved[$file]:-}" ]]; then
		printf '%-8s %s\n' "$folder" "$name"
		if [[ $DRY_RUN -eq 0 ]]; then
			mv "$file" "$target"
		fi
		moved[$file]=1
	fi
}

for dir in "${TARGETS[@]}"; do
	[[ -d "$dir" ]] || continue
	echo "===== ${dir#$BASE} ====="
	while IFS= read -r -d '' f; do
		move_file "$dir" "$f"
	done < <(find "$dir" -maxdepth 1 -type f -print0)
	echo
done

if [[ $DRY_RUN -eq 1 ]]; then
	echo "dry-run complete — no files moved."
	echo "Re-run without --dry-run (or with --yes) to apply."
elif [[ $YES -eq 1 ]]; then
	echo "done."
else
	echo "done."
fi
