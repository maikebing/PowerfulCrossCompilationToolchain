#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <x86|x64|arm|arm64|la64>" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/build-common.sh"
. "$SCRIPT_DIR/dependency-versions.sh"

pcct_setup_target "$1"

if [ ! -f "$SCRIPT_DIR/lv_conf.h" ]; then
    echo "missing lv_conf.h template: $SCRIPT_DIR/lv_conf.h" >&2
    exit 1
fi

cp "$SCRIPT_DIR/lv_conf.h" ./lv_conf.h
rm -f liblvgl.a

FREETYPE_CFLAGS=$(${PKG_CONFIG:-pkg-config} --cflags freetype2 2>/dev/null || true)
FFMPEG_CFLAGS=$(${PKG_CONFIG:-pkg-config} --cflags libavformat libavcodec libavutil libswscale 2>/dev/null || true)

if [ -z "$FREETYPE_CFLAGS" ]; then
    echo "pkg-config freetype2 cflags not found for target $1" >&2
    exit 1
fi

if [ -z "$FFMPEG_CFLAGS" ]; then
    echo "pkg-config ffmpeg cflags not found for target $1" >&2
    exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT INT TERM

n=0
for f in $(find src -name '*.c' -type f | sort); do
    n=$((n + 1))
    # shellcheck disable=SC2086
    "$CC" \
        -std=gnu99 \
        -O2 \
        -fPIC \
        -DLV_CONF_INCLUDE_SIMPLE \
        -DLANEAPP_ENABLE_LVGL_FFMPEG=1 \
        -I. \
        -I./src \
        $FREETYPE_CFLAGS \
        $FFMPEG_CFLAGS \
        -c "$f" \
        -o "$tmpdir/$n.o"
done

"$AR" rcs liblvgl.a "$tmpdir"/*.o
"$RANLIB" liblvgl.a

mkdir -p "$PCCT_LIBDIR" "$PCCT_INCLUDEDIR/lvgl" "$PCCT_PKGCONFIGDIR"
rm -rf "$PCCT_INCLUDEDIR/lvgl"
mkdir -p "$PCCT_INCLUDEDIR/lvgl"

install -m 644 liblvgl.a "$PCCT_LIBDIR/liblvgl.a"
cp -R src "$PCCT_INCLUDEDIR/lvgl/"
install -m 644 lvgl.h "$PCCT_INCLUDEDIR/lvgl/lvgl.h"
install -m 644 lv_conf.h "$PCCT_INCLUDEDIR/lvgl/lv_conf.h"
ln -sfn lvgl/lvgl.h "$PCCT_INCLUDEDIR/lvgl.h"
ln -sfn lvgl/lv_conf.h "$PCCT_INCLUDEDIR/lv_conf.h"

cat > "$PCCT_PKGCONFIGDIR/lvgl.pc" <<EOF
prefix=$PCCT_PREFIX
includedir=$PCCT_INCLUDEDIR
libdir=$PCCT_LIBDIR

Name: lvgl
Description: Light and Versatile Graphics Library
URL: https://lvgl.io/
Version: $LVGL_VERSION
Requires.private: freetype2 libavformat libavcodec libavutil libswscale
Cflags: -I\${includedir}/lvgl
Libs: -L\${libdir} -llvgl
EOF
