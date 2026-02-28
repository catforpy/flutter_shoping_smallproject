# 四级嵌套 + 瀑布流 - 快速参考

## 🚀 30秒快速上手

### 1️⃣ 添加依赖
```yaml
flutter_staggered_grid_view: ^0.7.0
```

### 2️⃣ 复制3个核心类
- `FourLevelPage` - 四级页面
- `WaterfallContent` - 瀑布流内容
- `WaterfallCardItem` - 卡片数据

### 3️⃣ 修改3个数据列表
```dart
level1Items  // 顶部横向标签
level2Items  // 左侧纵向菜单
level3Items  // 内容区横向标签
```

---

## 🎯 核心代码片段

### 瀑布流布局（最重要）
```dart
MasonryGridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemBuilder: (context, index) => Card(...),
)
```

### 错落效果
```dart
final heightVariants = [140, 180, 220, 260, 300];  // 5种高度
final height = heightVariants[index % heightVariants.length];
final hasDescription = index % 3 == 0;  // 1/3有描述
```

### 避免溢出
```dart
Column(
  mainAxisSize: MainAxisSize.min,  // 关键！
  children: [
    Text(..., maxLines: 2, overflow: TextOverflow.ellipsis),
    Row(mainAxisSize: MainAxisSize.min),
  ],
)
```

### 导航
```dart
context.go('/$level1/$level2/$level3');
```

---

## 📁 文件清单

- ✅ `four_level_nested_routes.dart` - 完整实现
- ✅ `TEMPLATE_FOUR_LEVEL_NESTED_ROUTES.md` - 详细文档
- ✅ `QUICK_REFERENCE.md` - 本文件

---

## ⚡ 常用修改

| 需求 | 修改位置 |
|------|----------|
| 改列数 | `crossAxisCount: 2` |
| 改高度 | `heightVariants = [...]` |
| 改颜色 | `Colors.blue` → `Colors.red` |
| 改尺寸 | `height: 50` |
| 加图标 | 在卡片中添加 `Image.network()` |

---

**重要程度**: ⭐⭐⭐⭐⭐
**复用频率**: 极高
**适用场景**: 电商、社交、内容、媒体...
