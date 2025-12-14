# EGE 2D 函数图像绘制器实现解析

## 项目简介

本项目基于蒙特卡洛方法实现了 2D 隐函数的可视化绘制。传统的函数绘制通常针对显式函数 $y = f(x)$，而本项目支持绘制隐函数形式 $f(x, y) = 0$，这使得可以轻松绘制圆、椭圆、心形等复杂图形。通过 EGE 图形库，程序提供了交互式的参数调整和多种预设函数演示。

## 蒙特卡洛方法原理

蒙特卡洛方法是一种基于随机采样的数值计算方法。在函数可视化中，其原理如下：

1. **随机采样**：在给定的坐标范围 $[x_{min}, x_{max}] \times [y_{min}, y_{max}]$ 内随机生成大量点 $(x, y)$
2. **函数评估**：计算每个点的函数值 $f(x, y)$
3. **条件筛选**：如果 $|f(x, y)| < \epsilon$（其中 $\epsilon$ 为容差），则认为该点在函数图像上
4. **绘制点**：将满足条件的点转换为屏幕坐标并绘制

**优势**：
- 不需要求解方程，适用于任意复杂的隐函数
- 实现简单，易于理解和扩展
- 能够处理多连通区域和不连续函数

**参数影响**：
- **采样点数**：越多则图像越密集，但计算时间越长
- **容差 $\epsilon$**：越小则曲线越细，但需要更多采样点

## 项目特性

- **多种预设函数**：圆形、椭圆、抛物线、双曲线、正弦波、玫瑰花、心形、莲花
- **交互式调整**：实时调整采样点数、容差、点大小
- **坐标系统**：自动绘制网格和坐标轴
- **图像缓存**：使用离屏绘制提升性能
- **参数显示**：实时显示当前坐标范围和渲染参数

## 核心类设计

### Function2DRenderer 类

```cpp
class Function2DRenderer {
public:
    using FunctionType = std::function<double(double, double)>;
    
    Function2DRenderer(int width, int height, 
                      double xMin, double xMax, 
                      double yMin, double yMax);
    
    void render(const FunctionType& func, PIMAGE pimg = NULL);
    void setTolerance(double tolerance);
    void setSampleCount(int count);
    
private:
    void drawFunction(const FunctionType& func, PIMAGE pimg);
    void mathToScreen(double x, double y, int& screenX, int& screenY);
};
```

**核心成员**：
- `m_xMin, m_xMax, m_yMin, m_yMax`：数学坐标范围
- `m_tolerance`：函数值容差 $\epsilon$
- `m_sampleCount`：蒙特卡洛采样点数
- `m_generator`：随机数生成器
- `m_xDistribution, m_yDistribution`：均匀分布生成器

## 坐标系统转换

数学坐标到屏幕坐标的转换是可视化的关键：

```cpp
void mathToScreen(double x, double y, int& screenX, int& screenY) const {
    screenX = static_cast<int>((x - m_xMin) / (m_xMax - m_xMin) * m_width);
    screenY = static_cast<int>((m_yMax - y) / (m_yMax - m_yMin) * m_height);
}
```

**转换公式**：
- 屏幕 X 坐标：$screenX = \frac{x - x_{min}}{x_{max} - x_{min}} \times width$
- 屏幕 Y 坐标：$screenY = \frac{y_{max} - y}{y_{max} - y_{min}} \times height$

注意 Y 坐标需要翻转，因为数学坐标系向上为正，而屏幕坐标系向下为正。

## 蒙特卡洛绘制实现

```cpp
void drawFunction(const FunctionType& func, PIMAGE pimg) {
    setcolor(m_pointColor, pimg);
    setfillcolor(m_pointColor, pimg);
    
    for (int i = 0; i < m_sampleCount; ++i) {
        // 生成随机点
        double x = m_xDistribution(m_generator);
        double y = m_yDistribution(m_generator);
        
        // 计算函数值
        double value = func(x, y);
        
        // 如果函数值在容差范围内，绘制该点
        if (std::abs(value) < m_tolerance) {
            int screenX, screenY;
            mathToScreen(x, y, screenX, screenY);
            
            if (screenX >= 0 && screenX < m_width && 
                screenY >= 0 && screenY < m_height) {
                if (m_pointSize == 1) {
                    putpixel(screenX, screenY, m_pointColor, pimg);
                } else {
                    fillcircle(screenX, screenY, m_pointSize, pimg);
                }
            }
        }
    }
}
```

**算法流程**：
1. 使用均匀分布生成随机坐标 $(x, y)$
2. 计算 $f(x, y)$ 的值
3. 判断 $|f(x, y)| < \epsilon$
4. 转换为屏幕坐标并绘制

## 预设函数实现

### 1. 圆形函数

```cpp
Function2DRenderer::FunctionType circle(double radius) {
    return [radius](double x, double y) -> double {
        return x * x + y * y - radius * radius;
    };
}
```

**数学表达式**：$x^2 + y^2 - r^2 = 0$

当 $x^2 + y^2 = r^2$ 时，点 $(x, y)$ 在半径为 $r$ 的圆上。

### 2. 椭圆函数

```cpp
Function2DRenderer::FunctionType ellipse(double a, double b) {
    return [a, b](double x, double y) -> double {
        return (x * x) / (a * a) + (y * y) / (b * b) - 1.0;
    };
}
```

**数学表达式**：$\frac{x^2}{a^2} + \frac{y^2}{b^2} - 1 = 0$

标准椭圆方程，$a$ 为 X 轴半径，$b$ 为 Y 轴半径。

### 3. 抛物线函数

```cpp
Function2DRenderer::FunctionType parabola(double a, double b, double c) {
    return [a, b, c](double x, double y) -> double {
        return y - a * x * x - b * x - c;
    };
}
```

**数学表达式**：$y - ax^2 - bx - c = 0$

即 $y = ax^2 + bx + c$，标准二次函数。

### 4. 双曲线函数

```cpp
Function2DRenderer::FunctionType hyperbola(double a, double b) {
    return [a, b](double x, double y) -> double {
        return (x * x) / (a * a) - (y * y) / (b * b) - 1.0;
    };
}
```

**数学表达式**：$\frac{x^2}{a^2} - \frac{y^2}{b^2} - 1 = 0$

双曲线有两支，分别位于坐标轴两侧。

### 5. 正弦波函数

```cpp
Function2DRenderer::FunctionType sineWave(double A, double B, double C) {
    return [A, B, C](double x, double y) -> double {
        return y - A * std::sin(B * x + C);
    };
}
```

**数学表达式**：$y - A \sin(Bx + C) = 0$

- $A$：振幅
- $B$：频率
- $C$：相位偏移

### 6. 玫瑰花函数

```cpp
Function2DRenderer::FunctionType rose(double A, int n) {
    return [A, n](double x, double y) -> double {
        double r = std::sqrt(x * x + y * y);
        if (r < 1e-10) return 0.0;
        
        double theta = std::atan2(y, x);
        double expected_r = A * std::sin(n * theta);
        return std::abs(r - std::abs(expected_r));
    };
}
```

**极坐标表达式**：$r = A \sin(n\theta)$

转换为直角坐标需要：
- $r = \sqrt{x^2 + y^2}$
- $\theta = \arctan(\frac{y}{x})$

当 $n = 3$ 时，产生三瓣玫瑰花形状。

### 7. 心形函数

```cpp
Function2DRenderer::FunctionType heart() {
    return [](double x, double y) -> double {
        double temp = x * x + y * y - 1.0;
        return temp * temp * temp - x * x * y * y * y;
    };
}
```

**数学表达式**：$(x^2 + y^2 - 1)^3 - x^2 y^3 = 0$

这是一个经典的心形曲线方程。

### 8. 莲花函数

```cpp
Function2DRenderer::FunctionType lotus() {
    return [](double x, double y) -> double {
        double r = std::sqrt(x * x + y * y);
        double theta = std::atan2(y, x);
        return r - 0.5 * (1 + std::sin(4 * theta));
    };
}
```

**极坐标表达式**：$r = 0.5(1 + \sin(4\theta))$

产生四瓣花瓣的莲花形状。

## EGE 图形库应用

### 1. 网格绘制

```cpp
void drawGrid(PIMAGE pimg) {
    setcolor(m_gridColor, pimg);
    setlinewidth(1, pimg);
    
    double xStep = (m_xMax - m_xMin) / 20.0;
    double yStep = (m_yMax - m_yMin) / 15.0;
    
    // 绘制垂直线
    for (double x = m_xMin; x <= m_xMax; x += xStep) {
        int screenX1, screenY1, screenX2, screenY2;
        mathToScreen(x, m_yMin, screenX1, screenY1);
        mathToScreen(x, m_yMax, screenX2, screenY2);
        line(screenX1, screenY1, screenX2, screenY2, pimg);
    }
    
    // 绘制水平线（类似实现）
}
```

### 2. 坐标轴绘制

```cpp
void drawAxes(PIMAGE pimg) {
    setcolor(m_axisColor, pimg);
    setlinewidth(2, pimg);
    
    // 绘制 X 轴（如果 Y=0 在范围内）
    if (m_yMin <= 0 && m_yMax >= 0) {
        int screenX1, screenY1, screenX2, screenY2;
        mathToScreen(m_xMin, 0, screenX1, screenY1);
        mathToScreen(m_xMax, 0, screenX2, screenY2);
        line(screenX1, screenY1, screenX2, screenY2, pimg);
    }
    
    // 绘制 Y 轴（类似实现）
}
```

### 3. 离屏渲染

```cpp
PIMAGE imgCache = newimage(800, 600);

// 渲染到缓存图像
renderer.renderFunction(functionNames[currentFunction], imgCache);

// 显示到屏幕
cleardevice();
putimage(0, 0, imgCache);
```

使用 `PIMAGE` 实现双缓冲，避免闪烁。

### 4. 随机数生成

```cpp
std::mt19937 m_generator;
std::uniform_real_distribution<double> m_xDistribution(m_xMin, m_xMax);
std::uniform_real_distribution<double> m_yDistribution(m_yMin, m_yMax);

// 生成随机点
double x = m_xDistribution(m_generator);
double y = m_yDistribution(m_generator);
```

使用 C++11 的随机数库生成均匀分布的随机坐标。

## 交互操作

- **空格**：切换到下一个预设函数
- **+ / =**：增加采样点数（+10000）
- **- / _**：减少采样点数（-10000）
- **W**：增加容差（+0.01），使曲线更粗
- **S**：减少容差（-0.01），使曲线更细
- **[**：减小点大小
- **]**：增大点大小
- **R**：重新绘制当前函数
- **ESC**：退出程序

## 性能优化

1. **图像缓存**：将结果绘制到离屏图像，避免重复计算
2. **边界检查**：只绘制屏幕范围内的点
3. **容差控制**：通过调整容差平衡图像质量和采样点数
4. **随机数优化**：使用高效的 Mersenne Twister 随机数生成器

## 扩展方向

基于这个框架，可以轻松扩展：

1. **3D 函数可视化**：扩展为 $f(x, y, z) = 0$ 的三维绘制
2. **参数方程绘制**：支持参数方程 $(x(t), y(t))$ 的绘制
3. **动画效果**：通过参数动态变化实现动画
4. **颜色映射**：根据函数值 $|f(x, y)|$ 映射不同颜色
5. **交互式编辑**：允许用户输入自定义函数表达式

## 数学与编程结合

这个项目很好地展示了数学与编程的结合：

- **隐函数理论**：理解 $f(x, y) = 0$ 的几何意义
- **概率方法**：蒙特卡洛方法的实际应用
- **坐标变换**：数学坐标系与屏幕坐标系的转换
- **函数式编程**：使用 `std::function` 和 Lambda 表达式
- **C++ 现代特性**：随机数库、智能指针、模板等

通过本项目，你不仅能学习图形编程和可视化技术，还能加深对隐函数、极坐标方程等数学概念的理解，是数学建模和计算机图形学学习的优秀案例。
