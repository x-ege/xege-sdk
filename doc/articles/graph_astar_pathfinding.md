# EGE A* 寻路算法可视化实现解析

## 项目简介

A* (A-Star) 是一种经典的启发式搜索算法，广泛应用于游戏开发、机器人路径规划和导航系统中。本项目通过 EGE 图形库实现了 A* 算法的完整可视化演示，让抽象的搜索过程变得直观可见。用户可以通过鼠标绘制障碍物、设置起点和终点，并实时观察算法如何寻找最短路径。

## A* 算法原理

A* 算法结合了 Dijkstra 算法的完备性和贪心最佳优先搜索的效率。其核心思想是使用评估函数：

$$f(n) = g(n) + h(n)$$

其中：
- **$g(n)$**：从起点到当前节点 $n$ 的实际代价
- **$h(n)$**：从当前节点 $n$ 到终点的启发式估计代价
- **$f(n)$**：节点 $n$ 的总估计代价

**算法流程**：
1. 将起点加入开放列表（Open Set）
2. 从开放列表中选择 $f(n)$ 值最小的节点
3. 将该节点移至关闭列表（Closed Set）
4. 探索该节点的所有邻居节点
5. 更新邻居节点的 $g$、$h$、$f$ 值
6. 重复步骤 2-5，直到找到终点或开放列表为空

## 项目特性

- **交互式绘制**：鼠标左键绘制/清除障碍物，右键设置起点和终点
- **单步执行**：按 S 键逐步执行算法，观察每一步的决策过程
- **自动演示**：按 A 键开启自动演示模式，持续执行直到找到路径
- **随机迷宫**：按 G 键生成随机迷宫
- **对角线移动**：按 D 键切换是否允许对角线移动
- **速度控制**：方向键调整动画速度
- **实时统计**：显示已探索节点数和最终路径长度
- **视觉反馈**：不同颜色表示节点状态（待探索、已探索、路径）

## 核心数据结构

### Node 结构

```cpp
struct Node {
    int row, col;        // 位置坐标
    float g;             // 从起点到当前节点的实际代价
    float h;             // 从当前节点到终点的启发式估计
    float f;             // f = g + h
    int parentRow;       // 父节点行（用于路径回溯）
    int parentCol;       // 父节点列
    
    bool operator>(const Node& other) const { 
        return f > other.f;  // 优先队列比较（f 值小的优先）
    }
};
```

### 网格表示

```cpp
enum CellType {
    CELL_EMPTY,   // 空地
    CELL_WALL,    // 障碍物
    CELL_START,   // 起点
    CELL_END      // 终点
};

enum CellState {
    STATE_NONE,    // 未访问
    STATE_OPEN,    // 在开放列表中
    STATE_CLOSED,  // 在关闭列表中
    STATE_PATH     // 在最终路径上
};
```

## 启发式函数

启发式函数 $h(n)$ 的选择直接影响算法的性能和路径质量。

### 欧几里得距离

```cpp
float heuristic(int r1, int c1, int r2, int c2) {
    float dx = static_cast<float>(c2 - c1);
    float dy = static_cast<float>(r2 - r1);
    
    if (m_allowDiagonal) {
        // 欧几里得距离
        return std::sqrt(dx * dx + dy * dy);
    } else {
        // 曼哈顿距离
        return std::abs(dx) + std::abs(dy);
    }
}
```

**欧几里得距离**：$h(n) = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}$
- 适用于允许对角线移动的情况
- 提供更准确的距离估计

**曼哈顿距离**：$h(n) = |x_2 - x_1| + |y_2 - y_1|$
- 适用于只允许上下左右移动的情况
- 计算更快速

## 核心算法实现

### 初始化搜索

```cpp
void initSearch() {
    resetSearch();
    m_state = ALG_SEARCHING;
    
    // 初始化起点
    Node& startNode = m_nodeInfo[m_startRow][m_startCol];
    startNode.g = 0;
    startNode.h = heuristic(m_startRow, m_startCol, m_endRow, m_endCol);
    startNode.f = startNode.g + startNode.h;
    
    // 加入开放列表
    m_openSet.push(startNode);
    m_openSetLookup.insert(m_startRow * GRID_COLS + m_startCol);
    m_cellState[m_startRow][m_startCol] = STATE_OPEN;
}
```

### 单步搜索

```cpp
bool stepSearch() {
    if (m_openSet.empty()) {
        m_state = ALG_NO_PATH;
        return true;  // 无解
    }
    
    // 取出 f 值最小的节点
    Node current = m_openSet.top();
    m_openSet.pop();
    m_openSetLookup.erase(current.row * GRID_COLS + current.col);
    
    int row = current.row;
    int col = current.col;
    
    // 标记为已探索
    m_cellState[row][col] = STATE_CLOSED;
    ++m_nodesExplored;
    
    // 检查是否到达终点
    if (row == m_endRow && col == m_endCol) {
        m_state = ALG_FOUND;
        reconstructPath();
        return true;  // 找到路径
    }
    
    // 探索相邻节点
    exploreNeighbors(row, col);
    
    return false;  // 继续搜索
}
```

### 探索邻居节点

```cpp
void exploreNeighbors(int row, int col) {
    // 4 方向（上下左右）
    static const int dx4[] = {0, 0, 1, -1};
    static const int dy4[] = {1, -1, 0, 0};
    
    // 8 方向（包括对角线）
    static const int dx8[] = {0, 0, 1, -1, 1, 1, -1, -1};
    static const int dy8[] = {1, -1, 0, 0, 1, -1, 1, -1};
    
    int numDirs = m_allowDiagonal ? 8 : 4;
    const int* dx = m_allowDiagonal ? dx8 : dx4;
    const int* dy = m_allowDiagonal ? dy8 : dy4;
    
    for (int i = 0; i < numDirs; ++i) {
        int newRow = row + dy[i];
        int newCol = col + dx[i];
        
        // 边界检查
        if (newRow < 0 || newRow >= GRID_ROWS || 
            newCol < 0 || newCol >= GRID_COLS) {
            continue;
        }
        
        // 墙壁或已关闭节点跳过
        if (m_grid[newRow][newCol] == CELL_WALL || 
            m_cellState[newRow][newCol] == STATE_CLOSED) {
            continue;
        }
        
        // 对角线移动时检查是否被墙壁阻挡
        if (m_allowDiagonal && i >= 4) {
            if (isCornerBlocked(row, col, dy[i], dx[i])) {
                continue;
            }
        }
        
        // 计算新的 g 值
        float moveCost = (i >= 4) ? 1.414f : 1.0f;  // √2 或 1
        float newG = m_nodeInfo[row][col].g + moveCost;
        
        // 更新或添加节点
        updateNeighbor(newRow, newCol, row, col, newG);
    }
}
```

### 对角线移动优化

```cpp
bool isCornerBlocked(int row, int col, int dy, int dx) {
    // 检查对角线路径是否被两个相邻墙壁阻挡
    int checkRow1 = row + dy;
    int checkCol1 = col;
    int checkRow2 = row;
    int checkCol2 = col + dx;
    
    return (m_grid[checkRow1][checkCol1] == CELL_WALL && 
            m_grid[checkRow2][checkCol2] == CELL_WALL);
}
```

这个优化防止对角线移动"穿墙"，确保路径的真实性。

### 节点更新

```cpp
void updateNeighbor(int newRow, int newCol, int parentRow, int parentCol, float newG) {
    int nodeKey = newRow * GRID_COLS + newCol;
    bool inOpenSet = m_openSetLookup.find(nodeKey) != m_openSetLookup.end();
    
    // 如果不在开放列表中，或找到更短路径
    if (!inOpenSet || newG < m_nodeInfo[newRow][newCol].g) {
        Node& neighbor = m_nodeInfo[newRow][newCol];
        neighbor.g = newG;
        neighbor.h = heuristic(newRow, newCol, m_endRow, m_endCol);
        neighbor.f = neighbor.g + neighbor.h;
        neighbor.parentRow = parentRow;
        neighbor.parentCol = parentCol;
        
        if (!inOpenSet) {
            m_openSet.push(neighbor);
            m_openSetLookup.insert(nodeKey);
            m_cellState[newRow][newCol] = STATE_OPEN;
        }
    }
}
```

### 路径回溯

```cpp
void reconstructPath() {
    int row = m_endRow;
    int col = m_endCol;
    
    while (row != m_startRow || col != m_startCol) {
        if (m_grid[row][col] != CELL_START && m_grid[row][col] != CELL_END) {
            m_cellState[row][col] = STATE_PATH;
        }
        ++m_pathLength;
        
        // 沿父节点回溯
        int parentRow = m_nodeInfo[row][col].parentRow;
        int parentCol = m_nodeInfo[row][col].parentCol;
        
        if (parentRow < 0 || parentCol < 0) break;
        
        row = parentRow;
        col = parentCol;
    }
}
```

## 数据结构优化

### 优先队列

```cpp
std::priority_queue<Node, std::vector<Node>, std::greater<Node>> m_openSet;
```

使用最小堆实现优先队列，确保每次能以 $O(\log n)$ 时间复杂度取出 $f$ 值最小的节点。

### 开放集快速查找

```cpp
std::set<int> m_openSetLookup;
```

使用 `std::set` 实现 $O(\log n)$ 时间复杂度的查找，判断节点是否已在开放列表中。节点位置编码为 `row * GRID_COLS + col`。

## 迷宫生成

```cpp
void generateMaze() {
    clearWalls();
    srand(static_cast<unsigned>(time(nullptr)));
    
    // 生成随机墙壁
    int wallCount = (GRID_ROWS * GRID_COLS) / 4;
    for (int i = 0; i < wallCount; ++i) {
        int r = rand() % GRID_ROWS;
        int c = rand() % GRID_COLS;
        
        if (m_grid[r][c] == CELL_EMPTY) {
            m_grid[r][c] = CELL_WALL;
        }
    }
    
    // 添加连续墙壁
    int lineCount = 15;
    for (int i = 0; i < lineCount; ++i) {
        int r = rand() % GRID_ROWS;
        int c = rand() % GRID_COLS;
        int length = rand() % 15 + 5;
        bool horizontal = rand() % 2;
        
        for (int j = 0; j < length; ++j) {
            int nr = horizontal ? r : r + j;
            int nc = horizontal ? c + j : c;
            
            if (isValidCell(nr, nc) && m_grid[nr][nc] == CELL_EMPTY) {
                m_grid[nr][nc] = CELL_WALL;
            }
        }
    }
    
    // 确保起点和终点周围有空间
    clearAroundPoint(m_startRow, m_startCol, 2);
    clearAroundPoint(m_endRow, m_endCol, 2);
}
```

## EGE 图形库应用

### 1. 网格绘制

```cpp
void drawGrid() {
    for (int r = 0; r < GRID_ROWS; ++r) {
        for (int c = 0; c < GRID_COLS; ++c) {
            int x = c * CELL_SIZE;
            int y = r * CELL_SIZE;
            
            color_t fillColor = getCellColor(r, c);
            
            setfillcolor(fillColor);
            bar(x + 1, y + 1, x + CELL_SIZE - 1, y + CELL_SIZE - 1);
        }
    }
    
    // 绘制网格线
    setcolor(ASTAR_COLOR_GRID);
    for (int r = 0; r <= GRID_ROWS; ++r) {
        line(0, r * CELL_SIZE, CANVAS_WIDTH, r * CELL_SIZE);
    }
    for (int c = 0; c <= GRID_COLS; ++c) {
        line(c * CELL_SIZE, 0, c * CELL_SIZE, CANVAS_HEIGHT);
    }
}
```

### 2. 颜色状态映射

```cpp
color_t getCellColor(int r, int c) {
    if (m_grid[r][c] == CELL_WALL) {
        return ASTAR_COLOR_WALL;      // 深灰色
    } else if (m_grid[r][c] == CELL_START) {
        return ASTAR_COLOR_START;     // 绿色
    } else if (m_grid[r][c] == CELL_END) {
        return ASTAR_COLOR_END;       // 红色
    }
    
    switch (m_cellState[r][c]) {
        case STATE_PATH:
            return ASTAR_COLOR_PATH;   // 黄色
        case STATE_CLOSED:
            return ASTAR_COLOR_CLOSED; // 紫色
        case STATE_OPEN:
            return ASTAR_COLOR_OPEN;   // 蓝色
        default:
            return ASTAR_COLOR_BG;     // 背景色
    }
}
```

### 3. 鼠标交互

```cpp
void handleMouse() {
    while (mousemsg()) {
        mouse_msg msg = getmouse();
        
        int col = msg.x / CELL_SIZE;
        int row = msg.y / CELL_SIZE;
        
        if (msg.is_left()) {
            // 绘制/清除墙壁
            if (msg.is_down() || msg.is_move()) {
                toggleWall(row, col);
            }
        } else if (msg.is_right() && msg.is_down()) {
            // 设置起点/终点（交替）
            setStartOrEnd(row, col);
        }
    }
}
```

### 4. 控制面板绘制

```cpp
void drawControlPanel() {
    int panelX = CANVAS_WIDTH;
    
    // 面板背景
    setfillcolor(EGERGB(45, 45, 55));
    bar(panelX, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    // 显示统计信息
    xyprintf(textX, textY, "已探索节点: %d", m_nodesExplored);
    xyprintf(textX, textY + 20, "路径长度: %d", m_pathLength);
    
    // 显示图例
    drawLegend(panelX);
    
    // 显示控制说明
    drawControls(panelX);
}
```

## 操作指南

- **S / 空格 / 回车**：开始/单步执行算法
- **R**：重置路径（保留障碍物）
- **C**：清除所有障碍物
- **G**：生成随机迷宫
- **A**：切换自动演示模式
- **D**：切换对角线移动
- **↑ / ↓**：调整动画速度
- **ESC**：退出程序
- **鼠标左键**：绘制/清除障碍物（支持拖动）
- **鼠标右键**：设置起点（绿）/终点（红）

## 算法性能分析

### 时间复杂度

- **最坏情况**：$O(b^d)$，其中 $b$ 是分支因子，$d$ 是解的深度
- **优先队列操作**：每次插入和删除为 $O(\log n)$
- **启发式函数良好时**：接近 $O(d)$，远优于盲目搜索

### 空间复杂度

- **开放列表**：$O(b^d)$
- **关闭列表**：$O(b^d)$
- **节点信息**：$O(\text{网格大小})$

### 最优性保证

A* 算法能保证找到最短路径，前提是启发式函数满足**可采纳性**（admissible）：

$$h(n) \leq h^*(n)$$

其中 $h^*(n)$ 是从 $n$ 到终点的真实最短距离。欧几里得距离和曼哈顿距离都是可采纳的启发式函数。

## 扩展方向

1. **不同启发式函数对比**：实现多种启发式函数（Chebyshev 距离、Octile 距离等）
2. **双向 A***：同时从起点和终点搜索
3. **Jump Point Search**：优化 A* 的跳点搜索算法
4. **动态权重 A***：调整 $h(n)$ 的权重以平衡速度和最优性
5. **多目标路径规划**：访问多个目标点的最优路径

## 技术亮点

1. **优先队列优化**：使用 `std::priority_queue` 实现高效的节点选择
2. **双重查找**：优先队列 + set 实现快速查找和更新
3. **对角线优化**：防止对角线穿墙，确保路径真实性
4. **实时可视化**：每一步都更新界面，展示算法决策过程
5. **交互式设计**：鼠标拖动、键盘快捷键，用户体验友好

这个项目不仅展示了 A* 算法的强大能力，还通过可视化让抽象的搜索过程变得直观易懂，是学习路径规划算法和游戏 AI 的绝佳案例。
