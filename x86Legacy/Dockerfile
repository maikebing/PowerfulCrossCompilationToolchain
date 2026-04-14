ARG BASE_PLATFORM=linux/386

FROM debian:bookworm-slim AS fetcher

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY sources/dependency-versions.sh /work/dependency-versions.sh
COPY sources/fetch-github-sources.sh /work/fetch-github-sources.sh

RUN for attempt in 1 2 3 4 5; do \
        rm -rf /var/lib/apt/lists/*; \
        if apt-get update && \
           apt-get install -y --no-install-recommends --fix-missing ca-certificates wget; then \
            break; \
        fi; \
        if [ "$attempt" = "5" ]; then \
            exit 1; \
        fi; \
        echo "apt attempt $attempt failed, retrying..." >&2; \
        sleep 10; \
    done && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /work/*.sh && \
    /work/fetch-github-sources.sh /dist curl freetype libusb sqlite ffmpeg lvgl && \
    echo "Fetching PostgreSQL 17.2..." && \
    wget -q --https-only --tries=5 --waitretry=10 \
        -O /dist/postgresql-REL_17_2.tar.gz \
        https://github.com/postgres/postgres/archive/refs/tags/REL_17_2.tar.gz && \
    echo "PostgreSQL 17.2 fetched successfully"

FROM --platform=${BASE_PLATFORM} i386/debian:wheezy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
COPY sources/rebuildpostgresql.sh /work/rebuildpostgresql.sh
COPY sources/minigui2.0.4-eb30dfdc.tar.gz /work/minigui2.0.4-eb30dfdc.tar.gz
COPY --from=fetcher /dist/ /dist/

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
    echo "deb http://archive.debian.org/debian  wheezy main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian  wheezy contrib" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian  wheezy non-free" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security wheezy  updates/main" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security wheezy  updates/contrib" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security wheezy  updates/non-free" >> /etc/apt/sources.list && \
    retry apt-get -y --force-yes -q update && \
    retry apt-get install -y --fix-missing --force-yes -q git build-essential gcc binutils automake libtool make cmake pkg-config busybox-static ca-certificates file flex bison wget xz-utils && \
    retry apt-get install -y --fix-missing --force-yes -q libgtk2.0-dev libjpeg-dev libpng12-dev libxml2-dev libconfig-dev libpq-dev libudev-dev libvncserver-dev zlib1g-dev && \
    retry apt-get install -y --fix-missing --force-yes -q openssh-server && \
    retry apt-get install -y --fix-missing --force-yes -q gdb gdbserver && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chmod +x /work/*.sh && \
    cd /work && \
    cat toolchain.tar.gz* | tar xz && \
    tar xzf ./toolchain_R2_EABI.tar.gz && \
    rm -f /work/toolchain_R2_EABI.tar.gz /work/toolchain.tar.gz*

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
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libmgext* \
        /work/toolchain_R2_EABI/usr/arm-unknown-linux-gnueabi/sysroot/usr/lib/libminigui* \
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

RUN /work/build-selected-deps.sh arm freetype sqlite libusb curl ffmpeg lvgl postgresql && \
    /work/build-selected-deps.sh x86 freetype sqlite libusb curl ffmpeg lvgl postgresql && \
    mkdir -p /tmp/minigui2.0.4 && \
    tar -xzf /work/minigui2.0.4-eb30dfdc.tar.gz -C /tmp/minigui2.0.4 --strip-components=1 && \
    cd /tmp/minigui2.0.4 && \
    chmod 755 ./rebuild && \
    ./rebuild && \
    make && \
    make install && \
    make clean && \
    chmod 755 ./rebuildx86 && \
    ./rebuildx86 && \
    make && \
    make install && \
    make clean && \
    rm -rf /tmp/minigui2.0.4 /dist

RUN mkdir /var/run/sshd
RUN echo 'root:1-q2-w3-e4-r5-t' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf && ldconfig

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig"
ENV CMAKE_PREFIX_PATH="/usr/local"
ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
