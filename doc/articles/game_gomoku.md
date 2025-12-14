# EGE 五子棋游戏实现解析

## 游戏简介

五子棋是一种起源于中国的传统棋类游戏，规则简单却变化丰富。游戏使用15×15的棋盘，两名玩家分别执黑子和白子，黑方先行。玩家轮流在棋盘交叉点落子，率先在横、竖、斜任意方向形成连续五子者获胜。

本游戏采用无禁手规则，即不对黑方施加"三三禁手"、"四四禁手"等限制，适合初学者快速上手，也便于程序实现和 AI 对战。

![五子棋游戏截图](https://xege.org/wp-content/uploads/2025/06/image.png)

## 游戏特性

- **双人对战模式**：支持两名玩家在同一设备上对弈
- **人机对战模式**：内置简单 AI，可与电脑对弈
- **先后手切换**：在 AI 模式下可通过 R 键切换先手
- **音效反馈**：黑白棋子落子时有不同音高的音效提示
- **视觉反馈**：最后落子位置会有高亮标记，便于追踪对局进展

## EGE 图形库能力应用

本游戏是 EGE 图形库功能的综合展示，主要使用了以下特性：

### 1. 基础图形绘制

```cpp
// 绘制棋盘线条
setcolor(ege::BLACK);
setlinestyle(PS_SOLID, 2);
for (int i = 0; i < BOARD_SIZE; i++) {
    int y = BOARD_OFFSET_Y + i * CELL_SIZE;
    line(BOARD_OFFSET_X, y, BOARD_OFFSET_X + (BOARD_SIZE - 1) * CELL_SIZE, y);
}
```

使用 `line()` 函数绘制棋盘网格，`setcolor()` 和 `setlinestyle()` 控制线条样式。

### 2. 抗锯齿圆形绘制

```cpp
ege_enable_aa(true);
ege_fillcircle(x, y, CELL_SIZE / 2 - 2);
ege_circle(x, y, CELL_SIZE / 2 - 2);
ege_enable_aa(false);
```

启用抗锯齿后，使用 `ege_fillcircle()` 和 `ege_circle()` 绘制平滑的棋子，视觉效果更加美观。

### 3. 鼠标交互

```cpp
while (mousemsg()) {
    mouse_msg msg = getmouse();
    if (msg.is_down() && msg.is_left()) {
        game.handleMouseClick(msg.x, msg.y);
    }
}
```

通过 `mousemsg()` 和 `getmouse()` 捕获鼠标事件，将屏幕坐标转换为棋盘坐标：

```cpp
bool mouseToBoard(int mouseX, int mouseY, int& row, int& col) {
    int x = mouseX - BOARD_OFFSET_X;
    int y = mouseY - BOARD_OFFSET_Y;
    col = (x + CELL_SIZE / 2) / CELL_SIZE;
    row = (y + CELL_SIZE / 2) / CELL_SIZE;
    
    // 检查点击是否在交叉点附近
    int actualX = col * CELL_SIZE;
    int actualY = row * CELL_SIZE;
    int dx = x - actualX;
    int dy = y - actualY;
    
    return (dx * dx + dy * dy <= (CELL_SIZE / 2) * (CELL_SIZE / 2));
}
```

这段代码通过距离公式确保只有点击交叉点附近才有效。

### 4. 键盘输入

```cpp
if (kbhit()) {
    int key = getch();
    if (key == 27) {           // ESC 退出
        break;
    } else if (key == 'r' || key == 'R') {  // R 重新开始
        game.restartGame();
    } else if (key == 'm' || key == 'M') {  // M 切换模式
        game.toggleMode();
    }
}
```

使用 `kbhit()` 和 `getch()` 实现键盘控制。

### 5. 图像缓存与半透明效果

```cpp
m_gameEndImage = newimage(bgWidth, bgHeight);
settarget(m_gameEndImage);
// ... 绘制内容 ...
ege_setalpha(0xa0, m_gameEndImage);
settarget(nullptr);

// 显示时使用
putimage_withalpha(nullptr, m_gameEndImage, m_imgX, m_imgY);
```

将游戏结束画面预先绘制到图像对象，设置半透明效果，提升性能和视觉体验。

## 双人对战实现

双人对战模式的实现相对简单，核心是玩家轮流落子：

```cpp
void makeMove(int row, int col) {
    if (placePiece(row, col, m_currentPlayer)) {
        if (checkWin(row, col, m_currentPlayer)) {
            m_gameState = (m_currentPlayer == BLACK_PIECE) ? BLACK_WIN : WHITE_WIN;
        } else if (isBoardFull()) {
            m_gameState = DRAW;
        } else {
            // 切换玩家
            m_currentPlayer = (m_currentPlayer == BLACK_PIECE) ? WHITE_PIECE : BLACK_PIECE;
        }
    }
}
```

每次落子后检查胜负，如果游戏继续则切换当前玩家。胜负判定使用方向搜索算法：

```cpp
bool checkWin(int row, int col, PieceType piece) {
    // 四个方向：水平、垂直、主对角线、副对角线
    int directions[4][2] = {{0, 1}, {1, 0}, {1, 1}, {1, -1}};
    
    for (int dir = 0; dir < 4; dir++) {
        int count = 1;
        int dr = directions[dir][0];
        int dc = directions[dir][1];
        
        // 正反方向统计连续棋子数
        int r = row + dr, c = col + dc;
        while (r >= 0 && r < BOARD_SIZE && c >= 0 && c < BOARD_SIZE 
               && m_board[r][c] == piece) {
            count++;
            r += dr;
            c += dc;
        }
        
        r = row - dr, c = col - dc;
        while (r >= 0 && r < BOARD_SIZE && c >= 0 && c < BOARD_SIZE 
               && m_board[r][c] == piece) {
            count++;
            r -= dr;
            c -= dc;
        }
        
        if (count >= 5) return true;
    }
    return false;
}
```

这个算法对每个落子位置检查四个方向，统计连续同色棋子数量。

## 人机对战 AI 算法

本游戏采用了基于位置评估的启发式算法，虽然不如 Alpha-Beta 剪枝等高级算法强大，但足以提供有趣的对战体验。

### AI 决策流程

```cpp
void aiMove() {
    int bestRow = -1, bestCol = -1;
    int bestScore = -1000;
    
    // 遍历所有空位，评估每个位置的得分
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            if (m_board[i][j] == EMPTY) {
                int score = evaluatePosition(i, j);
                if (score > bestScore) {
                    bestScore = score;
                    bestRow = i;
                    bestCol = j;
                }
            }
        }
    }
    
    if (bestRow != -1 && bestCol != -1) {
        makeMove(bestRow, bestCol);
    }
}
```

AI 遍历棋盘所有空位，选择评分最高的位置落子。

### 位置评估算法

评估函数综合考虑三个因素：

1. **位置价值**：靠近中心的位置得分更高
   ```cpp
   int centerRow = BOARD_SIZE / 2;
   int centerCol = BOARD_SIZE / 2;
   int distanceFromCenter = abs(row - centerRow) + abs(col - centerCol);
   score += (BOARD_SIZE - distanceFromCenter);
   ```

2. **进攻价值**：评估该位置能形成的己方连珠
   ```cpp
   score += evaluateDirection(row, col, aiPiece) * 10;
   ```

3. **防守价值**：评估该位置能阻止的对手连珠
   ```cpp
   score += evaluateDirection(row, col, humanPiece) * 8;
   ```

### 方向评估算法

```cpp
int evaluateDirection(int row, int col, PieceType piece) {
    int score = 0;
    int directions[4][2] = {{0, 1}, {1, 0}, {1, 1}, {1, -1}};
    
    for (int dir = 0; dir < 4; dir++) {
        int count = 0;
        bool blocked = false;
        
        // 正反两个方向统计连续棋子
        // ... 统计逻辑 ...
        
        // 根据连子数量给分
        if (count >= 4) {
            score += 1000;  // 四连，极其重要
        } else if (count >= 3) {
            score += blocked ? 5 : 50;  // 三连，活三价值更高
        } else if (count >= 2) {
            score += blocked ? 2 : 10;   // 二连
        }
    }
    return score;
}
```

该算法对每个方向统计能形成的连珠数量，连子越多得分越高，活棋（未被封堵）价值更高。

## 音效系统实现

游戏使用 Windows MIDI API 实现音效，为黑白棋子设计了不同音高的落子音效：

```cpp
void playPieceSound(PieceType piece) {
    // 设置音色为木琴(Xylophone)，编号13
    DWORD msg = 0xC000 | 13;
    midiOutShortMsg(m_device, msg);
    
    if (piece == BLACK_PIECE) {
        // 黑子使用较低沉的G4音符(MIDI编号45)
        midiOutShortMsg(m_device, 0x90 | (MIDI_BLACK << 8) | (80 << 16));
    } else if (piece == WHITE_PIECE) {
        // 白子使用较清脆的C5音符(MIDI编号57)
        midiOutShortMsg(m_device, 0x90 | (MIDI_WHITE << 8) | (80 << 16));
    }
}
```

黑子使用 G4 音符，白子使用 C5 音符，两者形成完美四度音程，听感舒适且易于区分。音效播放后会在约20帧后自动停止，避免声音延续过长。

## 游戏操作指南

- **鼠标左键**：点击棋盘交叉点落子
- **ESC 键**：退出游戏
- **R 键**：重新开始游戏（AI模式下会切换先后手）
- **M 键**：切换双人/人机对战模式

在人机对战模式下，玩家可以通过按 R 键来切换先后手，体验执黑或执白的不同策略。

## 技术亮点总结

1. **坐标转换公式**：屏幕坐标到棋盘逻辑坐标的精确转换，使用距离公式确保点击精度
2. **胜负判定算法**：四方向扫描，时间复杂度 O(1)，每次只检查落子点周围
3. **AI评估函数**：平衡攻守的启发式算法，权重系数经过调优（进攻×10，防守×8）
4. **视觉优化**：使用抗锯齿、图像缓存、半透明效果提升渲染质量
5. **跨平台兼容**：通过宏定义实现 MSVC 和非 MSVC 编译器的兼容性

这个五子棋游戏虽然规模不大，但麻雀虽小五脏俱全，展示了 EGE 图形库在游戏开发中的实用性和便捷性，是学习图形编程和游戏开发的优秀范例。
