#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <x86|x64|arm|arm64|la64>" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/build-common.sh"

pcct_setup_target "$1"
pcct_reset_build_tree

COMMON_ARGS="\
    --disable-all \
    --disable-autodetect \
    --disable-programs \
    --disable-doc \
    --disable-podpages \
    --disable-debug \
    --disable-network \
    --disable-asm \
    --disable-symver \
    --enable-static \
    --disable-shared \
    --enable-pic \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swscale \
    --enable-decoders \
    --enable-demuxers \
    --enable-parsers \
    --enable-protocol=file \
    --enable-zlib"

export CFLAGS="${CFLAGS:-} -O2 -fPIC"
export CXXFLAGS="${CXXFLAGS:-} -O2 -fPIC"

CFG_ARGS="\
    --prefix=$PCCT_PREFIX \
    --libdir=$PCCT_LIBDIR \
    --incdir=$PCCT_INCLUDEDIR \
    --pkgconfigdir=$PCCT_PKGCONFIGDIR \
    --arch=$PCCT_ARCH \
    --target-os=linux \
    --cc=$CC \
    --cxx=$CXX \
    --ld=$CC \
    --ar=$AR \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --nm=$NM \
    --pkg-config=${PKG_CONFIG:-pkg-config}"

if [ "$PCCT_IS_CROSS" = "1" ]; then
    CFG_ARGS="$CFG_ARGS --enable-cross-compile --cross-prefix=$PCCT_CROSS_PREFIX --host-cc=${CC_FOR_BUILD:-gcc}"
    if [ -n "${SYSROOT:-}" ]; then
        CFG_ARGS="$CFG_ARGS --sysroot=$SYSROOT"
    fi
fi

# shellcheck disable=SC2086
./configure $CFG_ARGS $COMMON_ARGS

make -j"$(pcct_nproc)"
make install
