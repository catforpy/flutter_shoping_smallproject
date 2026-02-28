library;

/// 消息类型枚举 - 完全可扩展
enum MessageType {
  /// 文本消息
  text('text'),

  /// 图片消息
  image('image'),

  /// 语音消息
  audio('audio'),

  /// 视频消息
  video('video'),

  /// 文件消息
  file('file'),

  /// 位置消息
  location('location'),

  /// 表情消息
  emoji('emoji'),

  /// 系统消息
  system('system'),

  /// 自定义消息
  custom('custom');

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.custom,
    );
  }
}

/// 消息状态
enum MessageStatus {
  /// 发送中
  sending('sending'),

  /// 已发送
  sent('sent'),

  /// 已送达
  delivered('delivered'),

  /// 已读
  read('read'),

  /// 发送失败
  failed('failed');

  const MessageStatus(this.value);
  final String value;

  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MessageStatus.sending,
    );
  }
}

/// 消息方向
enum MessageDirection {
  /// 发送的消息
  outgoing('outgoing'),

  /// 接收的消息
  incoming('incoming');

  const MessageDirection(this.value);
  final String value;
}

/// 消息实体 - 高度可扩展
final class Message {
  /// 消息ID
  final String id;

  /// 会话ID
  final String conversationId;

  /// 发送者ID
  final String senderId;

  /// 发送者信息（冗余字段，用于快速显示）
  final String? senderNickname;
  final String? senderAvatar;

  /// 消息类型
  final MessageType type;

  /// 消息内容（根据 type 不同，content 格式也不同）
  final String? content;

  /// 文本消息内容
  final String? text;

  /// 图片消息内容
  final ImageContent? image;

  /// 语音消息内容
  final AudioContent? audio;

  /// 视频消息内容
  final VideoContent? video;

  /// 文件消息内容
  final FileContent? file;

  /// 位置消息内容
  final LocationContent? location;

  /// 表情消息内容
  final String? emoji;

  /// 系统消息内容
  final SystemContent? systemInfo;

  /// 自定义消息内容
  final Map<String, dynamic>? customData;

  /// 消息状态
  final MessageStatus status;

  /// 消息方向
  final MessageDirection direction;

  /// 是否撤回
  final bool isRevoked;

  /// 撤回时间
  final DateTime? revokedAt;

  /// 引用回复的消息
  final Message? replyTo;

  /// @提及的用户ID列表
  final List<String> mentions;

  /// 创建时间
  final DateTime createdAt;

  /// 发送时间
  final DateTime? sentAt;

  /// 送达时间
  final DateTime? deliveredAt;

  /// 已读时间
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderNickname,
    this.senderAvatar,
    required this.type,
    this.content,
    this.text,
    this.image,
    this.audio,
    this.video,
    this.file,
    this.location,
    this.emoji,
    this.systemInfo,
    this.customData,
    this.status = MessageStatus.sending,
    this.direction = MessageDirection.outgoing,
    this.isRevoked = false,
    this.revokedAt,
    this.replyTo,
    this.mentions = const [],
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderNickname: json['senderNickname'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      type: MessageType.fromString(json['type'] as String),
      content: json['content'] as String?,
      text: json['text'] as String?,
      image: json['image'] != null
          ? ImageContent.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      audio: json['audio'] != null
          ? AudioContent.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
      video: json['video'] != null
          ? VideoContent.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      file: json['file'] != null
          ? FileContent.fromJson(json['file'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null
          ? LocationContent.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      emoji: json['emoji'] as String?,
      systemInfo: json['systemInfo'] != null
          ? SystemContent.fromJson(json['systemInfo'] as Map<String, dynamic>)
          : null,
      customData: json['customData'] as Map<String, dynamic>?,
      status: MessageStatus.fromString(json['status'] as String),
      direction: MessageDirection.values.firstWhere(
        (d) => d.value == json['direction'],
        orElse: () => MessageDirection.outgoing,
      ),
      isRevoked: json['isRevoked'] as bool? ?? false,
      revokedAt: json['revokedAt'] != null
          ? DateTime.parse(json['revokedAt'] as String)
          : null,
      replyTo: json['replyTo'] != null
          ? Message.fromJson(json['replyTo'] as Map<String, dynamic>)
          : null,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderNickname': senderNickname,
      'senderAvatar': senderAvatar,
      'type': type.value,
      'content': content,
      'text': text,
      'image': image?.toJson(),
      'audio': audio?.toJson(),
      'video': video?.toJson(),
      'file': file?.toJson(),
      'location': location?.toJson(),
      'emoji': emoji,
      'systemInfo': systemInfo?.toJson(),
      'customData': customData,
      'status': status.value,
      'direction': direction.value,
      'isRevoked': isRevoked,
      'revokedAt': revokedAt?.toIso8601String(),
      'replyTo': replyTo?.toJson(),
      'mentions': mentions,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// 是否为文本消息
  bool get isText => type == MessageType.text;

  /// 是否为图片消息
  bool get isImage => type == MessageType.image;

  /// 是否为语音消息
  bool get isAudio => type == MessageType.audio;

  /// 是否为视频消息
  bool get isVideo => type == MessageType.video;

  /// 是否为系统消息
  bool get isSystem => type == MessageType.system;

  /// 是否为发送的消息
  bool get isOutgoing => direction == MessageDirection.outgoing;

  /// 是否为接收的消息
  bool get isIncoming => direction == MessageDirection.incoming;

  /// 显示内容（用于列表显示）
  String get displayContent {
    if (isRevoked) return '消息已撤回';
    if (isText) return text ?? '';
    if (isImage) return '[图片]';
    if (isAudio) return '[语音]';
    if (isVideo) return '[视频]';
    if (isSystem) return systemInfo?.text ?? '[系统消息]';
    return '[消息]';
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderNickname,
    String? senderAvatar,
    MessageType? type,
    String? content,
    String? text,
    ImageContent? image,
    AudioContent? audio,
    VideoContent? video,
    FileContent? file,
    LocationContent? location,
    String? emoji,
    SystemContent? systemInfo,
    Map<String, dynamic>? customData,
    MessageStatus? status,
    MessageDirection? direction,
    bool? isRevoked,
    DateTime? revokedAt,
    Message? replyTo,
    List<String>? mentions,
    DateTime? createdAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderNickname: senderNickname ?? this.senderNickname,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      text: text ?? this.text,
      image: image ?? this.image,
      audio: audio ?? this.audio,
      video: video ?? this.video,
      file: file ?? this.file,
      location: location ?? this.location,
      emoji: emoji ?? this.emoji,
      systemInfo: systemInfo ?? this.systemInfo,
      customData: customData ?? this.customData,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      replyTo: replyTo ?? this.replyTo,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() =>
      'Message(id: $id, type: ${type.value}, content: ${displayContent})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 图片消息内容
final class ImageContent {
  final String url;
  final int? width;
  final int? height;
  final int? size;
  final String? thumbnail;

  const ImageContent({
    required this.url,
    this.width,
    this.height,
    this.size,
    this.thumbnail,
  });

  factory ImageContent.fromJson(Map<String, dynamic> json) {
    return ImageContent(
      url: json['url'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      size: json['size'] as int?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
      'size': size,
      'thumbnail': thumbnail,
    };
  }
}

/// 语音消息内容
final class AudioContent {
  final String url;
  final int? duration; // 秒
  final int? size;

  const AudioContent({
    required this.url,
    this.duration,
    this.size,
  });

  factory AudioContent.fromJson(Map<String, dynamic> json) {
    return AudioContent(
      url: json['url'] as String,
      duration: json['duration'] as int?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'duration': duration,
      'size': size,
    };
  }
}

/// 视频消息内容
final class VideoContent {
  final String url;
  final String? thumbnail;
  final int? duration;
  final int? width;
  final int? height;
  final int? size;

  const VideoContent({
    required this.url,
    this.thumbnail,
    this.duration,
    this.width,
    this.height,
    this.size,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail': thumbnail,
      'duration': duration,
      'width': width,
      'height': height,
      'size': size,
    };
  }
}

/// 文件消息内容
final class FileContent {
  final String url;
  final String filename;
  final int? size;
  final String? mimeType;

  const FileContent({
    required this.url,
    required this.filename,
    this.size,
    this.mimeType,
  });

  factory FileContent.fromJson(Map<String, dynamic> json) {
    return FileContent(
      url: json['url'] as String,
      filename: json['filename'] as String,
      size: json['size'] as int?,
      mimeType: json['mimeType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'size': size,
      'mimeType': mimeType,
    };
  }
}

/// 位置消息内容
final class LocationContent {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  const LocationContent({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });

  factory LocationContent.fromJson(Map<String, dynamic> json) {
    return LocationContent(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'name': name,
    };
  }
}

/// 系统消息内容
final class SystemContent {
  final String text;
  final SystemMessageType type;

  const SystemContent({
    required this.text,
    required this.type,
  });

  factory SystemContent.fromJson(Map<String, dynamic> json) {
    return SystemContent(
      text: json['text'] as String,
      type: SystemMessageType.values.firstWhere(
        (t) => t.value == json['type'],
        orElse: () => SystemMessageType.other,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.value,
    };
  }
}

/// 系统消息类型
enum SystemMessageType {
  /// 群创建
  groupCreated('group_created'),

  /// 群名称修改
  groupRenamed('group_renamed'),

  /// 成员加入
  memberJoined('member_joined'),

  /// 成员离开
  memberLeft('member_left'),

  /// 其他
  other('other');

  const SystemMessageType(this.value);
  final String value;
}
