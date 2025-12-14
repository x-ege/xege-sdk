# EGE K-Means 聚类算法可视化实现解析

## 项目简介

K-Means 是一种经典的无监督学习聚类算法，广泛应用于数据挖掘、图像分割、市场细分和模式识别等领域。本项目通过 EGE 图形库实现了 K-Means 算法的完整可视化演示，展示了从随机初始化到迭代收敛的全过程。用户可以动态调整簇数量、生成不同分布的数据集，并观察算法如何逐步将数据点分组。

## K-Means 算法原理

K-Means 算法的目标是将 $n$ 个数据点划分为 $K$ 个簇，使得每个簇内的数据点尽可能相似，不同簇之间的数据点尽可能不同。

### 算法流程

1. **初始化**：选择 $K$ 个点作为初始聚类中心
2. **分配**：将每个数据点分配给距离最近的聚类中心
3. **更新**：重新计算每个簇的中心点（簇内所有点的均值）
4. **迭代**：重复步骤 2 和 3，直到中心点不再移动或移动距离小于阈值

### 数学表达

**目标函数**（最小化簇内平方和）：

$$J = \sum_{i=1}^{K} \sum_{x \in C_i} \|x - \mu_i\|^2$$

其中：
- $C_i$ 是第 $i$ 个簇
- $\mu_i$ 是第 $i$ 个簇的中心点
- $\|x - \mu_i\|$ 是欧几里得距离

**更新公式**：

$$\mu_i = \frac{1}{|C_i|} \sum_{x \in C_i} x$$

## 项目特性

- **K-Means++ 初始化**：使用改进的初始化策略，提升收敛速度和结果质量
- **可视化迭代过程**：实时显示数据点的簇分配和中心点移动轨迹
- **动态参数调整**：支持调整簇数量 K（2-10）和动画速度
- **多样数据生成**：使用高斯分布生成具有自然簇结构的数据集
- **自动演示模式**：自动迭代直到收敛
- **统计信息显示**：显示迭代次数、各簇点数、中心点移动距离等

## 核心算法实现

### K-Means++ 初始化

传统 K-Means 随机选择初始中心点，容易陷入局部最优。K-Means++ 通过改进初始化策略显著提升性能。

```cpp
void initializeCentroids() {
    m_centroids.clear();
    
    // 1. 随机选择第一个中心点
    int firstIdx = m_rd() % m_points.size();
    m_centroids.push_back(Centroid(m_points[firstIdx].x, m_points[firstIdx].y));
    
    // 2. 依次选择其余中心点
    std::vector<float> distances(m_points.size());
    
    for (int c = 1; c < m_k; ++c) {
        float totalDist = 0.0f;
        
        // 计算每个点到最近中心点的距离平方
        for (size_t i = 0; i < m_points.size(); ++i) {
            float minDist = std::numeric_limits<float>::max();
            for (const auto& centroid : m_centroids) {
                float dx = m_points[i].x - centroid.x;
                float dy = m_points[i].y - centroid.y;
                float dist = dx * dx + dy * dy;
                minDist = std::min(minDist, dist);
            }
            distances[i] = minDist;
            totalDist += minDist;
        }
        
        // 按概率选择下一个中心点
        float r = random() * totalDist;
        float cumulative = 0.0f;
        
        for (size_t i = 0; i < m_points.size(); ++i) {
            cumulative += distances[i];
            if (cumulative >= r) {
                m_centroids.push_back(Centroid(m_points[i].x, m_points[i].y));
                break;
            }
        }
    }
}
```

**K-Means++ 优势**：
- 选择概率与距离平方成正比，倾向于选择远离已有中心点的点
- 初始中心点分布更均匀，避免聚集在同一区域
- 通常能更快收敛且结果更优

### 迭代过程

```cpp
bool iterate() {
    // 保存当前中心点位置（用于计算移动距离）
    for (auto& centroid : m_centroids) {
        centroid.savePosition();
    }
    
    // 步骤1：分配每个点到最近的中心点
    for (auto& point : m_points) {
        float minDist = std::numeric_limits<float>::max();
        int bestCluster = 0;
        
        for (int k = 0; k < m_k; ++k) {
            float dx = point.x - m_centroids[k].x;
            float dy = point.y - m_centroids[k].y;
            float dist = dx * dx + dy * dy;  // 使用距离平方避免开方
            
            if (dist < minDist) {
                minDist = dist;
                bestCluster = k;
            }
        }
        point.clusterId = bestCluster;
    }
    
    // 步骤2：更新中心点位置
    std::vector<float> sumX(m_k, 0.0f);
    std::vector<float> sumY(m_k, 0.0f);
    std::vector<int> counts(m_k, 0);
    
    for (const auto& point : m_points) {
        if (point.clusterId >= 0 && point.clusterId < m_k) {
            sumX[point.clusterId] += point.x;
            sumY[point.clusterId] += point.y;
            counts[point.clusterId]++;
        }
    }
    
    for (int k = 0; k < m_k; ++k) {
        if (counts[k] > 0) {
            m_centroids[k].x = sumX[k] / counts[k];
            m_centroids[k].y = sumY[k] / counts[k];
        }
    }
    
    ++m_iteration;
    
    // 检查是否收敛
    float maxMoved = 0.0f;
    for (const auto& centroid : m_centroids) {
        maxMoved = std::max(maxMoved, centroid.movedDistance());
    }
    
    return maxMoved < m_convergenceThreshold;
}
```

**算法关键点**：
- 使用距离平方而非距离，避免开方运算，提升性能
- 统计每个簇的点数和坐标和，然后计算均值
- 通过中心点移动距离判断收敛

### 收敛判定

```cpp
bool hasConverged() {
    float maxMoved = 0.0f;
    for (const auto& centroid : m_centroids) {
        float dx = centroid.x - centroid.prevX;
        float dy = centroid.y - centroid.prevY;
        float moved = std::sqrt(dx * dx + dy * dy);
        maxMoved = std::max(maxMoved, moved);
    }
    return maxMoved < m_convergenceThreshold;
}
```

当所有中心点的移动距离都小于阈值（如 0.5 像素）时，认为算法已收敛。

## 数据生成策略

### 高斯分布生成

```cpp
void generateDataPoints() {
    m_points.clear();
    
    // 生成几个随机簇中心
    int numClusters = m_rd() % 4 + 3;  // 3-6 个自然簇
    float clusterSpread = 60.0f;       // 簇内分散程度
    
    std::vector<Point2D> clusterCenters;
    for (int i = 0; i < numClusters; ++i) {
        float cx = random(50, CANVAS_WIDTH - 50);
        float cy = random(50, CANVAS_HEIGHT - 50);
        clusterCenters.push_back(Point2D(cx, cy));
    }
    
    // 围绕每个簇中心生成点
    std::normal_distribution<float> normalDist(0.0f, clusterSpread);
    int pointsPerCluster = m_numPoints / numClusters;
    
    for (int i = 0; i < numClusters; ++i) {
        int count = (i == numClusters - 1) ? 
                    (m_numPoints - m_points.size()) : pointsPerCluster;
        
        for (int j = 0; j < count; ++j) {
            float x = clusterCenters[i].x + normalDist(m_rd);
            float y = clusterCenters[i].y + normalDist(m_rd);
            
            // 确保点在画布范围内
            x = clamp(x, 10.0f, CANVAS_WIDTH - 10.0f);
            y = clamp(y, 10.0f, CANVAS_HEIGHT - 10.0f);
            
            m_points.push_back(Point2D(x, y));
        }
    }
    
    // 添加一些随机噪声点
    int noiseCount = m_numPoints / 10;
    for (int i = 0; i < noiseCount; ++i) {
        float x = random(10, CANVAS_WIDTH - 10);
        float y = random(10, CANVAS_HEIGHT - 10);
        m_points.push_back(Point2D(x, y));
    }
}
```

**数据特点**：
- 使用正态分布生成簇状数据，模拟真实场景
- 添加 10% 的噪声点，测试算法的鲁棒性
- 确保数据点在画布范围内

## 可视化设计

### 数据点绘制

```cpp
void drawPoints() {
    for (const auto& point : m_points) {
        color_t color;
        if (point.clusterId >= 0 && point.clusterId < m_k) {
            color = CLUSTER_COLORS[point.clusterId];
        } else {
            color = EGERGB(128, 128, 128);  // 未分配的点为灰色
        }
        
        setfillcolor(color);
        setcolor(EGEACOLOR(200, color));
        ege_fillellipse(point.x - POINT_RADIUS, point.y - POINT_RADIUS, 
                        POINT_RADIUS * 2, POINT_RADIUS * 2);
    }
}
```

每个簇使用不同颜色，便于区分。

### 中心点绘制

```cpp
void drawCentroids() {
    for (int k = 0; k < m_centroids.size(); ++k) {
        const auto& centroid = m_centroids[k];
        color_t color = CLUSTER_COLORS[k];
        
        int cx = (int)centroid.x;
        int cy = (int)centroid.y;
        
        // 外圈（簇颜色）
        setfillcolor(color);
        ege_fillellipse(cx - CENTROID_RADIUS, cy - CENTROID_RADIUS, 
                        CENTROID_RADIUS * 2, CENTROID_RADIUS * 2);
        
        // 内圈（白色）
        setfillcolor(WHITE);
        ege_fillellipse(cx - CENTROID_RADIUS / 2, cy - CENTROID_RADIUS / 2, 
                        CENTROID_RADIUS, CENTROID_RADIUS);
        
        // 绘制十字标记
        setcolor(color);
        setlinestyle(PS_SOLID, 2);
        line(cx - CENTROID_RADIUS - 5, cy, cx + CENTROID_RADIUS + 5, cy);
        line(cx, cy - CENTROID_RADIUS - 5, cx, cy + CENTROID_RADIUS + 5);
    }
}
```

中心点使用十字星标记，外圈颜色对应簇颜色，内圈白色，易于识别。

### 移动轨迹

```cpp
void drawCentroidTrails() {
    setlinestyle(PS_DASH, 2);  // 虚线
    for (int k = 0; k < m_centroids.size(); ++k) {
        const auto& centroid = m_centroids[k];
        if (centroid.movedDistance() > 0.1f) {
            color_t color = CLUSTER_COLORS[k];
            setcolor(EGEACOLOR(150, color));  // 半透明
            line((int)centroid.prevX, (int)centroid.prevY, 
                 (int)centroid.x, (int)centroid.y);
        }
    }
    setlinestyle(PS_SOLID, 1);
}
```

使用虚线连接中心点的前后位置，展示移动轨迹。

## 性能优化

### 1. 避免开方运算

```cpp
// 计算距离时使用距离平方
float distSquared = dx * dx + dy * dy;

// 只在需要显示时才计算真实距离
float movedDistance() const {
    float dx = x - prevX;
    float dy = y - prevY;
    return std::sqrt(dx * dx + dy * dy);
}
```

在分配步骤中，只需比较距离大小，使用距离平方即可，避免大量开方运算。

### 2. 数据结构优化

```cpp
struct Point2D {
    float x, y;
    int clusterId;  // 直接存储簇ID，避免额外查找
};
```

将簇分配结果直接存储在点结构中，避免使用额外的映射表。

### 3. 向量预分配

```cpp
std::vector<float> sumX(m_k, 0.0f);
std::vector<float> sumY(m_k, 0.0f);
std::vector<int> counts(m_k, 0);
```

预先分配固定大小的向量，避免动态扩容。

## 算法复杂度分析

### 时间复杂度

- **单次迭代**：$O(n \cdot K)$
  - 分配步骤：遍历 $n$ 个点，每个点与 $K$ 个中心点比较
  - 更新步骤：$O(n)$，遍历所有点统计
  
- **总时间复杂度**：$O(t \cdot n \cdot K)$
  - $t$ 是迭代次数（通常很小，10-30 次）

### 空间复杂度

- **数据点存储**：$O(n)$
- **中心点存储**：$O(K)$
- **辅助数组**：$O(K)$
- **总空间复杂度**：$O(n + K)$

## K-Means 的局限性

1. **需要预先指定 K**：需要事先知道簇的数量
2. **对初始值敏感**：不同初始化可能导致不同结果（K-Means++ 可缓解）
3. **假设簇为凸形**：对非凸形簇效果不佳
4. **对离群点敏感**：离群点会影响中心点位置
5. **局部最优**：可能陷入局部最优解

## 改进方向

1. **肘部法则（Elbow Method）**：自动确定最优 K 值
2. **轮廓系数（Silhouette Coefficient）**：评估聚类质量
3. **K-Medoids**：使用实际数据点作为中心，对离群点更鲁棒
4. **Fuzzy C-Means**：软聚类，允许点属于多个簇
5. **DBSCAN**：基于密度的聚类，不需要预先指定 K

## 操作指南

- **S / 空格 / 回车**：执行一次迭代
- **R**：重置算法（保留数据点）
- **G**：重新生成数据点
- **+ / =**：增加簇数量 K
- **- / _**：减少簇数量 K
- **A**：切换自动演示模式
- **↑ / ↓**：调整动画速度
- **ESC**：退出程序

## 实际应用

K-Means 算法在多个领域有广泛应用：

1. **图像分割**：将像素按颜色聚类，实现图像压缩
2. **市场细分**：根据客户特征将客户分组
3. **文档分类**：将文档按主题聚类
4. **异常检测**：识别不属于任何簇的离群点
5. **推荐系统**：将用户或物品聚类，进行协同过滤

## 技术亮点

1. **K-Means++ 初始化**：显著提升算法性能和结果质量
2. **高斯分布数据生成**：生成具有自然簇结构的测试数据
3. **实时可视化**：动态展示每次迭代的变化过程
4. **性能优化**：避免不必要的开方运算，使用距离平方
5. **交互体验**：支持参数调整、自动演示、速度控制

这个项目不仅展示了 K-Means 算法的工作原理，还通过可视化让抽象的数学概念变得直观易懂，是学习机器学习和数据挖掘的优秀案例。通过调整 K 值和观察不同数据分布，可以深入理解聚类算法的特性和局限性。
