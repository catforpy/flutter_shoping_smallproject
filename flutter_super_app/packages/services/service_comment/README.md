# service_comment

高度可扩展的评论服务 - 支持评论和回复，适用于所有业务领域。

## 核心特性

### 1. 完全可扩展
- 通过 `Comment.metadata` 存储自定义评论数据
- 支持图片评论、语音评论、评分评论等
- 适用于所有领域（内容、话题、商品等）

### 2. 多级回复
- 支持无限层级的回复结构
- 深度控制
- @提醒功能

### 3. 丰富的查询
- 热门排序（按点赞数+回复数）
- 最新排序
- 最早排序
- 只看作者

## 架构设计

### 核心模型

#### Comment - 评论实体
```dart
final class Comment {
  final String id;
  final TargetRef target;           // 评论所属的目标
  final String userId;
  final String content;
  final String? parentId;           // 父评论ID
  final String? replyToUserId;      // 回复给的用户
  final int depth;                  // 层级深度
  final int likeCount;
  final int replyCount;
  final Map<String, dynamic>? metadata;  // 自定义数据
  final DateTime createdAt;
}
```

### metadata 扩展示例

#### 图片评论
```dart
metadata: {
  'images': ['https://...', 'https://...'],
}
```

#### 语音评论
```dart
metadata: {
  'audio': {
    'url': 'https://...',
    'duration': 30,
  },
}
```

#### 评分评论
```dart
metadata: {
  'rating': 5,  // 1-5 星
}
```

#### 附加数据
```dart
metadata: {
  'productId': 'xxx',
  'order': true,  // 购买过的用户
}
```

## 使用示例

### 发布评论

#### 普通评论
```dart
final service = CommentService(...);

await service.createComment(
  userId: 'user123',
  target: TargetRef.content('content123'),
  content: '这是我的评论',
);
```

#### 图片评论
```dart
await service.createComment(
  userId: 'user123',
  target: TargetRef.product('product123'),
  content: '商品不错',
  metadata: {
    'images': ['url1', 'url2'],
    'rating': 5,
  },
);
```

#### 回复评论
```dart
await service.createComment(
  userId: 'user123',
  target: TargetRef.content('content123'),
  content: '同意你的观点',
  parentId: 'comment456',
  replyToUserId: 'user789',  // @提醒
);
```

### 回复评论（便捷方法）
```dart
await service.replyComment(
  userId: 'user123',
  commentId: 'comment456',
  content: '同意你的观点',
  replyToUserId: 'user789',
);
```

### 查询评论

#### 获取热门评论
```dart
final result = await service.getComments(
  CommentQuery(
    target: TargetRef.content('content123'),
    sortType: CommentSortType.hot,
  ),
);
```

#### 获取最新评论
```dart
final result = await service.getComments(
  CommentQuery(
    target: TargetRef.content('content123'),
    sortType: CommentSortType.latest,
  ),
);
```

#### 只看作者的评论
```dart
final result = await service.getComments(
  CommentQuery(
    target: TargetRef.content('content123'),
    authorUserId: 'author123',
  ),
);
```

### 获取回复
```dart
final result = await service.getReplies(
  commentId: 'comment456',
  page: 1,
  pageSize: 20,
);
```

### 点赞评论
```dart
await service.likeComment(
  userId: 'user123',
  commentId: 'comment456',
);
```

### 删除评论
```dart
await service.deleteComment('comment456');
```

### 编辑评论
```dart
await service.updateComment(
  commentId: 'comment456',
  content: '修改后的内容',
);
```

### 用户相关

#### 获取用户的评论列表
```dart
final result = await service.getUserComments(
  userId: 'user123',
  page: 1,
  pageSize: 20,
);
```

#### 获取用户收到的回复
```dart
final result = await service.getUserReplies(
  userId: 'user123',
  page: 1,
  pageSize: 20,
);
```

### 批量操作

```dart
// 批量删除
await service.batchDeleteComments(['id1', 'id2', 'id3']);

// 批量点赞
await service.batchLikeComments(
  userId: 'user123',
  commentIds: ['id1', 'id2', 'id3'],
);
```

## API 接口说明

### 评论操作

- `POST /comments` - 创建评论
- `POST /comments/:id/reply` - 回复评论
- `PUT /comments/:id` - 更新评论
- `DELETE /comments/:id` - 删除评论

### 点赞操作

- `POST /comments/:id/like` - 点赞评论
- `POST /comments/:id/unlike` - 取消点赞

### 查询操作

- `GET /comments` - 获取评论列表
- `GET /comments/:id` - 获取评论详情
- `GET /comments/:id/replies` - 获取回复列表

### 用户相关

- `GET /comments/user/:userId` - 获取用户的评论
- `GET /comments/user/:userId/replies` - 获取用户收到的回复

## 扩展指南

### 添加新的评论类型

使用 `metadata` 字段存储自定义数据：

```dart
// 表情评论
await service.createComment(
  userId: 'user123',
  target: TargetRef.content('content123'),
  content: '👍',
  metadata: {
    'emoji': '👍',
    'type': 'emoji',
  },
);

// 视频评论
await service.createComment(
  userId: 'user123',
  target: TargetRef.content('content123'),
  content: '视频回复',
  metadata: {
    'video': {
      'url': 'https://...',
      'thumbnail': 'https://...',
      'duration': 60,
    },
  },
);
```

### 评论状态管理

```dart
enum CommentStatus {
  normal,    // 正常
  pending,   // 待审核
  rejected,  // 已拒绝
  deleted,   // 已删除
  hidden,    // 已隐藏
}
```

### 评论树构建

使用 `CommentTree` 模型构建层级结构：

```dart
final tree = CommentTree(
  root: rootComment,
  replies: [reply1, reply2, reply3],
  isExpanded: false,
  hasLoadedAll: false,
);
```

## 与其他服务的关系

```
service_comment (评论服务)
    ↓ 依赖
service_interaction (交互服务) - 用于评论点赞
```

评论点赞可以使用 service_interaction 的通用点赞功能，也可以使用评论服务专门的点赞接口。

## 注意事项

1. **不要硬编码评论类型** - 使用 metadata 扩展
2. **控制回复深度** - 避免无限层级
3. **评论内容审核** - 使用 CommentStatus 管理状态
4. **@提醒功能** - 使用 replyToUserId 实现
