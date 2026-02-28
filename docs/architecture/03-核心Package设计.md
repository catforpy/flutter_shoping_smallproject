# 核心 Package 详细设计

> **文档版本**: v1.0.0
> **创建日期**: 2026-02-24
> **最后更新**: 2026-02-24
> **相关文档**: [02-Package依赖关系.md](./02-Package依赖关系.md)

---

## 📋 目录

- [1. 设计原则](#1-设计原则)
- [2. 基础设施层 Package](#2-基础设施层-package)
- [3. 核心能力层 Package](#3-核心能力层-package)
- [4. 业务服务层 Package](#4-业务服务层-package)
- [5. Package 开发规范](#5-package-开发规范)

---

## 1. 设计原则

### 1.1 Package 设计原则

```
✅ 单一职责
   每个 Package 只负责一个功能领域

✅ 高内聚低耦合
   内部功能紧密相关，对外依赖最少

✅ 接口隔离
   通过接口与外部交互，隐藏实现

✅ 可测试性
   每个 Package 都可独立测试

✅ 文档完善
   导出的 API 都有文档注释
```

### 1.2 Package 结构模板

```
package_name/
├── lib/
│   ├── package_name.dart           # 主导出文件
│   │
│   └── src/
│       ├── public/                 # 公共 API
│       │   ├── *.dart             # 对外导出的类/函数
│       │   └── exports.dart       # 重新导出
│       │
│       ├── private/                # 私有实现
│       │   └── *_impl.dart        # 实现细节
│       │
│       └── generated/              # 自动生成
│
├── test/                           # 测试
│   ├── unit/                       # 单元测试
│   ├── widget/                     # Widget 测试
│   └── integration/                # 集成测试
│
├── example/                        # 示例（可选）
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

---

## 2. 基础设施层 Package

### 2.1 core_base

#### 职责
- 定义基础类型
- 定义基础接口
- 提供公共抽象类

#### pubspec.yaml

```yaml
name: core_base
description: 基础类型定义
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
```

#### 导出结构

```dart
// core_base/lib/core_base.dart
library core_base;

// 基础类型
export 'src/types/result.dart';           // Result<T>
export 'src/types/either.dart';           // Either<L, R>
export 'src/types/pagination.dart';       // Pagination<T>
export 'src/types/resource.dart';         // Resource<T>

// 基础接口
export 'src/interfaces/repository.dart';   // Repository
export 'src/interfaces/usecase.dart';      // UseCase
export 'src/interfaces/datasource.dart';   // DataSource

// 公共抽象类
export 'src/base/base_controller.dart';    // BaseController
export 'src/base/base_state.dart';         // BaseState
export 'src/base/base_event.dart';         // BaseEvent
```

#### 核心类型示例

```dart
// core_base/lib/src/types/result.dart
/// 结果类型 - 统一处理成功和失败
class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.failure(this.error)
      : data = null,
        isSuccess = false;

  bool get isFailure => !isSuccess;

  R fold<R>(
    R Function(T data) success,
    R Function(Exception error) failure,
  ) {
    return isSuccess ? success(data!) : failure(error!);
  }

  TResult map<TResult>(
    TResult Function(T data) success,
    TResult Function(Exception error) failure,
  ) {
    return isSuccess ? success(data!) : failure(error!);
  }
}
```

### 2.2 core_utils

#### 职责
- 扩展方法
- 工具函数
- 常用辅助类

#### pubspec.yaml

```yaml
name: core_utils
description: 工具函数和扩展方法
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  core_base:
    path: ../core_base
  core_constants:
    path: ../core_constants

  # 第三方库
  intl: ^0.18.0
  uuid: ^4.0.0
  logger: ^2.0.0
```

#### 导出结构

```dart
// core_utils/lib/core_utils.dart
library core_utils;

// 扩展方法
export 'src/extensions/string_extension.dart';
export 'src/extensions/num_extension.dart';
export 'src/extensions/datetime_extension.dart';
export 'src/extensions/list_extension.dart';
export 'src/extensions/map_extension.dart';
export 'src/extensions/build_context_extension.dart';

// 工具类
export 'src/helpers/validator_helper.dart';
export 'src/helpers/formatter_helper.dart';
export 'src/helpers/timer_helper.dart';
export 'src/helpers/image_helper.dart';
export 'src/helpers/device_helper.dart';
```

#### 扩展方法示例

```dart
// core_utils/lib/src/extensions/string_extension.dart
/// String 扩展方法
extension StringExtension on String? {
  /// 判断是否为空
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 判断是否不为空
  bool get isNotNullOrNotEmpty => !isNullOrEmpty;

  /// 首字母大写
  String get capitalize {
    if (isNullOrEmpty) return '';
    final str = this!;
    return str[0].toUpperCase() + str.substring(1);
  }

  /// 移除所有空格
  String get removeAllSpaces {
    if (isNullOrEmpty) return '';
    return this!.replaceAll(' ', '');
  }

  /// 验证手机号
  bool get isPhoneNumber {
    if (isNullOrEmpty) return false;
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this!);
  }

  /// 验证邮箱
  bool get isEmail {
    if (isNullOrEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this!);
  }

  /// 隐藏手机号中间四位
  String get maskPhoneNumber {
    if (!isPhoneNumber) return this ?? '';
    return this!.replaceRange(3, 7, '****');
  }

  /// 解析为颜色
  Color get toColor {
    if (isNullOrEmpty) return Colors.transparent;
    final hex = this!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### 2.3 core_constants

#### 职责
- 定义应用常量
- 定义配置常量

#### pubspec.yaml

```yaml
name: core_constants
description: 常量定义
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
```

#### 导出结构

```dart
// core_constants/lib/core_constants.dart
library core_constants;

// 应用常量
export 'src/constants/app_constants.dart';
export 'src/constants/api_constants.dart';
export 'src/constants/storage_constants.dart';
export 'src/constants/route_constants.dart';

// 设计规范
export 'src/constants/design_constants.dart';
export 'src/constants/animation_constants.dart';
```

#### 常量定义示例

```dart
// core_constants/lib/src/constants/app_constants.dart
/// 应用常量
class AppConstants {
  // 应用信息
  static const String appName = 'Your Super App';
  static const String appVersion = '1.0.0';

  // 环境配置
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const bool isDebug = environment != 'production';

  // 默认配置
  static const int defaultPageSize = 20;
  static const int maxRetryCount = 3;
  static const Duration defaultTimeout = Duration(seconds: 30);

  // 平台信息
  static const bool isIOS = bool.fromEnvironment('dart.library.io') ?
    Platform.isIOS : false;
  static const bool isAndroid = bool.fromEnvironment('dart.library.io') ?
    Platform.isAndroid : false;
  static const bool isWeb = kIsWeb;
}
```

### 2.4 core_exceptions

#### 职责
- 定义异常类型
- 统一异常处理

#### pubspec.yaml

```yaml
name: core_exceptions
description: 异常定义
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  core_base:
    path: ../core_base
```

#### 导出结构

```dart
// core_exceptions/lib/core_exceptions.dart
library core_exceptions;

// 异常类型
export 'src/exceptions/app_exception.dart';
export 'src/exceptions/network_exception.dart';
export 'src/exceptions/auth_exception.dart';
export 'src/exceptions/validation_exception.dart';
export 'src/exceptions/cache_exception.dart';

// 异常处理
export 'src/exception_handler.dart';
```

#### 异常定义示例

```dart
// core_exceptions/lib/src/exceptions/app_exception.dart
/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// 网络异常
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory NetworkException.timeout() {
    return const NetworkException(
      message: '网络请求超时',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: '网络连接失败',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.fromStatusCode(int statusCode) {
    String message;
    switch (statusCode) {
      case 400:
        message = '请求参数错误';
        break;
      case 401:
        message = '未授权，请重新登录';
        break;
      case 403:
        message = '没有权限访问';
        break;
      case 404:
        message = '请求的资源不存在';
        break;
      case 500:
        message = '服务器内部错误';
        break;
      default:
        message = '网络请求失败 ($statusCode)';
    }
    return NetworkException(
      message: message,
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
    );
  }
}

/// 认证异常
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory AuthException.tokenExpired() {
    return const AuthException(
      message: '登录已过期，请重新登录',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthException.unauthorized() {
    return const AuthException(
      message: '未授权，请先登录',
      code: 'UNAUTHORIZED',
    );
  }
}
```

### 2.5 core_logging

#### 职责
- 提供日志功能
- 日志分级管理
- 日志持久化

#### pubspec.yaml

```yaml
name: core_logging
description: 日志系统
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  core_base:
    path: ../core_base

  # 第三方库
  logger: ^2.0.0
  path_provider: ^2.1.0
```

#### 导出结构

```dart
// core_logging/lib/core_logging.dart
library core_logging;

// 日志器
export 'src/app_logger.dart';

// 日志级别
export 'src/log_level.dart';

// 日志输出
export 'src/log_output.dart';
```

#### 日志实现示例

```dart
// core_logging/lib/src/app_logger.dart
/// 应用日志器
class AppLogger {
  static AppLogger? _instance;
  late Logger _logger;

  static AppLogger get instance {
    _instance ??= AppLogger._internal();
    return _instance!;
  }

  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
        noBoxingByDefault: false,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(),
      ]),
    );
  }

  /// 调试日志
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 信息日志
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 警告日志
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 错误日志
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 致命错误日志
  void wtf(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.wtf(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
```

---

## 3. 核心能力层 Package

### 3.1 core_network

#### 职责
- 封装网络请求
- 统一响应处理
- 请求拦截器
- 错误处理

#### pubspec.yaml

```yaml
name: core_network
description: 网络请求封装
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter

  # 基础设施层
  core_base:
    path: ../core_base
  core_utils:
    path: ../core_utils
  core_exceptions:
    path: ../core_exceptions
  core_logging:
    path: ../core_logging
  core_constants:
    path: ../core_constants

  # 第三方库
  dio: ^5.4.0
  connectivity_plus: ^5.0.0
  cookie_jar: ^4.0.0
  pretty_dio_logger: ^1.3.0
```

#### 导出结构

```dart
// core_network/lib/core_network.dart
library core_network;

// 客户端
export 'src/dio_client.dart';

// 请求封装
export 'src/api_request.dart';
export 'src/api_response.dart';

// 拦截器
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/log_interceptor.dart';
export 'src/interceptors/cache_interceptor.dart';
export 'src/interceptors/error_interceptor.dart';

// 异常处理
export 'src/network_exception.dart';
```

#### 核心实现示例

```dart
// core_network/lib/src/dio_client.dart
/// Dio 网络客户端
class DioClient {
  final Dio _dio;
  final String baseUrl;

  DioClient({
    required this.baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    List<Interceptor> interceptors = const [],
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // 添加默认拦截器
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(),
      ErrorInterceptor(),
      ...interceptors,
    ]);
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> upload<T>(
    String path,
    File file, {
    ProgressCallback? onSendProgress,
    Map<String, dynamic>? data,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      ...?data,
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return ApiResponse<T>.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 下载文件
  Future<void> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 错误处理
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.badResponse:
        return NetworkException.fromStatusCode(
          error.response?.statusCode ?? -1,
        );

      case DioExceptionType.cancel:
        return const AppException(message: '请求已取消');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException.noConnection();
        }
        return AppException(
          message: error.message ?? '网络请求失败',
          originalError: error.error,
        );

      default:
        return AppException(
          message: error.message ?? '未知错误',
          originalError: error.error,
        );
    }
  }
}
```

### 3.2 core_database

#### 职责
- 数据库连接管理
- CRUD 操作封装
- 事务管理
- 迁移管理

#### pubspec.yaml

```yaml
name: core_database
description: 数据库封装
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter

  # 基础设施层
  core_base:
    path: ../core_base
  core_logging:
    path: ../core_logging

  # 第三方库
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  path: ^1.8.0
```

#### 导出结构

```dart
// core_database/lib/core_database.dart
library core_database;

// 数据库
export 'src/app_database.dart';

// 基类
export 'src/base/base_entity.dart';
export 'src/base/base_dao.dart';

// 工具
export 'src/database_helper.dart';
```

### 3.3 core_cache

#### 职责
- 多级缓存管理
- 内存缓存
- 持久化缓存
- 缓存策略

#### pubspec.yaml

```yaml
name: core_cache
description: 多级缓存
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter

  # 基础设施层
  core_base:
    path: ../core_base
  core_logging:
    path: ../core_logging

  # 核心能力层
  core_database:
    path: ../core_database

  # 第三方库
  shared_preferences: ^2.2.0
  flutter_cache_manager: ^3.3.0
```

#### 多级缓存实现

```dart
// core_cache/lib/src/multi_level_cache.dart
/// 多级缓存管理器
class MultiLevelCache {
  final MemoryCache _memoryCache;
  final PersistentCache _persistentCache;

  MultiLevelCache({
    required MemoryCache memoryCache,
    required PersistentCache persistentCache,
  })  : _memoryCache = memoryCache,
        _persistentCache = persistentCache;

  /// 获取缓存 - L1 → L2
  Future<T?> get<T>(String key) async {
    // L1: 内存缓存
    final memoryValue = await _memoryCache.get<T>(key);
    if (memoryValue != null) {
      return memoryValue;
    }

    // L2: 持久化缓存
    final persistentValue = await _persistentCache.get<T>(key);
    if (persistentValue != null) {
      // 回写到内存
      await _memoryCache.set(key, persistentValue);
      return persistentValue;
    }

    return null;
  }

  /// 设置缓存 - 同时写入 L1 和 L2
  Future<void> set<T>(String key, T value) async {
    await Future.wait([
      _memoryCache.set(key, value),
      _persistentCache.set(key, value),
    ]);
  }

  /// 删除缓存
  Future<void> delete(String key) async {
    await Future.wait([
      _memoryCache.delete(key),
      _persistentCache.delete(key),
    ]);
  }

  /// 清空所有缓存
  Future<void> clear() async {
    await Future.wait([
      _memoryCache.clear(),
      _persistentCache.clear(),
    ]);
  }
}
```

---

## 4. 业务服务层 Package

### 4.1 service_user

#### 职责
- 用户信息管理
- 用户关系管理
- 用户设置管理

#### pubspec.yaml

```yaml
name: service_user
description: 用户服务
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter

  # 核心能力层
  core_network:
    path: ../../core/core_network
  core_database:
    path: ../../core/core_database
  core_cache:
    path: ../../core/core_cache
  core_state:
    path: ../../core/core_state
  core_utils:
    path: ../../core/core_utils

  # 第三方库
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

#### 导出结构

```dart
// service_user/lib/service_user.dart
library service_user;

// 服务
export 'src/user_service.dart';

// 模型
export 'src/models/user_model.dart';
export 'src/models/user_relation_model.dart';

// 仓库
export 'src/repository/user_repository.dart';

// 用例
export 'src/usecases/get_user_usecase.dart';
export 'src/usecases/update_user_usecase.dart';
```

---

## 5. Package 开发规范

### 5.1 命名规范

```
Package 命名:
   - 格式: {layer}_{feature}
   - 示例: core_network, service_user, module_shop

文件命名:
   - 类文件: lower_snake_case.dart (user_service.dart)
   - 页面文件: {feature}_page.dart (user_list_page.dart)
   - 组件文件: {feature}_{widget}.dart (user_card_widget.dart)

类命名:
   - PascalCase (UserService)

变量/方法命名:
   - camelCase (getUserInfo)

常量命名:
   - lowerCamelCase (defaultPageSize)

私有成员:
   - 下划线前缀 (_privateField)
```

### 5.2 文档规范

```dart
/// 类/方法文档注释
///
/// 详细说明...
///
/// - 参数说明
/// - 返回值说明
/// - 异常说明
///
/// Example:
/// ```dart
/// final service = UserService();
/// final user = await service.getUser('123');
/// ```
class UserService {
  /// 获取用户信息
  ///
  /// [userId] 用户ID
  ///
  /// 返回 [UserModel] 用户信息
  ///
  /// 抛出 [NetworkException] 网络错误
  /// 抛出 [AuthException] 未授权
  Future<UserModel> getUser(String userId) async {
    // ...
  }
}
```

### 5.3 导出规范

```dart
// ✅ 推荐: 只导出公共 API
library package_name;

export 'src/public/api.dart';
export 'src/public/models.dart';

// ❌ 不推荐: 导出私有实现
library package_name;

export 'src/private/implementation.dart'; // 错误
```

### 5.4 测试规范

```dart
// test/unit/user_service_test.dart
void main() {
  group('UserService', () {
    late UserService userService;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      userService = UserService(repository: mockRepository);
    });

    test('getUser 应该返回用户信息', () async {
      // Arrange
      const userId = '123';
      final expectedUser = UserModel(id: userId, name: 'Test');
      when(mockRepository.getUser(userId))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await userService.getUser(userId);

      // Assert
      expect(result, equals(expectedUser));
      verify(mockRepository.getUser(userId)).called(1);
    });
  });
}
```

---

## 6. 附录

### 6.1 Package 检查清单

```
创建 Package 时检查:
□ pubspec.yaml 配置完整
□ 主导出文件 (package_name.dart)
□ README.md 文档
□ CHANGELOG.md 版本记录
□ 单元测试覆盖率 ≥ 80%
□ 示例代码 (example/)

发布 Package 前检查:
□ 所有导出 API 有文档注释
□ 运行 flutter analyze 无错误
□ 运行 flutter test 全部通过
□ 更新版本号和 CHANGELOG
```

### 6.2 相关文档

- [00-架构概览.md](./00-架构概览.md)
- [01-架构分层职责.md](./01-架构分层职责.md)
- [02-Package依赖关系.md](./02-Package依赖关系.md)

---

**更新记录**

| 版本 | 日期 | 变更内容 | 负责人 |
|------|------|----------|--------|
| v1.0.0 | 2026-02-24 | 初始版本 | 架构团队 |
