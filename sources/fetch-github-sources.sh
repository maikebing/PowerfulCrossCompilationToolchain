#!/bin/sh

set -eu

if [ "$#" -lt 2 ]; then
    echo "usage: $0 <output-dir> <dependency> [dependency ...]" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/dependency-versions.sh"

OUTPUT_DIR=$1
shift

mkdir -p "$OUTPUT_DIR"

fetch_one() {
    dep=$1
    archive="$OUTPUT_DIR/$(pcct_dep_archive "$dep")"
    url=$(pcct_dep_url "$dep")
    sha256=$(pcct_dep_sha256 "$dep")
    tmp="${archive}.partial"

    if [ -f "$archive" ] && echo "$sha256  $archive" | sha256sum -c - >/dev/null 2>&1; then
        echo "reuse $dep: $archive"
        return 0
    fi

    rm -f "$archive" "$tmp"
    echo "fetch $dep from $url"
    wget -q --https-only --tries=5 --waitretry=5 -O "$tmp" "$url"
    echo "$sha256  $tmp" | sha256sum -c -
    mv "$tmp" "$archive"
}

for dep in "$@"; do
    fetch_one "$dep"
done
