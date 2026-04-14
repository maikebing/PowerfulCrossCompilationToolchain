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

download_with_fallback() {
    url=$1
    out=$2
    dep=$3
    in_ci=0

    if wget -q --https-only --tries=5 --waitretry=5 -O "$out" "$url"; then
        return 0
    fi

    case "${ENV_IN_CI:-${CI:-}}" in
        1|true|TRUE|yes|YES)
            in_ci=1
            ;;
    esac

    if [ "$in_ci" -eq 1 ]; then
        return 1
    fi

    proxy_addr=${PCCT_HTTP_PROXY:-http://127.0.0.1:7890}
    echo "retry $dep via proxy: $proxy_addr"
    if http_proxy="$proxy_addr" \
       https_proxy="$proxy_addr" \
       HTTP_PROXY="$proxy_addr" \
       HTTPS_PROXY="$proxy_addr" \
       wget -q --https-only --tries=3 --waitretry=5 -O "$out" "$url"; then
        return 0
    fi

    return 1
}

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
    if ! download_with_fallback "$url" "$tmp" "$dep"; then
        echo "failed to download $dep from $url (direct + proxy fallback)" >&2
        return 1
    fi

    echo "$sha256  $tmp" | sha256sum -c -
    mv "$tmp" "$archive"
}

for dep in "$@"; do
    fetch_one "$dep"
done
