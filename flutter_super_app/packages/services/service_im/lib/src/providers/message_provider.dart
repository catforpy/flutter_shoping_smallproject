library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_base/core_base.dart';
import 'package:core_logging/core_logging.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/message_service.dart';

/// 聊天状态
final class ChatState {
  /// 当前会话列表
  final List<Conversation> conversations;

  /// 当前激活的会话
  final Conversation? activeConversation;

  /// 当前会话的消息列表
  final List<Message> messages;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 未读消息总数
  final int totalUnreadCount;

  /// 是否正在发送消息
  final bool isSending;

  const ChatState({
    this.conversations = const [],
    this.activeConversation,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.totalUnreadCount = 0,
    this.isSending = false,
  });

  /// 初始状态
  const ChatState.initial() : conversations = const [], activeConversation = null, messages = const [], isLoading = false, error = null, totalUnreadCount = 0, isSending = false;

  ChatState copyWith({
    List<Conversation>? conversations,
    Conversation? activeConversation,
    List<Message>? messages,
    bool? isLoading,
    String? error,
    int? totalUnreadCount,
    bool? isSending,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  String toString() =>
      'ChatState(conversations: ${conversations.length}, messages: ${messages.length}, unread: $totalUnreadCount)';
}

/// 消息状态管理器
///
/// 负责管理聊天状态和消息列表
final class MessageProvider extends StateNotifier<ChatState> {
  final MessageService _messageService;
  final String _currentUserId;

  MessageProvider(this._messageService, this._currentUserId)
      : super(const ChatState.initial()) {
    _init();
  }

  /// 初始化 - 加载会话列表
  Future<void> _init() async {
    try {
      final result = await _messageService.getConversations(_currentUserId);
      if (result.isSuccess) {
        state = state.copyWith(conversations: result.valueOrThrow);
        
        // 获取未读数
        _updateUnreadCount();
      }
    } catch (e) {
      Log.e('初始化聊天状态失败', error: e);
    }
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);

    final result = await _messageService.getConversations(_currentUserId);

    if (result.isSuccess) {
      state = state.copyWith(
        conversations: result.valueOrThrow,
        isLoading: false,
      );
      
      await _updateUnreadCount();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error?.toString(),
      );
    }
  }

  /// 切换会话
  Future<void> switchConversation(Conversation conversation) async {
    state = state.copyWith(
      activeConversation: conversation,
      messages: [],
      isLoading: true,
    );

    await loadMessages(conversation.id);
  }

  /// 加载消息
  Future<void> loadMessages(String conversationId) async {
    final result = await _messageService.getMessages(
      conversationId: conversationId,
    );

    if (result.isSuccess) {
      final messages = result.valueOrThrow.data;
      state = state.copyWith(messages: messages);
      
      // 标记已读
      await markAsRead(conversationId);
    } else {
      state = state.copyWith(error: result.error?.toString());
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    state = state.copyWith(isSending: true);

    // 创建临时消息（显示在列表中）
    final tempMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: _currentUserId,
      type: MessageType.text,
      text: text,
      status: MessageStatus.sending,
      direction: MessageDirection.outgoing,
      createdAt: DateTime.now(),
    );

    // 添加到消息列表
    final updatedMessages = [tempMessage, ...state.messages];
    state = state.copyWith(messages: updatedMessages);

    final result = await _messageService.sendTextMessage(
      conversationId: conversationId,
      text: text,
    );

    if (result.isSuccess) {
      // 发送成功，替换临时消息
      final sentMessage = result.valueOrThrow;
      final messages = state.messages.map((msg) {
        return msg.id == tempMessage.id ? sentMessage : msg;
      }).toList();

      state = state.copyWith(
        messages: messages,
        isSending: false,
      );

      // 更新会话的最后一条消息
      await _updateConversationLastMessage(conversationId);
    } else {
      // 发送失败
      final messages = state.messages.map((msg) {
        if (msg.id == tempMessage.id) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();

      state = state.copyWith(
        messages: messages,
        isSending: false,
        error: result.error?.toString(),
      );
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage({
    required String conversationId,
    required String imageUrl,
    int? width,
    int? height,
  }) async {
    state = state.copyWith(isSending: true);

    final result = await _messageService.sendImageMessage(
      conversationId: conversationId,
      imageUrl: imageUrl,
      width: width,
      height: height,
    );

    if (result.isSuccess) {
      final newMessage = result.valueOrThrow;
      final updatedMessages = [newMessage, ...state.messages];
      
      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );

      await _updateConversationLastMessage(conversationId);
    } else {
      state = state.copyWith(
        isSending: false,
        error: result.error?.toString(),
      );
    }
  }

  /// 创建单聊会话
  Future<Result<Conversation>> createSingleConversation({
    required String targetUserId,
  }) async {
    return await _messageService.createSingleConversation(
      userId: _currentUserId,
      targetUserId: targetUserId,
    );
  }

  /// 撤回消息
  Future<void> revokeMessage(String messageId) async {
    final result = await _messageService.revokeMessage(messageId);

    if (result.isSuccess) {
      final messages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(
            isRevoked: true,
            revokedAt: DateTime.now(),
          );
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: messages);
    } else {
      state = state.copyWith(error: result.error?.toString());
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    final result = await _messageService.deleteMessage(messageId);

    if (result.isSuccess) {
      final messages = state.messages.where((msg) => msg.id != messageId).toList();
      state = state.copyWith(messages: messages);
    }
  }

  /// 标记已读
  Future<void> markAsRead(String conversationId) async {
    final result = await _messageService.markConversationAsRead(conversationId);
    if (result.isSuccess) {
      await _updateUnreadCount();
    }
  }

  /// 置顶会话
  Future<void> pinConversation(String conversationId) async {
    final result = await _messageService.pinConversation(conversationId);
    if (result.isSuccess) {
      await loadConversations();
    }
  }

  /// 取消置顶
  Future<void> unpinConversation(String conversationId) async {
    final result = await _messageService.unpinConversation(conversationId);
    if (result.isSuccess) {
      await loadConversations();
    }
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    final result = await _messageService.deleteConversation(conversationId);
    if (result.isSuccess) {
      final conversations = state.conversations
          .where((c) => c.id != conversationId)
          .toList();
      
      state = state.copyWith(conversations: conversations);
      
      if (state.activeConversation?.id == conversationId) {
        state = state.copyWith(
          activeConversation: null,
          messages: [],
        );
      }
    }
  }

  /// 更新未读数
  Future<void> _updateUnreadCount() async {
    final result = await _messageService.getUnreadCount(_currentUserId);
    if (result.isSuccess) {
      state = state.copyWith(totalUnreadCount: result.valueOrThrow);
    }
  }

  /// 更新会话的最后一条消息
  Future<void> _updateConversationLastMessage(String conversationId) async {
    final result = await _messageService.getConversation(conversationId);
    if (result.isSuccess) {
      final updatedConversation = result.valueOrThrow;
      final conversations = state.conversations.map((c) {
        return c.id == conversationId ? updatedConversation : c;
      }).toList();

      state = state.copyWith(conversations: conversations);
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
