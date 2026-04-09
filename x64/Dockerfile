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

ARG PCCT_USE_TUNA_MIRROR=1

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    CC=gcc \
    CXX=g++ \
    AR=ar \
    AS=as \
    LD=ld \
    NM=nm \
    RANLIB=ranlib \
    STRIP=strip \
    OBJCOPY=objcopy \
    OBJDUMP=objdump \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

RUN printf '%s\n' \
        'Acquire::Retries "5";' \
        'Acquire::http::Timeout "60";' \
        'Acquire::https::Timeout "60";' \
        'Acquire::http::Pipeline-Depth "0";' \
        > /etc/apt/apt.conf.d/99laneapp-network && \
    rm -f /etc/apt/sources.list.d/debian.sources && \
    if [ "$PCCT_USE_TUNA_MIRROR" = "1" ]; then \
        DEBIAN_MIRROR='http://mirrors.tuna.tsinghua.edu.cn/debian'; \
        DEBIAN_SECURITY_MIRROR='http://mirrors.tuna.tsinghua.edu.cn/debian-security'; \
    else \
        DEBIAN_MIRROR='http://deb.debian.org/debian'; \
        DEBIAN_SECURITY_MIRROR='http://deb.debian.org/debian-security'; \
    fi && \
    printf '%s\n' \
        "deb ${DEBIAN_MIRROR} trixie main" \
        "deb ${DEBIAN_MIRROR} trixie-updates main" \
        "deb ${DEBIAN_SECURITY_MIRROR} trixie-security main" \
        > /etc/apt/sources.list && \
    for attempt in 1 2 3 4 5; do \
        rm -rf /var/lib/apt/lists/*; \
        if apt-get update && \
           apt-get install -y --no-install-recommends --fix-missing \
               autoconf \
               automake \
               gcc \
               g++ \
               ca-certificates \
               file \
               flex \
               bison \
               libconfig-dev \
               libjpeg-dev \
               libpq-dev \
               libudev-dev \
               libtool \
               libtool-bin \
               m4 \
               make \
               perl \
               pkg-config \
               wget \
               zlib1g-dev; then \
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
    /work/build-selected-deps.sh x64 freetype sqlite libusb curl ffmpeg lvgl && \
    rm -rf /dist

WORKDIR /LaneApp

CMD ["bash"]
