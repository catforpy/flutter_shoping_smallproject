library;

import 'package:service_user/service_user.dart';
import 'message.dart';

/// 会话类型
enum ConversationType {
  /// 单聊
  single('single'),

  /// 群聊
  group('group'),

  /// 系统通知
  system('system'),

  /// 自定义
  custom('custom');

  const ConversationType(this.value);
  final String value;

  static ConversationType fromString(String value) {
    return ConversationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ConversationType.custom,
    );
  }
}

/// 会话实体 - 高度可扩展
final class Conversation {
  /// 会话ID
  final String id;

  /// 会话类型
  final ConversationType type;

  /// 会话名称
  final String? name;

  /// 会话头像
  final String? avatar;

  /// 当前用户ID（用于判断消息方向）
  final String currentUserId;

  /// 单聊：对方用户ID
  /// 群聊：群ID
  final String targetId;

  /// 对方用户信息（单聊时使用）
  final User? targetUser;

  /// 最后一条消息
  final Message? lastMessage;

  /// 未读消息数
  final int unreadCount;

  /// 是否置顶
  final bool isPinned;

  /// 是否免打扰
  final bool isMuted;

  /// 自定义元数据
  final Map<String, dynamic>? metadata;

  /// 更新时间
  final DateTime updatedAt;

  /// 创建时间
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.type,
    this.name,
    this.avatar,
    required this.currentUserId,
    required this.targetId,
    this.targetUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.metadata,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      type: ConversationType.fromString(json['type'] as String),
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      currentUserId: json['currentUserId'] as String,
      targetId: json['targetId'] as String,
      targetUser: json['targetUser'] != null
          ? User.fromJson(json['targetUser'] as Map<String, dynamic>)
          : null,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'name': name,
      'avatar': avatar,
      'currentUserId': currentUserId,
      'targetId': targetId,
      'targetUser': targetUser?.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'metadata': metadata,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 是否为单聊
  bool get isSingle => type == ConversationType.single;

  /// 是否为群聊
  bool get isGroup => type == ConversationType.group;

  /// 显示名称
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (targetUser != null) return targetUser!.displayName;
    return type == ConversationType.single ? '用户' : '群聊';
  }

  /// 显示头像
  String get displayAvatar {
    if (avatar != null && avatar!.isNotEmpty) return avatar!;
    if (targetUser?.avatar != null) return targetUser!.avatar!;
    return '';
  }

  Conversation copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? avatar,
    String? currentUserId,
    String? targetId,
    User? targetUser,
    Message? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      currentUserId: currentUserId ?? this.currentUserId,
      targetId: targetId ?? this.targetId,
      targetUser: targetUser ?? this.targetUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      metadata: metadata ?? this.metadata,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Conversation(id: $id, type: ${type.value}, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
