# service_content

高度可扩展的内容管理服务 - 支持文章、帖子、动态、视频等多种内容类型。

## 核心特性

### 1. 完全可扩展
- 通过 `Content.metadata` 存储自定义内容数据
- 通过 `ContentType.custom` 实现自定义内容类型
- 支持视频、链接、位置等多种富媒体

### 2. 内容类型
- **article** - 文章
- **post** - 帖子
- **moment** - 动态
- **video** - 视频
- **image** - 图片
- **audio** - 音频
- **link** - 链接分享
- **custom** - 自定义

### 3. 交互集成
- 点赞/收藏/分享（依赖 service_interaction）
- 评论/回复（依赖 service_comment）
- 浏览统计

## 使用示例

### 发布内容

```dart
// 普通文章
await service.createContent(
  authorId: 'user123',
  type: ContentType.article,
  title: 'Flutter 开发指南',
  content: '正文内容...',
);

// 图片动态
await service.createContent(
  authorId: 'user123',
  type: ContentType.moment,
  content: '分享图片',
  images: ['url1', 'url2'],
  topicIds: ['topic1'],
);
```

### 查询内容

```dart
// 获取最新内容
final result = await service.getContents(
  ContentQuery(sortType: ContentSortType.latest),
);

// 按话题查询
final result = await service.getContents(
  ContentQuery(topicId: 'topic123'),
);
```

## 扩展指南

### 添加自定义内容类型

```dart
await service.createContent(
  authorId: 'user123',
  type: ContentType.custom,
  content: '自定义内容',
  metadata: {
    'customType': 'live_stream',
    'streamUrl': 'rtmp://...',
  },
);
```
