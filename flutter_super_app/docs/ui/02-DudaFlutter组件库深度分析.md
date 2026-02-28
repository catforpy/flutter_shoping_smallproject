# DudaFlutter/common 组件库深度分析

## 核心设计模式总结

### 1. 扩展方法模式 (widget_extensions.dart)

**设计理念**：链式调用简化 Flutter UI 代码

```dart
// 传统写法
Padding(
  padding: EdgeInsets.all(16),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: GestureDetector(
      onTap: () {},
      child: Text('Hello'),
    ),
  ),
)

// 使用扩展方法
Text('Hello')
  .padding(all: 16)
  .borderRadius(all: 8)
  .onTap(() {})
```

**核心优势**：
- ✅ 代码可读性大幅提升
- ✅ 嵌套层级可视化
- ✅ 减少大量样板代码
- ✅ IDE 支持链式调用提示

**已实现的扩展方法**：
| 方法 | 说明 | 参数 |
|------|------|------|
| `padding()` | 内边距 | all, horizontal, vertical, top, bottom, left, right |
| `opacity()` | 透明度 | opacity (0-1) |
| `backgroundColor()` | 背景色 | color |
| `borderRadius()` | 圆角 | all, topLeft, topRight, bottomLeft, bottomRight |
| `border()` | 边框 | all, left, right, top, bottom, color |
| `boxShadow()` | 阴影 | color, offset, blurRadius, spreadRadius |
| `width()`/`height()`/`size()` | 尺寸 | 宽/高/宽高 |
| `scrollable()` | 滚动 | scrollDirection, controller |
| `expanded()` | 占满空间 | flex |
| `center()` | 居中 | - |
| `card()` | 卡片样式 | color, elevation, margin |
| `clipRRect()` | 圆角裁剪 | all, topLeft... |
| `safeArea()` | 避开系统UI | top, bottom, left, right |
| `positioned()` | Stack定位 | left, top, right, bottom, width, height |
| `aspectRatio()` | 宽高比 | aspectRatio |

**List 扩展**：
```dart
[
  Text('Item 1'),
  Text('Item 2'),
].toColumn(
  mainAxisAlignment: MainAxisAlignment.center,
)
```

---

### 2. 动画组件模式 (animations/)

#### 核心架构

```
ControlledAnimation (控制器)
    ↓
MultiTrackTween (多轨道动画)
    ↓
Track (单个轨道)
    ↓
Tween (补间动画)
```

#### ControlledAnimation - 通用动画控制器

**核心特性**：
- 内置 AnimationController 管理
- 支持多种播放模式
- 支持延迟启动
- 支持动画曲线
- 支持状态监听

**播放模式 (Playback)**：
```dart
enum Playback {
  PAUSE,              // 暂停
  PLAY_FORWARD,       // 向前播放
  PLAY_REVERSE,       // 向后播放
  START_OVER_FORWARD, // 从头开始向前播放
  START_OVER_REVERSE, // 从尾开始向后播放
  LOOP,              // 循环
  MIRROR,            // 来回镜像
}
```

**使用示例**：
```dart
ControlledAnimation(
  playback: Playback.PLAY_FORWARD,
  duration: Duration(milliseconds: 500),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value) {
    return Opacity(opacity: value, child: ...);
  },
)
```

#### MultiTrackTween - 多轨道动画系统

**核心特性**：
- 同时控制多个属性动画
- 支持不同属性不同时长
- 支持每个属性独立的曲线
- 自动计算总时长

**使用示例**：
```dart
final tween = MultiTrackTween([
  Track("opacity")
    .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0))
    .add(Duration(milliseconds: 500), Tween(begin: 1.0, end: 0.5)),
  Track("translateX")
    .add(Duration(milliseconds: 1000), Tween(begin: 120.0, end: 0.0),
         curve: Curves.easeOut),
]);

ControlledAnimation(
  duration: tween.duration,
  tween: tween,
  builder: (context, animation) {
    return Opacity(
      opacity: animation['opacity'],
      child: Transform.translate(
        offset: Offset(animation['translateX'], 0),
        child: ...,
      ),
    );
  },
)
```

#### 封装的动画组件

**1. FadeAnimation - 淡入淡出动画**
```dart
FadeAnimation(
  delay: 1.0,  // 延迟倍数
  child: Text('Hello'),
)
```

**2. ShakeAnimation - 抖动动画**
```dart
final key = GlobalKey<ShakeAnimationState>();

ShakeAnimation(
  key: key,
  shakeIntensity: 5.0,
  duration: Duration(milliseconds: 300),
  child: Text('Shake me'),
)

// 触发抖动
key.currentState.triggerShake();
```

**3. NumberRollingAnimation - 数字滚动**
```dart
NumberRollingAnimation(
  targetNumber: 9999,
  animationDuration: Duration(milliseconds: 800),
  textStyle: TextStyle(fontSize: 20),
)
```

---

### 3. 可展开内容模式 (expandable_content.dart)

**核心特性**：
- 展开/收起动画
- 自定义标题区域
- 自定义信息区域
- 可配置动画时长
- 可配置最大行数

**使用示例**：
```dart
ExpandableContent(
  title: '商家名称',
  expandText: '这里是详细描述...',
  collapseMaxLines: 1,
  titleRightWidget: Icon(Icons.expand_more),
  infoWidget: Text('自定义信息区域'),
  titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  animationDuration: Duration(milliseconds: 200),
)
```

---

### 4. Sticky 吸顶组件模式 (common_sticky/)

#### 核心架构

```
SliverPersistentHeader (Flutter 内置)
    ↓
SliverPersistentHeaderDelegate (代理)
    ↓
BasicStickyDelegate (基础实现)
```

#### StickyBasicHeader - 单个吸顶

**使用示例**：
```dart
StickyBasicHeader(
  headerChild: Text('吸顶标题'),
  headerHeight: 50,
  backgroundColor: Colors.white,
  sliverChildren: [
    SliverList(delegate: ...),
    SliverGrid(delegate: ...),
  ],
)
```

#### StickyMultiHeaderList - 多分区吸顶

**使用场景**：联系人列表、商品分类、多话题内容

**使用示例**：
```dart
StickyMultiHeaderList(
  sections: [
    StickySectionModel(key: 'A', title: 'A', itemCount: 5),
    StickySectionModel(key: 'B', title: 'B', itemCount: 8),
    StickySectionModel(key: 'C', title: 'C', itemCount: 3),
  ],
  headerHeight: 40,
  headerBackgroundColor: Colors.grey[200],
  itemBuilder: (context, sectionKey, index) {
    return ListTile(title: Text('Item $sectionKey-$index'));
  },
)
```

---

## 设计模式总结

### 1. 组件封装原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **配置化** | 所有样式外部传入 | titleStyle, expandTextStyle |
| **可选化** | 非核心功能使用可选参数 | titleRightWidget?, infoWidget? |
| **组合化** | 支持自定义 Widget 替换固定部分 | infoWidget 替代固定信息区域 |
| **动画化** | 默认提供流畅动画 | animationDuration 可配置 |

### 2. 代码复用策略

```
基础层 (extensions)  ←  最底层，纯工具方法
    ↓
组件层 (components)  ←  基于扩展方法封装
    ↓
业务层 (pages)       ←  组合组件构建页面
```

### 3. 动画设计思路

**问题**：Flutter 动画代码复杂
**解决**：三层封装

```
ControlledAnimation (控制器层)
    ↓ 简化播放状态管理
MultiTrackTween (编排层)
    ↓ 简化多属性动画
具体动画组件 (应用层)
    ↓ 直接业务使用
```

---

## 我们需要借鉴的组件

### 优先级 P0 - 立即实现

| 组件 | 说明 | 文件 |
|------|------|------|
| **ExpandableContent** | 可展开内容 | expandable_content.dart |
| **StickyMultiHeaderList** | 多分区吸顶列表 | sticky_multi_header_list.dart |

### 优先级 P1 - 近期实现

| 组件 | 说明 | 文件 |
|------|------|------|
| **ControlledAnimation** | 动画控制器 | controlled_animation.dart |
| **MultiTrackTween** | 多轨道动画 | multi_track_tween.dart |
| **ShakeAnimation** | 抖动动画 | shake_animation.dart |
| **NumberRollingAnimation** | 数字滚动 | number_rolling_animation.dart |
| **FadeAnimation** | 淡入淡出 | FadeAnimation.dart |

### 优先级 P2 - 按需实现

- StickyGradientHeader (渐变吸顶)
- 自定义扩展方法 (参考 DudaFlutter)

---

## 实现计划

### 第一阶段：核心动画系统

1. ✅ 创建 ui_extensions 包 (已完成)
2. ⏳ 实现 ControlledAnimation
3. ⏳ 实现 MultiTrackTween
4. ⏳ 实现 ShakeAnimation
5. ⏳ 实现 NumberRollingAnimation
6. ⏳ 实现 FadeAnimation

### 第二阶段：常用组件

1. ⏳ 实现 ExpandableContent
2. ⏳ 实现 StickyMultiHeaderList
3. ⏳ 实现更多 Widget 扩展方法

### 第三阶段：业务组件

1. ⏳ 横向滑动标签 (已完成)
2. ⏳ 卡片组件
3. ⏳ 列表组件

---

## 是否现在开始实现？

我建议现在实现以下几个核心组件：

1. **ExpandableContent** - 可展开内容（使用频率高）
2. **ControlledAnimation** + **MultiTrackTween** - 动画系统（基础能力）
3. **ShakeAnimation** - 抖动动画（常用交互反馈）

是否开始实现？
