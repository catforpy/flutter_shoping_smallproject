/// API 常量
final class ApiConstants {
  const ApiConstants._();

  /// 基础 URL（开发环境）
  static const String baseUrlDev = 'https://dev-api.example.com';

  /// 基础 URL（测试环境）
  static const String baseUrlTest = 'https://test-api.example.com';

  /// 基础 URL（生产环境）
  static const String baseUrlProd = 'https://api.example.com';

  /// 当前基础 URL（根据编译环境切换）
  static const String baseUrl = baseUrlDev;

  /// API 版本
  static const String apiVersion = '/v1';

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 30000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 30000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 30000;

  /// API 端点
  static const Endpoints endpoints = Endpoints._();

  /// HTTP 状态码
  static const StatusCodes statusCodes = StatusCodes._();
}

/// API 端点
final class Endpoints {
  const Endpoints._();

  // ==================== 认证相关 ====================
  /// 用户登录
  String get login => '/auth/login';

  /// 用户注册
  String get register => '/auth/register';

  /// 发送验证码
  String get sendCode => '/auth/send-code';

  /// 验证码登录
  String get codeLogin => '/auth/code-login';

  /// 刷新 Token
  String get refreshToken => '/auth/refresh-token';

  /// 登出
  String get logout => '/auth/logout';

  // ==================== 用户相关 ====================
  /// 获取用户信息
  String get userInfo => '/user/info';

  /// 更新用户信息
  String get updateUserInfo => '/user/update';

  /// 上传头像
  String get uploadAvatar => '/user/avatar';

  // ==================== IM 相关 ====================
  /// 获取会话列表
  String get conversations => '/im/conversations';

  /// 获取消息列表
  String get messages => '/im/messages';

  /// 发送消息
  String get sendMessage => '/im/send';

  // ==================== 文件相关 ====================
  /// 上传文件
  String get upload => '/file/upload';

  /// 下载文件
  String get download => '/file/download';
}

/// HTTP 状态码
final class StatusCodes {
  const StatusCodes._();

  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int requestTimeout = 408;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int notImplemented = 501;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
