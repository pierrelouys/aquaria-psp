#!/usr/bin/env bash
#
# Aquaria PSP port
# Copyright (C) 2010 Andrew Church <achurch@achurch.org>
#
# Convert Aquaria PNG textures and Ogg Vorbis audio to the formats used by
# the PSP port.  The converter algorithms and on-disk asset formats are kept
# in pngtotex.c and oggtomp3.c; this script only orchestrates those tools.

set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

usage() {
    cat <<USAGE
Usage: $0 [-f] <Aquaria-data-directory>

Converts all PNG textures to the PSP's half-size indexed .tex format and all
Ogg Vorbis audio to MP3, placing each converted file beside its original.
Original PNG and Ogg files are retained. The directory is checked for an
Aquaria title logo unless -f is specified.

Build the command-line tools first with:
    make -C "$SCRIPT_DIR" cli-tools
USAGE
}

FORCE=0
if [[ ${1-} == -f ]]; then
    FORCE=1
    shift
fi
if [[ $# -ne 1 || ! -d $1 ]]; then
    usage >&2
    exit 2
fi

DIR=$(cd -- "$1" && pwd -P)
if (( ! FORCE )) && [[ ! -f "$DIR/gfx/title/logo.png" ]]; then
    printf 'error: %q does not look like an Aquaria data directory (missing gfx/title/logo.png)\n' "$DIR" >&2
    printf 'If this is intentional, rerun with -f.\n' >&2
    exit 1
fi

for tool in pngtotex oggtomp3; do
    if [[ ! -x "$SCRIPT_DIR/$tool" ]]; then
        printf 'error: converter not found or not executable: %s\n' "$SCRIPT_DIR/$tool" >&2
        printf 'Build the tools with: make -C %q cli-tools\n' "$SCRIPT_DIR" >&2
        exit 1
    fi
done

# NUL-delimited, sorted paths correctly preserve spaces, tabs, leading dashes,
# and other legal filename characters. The original data files are never changed.
mapfile -d '' -t PNG_FILES < <(find "$DIR" -type f -iname '*.png' -print0 | sort -z)
mapfile -d '' -t OGG_FILES < <(find "$DIR" -type f -iname '*.ogg' -print0 | sort -z)

status() {
    local current=$1 total=$2 pathname=$3 width=${#2}
    printf '   [%*d/%d] %s\n' "$width" "$current" "$total" "$pathname"
}

printf '\nAquaria PSP data conversion script\n\n'
printf 'Converting %d textures...\n' "${#PNG_FILES[@]}"
current=1
total=${#PNG_FILES[@]}
for path in "${PNG_FILES[@]}"; do
    status "$current" "$total" "${path#"$DIR"/}"
    "$SCRIPT_DIR/pngtotex" -8 "$path"
    current=$((current + 1))
done
printf 'Texture conversion complete.\n\n'

printf 'Converting %d audio files...\n' "${#OGG_FILES[@]}"
current=1
total=${#OGG_FILES[@]}
for path in "${OGG_FILES[@]}"; do
    status "$current" "$total" "${path#"$DIR"/}"
    "$SCRIPT_DIR/oggtomp3" "$path"
    current=$((current + 1))
done
printf 'Audio file conversion complete.\n\nAll files have been successfully converted.\n'
