# ExpandableGridPageView 组件

## 📦 依赖插件

- **expandable_page_view**: `^1.2.1`
  - 用于实现可自动调整高度的 PageView
  - 解决不同高度页面切换时的越界问题
  - 提供平滑的高度过渡动画

## 🎯 功能特性

- ✅ 类似轮播图的滑动效果
- ✅ 第一页显示 1 行内容（默认 5 个 + 半个预览）
- ✅ 第二页显示 3 行内容（默认 15 个 + "全部频道"）
- ✅ **高度自动调整**：切换页面时，组件高度自动平滑过渡
- ✅ **无越界警告**：使用 `ExpandablePageView` 插件，容器高度始终等于当前页面高度
- ✅ 组件高度变化会**推开下面的内容**（如瀑布流）
- ✅ 支持自定义 "全部频道" 入口
- ✅ 底部轮播指示点

## 🎨 使用示例

```dart
ExpandableGridPageView(
  // 子 widget 列表（分类图标 + 文字）
  children: [
    _buildCategoryItem('品质外卖', Icons.restaurant),
    _buildCategoryItem('新人福利', Icons.card_giftcard),
    _buildCategoryItem('签到', Icons.event_available),
    // ... 更多分类
  ],

  // 每行显示的 widget 数量（默认 5）
  crossAxisCount: 5,

  // 第一页显示的行数（默认 1）
  firstPageRows: 1,

  // 第二页显示的行数（默认 3）
  secondPageRows: 3,

  // 内边距和间距
  topPadding: 16,
  bottomPadding: 8,
  spacing: 8,          // 水平间距
  runSpacing: 16,      // 垂直间距

  // 点击回调
  onTap: (index) {
    print('点击了第 $index 个分类');
  },

  // "全部频道" 点击回调
  onMoreTap: () {
    print('查看全部频道');
  },

  // 是否显示底部指示点（默认 true）
  showIndicator: true,

  // 指示点颜色
  indicatorColor: Colors.grey,
  currentIndicatorColor: Colors.red,
)
```

## 🔧 构建分类 Item

```dart
Widget _buildCategoryItem(String title, IconData icon) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        size: 28,
        color: Colors.grey[700],
      ),
      const SizedBox(height: 6),
      Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
```

## 📐 高度计算

### 第一页高度
```
height = topPadding + (itemHeight × firstPageRows) + (runSpacing × (firstPageRows - 1)) + bottomPadding
       = 16 + (80 × 1) + (16 × 0) + 8
       = 104px
```

### 第二页高度
```
height = topPadding + (itemHeight × secondPageRows) + (runSpacing × (secondPageRows - 1)) + bottomPadding + indicatorHeight
       = 16 + (80 × 3) + (16 × 2) + 8 + 30
       = 326px
```

## 🚀 实际应用场景

### 首页布局
```dart
Column(
  children: [
    // 搜索框
    SearchBar(),

    // 横向滑动标签栏
    HorizontalTabs(...),

    // 可展开网格轮播组件
    ExpandableGridPageView(
      children: categories,
      crossAxisCount: 5,
      firstPageRows: 1,
      secondPageRows: 3,
    ),

    // 瀑布流商品列表（会被自动推开）
    WaterFallFlowList(),
  ],
)
```

### 动画效果
1. **第一页状态**：
   - 组件高度 = 104px（1 行）
   - 瀑布流占据剩余屏幕空间
   - 用户可以滚动查看瀑布流内容

2. **滑动到第二页**：
   - 组件高度平滑过渡到 326px（3 行）
   - 瀂布流被向下推开 222px
   - 用户仍可滚动查看瀑布流内容

3. **滑回第一页**：
   - 组件高度平滑过渡回 104px
   - 瀑布流自然上移
   - 用户体验流畅自然

## ⚙️ 核心技术点

### 1. 使用 ExpandablePageView 插件
```dart
ExpandablePageView(
  controller: _pageController,
  onPageChanged: (index) {
    setState(() {
      _currentPageIndex = index;
    });
  },
  children: [
    _buildFirstPage(),  // 高度 104px
    _buildSecondPage(), // 高度 326px
  ],
)
```

**优势：**
- ✅ 自动检测每个子页面的高度
- ✅ 容器高度自动等于当前显示页面的高度
- ✅ **完全避免越界警告**
- ✅ 内置平滑的高度过渡动画

### 2. 页面高度固定
```dart
// 第一页：固定高度
Container(
  height: _calculateFirstPageHeight(80), // 104px
  color: Colors.white,
  child: _buildGrid(displayWidgets, displayCount),
)

// 第二页：固定高度
Container(
  color: Colors.white,
  child: Column(
    children: [
      _buildGrid(displayWidgets, displayCount),
      if (showIndicator) _buildIndicator(), // +30px
    ],
  ),
)
```

### 3. 动画原理
- PageView 滚动时，`ExpandablePageView` 自动检测目标页面的高度
- 容器高度从当前页面高度平滑过渡到目标页面高度
- 下面的内容（如瀑布流）自然被推开或拉起
- **无需手动管理动画控制器**

## 🐛 常见问题

### Q: 为什么之前会有越界警告？
**A:** 之前使用普通 `PageView` + 手动动画控制时：
- 第一页高度 104px，第二页高度 326px
- 滚动过程中，容器高度可能在 200px，但第二页内容已经是 326px
- 导致内容被挤压 → **越界警告**

### Q: 为什么 ExpandablePageView 能解决？
**A:** `ExpandablePageView` 的工作原理：
- 容器高度**始终等于当前可见页面的高度**
- 滚动时，实时检测目标页面的高度，同步调整容器高度
- **容器永远不会小于内容高度** → **无越界**

### Q: 如何自定义动画时长和曲线？
**A:** 目前 `expandable_page_view` 插件使用默认动画配置。如需自定义，可以考虑：
- 使用 `linked_pageview` 插件（支持自定义动画参数）
- 或自行实现（参考方案 3 的同步动画逻辑）

## 📚 参考资料

- [expandable_page_view 插件文档](https://pub.dev/packages/expandable_page_view)
- [Flutter PageView 官方文档](https://api.flutter.dev/flutter/widgets/PageView-class.html)

## 📝 更新日志

### v1.2.0 (2024-03-01)
- ✨ 使用 `expandable_page_view` 插件替代手动动画控制
- 🐛 修复页面切换时的越界警告问题
- 🎨 优化高度动画的流畅度
- 📚 完善文档和使用示例

### v1.0.0 (2024-02-28)
- 🎉 初始版本
- ✨ 支持两页切换（1 行 / 3 行）
- ✨ 支持自定义行数、间距、样式
- ✨ 支持点击回调和 "全部频道" 入口
