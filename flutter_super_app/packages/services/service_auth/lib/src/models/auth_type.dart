/// 认证类型
///
/// 定义应用支持的多种登录方式
enum AuthType {
  /// 游客模式 - 无需登录，仅可浏览
  /// 使用硬件编码标识
  guest,

  /// 手机验证码登录 - 部分开放
  /// 需要完成实名认证才能使用核心功能
  phone,

  /// 微信授权登录 - 部分开放
  /// 与手机验证码登录权限相同
  /// 启用微信支付（微信侧负责实名验证）
  wechat,

  /// 手机号+密码登录 - 部分开放
  /// 与手机验证码登录权限相同
  password,
}

/// 认证类型扩展
extension AuthTypeExtension on AuthType {
  /// 获取认证类型显示名称
  String get displayName {
    switch (this) {
      case AuthType.guest:
        return '游客';
      case AuthType.phone:
        return '手机验证码';
      case AuthType.wechat:
        return '微信授权';
      case AuthType.password:
        return '密码登录';
    }
  }

  /// 是否需要实名认证才能使用核心功能
  bool get requiresRealNameForCoreFeatures {
    switch (this) {
      case AuthType.guest:
        return true; // 游客模式即使实名也无法使用核心功能
      case AuthType.phone:
      case AuthType.wechat:
      case AuthType.password:
        return true; // 需要实名认证
    }
  }

  /// 是否可以使用微信支付
  bool get canUseWeChatPay {
    switch (this) {
      case AuthType.guest:
        return false;
      case AuthType.phone:
      case AuthType.password:
        return false; // 非微信授权登录，无法使用微信支付
      case AuthType.wechat:
        return true; // 微信授权登录可以使用微信支付
    }
  }

  /// 是否允许浏览内容
  bool get canBrowse {
    return true; // 所有认证类型都可以浏览
  }

  /// 是否允许互动（点赞、评论、收藏等）
  bool get canInteract {
    switch (this) {
      case AuthType.guest:
        return false; // 游客不能互动
      case AuthType.phone:
      case AuthType.wechat:
      case AuthType.password:
        return true; // 登录用户可以互动
    }
  }
}
