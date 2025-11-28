### EGE 下载

#### 站内下载地址（在下方链接上右键点击选择"另存为"）

- [ege25.11（推荐，支持 VS2010-VS2026+ 以及 DevCpp、CodeBlocks 等，支持基于 MinGW-W64 的 macOS 以及 Debian/Ubuntu）](https://xege.org/download/ege25.11.7z)
- [~~ege24.04~~（旧版本，如遇问题可回退）](https://xege.org/download/ege24.04_all.7z)
- ~~[VC6.0 免安装包，内置 ege24.04，可直接使用](http://xege.org/download/vc6_ege24.04.7z)~~

#### 百度网盘下载

<https://pan.baidu.com/s/1qWxAgeK>

#### 其他下载

- **[小熊猫 C++，内置 EGE 最新版可直接使用（初学者推荐使用）](https://royqh.net/redpandacpp/)**
- [小龙 Dev-C++，内置 EGE 最新版，安装后即可直接使用（头文件名改为 egegraphics.h）](https://gitee.com/devcpp/devcpp/)

#### 历史版本下载

[EGE 历史版本下载](https://xege.org/download/)

---

### 安装教程

#### 网友教程

- **[依稀的 EGE 安装与配置教程](https://blog.csdn.net/qq_39151563/article/details/100161986)（强烈推荐，更新中）**
- **[小熊猫 C++ 中 EGE 使用教程（使用上面推荐的小熊猫 C++ 整合版用户看这个）](https://royqh.net/redpandacpp/docsy/docs/libraries/ege/)**
- [小龙 Dev-C++ 中 EGE 使用说明（使用上面推荐的小龙 Dev-C++）](https://gitee.com/devcpp/devcpp/blob/master/manual/support-ege.html)
- [徐司机的教程（2019 年以前版本的 Code::Blocks 用户看这个）](https://blog.csdn.net/qq_18994119/article/details/80890068)

#### 官方教程

- [EGE 的介绍、安装和使用](https://xege.org/beginner-lesson-1.html)
- [使用 EGE 提供的 Visual Studio Code 插件进行跨平台配置（支持 Windows、Mac、Linux）](https://xege.org/ege-vscode.html)

---

#### 支持的开发环境

EGE 支持以下 开发工具/编译器：

| 编译器/IDE | 版本支持 | 备注 |
|------------|----------|------|
| [Visual Studio](https://visualstudio.microsoft.com/) | 2017 ~ 2026 | ✅ **推荐**，支持 C++17 全部特性 </br> 强烈建议使用最新版本 (2026) |
| [CLion](https://www.jetbrains.com/clion/) | 支持 | ✅ **推荐** 可配合 [XEGE 插件](#ide-插件) 迅速上手 |
| [VS Code](https://code.visualstudio.com/) | 支持 | ✅ **推荐** 可配合 [EGE 插件](#ide-插件) 迅速上手 |
| [小熊猫 C++](http://royqh.net/redpandacpp/) | 支持 | ✅ **推荐** 已内置 EGE, 下载即可用 |
| [Code::Blocks](https://www.codeblocks.org/) | 支持 | 已测试版本: 25.03 (最新) |
| MinGW / MinGW-w64 | 支持 | ✅ 支持, SDK 发布时会基于最新版本进行测试 |
| 老版本 Visual Studio | 2010 ~ 2015 | ⚠️ 支持，但不推荐（不支持 C++17） |
| [Visual C++ 6.0](http://xege.org/download/vc6_ege24.04.7z) | aka vc6.0 | ⚠️ 停留支持 24.04 版本 |
| [Dev-C++](https://sourceforge.net/projects/orwelldevcpp/) | 支持 | ⚠️ 十年未更新, 不那么推荐 </br> 已测试版本: 5.11 (最新) |
| Eclipse for C/C++、 C-Free 等 | 支持 | ⚠️ 需自行配置 |

#### IDE 插件

EGE 提供官方 IDE 插件，让项目配置更加简单：

| IDE | 插件 | 安装方式 | 功能 |
|-----|------|---------|------|
| **[CLion](https://www.jetbrains.com/clion/)** | [XEGE Creator](https://plugins.jetbrains.com/plugin/28785-xege-creator) | `Settings → Plugins → Marketplace` </br> 搜索 "XEGE Creator" | 一键创建项目 </br> CMake 自动配置 </br>多平台支持 |
| **[VS Code](https://code.visualstudio.com/)** | [EGE VSCode 插件](https://marketplace.visualstudio.com/items?itemName=wysaid.ege) | 扩展面板搜索 "ege" | 一键创建项目</br>单文件编译运行</br>跨平台支持 |

##### CLion 插件使用

1. 安装插件后，点击 `File → New → Project...`
2. 在左侧项目类型列表中选择 **EGE**
3. 配置项目名称和位置，选择是否使用源码模式
4. 点击 `Create` 即可生成可运行的 EGE 项目

##### VS Code 插件使用

1. 安装插件后，打开命令面板（`Ctrl+Shift+P`）
2. 输入 `EGE:` 查看可用命令：
   - `EGE: 在当前工作区设置 ege 项目` - 使用预编译库创建项目
   - `EGE: 在当前工作区设置带有 EGE 源代码的 ege 项目` - 使用源码创建项目
   - `EGE: 构建并运行当前文件` - 快速编译运行单个 cpp 文件
3. 插件支持 Windows、macOS（需 mingw-w64 + wine）和 Linux

> 更多详情请访问插件主页：[CLion 插件](https://github.com/x-ege/ege-clion-plugin) | [VS Code 插件](https://github.com/x-ege/ege-vscode-plugin)

---

### IDE 下载

#### Visual Studio 下载

<https://visualstudio.microsoft.com/zh-hans/downloads/>

#### DevCpp

- [小熊猫 C++](https://sourceforge.net/projects/redpanda-cpp/)
- DevCpp 5.11 - 官方下载：<https://sourceforge.net/projects/orwelldevcpp/>
- DevCpp 5.11 - xege.org 镜像下载：<http://xege.org/download/Dev-Cpp_5.11_TDM-GCC_4.9.2_Setup.exe>

---

### 25.11 新版发布

#### 新增功能

- 增加相机捕获功能，基于 [ccap](https://github.com/wysaid/CameraCapture) 提供相机驱动，新增 `ege::Camera` 类，支持在 C++17 及以上的编译器中使用
- 增加鼠标双击检测支持，新增 `mouse_msg::is_doubleclick()` 方法
- 增加鼠标扩展键的检测（如 XBUTTON1、XBUTTON2）
- 增加 `ege::measuretext()` 函数用于测量 `ege_` 前缀函数绘制的文本宽高
- 增加 `ege::image_convertcolor()` 函数用于转换图像像素的颜色类型
- 增加快速检测按键动作的函数 `keypress()`、`keyrelease()`、`keyrepeat()`
- 增加 `ege/types.h` 头文件，提供基础类型定义
- 增加 `kbhit_console()` 函数，与 `getch_console()` 配套使用
- 新增 `ege_compress_bound()` 函数用于获取压缩数据的最大长度
- 新增 `color_type` 枚举，用于指定图像像素的颜色类型

#### 改进

- 使用 `stb_image` 替代 `libpng` 解析图像文件，支持更多图像格式（PNG、JPEG、BMP、GIF、TGA、PSD、HDR、PIC、PNM）
- 使用轻量的 `sdefl`/`sinfl` 库替代 `zlib` 实现数据压缩/解压，移除 `libpng` 和 `zlib` 依赖
- 图像像素默认颜色格式由 `ARGB32` 改为 `PRGB32`（预乘 Alpha），提升渲染效率
- `color_t` 类型调整为 `uint32_t`，提高代码一致性
- C++ 标准不低于 C++11 时，颜色枚举 `COLORS` 底层类型设置为 `uint32_t`
- `ege_` 系列文本输出函数的坐标参数类型由 `int` 改为 `float`，支持更精细的定位
- 图像读取和保存返回更详细的错误信息，增加 `grInvalidFileFormat` 和 `grUnsupportedFormat` 错误码
- 增加对 Visual Studio 2026 的支持
- 优化项目配置，在编译器支持 C++17 时自动开启 C++17，并定义宏 `EGE_ENABLE_CPP17=1`
- 优化静态库编译参数，同时支持 `/MD` 和 `/MT` 编译
- `ege.h` 提供双语版本（英文版为默认版本，中文版 `ege.zh_CN.h` 主要用于生成文档）

#### 修复

- 修复垂直方向对齐对 `ege_` 文本绘制函数无效的问题
- 修复调用 `resizewindow()` 后图形出现偏移和被裁剪的问题
- 修复 `resizewindow()` 后视口未进行调整的问题
- 修复 `ege_fillroundrect()` 单圆角半径参数重载无法在指定图像中绘制的问题
- 修复使用 `lineto()` 前未调整当前点的问题
- 修复 `bar3d()` 图形在线条连接点处有突出，以及在图形堆叠时存在重复边的问题
- 修复自动渲染模式下长时间无绘制操作时不触发刷新的问题
- 修复 `IMAGE::gentexture()` 会引发栈溢出的问题
- 修复调用 `delay_ms()` 时出现帧率误差较大的问题
- 修复 `getpixel_f()` 和 `putpixels_f()` 声明和定义不一致的问题
- 修复 `MUSIC` 需要依赖 `initgraph()` 初始化的问题
- 修复部分函数使用 `ege_transform_matrix` 参数做变换时崩溃的问题
- 修复 `ege/button.h` 中调用 `setfillstyle()` 时参数位置错误的问题
- 纠正 `PIMAGE` 和 `PCIMAGE` 的错误混用

#### 调整

- `alpha_type` 枚举值顺序调整：`ALPHATYPE_PREMULTIPLIED` 现为 0，`ALPHATYPE_STRAIGHT` 为 1
- `putimage_alphablend` 系列函数的参数由 `alpha_type` 改为 `color_type`，默认值为 `COLORTYPE_PRGB32`
- 数据压缩相关函数签名调整，参数类型由 `unsigned long` 改为 `uint32_t`
- `keystate()` 返回值改为 `bool` 类型，参数无效时返回 `false`
- `kbmsg()`、`kbhit()` 在运行环境退出后的返回值由 `-1` 改为 `0`，防止阻塞
- 非阻塞或非延时函数不再触发窗口刷新
- `flushmouse()`、`flushkey()` 不再触发窗口刷新
- 调整初始化环境之前所返回的颜色值，允许预先设置窗口背景色
- `graphics_errors` 数值改为十进制格式，便于调试

#### 新增示例

- 新增五子棋游戏 Demo（支持简单 AI 对战、落棋音效、抗锯齿棋子）
- 新增排序可视化 Demo
- 新增蒙特卡洛法绘制二元函数图像 Demo
- 新增相机波浪效果 Demo

---

### 24.04 新版发布

#### 配置变更

- 库文件名统一为 `graphics.lib` 或 `libgraphics.a`
- 在 GCC 中使用 EGE 库时，需要链接 `libgraphics.a`、`libgdi32.a`、`libgdiplus.a` 库，参数为 `-lgraphics -lgdi32 -lgdiplus`

#### 新特性

- 新增 `EGE_VERSION`、`EGE_VERSION_NUMBER` 等版本相关的宏
- 提供 Linux/macOS 下的编译支持（使用 MinGW-W64 工具链）
- 新增 `putimage_rotatetransparent()`，支持指定透明色旋转绘制图像
- 新增 `putpixel_savealpha()`（写入像素时保留原来的 alpha 值）
- 新增 `putpixel_alphablend()`（使用 alpha 混合公式写入像素）
- 新增 `ege_drawimage()`，用于绘制带透明通道图像（支持坐标变换、拉伸）
- 新增控制台系列相关函数（不支持 VC++ 6.0）
- 新增圆角矩形系列函数、填充圆系列函数、饼形系列函数、闭合曲线系列函数、填充矩形 `fillrect()`
- 新增无边框填充的普通图形函数
- 新增与 `drawpoly()` 相似但更明确的 `polyline()`（折线）、`polygon()`（多边形）
- 新增路径图形
- 支持保存带透明通道的 BMP 图片，新增保存 BMP 格式图片的 `savebmp()` 函数
- 新增 `key_A` 和 `key_Z` 中间的键码定义
- 新增更多预定义颜色
- 新增按键标志位 `key_flag_first_down`，指示按键按下时发送的第一次 down 消息
- 新增 `showwindow()`、`hidewindow()` 函数，用于控制窗口显示/隐藏
- 新增 `INIT_HIDE` 初始化模式，使窗口创建后不可见（调用 `showwindow()` 显示窗口）
- 支持在 EGE 中使用 UTF-8 字符串
- 新增用于刷新窗口的 `flushwindow()` 函数，确保显示绘图内容
- 提供对 VS2022 的支持
- `putimage_withalpha()` 支持缩放
- `ege_` 系列绘图函数支持设置线型（由 `setlinestyle()` 设置）
- `MUSIC` 类增加 `RepeatPlay()`，支持循环播放
- 新增 alpha 颜色混合计算函数：`alphablend()`（标准公式）、`colorblend()`（保留目标颜色的 alpha 值）、`alphablend_premultiplied()`（预乘 alpha 格式）
- 支持设置线帽和线条连接样式
- `randomize()` 支持传入随机数种子，并且会返回所使用的随机数种子
- 新增 `ege_` 系列使用 ARGB 颜色的单行文本输出函数：`ege_xyprintf()`、`ege_outtextxy()`
- 支持对使用预乘 alpha 像素格式的图像进行混合
- 支持设置和获取 EGE 所使用的代码页
- `ege_` 系列高级绘图函数支持坐标变换
- 支持独立设置和获取线条颜色和文本颜色

#### 修复 BUG

- 修复 `inputbox_getline()` 界面发黑的问题（20.08 引入）
- 修复 `sector()` 函数在半径小于等于 20 时出现绘制错误的问题
- 修复 `drawpoly()` 绘制闭合多边形时首尾连接点无拐角的问题
- 修复 `setinitmode()` 无法改变窗口位置的问题（20.08 引入）
- 修复初始化后 `initgraph(-1, -1)` 无法将窗口大小设置为全屏的问题
- 修复 `sys_edit` 的 `isfocus()` 函数不可用的问题
- 修复 `sys_edit` 在调用 `setfocus()` 后不显示光标的问题
- 修复初始化后鼠标初始位置不正确的问题
- 修复 `rgb2gray()` 未做近似处理的问题
- 修复用户手动关闭窗口不能马上退出的问题
- 修复 `delay_ms(0)` 延时过长的问题，改为与 `Sleep(0)` 一致的行为（放弃剩余 CPU 时间片，其它线程执行后立即返回）
- 修复角度不为 0 的文本在设置垂直居中时发生偏移的问题
- 修复 RGB 格式图片文件读取后图像 alpha 通道为 0 的问题
- 修复 `ege_drawtext()` 无法旋转的问题
- 修复填充模式 `EMPTY_FILL` 不正确的问题
- 修复矩形区域输出文本无法按照对齐方式正确显示的问题
- 修复 `ege_drawtext()` 无法按照指定字体宽度输出文本的问题
- 修复 `outtext()` 不更新当前点的问题
- 纠正 `HOME` 键和 `END` 键的键码
- 修复设置视口后当前点没有移动至视口左上角的问题
- 修复 `putimage` 系列函数在源矩形区域左上角不为 (0,0) 且宽高使用默认值 0 时会发生越界的问题
- 修复设置视口后 GDI+ 绘图坐标系未移动至视口左上角的问题
- `VECTOR3D` 的 `GetAngel()` 函数纠正为 `GetAngle()`
- 修复 `random()` 无默认参数的问题
- 修复 `keystate` 在打开文件对话窗口后失效的问题

#### 功能调整

- `getimage()` 返回值类型统一为 `int`，表示是否成功读取图像
- `saveimage()` 根据文件名后缀确定保存为 PNG 格式还是 BMP 格式（优先保存为 PNG 格式）
- `resize()` 恢复为自动填充背景色（20.08 行为改为不填充，现恢复），另新增不填充背景色的 `resize_f()`
- `EGERGB()`、`EGEARGB()` 等宏的返回值类型修改为 `color_t`
- 定时精度提升至 1ms
- 为部分类型增加 `EGE_XXX_TYPEDEF` 宏，控制类型定义
- 消除扩展中的头文件包含顺序依赖
- 取消 `setfillstyle()`/`getfillstyle()` 的弃用标记
- 图像旋转正方向修改为与坐标系一致的顺时针方向
- 调整文本垂直对齐方式的值
- 为 GCC 4.5 以上版本增加弃用信息
- 线条连接点默认样式统一修改为尖角
- `color_t` 恢复为与 `uint32_t` 一致的 `unsigned int` 类型（20.08 改为 `DWORD`）

#### 其它

- 绘图性能优化（GDI+ 实现的图形绘制以及 GDI 的直线绘制）
- 减少初次显示屏幕时的闪烁
- 图片读取速度优化

---

### 20.08 新版发布

#### 新特性

- 库文件名统一为 `graphics[64].lib` 或 `libgraphics[64].a`
- 初始化图形对象或调用 `resize()` 时，支持将图形对象的长或宽设置为 0
- 增加 `INIT_UNICODE` 初始化选项，此选项会创建 Unicode 窗口
- 增加 `ege::seticon()` 函数，可通过资源 ID 设置窗口图标
- 增加 `ege::ege_drawtext()`，支持绘制文字时使用 Alpha 通道混合，呈现半透明效果
- 增加 `putpixel_withalpha()` 和 `putpixel_withalpha_f()` 函数，支持带透明通道绘制像素点
- 允许在 `initgraph()` 前调用 `newimage()` 创建图形对象
- 支持加载资源中 PNG 格式图片
- 使 `getkey()` 可返回 `key_msg_char` 类型的消息，现在 EGE 支持读取输入法输入了
- 允许在调用 `initgraph()` 前设置窗口标题和图标

#### 修复 BUG

- 修正 `putimage` 系列函数裁剪区计算错误的 BUG
- 修复了 `initgraph()` 的内存泄漏情况
- 修复了 `setactivepage()` 和 `setvisualpage()` 无法使用的问题
- 修正 `putpixel()` 等函数颜色格式错误
- 修正关于线型设置的 BUG
- 修正某些函数传入 `NULL` 时段错误的 BUG

#### 其它

- 使用 CMake 作为编译系统
- 从 `ege.h` 中移出 `EgeControlBase` 的定义到 `ege/egecontrolbase.h` 中
- 默认字体设置为宋体
- 使用 `PCIMAGE` 作为 `const IMAGE*` 的别名，并作为某些函数的形参类型
- 生成的静态库文件中不再包含 gdiplus 静态库
- 改用误差更小的 Alpha 通道混合算法
- 增加之前缺少的键码
- `resize()` 不再用默认背景色清空图像
- 修改了 `initgraph()` 的接口定义
