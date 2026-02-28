library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../repositories/message_repository.dart';

/// 即时通讯服务 - 高度可扩展
///
/// 核心功能：
/// 1. 单聊 - 一对一聊天
/// 2. 群聊 - 多人群组聊天
/// 3. 消息类型 - 文本、图片、语音、视频、文件、位置、表情、自定义
/// 4. 会话管理 - 置顶、免打扰、删除
///
/// 扩展性：
/// - 通过 MessageType.custom 实现自定义消息类型
/// - 通过 customData 存储任意扩展数据
final class MessageService {
  final MessageRepository _repository;
  final ApiClient _apiClient;

  MessageService({
    required MessageRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        _apiClient = apiClient;

  // ==================== 会话管理 ====================

  /// 获取会话列表
  Future<Result<List<Conversation>>> getConversations(String userId) async {
    return await _repository.getConversations(userId);
  }

  /// 获取单个会话
  Future<Result<Conversation>> getConversation(String conversationId) async {
    return await _repository.getConversation(conversationId);
  }

  /// 创建单聊会话
  ///
  /// 使用场景：
  /// - 点击用户头像开始聊天
  /// - 从用户列表发起聊天
  Future<Result<Conversation>> createSingleConversation({
    required String userId,
    required String targetUserId,
  }) async {
    try {
      Log.i('创建单聊会话: $userId -> $targetUserId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/im/conversations/single',
        body: {
          'userId': userId,
          'targetUserId': targetUserId,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final conversationData = response.data!['data'] as Map<String, dynamic>;
        final conversation = Conversation.fromJson(conversationData);

        Log.i('创建单聊会话成功: ${conversation.id}');
        return Result.success(conversation);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '创建会话失败'),
      );
    } catch (e) {
      Log.e('创建会话失败', error: e);
      return Result.failure(Exception('创建会话失败: $e'));
    }
  }

  /// 更新会话信息
  Future<Result<void>> updateConversationInfo({
    required String conversationId,
    String? name,
    String? avatar,
  }) async {
    try {
      Log.i('更新会话信息: $conversationId');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/im/conversations/$conversationId',
        body: {
          if (name != null) 'name': name,
          if (avatar != null) 'avatar': avatar,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('更新会话信息成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '更新会话失败'),
      );
    } catch (e) {
      Log.e('更新会话失败', error: e);
      return Result.failure(Exception('更新会话失败: $e'));
    }
  }

  /// 置顶会话
  Future<Result<void>> pinConversation(String conversationId) async {
    return await _repository.pinConversation(conversationId);
  }

  /// 取消置顶
  Future<Result<void>> unpinConversation(String conversationId) async {
    return await _repository.unpinConversation(conversationId);
  }

  /// 免打扰
  Future<Result<void>> muteConversation(String conversationId) async {
    return await _repository.muteConversation(conversationId);
  }

  /// 取消免打扰
  Future<Result<void>> unmuteConversation(String conversationId) async {
    return await _repository.unmuteConversation(conversationId);
  }

  /// 删除会话
  Future<Result<void>> deleteConversation(String conversationId) async {
    return await _repository.deleteConversation(conversationId);
  }

  // ==================== 消息发送 ====================

  /// 发送文本消息
  Future<Result<Message>> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.text,
      extra: {'text': text},
    );
  }

  /// 发送图片消息
  Future<Result<Message>> sendImageMessage({
    required String conversationId,
    required String imageUrl,
    int? width,
    int? height,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.image,
      extra: {
        'image': {
          'url': imageUrl,
          'width': width,
          'height': height,
        },
      },
    );
  }

  /// 发送语音消息
  Future<Result<Message>> sendAudioMessage({
    required String conversationId,
    required String audioUrl,
    required int duration,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.audio,
      extra: {
        'audio': {
          'url': audioUrl,
          'duration': duration,
        },
      },
    );
  }

  /// 发送视频消息
  Future<Result<Message>> sendVideoMessage({
    required String conversationId,
    required String videoUrl,
    String? thumbnail,
    int? duration,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.video,
      extra: {
        'video': {
          'url': videoUrl,
          'thumbnail': thumbnail,
          'duration': duration,
        },
      },
    );
  }

  /// 发送位置消息
  Future<Result<Message>> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
    String? address,
    String? name,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.location,
      extra: {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'name': name,
        },
      },
    );
  }

  /// 发送自定义消息
  ///
  /// 使用场景：
  /// - 商品卡片
  /// - 订单卡片
  /// - 红包
  /// - 自定义任何类型
  Future<Result<Message>> sendCustomMessage({
    required String conversationId,
    required Map<String, dynamic> customData,
  }) async {
    return await _repository.sendMessage(
      conversationId: conversationId,
      type: MessageType.custom,
      extra: {'customData': customData},
    );
  }

  // ==================== 消息操作 ====================

  /// 撤回消息
  Future<Result<void>> revokeMessage(String messageId) async {
    return await _repository.revokeMessage(messageId);
  }

  /// 删除消息
  Future<Result<void>> deleteMessage(String messageId) async {
    return await _repository.deleteMessage(messageId);
  }

  /// 标记消息已读
  Future<Result<void>> markAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    return await _repository.markAsRead(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// 标记会话所有消息已读
  Future<Result<void>> markConversationAsRead(String conversationId) async {
    return await _repository.markConversationAsRead(conversationId);
  }

  // ==================== 消息查询 ====================

  /// 获取会话消息列表
  Future<Result<PagedResult<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getMessages(
      conversationId: conversationId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取未读消息数
  Future<Result<int>> getUnreadCount(String userId) async {
    return await _repository.getUnreadCount(userId);
  }
}
