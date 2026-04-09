FROM debian:bookworm-slim AS fetcher

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY sources/dependency-versions.sh /work/dependency-versions.sh
COPY sources/fetch-github-sources.sh /work/fetch-github-sources.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /work/*.sh && \
    /work/fetch-github-sources.sh /dist curl freetype libusb sqlite ffmpeg lvgl

FROM debian:trixie-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CC=aarch64-linux-gnu-gcc \
    CXX=aarch64-linux-gnu-g++ \
    AR=aarch64-linux-gnu-ar \
    AS=aarch64-linux-gnu-as \
    LD=aarch64-linux-gnu-ld \
    NM=aarch64-linux-gnu-nm \
    RANLIB=aarch64-linux-gnu-ranlib \
    STRIP=aarch64-linux-gnu-strip \
    OBJCOPY=aarch64-linux-gnu-objcopy \
    OBJDUMP=aarch64-linux-gnu-objdump \
    PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig

RUN printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "60";' \
        'Acquire::https::Timeout "60";' \
        'Acquire::http::Pipeline-Depth "0";' \
        > /etc/apt/apt.conf.d/99laneapp-network && \
    rm -f /etc/apt/sources.list.d/debian.sources && \
    printf '%s\n' \
        'deb http://mirrors.tuna.tsinghua.edu.cn/debian trixie main' \
        'deb http://mirrors.tuna.tsinghua.edu.cn/debian trixie-updates main' \
        'deb http://mirrors.tuna.tsinghua.edu.cn/debian-security trixie-security main' \
        > /etc/apt/sources.list && \
    dpkg --add-architecture arm64 && \
    for attempt in 1 2 3 4 5; do \
        rm -rf /var/lib/apt/lists/*; \
        if apt-get update && \
           apt-get install -y --no-install-recommends --fix-missing \
               autoconf \
               automake \
               binutils-aarch64-linux-gnu \
               gcc \
               g++ \
               ca-certificates \
               file \
               flex \
               bison \
               gcc-aarch64-linux-gnu \
               g++-aarch64-linux-gnu \
               libconfig-dev:arm64 \
               libc6-dev-arm64-cross \
               libjpeg-dev:arm64 \
               libpq-dev:arm64 \
               libudev-dev:arm64 \
               libtool \
               libtool-bin \
               m4 \
               make \
               perl \
               pkg-config \
               wget \
               zlib1g-dev:arm64; then \
            break; \
        fi; \
        if [ "$attempt" = "5" ]; then \
            exit 1; \
        fi; \
        echo "apt attempt $attempt failed, retrying..." >&2; \
        sleep 10; \
    done && \
    rm -rf /var/lib/apt/lists/*

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

RUN chmod +x /work/*.sh && \
    /work/build-selected-deps.sh arm64 freetype sqlite libusb curl ffmpeg lvgl && \
    rm -rf /dist

WORKDIR /LaneApp

CMD ["bash"]
