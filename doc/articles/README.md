# EGE 示例程序文章集

本目录收录了 EGE 图形库示例程序的技术解析文章，旨在帮助开发者深入理解 EGE 的使用方法和编程技巧。

## 目录结构

```
doc/articles/
├── README.md                           # 本文件
├── .gitignore                          # 忽略生成的 html 目录
├── *.md                                # Markdown 格式的技术文章
└── html/                               # 自动生成的 HTML 文件（不纳入版本控制）
    └── *.html                          # WordPress 格式的 HTML 文章
```

## 文章列表

### 游戏类示例

- **[game_gomoku.md](game_gomoku.md)** - EGE 五子棋游戏实现解析
  - 双人/人机对战模式
  - 鼠标交互、音效反馈
  - AI 算法实现

### 算法可视化示例

- **[graph_astar_pathfinding.md](graph_astar_pathfinding.md)** - A* 寻路算法可视化
  - A* 启发式搜索算法
  - 实时可视化搜索过程
  - 交互式地图编辑

- **[graph_sort_visualization.md](graph_sort_visualization.md)** - 排序算法可视化
  - 多种经典排序算法对比
  - 实时动画展示排序过程
  - 性能统计分析

- **[graph_kmeans.md](graph_kmeans.md)** - K-means 聚类算法可视化
  - K-means 聚类算法原理
  - 交互式聚类过程演示
  - 参数调节与效果对比

### 数学与图形示例

- **[graph_function_visualization.md](graph_function_visualization.md)** - 数学函数可视化
  - 函数曲线绘制
  - 交互式参数调节
  - 实时图形更新

- **[graph_game_of_life.md](graph_game_of_life.md)** - 康威生命游戏
  - 元胞自动机原理
  - 交互式细胞编辑
  - 经典图案展示

## 文章特点

每篇文章都包含：
- 📖 **程序功能介绍** - 详细说明示例程序的功能和特性
- 🔧 **EGE 图形库应用** - 展示具体使用的 EGE API 和技术
- 💻 **关键代码解析** - 分析核心算法和实现思路
- 🎯 **实现要点** - 总结开发过程中的关键技术点
- 🖼️ **效果截图** - 程序运行的视觉效果展示

## 面向读者

这些文章适合：
- 🌱 **EGE 初学者** - 通过实例学习 EGE 图形编程
- 🎓 **算法学习者** - 理解算法原理并看到可视化效果
- 🎮 **游戏开发爱好者** - 学习简单游戏的实现方法
- 👨‍🏫 **教师和学生** - 作为图形编程和算法课程的参考资料

## 文章编写规范

Markdown 文章采用以下规范：
- 使用中文撰写，语言简洁易懂
- 代码块使用 ````cpp` 标记 C++ 代码
- 包含程序截图和效果演示
- 结构清晰：简介 → 特性 → 实现 → 总结
- 强调 EGE API 的使用方法和技巧

---

## HTML 转换说明

本目录的 Markdown 文章可以转换为适合发布到 WordPress 博客的 HTML 格式。

### 转换方式

使用父目录下的 `convert_articles.py` 脚本：

```bash
cd doc
python3 convert_articles.py
```

转换后的 HTML 文件将保存在 `html/` 子目录中。

### HTML 文件特性

- **纯静态内容**：不包含任何 JavaScript 代码
- **内联样式**：所有 CSS 样式都内联在 HTML 文件中
- **独立完整**：每个 HTML 文件都是完整的文档，可以直接在浏览器中查看
- **WordPress 优化**：代码块使用 `<pre class="lang:xxx decode:true">` 格式，兼容常见的语法高亮插件
- **开箱即用**：可直接将 body 内容复制到 WordPress 编辑器

### 如何发布到 WordPress

1. 运行转换脚本生成 HTML 文件
2. 在浏览器中打开生成的 HTML 文件
3. 在 WordPress 编辑器中切换到"文本"模式
4. 复制 HTML 中 `<body>` 标签内的内容并粘贴
5. 如需保留样式，可将 `<style>` 中的 CSS 添加到主题自定义 CSS（仅需一次）

详细使用说明请参考 `convert_articles.py` 脚本开头的文档注释。

---

## 贡献指南

欢迎为本文章集贡献内容！

### 添加新文章

1. 在本目录创建新的 `.md` 文件
2. 参考现有文章的结构和格式
3. 确保代码示例完整可运行
4. 添加程序截图和效果演示
5. 更新本 README 的文章列表

### 改进现有文章

- 修正技术错误或表述不清的地方
- 补充更多示例代码和说明
- 优化文章结构和可读性
- 更新过时的 API 用法

提交时请确保：
- Markdown 格式规范
- 代码块语法正确
- 链接和图片有效
- 内容准确无误
