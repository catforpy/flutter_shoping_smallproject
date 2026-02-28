/// 用户资料
final class UserProfile {
  /// 用户ID
  final String userId;

  /// 真实姓名
  final String? realName;

  /// 身份证号
  final String? idCard;

  /// 地址
  final String? address;

  /// 公司
  final String? company;

  /// 职位
  final String? position;

  /// 个人简介
  final String? bio;

  /// 网站
  final String? website;

  /// 微信
  final String? wechat;

  /// QQ
  final String? qq;

  const UserProfile({
    required this.userId,
    this.realName,
    this.idCard,
    this.address,
    this.company,
    this.position,
    this.bio,
    this.website,
    this.wechat,
    this.qq,
  });

  /// 从 JSON 创建
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      realName: json['realName'] as String?,
      idCard: json['idCard'] as String?,
      address: json['address'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      wechat: json['wechat'] as String?,
      qq: json['qq'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'realName': realName,
      'idCard': idCard,
      'address': address,
      'company': company,
      'position': position,
      'bio': bio,
      'website': website,
      'wechat': wechat,
      'qq': qq,
    };
  }

  /// 创建副本
  UserProfile copyWith({
    String? userId,
    String? realName,
    String? idCard,
    String? address,
    String? company,
    String? position,
    String? bio,
    String? website,
    String? wechat,
    String? qq,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      realName: realName ?? this.realName,
      idCard: idCard ?? this.idCard,
      address: address ?? this.address,
      company: company ?? this.company,
      position: position ?? this.position,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      wechat: wechat ?? this.wechat,
      qq: qq ?? this.qq,
    );
  }

  @override
  String toString() => 'UserProfile(userId: $userId, realName: $realName)';
}
