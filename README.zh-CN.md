# 构建镜像说明

English README: [README.md](README.md)

本仓库保存的是构建镜像定义，供本地验证、CI，以及遗留的 VisualGDB 调试容器共同使用。

## 目录布局

- `sources/`：保存共享依赖版本清单、GitHub 源码拉取脚本、各平台通用构建脚本、`lv_conf.h`，以及遗留 ARM 工具链压缩包。本仓库不再长期保存通用第三方库的本地源码快照。
- `x86Legacy/`：遗留 Wheezy 基线的 X86 调试镜像，包含 MiniGUI 2.0.4、SSH，以及旧版工具链/调试环境。
- `x86/`：现代化原生 i386 构建镜像，与其他非遗留平台镜像保持一致，不再携带旧版 MiniGUI/SSH/调试栈。
- `arm/`：`ARM` 平台构建镜像。
- `x64/`：`X64` 平台构建镜像。
- `arm64/`：`ARM64` 平台构建镜像。
- `loongson/`：`LA64` 平台构建镜像。

## 共享依赖策略

- 可移植的第三方依赖统一在镜像构建阶段下载，来源为固定的 GitHub release/tag 压缩包，并在解压前进行 SHA256 校验。
- 当前固定版本为：`curl 8.10.1`、`freetype 2.13.3`、`libusb 1.0.23`、`sqlite 3.51.2`、`ffmpeg 4.4.5`、`lvgl 9.5.0`。
- `libusb` 固定在 `1.0.23`，因为 `1.0.24+` 已切换到 C11 基线，不适合遗留 ARM `gcc 4.6.1` 工具链。
- `sqlite` 与上游应用保持 `3.51.2` 一致，镜像内提供匹配版本的静态库 `libsqlite3.a`，并与其他依赖一样在镜像构建时从固定 GitHub tag 拉取源码。
- 所有平台镜像都会从源码构建 `freetype/sqlite/libusb/curl/ffmpeg/lvgl`，并安装目标平台对应的静态库、头文件和 `pkg-config` 元数据。
- `lvgl` 使用共享的 `lv_conf.h` 构建，并开启 FreeType、QRCode、FFmpeg、Linux framebuffer 支持。

## x86Legacy 特殊说明

- `x86Legacy` 仍保留 MiniGUI 2.0.4、SSH，以及 `arm + x86` 双目标的历史调试流程。
- `x86Legacy` 所需的 `MiniGUI 2.0.4` 源码压缩包已随仓库一同保存，避免未来因上游 GitHub 仓库改名、删除或不可访问而导致遗留镜像无法重建。
- MiniGUI 本地归档的来源、固定提交和 SHA256 记录在 `sources/minigui2.0.4-eb30dfdc.txt`。

## 依赖构建约定

- 通用版本信息集中在 `sources/dependency-versions.sh`。
- 通用源码下载逻辑在 `sources/fetch-github-sources.sh`。
- 通用构建入口在 `sources/build-selected-deps.sh`。
- 各依赖的具体重建逻辑分别位于 `rebuildcurl.sh` 与 `sources/rebuild*.sh`。
- 镜像发布流水线位于 `.github/workflows/publish-build-images.yml`，提交后可由 CI 统一验证和发布。

## 遗留 VisualGDB 调试入口

- 使用 `docker compose -f docker-compose.debug.yml up --build -d x86-debug-builder` 启动本地调试构建容器。
- 容器通过 `127.0.0.1:2221` 暴露 SSH，对应 `LaneApp-Debug.vgdbsettings` 中的配置。
- 除 `x86Legacy` 外，其余镜像均采用统一的现代依赖栈。
