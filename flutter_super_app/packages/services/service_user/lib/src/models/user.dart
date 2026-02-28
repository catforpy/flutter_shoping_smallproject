library;

import 'attributes/user_attributes.dart';

/// 用户实体 - 核心模型（极简且可扩展）
///
/// 核心字段：只包含最基础、最稳定的字段
/// 扩展属性：通过 attributes 实现高度可扩展
///
/// 设计原则：
/// 1. 核心字段极少，几乎不需要改动
/// 2. 所有扩展信息都在 attributes 中
/// 3. 向后兼容，新增字段不影响旧版本
final class User {
  /// 用户ID - 唯一标识，不可变
  final String id;

  /// 用户名 - 登录用，唯一，不可变
  final String username;

  /// 昵称 - 可自定义
  final String? nickname;

  /// 头像 URL
  final String? avatar;

  /// 手机号
  final String? phone;

  /// 邮箱
  final String? email;

  /// 性别
  final String? gender;

  /// 生日
  final DateTime? birthday;

  /// 状态
  final UserStatus status;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 扩展属性 - 关键扩展点
  ///
  /// 包含：
  /// - 实名认证信息
  /// - 企业信息
  /// - 会员信息
  /// - 角色列表
  /// - 统计数据
  /// - 自定义字段
  final UserAttributes attributes;

  const User({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.phone,
    this.email,
    this.gender,
    this.birthday,
    this.status = UserStatus.active,
    this.createdAt,
    this.updatedAt,
    this.attributes = const UserAttributes(),
  });

  /// 显示名称（优先使用昵称）
  String get displayName => nickname ?? username;

  /// 是否活跃
  bool get isActive => status == UserStatus.active;

  /// 是否已实名认证
  bool get isRealNameVerified => attributes.isRealNameVerified;

  /// 是否企业认证
  bool get isCompanyVerified => attributes.isCompanyVerified;

  /// 是否会员
  bool get isMember => attributes.isMember;

  /// 从 JSON 创建
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      status: json['status'] != null
          ? UserStatus.values.firstWhere(
              (s) => s.name == json['status'],
              orElse: () => UserStatus.active,
            )
          : UserStatus.active,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      attributes: json['attributes'] != null
          ? UserAttributes.fromJson(json['attributes'] as Map<String, dynamic>)
          : const UserAttributes(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'phone': phone,
      'email': email,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'attributes': attributes.toJson(),
    };
  }

  /// 创建副本
  User copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? phone,
    String? email,
    String? gender,
    DateTime? birthday,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserAttributes? attributes,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, nickname: $nickname)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 用户状态
enum UserStatus {
  /// 活跃
  active('active'),

  /// 禁用
  disabled('disabled'),

  /// 删除
  deleted('deleted'),

  /// 未激活
  inactive('inactive');

  const UserStatus(this.value);
  final String value;
}
