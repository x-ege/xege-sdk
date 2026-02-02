# MSVC 静态库整合说明

## 概述

从 EGE 25.11 版本开始，我们对 MSVC 静态库的发布策略进行了优化，将 VS2017、VS2019、VS2022、VS2026 统一使用同一套 MSVC 编译的静态库。此改进减少了发布包体积约 52MB（从 86MB 降至 34MB），同时保持了对所有现代 Visual Studio 版本的完全兼容。

## 技术背景

### MSVC ABI 兼容性

从 Visual Studio 2015 开始，微软引入了 Universal CRT (UCRT)，并在后续版本中保持了 ABI（Application Binary Interface）的向后兼容性：

- **VS2015 (v140)**: 引入 Universal CRT
- **VS2017 (v141)**: 保持 ABI 兼容
- **VS2019 (v142)**: 保持 ABI 兼容
- **VS2022 (v143)**: 保持 ABI 兼容
- **VS2026 (v145)**: 保持 ABI 兼容

这意味着使用任一版本编译的静态库可以在其他版本中链接使用，只要运行时库配置一致（/MD 或 /MT）。

### Debug/Release 库分离

虽然 ABI 兼容，但 MSVC 的 Debug 和 Release 配置在 STL 实现上存在差异：

- `_ITERATOR_DEBUG_LEVEL` 宏在 Debug 和 Release 中值不同
- 容器的内存布局在 Debug 和 Release 中不同
- Debug 库包含额外的运行时检查

因此，我们继续提供独立的 Debug 和 Release 版本：
- `graphics.lib` - Release 版本
- `graphicsd.lib` - Debug 版本

头文件会根据 `_DEBUG` 宏自动选择正确的库。

## 实施方案

### 统一的 MSVC 库目录

我们使用统一的 `lib/msvc` 目录存放 MSVC 编译的静态库，不再区分具体的 Visual Studio 版本。这样做的原因是：

1. **广泛兼容性**: 由于 VS2015+ 的 ABI 兼容性，同一套静态库可以在所有现代 MSVC 版本中使用
2. **更清晰的命名**: `msvc` 比 `vs2019` 更能表达"适用于所有 MSVC 版本"的含义
3. **简化维护**: 避免因具体版本号带来的混淆

### 库文件结构

```
lib/
├── msvc/
│   ├── x64/
│   │   ├── graphics.lib   (Release, x64)
│   │   └── graphicsd.lib  (Debug, x64)
│   └── x86/
│       ├── graphics.lib   (Release, x86)
│       └── graphicsd.lib  (Debug, x86)
├── vs2015/               (保留用于 VS2015 支持)
└── vs2010/               (保留用于 VS2010 支持)
```

## 使用说明

### 对用户的影响

**完全透明，无需任何更改！**

- 使用 VS2017、VS2019、VS2022 或 VS2026 的用户无需修改项目配置
- CMakeLists.txt 会自动选择正确的库目录
- 头文件会自动根据编译模式（Debug/Release）选择正确的库

### CMake 配置

CMakeLists.txt 中的库选择逻辑：

```cmake
if(MSVC_VERSION GREATER_EQUAL 1910)
    # vs2017 及以上版本统一使用 msvc 静态库
    # msvc 静态库与 vs2017, vs2019, vs2022, vs2026 兼容
    if(CMAKE_CL_64)
        set(osLibDir "msvc/x64")
    else()
        set(osLibDir "msvc/x86")
    endif()
endif()
```

### 手动配置

如果不使用 CMake，需要在项目中：

1. 添加库搜索路径：`lib/msvc/x64` 或 `lib/msvc/x86`
2. 包含头文件目录：`include`
3. 链接库会自动根据 `_DEBUG` 宏选择（在 `ege.h` 中通过 `#pragma comment` 实现）

## 兼容性验证

我们通过以下方式验证了兼容性：

1. **ABI 兼容性**: 所有 VS2015+ 版本共享相同的 UCRT 和 ABI
2. **编译测试**: 在不同 VS 版本中成功编译链接
3. **运行时测试**: 验证所有 demo 程序正常运行

## 优势

1. **显著减少包体积**: 从 86MB 降至 34MB，减少约 60%
2. **简化维护**: 只需维护一个 MSVC 版本的库文件
3. **简化构建**: 减少构建和测试的复杂度
4. **完全兼容**: 对用户完全透明，无需任何代码更改

## 注意事项

### VS2015 及更早版本

VS2015 及更早版本仍然使用独立的库文件：
- VS2015: `lib/vs2015/`
- VS2010: `lib/vs2010/`

### 跨版本链接

虽然 ABI 兼容，但仍建议：
- 整个项目使用相同版本的 MSVC 编译
- 不要在同一项目中混用不同运行时库（/MD 和 /MT）

### 第三方库

如果项目依赖其他第三方静态库，确保这些库也遵循相同的 ABI 兼容性原则。

## 技术参考

- [Microsoft C++ binary compatibility 2015-2022](https://docs.microsoft.com/en-us/cpp/porting/binary-compat-2015-2017)
- [Universal CRT deployment](https://docs.microsoft.com/en-us/cpp/windows/universal-crt-deployment)
- [MSVC ABI versioning](https://docs.microsoft.com/en-us/cpp/porting/overview-of-potential-upgrade-issues-visual-cpp)

## 更新日志

- **25.11**: 首次实施 MSVC 库整合策略，减少发布包体积约 52MB
