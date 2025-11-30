#!/usr/bin/env bash

cd "$(dirname "$0")"

set -e

THIS_DIR=$(realpath .)

# 简要说明:
# 1) 默认先执行 update-libs.sh -f 强制下载最新包并更新本地文件（可用 -s 跳过）。
# 2) 检查 git 工作目录是否干净，若有未提交的修改则报错退出。
# 3) 从 version.txt 读取版本号并创建发布目录 `ege-<version>`。
# 4) 将要发布的目录与文件复制到发布目录（.vscode,demo,include,man,lib 等）。
# 5) 优先使用 7z/7za 打包成 .7z；若不可用且存在 PowerShell 则退回到 ZIP（使用 Compress-Archive）。
# 6) 最终会在仓库根生成 ege-<version>.7z 或 ege-<version>.zip。

# 解析参数
SKIP_UPDATE=0
while [[ $# -gt 0 ]]; do
    case "$1" in
    -s | --skip-update)
        SKIP_UPDATE=1
        shift
        ;;
    *)
        echo "Warning: ignoring unknown argument: $1"
        shift
        ;;
    esac
done

# Step 1: 执行 update-libs.sh -f 强制下载最新包（除非指定 -s 跳过）
if [[ $SKIP_UPDATE -eq 1 ]]; then
    echo "=== Skipping update-libs.sh (--skip-update) ==="
else
    echo "=== Running update-libs.sh -f to fetch latest release ==="
    if [[ -x "$THIS_DIR/update-libs.sh" ]]; then
        "$THIS_DIR/update-libs.sh" -f
    else
        echo "Error: update-libs.sh not found or not executable."
        exit 1
    fi
fi

# Step 2: 检查 git 工作目录是否干净
echo ""
echo "=== Checking git working directory ==="
if ! command -v git >/dev/null 2>&1; then
    echo "Warning: git not found, skipping working directory check."
elif [[ -n $(git status --porcelain) ]]; then
    echo "Error: Git working directory is not clean. Please commit or stash your changes before releasing."
    git status --short
    exit 1
else
    echo "Git working directory is clean."
fi

# Step 3: 从 version.txt 读取版本号
VERSION_FILE="$THIS_DIR/version.txt"
if [[ ! -f "$VERSION_FILE" ]]; then
    echo "Error: version.txt not found. Please run update-libs.sh first."
    exit 1
fi

## 从 version.txt 读取并去除所有空白字符（包括空格、制表符、换行）
EGE_VERSION=$(tr -d '[:space:]' <"$VERSION_FILE")
if [[ -z "$EGE_VERSION" ]]; then
    echo "Error: version.txt is empty."
    exit 1
fi

echo "EGE Version: $EGE_VERSION"

# 创建发布目录
RELEASE_DIR_NAME="ege-${EGE_VERSION}"
RELEASE_DIR="$THIS_DIR/$RELEASE_DIR_NAME"
RELEASE_ARCHIVE="$THIS_DIR/${RELEASE_DIR_NAME}.7z"

# 清理旧的发布目录和压缩包
rm -rf "$RELEASE_DIR"
rm -f "$RELEASE_ARCHIVE"

mkdir -p "$RELEASE_DIR"

echo "Creating release directory: $RELEASE_DIR"

# 复制目录
declare -a DIRS_TO_COPY=(
    .vscode
    demo
    include
    man
    lib
)

for dir in "${DIRS_TO_COPY[@]}"; do
    if [[ -d "$THIS_DIR/$dir" ]]; then
        echo "Copying directory: $dir"
        cp -r "$THIS_DIR/$dir" "$RELEASE_DIR/$dir"
    else
        echo "Warning: Directory '$dir' not found, skipping."
    fi
done

# 复制文件
declare -a FILES_TO_COPY=(
    egelogo.jpg
    CMakeLists.txt
)

for file in "${FILES_TO_COPY[@]}"; do
    if [[ -f "$THIS_DIR/$file" ]]; then
        echo "Copying file: $file"
        cp "$THIS_DIR/$file" "$RELEASE_DIR/$file"
    else
        echo "Warning: File '$file' not found, skipping."
    fi
done

# 复制 README.md 为 说明.txt
if [[ -f "$THIS_DIR/README.md" ]]; then
    echo "Copying README.md as 说明.txt"
    cp "$THIS_DIR/README.md" "$RELEASE_DIR/说明.txt"
else
    echo "Warning: README.md not found, skipping."
fi

# 复制 doc 目录下的文件到根目录，后缀改为 .txt
if [[ -d "$THIS_DIR/doc" ]]; then
    echo "Copying doc files to release root (with .txt extension)..."
    for doc_file in "$THIS_DIR/doc"/*; do
        if [[ -f "$doc_file" ]]; then
            # 获取文件名（不含路径）
            base_name=$(basename "$doc_file")
            # 去掉原有后缀，加上 .txt
            name_without_ext="${base_name%.*}"
            new_name="${name_without_ext}.txt"
            echo "  $base_name -> $new_name"
            cp "$doc_file" "$RELEASE_DIR/$new_name"
        fi
    done
else
    echo "Warning: doc directory not found, skipping."
fi

# 打包（优先 7z/7za；如果没有，尝试使用 PowerShell 生成 ZIP）
echo ""
echo "Creating archive: $RELEASE_ARCHIVE"

if command -v 7z >/dev/null 2>&1; then
    echo "Using 7z to create archive: $RELEASE_ARCHIVE"
    7z a -t7z -mx=9 "$RELEASE_ARCHIVE" "$RELEASE_DIR"
elif command -v 7za >/dev/null 2>&1; then
    echo "Using 7za to create archive: $RELEASE_ARCHIVE"
    7za a -t7z -mx=9 "$RELEASE_ARCHIVE" "$RELEASE_DIR"
else
    # fallback: try powershell (pwsh or powershell)
    if command -v powershell >/dev/null 2>&1; then
        # switch to .zip extension
        RELEASE_ARCHIVE="$THIS_DIR/${RELEASE_DIR_NAME}.zip"
        echo "7z not found — using PowerShell to create ZIP: $RELEASE_ARCHIVE"

        powershell -NoProfile -Command "Set-Location -LiteralPath '$THIS_DIR'; if (Test-Path -Path '$RELEASE_ARCHIVE') { Remove-Item -Force -Path '$RELEASE_ARCHIVE' } ; Compress-Archive -LiteralPath '$RELEASE_DIR_NAME' -DestinationPath '$RELEASE_ARCHIVE' -Force"
    else
        echo "Error: Neither 7z/7za nor PowerShell (pwsh/powershell) is available to create archive."
        exit 1
    fi
fi

# 保留发布目录方便检查, 发布目录已被忽略

echo ""
echo "=== Release completed ==="
echo "Archive: $RELEASE_ARCHIVE"
ls -lh "$RELEASE_ARCHIVE"
