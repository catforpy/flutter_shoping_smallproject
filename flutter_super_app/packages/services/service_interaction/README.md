# service_interaction

高度可扩展的通用交互服务 - 支持点赞、收藏、分享等交互，适用于所有业务领域。

## 核心特性

### 1. 完全可扩展
- 通过 `InteractionType.custom` 实现自定义交互类型
- 通过 `metadata` 存储任意扩展数据
- 适用于所有领域（内容、话题、商品、用户等）

### 2. 类型安全
- 使用枚举而非字符串
- 编译时类型检查
- IDE 自动补全

### 3. 通用性
- 一套接口适用于所有目标类型
- 减少代码重复
- 统一的交互模式

## 架构设计

### 核心模型

#### TargetRef - 目标引用
```dart
final class TargetRef {
  final TargetType type;      // 目标类型
  final String id;            // 目标ID
  final Map<String, dynamic>? metadata;  // 自定义元数据
}

// 使用示例
TargetRef.content('content123');
TargetRef.topic('topic123');
TargetRef.custom(
  id: 'course123',
  metadata: {'domain': 'course', 'subType': 'lesson'},
);
```

#### InteractionType - 交互类型
```dart
enum InteractionType {
  like,       // 点赞
  favorite,   // 收藏
  share,      // 分享
  dislike,    // 踩
  follow,     // 关注
  subscribe,  // 订阅
  report,     // 举报
  custom,     // 自定义
}
```

#### InteractionStats - 交互统计
```dart
final class InteractionStats {
  final TargetRef target;
  final int likeCount;
  final int favoriteCount;
  final int shareCount;
  final Map<String, bool>? currentUserInteractions;  // 当前用户状态
  final Map<String, dynamic>? customStats;           // 自定义统计
}
```

## 使用示例

### 基础交互

#### 点赞/取消点赞
```dart
final service = InteractionService(...);

// 点赞
await service.like(
  userId: 'user123',
  target: TargetRef.content('content123'),
);

// 取消点赞
await service.unlike(
  userId: 'user123',
  target: TargetRef.content('content123'),
);

// 切换点赞状态
final result = await service.toggleLike(
  userId: 'user123',
  target: TargetRef.content('content123'),
);
// result.value: true=已点赞, false=未点赞
```

#### 收藏/取消收藏
```dart
// 收藏
await service.favorite(
  userId: 'user123',
  target: TargetRef.topic('topic123'),
);

// 取消收藏
await service.unfavorite(
  userId: 'user123',
  target: TargetRef.topic('topic123'),
);
```

#### 分享
```dart
await service.share(
  userId: 'user123',
  target: TargetRef.content('content123'),
  channel: 'wechat',
  platform: 'timeline',
  customMessage: '推荐这个内容',
);
```

### 获取统计

#### 单个目标统计
```dart
final stats = await service.getStats(
  TargetRef.content('content123'),
);

print(stats.likeCount);        // 点赞数
print(stats.favoriteCount);    // 收藏数
print(stats.shareCount);       // 分享数
print(stats.isLiked);          // 当前用户是否点赞
print(stats.isFavorited);      // 当前用户是否收藏
```

#### 批量获取统计
```dart
final targets = [
  TargetRef.content('content1'),
  TargetRef.content('content2'),
  TargetRef.topic('topic1'),
];

final statsMap = await service.getBatchStats(targets);

statsMap.forEach((targetId, stats) {
  print('$targetId: ${stats.likeCount} 赞');
});
```

### 自定义交互

#### 打赏功能
```dart
await service.interact(
  userId: 'user123',
  target: TargetRef.content('content123'),
  type: InteractionType.custom,
  metadata: {
    'action': 'reward',
    'currency': 'coin',
    'amount': 100,
  },
);
```

#### 举报功能
```dart
await service.interact(
  userId: 'user123',
  target: TargetRef.content('content123'),
  type: InteractionType.report,
  metadata: {
    'reason': 'spam',
    'description': '垃圾内容',
  },
);
```

#### 查看用户交互记录
```dart
// 查看用户的点赞列表
final result = await service.getUserInteractions(
  userId: 'user123',
  type: InteractionType.like,
  page: 1,
  pageSize: 20,
);

// 查看谁点赞了这条内容
final result = await service.getTargetInteractions(
  target: TargetRef.content('content123'),
  type: InteractionType.like,
  page: 1,
  pageSize: 20,
);
```

### 批量操作

```dart
// 批量点赞
await service.batchLike(
  userId: 'user123',
  targets: [
    TargetRef.content('content1'),
    TargetRef.content('content2'),
    TargetRef.topic('topic1'),
  ],
);

// 批量收藏
await service.batchFavorite(
  userId: 'user123',
  targets: [...],
);
```

## 扩展指南

### 添加新的目标类型

```dart
// 1. 使用 custom 类型
final target = TargetRef.custom(
  id: 'course123',
  metadata: {
    'domain': 'course',
    'subType': 'lesson',
    'version': '2.0',
  },
);

// 2. 正常使用交互服务
await service.like(userId: 'user123', target: target);
```

### 添加新的交互类型

```dart
// 1. 使用 InteractionType.custom
await service.interact(
  userId: 'user123',
  target: TargetRef.content('content123'),
  type: InteractionType.custom,
  metadata: {
    'action': 'your_custom_action',
    'any_param': 'any_value',
  },
);
```

### 自定义统计字段

统计数据的 `customStats` 字段可以存储任意自定义统计：

```dart
// 后端返回时包含自定义统计
{
  "target": {...},
  "likeCount": 100,
  "customStats": {
    "reward_count": 150,           // 打赏次数
    "reward_total_amount": 15000,  // 打赏总额
    "view_count": 5000,            // 浏览次数
  }
}

// 前端读取
final rewardCount = stats.getCustomStat<int>('reward_count');
```

## API 接口说明

### 交互操作

- `POST /interactions/like` - 点赞
- `POST /interactions/unlike` - 取消点赞
- `POST /interactions/favorite` - 收藏
- `POST /interactions/unfavorite` - 取消收藏
- `POST /interactions/share` - 分享

### 统计查询

- `GET /interactions/stats` - 获取单个目标统计
- `POST /interactions/stats/batch` - 批量获取统计

### 交互记录

- `GET /interactions/user/:userId` - 获取用户交互列表
- `GET /interactions/target` - 获取目标交互列表

## 数据流

```
UI/Provider
    ↓
InteractionService
    ↓
InteractionRepository (接口)
    ↓
ApiClient → 后端 API
    ↓
返回 Result<T>
```

## 与其他服务的关系

```
service_interaction (通用交互)
    ↑           ↑           ↑
service_content  service_commerce  service_user
    |             |                |
  内容交互        商品交互          用户交互
```

所有需要点赞、收藏、分享等功能的模块都依赖 service_interaction。

## 注意事项

1. **不要硬编码交互类型** - 使用枚举或 custom
2. **使用 metadata 存储扩展数据** - 不要修改核心模型
3. **批量操作优化性能** - 列表页面优先使用批量接口
4. **统计数据的 customStats** - 用于自定义统计维度
