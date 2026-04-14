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

# PostgreSQL uses custom configure, not GNU Autotools
if [ ! -f configure ]; then
    echo "ERROR: PostgreSQL configure script not found" >&2
    exit 2
fi

export CFLAGS="${CFLAGS:-} -O2 -fPIC"
export CXXFLAGS="${CXXFLAGS:-} -O2 -fPIC"

# Configure PostgreSQL with minimal client library dependencies:
# - disable SSL/TLS to remove OpenSSL dependency
# - disable Kerberos, LDAP authentication
# - disable server build features not needed for libpq
./configure \
    --host="$PCCT_HOST" \
    --build="$PCCT_BUILD" \
    --prefix="$PCCT_PREFIX" \
    --exec-prefix="$PCCT_PREFIX" \
    --libdir="$PCCT_LIBDIR" \
    --includedir="$PCCT_INCLUDEDIR" \
    --disable-shared \
    --enable-static \
    --disable-ssl \
    --without-krb5 \
    --without-ldap \
    --without-bonjour \
    --without-linux-perf \
    --without-tcl \
    --without-perl \
    --without-python \
    --without-icu \
    --without-openssl \
    --without-readline \
    --without-zlib

# Build and install only the libpq client library
make -C src/interfaces/libpq -j"$(pcct_nproc)"
make -C src/interfaces/libpq install LIBDIR="$PCCT_LIBDIR"

# Install libpq header files
mkdir -p "$PCCT_INCLUDEDIR"
cp src/include/libpq-fe.h "$PCCT_INCLUDEDIR/" 2>/dev/null || true
cp src/include/libpq-events.h "$PCCT_INCLUDEDIR/" 2>/dev/null || true
cp src/include/postgres_ext.h "$PCCT_INCLUDEDIR/" 2>/dev/null || true

