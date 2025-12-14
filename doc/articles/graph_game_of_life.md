# EGE 康威生命游戏实现解析

## 项目简介

康威生命游戏（Conway's Game of Life）是英国数学家约翰·康威（John Conway）于 1970 年发明的一个经典元胞自动机（Cellular Automaton）。这个零玩家游戏仅由简单的规则驱动，却能产生极其复杂的涌现行为，被广泛用于研究复杂系统、人工生命和混沌理论。本项目使用 EGE 图形库实现了完整的生命游戏可视化，支持交互式绘制、多种经典图案、视图缩放和轨迹效果。

## 生命游戏规则

生命游戏在一个无限的二维网格上进行，每个格子（细胞）有两种状态：**存活**或**死亡**。每一代的演化遵循以下四条规则：

1. **孤独**：任何活细胞周围少于 2 个活邻居则死亡
2. **存活**：任何活细胞周围有 2 或 3 个活邻居则继续存活
3. **拥挤**：任何活细胞周围超过 3 个活邻居则死亡
4. **繁殖**：任何死细胞周围恰好有 3 个活邻居则复活

这四条简单规则产生了丰富多彩的图案，包括静止图案、振荡器、飞船、滑翔机枪等。

## 项目特性

- **交互式绘制**：鼠标左键绘制/擦除细胞，支持拖动连续绘制
- **9 种预设图案**：滑翔机、轻型飞船、脉冲星、高斯帕枪等经典图案
- **视图控制**：鼠标右键平移视图，滚轮缩放（2x-30x）
- **轨迹效果**：显示细胞的历史轨迹，形成渐变尾迹
- **速度控制**：1-60 代/秒可调，支持暂停和单步执行
- **网格开关**：可切换网格线显示
- **实时统计**：显示代数、存活细胞数、速度等信息
- **视觉反馈**：不同颜色表示新生、存活、死亡细胞

## 核心算法实现

### 邻居计数

```cpp
int countNeighbors(int x, int y) const {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) {
                continue;  // 跳过自己
            }
            if (getCell(x + dx, y + dy)) {
                count++;
            }
        }
    }
    return count;
}
```

这个函数检查细胞周围 8 个方向的邻居（摩尔邻域），返回存活邻居的数量。

### 状态更新

```cpp
void update() {
    m_prevGrid = m_grid;  // 保存上一代状态用于视觉效果
    m_population = 0;
    
    for (int y = 0; y < GRID_HEIGHT; y++) {
        for (int x = 0; x < GRID_WIDTH; x++) {
            int neighbors = countNeighbors(x, y);
            bool alive = getCell(x, y);
            bool nextState = false;
            
            if (alive) {
                // 规则 1, 2, 3
                nextState = (neighbors == 2 || neighbors == 3);
            } else {
                // 规则 4
                nextState = (neighbors == 3);
            }
            
            m_nextGrid[y * GRID_WIDTH + x] = nextState;
            
            if (nextState) {
                m_population++;
            }
        }
    }
    
    std::swap(m_grid, m_nextGrid);
    m_generation++;
}
```

**算法要点**：
- 同时计算所有细胞的下一代状态，避免影响其他细胞的计算
- 使用双缓冲（`m_grid` 和 `m_nextGrid`）避免读写冲突
- 保存上一代状态用于视觉过渡效果

### 规则简化表达

生命游戏的规则可以用一行代码表达：

```cpp
nextState = (neighbors == 3) || (alive && neighbors == 2);
```

这个表达式等价于四条规则：
- `neighbors == 3`：死细胞复活，活细胞存活
- `alive && neighbors == 2`：活细胞存活

## 经典图案

### 1. 滑翔机（Glider）

```cpp
pattern = {{0, 0}, {1, 0}, {2, 0}, {2, -1}, {1, -2}};
```

最小的飞船，每 4 代向右下移动一格，是生命游戏的标志性图案。

```
  █
█  █
 ███
```

### 2. 轻型飞船（LWSS）

```cpp
pattern = {{0, 0}, {3, 0}, {4, 1}, {0, 2}, {4, 2}, 
           {1, 3}, {2, 3}, {3, 3}, {4, 3}};
```

每 4 代水平移动 2 格的飞船。

### 3. 脉冲星（Pulsar）

周期为 3 的振荡器，具有完美的对称性。通过镜像生成完整图案：

```cpp
// 生成一个象限
pattern = {{2, 0}, {3, 0}, {4, 0}, {0, 2}, {5, 2}, ...};

// 镜像到四个象限
for (auto& p : pattern) {
    fullPattern.push_back({p.first, p.second});
    fullPattern.push_back({-p.first - 1, p.second});
    fullPattern.push_back({p.first, -p.second - 1});
    fullPattern.push_back({-p.first - 1, -p.second - 1});
}
```

### 4. 高斯帕滑翔机枪（Gosper Glider Gun）

```cpp
pattern = {{0, 4}, {0, 5}, {1, 4}, {1, 5}, 
           {10, 4}, {10, 5}, {10, 6}, {11, 3}, ...};
```

第一个被发现的能产生无限滑翔机的图案，证明了生命游戏可以产生无限增长的结构。每 30 代发射一个滑翔机。

### 5. R-五格体（R-pentomino）

```cpp
pattern = {{0, 0}, {1, 0}, {0, 1}, {-1, 1}, {0, 2}};
```

仅由 5 个细胞组成，却要经过 1103 代才稳定下来，最终产生 116 个细胞。展示了简单初始状态可以产生极其复杂的演化。

### 6. 橡子（Acorn）

```cpp
pattern = {{0, 0}, {1, -2}, {1, 0}, {3, -1}, 
           {4, 0}, {5, 0}, {6, 0}};
```

仅 7 个细胞，经过 5206 代才稳定，最终产生 633 个细胞。

## 视觉效果实现

### 轨迹效果

```cpp
void updateTrail() {
    if (m_showTrail) {
        for (int i = 0; i < GRID_WIDTH * GRID_HEIGHT; i++) {
            if (m_grid[i]) {
                m_trailGrid[i] = 255;  // 活细胞轨迹最亮
            } else if (m_trailGrid[i] > 0) {
                m_trailGrid[i] = std::max(0, m_trailGrid[i] - 15);  // 渐变淡化
            }
        }
    }
}

void renderTrail() {
    for (int y = 0; y < GRID_HEIGHT; y++) {
        for (int x = 0; x < GRID_WIDTH; x++) {
            int trail = m_trailGrid[y * GRID_WIDTH + x];
            if (trail > 0 && !m_grid[y * GRID_WIDTH + x]) {
                int r = 30 * trail / 255;
                int g = 60 * trail / 255;
                int b = 40 * trail / 255;
                setfillcolor(EGERGB(r, g, b));
                bar(screenX, screenY, screenX + cellSize - 1, screenY + cellSize - 1);
            }
        }
    }
}
```

轨迹效果为每个细胞维护一个强度值（0-255），活细胞设为最亮，死亡后逐渐淡化，形成渐变的历史轨迹。

### 细胞状态颜色

```cpp
color_t cellColor;
if (alive && !wasAlive) {
    cellColor = LIFE_COLOR_CELL_BORN;    // 新生 - 浅绿色
} else if (!alive && wasAlive) {
    cellColor = LIFE_COLOR_CELL_DYING;   // 死亡 - 橙色
} else {
    cellColor = LIFE_COLOR_CELL_ALIVE;   // 存活 - 绿色
}
```

通过对比当前状态和上一代状态，用不同颜色表示细胞的生命周期。

## 交互功能实现

### 鼠标绘制

```cpp
void handleMouseDrawing(mouse_msg msg) {
    if (msg.is_left()) {
        if (msg.is_down()) {
            m_isDrawing = true;
            int gridX = (int)((msg.x - m_offsetX) / m_cellSize);
            int gridY = (int)((msg.y - m_offsetY) / m_cellSize);
            
            // 记录绘制值（toggle 当前细胞状态）
            m_drawValue = !getCell(gridX, gridY);
            setCell(gridX, gridY, m_drawValue);
        } else if (msg.is_move() && m_isDrawing) {
            // 拖动连续绘制
            int gridX = (int)((msg.x - m_offsetX) / m_cellSize);
            int gridY = (int)((msg.y - m_offsetY) / m_cellSize);
            setCell(gridX, gridY, m_drawValue);
        } else if (msg.is_up()) {
            m_isDrawing = false;
        }
    }
}
```

支持点击切换细胞状态，以及拖动连续绘制。

### 视图平移

```cpp
void handlePan(mouse_msg msg) {
    if (msg.is_right()) {
        if (msg.is_down()) {
            m_isDragging = true;
            m_lastMouseX = msg.x;
            m_lastMouseY = msg.y;
        } else if (msg.is_move() && m_isDragging) {
            m_offsetX += msg.x - m_lastMouseX;
            m_offsetY += msg.y - m_lastMouseY;
            m_lastMouseX = msg.x;
            m_lastMouseY = msg.y;
        } else if (msg.is_up()) {
            m_isDragging = false;
        }
    }
}
```

右键拖动实现视图平移，类似地图导航。

### 缩放功能

```cpp
void handleZoom(mouse_msg msg) {
    if (msg.is_wheel()) {
        float oldCellSize = m_cellSize;
        float zoomFactor = msg.wheel > 0 ? 1.2f : 0.8f;
        m_cellSize *= zoomFactor;
        m_cellSize = std::max(2.0f, std::min(30.0f, m_cellSize));
        
        // 以鼠标位置为中心缩放
        float mouseGridX = (msg.x - m_offsetX) / oldCellSize;
        float mouseGridY = (msg.y - m_offsetY) / oldCellSize;
        m_offsetX = msg.x - mouseGridX * m_cellSize;
        m_offsetY = msg.y - mouseGridY * m_cellSize;
    }
}
```

**缩放算法要点**：
- 保持鼠标指向的网格坐标不变
- 计算鼠标在网格中的相对位置
- 根据新的 `cellSize` 重新计算偏移量

数学公式：
$$\text{mouseGridX} = \frac{\text{mouseX} - \text{offsetX}_{\text{old}}}{\text{cellSize}_{\text{old}}}$$
$$\text{offsetX}_{\text{new}} = \text{mouseX} - \text{mouseGridX} \times \text{cellSize}_{\text{new}}$$

## 性能优化

### 1. 视锥剔除（Frustum Culling）

```cpp
void renderCells() {
    for (int y = 0; y < GRID_HEIGHT; y++) {
        for (int x = 0; x < GRID_WIDTH; x++) {
            float screenX = m_offsetX + x * m_cellSize;
            float screenY = m_offsetY + y * m_cellSize;
            
            // 剔除屏幕外的细胞
            if (screenX + m_cellSize < 0 || screenX > GRID_AREA_WIDTH ||
                screenY + m_cellSize < 0 || screenY > WINDOW_HEIGHT) {
                continue;
            }
            
            // 只渲染可见区域
            drawCell(x, y, screenX, screenY);
        }
    }
}
```

只渲染屏幕可见区域的细胞，大幅提升性能。

### 2. 帧率控制

```cpp
void run() {
    while (is_run()) {
        if (!m_paused) {
            m_frameCount++;
            int updateInterval = 60 / m_speed;  // 控制更新频率
            
            if (m_frameCount >= updateInterval) {
                update();
                m_frameCount = 0;
            }
        }
        
        render();
        delay_fps(60);  // 保持 60 FPS 渲染
    }
}
```

渲染和逻辑更新分离，确保流畅的视觉体验。

### 3. 一维数组存储

```cpp
std::vector<bool> m_grid;  // 大小为 GRID_WIDTH * GRID_HEIGHT

// 访问 (x, y) 位置
int index = y * GRID_WIDTH + x;
bool alive = m_grid[index];
```

使用一维数组替代二维数组，提升缓存友好性和访问效率。

## EGE 图形库应用

### 网格绘制

```cpp
void drawGrid() {
    if (m_showGrid && m_cellSize >= 4) {
        setcolor(LIFE_COLOR_GRID);
        
        // 垂直线
        for (int x = 0; x <= GRID_WIDTH; x++) {
            float screenX = m_offsetX + x * m_cellSize;
            if (screenX >= 0 && screenX < GRID_AREA_WIDTH) {
                line((int)screenX, 0, (int)screenX, WINDOW_HEIGHT);
            }
        }
        
        // 水平线
        for (int y = 0; y <= GRID_HEIGHT; y++) {
            float screenY = m_offsetY + y * m_cellSize;
            if (screenY >= 0 && screenY < WINDOW_HEIGHT) {
                line(0, (int)screenY, GRID_AREA_WIDTH, (int)screenY);
            }
        }
    }
}
```

当 `cellSize` 足够大时绘制网格线，提升视觉效果。

### 信息面板

```cpp
void drawPanel() {
    // 面板背景
    setfillcolor(LIFE_COLOR_PANEL);
    bar(GRID_AREA_WIDTH, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    // 统计信息
    sprintf(buf, "代数: %d", m_generation);
    outtextxy(x, y, buf);
    
    sprintf(buf, "存活: %d", m_population);
    outtextxy(x, y + 22, buf);
    
    sprintf(buf, "速度: %d 代/秒", m_speed);
    outtextxy(x, y + 44, buf);
}
```

右侧面板显示实时统计和操作说明。

## 操作指南

- **空格**：暂停/继续
- **R**：随机生成细胞
- **C**：清空网格
- **G**：切换网格线
- **T**：切换轨迹效果
- **+ / -**：调整速度
- **1-9**：加载预设图案
- **鼠标左键**：绘制/擦除细胞
- **鼠标右键**：平移视图
- **滚轮**：缩放
- **ESC**：退出

## 数学与哲学意义

生命游戏不仅是一个有趣的可视化项目，还蕴含深刻的数学和哲学意义：

1. **涌现性**：简单规则产生复杂行为，展示了复杂系统的涌现特性
2. **图灵完备**：生命游戏被证明是图灵完备的，可以模拟任何计算机程序
3. **自组织**：无需外部干预，系统自发形成有序结构
4. **混沌边缘**：介于完全随机和完全有序之间的临界状态
5. **人工生命**：探索生命的本质特征——自我复制、演化、适应

通过这个项目，你不仅能学习元胞自动机和可视化技术，还能深入思考生命、计算和复杂性的本质。
