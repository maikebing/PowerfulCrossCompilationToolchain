#!/bin/sh

set -eu

# Conservative dependency baseline for the legacy images:
# - ARM cross toolchain gcc 4.6.1
# - Debian wheezy era native x86 toolchain

CURL_VERSION=8.10.1
CURL_TAG=curl-8_10_1
CURL_ARCHIVE="curl-${CURL_VERSION}.tar.gz"
CURL_URL="https://github.com/curl/curl/releases/download/${CURL_TAG}/${CURL_ARCHIVE}"
CURL_SHA256="D15EBAB765D793E2E96DB090F0E172D127859D78CA6F6391D7EAFECFD894BBC0"

FREETYPE_VERSION=2.13.3
FREETYPE_TAG=VER-2-13-3
FREETYPE_ARCHIVE="freetype-${FREETYPE_TAG}.tar.gz"
FREETYPE_URL="https://github.com/freetype/freetype/archive/refs/tags/${FREETYPE_TAG}.tar.gz"
FREETYPE_SHA256="BC5C898E4756D373E0D991BAB053036C5EB2AA7C0D5C67E8662DDC6DA40C4103"

LIBUSB_VERSION=1.0.23
LIBUSB_TAG=v1.0.23
LIBUSB_ARCHIVE="libusb-${LIBUSB_TAG}.tar.gz"
LIBUSB_URL="https://github.com/libusb/libusb/archive/refs/tags/${LIBUSB_TAG}.tar.gz"
LIBUSB_SHA256="02620708C4EEA7E736240A623B0B156650C39BFA93A14BCFA5F3E05270313EBA"

SQLITE_VERSION=3.51.2
SQLITE_TAG=version-3.51.2
SQLITE_ARCHIVE="sqlite-${SQLITE_TAG}.tar.gz"
SQLITE_URL="https://github.com/sqlite/sqlite/archive/refs/tags/${SQLITE_TAG}.tar.gz"
SQLITE_SHA256="2F35E1E63E8D4B57184DA77A56CABC941F52BEB1398023B1FFED97389C3FEF6F"

FFMPEG_VERSION=4.4.5
FFMPEG_TAG=n4.4.5
FFMPEG_ARCHIVE="ffmpeg-${FFMPEG_TAG}.tar.gz"
FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/${FFMPEG_TAG}.tar.gz"
FFMPEG_SHA256="36D12B77917CEF669484C39FE9ECEA6FEDC26D0F12A5B01C154BCC64AFF86019"

LVGL_VERSION=9.5.0
LVGL_TAG=v9.5.0
LVGL_ARCHIVE="lvgl-${LVGL_TAG}.tar.gz"
LVGL_URL="https://github.com/lvgl/lvgl/archive/refs/tags/${LVGL_TAG}.tar.gz"
LVGL_SHA256="34A955CDF3A2D005507B704E87357AF669A114523B6D3F77B5344FDC68717BC6"

pcct_dep_archive() {
    case "$1" in
        curl) echo "$CURL_ARCHIVE" ;;
        freetype) echo "$FREETYPE_ARCHIVE" ;;
        libusb) echo "$LIBUSB_ARCHIVE" ;;
        sqlite) echo "$SQLITE_ARCHIVE" ;;
        ffmpeg) echo "$FFMPEG_ARCHIVE" ;;
        lvgl) echo "$LVGL_ARCHIVE" ;;
        *)
            echo "unknown dependency: $1" >&2
            return 1
            ;;
    esac
}

pcct_dep_url() {
    case "$1" in
        curl) echo "$CURL_URL" ;;
        freetype) echo "$FREETYPE_URL" ;;
        libusb) echo "$LIBUSB_URL" ;;
        sqlite) echo "$SQLITE_URL" ;;
        ffmpeg) echo "$FFMPEG_URL" ;;
        lvgl) echo "$LVGL_URL" ;;
        *)
            echo "unknown dependency: $1" >&2
            return 1
            ;;
    esac
}

pcct_dep_sha256() {
    case "$1" in
        curl) echo "$CURL_SHA256" ;;
        freetype) echo "$FREETYPE_SHA256" ;;
        libusb) echo "$LIBUSB_SHA256" ;;
        sqlite) echo "$SQLITE_SHA256" ;;
        ffmpeg) echo "$FFMPEG_SHA256" ;;
        lvgl) echo "$LVGL_SHA256" ;;
        *)
            echo "unknown dependency: $1" >&2
            return 1
            ;;
    esac
}

pcct_dep_version() {
    case "$1" in
        curl) echo "$CURL_VERSION" ;;
        freetype) echo "$FREETYPE_VERSION" ;;
        libusb) echo "$LIBUSB_VERSION" ;;
        sqlite) echo "$SQLITE_VERSION" ;;
        ffmpeg) echo "$FFMPEG_VERSION" ;;
        lvgl) echo "$LVGL_VERSION" ;;
        *)
            echo "unknown dependency: $1" >&2
            return 1
            ;;
    esac
}
