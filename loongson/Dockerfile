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

ARG LOONGSON_TOOLCHAIN_VERSION=2025.08.08
ARG LOONGSON_TOOLCHAIN_FILE=x86_64-cross-tools-loongarch64-binutils_2.45-gcc_15.1.0-glibc_2.42.tar.xz

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    SYSROOT=/opt/cross-tools/target \
    CROSS_COMPILE=loongarch64-unknown-linux-gnu- \
    ARCH=loongarch64 \
    CC=loongarch64-unknown-linux-gnu-gcc \
    CXX=loongarch64-unknown-linux-gnu-g++ \
    AR=loongarch64-unknown-linux-gnu-ar \
    AS=loongarch64-unknown-linux-gnu-as \
    LD=loongarch64-unknown-linux-gnu-ld \
    NM=loongarch64-unknown-linux-gnu-nm \
    RANLIB=loongarch64-unknown-linux-gnu-ranlib \
    STRIP=loongarch64-unknown-linux-gnu-strip \
    OBJCOPY=loongarch64-unknown-linux-gnu-objcopy \
    OBJDUMP=loongarch64-unknown-linux-gnu-objdump \
    PKG_CONFIG_SYSROOT_DIR=/opt/cross-tools/target \
    PKG_CONFIG_LIBDIR=/opt/cross-tools/target/usr/lib/loongarch64-linux-gnu/pkgconfig:/opt/cross-tools/target/usr/lib64/pkgconfig:/opt/cross-tools/target/usr/lib/pkgconfig:/opt/cross-tools/target/usr/share/pkgconfig \
    PATH=/usr/local/bin:/opt/cross-tools/bin:$PATH

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
    for attempt in 1 2 3 4 5; do \
        rm -rf /var/lib/apt/lists/*; \
        if apt-get update && \
           apt-get install -y --no-install-recommends --fix-missing \
               apt-rdepends \
               autoconf \
               automake \
               gcc \
               g++ \
               ca-certificates \
               debian-ports-archive-keyring \
               file \
               flex \
               bison \
               libtool \
               libtool-bin \
               m4 \
               make \
               perl \
               pkg-config \
               wget \
               xz-utils; then \
            break; \
        fi; \
        if [ "$attempt" = "5" ]; then \
            exit 1; \
        fi; \
        echo "apt bootstrap attempt $attempt failed, retrying..." >&2; \
        sleep 10; \
    done && \
    printf '%s\n' \
        'deb [arch=amd64] http://mirrors.tuna.tsinghua.edu.cn/debian trixie main' \
        'deb [arch=amd64] http://mirrors.tuna.tsinghua.edu.cn/debian trixie-updates main' \
        'deb [arch=amd64] http://mirrors.tuna.tsinghua.edu.cn/debian-security trixie-security main' \
        'deb [arch=loong64] http://deb.debian.org/debian-ports unstable main' \
        > /etc/apt/sources.list && \
    dpkg --add-architecture loong64 && \
    for attempt in 1 2 3 4 5; do \
        rm -rf /var/lib/apt/lists/*; \
        if apt-get update; then \
            break; \
        fi; \
        if [ "$attempt" = "5" ]; then \
            exit 1; \
        fi; \
        echo "apt loong64 index attempt $attempt failed, retrying..." >&2; \
        sleep 10; \
    done && \
    cd /tmp && \
    wget -q "https://github.com/loongson/build-tools/releases/download/${LOONGSON_TOOLCHAIN_VERSION}/${LOONGSON_TOOLCHAIN_FILE}" -O loongarch64-toolchain.tar.xz && \
    mkdir -p /opt && \
    tar -xf loongarch64-toolchain.tar.xz -C /opt && \
    rm -f loongarch64-toolchain.tar.xz && \
    test -x /opt/cross-tools/bin/loongarch64-unknown-linux-gnu-gcc && \
    mkdir -p /tmp/loong-debs && \
    mapfile -t target_packages < <( \
        apt-rdepends \
            libconfig-dev:loong64 \
            libjpeg-dev:loong64 \
            libpq-dev:loong64 \
            libudev-dev:loong64 \
            zlib1g-dev:loong64 \
        | awk '/^[^ ]/ { print $1 } /^  PreDepends: / { print $2 } /^  Depends: / { print $2 }' \
        | sed 's/:loong64$//' \
        | grep -v '^<' \
        | sort -u \
    ) && \
    cd /tmp/loong-debs && \
    for pkg in "${target_packages[@]}"; do \
        if apt-cache policy "${pkg}:loong64" | grep -q 'Candidate: (none)'; then \
            echo "skip package without install candidate: ${pkg}:loong64" >&2; \
            continue; \
        fi; \
        if ! apt-cache show "${pkg}:loong64" >/dev/null 2>&1; then \
            echo "skip package without candidate: ${pkg}:loong64" >&2; \
            continue; \
        fi; \
        for attempt in 1 2 3 4 5; do \
            if apt-get download "${pkg}:loong64"; then \
                break; \
            fi; \
            if [ "$attempt" = "5" ]; then \
                exit 1; \
            fi; \
            echo "apt download ${pkg}:loong64 attempt $attempt failed, retrying..." >&2; \
            sleep 10; \
        done; \
    done && \
    for deb in ./*.deb; do \
        dpkg-deb -x "${deb}" "${SYSROOT}"; \
    done && \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        'exec /opt/cross-tools/bin/loongarch64-unknown-linux-gnu-gcc \' \
        '  --sysroot=/opt/cross-tools/target \' \
        '  -I/opt/cross-tools/target/usr/include \' \
        '  -I/opt/cross-tools/target/usr/include/loongarch64-linux-gnu \' \
        '  -I/opt/cross-tools/target/usr/include/postgresql \' \
        '  -L/opt/cross-tools/target/lib \' \
        '  -L/opt/cross-tools/target/lib64 \' \
        '  -L/opt/cross-tools/target/lib/loongarch64-linux-gnu \' \
        '  -L/opt/cross-tools/target/usr/lib \' \
        '  -L/opt/cross-tools/target/usr/lib64 \' \
        '  -L/opt/cross-tools/target/usr/lib/loongarch64-linux-gnu \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib64 \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib/loongarch64-linux-gnu \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib64 \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib/loongarch64-linux-gnu \' \
        '  "$@"' \
        > /usr/local/bin/loongarch64-unknown-linux-gnu-gcc && \
    chmod +x /usr/local/bin/loongarch64-unknown-linux-gnu-gcc && \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        'exec /opt/cross-tools/bin/loongarch64-unknown-linux-gnu-g++ \' \
        '  --sysroot=/opt/cross-tools/target \' \
        '  -I/opt/cross-tools/target/usr/include \' \
        '  -I/opt/cross-tools/target/usr/include/loongarch64-linux-gnu \' \
        '  -I/opt/cross-tools/target/usr/include/postgresql \' \
        '  -L/opt/cross-tools/target/lib \' \
        '  -L/opt/cross-tools/target/lib64 \' \
        '  -L/opt/cross-tools/target/lib/loongarch64-linux-gnu \' \
        '  -L/opt/cross-tools/target/usr/lib \' \
        '  -L/opt/cross-tools/target/usr/lib64 \' \
        '  -L/opt/cross-tools/target/usr/lib/loongarch64-linux-gnu \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib64 \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/lib/loongarch64-linux-gnu \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib64 \' \
        '  -Wl,-rpath-link,/opt/cross-tools/target/usr/lib/loongarch64-linux-gnu \' \
        '  "$@"' \
        > /usr/local/bin/loongarch64-unknown-linux-gnu-g++ && \
    chmod +x /usr/local/bin/loongarch64-unknown-linux-gnu-g++ && \
    ln -sf /usr/local/bin/loongarch64-unknown-linux-gnu-gcc /usr/local/bin/loongarch64-linux-gnu-gcc && \
    ln -sf /usr/local/bin/loongarch64-unknown-linux-gnu-g++ /usr/local/bin/loongarch64-linux-gnu-g++ && \
    for tool in ar as ld nm ranlib strip objcopy objdump; do \
        ln -sf "/opt/cross-tools/bin/loongarch64-unknown-linux-gnu-${tool}" "/usr/local/bin/loongarch64-unknown-linux-gnu-${tool}"; \
        ln -sf "/opt/cross-tools/bin/loongarch64-unknown-linux-gnu-${tool}" "/usr/local/bin/loongarch64-linux-gnu-${tool}"; \
    done && \
    rm -rf /tmp/loong-debs /var/lib/apt/lists/*

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
    /work/build-selected-deps.sh la64 freetype sqlite libusb curl ffmpeg lvgl && \
    rm -rf /dist

WORKDIR /LaneApp

CMD ["bash"]
