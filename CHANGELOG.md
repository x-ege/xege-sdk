# EGE 版本变更记录

本文档记录了 EGE (Easy Graphics Engine) 图形库的主要版本变更。

遵循[如何维护更新日志](https://keepachangelog.com/zh-CN/1.0.0/)编写。

## 未发布（开发中）

### 更新

- 增加对 Visual Studio 2026 的支持
- 增加 `ege::putimage_rotatetransparent` 方法
- 增加 `ege::ege_` 系列绘图函数对 `ege::setlinestyle` 的支持
- 增加 `ege::ege_drawimage` 和 `ege::ege_transform` 系列函数
- 增加绘制圆角矩形的函数
- 增加主控台系列函数
- 现在 `ege::saveimage` 根据后缀名决定将文件保存为 PNG 还是 BMP 格式
- 增加 `ege::setcodepage` 控制 EGE 如何解析程序中的 `char*` 字符串
- 增加 `ege::setunicodecharmessage` 控制字符消息的编码
- 增加 `image_convertcolor` 函数用于转换图像像素的颜色类型

### 修复

- 修复 `ege::inputbox_getline` 界面发黑的问题
- 修正当半径小于等于 20 时，`ege::sector` 函数绘制错误的问题
- 修正 `ege::setinitmode` 无法改变窗口位置的问题
- 使 `sys_edit` 的 `isfocus` 方法可用
- 修复 Windows 10 下创建窗口时白屏的问题
- 修复在执行 `ege::outputbox_getline` 后 `ege::outtextxy` 有概率无效的问题
- 修复垂直方向对齐对 ege_ 文本绘制函数无效的问题
- 修复 ege_ 单行文本右对齐时忽略文本末尾空白字符的问题

### 变更

- `ege::getimage` 系列函数现在通过返回值表示是否成功
- 改用支持 GPU 加速的 `AlphaBlend` 函数实现 `ege::putimage_alpha`
- 将 `ege::resize` 行为改回会填充背景色，并增加不填充背景色的 `ege::resize_f` 函数
- 按照 CSS 颜色表修改并增加了预定义颜色值定义
- `INIT_UNICODE` 初始化选项，改为设置 `setunicodecharmessage(true)`，现在 EGE 总是创建 Unicode 窗口
- 图像像素颜色格式由 ARGB32 改为 PRGB32（`putimage_alphablend` 有不兼容性改动）
- C++ 标准不低于 C++11 时，设置颜色枚举底层类型为 uint32_t，和 color_t 一致

## [24.04] - 2024-04

### 配置变更

- 库文件名统一为 `graphics.lib` 或 `libgraphics.a`
- 在 GCC 中使用 ege 库时，需要链接 `libgraphics.a`, `libgdi32.a`, `libgdiplus.a` 库，参数为 `-lgraphics -lgdi32 -lgdiplus`

### 新特性

- 新增 EGE_VERSION, EGE_VERSION_NUMBER 等版本相关的宏
- 提供 Linux/MacOS 下的编译支持(使用 MinGW-W64 工具链)
- 新增 `putimage_rotatetransparent()`，支持指定透明色旋转绘制图像
- 新增 `putpixel_savealpha`(写入像素时保留原来的 alpha 值)
- 新增 `putpixel_alphablend`(使用 alpha 混合公式写入像素)
- 新增 `ege_drawimage()`，用于绘制带透明通道图像(支持坐标变换，拉伸)
- 新增控制台系列相关函数(不支持 VC++ 6.0)
- 新增圆角矩形系列函数、填充圆系列函数，饼形系列函数，闭合曲线系列函数，填充矩形(fillrect)
- 新增无边框填充的普通图形函数
- 新增与 drawpoly 相似但更明确的 polyline(折线), polygon(多边形)
- 新增路径图形
- 支持保存带透明通道的 BMP 图片，新增保存 BMP 格式图片的 savebmp 函数
- 新增 key_A 和 key_Z 中间的键码定义
- 新增更多预定义颜色
- 新增按键标志位 key_flag_first_down，指示按键按下时发送的第一次 down 消息
- 新增 `showwindow()`, `hidewindow()` 函数，用于控制窗口显示/隐藏
- 新增 INIT_HIDE 初始化模式，使用窗口创建后不可见(调用 showwindow() 显示窗口)
- 支持在 EGE 中使用 UTF-8 字符串
- 新增用于刷新窗口的 `flushwindow()` 函数，确保显示绘图内容
- 提供对 Visual Studio 2022 的支持
- `putimage_withalpha()` 支持缩放
- ege_系列绘图函数支持设置线型(由 setlinestyle 设置)
- MUSIC 类增加 `RepeatPlay()`，支持循环播放
- 新增 alpha 颜色混合计算函数 `alphablend`(标准公式), `colorblend`(保留目标颜色的alpha值), `alphablend_premultiplied`(预乘 alpha 格式)
- 支持设置线帽和线条连接样式
- randomize 支持传入随机数种子，并且会返回所使用的随机数种子
- 新增 ege_系列使用 ARGB 颜色的单行文本输出函数(`ege_xyprintf`, `ege_outtextxy`)
- 支持对使用预乘 alpha 像素格式的图像进行混合
- 支持设置和获取 EGE 所使用的代码页
- ege_系列高级绘图函数支持坐标变换
- 支持独立设置和获取线条颜色和文本颜色

### 修复 BUG

- 修复 `inputbox_getline()` 界面发黑的问题(20.08 引入)
- 修复 `sector()` 函数在半径小于等于 20 时出现绘制错误的问题
- 修复 `drawpoly()` 绘制闭合多边形时首尾连接点无拐角的问题
- 修复 `setinitmode()` 无法改变窗口位置的问题(20.08 引入)
- 修复初始化后 `initgraph(-1, -1)` 无法将窗口大小设置为全屏的问题
- 修复 sys_edit 的 `isfocus()` 函数不可用的问题
- 修复 sys_edit 在调用 `setfocus()` 后不显示光标的问题
- 修复初始化后鼠标初始位置不正确的问题
- 修复 `rgb2gray()` 未对做近似处理的问题
- 修复用户手动关闭窗口，不能马上退出的问题
- 修复 `delay_ms(0)` 延时过长的问题，改为与 Sleep(0) 一致的行为(放弃剩余 CPU 时间片，其它线程执行后立即返回)
- 修复角度不为0的文本在设置垂直居中时发生偏移的问题
- 修复 RGB 格式图片文件读取后图像 alpha 通道为 0 的问题
- 修复 `ege_drawtext()` 无法旋转的问题
- 修复填充模式 EMPTY_FILL 不正确的问题
- 修复矩形区域输出文本无法按照对齐方式正确的问题
- 修复 `ege_drawtext()` 无法按照指定字体宽度输出文本的问题
- 修复 `outtext()` 不更新当前点的问题
- 纠正 HOME 键和 END 键的键码
- 修复设置视口后当前点没有移动至视口左上角的问题
- 修复 putimage 系列函数在源矩形区域左上角不为 (0,0) 且宽高使用默认值0时会发生越界的问题
- 修复设置视口后 GDI+ 绘图坐标系未移动至视口左上角的问题
- VECTOR3D 的 `GetAngel()` 函数纠正为 `GetAngle()`
- 修复 `random()` 无默认参数的问题
- 修复 keystate 在打开文件对话窗口后失效的问题

### 功能调整

- `getimage()` 返回值类型统一为 int, 表示是否成功读取图像
- `saveimage()` 根据文件名后缀确定保存为 PNG 格式还是 BMP 格式(优先保存为 PNG 格式)
- `resize()` 恢复为自动填充背景色(20.08 行为改为不填充，现恢复)，另新增不填充背景色的 `resize_f()`
- `EGERGB()`, `EGEARGB()` 等宏的返回值类型修改为 color_t
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

## [20.08] - 2020-08-31

### 更新

- 库文件名统一为 `graphics[64].lib` 或 `libgraphics[64].a`
- 初始化图形对象或调用 `resize` 时，支持将图形对象的长或宽设置为 0
- 增加 `INIT_UNICODE` 初始化选项，此选项会创建 Unicode 窗口
- 增加 `ege::seticon` 函数，可通过资源 ID 设置窗口图标
- 增加 `ege::ege_drawtext`，支持绘制文字时使用 Alpha 通道混合，呈现半透明效果
- 增加 `putpixel_withalpha` 和 `putpixel_withalpha_f` 函数，支持带透明通道绘制像素点
- 允许在 `initgraph` 前调用 `newimage` 创建图形对象
- 支持加载资源中 PNG 格式图片
- 使 `getkey` 可返回 `key_msg_char` 类型的消息，现在 EGE 支持读取输入法输入了
- 允许在调用 `initgraph` 前设置窗口标题和图标
- 使用 CMake 作为编译系统
- 增加之前缺少的键码
- 使用 `PCIMAGE` 作为 `const IMAGE*` 的别名，并作为某些函数的形参类型

### 修复

- 修正 `putimage` 系列函数裁剪区计算错误的 BUG
- 修复了 `initgraph` 的内存泄漏情况
- 修复了 `setactivepage()` 和 `setvisualpage()` 无法使用的问题
- 修正 `putpixel` 等函数颜色格式错误
- 修正关于线型设置的 BUG
- 修正某些函数传入 `NULL` 时段错误的 BUG

### 变更

- 从 `ege.h` 中移出 `EgeControlBase` 的定义到 `ege/egecontrolbase.h` 中
- 默认字体设置为宋体
- 生成的静态库文件中不再包含 gdiplus 静态库
- 改用误差更小的 Alpha 通道混合算法
- `resize` 不再用默认背景色清空图像（**在 24.04 中重置**）
- 修改了 `initgraph` 的接口定义

## [19.01] - 2019-01

早期版本的 EGE 库发布。

---

## 编译支持的 IDE

目前 EGE 图形库已经完美支持以下 IDE：

- Visual C++ 6.0
- Visual Studio 2008
- Visual Studio 2010
- Visual Studio 2012
- Visual Studio 2013
- Visual Studio 2015
- Visual Studio 2017
- Visual Studio 2019
- Visual Studio 2022
- Visual Studio 2026
- 小熊猫 C++ (Dev-C++ 的现代版本)
- CLion
- C-Free
- Dev-C++
- Code::Blocks
- wxDev-C++
- CodeLite
- Eclipse for C/C++

以及其他使用 MinGW 为编译环境的 IDE。

## 参考资料

- 官网：<https://xege.org>
- 源代码：<https://github.com/x-ege/xege>
- 社区：<https://club.xege.org>
- 教程：<https://xege.org/beginner-lesson-1.html>
- 示例：<https://xege.org/category/demo>
