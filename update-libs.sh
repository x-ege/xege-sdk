#!/usr/bin/env bash

cd "$(dirname "$0")"

set -e

THIS_DIR=$(realpath .)

# Default values
DEFAULT_XEGE_LIB_DIR="../xege-libs-cache"
# By default we skip downloading the archive. Pass -f or --force-download to
# force a fresh download (disable skipping).
SKIP_DOWNLOAD=1

# Parse arguments: first non-flag is XEGE_LIB_DIR; support --skip-download/-n
# to explicitly request skipping, or -f/--force-download to force download
XEGE_LIB_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
    --skip-download | -n)
        SKIP_DOWNLOAD=1
        shift
        ;;
    -f | --force-download)
        # Force download: disable skip
        SKIP_DOWNLOAD=0
        shift
        ;;
    *)
        if [[ -z "$XEGE_LIB_DIR" ]]; then
            XEGE_LIB_DIR="$1"
        else
            echo "Warning: ignoring extra argument: $1"
        fi
        shift
        ;;
    esac
done

if [[ -z "$XEGE_LIB_DIR" ]]; then
    XEGE_LIB_DIR="$DEFAULT_XEGE_LIB_DIR"
fi
export XEGE_LIB_DIR

mkdir -p "$XEGE_LIB_DIR" || exit 1

XEGE_LIB_DIR=$(realpath "$XEGE_LIB_DIR")

cd "$XEGE_LIB_DIR"

ARCHIVE_NAME="ege_release.7z"
ARCHIVE_URL="https://jenkins.xege.org/view/%E6%9C%80%E6%96%B0%E5%8F%91%E5%B8%83/job/ege-latest/lastSuccessfulBuild/artifact/collected/merged_ege_release.7z"

if [[ $SKIP_DOWNLOAD -eq 1 && -f "$ARCHIVE_NAME" ]]; then
    echo "Skip download requested and '$ARCHIVE_NAME' already exists — skipping download."
    export DID_SKIP_DOWNLOAD=true
else
    echo "Downloading '$ARCHIVE_NAME' from $ARCHIVE_URL ..."
    # remove any existing archives first to avoid confusion
    rm -f *.7z || true
    if command -v wget >/dev/null 2>&1; then
        wget "$ARCHIVE_URL" -O "$ARCHIVE_NAME"
    elif command -v curl >/dev/null 2>&1; then
        # -L follow redirects
        curl -L "$ARCHIVE_URL" -o "$ARCHIVE_NAME"
    else
        echo "Error: neither wget nor curl is installed. Cannot download $ARCHIVE_URL"
        exit 1
    fi
fi

if command -v 7z >/dev/null 2>&1; then
    7z x -aoa ege_release.7z
elif command -v 7za >/dev/null 2>&1; then
    7za x -aoa ege_release.7z
else
    echo "Error: Neither 7z nor 7za is installed."
    exit 1
fi

# 定义拷贝映射关系
# SRC: 来自解压后的 ege_release 目录
# DST: 目标路径（相对于 THIS_DIR）

# 所有 lib 目录直接全部覆盖，除了 vs2010 需要特殊处理
declare -a COPY_MAPPING_SRC=(
    include

    lib/macOS
    lib/mingw-w64-debian
    lib/mingw64
    lib/codeblocks
    lib/devcpp
    lib/redpanda

    lib/vs2026
    lib/vs2022
    lib/vs2019
    lib/vs2017

    # vs2010 需要特殊处理 (参考插件项目规则)
    lib/vs2010/x86
    lib/vs2010/x64
)

declare -a COPY_MAPPING_DST=(
    include

    lib/macOS
    lib/mingw-w64-debian
    lib/mingw64
    lib/codeblocks
    lib/devcpp
    lib/redpanda

    lib/vs2026
    lib/vs2022
    lib/vs2019
    lib/vs2017

    # vs2010 特殊映射: x86 -> vs2010 根目录, x64 -> vs2010/amd64
    lib/vs2010
    lib/vs2010/amd64
)

# 这里确保一下 SRC 和 DST 长度一致
if [[ ${#COPY_MAPPING_SRC[@]} -ne ${#COPY_MAPPING_DST[@]} ]]; then
    echo "Error: SRC and DST arrays have different lengths."
    exit 1
fi

function performSync() {
    # 传入俩参数 src 和 dst, 进行同步操作
    local src="$XEGE_LIB_DIR/$1"
    local dst="$THIS_DIR/$2"
    echo "Syncing '$src' to '$dst'..."

    if [[ ! -e "$src" ]]; then
        echo "Error: Source '$src' does not exist."
        exit 1
    fi

    # Ensure destination parent directory exists.
    local dst_parent
    dst_parent=$(dirname "$dst")
    if [[ -n "$dst_parent" && ! -d "$dst_parent" ]]; then
        mkdir -p "$dst_parent" || {
            echo "Error: Failed to create directory '$dst_parent'"
            return 1
        }
    fi

    # 如果源是目录，需要确保目标目录存在，并复制目录内容（而不是目录本身）
    if [[ -d "$src" ]]; then
        # 确保目标目录存在
        mkdir -p "$dst"
        # 使用 rsync 或 cp 复制目录内容
        if command -v rsync >/dev/null 2>&1; then
            # rsync 末尾加 / 表示复制目录内容而非目录本身
            rsync -a --delete "$src/" "$dst/"
        else
            # cp -r 复制目录内容
            cp -r "$src"/* "$dst/" 2>/dev/null || true
        fi
    else
        # 文件直接复制
        if command -v rsync >/dev/null 2>&1; then
            rsync -a "$src" "$dst"
        else
            cp "$src" "$dst"
        fi
    fi
}

for i in "${!COPY_MAPPING_SRC[@]}"; do
    performSync "${COPY_MAPPING_SRC[$i]}" "${COPY_MAPPING_DST[$i]}"
done

echo ""
echo "=== Update completed ==="
cat "$XEGE_LIB_DIR/buildInfo.txt"

if [[ "$DID_SKIP_DOWNLOAD" == "true" ]]; then
    echo ""
    echo "Warning: 最新包的下载本次被跳过, 被同步的 ege 版本不一定是最新的. 如果要保证获取最新版本, 可以重新执行本脚本并传入参数 -f"
fi
