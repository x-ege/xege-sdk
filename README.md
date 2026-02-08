# EGE (Easy Graphics Engine) SDK

[![GitHub Release](https://img.shields.io/github/v/release/x-ege/xege-sdk)](https://github.com/x-ege/xege-sdk/releases)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/x-ege/xege/blob/master/LICENSE)

EGE (Easy Graphics Engine) 是 Windows 下的简易绘图库，面向 C/C++ 初学者，接口简单易用，无需了解 Windows 编程即可快速上手图形编程。

**本仓库为 EGE 预编译 SDK 发布仓库**，包含头文件、预编译静态库和示例程序。源代码仓库请访问 [x-ege/xege](https://github.com/x-ege/xege)。

## 快速开始

```cpp
#include <graphics.h>

int main()
{
    initgraph(640, 480);

    setbkcolor(WHITE);
    cleardevice();

    setcolor(BLACK);
    setfont(36, 0, "微软雅黑");
    outtextxy(200, 200, "Hello, EGE!");

    getch();
    closegraph();
    return 0;
}
```

## 下载安装

### 方式一：使用安装器（推荐）

从 [GitHub Releases](https://github.com/x-ege/xege-sdk/releases) 下载 `ege-installer-x.x.x.exe`，运行后自动检测已安装的 IDE，一键完成配置。

详细安装教程请参考 [EGE 安装使用教程](https://github.com/x-ege/ege-installer/blob/master/INSTALLATION.md)。

### 方式二：使用 IDE 插件

| IDE | 插件 | 安装方式 |
|-----|------|---------|
| **[CLion](https://www.jetbrains.com/clion/)** | [XEGE Creator](https://plugins.jetbrains.com/plugin/28785-xege-creator) | Settings → Plugins → Marketplace 搜索 "XEGE Creator" |
| **[VS Code](https://code.visualstudio.com/)** | [EGE](https://marketplace.visualstudio.com/items?itemName=wysaid.ege) | 扩展面板搜索 "ege" |

### 方式三：手动安装

1. 下载 [最新 SDK 压缩包](https://github.com/x-ege/xege-sdk/releases)
2. 将 `include/` 下的头文件复制到编译器的 include 目录
3. 将 `lib/` 下对应平台的库文件复制到编译器的 lib 目录

## 支持的开发环境

| 编译器/IDE | 版本支持 | 备注 |
|------------|----------|------|
| [Visual Studio](https://visualstudio.microsoft.com/) | 2017 ~ 2026 | **推荐**，VS2017+ 使用统一 MSVC 静态库 |
| [CLion](https://www.jetbrains.com/clion/) | 支持 | **推荐**，可配合 [XEGE Creator 插件](https://plugins.jetbrains.com/plugin/28785-xege-creator)使用 |
| [VS Code](https://code.visualstudio.com/) | 支持 | **推荐**，可配合 [EGE 插件](https://marketplace.visualstudio.com/items?itemName=wysaid.ege)使用 |
| [小熊猫 C++](http://royqh.net/redpandacpp/) | 支持 | **推荐**，已内置 EGE，下载即可用 |
| [Code::Blocks](https://www.codeblocks.org/) | 支持 | 已测试 25.03 |
| MinGW / MinGW-w64 | 支持 | 支持 32/64 位 |
| 老版本 Visual Studio | 2010 ~ 2015 | 支持但不推荐（不支持 C++17） |
| [Dev-C++](https://sourceforge.net/projects/orwelldevcpp/) | 支持 | 已测试 5.11 |

**跨平台**：支持 Linux/macOS 下基于 MinGW-W64 + Wine 的交叉编译。

## SDK 目录结构

```
xege-sdk/
├── include/              # 头文件
│   ├── ege.h
│   ├── ege.zh_CN.h       # 中文注释版
│   └── graphics.h
├── lib/                  # 预编译静态库
│   ├── msvc/             # Visual Studio 2017-2026（统一）
│   │   ├── x64/
│   │   └── x86/
│   ├── mingw64/          # MinGW 64 位
│   ├── redpanda/         # 小熊猫 C++ / CLion
│   ├── codeblocks/       # Code::Blocks
│   ├── devcpp/           # Dev-C++
│   └── macOS/            # macOS 交叉编译
├── demo/                 # 示例程序源码
├── doc/                  # 文档
└── man/                  # API 手册
```

## 链接

| 资源 | 地址 |
|------|------|
| 官网 | <https://xege.org> |
| 源代码 | <https://github.com/x-ege/xege> |
| SDK 仓库 | <https://github.com/x-ege/xege-sdk> |
| 安装器 | <https://github.com/x-ege/ege-installer> |
| API 文档 | <https://xege.org/manual/api/> |
| 入门教程 | <https://xege.org/manual/tutorial/> |
| 百度网盘 | <https://pan.baidu.com/s/1qWxAgeK> |

## 版本更新说明

### 当前版本：25.11（2025-11）

**主要亮点：**

- 📸 **相机捕捉功能** - 新增 `ege::Camera` 类，支持摄像头画面采集（需 C++17）
- 📦 **图像库升级** - 使用 `stb_image` 支持更多格式（PNG/JPEG/BMP/GIF/TGA/PSD/HDR 等），移除 libpng/zlib 依赖
- 🎯 **输入增强** - 支持鼠标双击检测、扩展键（XBUTTON1/2）、快速按键检测（keypress/keyrelease/keyrepeat）
- ⚡ **性能提升** - 图像默认格式改为预乘 Alpha（PRGB32），显著提升渲染效率
- 🔧 **Debug/Release 库分离** - MSVC 提供独立的 `graphics.lib` 和 `graphicsd.lib`，自动选择
- 📦 **MSVC 库整合** - VS2017-2026 统一使用相同静态库，减少包体积约 50MB
- 🎮 **新增示例** - 五子棋（AI 对战）、排序可视化、函数绘制、A* 寻路、Boids 群集、生命游戏等

**完整更新记录：**

- [CHANGELOG.md](CHANGELOG.md) - 完整版本历史（25.11、24.04、20.08 等）
- [Release-25.11.md](doc/Release-25.11.md) - 详细发布公告
- [Release-notes.md](doc/Release-notes.md) - 在线版本说明
