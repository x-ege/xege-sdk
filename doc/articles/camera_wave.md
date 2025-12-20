# EGE 相机进阶特效：camera_wave 水波变形详解

## 引言

在掌握了 EGE 相机模块的基础使用方法后（参见 [camera_base - 相机基础示例](camera_base.md)），我们可以进一步探索相机图像的实时处理和特效应用。`camera_wave.cpp` 演示了如何在相机采集的实时图像上实现交互式的水波变形特效，展示了 EGE 相机模块在图像处理领域的强大能力。

本文将深入解析 `camera_wave.cpp` 的实现原理，包括物理模拟、纹理映射、性能优化等核心技术。建议在阅读本文前先学习 [camera_base](camera_base.md)，了解相机模块的基本使用方法。

## 一、功能概述

### 1.1 主要特性

`camera_wave.cpp` 在 `camera_base` 的基础上，添加了以下高级特性：

- **实时水波模拟**：基于物理模拟的弹性网格变形
- **交互式控制**：通过鼠标拖拽实时改变网格形状
- **可调参数**：通过键盘动态调整弹性强度
- **高性能渲染**：使用纹理映射和三角形光栅化
- **完整功能保留**：继承 camera_base 的所有设备管理功能

### 1.2 交互操作

除了 camera_base 的所有键盘操作外，camera_wave 还支持：

| 操作 | 功能 |
|------|------|
| **鼠标左键拖拽** | 拖动网格点，产生波纹效果 |
| **+ 或 = 键** | 增加弹性强度（增强波纹效果） |
| **- 或 _ 键** | 减少弹性强度（减弱波纹效果） |

### 1.3 视觉效果

当鼠标按下并拖动时，相机画面会像水面一样产生波纹，并在松开鼠标后逐渐恢复平静。整个过程基于真实的物理模拟，波纹的传播、衰减都符合弹性力学规律。

## 二、核心原理

### 2.1 网格物理模拟

水波特效的核心是一个基于弹性力学的网格系统。网格由 $M \times N$ 个点组成（在 camera_wave 中默认为 80×60），每个点具有以下属性：

$$
\text{Point}_i = (x_i, y_i, dx_i, dy_i, u_i, v_i)
$$

其中：
- $(x_i, y_i)$ 是点的屏幕坐标（归一化到 [0, 1] 范围）
- $(dx_i, dy_i)$ 是点的速度
- $(u_i, v_i)$ 是该点对应的纹理坐标

网格的运动遵循简化的弹性方程。对于每个内部点 $(i, j)$,其加速度由四个相邻点（上下左右）的位置决定：

$$
a_x = (x_{i-1,j} + x_{i+1,j} + x_{i,j-1} + x_{i,j+1}) - 4x_{i,j}
$$

$$
a_y = (y_{i-1,j} + y_{i+1,j} + y_{i,j-1} + y_{i,j+1}) - 4y_{i,j}
$$

这是二维拉普拉斯算子 $\nabla^2$ 的离散形式，它计算了四个方向邻居对当前点的拉力总和。当相邻点离得越远,拉力就越大。

### 2.2 能量损耗模拟

为了使波纹逐渐衰减而不是无限振荡，程序引入了能量损耗机制。当加速度方向与速度方向相反（即正在减速）时，加大阻尼效果：

```cpp
// 模拟能量损失
if (std::signbit(dx) != std::signbit(m_vec[m_index][h].dx)) {
    dx *= 1.0f + m_intensity;
}

if (std::signbit(dy) != std::signbit(m_vec[m_index][h].dy)) {
    dy *= 1.0f + m_intensity;
}
```

这种设计使得波纹能够快速收敛到静止状态。`m_intensity` 参数控制弹性强度，取值范围为 0.001 到 0.3：
- 较小的值：波纹传播缓慢，衰减快
- 较大的值：波纹传播快速，持续时间长

### 2.3 纹理映射与三角形光栅化

网格中每个四边形单元被分解为两个三角形，然后使用纹理映射进行渲染：

```cpp
// 将四边形分解为两个三角形
for (int i = 1; i != m_height; ++i) {
    const int k1 = (i - 1) * m_width;
    const int k2 = i * m_width;

    for (int j = 1; j != m_width; ++j) {
        const int p1 = k1 + j - 1;  // 左上
        const int p2 = k1 + j;      // 右上
        const int p3 = k2 + j - 1;  // 左下
        const int p4 = k2 + j;      // 右下

        fillTriangle(v[p1], v[p2], v[p3]);  // 上三角形
        fillTriangle(v[p3], v[p2], v[p4]);  // 下三角形
    }
}
```

每个三角形使用透视正确的纹理插值进行填充。对于三角形内部的每个像素，根据重心坐标计算对应的纹理坐标 $(u, v)$，然后从相机帧图像中采样颜色。这样即使网格变形，纹理也能正确映射。

## 三、Net 类详解

### 3.1 类结构

`Net` 类封装了整个网格系统的实现：

```cpp
class Net {
public:
    Net() : m_index(0), m_intensity(0.2f), m_lastIndex(-1) {}
    
    // 初始化网格（w x h 分辨率）
    bool initNet(int w, int h, PIMAGE inputTexture, PIMAGE outputTarget);
    
    // 设置输入纹理（相机帧）
    void setTextureImage(PIMAGE texture);
    
    // 设置输出目标
    void setOutputTarget(PIMAGE target);
    
    // 更新网格物理状态
    void update();
    
    // 捕获网格点（鼠标按下时）
    void catchPoint(float x, float y);
    
    // 释放网格点（鼠标松开时）
    void releasePoint();
    
    // 渲染网格
    void drawNet();
    
    // 调整弹性强度
    void intensityInc(float f);
    void intensityDec(float f);
    float getIntensity();
    
private:
    std::vector<Point> m_vec[2];      // 双缓冲点数组
    std::vector<Point> m_pointCache;  // 渲染缓存
    int m_index;                      // 当前缓冲区索引
    int m_width, m_height;            // 网格尺寸
    float m_intensity;                // 弹性强度
    int m_lastIndex;                  // 当前捕获的点索引
    
    PIMAGE m_texture;                 // 输入纹理（相机帧）
    PIMAGE m_outputTarget;            // 输出目标
    
    // 三角形填充函数
    template <class Type>
    void fillTriangle(const Type& v0, const Type& v1, const Type& v2);
};
```

### 3.2 网格初始化

网格初始化时，将所有点均匀分布在 [0, 1]×[0, 1] 的归一化坐标空间中：

```cpp
bool Net::initNet(int w, int h, PIMAGE inputTexture, PIMAGE outputTarget)
{
    if (w < 2 || h < 2) {
        return false;
    }

    m_width = w;
    m_height = h;

    m_vec[0].resize(w * h);
    m_vec[1].resize(w * h);
    
    float widthStep = 1.0f / (w - 1);
    float heightStep = 1.0f / (h - 1);

    for (int i = 0; i < h; ++i) {
        const float heightI = i * heightStep;
        int index = w * i;
        for (int j = 0; j < w; ++j) {
            const float widthJ = j * widthStep;
            // 初始位置和纹理坐标相同，速度为0
            m_vec[0][index] = Point(widthJ, heightI, widthJ, heightI);
            m_vec[1][index] = Point(widthJ, heightI, widthJ, heightI);
            ++index;
        }
    }
    return true;
}
```

**技术要点**：
- 使用双缓冲数组 `m_vec[0]` 和 `m_vec[1]` 交替读写
- 归一化坐标便于适配不同分辨率的窗口
- 初始状态下，所有点静止且均匀分布

### 3.3 网格更新算法

网格的更新使用双缓冲技术，避免读写冲突：

```cpp
void Net::update()
{
    const float widthStep = 1.0f / (m_width - 1.0f);
    const float heightStep = 1.0f / (m_height - 1.0f);
    int index = (m_index + 1) % 2;  // 切换到另一个缓冲区

    // 只更新内部点，边界保持固定
    for (int i = 1; i < m_height - 1; ++i) {
        const int k = m_width * i;
        for (int j = 1; j < m_width - 1; ++j) {
            const int h = k + j;
            float dx, dy;
            
            // 计算水平方向的加速度（左右邻居的拉力）
            dx = (m_vec[m_index][h - 1].x + m_vec[m_index][h + 1].x 
                 - m_vec[m_index][h].x * 2.0f);
            dy = (m_vec[m_index][h - 1].y + m_vec[m_index][h + 1].y 
                 - m_vec[m_index][h].y * 2.0f);

            // 计算垂直方向的加速度（上下邻居的拉力）
            dx += (m_vec[m_index][h - m_width].x + m_vec[m_index][h + m_width].x 
                  - m_vec[m_index][h].x * 2.0f);
            dy += (m_vec[m_index][h - m_width].y + m_vec[m_index][h + m_width].y 
                  - m_vec[m_index][h].y * 2.0f);

            // 模拟能量损失
            if (std::signbit(dx) != std::signbit(m_vec[m_index][h].dx)) {
                dx *= 1.0f + m_intensity;
            }
            if (std::signbit(dy) != std::signbit(m_vec[m_index][h].dy)) {
                dy *= 1.0f + m_intensity;
            }

            // 更新速度：v' = v + a * intensity
            m_vec[m_index][h].dx += dx * m_intensity;
            m_vec[m_index][h].dy += dy * m_intensity;
            m_vec[index][h].dx = m_vec[m_index][h].dx;
            m_vec[index][h].dy = m_vec[m_index][h].dy;

            // 更新位置：p' = p + v'
            m_vec[index][h].x = m_vec[m_index][h].x + m_vec[index][h].dx;
            m_vec[index][h].y = m_vec[m_index][h].y + m_vec[index][h].dy;
        }
    }
    
    m_index = index;  // 切换缓冲区
}
```

**技术要点**：
- 双缓冲避免在更新过程中读写同一个数组
- 边界点不更新，保持网格形状稳定
- 加速度由相邻点的位置差决定（拉普拉斯算子）
- 能量损耗机制确保波纹逐渐衰减

### 3.4 鼠标交互

当用户按下鼠标左键时，程序会找到最接近鼠标的网格点并将其固定在鼠标位置：

```cpp
void Net::catchPoint(float x, float y)
{
    int index;

    if (m_lastIndex < 0) {
        // 首次捕获，找到最近的点（使用曼哈顿距离）
        float mdis = 1e9f;
        for (int i = 1; i < m_height - 1; ++i) {
            const int k = m_width * i;
            for (int j = 1; j < m_width - 1; ++j) {
                const int h = k + j;
                const float dis = fabsf(x - m_vec[m_index][h].x) 
                                + fabsf(y - m_vec[m_index][h].y);
                if (dis < mdis) {
                    index = h;
                    mdis = dis;
                }
            }
        }
        m_lastIndex = index;
    } else {
        index = m_lastIndex;
    }

    // 固定该点的位置并清零速度
    m_vec[0][index].x = x;
    m_vec[0][index].y = y;
    m_vec[1][index].x = x;
    m_vec[1][index].y = y;
    m_vec[0][index].dx = 0.0f;
    m_vec[0][index].dy = 0.0f;
    m_vec[1][index].dx = 0.0f;
    m_vec[1][index].dy = 0.0f;
}

void Net::releasePoint() 
{ 
    m_lastIndex = -1;  // 松开鼠标，释放捕获的点
}
```

**技术要点**：
- 首次按下时查找最近的网格点
- 后续拖动直接使用已记录的点索引，避免重复查找
- 将该点固定在鼠标位置，速度清零
- 松开鼠标后，该点恢复参与物理模拟

### 3.5 三角形光栅化

三角形填充是整个渲染过程的核心。`Net` 类将每个四边形分解为两个三角形，然后对每个三角形进行纹理映射填充：

```cpp
template <class Type> 
inline void Net::fillTriangle(const Type& v0, const Type& v1, const Type& v2)
{
    if (v0.y == v2.y) {
        _fillSimpleTriangle(v0, v1, v2);
    } else if (v1.y == v2.y) {
        _fillSimpleTriangle(v1, v0, v2);
    } else if (v0.y == v1.y) {
        _fillSimpleTriangle(v0, v2, v1);
    } else {
        _fillNormalTriangle(v0, v1, v2);
    }
}
```

三角形有两种情况：
1. **平底/平顶三角形**：有两个点的 y 坐标相同，直接填充
2. **普通三角形**：将其分解为一个平底和一个平顶三角形

对于简单三角形（平底或平顶），逐行扫描填充：

```cpp
template <class Type> 
inline void Net::_fillSimpleTriangle(const Type& vv0, const Type& v1, const Type& vv2)
{
    assert(vv0.y == vv2.y);
    const Type& v0 = (vv0.x < vv2.x) ? vv0 : vv2;
    const Type& v2 = (vv0.x < vv2.x) ? vv2 : vv0;

    float h = v1.y - v0.y;
    if (fabs(h) < 1e-6f) {
        return; // 退化为线段，跳过
    }

    // 计算左右边界的斜率
    float dL = (v1.x - v0.x) / h;  // 左边界 x 增量
    float dR = (v1.x - v2.x) / h;  // 右边界 x 增量

    // 计算纹理坐标的插值增量
    float dUL = (v1.u - v0.u) / h;
    float dVL = (v1.v - v0.v) / h;
    float dUR = (v1.u - v2.u) / h;
    float dVR = (v1.v - v2.v) / h;

    float xL = v0.x, xR = v2.x;
    float uL = v0.u, vL = v0.v;
    float uR = v2.u, vR = v2.v;

    const color_t* data = m_textureData;
    color_t* outputBuffer = (color_t*)getbuffer(m_outputTarget);

    // 逐行扫描填充
    for (int i = v0.y; i < v1.y; ++i) {
        float len = xR - xL;
        if (fabs(len) < 1e-6f) {
            continue; // 该行长度为0，跳过
        }
        
        // 逐列填充
        for (int j = xL; j < xR; ++j) {
            float percent = (j - xL) / len;
            float u = uL + (uR - uL) * percent;
            float v = vL + (vR - vL) * percent;
            
            // 边界检查
            if (u < 0 || v < 0 || u > 1 || v > 1 || 
                i < 0 || j < 0 || i >= m_outputHeight || j >= m_outputWidth) {
                continue;
            }

            // 从纹理中采样
            int ww = u * (m_texWidth - 1);
            int hh = v * (m_texHeight - 1);
            int index = ww + hh * m_texWidth;
            int outputIndex = j + i * m_outputWidth;
            outputBuffer[outputIndex] = data[index];
        }
        
        // 更新下一行的边界和纹理坐标
        xL += dL; xR += dR;
        uL += dUL; vL += dVL;
        uR += dUR; vR += dVR;
    }
}
```

**技术要点**：
- 逐行扫描，从三角形顶部到底部
- 每行计算左右边界，然后逐列填充
- 使用线性插值计算纹理坐标
- 添加除零检查和边界检查，确保数值稳定性

## 四、主循环实现

camera_wave 的主循环整合了相机采集、网格更新和交互控制：

```cpp
Net net;
PIMAGE target = newimage(getwidth(), getheight());
net.initNet(80, 60, nullptr, target);  // 80x60 网格

// 主循环
for (; camera.isStarted() && is_run(); delay_fps(60)) {
    cleardevice();

    // 获取相机帧（非阻塞模式）
    auto newFrame = camera.grabFrame(0);
    if (newFrame) {
        frame = newFrame;
        net.setTextureImage(frame->getImage());
    }

    // 鼠标交互
    if (keystate(key_mouse_l)) {
        int x, y;
        mousepos(&x, &y);
        net.catchPoint(x / (float)getwidth(), y / (float)getheight());
    } else {
        net.releasePoint();
    }

    // 键盘控制
    if (kbhit()) {
        auto keyMsg = getkey();
        switch (keyMsg.key) {
        case '+':
        case '=':
            net.intensityInc(0.005f);  // 增加弹性
            break;
        case '-':
        case '_':
            net.intensityDec(0.005f);  // 减少弹性
            break;
        // ... 其他按键处理（相机切换、分辨率切换等）
        }
        flushkey();
    }

    // 更新并渲染网格
    net.drawNet();
    net.update();
    putimage(0, 0, target);

    // 显示信息界面
    displayInfo(net.getIntensity(), deviceNames, currentDeviceIndex, 
               resolutions, currentResolutionIndex);
}
```

**技术要点**：
- 使用 `grabFrame(0)` 非阻塞模式，立即返回最新帧或 nullptr
- 鼠标坐标归一化到 [0, 1] 范围，便于与网格坐标匹配
- 先渲染网格 (`drawNet`)，再更新物理状态 (`update`)
- 鼠标按下时显示网格线，帮助理解变形过程

## 五、技术要点与优化

### 5.1 性能优化

1. **双缓冲技术**：使用两个点数组交替读写，避免数据竞争
2. **非阻塞帧获取**：`grabFrame(0)` 立即返回，避免等待造成的卡顿
3. **缓存变换结果**：将归一化坐标转换为屏幕坐标后缓存在 `m_pointCache` 中
4. **边界固定**：网格边界点保持不变，减少 20% 以上的计算量
5. **合理的网格分辨率**：80×60 的网格在性能和效果之间取得平衡

### 5.2 数值稳定性

1. **除零保护**：在所有除法运算前检查分母是否接近零
2. **边界检查**：绘制前检查坐标是否在有效范围内
3. **浮点比较**：使用 `fabs(x) < 1e-6f` 判断浮点数是否接近零
4. **退化三角形处理**：当三角形面积为零时跳过渲染，避免无效计算

### 5.3 用户体验

1. **实时反馈**：在屏幕上显示当前弹性强度
2. **网格可视化**：鼠标按下时显示网格线（黄色），帮助理解变形
3. **参数调节**：通过 `+/-` 键微调弹性参数（每次 0.005）
4. **信息丰富**：显示操作提示、相机设备列表、分辨率列表、作者信息

## 六、扩展思路

基于 camera_wave 的架构，您可以实现更多有趣的特效：

### 6.1 彩色滤镜

在纹理采样时修改颜色通道：

```cpp
// 采样后添加滤镜效果
color_t color = data[index];
int r = EGEGET_R(color);
int g = EGEGET_G(color);
int b = EGEGET_B(color);

// 例如：黑白滤镜
int gray = (r + g + b) / 3;
outputBuffer[outputIndex] = EGERGB(gray, gray, gray);

// 例如：暖色调滤镜
outputBuffer[outputIndex] = EGERGB(
    std::min(r + 30, 255),
    g,
    std::max(b - 30, 0)
);
```

### 6.2 时间延迟效果

保存历史帧，实现时间回溯：

```cpp
std::deque<std::shared_ptr<CameraFrame>> historyFrames;
const int MAX_HISTORY = 30;  // 保存 30 帧历史

// 每帧保存
historyFrames.push_back(frame);
if (historyFrames.size() > MAX_HISTORY) {
    historyFrames.pop_front();
}

// 使用延迟 N 帧的图像作为纹理
int delay = 15;
if (historyFrames.size() > delay) {
    net.setTextureImage(historyFrames[historyFrames.size() - delay]->getImage());
}
```

### 6.3 边缘检测

对相机图像进行实时边缘检测：

```cpp
// Sobel 边缘检测
PIMAGE edgeImage = newimage(width, height);
for (int i = 1; i < height - 1; ++i) {
    for (int j = 1; j < width - 1; ++j) {
        // 计算梯度...
        int gx = ..., gy = ...;
        int magnitude = sqrt(gx*gx + gy*gy);
        putpixel(j, i, magnitude > threshold ? WHITE : BLACK, edgeImage);
    }
}
net.setTextureImage(edgeImage);
```

### 6.4 多重网格叠加

使用多个不同参数的网格叠加，产生更复杂的效果：

```cpp
Net net1, net2;
net1.initNet(40, 30, frame->getImage(), target1);
net1.setIntensity(0.1f);

net2.initNet(20, 15, frame->getImage(), target2);
net2.setIntensity(0.3f);

// 混合渲染
net1.drawNet();
net2.drawNet();
alphaBlend(target1, target2, finalTarget, 0.5f);
```

## 七、常见问题解答

**Q1: 为什么我的水波效果看起来不自然？**

A: 可以尝试调整以下参数：
- 降低弹性强度（按 `-` 键）
- 减小网格分辨率（如 40×30）
- 检查窗口大小是否与相机分辨率匹配

**Q2: 如何提高渲染性能？**

A: 性能优化建议：
- 降低网格分辨率（如从 80×60 改为 60×45）
- 降低相机分辨率（如使用 640×480）
- 使用 Release 模式编译（而非 Debug）
- 确保使用了 `INIT_RENDERMANUAL` 标志

**Q3: 网格变形后如何复位？**

A: 可以添加一个复位功能：

```cpp
void Net::reset()
{
    for (int i = 0; i < m_height; ++i) {
        for (int j = 0; j < m_width; ++j) {
            int index = i * m_width + j;
            float x = j / (float)(m_width - 1);
            float y = i / (float)(m_height - 1);
            m_vec[0][index] = Point(x, y, x, y);
            m_vec[1][index] = Point(x, y, x, y);
        }
    }
}
```

**Q4: 可以改变网格的形状吗？**

A: 可以。修改 `initNet` 函数中的初始位置计算。例如，创建圆形网格：

```cpp
float centerX = 0.5f, centerY = 0.5f, radius = 0.4f;
float angle = (j / (float)w) * 2 * PI;
float r = (i / (float)h) * radius;
float x = centerX + r * cos(angle);
float y = centerY + r * sin(angle);
m_vec[0][index] = Point(x, y, widthJ, heightI);
```

## 八、总结

camera_wave 展示了如何在 EGE 相机模块的基础上实现复杂的图像处理和视觉特效：

- ✅ 基于物理的网格模拟
- ✅ 实时纹理映射和三角形光栅化
- ✅ 交互式鼠标控制
- ✅ 高性能渲染优化
- ✅ 数值稳定性保障

通过学习这个示例，您可以：
- 理解弹性网格的物理原理
- 掌握纹理映射和三角形光栅化技术
- 学习如何优化实时图像处理程序
- 创造自己的相机特效应用

## 参考资源

- **基础教程**：[camera_base - 相机基础示例](camera_base.md)
- **EGE 官方网站**：http://xege.org
- **EGE GitHub 仓库**：https://github.com/x-ege/xege
- **API 文档**：参见 EGE 安装包或源码仓库的 `man/api/` 目录
- **更多示例**：参见 EGE 安装包或源码仓库的 `demo/` 目录