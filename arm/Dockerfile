ARG BASE_PLATFORM=linux/386

FROM debian:bookworm-slim AS fetcher

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY sources/dependency-versions.sh /work/dependency-versions.sh
COPY sources/fetch-github-sources.sh /work/fetch-github-sources.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /work/*.sh && \
    /work/fetch-github-sources.sh /dist curl freetype libusb sqlite ffmpeg lvgl

FROM --platform=${BASE_PLATFORM} i386/debian:wheezy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CROSS_COMPILE=arm-none-linux-gnueabi- \
    SYSROOT=/work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot \
    CC=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-gcc \
    CXX=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-g++ \
    AR=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-ar \
    AS=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-as \
    LD=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-ld \
    NM=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-nm \
    RANLIB=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-ranlib \
    STRIP=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-strip \
    OBJCOPY=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-objcopy \
    OBJDUMP=/work/toolchain_R2_EABI/usr/bin/arm-none-linux-gnueabi-objdump \
    PKG_CONFIG=/work/toolchain_R2_EABI/usr/bin/pkg-config \
    PATH=/work/toolchain_R2_EABI/usr/bin:/work/toolchain_R2_EABI/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY sources/toolchain.tar.gzaa /work/
COPY sources/toolchain.tar.gzab /work/
COPY sources/toolchain.tar.gzac /work/
COPY rebuildcurl.sh /work/rebuildcurl.sh
COPY sources/build-common.sh /work/build-common.sh
COPY sources/build-selected-deps.sh /work/build-selected-deps.sh
COPY sources/dependency-versions.sh /work/dependency-versions.sh
COPY sources/lv_conf.h /work/lv_conf.h
COPY sources/rebuildffmpeg.sh /work/rebuildffmpeg.sh
COPY sources/rebuildfreetype.sh /work/rebuildfreetype.sh
COPY sources/rebuildlibusb.sh /work/rebuildlibusb.sh
COPY sources/rebuildlvgl.sh /work/rebuildlvgl.sh
COPY sources/rebuildsqlite.sh /work/rebuildsqlite.sh
COPY --from=fetcher /dist/ /dist/

RUN printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "60";' \
        'Acquire::https::Timeout "60";' \
        'Acquire::http::Pipeline-Depth "0";' \
        'Acquire::Check-Valid-Until "false";' \
        'Acquire::AllowInsecureRepositories "true";' \
        'APT::Get::AllowUnauthenticated "true";' \
        > /etc/apt/apt.conf.d/99laneapp-legacy && \
    printf '%s\n' \
        'deb http://archive.debian.org/debian wheezy main' \
        'deb http://archive.debian.org/debian wheezy contrib' \
        'deb http://archive.debian.org/debian wheezy non-free' \
        'deb http://archive.debian.org/debian-security wheezy/updates main' \
        'deb http://archive.debian.org/debian-security wheezy/updates contrib' \
        'deb http://archive.debian.org/debian-security wheezy/updates non-free' \
        > /etc/apt/sources.list

RUN set -e; \
    retry() { \
        n=1; \
        while true; do \
            "$@" && return 0; \
            if [ "$n" -ge 5 ]; then return 1; fi; \
            echo "Retry $n/5: $*" >&2; \
            n=$((n + 1)); \
            sleep 5; \
        done; \
    }; \
    rm -rf /var/lib/apt/lists/* && \
    retry apt-get -o Acquire::Check-Valid-Until=false -y --force-yes -q update && \
    retry apt-get install -y --fix-missing --force-yes -q \
        autoconf \
        automake \
        binutils \
        build-essential \
        busybox-static \
        ca-certificates \
        cmake \
        file \
        flex \
        bison \
        libtool \
        m4 \
        make \
        perl \
        pkg-config \
        wget \
        xz-utils && \
    retry apt-get install -y --fix-missing --force-yes -q \
        libconfig-dev \
        libjpeg-dev \
        libpng12-dev \
        libpq-dev \
        libudev-dev \
        zlib1g-dev && \
    retry apt-get install -y --fix-missing --force-yes -q \
        libxml2-dev && \
    retry apt-get install -y --fix-missing --force-yes -q \
        libgtk2.0-dev \
        libvncserver-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chmod +x /work/*.sh && \
    cd /work && \
    cat toolchain.tar.gz* | tar xz && \
    tar xzf ./toolchain_R2_EABI.tar.gz && \
    rm -f ./toolchain_R2_EABI.tar.gz ./toolchain.tar.gz*

RUN rm -rf \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/include/minigui \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/include/freetype2 \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/include/lvgl && \
    rm -f \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/etc/MiniGUI.cfg \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/bin/curl-config \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/bin/freetype-config \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/include/lvgl.h \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/include/lv_conf.h \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext-2.0.so.4 \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext-2.0.so.4.0.0 \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext.a \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext.la \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext.so \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui-2.0.so.4 \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui-2.0.so.4.0.0 \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui.a \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui.la \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui.so \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libcurl* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libfreetype* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libsqlite3* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libusb-1.0* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libavcodec* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libavformat* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libavutil* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libswscale* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/liblvgl.a \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/freetype2.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libcurl.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libusb-1.0.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/sqlite3.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libavcodec.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libavformat.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libavutil.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/libswscale.pc \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/pkgconfig/lvgl.pc

RUN /work/build-selected-deps.sh arm freetype sqlite libusb curl ffmpeg lvgl && \
    rm -rf /dist

WORKDIR /LaneApp

CMD ["bash"]
