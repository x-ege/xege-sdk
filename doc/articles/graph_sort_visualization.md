# EGE 排序算法可视化实现解析

## 项目简介

排序算法是计算机科学的基础内容之一。本项目通过 EGE 图形库实现了多种经典排序算法的可视化演示，让抽象的算法过程变得直观可见。程序支持 11 种常见排序算法，包括冒泡排序、快速排序、归并排序等，并实时显示算法执行过程、操作统计和时间消耗。

## 项目特性

- **11 种排序算法**：冒泡、选择、插入、快速、归并、堆、希尔、基数、计数、TimSort 以及标准库排序
- **实时可视化**：通过柱状图展示数组状态，高亮显示当前比较和交换的元素
- **操作统计**：实时统计算法的写入/赋值次数、比较次数、读取次数
- **速度控制**：支持动态调整动画速度，方便观察不同算法的执行过程
- **交互操作**：支持算法切换、数组打乱、自动演示等多种交互方式
- **性能对比**：显示每个算法的时间复杂度和实际执行时间

## 可视化设计

### 视觉元素

程序使用柱状图表示数组元素，每个柱子的高度对应元素值的大小。通过颜色区分不同状态：

- **浅蓝色**：普通元素
- **红色**：当前正在访问或比较的第一个元素
- **黄色**：当前正在比较的第二个元素

### 信息显示

界面顶部实时显示：
- 当前算法名称
- 操作统计（写入/赋值、比较、读取次数）
- 动画速度设置
- 算法时间复杂度和空间复杂度

## 核心技术实现

### 1. 自定义元素类 `MyElement`

为了实现操作统计和可视化触发，程序封装了自定义的 `MyElement` 类：

```cpp
class MyElement {
public:
    MyElement& operator=(const MyElement& other) {
        if (this != &other) {
            m_value = other.getValue();
            recordWrite();           // 记录写入操作
            notifyVisualization();   // 触发可视化更新
            if (g_operationDelay > 0) {
                api_sleep(g_operationDelay);  // 延迟以展示动画
            }
        }
        return *this;
    }
    
    bool operator<(const MyElement& other) const {
        recordComparison();  // 记录比较操作
        return m_value < other.m_value;
    }
    
private:
    static int s_writeCount;     // 写入次数统计
    static int s_compareCount;   // 比较次数统计
    static int s_readCount;      // 读取次数统计
};
```

这个设计的巧妙之处在于：
- **运算符重载**：通过重载赋值、比较等运算符，自动统计操作次数
- **静态计数器**：使用静态成员变量全局统计，避免传递额外参数
- **延迟机制**：每次操作后延迟指定时间，使可视化过程清晰可见

### 2. 自定义迭代器 `MyIterator`

为了让标准库算法也能触发可视化，程序实现了符合 STL 标准的自定义迭代器：

```cpp
class MyIterator {
public:
    using iterator_category = std::random_access_iterator_tag;
    using value_type = MyElement;
    
    reference operator*() {
        m_arrayPtr->m_highlightedIndex1 = m_index;  // 高亮当前元素
        m_arrayPtr->notifyVisualization();          // 触发可视化
        return m_arrayPtr->m_data[m_index];
    }
    
    reference operator[](difference_type n) {
        m_arrayPtr->m_highlightedIndex1 = m_index + n;
        m_arrayPtr->notifyVisualization();
        return m_arrayPtr->m_data[m_index + n];
    }
};
```

**关键特性**：
- **随机访问迭代器**：实现了完整的随机访问迭代器接口
- **操作拦截**：在解引用和下标访问时触发可视化
- **STL 兼容**：可以直接用于 `std::sort`、`std::stable_sort` 等标准库算法

### 3. 特化 `std::swap` 和 `std::iter_swap`

为了统计交换操作，程序特化了标准库的交换函数：

```cpp
namespace std {
    template<> void swap(MyElement& a, MyElement& b) {
        MyElement temp = a;  // 1次写入
        a = b;               // 1次写入
        b = temp;            // 1次写入
        // 总计3次写入，正确反映交换成本
    }
    
    template<> void iter_swap(MyArray::MyIterator a, MyArray::MyIterator b) {
        MyArray* arr = a.getArray();
        arr->highlightElements(a.getIndex(), b.getIndex());  // 高亮交换元素
        std::swap(*a, *b);
    }
}
```

这确保了即使使用标准库的交换函数，也能正确统计和可视化。

## 排序算法实现

### 冒泡排序

```cpp
template<typename Iterator>
void bubbleSort(Iterator first, Iterator last) {
    for (auto i = first; i != last; ++i) {
        for (auto j = first; j != last - 1; ++j) {
            if (*j > *(j + 1)) {
                std::iter_swap(j, j + 1);
            }
        }
    }
}
```

- **时间复杂度**：$O(n^2)$
- **空间复杂度**：$O(1)$
- **特点**：每次遍历将最大元素"冒泡"到末尾

### 快速排序

```cpp
template<typename Iterator>
Iterator partition(Iterator first, Iterator last) {
    auto pivot = *(last - 1);
    auto i = first - 1;
    
    for (auto j = first; j != last - 1; ++j) {
        if (*j <= pivot) {
            ++i;
            if (i != j) {
                std::iter_swap(i, j);
            }
        }
    }
    std::iter_swap(i + 1, last - 1);
    return i + 1;
}

template<typename Iterator>
void quickSort(Iterator first, Iterator last) {
    if (first < last) {
        auto pivot = partition(first, last);
        quickSort(first, pivot);
        quickSort(pivot + 1, last);
    }
}
```

- **时间复杂度**：平均 $O(n \log n)$，最坏 $O(n^2)$
- **空间复杂度**：$O(\log n)$（递归栈）
- **特点**：分治算法，通过基准元素分区实现排序

### 归并排序

```cpp
template<typename Iterator>
void merge(Iterator first, Iterator mid, Iterator last) {
    std::vector<std::pair<Iterator, typename Iterator::value_type>> temp;
    
    auto left = first;
    auto right = mid;
    
    while (left != mid && right != last) {
        if (*left <= *right) {
            temp.emplace_back(left, *left);
            ++left;
        } else {
            temp.emplace_back(right, *right);
            ++right;
        }
    }
    
    // 复制剩余元素...
    
    // 复制回原数组
    auto iter = first;
    for (const auto& val : temp) {
        *iter = val.second;
        ++iter;
    }
}
```

- **时间复杂度**：$O(n \log n)$
- **空间复杂度**：$O(n)$
- **特点**：稳定排序，通过分治和合并实现

### 堆排序

堆排序手动实现了堆化过程，与自定义迭代器完美配合：

```cpp
template<typename Iterator>
void heapSort(Iterator first, Iterator last) {
    auto heapify = [](Iterator start, Iterator end, Iterator root) {
        while (true) {
            auto largest = root;
            auto left = start + 2 * (root - start) + 1;
            auto right = start + 2 * (root - start) + 2;
            
            if (left < end && (*left) > *largest) {
                largest = left;
            }
            if (right < end && (*right) > *largest) {
                largest = right;
            }
            if (largest == root) break;
            
            std::iter_swap(root, largest);
            root = largest;
        }
    };
    
    // 构建堆
    auto distance = std::distance(first, last);
    for (int i = distance / 2 - 1; i >= 0; i--) {
        heapify(first, last, first + i);
    }
    
    // 提取元素
    for (auto it = last - 1; it != first; --it) {
        std::iter_swap(first, it);
        heapify(first, it, first);
    }
}
```

- **时间复杂度**：$O(n \log n)$
- **空间复杂度**：$O(1)$
- **特点**：原地排序，不稳定

### 基数排序

基数排序针对整数特点，按位进行排序：

```cpp
template<typename Iterator>
void radixSort(Iterator first, Iterator last) {
    auto max_val = *std::max_element(first, last);
    
    // 对每一位进行计数排序
    for (int exp = 1; max_val.getValue() / exp > 0; exp *= 10) {
        // 计数排序逻辑...
        for (auto it = first; it != last; ++it) {
            count[(it->getValue() / exp) % 10]++;
        }
        // 重建数组...
    }
}
```

- **时间复杂度**：$O(d \cdot (n + k))$，其中 $d$ 是位数
- **空间复杂度**：$O(n + k)$
- **特点**：非比较排序，适合整数

## EGE 图形库应用

### 1. 柱状图绘制

```cpp
void updateScene(bool flush = true) {
    cleardevice();
    
    const auto& data = m_array.getData();
    
    for (int i = 0; i < data.size(); ++i) {
        int x = i * BAR_WIDTH;
        int height = data[i].getValue();
        
        // 根据状态设置颜色
        if (i == m_array.getHighlightedIndex1()) {
            setfillcolor(RED);
        } else if (i == m_array.getHighlightedIndex2()) {
            setfillcolor(YELLOW);
        } else {
            setfillcolor(LIGHTBLUE);
        }
        
        bar(x, WINDOW_HEIGHT - height - 20, 
            x + BAR_WIDTH - 2, WINDOW_HEIGHT - 20);
    }
}
```

### 2. 实时信息显示

```cpp
setcolor(CYAN);
setfont(14, 0, TEXT_FONT_NAME);
xyprintf(10, 40, "算法: %s | 写入: %d | 比较: %d | 读取: %d",
    m_array.getCurrentAlgorithm().c_str(),
    m_array.getWriteCount(),
    m_array.getCompareCount(), 
    m_array.getReadCount());
```

### 3. 键盘交互

```cpp
void handleKeyMsg() {
    while (kbhit()) {
        char ch = getch();
        switch (ch) {
        case 's': case 'S':
        case ' ': case '\n':
            startSorting();
            break;
        case 'r': case 'R':
        case 27:  // ESC
            shuffleArray();
            break;
        case '+': case '=':
            g_operationDelay = std::max(0, g_operationDelay - 10);
            break;
        case '-': case '_':
            g_operationDelay = std::min(500, g_operationDelay + 10);
            break;
        case 'a': case 'A':
            autoDemo();
            break;
        }
    }
}
```

## 操作指南

- **S / 空格 / 回车**：开始排序当前算法
- **R / ESC**：重新打乱数组
- **← / →**：切换算法
- **A**：自动演示所有算法
- **+ / =**：加速动画
- **- / _**：减速动画
- **ESC（排序中）**：中断排序

## 技术亮点

1. **泛型设计**：使用 C++ 模板，所有算法统一接口
2. **STL 兼容**：自定义迭代器完全符合 STL 标准
3. **操作拦截**：通过运算符重载自动统计操作
4. **实时反馈**：每次操作都触发可视化更新
5. **跨平台文本**：通过宏定义支持中英文界面

## 性能分析

程序不仅可视化排序过程，还提供详细的性能数据：

| 算法 | 时间复杂度 | 空间复杂度 | 稳定性 |
|------|-----------|-----------|--------|
| 冒泡排序 | $O(n^2)$ | $O(1)$ | 稳定 |
| 选择排序 | $O(n^2)$ | $O(1)$ | 不稳定 |
| 插入排序 | $O(n^2)$ | $O(1)$ | 稳定 |
| 快速排序 | $O(n \log n)$ | $O(\log n)$ | 不稳定 |
| 归并排序 | $O(n \log n)$ | $O(n)$ | 稳定 |
| 堆排序 | $O(n \log n)$ | $O(1)$ | 不稳定 |
| 希尔排序 | $O(n^{1.3})$ | $O(1)$ | 不稳定 |
| 基数排序 | $O(d \cdot n)$ | $O(n + k)$ | 稳定 |
| 计数排序 | $O(n + k)$ | $O(k)$ | 稳定 |

## 教育价值

这个项目非常适合：
- **算法学习**：直观理解各种排序算法的工作原理
- **性能对比**：实时对比不同算法的效率差异
- **代码设计**：学习泛型编程、迭代器设计、运算符重载等 C++ 高级特性
- **可视化技术**：掌握如何将抽象算法转化为直观的图形展示

通过这个项目，你不仅能理解排序算法本身，还能学习如何优雅地设计可扩展的程序架构，以及如何利用 EGE 图形库实现专业的数据可视化效果。
