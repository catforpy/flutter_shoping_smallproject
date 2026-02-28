library;

/// 用户属性 - 高度可扩展系统
///
/// 核心设计原则：
/// 1. 预定义扩展：有类型检查，常用扩展
/// 2. 自定义字段：完全灵活，任意扩展
///
/// 使用示例：
/// ```dart
/// final attrs = UserAttributes(
///   realNameInfo: RealNameInfo(isVerified: true),
///   customFields: {'industry': 'education'},
/// );
/// ```

// ==================== 预定义扩展 ====================

/// 实名认证信息
final class RealNameInfo {
  /// 是否已实名认证
  final bool isVerified;

  /// 真实姓名
  final String? realName;

  /// 身份证号
  final String? idCard;

  /// 认证时间
  final DateTime? verifiedAt;

  /// 认证机构
  final String? verifiedBy;

  const RealNameInfo({
    required this.isVerified,
    this.realName,
    this.idCard,
    this.verifiedAt,
    this.verifiedBy,
  });

  /// 从 JSON 创建
  factory RealNameInfo.fromJson(Map<String, dynamic> json) {
    return RealNameInfo(
      isVerified: json['isVerified'] as bool? ?? false,
      realName: json['realName'] as String?,
      idCard: json['idCard'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      verifiedBy: json['verifiedBy'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'isVerified': isVerified,
      'realName': realName,
      'idCard': idCard,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
    };
  }

  RealNameInfo copyWith({
    bool? isVerified,
    String? realName,
    String? idCard,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return RealNameInfo(
      isVerified: isVerified ?? this.isVerified,
      realName: realName ?? this.realName,
      idCard: idCard ?? this.idCard,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }
}

/// 企业/商户信息
final class CompanyInfo {
  /// 是否企业认证
  final bool isCompanyVerified;

  /// 企业名称
  final String? companyName;

  /// 营业执照 URL
  final String? businessLicense;

  /// 税务号
  final String? taxNumber;

  /// 资质证书列表
  final List<String>? certificates;

  /// 企业地址
  final String? address;

  /// 认证时间
  final DateTime? verifiedAt;

  const CompanyInfo({
    required this.isCompanyVerified,
    this.companyName,
    this.businessLicense,
    this.taxNumber,
    this.certificates,
    this.address,
    this.verifiedAt,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      isCompanyVerified: json['isCompanyVerified'] as bool? ?? false,
      companyName: json['companyName'] as String?,
      businessLicense: json['businessLicense'] as String?,
      taxNumber: json['taxNumber'] as String?,
      certificates: json['certificates'] as List<String>?,
      address: json['address'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCompanyVerified': isCompanyVerified,
      'companyName': companyName,
      'businessLicense': businessLicense,
      'taxNumber': taxNumber,
      'certificates': certificates,
      'address': address,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  CompanyInfo copyWith({
    bool? isCompanyVerified,
    String? companyName,
    String? businessLicense,
    String? taxNumber,
    List<String>? certificates,
    String? address,
    DateTime? verifiedAt,
  }) {
    return CompanyInfo(
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      companyName: companyName ?? this.companyName,
      businessLicense: businessLicense ?? this.businessLicense,
      taxNumber: taxNumber ?? this.taxNumber,
      certificates: certificates ?? this.certificates,
      address: address ?? this.address,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

/// 会员信息 - 类型完全可配置
final class MembershipInfo {
  /// 会员类型 - 可自定义
  /// 示例: "VIP", "SVIP", "PRO", "Premium", "Gold", "Platinum"...
  final String membershipType;

  /// 会员等级 - 可自定义
  /// 可以是数字: "1", "2", "3"
  /// 可以是名称: "Basic", "Advanced", "Expert"
  final String level;

  /// 到期时间
  final DateTime? expireAt;

  /// 扩展数据 - 存储会员相关自定义配置
  final Map<String, dynamic>? customData;

  const MembershipInfo({
    required this.membershipType,
    required this.level,
    this.expireAt,
    this.customData,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) {
    return MembershipInfo(
      membershipType: json['membershipType'] as String,
      level: json['level'] as String,
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'] as String)
          : null,
      customData: json['customData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membershipType': membershipType,
      'level': level,
      'expireAt': expireAt?.toIso8601String(),
      'customData': customData,
    };
  }

  /// 是否已过期
  bool get isExpired => expireAt != null && DateTime.now().isAfter(expireAt!);

  MembershipInfo copyWith({
    String? membershipType,
    String? level,
    DateTime? expireAt,
    Map<String, dynamic>? customData,
  }) {
    return MembershipInfo(
      membershipType: membershipType ?? this.membershipType,
      level: level ?? this.level,
      expireAt: expireAt ?? this.expireAt,
      customData: customData ?? this.customData,
    );
  }
}

/// 用户角色 - 类型可自定义
final class UserRole {
  /// 角色类型 - 可自定义
  /// 预定义示例:
  /// - "customer_service" - 客服
  /// - "teacher" - 老师
  /// - "expert" - 达人
  /// - "sales" - 销售
  /// - "admin" - 管理员
  /// - "custom" - 自定义
  final String roleType;

  /// 角色显示名称 - 可自定义
  /// 示例: "高级讲师", "金牌客服", "区域代理"
  final String? roleName;

  /// 权限配置 - 可自定义
  final Map<String, dynamic>? permissions;

  /// 角色获取时间
  final DateTime? obtainedAt;

  const UserRole({
    required this.roleType,
    this.roleName,
    this.permissions,
    this.obtainedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleType: json['roleType'] as String,
      roleName: json['roleName'] as String?,
      permissions: json['permissions'] as Map<String, dynamic>?,
      obtainedAt: json['obtainedAt'] != null
          ? DateTime.parse(json['obtainedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleType': roleType,
      'roleName': roleName,
      'permissions': permissions,
      'obtainedAt': obtainedAt?.toIso8601String(),
    };
  }

  UserRole copyWith({
    String? roleType,
    String? roleName,
    Map<String, dynamic>? permissions,
    DateTime? obtainedAt,
  }) {
    return UserRole(
      roleType: roleType ?? this.roleType,
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? this.permissions,
      obtainedAt: obtainedAt ?? this.obtainedAt,
    );
  }
}

/// 用户统计数据
final class UserStats {
  /// 粉丝数
  final int followersCount;

  /// 关注数
  final int followingCount;

  /// 发布内容数
  final int postsCount;

  /// 获得点赞数
  final int likesCount;

  /// 扩展统计字段
  final Map<String, dynamic>? customStats;

  const UserStats({
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.likesCount,
    this.customStats,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      likesCount: json['likesCount'] as int? ?? 0,
      customStats: json['customStats'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'likesCount': likesCount,
      'customStats': customStats,
    };
  }

  UserStats copyWith({
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? likesCount,
    Map<String, dynamic>? customStats,
  }) {
    return UserStats(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      likesCount: likesCount ?? this.likesCount,
      customStats: customStats ?? this.customStats,
    );
  }
}

// ==================== 用户属性主类 ====================

/// 用户属性 - 高度可扩展
final class UserAttributes {
  // ========== 预定义扩展（有类型检查） ==========

  /// 实名认证信息
  final RealNameInfo? realNameInfo;

  /// 企业/商户信息
  final CompanyInfo? companyInfo;

  /// 会员信息（类型可配置）
  final MembershipInfo? membership;

  /// 用户角色列表（可扩展）
  final List<UserRole> roles;

  /// 用户统计数据
  final UserStats? stats;

  // ========== 自定义扩展（完全灵活） ==========

  /// 自定义字段 - 完全灵活的扩展点
  ///
  /// 存储格式：Map<String, dynamic>
  ///
  /// 示例：
  /// ```dart
  /// customFields: {
  ///   'industry': 'education',
  ///   'specialties': ['Flutter', 'Dart'],
  ///   'website': 'https://example.com',
  ///   'anyCustomField': 'any value',
  /// }
  /// ```
  final Map<String, dynamic> customFields;

  const UserAttributes({
    this.realNameInfo,
    this.companyInfo,
    this.membership,
    this.roles = const [],
    this.stats,
    this.customFields = const {},
  });

  /// 从 JSON 创建
  factory UserAttributes.fromJson(Map<String, dynamic> json) {
    return UserAttributes(
      realNameInfo: json['realNameInfo'] != null
          ? RealNameInfo.fromJson(json['realNameInfo'] as Map<String, dynamic>)
          : null,
      companyInfo: json['companyInfo'] != null
          ? CompanyInfo.fromJson(json['companyInfo'] as Map<String, dynamic>)
          : null,
      membership: json['membership'] != null
          ? MembershipInfo.fromJson(json['membership'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      customFields: json['customFields'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'realNameInfo': realNameInfo?.toJson(),
      'companyInfo': companyInfo?.toJson(),
      'membership': membership?.toJson(),
      'roles': roles.map((e) => e.toJson()).toList(),
      'stats': stats?.toJson(),
      'customFields': customFields,
    };
  }

  /// 获取自定义字段
  T? getCustom<T>(String key) {
    final value = customFields[key];
    if (value == null) return null;
    return value as T;
  }

  /// 设置自定义字段
  UserAttributes setCustom<T>(String key, T value) {
    return copyWith(
      customFields: {...customFields, key: value},
    );
  }

  /// 移除自定义字段
  UserAttributes removeCustom(String key) {
    final newFields = Map<String, dynamic>.from(customFields);
    newFields.remove(key);
    return copyWith(customFields: newFields);
  }

  /// 是否已实名认证
  bool get isRealNameVerified => realNameInfo?.isVerified ?? false;

  /// 是否企业认证
  bool get isCompanyVerified => companyInfo?.isCompanyVerified ?? false;

  /// 是否会员
  bool get isMember => membership != null && !membership!.isExpired;

  /// 是否有特定角色
  bool hasRole(String roleType) {
    return roles.any((r) => r.roleType == roleType);
  }

  /// 创建副本
  UserAttributes copyWith({
    RealNameInfo? realNameInfo,
    CompanyInfo? companyInfo,
    MembershipInfo? membership,
    List<UserRole>? roles,
    UserStats? stats,
    Map<String, dynamic>? customFields,
  }) {
    return UserAttributes(
      realNameInfo: realNameInfo ?? this.realNameInfo,
      companyInfo: companyInfo ?? this.companyInfo,
      membership: membership ?? this.membership,
      roles: roles ?? this.roles,
      stats: stats ?? this.stats,
      customFields: customFields ?? this.customFields,
    );
  }

  /// 创建空属性
  factory UserAttributes.empty() => const UserAttributes();

  @override
  String toString() {
    return 'UserAttributes('
        'isRealNameVerified: $isRealNameVerified, '
        'isCompanyVerified: $isCompanyVerified, '
        'isMember: $isMember, '
        'roles: ${roles.length})';
  }
}
