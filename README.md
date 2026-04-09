# Build Images

Chinese README: [README.zh-CN.md](README.zh-CN.md)

These Dockerfiles are the build-image definitions used by local verification, CI, and the legacy VisualGDB debug container.

Image layout:

- `sources/` stores the shared dependency version manifest, GitHub source-fetch helpers, target build scripts, `lv_conf.h`, and the legacy ARM toolchain bundles. Portable third-party source snapshots are not checked in locally anymore.
- `x86Legacy/` keeps the legacy Wheezy-based X86 debug image, including MiniGUI 2.0.4, SSH, and the old toolchain/debug baseline.
- `x86/` is the modern native i386 build image. It stays aligned with the non-legacy platform images and does not carry the old MiniGUI/SSH/debug stack.
- `arm/` for `ARM`
- `x64/` for `X64`
- `arm64/` for `ARM64`
- `loongson/` for `LA64`

Shared dependency policy:

- All portable third-party dependencies are downloaded at build time from pinned GitHub release/tag archives and verified with SHA256 before extraction.
- The current pinned versions are `curl 8.10.1`, `freetype 2.13.3`, `libusb 1.0.23`, `sqlite 3.51.2`, `ffmpeg 4.4.5`, and `lvgl 9.5.0`.
- `libusb` is intentionally pinned to `1.0.23` because `1.0.24+` switched to a C11 baseline, which is not a safe match for the legacy ARM `gcc 4.6.1` toolchain.
- `sqlite` stays aligned with the upstream app's `3.51.2` baseline so the image exposes a matching static `libsqlite3.a`, and it is fetched from the pinned GitHub mirror tag at image-build time like the other portable dependencies.
- Every image now builds `freetype/sqlite/libusb/curl/ffmpeg/lvgl` from source and installs static libraries, headers, and pkg-config metadata for the target platform.
- `lvgl` is built with the shared `lv_conf.h`, with FreeType, QRCode, FFmpeg, and Linux framebuffer support enabled.
- `x86Legacy` vendors the required `MiniGUI 2.0.4` source archive locally so the legacy image stays buildable even if the upstream GitHub repository is renamed, deleted, or otherwise unavailable.

Batch build with Docker Compose:

- `docker-compose.yml` can start all build images in parallel and bind-mount a host source directory into `/LaneApp`.
- `docker-compose.yml` is the runtime entrypoint and pulls prebuilt images from GHCR by default.
- `docker-compose.override.yml` only carries the local `build` definitions. When you run `docker compose up --build`, Compose uses the override and rebuilds the images locally before starting them.
- Set `BUILD_DIR` to the host directory you want to build, and optionally set `BUILD_COMMAND` (defaults to `make`).
- Optionally set `PCCT_IMAGE_PREFIX` (defaults to `ghcr.io/maikebing`) and `PCCT_IMAGE_TAG` (defaults to `latest`) to switch image registry/tag.
- PowerShell example:
  `$env:BUILD_DIR='D:/path/to/project'; $env:BUILD_COMMAND='make'; docker compose up --build`
- Bash example:
  `BUILD_DIR=/abs/path/to/project BUILD_COMMAND=make docker compose up --build`
- The compose run exits after all service commands finish. Build outputs stay in the mounted host directory.

Legacy VisualGDB debug entrypoint:

- Start the local debug builder with `docker compose -f docker-compose.debug.yml up --build -d x86-debug-builder`
- The container exposes SSH on `127.0.0.1:2221`, which matches `LaneApp-Debug.vgdbsettings`
- `x86Legacy` still keeps the MiniGUI 2.0.4, SSH, and dual-target `arm + x86` legacy workflow; the other images stay on the unified modern dependency stack.
