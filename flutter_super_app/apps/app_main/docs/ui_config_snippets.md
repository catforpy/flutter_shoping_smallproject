# UI 配置片段文档

> 用于保存不同 UI 风格的配置代码，方便快速切换和调试

---

## 首页 - 横向滑动标签栏配置

### 方案 1：蓝色主题（默认）

```dart
/// 构建横向滑动标签栏
Widget _buildHorizontalTabs() {
  return HorizontalTabs(
    tabs: _tabs, // 传入标签列表配置
    currentIndex: _currentIndex, // 当前选中的标签索引
    onTap: _onTabTap, // 标签点击事件处理
    pinnedTabIndex: 1, // 关注标签吸附（索引1的标签固定在左侧）
    height: 40, // 标签栏高度
    spacing: 12, // 标签之间的间距
    selectedColor: Colors.blue, // 选中标签的文字颜色
    unselectedColor: Colors.grey[600], // 未选中标签的文字颜色
    selectedBackgroundColor: Colors.blue.shade50, // 选中标签的背景色
  );
}
```

**效果**：蓝色主题，"关注"标签吸附

---

### 方案 2：红色主题

```dart
/// 构建横向滑动标签栏
Widget _buildHorizontalTabs() {
  return HorizontalTabs(
    tabs: _tabs,
    currentIndex: _currentIndex,
    onTap: _onTabTap,
    pinnedTabIndex: 0, // 推荐标签吸附
    height: 44,
    spacing: 16,
    selectedColor: Colors.red,
    unselectedColor: Colors.grey[600],
    selectedBackgroundColor: Colors.red.shade50,
  );
}
```

**效果**：红色主题，"推荐"标签吸附

---

### 方案 3：黑色主题（简约）

```dart
/// 构建横向滑动标签栏
Widget _buildHorizontalTabs() {
  return HorizontalTabs(
    tabs: _tabs,
    currentIndex: _currentIndex,
    onTap: _onTabTap,
    pinnedTabIndex: null, // 无吸附标签
    height: 36,
    spacing: 20,
    selectedColor: Colors.black,
    unselectedColor: Colors.grey,
    selectedBackgroundColor: Colors.grey.shade200,
  );
}
```

**效果**：黑色主题，无吸附标签

---

### 方案 4：绿色主题

```dart
/// 构建横向滑动标签栏
Widget _buildHorizontalTabs() {
  return HorizontalTabs(
    tabs: _tabs,
    currentIndex: _currentIndex,
    onTap: _onTabTap,
    pinnedTabIndex: 2, // 热门标签吸附
    height: 48,
    spacing: 10,
    selectedColor: Colors.green,
    unselectedColor: Colors.grey[600],
    selectedBackgroundColor: Colors.green.shade50,
  );
}
```

**效果**：绿色主题，"热门"标签吸附

---

## 使用方法

1. **保存配置**：调试好一种样式后，将 `_buildHorizontalTabs()` 函数代码复制到本文档
2. **切换配置**：从本文档复制对应的代码，替换 `home_page.dart` 中的 `_buildHorizontalTabs()` 函数
3. **记录修改日期**：在每个方案后面标注调试日期和效果说明

---

## 配置参数说明

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `tabs` | 标签列表 | `_tabs` |
| `currentIndex` | 当前选中索引 | `_currentIndex` |
| `onTap` | 点击事件 | `_onTabTap` |
| `pinnedTabIndex` | 吸附标签索引 | `0` / `1` / `null` |
| `height` | 标签栏高度 | `40` |
| `spacing` | 标签间距 | `12` |
| `selectedColor` | 选中文字颜色 | `Colors.blue` |
| `unselectedColor` | 未选中文字颜色 | `Colors.grey[600]` |
| `selectedBackgroundColor` | 选中背景色 | `Colors.blue.shade50` |
