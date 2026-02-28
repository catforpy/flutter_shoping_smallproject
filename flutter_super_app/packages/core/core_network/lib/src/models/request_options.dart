library;

import 'package:flutter/foundation.dart';

// ============================================================
// 请求模型层
// ============================================================
// 设计理念：
// 1. 不可变数据结构（所有属性 final）
// 2. 提供 copyWith 方法用于修改
// 3. 支持链式构建 URL

// ============================================================
// HTTP 请求方法枚举
// ============================================================

/// HTTP 请求方法枚举
///
/// 定义了常用的 HTTP 请求方法。
///
/// ## 使用示例
/// ```dart
/// final method = RequestMethod.post;
/// print(method.value);  // 输出: POST
/// ```
///
/// ## HTTP 方法对比
/// | 方法 | 用途 | 幂等性 | 缓存 |
/// |------|------|--------|------|
/// | GET | 获取资源 | ✅ | ✅ |
/// | POST | 创建资源 | ❌ | ❌ |
/// | PUT | 更新资源（全量） | ✅ | ❌ |
/// | DELETE | 删除资源 | ✅ | ❌ |
/// | PATCH | 更新资源（部分） | ❌ | ❌ |
/// | HEAD | 获取响应头 | ✅ | ✅ |
final class RequestMethod {
  /// GET 方法值
  final String value;

  const RequestMethod(this.value);

  /// GET 请求 - 获取资源
  ///
  /// 用于请求数据，不修改服务器状态。
  /// 特点：
  /// - 幂等：多次请求结果相同
  /// - 可缓存：响应可以被浏览器缓存
  /// - 参数限制：URL 长度限制（通常 2048 字符）
  static const get = RequestMethod('GET');

  /// POST 请求 - 创建资源
  ///
  /// 用于向服务器提交数据。
  /// 特点：
  /// - 非幂等：多次请求可能创建多个资源
  /// - 不可缓存：响应默认不被缓存
  /// - 数据量：支持大量数据（请求体）
  static const post = RequestMethod('POST');

  /// PUT 请求 - 更新资源（全量）
  ///
  /// 用于更新资源的完整数据。
  /// 特点：
  /// - 幂等：多次请求结果相同
  /// - 不可缓存：响应默认不被缓存
  /// - 全量更新：替换整个资源
  static const put = RequestMethod('PUT');

  /// DELETE 请求 - 删除资源
  ///
  /// 用于删除指定资源。
  /// 特点：
  /// - 幂等：多次删除结果相同
  /// - 不可缓存：响应默认不被缓存
  static const delete = RequestMethod('DELETE');

  /// PATCH 请求 - 更新资源（部分）
  ///
  /// 用于更新资源的部分数据。
  /// 特点：
  /// - 非幂等：取决于实现
  /// - 不可缓存：响应默认不被缓存
  /// - 部分更新：只修改提供的字段
  static const patch = RequestMethod('PATCH');

  /// HEAD 请求 - 获取响应头
  ///
  /// 用于获取资源的响应头，不返回响应体。
  /// 特点：
  /// - 幂等：多次请求结果相同
  /// - 可缓存：响应可以被缓存
  /// - 性能：只返回响应头，节省带宽
  static const head = RequestMethod('HEAD');
}

// ============================================================
// 请求选项
// ============================================================

/// 请求选项
///
/// 封装 HTTP 请求的所有配置信息。
/// 不可变对象，通过 copyWith 方法创建修改后的副本。
///
/// ## 设计理念
/// - 不可变性：所有属性 final，线程安全
/// - 可组合：通过 copyWith 修改部分属性
/// - 类型安全：使用枚举而非字符串
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// final options = RequestOptions(
///   url: '/users/123',
///   method: RequestMethod.get,
/// );
///
/// // 带查询参数
/// final options = RequestOptions(
///   url: '/users',
///   method: RequestMethod.get,
///   queryParameters: {'page': '1', 'size': '20'},
/// );
///
/// // 带请求体
/// final options = RequestOptions(
///   url: '/users',
///   method: RequestMethod.post,
///   body: {'name': 'John', 'age': 30},
/// );
///
/// // 使用 copyWith 修改
/// final newOptions = options.copyWith(
///   headers: {'Authorization': 'Bearer token'},
/// );
///
/// // 构建 URL（包含查询参数）
/// final url = options.buildUrl();
/// // 输出: /users?page=1&size=20
/// ```
///
/// ## requireAuth 参数
/// - true: 需要认证，AuthInterceptor 会自动添加 Token
/// - false: 不需要认证，跳过 Token 添加
///
/// ## 与其他框架对比
///
/// ### Axios (Web)
/// ```javascript
/// // Axios 配置对象
/// axios({
///   url: '/users',
///   method: 'GET',
///   headers: { 'Authorization': 'Bearer token' },
///   params: { page: 1 },
///   data: { name: 'John' },
/// })
/// ```
///
/// ### Dio (Flutter)
/// ```dart
/// await dio.get(
///   '/users',
///   queryParameters: {'page': '1'},
///   options: Options(headers: {'Auth': 'Bearer token'}),
/// );
/// ```
final class RequestOptions {
  // ========== 基础属性 ==========

  /// 请求 URL（相对路径或完整 URL）
  ///
  /// 相对路径：'/users' → 会拼接 baseUrl
  /// 完整 URL：'https://api.example.com/users' → 直接使用
  final String url;

  /// HTTP 请求方法
  ///
  /// 默认为 GET，支持 GET/POST/PUT/DELETE/PATCH/HEAD
  final RequestMethod method;

  // ========== 请求配置 ==========

  /// 请求头（HTTP Headers）
  ///
  /// 常用请求头：
  /// - Content-Type: application/json
  /// - Authorization: Bearer {token}
  /// - Accept: application/json
  final Map<String, String>? headers;

  /// URL 查询参数（Query Parameters）
  ///
  /// 会被拼接在 URL 后面：?key1=value1&key2=value2
  ///
  /// 示例：
  /// ```dart
  /// queryParameters: {
  ///   'page': '1',
  ///   'size': '20',
  ///   'keyword': 'flutter',
  /// }
  /// // 最终 URL: /api/users?page=1&size=20&keyword=flutter
  /// ```
  final Map<String, dynamic>? queryParameters;

  /// 请求体（Request Body）
  ///
  /// 用于 POST/PUT/PATCH 请求，会被编码为 JSON。
  ///
  /// 支持的类型：
  /// - Map<String, dynamic>: 自动转为 JSON
  /// - List: 自动转为 JSON 数组
  /// - String: 直接作为请求体
  /// - 其他: 调用 toString() 转为字符串
  final dynamic body;

  /// 请求超时时间（毫秒）
  ///
  /// null 则使用默认超时时间
  final int? timeout;

  /// 是否需要认证
  ///
  /// - true: AuthInterceptor 会自动添加 Token
  /// - false: 跳过 Token 添加（用于登录接口等）
  ///
  /// 示例：
  /// ```dart
  /// // 需要认证的请求
  /// RequestOptions(
  ///   url: '/user/profile',
  ///   requireAuth: true,  // 默认值
  /// )
  ///
  /// // 不需要认证的请求
  /// RequestOptions(
  ///   url: '/login',
  ///   requireAuth: false,
  /// )
  /// ```
  final bool requireAuth;

  // ========== 构造函数 ==========

  const RequestOptions({
    required this.url,                        // 必填：请求 URL
    this.method = RequestMethod.get,          // 默认：GET 请求
    this.headers,                             // 可选：请求头
    this.queryParameters,                     // 可选：查询参数
    this.body,                                // 可选：请求体
    this.timeout,                             // 可选：超时时间
    this.requireAuth = true,                  // 默认：需要认证
  });

  // ========== 方法 ==========

  /// 复制并修改部分属性
  ///
  /// 返回一个新的 RequestOptions 实例，只修改指定的属性。
  ///
  /// ## 使用示例
  /// ```dart
  /// final original = RequestOptions(url: '/users');
  ///
  /// // 只修改 method
  /// final modified = original.copyWith(
  ///   method: RequestMethod.post,
  /// );
  ///
  /// // 修改多个属性
  /// final modified2 = original.copyWith(
  ///   method: RequestMethod.post,
  ///   body: {'name': 'John'},
  ///   headers: {'Content-Type': 'application/json'},
  /// );
  ///
  /// // 原对象不受影响
  /// print(original.method.value);   // GET
  /// print(modified.method.value);   // POST
  /// ```
  ///
  /// ## 为什么使用 copyWith？
  /// - 保持不可变性：原对象不会被修改
  /// - 链式调用：可以连续调用 copyWith
  /// - 线程安全：不可变对象天然线程安全
  RequestOptions copyWith({
    String? url,
    RequestMethod? method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    int? timeout,
    bool? requireAuth,
  }) {
    return RequestOptions(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      body: body ?? this.body,
      timeout: timeout ?? this.timeout,
      requireAuth: requireAuth ?? this.requireAuth,
    );
  }

  /// 构建 URL（包含查询参数）
  ///
  /// 将 queryParameters 拼接到 URL 后面。
  ///
  /// ## 规则
  /// - 无查询参数：返回原 URL
  /// - 有查询参数：拼接 ?key=value&key2=value2
  /// - URL 已有 ?：使用 & 拼接
  ///
  /// ## 示例
  /// ```dart
  /// // 无查询参数
  /// RequestOptions(url: '/users').buildUrl();
  /// // 输出: /users
  ///
  /// // 有查询参数
  /// RequestOptions(
  ///   url: '/users',
  ///   queryParameters: {'page': '1', 'size': '20'},
  /// ).buildUrl();
  /// // 输出: /users?page=1&size=20
  ///
  /// // URL 已有参数
  /// RequestOptions(
  ///   url: '/users?status=active',
  ///   queryParameters: {'page': '1'},
  /// ).buildUrl();
  /// // 输出: /users?status=active&page=1
  /// ```
  @visibleForTesting
  String buildUrl() {
    // 无查询参数，直接返回 URL
    if (queryParameters == null || queryParameters!.isEmpty) {
      return url;
    }

    // 构建查询字符串
    final queryString = queryParameters!
        .entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    // URL 已有参数，用 & 连接
    if (url.contains('?')) {
      return '$url&$queryString';
    }

    // URL 无参数，用 ? 连接
    return '$url?$queryString';
  }

  @override
  String toString() {
    return 'RequestOptions(method: ${method.value}, url: $url)';
  }
}
