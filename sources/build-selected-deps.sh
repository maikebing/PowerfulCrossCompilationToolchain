#!/bin/sh

set -eu

if [ "$#" -lt 2 ]; then
    echo "usage: $0 <target> <dependency> [dependency ...]" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/dependency-versions.sh"

TARGET=$1
shift

build_one() {
    dep=$1
    archive="/dist/$(pcct_dep_archive "$dep")"
    script="/work/rebuild${dep}.sh"
    workdir="/tmp/pcct-${dep}-${TARGET}"

    if [ ! -f "$archive" ]; then
        echo "missing dependency archive: $archive" >&2
        exit 1
    fi

    if [ ! -x "$script" ]; then
        echo "missing dependency build script: $script" >&2
        exit 1
    fi

    rm -rf "$workdir"
    mkdir -p "$workdir"
    tar -xzf "$archive" -C "$workdir" --strip-components=1

    echo "build $dep for $TARGET"
    (
        cd "$workdir"
        "$script" "$TARGET"
    )

    rm -rf "$workdir"
}

for dep in "$@"; do
    build_one "$dep"
done
