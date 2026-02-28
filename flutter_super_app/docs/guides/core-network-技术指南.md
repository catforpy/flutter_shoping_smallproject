# core_network 网络库技术指南

> **核心功能**：基于拦截器模式的 Flutter HTTP 网络请求库

---

## 目录

1. [架构原理](#1-架构原理)
2. [核心组件](#2-核心组件)
3. [拦截器机制](#3-拦截器机制)
4. [使用示例](#4-使用示例)
5. [错误处理](#5-错误处理)
6. [技术对比](#6-技术对比)

---

## 1. 架构原理

### 1.1 设计理念

```
┌─────────────────────────────────────────────────────────────┐
│                      core_network                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              HttpClient (HTTP 客户端)                  │    │
│  │  - 基于 package:http                                  │    │
│  │  - 支持所有 HTTP 方法                                 │    │
│  │  - 自动 JSON 编解码                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                    │
│                          ▼                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         拦截器链 (Interceptor Chain)                  │    │
│  │                                                         │    │
│  │  请求方向：Request → LogInterceptor → AuthInterceptor │    │
│  │  响应方向：Response → AuthInterceptor → ErrorInterceptor│    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                    │
│                          ▼                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              ApiClient (API 客户端)                    │    │
│  │  - 提供 get/post/put/delete 方法                      │    │
│  │  - 自动解析响应数据                                   │    │
│  │  - 类型安全的泛型支持                                 │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 数据流向

```
发起请求 (apiClient.get<T>())
    │
    ▼
创建 RequestOptions
    │
    ▼
【请求拦截器链】
    │
    ├── LogInterceptor (打印请求日志)
    │
    ├── AuthInterceptor (添加 Token)
    │
    └── 自定义拦截器...
    │
    ▼
HttpClient 执行 HTTP 请求
    │
    ▼
【响应拦截器链】
    │
    ├── AuthInterceptor (处理 401)
    │
    ├── ErrorInterceptor (检查状态码)
    │
    └── LogInterceptor (打印响应日志)
    │
    ▼
返回 ApiResponse<T>
```

---

## 2. 核心组件

### 2.1 HttpClient

**职责**：底层 HTTP 请求执行

```dart
final httpClient = HttpClient(
  baseUrl: 'https://api.example.com',
  interceptors: [
    LogInterceptor(),
    AuthInterceptor(tokenGetter: () => getToken()),
  ],
);

// 执行请求
final response = await httpClient.get('/users');
```

**核心方法**：
- `get()` - GET 请求
- `post()` - POST 请求
- `put()` - PUT 请求
- `delete()` - DELETE 请求
- `request()` - 通用请求方法

### 2.2 ApiClient

**职责**：高级 API 请求封装

```dart
final apiClient = ApiClient(
  httpClient: httpClient,
  baseUrl: 'https://api.example.com',
);

// GET 请求（自动解析数据）
final users = await apiClient.get<List<User>>(
  '/users',
  queryParameters: {'page': '1'},
  dataParser: (json) => (json as List)
      .map((e) => User.fromJson(e))
      .toList(),
);
```

**特性**：
- 泛型支持：`get<T>()`、`post<T>()`
- 自动解析：`dataParser` 将 JSON 转为模型
- 统一响应：返回 `ApiDataResponse<T>`

### 2.3 响应模型

#### ApiResponse（原始响应）

```dart
final response = ApiResponse<User>(
  statusCode: 200,
  data: User(...),
  headers: {'content-type': 'application/json'},
  statusMessage: 'OK',
);

// 状态判断
response.isSuccess;     // true (200-299)
response.isClientError; // false
response.isServerError; // false
```

#### ApiDataResponse（业务响应）

```dart
final dataResponse = ApiDataResponse<User>(
  code: 0,          // 业务状态码
  message: 'success', // 业务消息
  data: User(...),   // 业务数据
  success: true,     // 是否成功
);

// 从 JSON 解析
final response = ApiDataResponse<User>.fromJson(
  json,
  dataParser: (json) => User.fromJson(json),
);
```

---

## 3. 拦截器机制

### 3.1 拦截器接口

```dart
abstract base class Interceptor {
  /// 请求拦截（在请求发送前）
  Future<RequestOptions> onRequest(RequestOptions options);

  /// 响应拦截（在响应返回后）
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response);

  /// 错误拦截（在请求失败时）
  Future<dynamic> onError(dynamic error);
}
```

### 3.2 内置拦截器

#### LogInterceptor（日志拦截器）

```dart
LogInterceptor(
  logHeaders: true,  // 是否打印请求头
  logBody: true,     // 是否打印请求体
)
```

**输出示例**：
```
┌────────────── Request ──────────────
│ Method: POST
│ URL: https://api.example.com/users
│ Headers:
│   Authorization: Bearer xxx
│ Body: {"name":"John"}
└────────────────────────────────────

┌────────────── Response ─────────────
│ Status: 200
│ Data: {"code":0,"message":"success"}
└────────────────────────────────────
```

#### AuthInterceptor（认证拦截器）

```dart
AuthInterceptor(
  tokenGetter: () => UserSession.token,           // 获取 Token
  tokenRefresher: () async => await refresh(),    // 刷新 Token
  onTokenExpired: () => logout(),                   // Token 失效回调
)
```

**工作流程**：
```
请求 → 检查 requireAuth → 添加 Token → 发送
                                    ↓
                              401 响应
                                    ↓
                       尝试刷新 Token → 重试请求
                                    ↓
                         仍 401 → 触发 onTokenExpired
```

#### ErrorInterceptor（错误拦截器）

```dart
ErrorInterceptor()
  // 自动检查状态码
  // 非 2xx 响应抛出 NetworkException
```

### 3.3 自定义拦截器

```dart
class RetryInterceptor extends BaseInterceptor {
  final int maxRetries;

  const RetryInterceptor({this.maxRetries = 3});

  @override
  Future<dynamic> onError(dynamic error) async {
    if (error is SocketException && maxRetries > 0) {
      // 网络错误，自动重试
      return retryRequest();
    }
    return error;
  }
}

// 使用
final client = HttpClient(
  interceptors: [
    RetryInterceptor(maxRetries: 3),
  ],
);
```

---

## 4. 使用示例

### 4.1 基础配置

```dart
// main.dart
void main() {
  // 1. 创建 HTTP 客户端
  final httpClient = HttpClient(
    baseUrl: 'https://api.example.com',
    interceptors: [
      // 日志拦截器
      LogInterceptor(logBody: true),

      // 认证拦截器
      AuthInterceptor(
        tokenGetter: () => UserSession.token,
        tokenRefresher: () async => await refreshToken(),
        onTokenExpired: () => navigateToLogin(),
      ),

      // 错误拦截器
      ErrorInterceptor(),
    ],
  );

  // 2. 创建 API 客户端
  final apiClient = ApiClient(
    httpClient: httpClient,
    baseUrl: 'https://api.example.com',
  );

  // 3. 注入到依赖注入容器
  final container = ProviderContainer();
  container.register(apiClient);
}
```

### 4.2 GET 请求

```dart
// 获取用户列表
final users = await apiClient.get<List<User>>(
  '/users',
  queryParameters: {
    'page': '1',
    'size': '20',
  },
  dataParser: (json) {
    return (json as List)
        .map((e) => User.fromJson(e))
        .toList();
  },
);

// 检查响应
if (users.success) {
  print('用户数量: ${users.data?.length}');
} else {
  print('错误: ${users.message}');
}
```

### 4.3 POST 请求

```dart
// 创建用户
final response = await apiClient.post<Map<String, dynamic>>(
  '/users',
  body: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
  },
);

// 检查响应
if (response.success) {
  final userId = response.data?['id'];
  print('用户创建成功，ID: $userId');
} else {
  print('创建失败: ${response.message}');
}
```

### 4.4 PUT 请求

```dart
// 更新用户
final response = await apiClient.put<Map<String, dynamic>>(
  '/users/123',
  body: {
    'name': 'Jane Doe',
    'age': 25,
  },
);
```

### 4.5 DELETE 请求

```dart
// 删除用户
final response = await apiClient.delete<Map<String, dynamic>>(
  '/users/123',
);
```

### 4.6 无需认证的请求

```dart
// 登录接口不需要 Token
final response = await apiClient.post<Map<String, dynamic>>(
  '/login',
  body: {
    'username': 'user',
    'password': 'pass',
  },
  requireAuth: false,  // 不添加 Token
);
```

### 4.7 错误处理

```dart
try {
  final response = await apiClient.get('/users');
  // 处理响应
} on NetworkException catch (e) {
  // 网络错误（404、500 等）
  print('网络错误: ${e.message}');
  print('状态码: ${e.statusCode}');
} on SocketException catch (e) {
  // 网络连接失败
  print('网络连接失败');
} on FormatException catch (e) {
  // JSON 解析错误
  print('数据格式错误');
} catch (e) {
  // 其他错误
  print('未知错误: $e');
}
```

---

## 5. 错误处理

### 5.1 错误类型

| 错误类型 | 说明 | 触发条件 |
|----------|------|----------|
| **NetworkException** | 网络错误 | HTTP 状态码非 2xx |
| **SocketException** | 连接错误 | 无法连接到服务器 |
| **FormatException** | 解析错误 | JSON 格式不正确 |

### 5.2 错误处理流程

```
HTTP 请求
    │
    ├─ 成功 (200-299) ──▶ ApiResponse
    │                         └─ onSuccess
    │
    ├─ 客户端错误 (400-499)
    │   ├─ 400: 请求参数错误
    │   ├─ 401: 未认证 → AuthInterceptor 处理
    │   ├─ 403: 无权限
    │   ├─ 404: 资源不存在
    │   └─ 429: 请求过于频繁
    │
    └─ 服务端错误 (500-599)
        ├─ 500: 服务器内部错误
        ├─ 502: 网关错误
        ├─ 503: 服务不可用
        └─ 504: 网关超时
```

### 5.3 统一错误处理

```dart
class ApiHelper {
  final ApiClient _client;

  Future<T?> safeRequest<T>(
    Future<T> Function() request, {
    T Function(dynamic)? onError,
  }) async {
    try {
      return await request();
    } on NetworkException catch (e) {
      // 处理网络错误
      showError(e.message);
      return onError?.call(e);
    } on SocketException catch (e) {
      // 处理连接错误
      showError('网络连接失败');
      return onError?.call(e);
    } catch (e) {
      // 处理其他错误
      showError('未知错误');
      return onError?.call(e);
    }
  }
}

// 使用
final result = await apiHelper.safeRequest(
  () => apiClient.get('/users'),
  onError: (error) => null,  // 返回默认值
);
```

---

## 6. 技术对比

### 6.1 core_network vs Dio

| 特性 | core_network | Dio |
|------|--------------|-----|
| **依赖** | package:http | package:dio |
| **拦截器** | 自定义接口 | 内置 Dio 拦截器 |
| **类型安全** | 泛型支持 | 泛型支持 |
| **复杂度** | 轻量级 | 功能丰富 |
| **学习曲线** | 低 | 中 |

#### Dio 示例

```dart
// Dio 配置
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
));

// 添加拦截器
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  },
  onError: (DioException error, handler) {
    if (error.response?.statusCode == 401) {
      // 处理 401
    }
    return handler.next(error);
  },
));

// 发起请求
final response = await dio.get('/users');
```

#### core_network 示例

```dart
// core_network 配置
final client = HttpClient(
  baseUrl: 'https://api.example.com',
  interceptors: [
    AuthInterceptor(tokenGetter: () => token),
    ErrorInterceptor(),
  ],
);

// 发起请求
final response = await client.get('/users');
```

### 6.2 core_network vs Fetch Client (http)

| 特性 | core_network | http |
|------|--------------|------|
| **拦截器** | ✅ 内置 | ❌ 需手动实现 |
| **JSON 解码** | ✅ 自动 | ⚠️ 手动 |
| **错误处理** | ✅ 统一 | ❌ 分散 |
| **类型安全** | ✅ 泛型 | ⚠️ 动态 |

### 6.3 为什么选择 core_network

1. **轻量级**：基于官方 http 包，依赖少
2. **可扩展**：拦截器机制，易于扩展
3. **类型安全**：泛型支持，编译时检查
4. **统一响应**：标准化的响应格式
5. **易于测试**：依赖注入，易于 mock

### 6.4 架构对比

```
┌──────────────────────────────────────┐
│  直接使用 http (不推荐)               │
│                                       │
│  get('/users')                       │
│    ├─ 手动添加 Token                  │
│    ├─ 手动处理 JSON                   │
│    ├─ 手动处理错误                    │
│    └─ 代码重复                       │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  使用 Dio (推荐)                      │
│                                       │
│  dio.get('/users')                   │
│    ├─ 自动添加 Token (拦截器)         │
│    ├─ 自动处理 JSON                   │
│    ├─ 内置错误处理                    │
│    └─ 功能强大                       │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  使用 core_network (推荐)             │
│                                       │
│  apiClient.get<List<User>>('/users') │
│    ├─ 自动添加 Token (拦截器)         │
│    ├─ 自动处理 JSON                   │
│    ├─ 自动类型转换                     │
│    └─ 轻量、可扩展                     │
└──────────────────────────────────────┘
```

---

## 总结

### 核心优势

1. **拦截器模式** - 可插拔的请求/响应处理
2. **类型安全** - 泛型支持，编译时检查
3. **自动化** - 自动 JSON 编解码、Token 添加
4. **可测试** - 依赖注入，易于 mock
5. **轻量级** - 最小依赖，按需使用

### 最佳实践

1. **统一配置** - 在 main.dart 中统一创建客户端
2. **错误处理** - 使用 try-catch 包裹请求
3. **Token 管理** - 使用 AuthInterceptor 自动管理
4. **日志记录** - 开发环境启用 LogInterceptor
5. **类型定义** - 使用泛型和 dataParser 确保类型安全

---

**参考资源**：

- [package:http 文档](https://pub.dev/packages/http)
- [Dio 文档](https://pub.dev/packages/dio)
- [Flutter 网络请求最佳实践](https://docs.flutter.dev/data-and-backend/networking)
