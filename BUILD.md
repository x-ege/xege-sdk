# EGE 编译说明

本文档说明如何从源代码编译 EGE (Easy Graphics Engine) 图形库。

## 快速使用预编译版本

如果你只是想使用 EGE 图形库而不需要从源代码编译，可以直接从本仓库获取预编译的静态库文件。

本仓库（xege.org）是 [xege 源代码仓库](https://github.com/x-ege/xege) 的产物存储项目，包含了预编译的库文件和头文件，可以直接在项目中使用。

### 使用方法

1. 下载本仓库的 `include` 和 `lib` 目录
2. 在你的项目中配置包含路径指向 `include` 目录
3. 链接相应的库文件（位于 `lib` 目录）

详细的安装配置教程请参见：<https://xege.org/beginner-lesson-1.html>

## 支持的编译环境

EGE 图形库支持以下编译环境：

### Microsoft Visual Studio

- Visual Studio 6.0
- Visual Studio 2008
- Visual Studio 2010
- Visual Studio 2012
- Visual Studio 2013
- Visual Studio 2015
- Visual Studio 2017
- Visual Studio 2019
- Visual Studio 2022
- **Visual Studio 2026** (最新支持)

### MinGW 工具链

- MinGW
- MinGW-w64 (32/64位)
- TDM-GCC

### 其他支持的 IDE

- 小熊猫 C++ (Dev-C++ 的现代版本)
- CLion
- C-Free
- Dev-C++
- Code::Blocks
- CodeLite
- wxDev-C++
- Eclipse for C/C++

以及其他使用 MinGW 为编译环境的 IDE。

## 从源代码编译

如果你需要从源代码编译 EGE，请参考源代码仓库的编译指南：

<https://github.com/x-ege/xege/blob/master/BUILD.md>

源代码仓库使用 CMake 构建系统，支持：

- Windows 平台的各种编译器
- Linux/MacOS 环境下使用 MinGW-w64 交叉编译

### 快速编译（Windows）

Windows 用户可以使用源代码仓库根目录下的 `build_commands.bat` 批处理脚本快速编译。该脚本会自动检测系统中已安装的编译环境并进行编译。

支持的快速编译环境：
- MinGW
- Visual Studio 2008 ~ 2026

详细信息请查看源代码仓库的 BUILD.md 文档。

## 库文件说明

### 库文件命名

- MSVC 编译器：`graphics.lib` (32位) 或 `graphics64.lib` (64位)
- MinGW 编译器：`libgraphics.a` (32位) 或 `libgraphics64.a` (64位)

### 链接要求

使用 GCC/MinGW 编译器时，除了链接 EGE 库，还需要链接以下系统库：

```
-lgraphics -lgdi32 -lgdiplus
```

对于 MSVC 编译器，通常只需要链接 `graphics.lib` 即可。

## 获取帮助

- 官网：<https://xege.org>
- 教程：<https://xege.org/beginner-lesson-1.html>
- 社区：<https://club.xege.org>
- 源代码：<https://github.com/x-ege/xege>
- 问题反馈：<https://github.com/x-ege/xege/issues>

## 参考资料

更多详细的编译说明和高级配置，请参考源代码仓库的完整文档：

- [完整编译指南](https://github.com/x-ege/xege/blob/master/BUILD.md)
- [API 文档](https://github.com/x-ege/xege/blob/master/man/api.md)
- [版本变更记录](CHANGELOG.md)
