#!/usr/bin/env bash

# EGE 安装包构建脚本
# 克隆 ege-installer 项目并调用其 build.ps1 打包本项目为 exe 安装包
#
# 用法:
#   ./build-installer.sh                    # 使用 version.txt 中的版本号
#   ./build-installer.sh -v 25.11.0         # 手动指定版本号
#   ./build-installer.sh --clean            # 清理缓存后重新构建
#
# 前置条件 (Windows):
#   - PowerShell 5.1+
#   - NSIS 3.11+ (可通过 winget install NSIS.NSIS 或 scoop install nsis 安装)
#   - Git

set -e
cd "$(dirname "$0")"

THIS_DIR=$(realpath .)
INSTALLER_REPO="https://github.com/x-ege/ege-installer.git"
INSTALLER_DIR="$THIS_DIR/ege-installer"
OUTPUT_DIR="$THIS_DIR/dist"

# 解析参数
CUSTOM_VERSION=""
CLEAN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
    -v | --version)
        if [[ -z "${2:-}" ]]; then
            echo "Error: -v/--version requires a version argument"
            exit 1
        fi
        CUSTOM_VERSION="$2"
        shift 2
        ;;
    --clean)
        CLEAN=1
        shift
        ;;
    *)
        echo "Warning: ignoring unknown argument: $1"
        shift
        ;;
    esac
done

echo "=== EGE Installer Build Script ==="
echo ""

# Step 1: 清理（如果指定了 --clean）
if [[ $CLEAN -eq 1 ]]; then
    echo "Cleaning ege-installer cache..."
    rm -rf "$INSTALLER_DIR"
    rm -rf "$OUTPUT_DIR"
    echo ""
fi

# Step 2: 克隆或更新 ege-installer
echo "=== Preparing ege-installer ==="

if [[ -d "$INSTALLER_DIR/.git" ]]; then
    echo "Updating existing ege-installer..."
    cd "$INSTALLER_DIR"
    git fetch origin
    git reset --hard origin/main
    cd "$THIS_DIR"
else
    echo "Cloning ege-installer..."
    rm -rf "$INSTALLER_DIR"
    git clone --depth 1 "$INSTALLER_REPO" "$INSTALLER_DIR"
fi

echo ""

# Step 3: 读取版本号
if [[ -n "$CUSTOM_VERSION" ]]; then
    EGE_VERSION="$CUSTOM_VERSION"
    echo "Using custom version: $EGE_VERSION"
else
    VERSION_FILE="$THIS_DIR/version.txt"
    if [[ ! -f "$VERSION_FILE" ]]; then
        echo "Error: version.txt not found."
        exit 1
    fi
    EGE_VERSION=$(tr -d '[:space:]' <"$VERSION_FILE")
    if [[ -z "$EGE_VERSION" ]]; then
        echo "Error: version.txt is empty."
        exit 1
    fi
    echo "Using version from version.txt: $EGE_VERSION"
fi

echo ""

# Step 4: 检查必要目录
if [[ ! -d "$THIS_DIR/include" || ! -d "$THIS_DIR/lib" ]]; then
    echo "Error: include/ or lib/ directory not found."
    echo "Please run update-libs.sh first to fetch EGE library files."
    exit 1
fi

# Step 5: 调用 build.ps1 打包
echo "=== Building installer package ==="
echo "EGE Libs: $THIS_DIR"
echo "Installer: $INSTALLER_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# 将路径转换为 Windows 格式（兼容 Git Bash / MSYS2）
to_win_path() {
    local p="$1"
    # 如果是 /c/... 形式的路径，转换为 C:\...
    if [[ "$p" =~ ^/([a-zA-Z])/ ]]; then
        local drive="${BASH_REMATCH[1]}"
        p="${drive^^}:${p:2}"
    fi
    echo "$p" | sed 's|/|\\|g'
}

XEGE_LIBS_WIN=$(to_win_path "$THIS_DIR")

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 使用 PowerShell 调用 build.ps1
BUILD_SCRIPT="$INSTALLER_DIR/scripts/build.ps1"

if [[ ! -f "$BUILD_SCRIPT" ]]; then
    echo "Error: build.ps1 not found at $BUILD_SCRIPT"
    exit 1
fi

BUILD_SCRIPT_WIN=$(to_win_path "$BUILD_SCRIPT")

echo "Running: powershell -File $BUILD_SCRIPT_WIN ..."
echo ""

# 注意：build.ps1 的 NSIS 输出路径被硬编码为 ege-installer/dist/
# 不传 OutputDir，让 build.ps1 使用默认值，之后再复制到本地 dist/
powershell -NoProfile -ExecutionPolicy Bypass -File "$BUILD_SCRIPT_WIN" \
    -XegeLibsPath "$XEGE_LIBS_WIN" \
    -Version "$EGE_VERSION"

echo ""

# Step 6: 从 ege-installer/dist/ 复制输出到本地 dist/
INSTALLER_OUTPUT="$INSTALLER_DIR/dist/ege-installer-${EGE_VERSION}.exe"
EXE_FILE="$OUTPUT_DIR/ege-installer-${EGE_VERSION}.exe"

if [[ -f "$INSTALLER_OUTPUT" ]]; then
    cp "$INSTALLER_OUTPUT" "$EXE_FILE"
    echo "=== Build completed successfully ==="
    echo "Output: $EXE_FILE"
    ls -lh "$EXE_FILE"
else
    echo "Error: Build output not found."
    echo "Expected: $INSTALLER_OUTPUT"
    # 尝试查找任何生成的 exe
    echo "Files in ege-installer/dist/:"
    ls -la "$INSTALLER_DIR/dist/" 2>/dev/null || echo "  (directory not found)"
    exit 1
fi
