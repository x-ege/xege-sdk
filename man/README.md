# EGE（Easy Graphics Engine）

> **原作者**：misakamm

| 相关网站 | 网址 |
| --- | --- |
| 官网 | <https://xege.org> |
| 源码 (GitHub) | <https://github.com/x-ege/xege> |
| SDK 仓库 | <https://github.com/x-ege/xege-sdk> |
| 安装器 | <https://github.com/x-ege/ege-installer> |
| 教程与介绍 | [EGE 教程 & 介绍](https://blog.csdn.net/qq_39151563/article/details/100154767)（by [依稀](https://blog.csdn.net/qq_39151563?type=blog)） |
| 在线文档 | <https://xege.org/manual> |

## 预编译库下载

| 站点名称 | 下载链接 |
| --- | --- |
| GitHub Releases | <https://github.com/x-ege/xege-sdk/releases> |
| EGE Installer | <https://github.com/x-ege/ege-installer/releases> |
| 百度网盘 | <https://pan.baidu.com/s/1qWxAgeK> |

## 支持的开发环境

| 编译器/IDE | 版本支持 | 备注 |
|---|---|---|
| Visual Studio | 2017 ~ 2026 | **推荐**，VS2017+ 使用统一 MSVC 静态库 |
| CLion | 支持 | **推荐**，可配合 [XEGE Creator 插件](https://plugins.jetbrains.com/plugin/28785-xege-creator)使用 |
| VS Code | 支持 | **推荐**，可配合 [EGE 插件](https://marketplace.visualstudio.com/items?itemName=wysaid.ege)使用 |
| 小熊猫 C++ | 支持 | **推荐**，已内置 EGE，下载即可用 |
| Code::Blocks | 支持 | 已测试 25.03 |
| MinGW / MinGW-w64 | 支持 | 支持 32/64 位 |
| Dev-C++ | 支持 | 已测试 5.11 |

在 Linux 和 macOS 上，EGE 支持基于 MinGW-W64 的交叉编译环境（需 Wine 运行）。

## IDE 插件

| IDE | 插件 | 安装方式 |
|-----|------|----------|
| **CLion** | [XEGE Creator](https://plugins.jetbrains.com/plugin/28785-xege-creator) | Settings → Plugins → Marketplace 搜索 "XEGE Creator" |
| **VS Code** | [EGE](https://marketplace.visualstudio.com/items?itemName=wysaid.ege) | 扩展面板搜索 "ege" |

## 自己编译 EGE 源代码

### 获取源码

```bash
git clone https://github.com/x-ege/xege --recursive
```

### 编译源码

EGE 项目是一个 CMake 项目，使用标准的 CMake 构建方式即可编译。

对于新手来说，可以参考如下步骤：

1. 下载安装 [CMake](https://cmake.org)
2. 推荐安装 Visual Studio 2022 或以上版本以获得最好的体验
3. 启动 `cmake-gui.exe`，选择源码目录和编译目录，点击 `Configure` → `Generate` → `Open Project`，然后在 Visual Studio 中编译即可

## 库教程和文档目录（本文档对应 EGE 版本: 25.11）

* [基本说明](https://xege.org/manual/intro/index.htm)
* [图形库安装说明](https://xege.org/manual/setup/index.htm)
* [使用预览](https://xege.org/manual/preview/index.htm)
* [入门基础示例和教程](https://xege.org/manual/tutorial/index.htm)
* [库函数目录](https://xege.org/manual/api/index.htm)
* [示例程序](https://xege.org/manual/demo/index.htm)
* [网友小程序](https://xege.org/manual/netfriendsdemo/index.htm)
* [关于本图形库](https://xege.org/manual/about/index.htm)
