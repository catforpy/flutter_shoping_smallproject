# Core Exceptions 技术指南

## 目录
- [概述](#概述)
- [架构设计](#架构设计)
- [异常类型](#异常类型)
- [使用指南](#使用指南)
- [错误码参考](#错误码参考)
- [最佳实践](#最佳实践)

---

## 概述

`core_exceptions` 是一个统一的异常处理库，定义了项目中所有自定义异常类型，提供完整的异常分类和错误码体系。

### 核心特性

- **统一异常体系**：所有自定义异常继承自 `AppException`
- **分类明确**：网络、认证、数据、验证四大异常分类
- **自动状态码映射**：HTTP 状态码自动转换为对应异常类型
- **用户友好消息**：区分开发者消息和用户消息
- **完整上下文**：保留原始异常和堆栈跟踪

### 异常层次结构

```
AppException (应用异常基类)
│
├── NetworkException (网络异常)
│   ├── HttpException
│   ├── BadRequestException (400)
│   ├── UnauthorizedException (401)
│   ├── ForbiddenException (403)
│   ├── NotFoundException (404)
│   ├── RequestTimeoutException (408)
│   ├── TooManyRequestsException (429)
│   ├── ServerException (500)
│   ├── BadGatewayException (502)
│   ├── ServiceUnavailableException (503)
│   ├── GatewayTimeoutException (504)
│   ├── NetworkConnectException
│   └── NetworkParseException
│
├── AuthException (认证异常)
│   ├── TokenExpiredException
│   ├── TokenInvalidException
│   ├── NotLoginException
│   ├── UsernamePasswordException
│   ├── VerificationCodeException
│   ├── VerificationCodeExpiredException
│   ├── AccountDisabledException
│   ├── AccountAlreadyExistsException
│   ├── AccountNotExistsException
│   └── PermissionDeniedException
│
├── DataException (数据异常)
│   ├── DataNotFoundException
│   ├── DataAlreadyExistsException
│   ├── DataSaveException
│   ├── DataDeleteException
│   ├── DataUpdateException
│   ├── DataParseException
│   ├── DataFormatException
│   ├── DataConflictException
│   ├── DatabaseException
│   └── CacheException
│
└── ValidationException (验证异常)
    ├── NullParamException
    ├── InvalidParamException
    ├── OutOfRangeException
    ├── FileSizeLimitException
    └── FileNotSupportedException
```

---

## 架构设计

### 异常基类设计

```dart
/// 应用异常基类
abstract base class AppException implements Exception {
  /// 错误代码
  final String code;

  /// 错误消息（开发者）
  final String message;

  /// 原始异常
  final dynamic originalException;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  /// 获取用户友好的错误消息
  String getUserMessage() => message;
}
```

### 设计原则

1. **单一职责**：每个异常类只负责一种错误情况
2. **不可变性**：所有字段都是 `final`，确保异常不会被修改
3. **类型安全**：使用 `abstract base class` 确保异常类型正确
4. **完整上下文**：保留原始异常和堆栈跟踪，方便调试

---

## 异常类型

### 1. AppException - 基础异常

所有自定义异常的基类。

#### 内置通用异常

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `UnknownException` | `UNKNOWN_ERROR` | 未知错误 |
| `NotImplementedException` | `NOT_IMPLEMENTED` | 功能未实现 |
| `UnsupportedException` | `UNSUPPORTED` | 不支持的操作 |
| `TimeoutException` | `TIMEOUT` | 操作超时 |
| `CancelledException` | `CANCELLED` | 操作已取消 |

#### 使用示例

```dart
// 抛出未知异常
throw const UnknownException(message: '发生未知错误');

// 抛出未实现异常
throw const NotImplementedException(message: '该功能暂未实现');

// 抛出超时异常
throw const TimeoutException(message: '请求超时，请重试');
```

### 2. NetworkException - 网络异常

处理所有网络相关的错误，包括 HTTP 状态码异常。

#### HTTP 状态码映射

| 状态码 | 异常类 | 错误码 |
|--------|--------|--------|
| 400 | `BadRequestException` | `BAD_REQUEST` |
| 401 | `UnauthorizedException` | `UNAUTHORIZED` |
| 403 | `ForbiddenException` | `FORBIDDEN` |
| 404 | `NotFoundException` | `NOT_FOUND` |
| 408 | `RequestTimeoutException` | `REQUEST_TIMEOUT` |
| 429 | `TooManyRequestsException` | `TOO_MANY_REQUESTS` |
| 500 | `ServerException` | `SERVER_ERROR` |
| 502 | `BadGatewayException` | `BAD_GATEWAY` |
| 503 | `ServiceUnavailableException` | `SERVICE_UNAVAILABLE` |
| 504 | `GatewayTimeoutException` | `GATEWAY_TIMEOUT` |

#### 其他网络异常

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `NetworkConnectException` | `NETWORK_CONNECT_ERROR` | 网络连接失败 |
| `NetworkParseException` | `NETWORK_PARSE_ERROR` | 数据解析失败 |

#### 使用示例

```dart
// 自动根据状态码创建异常
final exception = NetworkException.fromStatusCode(401, 'Token 已过期');

// 手动抛出网络异常
throw const UnauthorizedException(message: '请先登录');

// 处理网络异常
try {
  await apiClient.getData();
} on NetworkException catch (e) {
  print('网络错误: ${e.getUserMessage()}');
  if (e is UnauthorizedException) {
    // 跳转到登录页
    navigateToLogin();
  }
}
```

### 3. AuthException - 认证异常

处理用户认证和授权相关的错误。

#### 认证异常类型

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `TokenExpiredException` | `TOKEN_EXPIRED` | Token 已过期 |
| `TokenInvalidException` | `TOKEN_INVALID` | Token 无效 |
| `NotLoginException` | `NOT_LOGIN` | 用户未登录 |
| `UsernamePasswordException` | `USERNAME_PASSWORD_ERROR` | 用户名或密码错误 |
| `VerificationCodeException` | `VERIFICATION_CODE_ERROR` | 验证码错误 |
| `VerificationCodeExpiredException` | `VERIFICATION_CODE_EXPIRED` | 验证码已过期 |
| `AccountDisabledException` | `ACCOUNT_DISABLED` | 账号已被禁用 |
| `AccountAlreadyExistsException` | `ACCOUNT_ALREADY_EXISTS` | 账号已存在 |
| `AccountNotExistsException` | `ACCOUNT_NOT_EXISTS` | 账号不存在 |
| `PermissionDeniedException` | `PERMISSION_DENIED` | 权限不足 |

#### 使用示例

```dart
// 登录处理
Future<User> login(String username, String password) async {
  try {
    return await authService.login(username, password);
  } on UsernamePasswordException {
    rethrow;
  } on AccountDisabledException {
    rethrow;
  } on AuthException catch (e) {
    throw AuthException(
      code: 'LOGIN_FAILED',
      message: '登录失败，请重试',
      originalException: e,
    );
  }
}

// Token 验证
Future<void> validateToken(String token) async {
  if (token.isEmpty) {
    throw const NotLoginException();
  }

  final response = await authService.validateToken(token);
  if (!response.isValid) {
    throw const TokenExpiredException();
  }
}
```

### 4. DataException - 数据异常

处理数据操作相关的错误。

#### 数据异常类型

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `DataNotFoundException` | `DATA_NOT_FOUND` | 数据不存在 |
| `DataAlreadyExistsException` | `DATA_ALREADY_EXISTS` | 数据已存在 |
| `DataSaveException` | `DATA_SAVE_FAILED` | 数据保存失败 |
| `DataDeleteException` | `DATA_DELETE_FAILED` | 数据删除失败 |
| `DataUpdateException` | `DATA_UPDATE_FAILED` | 数据更新失败 |
| `DataParseException` | `DATA_PARSE_FAILED` | 数据解析失败 |
| `DataFormatException` | `DATA_FORMAT_ERROR` | 数据格式错误 |
| `DataConflictException` | `DATA_CONFLICT` | 数据冲突 |
| `DatabaseException` | `DATABASE_ERROR` | 数据库操作失败 |
| `CacheException` | `CACHE_ERROR` | 缓存操作失败 |

#### 使用示例

```dart
// 数据获取
Future<User> getUser(String id) async {
  try {
    return await userRepository.findById(id);
  } on DataNotFoundException {
    throw DataNotFoundException(
      message: '用户 $id 不存在',
      originalException: null,
    );
  }
}

// 数据保存
Future<void> saveUser(User user) async {
  try {
    await userRepository.save(user);
  } on DatabaseException catch (e) {
    throw DataSaveException(
      message: '保存用户失败: ${e.message}',
      originalException: e,
    );
  }
}
```

### 5. ValidationException - 验证异常

处理数据验证和参数校验相关的错误。

#### 验证异常类型

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `ValidationException` | `VALIDATION_ERROR` | 数据验证失败（支持多字段错误） |
| `NullParamException` | `NULL_PARAM` | 参数为空 |
| `InvalidParamException` | `INVALID_PARAM` | 参数格式错误 |
| `OutOfRangeException` | `OUT_OF_RANGE` | 参数超出范围 |
| `FileSizeLimitException` | `FILE_SIZE_LIMIT` | 文件大小超出限制 |
| `FileNotSupportedException` | `FILE_NOT_SUPPORTED` | 文件类型不支持 |

#### 使用示例

```dart
// 单字段验证
void validateEmail(String? email) {
  if (email.isNullOrEmpty) {
    throw const NullParamException(paramName: 'email');
  }
  if (!email.isEmail) {
    throw const InvalidParamException(paramName: 'email');
  }
}

// 多字段验证
void validateUser(User user) {
  final errors = <String, String>{};

  if (user.name.isNullOrEmpty) {
    errors['name'] = '用户名不能为空';
  }

  if (!user.email.isEmail) {
    errors['email'] = '邮箱格式不正确';
  }

  if (user.age != null && (user.age! < 0 || user.age! > 150)) {
    errors['age'] = '年龄必须在 0-150 之间';
  }

  if (errors.isNotEmpty) {
    throw ValidationException(
      message: '用户信息验证失败',
      errors: errors,
    );
  }
}

// 文件验证
void validateFile(File file) {
  final size = file.lengthSync();
  if (size > 10 * 1024 * 1024) {
    throw const FileSizeLimitException(
      maxSize: 10,
      actualSize: size ~/ (1024 * 1024),
    );
  }

  final extension = file.path.split('.').last;
  if (!['jpg', 'png', 'jpeg'].contains(extension)) {
    throw FileNotSupportedException(
      fileType: extension,
      message: '仅支持 jpg、png 格式',
    );
  }
}
```

---

## 使用指南

### 场景 1：网络请求异常处理

```dart
class ApiClient {
  Future<T> request<T>(String path) async {
    try {
      final response = await httpClient.get(path);

      if (response.statusCode == 200) {
        return parseResponse<T>(response.body);
      }

      // 自动根据状态码抛出异常
      throw NetworkException.fromStatusCode(
        response.statusCode,
        response.body['message'],
      );
    } on SocketException catch (e) {
      throw const NetworkConnectException(
        message: '网络连接失败，请检查网络设置',
        originalException: e,
      );
    } on FormatException catch (e) {
      throw const NetworkParseException(
        message: '数据解析失败',
        originalException: e,
      );
    }
  }
}

// 使用
try {
  final data = await apiClient.request<User>('/user/profile');
} on UnauthorizedException {
  // 跳转到登录页
} on NetworkConnectException {
  // 显示网络错误提示
} on NetworkException catch (e) {
  // 显示错误消息
  showError(e.getUserMessage());
}
```

### 场景 2：认证流程异常处理

```dart
class AuthManager {
  Future<void> login(String username, String password) async {
    try {
      // 验证输入
      if (username.isNullOrEmpty) {
        throw const NullParamException(paramName: 'username');
      }
      if (password.isNullOrEmpty) {
        throw const NullParamException(paramName: 'password');
      }

      // 发起登录请求
      final response = await authService.login(username, password);

      if (!response.success) {
        // 根据错误码抛出对应异常
        switch (response.code) {
          case 'USERNAME_PASSWORD_ERROR':
            throw const UsernamePasswordException();
          case 'ACCOUNT_DISABLED':
            throw const AccountDisabledException();
          case 'ACCOUNT_NOT_EXISTS':
            throw const AccountNotExistsException();
          default:
            throw UnknownException(message: response.message);
        }
      }

      // 保存登录信息
      await saveToken(response.token);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'LOGIN_FAILED',
        message: '登录失败，请重试',
        originalException: e,
      );
    }
  }

  Future<void> checkLoginStatus() async {
    final token = await getToken();
    if (token.isNullOrEmpty) {
      throw const NotLoginException();
    }

    try {
      await authService.validateToken(token);
    } on TokenExpiredException {
      // Token 过期，清除登录信息
      await clearToken();
      rethrow;
    } on TokenInvalidException {
      // Token 无效，清除登录信息
      await clearToken();
      rethrow;
    }
  }
}
```

### 场景 3：表单验证异常处理

```dart
class RegistrationFormValidator {
  void validate({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String>{};

    // 验证用户名
    if (username.isNullOrEmpty) {
      errors['username'] = '用户名不能为空';
    } else if (!username.isUsername) {
      errors['username'] = '用户名必须为4-20位字母、数字或下划线';
    }

    // 验证邮箱
    if (email.isNullOrEmpty) {
      errors['email'] = '邮箱不能为空';
    } else if (!email.isEmail) {
      errors['email'] = '邮箱格式不正确';
    }

    // 验证密码
    if (password.isNullOrEmpty) {
      errors['password'] = '密码不能为空';
    } else if (!password.isPassword) {
      errors['password'] = '密码必须为8-20位，且包含字母和数字';
    }

    // 验证确认密码
    if (confirmPassword.isNullOrEmpty) {
      errors['confirmPassword'] = '请确认密码';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = '两次密码不一致';
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: '注册信息验证失败',
        errors: errors,
      );
    }
  }
}

// 使用
try {
  validator.validate(
    username: usernameController.text,
    email: emailController.text,
    password: passwordController.text,
    confirmPassword: confirmController.text,
  );
} on ValidationException catch (e) {
  // 显示错误信息
  if (e.errors != null) {
    e.errors!.forEach((field, message) {
      // 显示对应字段的错误
      showFieldError(field, message);
    });
  }
}
```

### 场景 4：数据操作异常处理

```dart
class UserRepository {
  final Database _database;

  Future<User> create(User user) async {
    try {
      // 检查用户是否已存在
      final existing = await _database.findUserByEmail(user.email);
      if (existing != null) {
        throw const DataAlreadyExistsException(
          message: '该邮箱已被注册',
        );
      }

      // 保存用户
      final id = await _database.insertUser(user);
      return user.copyWith(id: id);
    } on DatabaseException catch (e) {
      throw DataSaveException(
        message: '创建用户失败',
        originalException: e,
      );
    }
  }

  Future<User> update(User user) async {
    try {
      // 检查用户是否存在
      final existing = await _database.findUserById(user.id);
      if (existing == null) {
        throw const DataNotFoundException(
          message: '用户不存在',
        );
      }

      // 更新用户
      await _database.updateUser(user);
      return user;
    } on DatabaseException catch (e) {
      throw DataUpdateException(
        message: '更新用户失败',
        originalException: e,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      // 检查用户是否存在
      final existing = await _database.findUserById(id);
      if (existing == null) {
        throw const DataNotFoundException(
          message: '用户不存在',
        );
      }

      // 删除用户
      await _database.deleteUser(id);
    } on DatabaseException catch (e) {
      throw DataDeleteException(
        message: '删除用户失败',
        originalException: e,
      );
    }
  }
}
```

### 场景 5：全局异常处理

```dart
class ExceptionHandler {
  static String getUserMessage(dynamic exception) {
    if (exception is AppException) {
      return exception.getUserMessage();
    }

    // 处理其他类型的异常
    if (exception is SocketException) {
      return '网络连接失败';
    }

    if (exception is FormatException) {
      return '数据格式错误';
    }

    return '发生未知错误';
  }

  static String getErrorCode(dynamic exception) {
    if (exception is AppException) {
      return exception.code;
    }
    return 'UNKNOWN_ERROR';
  }

  static bool shouldShowLoginDialog(dynamic exception) {
    return exception is UnauthorizedException ||
        exception is TokenExpiredException ||
        exception is NotLoginException;
  }

  static bool shouldRetry(dynamic exception) {
    return exception is NetworkConnectException ||
        exception is RequestTimeoutException ||
        exception is GatewayTimeoutException ||
        exception is ServerException;
  }
}

// 在 UI 中使用
try {
  await viewModel.loadData();
} catch (e) {
  final message = ExceptionHandler.getUserMessage(e);

  if (ExceptionHandler.shouldShowLoginDialog(e)) {
    showLoginDialog();
  } else if (ExceptionHandler.shouldRetry(e)) {
    showRetryDialog(message, onRetry: () => viewModel.loadData());
  } else {
    showErrorDialog(message);
  }
}
```

---

## 错误码参考

### 通用错误码

| 错误码 | 说明 |
|--------|------|
| `UNKNOWN_ERROR` | 未知错误 |
| `NOT_IMPLEMENTED` | 功能未实现 |
| `UNSUPPORTED` | 不支持的操作 |
| `TIMEOUT` | 操作超时 |
| `CANCELLED` | 操作已取消 |

### 网络错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|------------|------|
| `HTTP_ERROR` | - | HTTP 请求失败 |
| `BAD_REQUEST` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未授权，请先登录 |
| `FORBIDDEN` | 403 | 无权访问 |
| `NOT_FOUND` | 404 | 请求的资源不存在 |
| `REQUEST_TIMEOUT` | 408 | 请求超时 |
| `TOO_MANY_REQUESTS` | 429 | 请求过于频繁 |
| `SERVER_ERROR` | 500 | 服务器内部错误 |
| `BAD_GATEWAY` | 502 | 网关错误 |
| `SERVICE_UNAVAILABLE` | 503 | 服务暂时不可用 |
| `GATEWAY_TIMEOUT` | 504 | 网关超时 |
| `NETWORK_CONNECT_ERROR` | - | 网络连接失败 |
| `NETWORK_PARSE_ERROR` | - | 数据解析失败 |

### 认证错误码

| 错误码 | 说明 |
|--------|------|
| `TOKEN_EXPIRED` | Token 已过期 |
| `TOKEN_INVALID` | Token 无效 |
| `NOT_LOGIN` | 用户未登录 |
| `USERNAME_PASSWORD_ERROR` | 用户名或密码错误 |
| `VERIFICATION_CODE_ERROR` | 验证码错误 |
| `VERIFICATION_CODE_EXPIRED` | 验证码已过期 |
| `ACCOUNT_DISABLED` | 账号已被禁用 |
| `ACCOUNT_ALREADY_EXISTS` | 账号已存在 |
| `ACCOUNT_NOT_EXISTS` | 账号不存在 |
| `PERMISSION_DENIED` | 权限不足 |

### 数据错误码

| 错误码 | 说明 |
|--------|------|
| `DATA_NOT_FOUND` | 数据不存在 |
| `DATA_ALREADY_EXISTS` | 数据已存在 |
| `DATA_SAVE_FAILED` | 数据保存失败 |
| `DATA_DELETE_FAILED` | 数据删除失败 |
| `DATA_UPDATE_FAILED` | 数据更新失败 |
| `DATA_PARSE_FAILED` | 数据解析失败 |
| `DATA_FORMAT_ERROR` | 数据格式错误 |
| `DATA_CONFLICT` | 数据冲突 |
| `DATABASE_ERROR` | 数据库操作失败 |
| `CACHE_ERROR` | 缓存操作失败 |

### 验证错误码

| 错误码 | 说明 |
|--------|------|
| `VALIDATION_ERROR` | 数据验证失败 |
| `NULL_PARAM` | 参数为空 |
| `INVALID_PARAM` | 参数格式错误 |
| `OUT_OF_RANGE` | 参数超出范围 |
| `FILE_SIZE_LIMIT` | 文件大小超出限制 |
| `FILE_NOT_SUPPORTED` | 文件类型不支持 |

---

## 最佳实践

### 1. 总是使用自定义异常

```dart
// ✅ 好的做法：使用自定义异常
throw const DataNotFoundException(message: '用户不存在');

// ❌ 不好的做法：使用通用异常
throw Exception('用户不存在');
```

### 2. 保留原始异常上下文

```dart
// ✅ 好的做法：保留原始异常
try {
  await database.insert(data);
} catch (e, stackTrace) {
  throw DataSaveException(
    message: '保存数据失败',
    originalException: e,
    stackTrace: stackTrace,
  );
}

// ❌ 不好的做法：丢失原始异常
try {
  await database.insert(data);
} catch (e) {
  throw const DataSaveException(message: '保存数据失败');
}
```

### 3. 提供用户友好的错误消息

```dart
// ✅ 好的做法：覆盖 getUserMessage
class HttpException extends NetworkException {
  @override
  String getUserMessage() {
    return '网络请求失败 (错误码: $statusCode)';
  }
}

// ❌ 不好的做法：直接使用技术消息
throw const HttpException(message: 'HTTP 500 Internal Server Error');
```

### 4. 使用 ValidationException 处理多字段错误

```dart
// ✅ 好的做法：一次返回所有错误
final errors = <String, String>{};
if (username.isNullOrEmpty) errors['username'] = '用户名不能为空';
if (email.isNullOrEmpty) errors['email'] = '邮箱不能为空';
if (errors.isNotEmpty) {
  throw ValidationException(errors: errors);
}

// ❌ 不好的做法：遇到第一个错误就返回
if (username.isNullOrEmpty) {
  throw const NullParamException(paramName: 'username');
}
if (email.isNullOrEmpty) {
  throw const NullParamException(paramName: 'email');
}
```

### 5. 在适当的层次处理异常

```dart
// Repository 层：抛出具体异常
Future<User> getUser(String id) async {
  final user = await database.findUserById(id);
  if (user == null) {
    throw const DataNotFoundException(message: '用户不存在');
  }
  return user;
}

// Service 层：可以转换异常
Future<UserProfile> getUserProfile(String id) async {
  try {
    final user = await repository.getUser(id);
    return UserProfile.fromUser(user);
  } on DataNotFoundException {
    throw const NotFoundException(message: '用户资料不存在');
  }
}

// UI 层：统一处理错误
try {
  final profile = await service.getUserProfile(id);
} on AppException catch (e) {
  showError(e.getUserMessage());
}
```

### 6. 使用工厂方法自动创建异常

```dart
// ✅ 好的做法：使用工厂方法
throw NetworkException.fromStatusCode(statusCode, message);

// ❌ 不好的做法：手动匹配状态码
switch (statusCode) {
  case 400:
    throw const BadRequestException();
  case 401:
    throw const UnauthorizedException();
  // ...
}
```

---

## 总结

`core_exceptions` 提供了一套完整的异常处理体系：

1. **统一基类**：所有异常继承自 `AppException`
2. **分类清晰**：网络、认证、数据、验证四大分类
3. **自动映射**：HTTP 状态码自动转换为对应异常
4. **用户友好**：区分开发者消息和用户消息
5. **完整上下文**：保留原始异常和堆栈跟踪

通过使用这套异常体系，可以：
- 统一错误处理方式
- 提供更好的用户体验
- 简化错误日志和监控
- 便于问题定位和调试
