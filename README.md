# EGE 安装包

- 安装教程 <https://xege.org/beginner-lesson-1.html>
- IDE下载 <https://xege.org/install_and_config>
- 源代码 <https://github.com/wysaid/xege>

# 版本更新说明

## EGE 25.11 版本改动

### 新增功能

- 增加相机捕获功能，基于 [ccap](https://github.com/wysaid/CameraCapture) 提供相机驱动，新增 `ege::Camera` 类，支持在 C++17 及以上的编译器中使用。
- 增加鼠标双击检测支持，新增 `mouse_msg::is_doubleclick()` 方法。
- 增加鼠标扩展键的检测（如 XBUTTON1, XBUTTON2）。
- 增加 `ege::measuretext` 函数用于测量 `ege_` 前缀函数绘制的文本宽高。
- 增加 `ege::image_convertcolor` 函数用于转换图像像素的颜色类型。
- 增加快速检测按键动作的函数 `keypress`、`keyrelease`、`keyrepeat`。
- 增加 `ege/types.h` 头文件，提供基础类型定义。
- 增加 `kbhit_console` 函数，与 `getch_console` 配套使用。
- 新增 `ege_compress_bound` 函数用于获取压缩数据的最大长度。
- 新增 `color_type` 枚举，用于指定图像像素的颜色类型（`COLORTYPE_PRGB32`, `COLORTYPE_ARGB32`, `COLORTYPE_RGB32`）。

### 改进

- 使用 `stb_image` 替代 `libpng` 解析图像文件，支持更多图像格式（PNG, JPEG, BMP, GIF, TGA, PSD, HDR, PIC, PNM）。
- 使用轻量的 `sdefl`/`sinfl` 库替代 `zlib` 实现数据压缩/解压，移除 `libpng` 和 `zlib` 依赖。
- 图像像素默认颜色格式由 `ARGB32` 改为 `PRGB32`（预乘Alpha），提升渲染效率。
- `color_t` 类型调整为 `uint32_t`，提高代码一致性。
- C++ 标准不低于 C++11 时，颜色枚举 `COLORS` 底层类型设置为 `uint32_t`，与 `color_t` 一致。
- `ege_` 系列文本输出函数的坐标参数类型由 `int` 改为 `float`，支持更精细的定位。
- 图像读取和保存返回更详细的错误信息，增加 `grInvalidFileFormat` 和 `grUnsupportedFormat` 错误码。
- 增加对 Visual Studio 2026 的支持。
- 优化项目配置，在编译器支持 C++17 时自动开启 C++17，并定义宏 `EGE_ENABLE_CPP17=1`。
- 优化静态库编译参数，同时支持 `/MD` 和 `/MT` 编译。
- MSVC 版本新增 Debug 版本静态库 `graphicsd.lib`，解决 Debug/Release 模式下 STL 不兼容的问题。头文件会根据 `_DEBUG` 宏自动选择正确的库。
- `ege.h` 提供双语版本（英文版为默认版本，中文版 `ege.zh_CN.h` 主要用于生成文档）。
- 示例代码中的 `sprintf` 改为更安全的 `snprintf`。

### 修复

- 修复垂直方向对齐对 `ege_` 文本绘制函数无效的问题。
- 修复调用 `resizewindow` 后图形出现偏移和被裁剪的问题。
- 修复 `resizewindow` 后视口未进行调整的问题。
- 修复 `ege_fillroundrect()` 单圆角半径参数重载无法在指定图像中绘制的问题。
- 修复使用 `lineto` 前未调整当前点的问题。
- 修复 `bar3d` 图形在线条连接点处有突出，以及在图形堆叠时存在重复边的问题。
- 修复自动渲染模式下长时间无绘制操作时不触发刷新的问题。
- 修复 `IMAGE::gentexture` 会引发栈溢出的问题。
- 修复调用 `delay_ms` 时出现帧率误差较大的问题。
- 修复 `getpixel_f` 和 `putpixels_f` 声明和定义不一致的问题。
- 修复 `MUSIC` 需要依赖 `initgraph()` 初始化的问题。
- 修复部分函数使用 `ege_transform_matrix` 参数做变换时崩溃的问题。
- 修复 `ege/button.h` 中调用 `setfillstyle` 时参数位置错误的问题。
- 纠正 `PIMAGE` 和 `PCIMAGE` 的错误混用。

### 调整

- `alpha_type` 枚举值顺序调整：`ALPHATYPE_PREMULTIPLIED` 现为 0，`ALPHATYPE_STRAIGHT` 为 1。
- `putimage_alphablend` 系列函数的参数由 `alpha_type alphaType` 改为 `color_type colorType`，默认值为 `COLORTYPE_PRGB32`。
- 数据压缩相关函数签名调整，参数类型由 `unsigned long` 改为 `uint32_t`。
- `keystate` 返回值改为 `bool` 类型，参数无效时返回 `false`。
- `kbmsg`、`kbhit` 在运行环境退出后的返回值由 `-1` 改为 `0`，防止阻塞。
- 非阻塞或非延时函数不再触发窗口刷新。
- `flushmouse`、`flushkey` 不再触发窗口刷新。
- 调整初始化环境之前所返回的颜色值，允许预先设置窗口背景色。
- `graphics_errors` 数值改为十进制格式，便于调试。

### 新增示例

- 新增五子棋游戏 Demo（支持简单 AI 对战、落棋音效、抗锯齿棋子）。
- 新增排序可视化 Demo。
- 新增蒙特卡洛法绘制二元函数图像 Demo。
- 新增相机波浪效果 Demo。

### 构建与文档

- 移除 `libpng` 和 `zlib` 依赖，简化编译配置。
- 优化 CMake 配置，添加构建选项允许设置不构建示例程序。
- 优化 CMake 配置，为 MSVC 添加 `/Zc:__cplusplus` 编译选项，使 `__cplusplus` 宏正确反映 C++ 标准版本。
- 优化 GitHub Actions 工作流，增加 MinGW Windows 构建。
- 增加编译测试模块，用于发现编译兼容性问题。
- 添加单元测试相关模块和性能测试逻辑。
- 优化发布脚本，支持跨平台（macOS/Linux/Windows）。
- 文档更新：修正多处文档错误，更新示例代码，补充新功能说明。

## EGE 24.04 版本改动

### 配置变更

- 库文件名统一为 `graphics.lib` 或 `libgraphics.a`
- 在 GCC 中使用 ege 库时，需要链接 `libgraphics.a`, `libgdi32.a`, `libgdiplus.a` 库，参数为 `-lgraphics -lgdi32 -lgdiplus`

### 新特性

- 新增 EGE_VERSION, EGE_VERSION_NUMBER 等版本相关的宏
- 提供 Linux /MacOs 下的编译支持(使用 MinGW-W64 工具链)
- 新增 putimage_rotatetransparent()，支持指定透明色旋转绘制图像
- 新增 putpixel_savealpha(写入像素时保留原来的 alpha 值),
- 新增 putpixel_alphablend(使用 alpha 混合公式写入像素)
- 新增 ege_drawimage()，用于绘制带透明通道图像(支持坐标变换，拉伸)
- 新增控制台系列相关函数(不支持 VC++ 6.0)
- 新增圆角矩形系列函数、填充圆系列函数，饼形系列函数，闭合曲线系列函数，填充矩形(fillrect)
- 新增无边框填充的普通图形函数
- 新增与 drawpoly 相似但更明确的 polyline(折线), polygon(多边形)
- 新增路径图形
- 支持保存带透明通道的 BMP 图片， 新增保存 BMP 格式图片的 savebmp 函数
- 新增 key_A 和 key_Z 中间的键码定义
- 新增更多预定义颜色
- 新增按键标志位 key_flag_first_down，指示按键按下时发送的第一次 down 消息
- 新增 showwindow(), hidewindow() 函数，用于控制窗口显示/隐藏
- 新增 INIT_HIDE 初始化模式，使用窗口创建后不可见(调用 showwindow() 显示窗口)
- 支持在 EGE 中使用 UTF-8 字符串
- 新增用于刷新窗口的 flushwindow() 函数，确保显示绘图内容
- 提供对 VS2022 的支持
- putimage_withalpha() 支持缩放
- ege_系列绘图函数支持设置线型(由 setlinestyle 设置)
- MUSIC 类增加 RepeatPlay(), 支持循环播放
- 新增 alpha 颜色混合计算函数 alphablend(标准公式), colorblend(保留目标颜色的alpha值), alphablend_premultiplied(预乘 alpha 格式)
- 支持设置线帽和线条连接样式
- randomize 支持传入随机数种子，并且会返回所使用的随机数种子
- 新增 ege_系列使用 ARGB 颜色的单行文本输出函数(ege_xyprintf, ege_outtextxy)
- 支持对使用预乘 alpha 像素格式的图像进行混合
- 支持设置和获取 EGE 所使用的代码页
- ege_系列高级绘图函数支持坐标变换
- 支持独立设置和获取线条颜色和文本颜色

### 修复 BUG

- 修复 inputbox_getline() 界面发黑的问题(20.08 引入)
- 修复 sector() 函数在半径小于等于 20 时出现绘制错误的问题
- 修复 drawpoly() 绘制闭合多边形时首尾连接点无拐角的问题
- 修复 setinitmode() 无法改变窗口位置的问题(20.08 引入)
- 修复初始化后 initgraph(-1, -1) 无法将窗口大小设置为全屏的问题
- 修复 sys_edit 的 isfocus() 函数不可用的问题
- 修复 sys_edit 在调用 setfocus() 后不显示光标的问题
- 修复初始化后鼠标初始位置不正确的问题
- 修复 rgb2gray() 未对做近似处理的问题
- 修复用户手动关闭窗口，不能马上退出的问题
- 修复 delay_ms(0) 延时过长的问题，改为与 Sleep(0) 一致的行为(放弃剩余 CPU 时间片，其它线程执行后立即返回)
- 修复角度不为0的文本在设置垂直居中时发生偏移的问题
- 修复 RGB 格式图片文件读取后图像 alpha 通道为 0 的问题
- 修复 ege_drawtext() 无法旋转的问题
- 修复填充模式 EMPTY_FILL 不正确的问题
- 修复矩形区域输出文本无法按照对齐方式正确的问题
- 修复 ege_drawtext() 无法按照指定字体宽度输出文本的问题
- 修复 outtext() 不更新当前点的问题
- 纠正 HOME 键和 END 键的键码
- 修复设置视口后当前点没有移动至视口左上角的问题
- 修复 putimage 系列函数在源矩形区域左上角不为 (0,0) 且宽高使用默认值0时会发生越界的问题
- 修复设置视口后 GDI+ 绘图坐标系未移动至视口左上角的问题
- VECTOR3D 的 GetAngel() 函数纠正为 GetAngle()
- 修复 random() 无默认参数的问题
- 修复 keystate 在打开文件对话窗口后失效的问题

### 功能调整

- getimage() 返回值类型统一为 int, 表示是否成功读取图像
- saveimage() 根据文件名后缀确定保存为 PNG 格式还是 BMP 格式(优先保存为 PNG 格式)
- resize() 恢复为自动填充背景色(20.08 行为改为不填充，现恢复)，另新增不填充背景色的 resize_f()
- EGERGB(), EGEARGB() 等宏的返回值类型修改为 color_t
- 定时精度提升至 1ms
- 为部分类型增加 EGE_XXX_TYPEDEF 宏，控制类型定义
- 消除扩展中的头文件包含顺序依赖
- 取消 setfillstyle/getfillstyle 的弃用标记
- 图像旋转正方向修改为与坐标系一致的顺时针方向
- 调整文本垂直对齐方式的值
- 为 GCC4.5 以上版本增加弃用信息
- 线条连接点默认样式统一修改为尖角
- color_t 恢复为与 uint32_t 一致的 unsigned int 类型(20.08 改为 DWORD)

### 其它

- 绘图性能优化(GDI+ 实现的图形绘制以及 GDI 的直线绘制)
- 减少初次显示屏幕时的闪烁
- 图片读取速度优化
