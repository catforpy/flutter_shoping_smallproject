# service_im

高度可扩展的即时通讯服务 - 支持单聊、群聊和多种消息类型。

## 核心特性

### 1. 完全可扩展的消息类型
- **文本消息** - 基础文本聊天
- **图片消息** - 发送图片
- **语音消息** - 发送语音
- **视频消息** - 发送视频
- **文件消息** - 发送文件
- **位置消息** - 发送位置
- **表情消息** - 发送表情
- **自定义消息** - 商品卡片、红包等任何自定义类型

### 2. 会话管理
- 单聊会话
- 群聊会话
- 会话置顶
- 会话免打扰
- 未读消息统计

### 3. 消息操作
- 发送/接收消息
- 撤回消息
- 删除消息
- 标记已读
- 引用回复

## 架构层次

```
┌─────────────────────────────────────────┐
│           UI Layer (Widget)              │
└─────────────────┬───────────────────────┘
                  │ 调用 Provider 方法
┌─────────────────▼───────────────────────┐
│      Provider Layer (MessageProvider)    │
│  - 管理会话列表                           │
│  - 管理消息列表                           │
│  - 调用 MessageService                     │
└─────────────────┬───────────────────────┘
                  │ 调用 Service 方法
┌─────────────────▼───────────────────────┐
│       Service Layer (MessageService)      │
│  - 业务逻辑                               │
│  - 调用 MessageRepository                   │
└─────────────────┬───────────────────────┘
                  │ 获取/保存数据
┌─────────────────▼───────────────────────┐
│    Repository Layer (MessageRepository)    │
│  - API 调用                               │
│  - 本地缓存                               │
└─────────────────────────────────────────┘
```

## 使用示例

### 1. 在 main.dart 中配置 Provider

```dart
// 创建 MessageProvider
final messageProvider = StateNotifierProvider<MessageProvider, ChatState>((ref) {
  return MessageProvider(
    ref.watch(messageServiceProvider),
    'currentUserId', // 从 auth provider 获取
  );
});
```

### 2. 在聊天页面中使用

```dart
class ChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(messageProvider);
    final chatNotifier = ref.read(messageProvider.notifier);

    return Column(
      children: [
        // 消息列表
        Expanded(
          child: ListView.builder(
            itemCount: chatState.messages.length,
            itemBuilder: (context, index) {
              final message = chatState.messages[index];
              return MessageBubble(message: message);
            },
          ),
        ),

        // 输入框
        MessageInput(
          onSend: (text) async {
            await chatNotifier.sendTextMessage(
              conversationId: 'conv123',
              text: text,
            );
          },
        ),
      ],
    );
  }
}
```

### 3. 发送各种类型的消息

```dart
final chatNotifier = ref.read(messageProvider.notifier);

// 发送文本消息
await chatNotifier.sendTextMessage(
  conversationId: 'conv123',
  text: '你好',
);

// 发送图片消息
await chatNotifier.sendImageMessage(
  conversationId: 'conv123',
  imageUrl: 'https://...',
  width: 1080,
  height: 1920,
);

// 发送语音消息
await chatNotifier.sendAudioMessage(
  conversationId: 'conv123',
  audioUrl: 'https://...',
  duration: 30,
);

// 发送位置消息
await chatNotifier.sendLocationMessage(
  conversationId: 'conv123',
  latitude: 39.9042,
  longitude: 116.4074,
  address: '北京市朝阳区',
);
```

### 4. 创建单聊会话

```dart
// 从用户列表点击后创建会话
final result = await chatNotifier.createSingleConversation(
  targetUserId: 'user456',
);

if (result.isSuccess) {
  final conversation = result.data;
  await chatNotifier.switchConversation(conversation);
}
```

### 5. 会话操作

```dart
// 置顶会话
await chatNotifier.pinConversation('conv123');

// 取消置顶
await chatNotifier.unpinConversation('conv123');

// 删除会话
await chatNotifier.deleteConversation('conv123');

// 标记已读
await chatNotifier.markAsRead('conv123');
```

## 消息类型扩展

### 自定义消息类型

```dart
// 商品卡片消息
await messageService.sendCustomMessage(
  conversationId: 'conv123',
  customData: {
    'type': 'product_card',
    'productId': 'product123',
    'name': '商品名称',
    'price': 9900,
    'image': 'https://...',
  },
);

// 订单卡片消息
await messageService.sendCustomMessage(
  conversationId: 'conv123',
  customData: {
    'type': 'order_card',
    'orderId': 'order123',
    'status': 'pending',
    'amount': 9900,
  },
);

// 红包消息
await messageService.sendCustomMessage(
  conversationId: 'conv123',
  customData: {
    'type': 'red_packet',
    'amount': 1000,
    'count': 10,
  },
);
```

## 消息模型说明

### Message 核心字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | String | 消息ID |
| `conversationId` | String | 会话ID |
| `senderId` | String | 发送者ID |
| `type` | MessageType | 消息类型 |
| `status` | MessageStatus | 消息状态 |
| `direction` | MessageDirection | 消息方向 |
| `text` | String? | 文本内容 |
| `image` | ImageContent? | 图片内容 |
| `audio` | AudioContent? | 语音内容 |
| `video` | VideoContent? | 视频内容 |
| `customData` | Map? | 自定义数据 |

### MessageType 枚举

```dart
MessageType.text     // 文本
MessageType.image     // 图片
MessageType.audio     // 语音
MessageType.video     // 视频
MessageType.file      // 文件
MessageType.location  // 位置
MessageType.emoji     // 表情
MessageType.system    // 系统
MessageType.custom    // 自定义
```

### MessageStatus 枚举

```dart
MessageStatus.sending    // 发送中
MessageStatus.sent       // 已发送
MessageStatus.delivered   // 已送达
MessageStatus.read       // 已读
MessageStatus.failed     // 失败
```

## 注意事项

1. **消息方向**: 通过 `direction` 区分发送/接收的消息
2. **扩展性**: 使用 `MessageType.custom` 和 `customData` 实现自定义消息
3. **状态管理**: 使用 Riverpod 进行响应式状态管理
4. **性能优化**: 消息列表使用分页加载
5. **已读回执**: 发送消息后需要等待已读回执更新状态
