# 业务服务实现总结

本文档总结了所有已实现的业务服务，这些服务都遵循**高度可扩展**的设计原则。

## 核心设计原则

### 1. 不要硬编码
- 使用枚举而非字符串
- 使用 `metadata` / `customFields` 存储扩展数据
- 预定义 `custom` 类型用于完全自定义

### 2. 通用性
- service_interaction 适用于所有领域的交互
- service_comment 适用于所有目标的评论
- 其他服务通过 TargetRef 引用目标

### 3. 类型安全
- 枚举类型提供编译时检查
- IDE 自动补全支持
- 减少 runtime 错误

## 已实现的服务

### 1. service_interaction - 通用交互服务

**位置**: `packages/services/service_interaction`

**核心功能**:
- 点赞/取消点赞
- 收藏/取消收藏
- 分享
- 自定义交互（打赏、举报等）

**关键模型**:
```dart
TargetRef        // 目标引用（类型 + ID）
InteractionType  // 交互类型（like, favorite, share, custom）
Interaction      // 交互记录
InteractionStats // 交互统计
```

**扩展方式**:
```dart
// 自定义交互 - 打赏
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

**依赖**: 无（最底层服务）

---

### 2. service_comment - 评论服务

**位置**: `packages/services/service_comment`

**核心功能**:
- 创建评论/回复
- 删除/编辑评论
- 点赞评论
- 评论查询（热门、最新、最早）

**关键模型**:
```dart
Comment            // 评论实体
CommentTree        // 评论树（层级结构）
CommentQuery       // 查询条件
CommentSortType    // 排序类型
```

**扩展方式**:
```dart
await service.createComment(
  userId: 'user123',
  target: TargetRef.content('content123'),
  content: '商品不错',
  metadata: {
    'images': ['url1', 'url2'],
    'rating': 5,  // 评分
  },
);
```

**依赖**: service_interaction（评论点赞）

---

### 3. service_content - 内容服务

**位置**: `packages/services/service_content`

**核心功能**:
- 发布内容（文章、帖子、动态、视频等）
- 内容管理（编辑、删除、发布）
- 内容查询（按作者、话题、关键字等）
- 交互集成（点赞、收藏、评论）

**关键模型**:
```dart
Content            // 内容实体
ContentType        // 内容类型（article, post, video, custom）
VideoInfo          // 视频信息
LinkInfo           // 链接信息
LocationInfo       // 位置信息
ContentQuery       // 查询条件
```

**扩展方式**:
```dart
await service.createContent(
  authorId: 'user123',
  type: ContentType.article,
  title: '标题',
  content: '正文',
  metadata: {
    'wordCount': 1000,
    'readTime': 5,
  },
);
```

**依赖**: 
- service_user（用户信息）
- service_interaction（交互功能）
- service_comment（评论功能）

---

### 4. service_commerce - 商城服务

**位置**: `packages/services/service_commerce`

**核心功能**:
- 商品管理（查询、搜索、分类）
- 购物车（添加、修改、删除）
- 订单管理（创建、查询、取消）

**关键模型**:
```dart
Product            // 商品实体
ProductType        // 商品类型（physical, virtual, custom）
ProductSku         // SKU（库存单位）
CartItem           // 购物车项
Order              // 订单实体
OrderStatus        // 订单状态
ShippingAddress    // 收货地址
```

**扩展方式**:
```dart
await service.createContent(
  // 商品类型可以是虚拟商品、服务等
  type: ProductType.custom,
  metadata: {
    'productSubType': 'course',
    'duration': 3600,
  },
);
```

**依赖**:
- service_user（卖家信息）
- service_interaction（商品点赞、收藏）

---

### 5. service_payment - 支付服务

**位置**: `packages/services/service_payment`

**核心功能**:
- 余额查询
- 充值（微信、支付宝等）
- 提现
- 交易记录查询

**关键模型**:
```dart
Transaction            // 交易记录
TransactionType        // 交易类型（recharge, purchase, custom）
TransactionStatus      // 交易状态
PaymentMethod          // 支付方式（wechat, alipay, custom）
RechargeConfig         // 充值配置
WithdrawInfo           // 提现信息
```

**扩展方式**:
```dart
// 自定义交易类型
Transaction(
  type: TransactionType.custom,
  metadata: {
    'action': 'exchange',
    'from': 'coin',
    'to': 'diamond',
  },
);
```

**依赖**:
- service_user（用户余额）
- service_commerce（订单支付）

---

## 服务依赖关系图

```
service_interaction (最底层)
    ↑
    ├── service_comment (评论点赞)
    │
    ├── service_content (内容交互)
    │
    └── service_commerce (商品交互)
           ↑
           └── service_payment (订单支付)
```

## 扩展接口总结

### TargetRef - 通用目标引用

所有服务都使用 `TargetRef` 来引用目标：

```dart
TargetRef.content('content123')
TargetRef.topic('topic123')
TargetRef.product('product123')
TargetRef.comment('comment123')
TargetRef.user('user123')
TargetRef.custom(id: 'xxx', metadata: {...})
```

### metadata / customFields 扩展模式

所有实体都支持通过 metadata 扩展：

```dart
// 用户扩展
UserAttributes.customFields

// 交互扩展
Interaction.metadata

// 评论扩展
Comment.metadata

// 内容扩展
Content.metadata

// 商品扩展
Product.metadata

// 交易扩展
Transaction.metadata
```

### 枚举 custom 扩展模式

所有枚举都有 custom 类型：

```dart
ContentType.custom
InteractionType.custom
ProductType.custom
TransactionType.custom
PaymentMethod.custom
```

## API 接口规范

所有服务遵循统一的 API 规范：

### 响应格式
```json
{
  "success": true,
  "data": {...},
  "message": "操作成功"
}
```

### 分页格式
```json
{
  "success": true,
  "data": {
    "items": [...],
    "total": 100
  }
}
```

### 错误处理
```dart
Result.success(data)
Result.failure(Exception('message'))
```

## 使用示例

### 完整的内容发布流程

```dart
// 1. 发布内容
final content = await contentService.createContent(
  authorId: 'user123',
  type: ContentType.article,
  title: '标题',
  content: '正文',
  topicIds: ['topic1'],
);

// 2. 用户点赞
await contentService.likeContent(
  userId: 'user456',
  contentId: content.value.id,
);

// 3. 用户评论
final comment = await contentService.createComment(
  userId: 'user456',
  contentId: content.value.id,
  commentContent: '评论内容',
);

// 4. 用户分享
await contentService.shareContent(
  userId: 'user456',
  contentId: content.value.id,
  channel: 'wechat',
);
```

### 完整的购物流程

```dart
// 1. 浏览商品
final products = await commerceService.getProducts(
  ProductQuery(keyword: '手机'),
);

// 2. 添加到购物车
await commerceService.addToCart(
  userId: 'user123',
  productId: products.data[0].id,
  quantity: 1,
);

// 3. 创建订单
final order = await commerceService.createOrder(
  userId: 'user123',
  cartItemIds: ['cart1'],
  shippingAddress: ShippingAddress(...),
);

// 4. 支付订单
final payment = await paymentService.createRecharge(
  userId: 'user123',
  configId: 'config1',
  paymentMethod: PaymentMethod.wechat,
);
```

## 下一步

剩余待实现的功能：

1. **service_im** - 即时通讯服务
   - 单聊
   - 群聊
   - 消息类型（文本、图片、语音、视频）

2. **UserRepository 实现** - service_user 的数据层

3. **UserProvider 实现** - service_user 的状态管理层

4. **文档完善** - 各服务的 README.md

## 注意事项

1. **所有服务都设计为可扩展**，通过 metadata 和 custom 类型实现
2. **不要硬编码业务逻辑**，使用扩展接口
3. **通用功能下沉**，如交互、评论
4. **保持接口一致性**，统一的 Result 返回和分页格式
