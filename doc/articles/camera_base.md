# EGE 相机基础示例：camera_base 完全解析

## 引言

EGE（Easy Graphics Engine）库是一个专为初学者设计的轻量级 C++ 图形库，它提供了简洁易用的 API 来进行图形编程。从 25.11 版本开始，EGE 新增了相机模块（`ege::CameraCapture`），使得开发者可以轻松地在程序中访问摄像头，进行实时图像采集和处理。

本文将详细介绍 **camera_base.cpp** 示例程序，这是一个功能完整的相机演示程序，展示了 EGE 相机模块的所有基础功能。通过本文，您将学习到如何使用 EGE 相机模块进行设备管理、实时预览、交互控制等操作。

## 一、EGE 相机类接口详解

### 1.1 相机模块概述

EGE 相机模块提供了一套完整的相机访问接口，主要包括以下功能：

- **设备枚举**：查找系统中所有可用的相机设备
- **设备控制**：打开/关闭相机、启动/停止采集
- **参数设置**：设置分辨率、帧率等参数
- **帧数据获取**：实时获取相机的图像帧
- **分辨率查询**：获取相机支持的所有分辨率列表

### 1.2 核心类和接口

#### 1.2.1 CameraCapture 类

`ege::CameraCapture` 是相机模块的核心类，提供了以下主要方法：

```cpp
namespace ege {
    class CameraCapture {
    public:
        // 查找所有相机设备
        DeviceInfoList findDeviceNames();
        
        // 打开指定索引的相机设备
        bool open(int deviceIndex);
        
        // 关闭相机
        void close();
        
        // 启动相机采集
        bool start();
        
        // 判断相机是否正在运行
        bool isStarted() const;
        
        // 设置相机帧大小（分辨率）
        void setFrameSize(int width, int height);
        
        // 设置相机帧率
        void setFrameRate(int fps);
        
        // 获取一帧图像数据（返回智能指针）
        std::shared_ptr<CameraFrame> grabFrame(int timeoutMs);
        
        // 获取相机支持的分辨率列表
        ResolutionInfoList getDeviceSupportedResolutions();
    };
}
```

#### 1.2.2 CameraFrame 类

`CameraFrame` 封装了从相机获取的单帧图像数据：

```cpp
class CameraFrame {
public:
    // 获取 EGE 图像对象指针
    PIMAGE getImage();
    
    // 获取帧的宽度
    int getWidth() const;
    
    // 获取帧的高度
    int getHeight() const;
};
```

#### 1.2.3 辅助函数

```cpp
namespace ege {
    // 检查当前 EGE 版本是否支持相机模块
    bool hasCameraCaptureModule();
    
    // 启用相机模块的日志输出
    // level: 0=不输出, 1=警告, 2=信息, 3=调试
    void enableCameraModuleLog(int level);
}
```

### 1.3 使用流程

使用 EGE 相机模块的典型流程如下：

```cpp
// 1. 创建相机对象
ege::CameraCapture camera;

// 2. 查找可用设备
auto devices = camera.findDeviceNames();
if (devices.count == 0) {
    // 没有找到相机设备
    return -1;
}

// 3. 设置相机参数（可选）
camera.setFrameSize(1280, 720);
camera.setFrameRate(30);

// 4. 打开相机（使用第一个设备）
if (!camera.open(0)) {
    // 打开失败
    return -1;
}

// 5. 启动采集
camera.start();

// 6. 循环获取帧数据
while (camera.isStarted()) {
    auto frame = camera.grabFrame(3000); // 等待最多 3 秒
    if (frame) {
        PIMAGE img = frame->getImage();
        // 处理图像...
        putimage(0, 0, img);
    }
}

// 7. 关闭相机
camera.close();
```

### 1.4 编译器要求

相机模块需要 **C++11 或更高版本**的编译器支持。对于 MSVC，建议使用 **MSVC 2022 或更高版本**。

可以使用 `hasCameraCaptureModule()` 函数在运行时检查当前 EGE 版本是否支持相机功能。

## 二、camera_base 功能概述

### 2.1 主要功能

`camera_base.cpp` 是一个功能完整的相机演示程序，展示了 EGE 相机模块的所有基础功能：

- **设备管理**：自动检测所有可用相机设备，支持多设备切换
- **实时预览**：将相机画面实时显示在窗口中
- **交互控制**：通过键盘快捷键切换相机和分辨率
- **窗口自适应**：根据相机分辨率自动调整窗口大小
- **跨平台文本**：根据编译器自动选择中英文界面
- **详细信息显示**：实时显示当前设备、支持的分辨率列表等

### 2.2 交互操作

程序支持以下键盘操作：

| 按键 | 功能 |
|------|------|
| **空格键** | 切换到下一个相机设备 |
| **数字键 0-9** | 直接切换到指定编号的相机 |
| **↑ 上箭头** | 切换到上一个分辨率 |
| **↓ 下箭头** | 切换到下一个分辨率 |
| **ESC** | 退出程序 |

### 2.3 界面信息

程序在窗口左上角显示丰富的信息：

- **可用相机设备列表**：显示所有检测到的相机设备，当前设备高亮显示
- **设备切换提示**：提示如何切换相机设备
- **支持的分辨率列表**：显示当前相机支持的所有分辨率（最多显示 8 个），当前分辨率高亮显示
- **分辨率切换提示**：提示如何切换分辨率

## 三、核心代码实现

### 3.1 设备枚举与初始化

程序启动时首先枚举所有可用的相机设备：

```cpp
ege::CameraCapture camera;

// 保存设备信息
std::vector<std::string> deviceNames;
int deviceCount = 0;
int currentDeviceIndex = 0;

// 获取所有相机设备的名称
auto devices = camera.findDeviceNames();

if (devices.count == 0) {
    fputs("未找到相机设备！", stderr);
    showErrorWindow();
    return -1;
}

deviceCount = devices.count;
for (int i = 0; i < devices.count; ++i) {
    deviceNames.push_back(devices.info[i].name);
    printf("相机设备: %s\n", devices.info[i].name);
}
```

**技术要点**：
- 使用 `findDeviceNames()` 获取所有可用设备
- 将设备名称保存到 `vector` 中，方便后续显示和管理
- 如果没有找到设备，显示错误提示并退出

### 3.2 相机切换功能

`switchCamera` 函数封装了切换相机的完整逻辑：

```cpp
bool switchCamera(ege::CameraCapture& camera, int deviceIndex, 
                 int deviceCount, int resWidth = 1280, int resHeight = 720)
{
    if (deviceIndex < 0 || deviceIndex >= deviceCount) {
        return false;
    }

    // 先关闭当前相机
    if (camera.isStarted()) {
        camera.close();
    }

    // 设置相机分辨率
    camera.setFrameSize(resWidth, resHeight);
    camera.setFrameRate(30);

    // 打开新相机
    if (!camera.open(deviceIndex)) {
        return false;
    }

    camera.start();
    return true;
}
```

**技术要点**：
- 切换前先关闭当前相机，释放资源
- 设置目标分辨率和帧率（默认 1280x720, 30fps）
- 打开指定索引的相机设备
- 启动采集，返回操作是否成功

### 3.3 分辨率管理

程序支持动态切换相机分辨率，并能显示所有支持的分辨率：

```cpp
// 分辨率信息结构体
struct ResolutionItem {
    int width;
    int height;
};

// 获取并保存分辨率列表
std::vector<ResolutionItem> getResolutionList(ege::CameraCapture& camera)
{
    std::vector<ResolutionItem> resolutions;
    auto resList = camera.getDeviceSupportedResolutions();
    if (resList.count > 0) {
        for (int i = 0; i < resList.count; ++i) {
            resolutions.push_back({resList.info[i].width, resList.info[i].height});
        }
    }
    return resolutions;
}

// 根据当前帧分辨率找到对应的分辨率索引
int findCurrentResolutionIndex(const std::vector<ResolutionItem>& resolutions, 
                               int width, int height)
{
    for (size_t i = 0; i < resolutions.size(); ++i) {
        if (resolutions[i].width == width && resolutions[i].height == height) {
            return static_cast<int>(i);
        }
    }
    return 0;
}
```

**技术要点**：
- 使用 `getDeviceSupportedResolutions()` 获取所有支持的分辨率
- 将分辨率信息保存到 `vector` 中，方便遍历和选择
- 通过 `findCurrentResolutionIndex` 定位当前使用的分辨率

### 3.4 窗口自适应调整

根据相机分辨率智能调整窗口大小，同时考虑屏幕尺寸限制：

```cpp
bool adjustWindowToCamera(int cameraWidth, int cameraHeight)
{
    int windowWidth = getwidth();
    int windowHeight = getheight();

    // 计算相机的长边和比例
    int cameraLongEdge = std::max(cameraWidth, cameraHeight);
    float cameraRatio = (float)cameraWidth / cameraHeight;

    // 获取屏幕可用区域（考虑任务栏）
    RECT workArea;
    SystemParametersInfo(SPI_GETWORKAREA, 0, &workArea, 0);
    int screenAvailWidth = workArea.right - workArea.left - 20;
    int screenAvailHeight = workArea.bottom - workArea.top - 40;

    // 计算目标窗口尺寸，限制在 640-1920 之间
    int targetLongEdge = std::clamp(cameraLongEdge, 640, 1920);

    // 根据比例计算新窗口尺寸
    int newWidth, newHeight;
    if (cameraWidth >= cameraHeight) {
        newWidth = targetLongEdge;
        newHeight = (int)(newWidth / cameraRatio);
    } else {
        newHeight = targetLongEdge;
        newWidth = (int)(newHeight * cameraRatio);
    }

    // 确保不超过屏幕可用区域
    if (newWidth > screenAvailWidth) {
        float scale = (float)screenAvailWidth / newWidth;
        newWidth = screenAvailWidth;
        newHeight = (int)(newHeight * scale);
    }
    if (newHeight > screenAvailHeight) {
        float scale = (float)screenAvailHeight / newHeight;
        newHeight = screenAvailHeight;
        newWidth = (int)(newWidth * scale);
    }

    // 如果尺寸相同则无需调整
    if (newWidth == windowWidth && newHeight == windowHeight) {
        return false;
    }

    // 调整窗口大小
    initgraph(newWidth, newHeight, INIT_RENDERMANUAL);
    setcaption("EGE 相机演示");
    setbkmode(TRANSPARENT);

    return true;
}
```

**技术要点**：
- 使用 `SystemParametersInfo` 获取屏幕可用区域
- 保持相机原始宽高比，避免画面变形
- 限制窗口大小在合理范围内（640-1920 长边）
- 确保窗口不超出屏幕边界
- 使用 `INIT_RENDERMANUAL` 标志避免闪屏

### 3.5 主循环与交互控制

主循环负责获取帧数据、显示图像和处理用户输入：

```cpp
// 打开第一个相机
if (!switchCamera(camera, 0, deviceCount)) {
    fputs("打开相机设备失败！", stderr);
    return -1;
}

// 获取分辨率列表
resolutions = getResolutionList(camera);

// 主循环
for (; camera.isStarted() && is_run(); delay_fps(60)) {
    cleardevice();

    // 获取一帧数据
    auto newFrame = camera.grabFrame(3000);
    if (!newFrame) {
        fputs("获取帧数据失败！", stderr);
        break;
    }

    // 显示图像
    auto* img = newFrame->getImage();
    if (img) {
        auto w = getwidth(img);
        auto h = getheight(img);
        putimage(0, 0, getwidth(), getheight(), img, 0, 0, w, h);
        
        // 更新当前分辨率索引
        currentResolutionIndex = findCurrentResolutionIndex(resolutions, w, h);
    }

    // 处理键盘输入
    if (kbhit()) {
        auto keyMsg = getkey();
        int key = keyMsg.key;
        
        if (key == ' ') {
            // 空格键：切换到下一个相机
            int newDeviceIndex = (currentDeviceIndex + 1) % deviceCount;
            if (switchCamera(camera, newDeviceIndex, deviceCount)) {
                currentDeviceIndex = newDeviceIndex;
                resolutions = getResolutionList(camera);
            }
        } else if (key >= '0' && key <= '9') {
            // 数字键：直接切换到指定相机
            int requestedIndex = key - '0';
            if (requestedIndex < deviceCount) {
                switchCamera(camera, requestedIndex, deviceCount);
                currentDeviceIndex = requestedIndex;
            }
        } else if (key == key_up || key == key_down) {
            // 上下箭头：切换分辨率
            int direction = (key == key_up) ? -1 : 1;
            int newIndex = (currentResolutionIndex + direction + resolutions.size()) 
                          % resolutions.size();
            int newWidth = resolutions[newIndex].width;
            int newHeight = resolutions[newIndex].height;
            
            if (switchCamera(camera, currentDeviceIndex, deviceCount, 
                           newWidth, newHeight)) {
                currentResolutionIndex = newIndex;
                adjustWindowToCamera(newWidth, newHeight);
            }
        } else if (key == key_esc) {
            break;
        }
        
        flushkey();
    }

    // 显示设备列表和分辨率信息
    displayCameraInfo(deviceNames, currentDeviceIndex, resolutions, 
                     currentResolutionIndex);
}

camera.close();
```

**技术要点**：
- 使用 `delay_fps(60)` 限制帧率为 60fps
- `grabFrame(3000)` 最多等待 3 秒获取一帧
- 使用 `putimage` 将相机图像拉伸填充整个窗口
- 通过 `kbhit()` 和 `getkey()` 处理键盘输入
- 使用 `flushkey()` 清空键盘缓冲区

### 3.6 界面显示功能

程序在屏幕上显示丰富的信息，帮助用户了解当前状态：

```cpp
void displayCameraInfo(const std::vector<std::string>& deviceNames,
                      int currentDeviceIndex,
                      const std::vector<ResolutionItem>& resolutions,
                      int currentResolutionIndex)
{
    int textY = 10;
    char msgBuffer[1024];
    
    // 显示设备列表
    setcolor(YELLOW);
    outtextxy(10, textY, "可用相机设备:");
    textY += 20;
    
    for (int i = 0; i < deviceNames.size(); ++i) {
        setcolor(i == currentDeviceIndex ? LIGHTGREEN : WHITE);
        sprintf(msgBuffer, "  [%d] %s", i, deviceNames[i].c_str());
        outtextxy(10, textY, msgBuffer);
        textY += 18;
    }
    
    // 显示切换提示
    if (deviceNames.size() > 1) {
        textY += 5;
        setcolor(CYAN);
        sprintf(msgBuffer, "按空格键切换相机，或按数字键选择 | 当前: [%d] %s",
                currentDeviceIndex, deviceNames[currentDeviceIndex].c_str());
        outtextxy(10, textY, msgBuffer);
        textY += 20;
    }
    
    // 显示分辨率列表（最多显示 8 个）
    if (!resolutions.empty()) {
        textY += 10;
        setcolor(YELLOW);
        outtextxy(10, textY, "支持的分辨率:");
        textY += 20;
        
        int displayCount = std::min((int)resolutions.size(), 8);
        for (int i = 0; i < displayCount; ++i) {
            setcolor(i == currentResolutionIndex ? LIGHTGREEN : WHITE);
            sprintf(msgBuffer, "  %dx%d%s", 
                   resolutions[i].width, resolutions[i].height,
                   i == currentResolutionIndex ? " <-当前" : "");
            outtextxy(10, textY, msgBuffer);
            textY += 16;
        }
        
        textY += 5;
        setcolor(CYAN);
        outtextxy(10, textY, "按 ↑/↓ 箭头键切换分辨率");
    }
}
```

**技术要点**：
- 使用不同颜色区分不同信息（黄色标题、绿色高亮、白色普通、青色提示）
- 当前设备和分辨率用绿色高亮显示
- 分辨率列表最多显示 8 个，避免占用过多空间
- 只有多个设备时才显示设备切换提示

## 四、技术要点总结

### 4.1 资源管理

1. **智能指针**：`grabFrame` 返回 `std::shared_ptr<CameraFrame>`，自动管理内存，无需手动释放
2. **设备切换**：切换相机前先关闭当前设备，避免资源冲突
3. **错误处理**：对所有可能失败的操作进行检查，及时给出错误提示

### 4.2 性能优化

1. **帧率控制**：使用 `delay_fps(60)` 限制帧率，避免 CPU 占用过高
2. **手动渲染**：使用 `INIT_RENDERMANUAL` 标志，避免自动刷新导致的闪屏
3. **阻塞模式**：使用 `grabFrame(3000)` 阻塞等待，避免空转浪费 CPU

### 4.3 用户体验

1. **窗口自适应**：根据相机分辨率自动调整窗口大小
2. **信息丰富**：实时显示设备列表、分辨率列表、操作提示
3. **快捷操作**：支持空格、数字键、箭头键快速切换
4. **跨平台文本**：根据编译器自动选择中英文界面

## 五、常见问题解答

**Q1: 为什么我的程序检测不到相机设备？**

A: 请检查以下几点：
- 确保相机已正确连接并被系统识别
- 检查相机驱动是否正常安装
- 确认相机没有被其他程序占用
- 使用 `enableCameraModuleLog(2)` 启用日志查看详细错误信息

**Q2: 为什么程序画面会闪烁？**

A: 必须使用 `INIT_RENDERMANUAL` 标志初始化窗口。这个标志告诉 EGE 不要自动刷新窗口，避免与相机的高帧率产生冲突。

**Q3: 如何提高相机帧率？**

A: 可以采取以下措施：
- 降低相机分辨率（如使用 640x480 而非 1920x1080）
- 减少图像处理逻辑
- 使用更高性能的相机
- 检查系统 USB 带宽是否充足

**Q4: 可以同时打开多个相机吗？**

A: 可以。创建多个 `CameraCapture` 对象，分别打开不同的设备即可。但需要注意系统 USB 带宽和 CPU 性能限制。

**Q5: 如何保存相机图像到文件？**

A: 使用 EGE 的 `saveimage` 函数：

```cpp
auto frame = camera.grabFrame(3000);
if (frame) {
    saveimage(frame->getImage(), "photo.bmp");
}
```

## 六、总结

`camera_base.cpp` 是学习 EGE 相机模块的最佳起点。它展示了：

- ✅ 如何枚举和管理相机设备
- ✅ 如何打开和关闭相机
- ✅ 如何实时获取和显示相机图像
- ✅ 如何动态切换相机设备和分辨率
- ✅ 如何根据相机参数自适应调整窗口
- ✅ 如何提供友好的用户界面和交互

掌握这个示例后，您就可以开始开发自己的相机应用了。对于更高级的图像处理和特效，可以参考 [camera_wave - 相机水波特效](camera_wave.md) 示例。

## 参考资源

- **EGE 官方网站**：http://xege.org
- **EGE GitHub 仓库**：https://github.com/x-ege/xege
- **API 文档**：参见 EGE 安装包或源码仓库的 `man/api/` 目录
- **更多示例**：参见 EGE 安装包或源码仓库的 `demo/` 目录