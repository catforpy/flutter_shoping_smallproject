library;

import 'package:core_base/core_base.dart';
import '../models/message.dart';
import '../models/conversation.dart';

/// 消息仓库接口
abstract class MessageRepository {
  // ==================== 会话管理 ====================
  
  /// 获取会话列表
  Future<Result<List<Conversation>>> getConversations(String userId);

  /// 获取单个会话
  Future<Result<Conversation>> getConversation(String conversationId);

  /// 创建单聊会话
  Future<Result<Conversation>> createSingleConversation({
    required String userId,
    required String targetUserId,
  });

  /// 创建群聊会话
  Future<Result<Conversation>> createGroupConversation({
    required String userId,
    required String name,
    required List<String> memberIds,
  });

  /// 更新会话
  Future<Result<Conversation>> updateConversation(Conversation conversation);

  /// 置顶会话
  Future<Result<void>> pinConversation(String conversationId);

  /// 取消置顶
  Future<Result<void>> unpinConversation(String conversationId);

  /// 免打扰
  Future<Result<void>> muteConversation(String conversationId);

  /// 取消免打扰
  Future<Result<void>> unmuteConversation(String conversationId);

  /// 删除会话
  Future<Result<void>> deleteConversation(String conversationId);

  // ==================== 消息管理 ====================
  
  /// 获取会话消息列表
  Future<Result<PagedResult<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 20,
  });

  /// 发送消息
  Future<Result<Message>> sendMessage({
    required String conversationId,
    required MessageType type,
    String? text,
    Map<String, dynamic>? extra,
  });

  /// 撤回消息
  Future<Result<void>> revokeMessage(String messageId);

  /// 删除消息
  Future<Result<void>> deleteMessage(String messageId);

  /// 标记消息已读
  Future<Result<void>> markAsRead({
    required String conversationId,
    required String messageId,
  });

  /// 标记会话所有消息已读
  Future<Result<void>> markConversationAsRead(String conversationId);

  /// 获取未读消息数
  Future<Result<int>> getUnreadCount(String userId);

  /// 清除缓存
  Future<void> clearCache();
}
