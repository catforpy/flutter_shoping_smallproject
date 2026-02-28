# Core Constants 技术指南

## 目录
- [概述](#概述)
- [架构设计](#架构设计)
- [常量分类](#常量分类)
- [使用指南](#使用指南)
- [最佳实践](#最佳实践)

---

## 概述

`core_constants` 是一个统一的常量定义库，集中管理项目中所有的常量值，提供单一数据源（Single Source of Truth）。

### 核心特性

- **统一管理**：所有常量集中定义，便于维护
- **分类清晰**：按功能划分为 5 大类常量
- **类型安全**：使用 `final class` 确保常量不可修改
- **私有构造**：使用私有构造函数防止实例化
- **文档完善**：每个常量都有清晰的中文注释

### 包结构

```
core_constants
├── lib/
│   ├── src/
│   │   └── constants/
│   │       ├── app_constants.dart          # 应用常量
│   │       ├── api_constants.dart          # API 常量
│   │       ├── storage_keys.dart           # 存储键常量
│   │       ├── regex_constants.dart        # 正则表达式常量
│   │       └── date_format_constants.dart  # 日期格式常量
│   └── core_constants.dart                 # 统一导出
└── test/
```

---

## 架构设计

### 常量类设计模式

所有常量类都采用相同的设计模式：

```dart
/// 常量类
final class XxxConstants {
  // 私有构造函数，防止实例化
  const XxxConstants._();

  /// 常量定义
  static const String someConstant = 'value';

  /// 嵌套类
  static const NestedClass nested = NestedClass._();
}

/// 嵌套常量类
final class NestedClass {
  const NestedClass._();

  /// 常量定义
  static const String nestedConstant = 'value';
}
```

### 设计原则

1. **不可变性**：使用 `final class` 和 `const` 确保常量不可修改
2. **私有构造**：使用 `._()` 私有构造函数防止实例化
3. **静态访问**：所有常量都是 `static const`，通过类名访问
4. **逻辑分组**：相关常量放在一起，使用注释分隔

---

## 常量分类

### 1. AppConstants - 应用常量

定义应用程序的基础配置常量。

#### 应用信息

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `appName` | String | `Flutter Super App` | 应用名称 |
| `appPackage` | String | `com.example.flutter_super_app` | 应用包名 |
| `appVersion` | String | `1.0.0` | 应用版本 |
| `appBuildNumber` | int | `1` | 应用版本号 |

#### 本地化配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `defaultLanguage` | String | `zh-CN` | 默认语言 |
| `defaultTimeZone` | String | `Asia/Shanghai` | 默认时区 |

#### 分页配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `defaultPageSize` | int | `20` | 默认每页数量 |
| `maxPageSize` | int | `100` | 最大每页数量 |
| `minPageSize` | int | `10` | 最小每页数量 |

#### 超时配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `defaultTimeoutSeconds` | int | `30` | 默认超时时间（秒） |

#### 文件大小限制

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `maxImageSizeMB` | int | `10` | 图片最大大小（MB） |
| `maxVideoSizeMB` | int | `100` | 视频最大大小（MB） |
| `maxFileSizeMB` | int | `50` | 文件最大大小（MB） |
| `defaultImageQuality` | int | `85` | 默认图片质量 |

#### 缓存配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `cacheExpireDays` | int | `7` | 缓存过期时间（天） |

#### 重试配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `maxRetryCount` | int | `3` | 最大重试次数 |

#### 用户验证规则

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `usernameMinLength` | int | `4` | 用户名最小长度 |
| `usernameMaxLength` | int | `20` | 用户名最大长度 |
| `passwordMinLength` | int | `8` | 密码最小长度 |
| `passwordMaxLength` | int | `20` | 密码最大长度 |
| `verificationCodeLength` | int | `6` | 验证码长度 |
| `verificationCodeExpireSeconds` | int | `300` | 验证码过期时间（秒） |

#### 使用示例

```dart
// 获取应用信息
final appName = AppConstants.appName;
final version = AppConstants.appVersion;

// 分页请求
final response = await api.getUsers(
  page: 1,
  pageSize: AppConstants.defaultPageSize,
);

// 文件上传验证
if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
  throw '图片大小不能超过 ${AppConstants.maxImageSizeMB}MB';
}
```

### 2. ApiConstants - API 常量

定义 API 相关的常量，包括 URL、端点、状态码等。

#### 环境配置

| 常量名 | 类型 | 说明 |
|--------|------|------|
| `baseUrlDev` | String | 开发环境 URL |
| `baseUrlTest` | String | 测试环境 URL |
| `baseUrlProd` | String | 生产环境 URL |
| `baseUrl` | String | 当前使用的 URL |
| `apiVersion` | String | API 版本 |

#### 超时配置

| 常量名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `connectTimeout` | int | `30000` | 连接超时（毫秒） |
| `receiveTimeout` | int | `30000` | 接收超时（毫秒） |
| `sendTimeout` | int | `30000` | 发送超时（毫秒） |

#### API 端点（Endpoints）

| 端点名 | 路径 | 说明 |
|--------|------|------|
| `login` | `/auth/login` | 用户登录 |
| `register` | `/auth/register` | 用户注册 |
| `sendCode` | `/auth/send-code` | 发送验证码 |
| `codeLogin` | `/auth/code-login` | 验证码登录 |
| `refreshToken` | `/auth/refresh-token` | 刷新 Token |
| `logout` | `/auth/logout` | 登出 |
| `userInfo` | `/user/info` | 获取用户信息 |
| `updateUserInfo` | `/user/update` | 更新用户信息 |
| `uploadAvatar` | `/user/avatar` | 上传头像 |
| `conversations` | `/im/conversations` | 获取会话列表 |
| `messages` | `/im/messages` | 获取消息列表 |
| `sendMessage` | `/im/send` | 发送消息 |
| `upload` | `/file/upload` | 上传文件 |
| `download` | `/file/download` | 下载文件 |

#### HTTP 状态码（StatusCodes）

| 状态码 | 常量名 | 说明 |
|--------|--------|------|
| 200 | `ok` | 请求成功 |
| 201 | `created` | 创建成功 |
| 202 | `accepted` | 已接受 |
| 204 | `noContent` | 无内容 |
| 400 | `badRequest` | 请求参数错误 |
| 401 | `unauthorized` | 未授权 |
| 403 | `forbidden` | 禁止访问 |
| 404 | `notFound` | 资源不存在 |
| 405 | `methodNotAllowed` | 方法不允许 |
| 408 | `requestTimeout` | 请求超时 |
| 409 | `conflict` | 冲突 |
| 422 | `unprocessableEntity` | 无法处理的实体 |
| 429 | `tooManyRequests` | 请求过多 |
| 500 | `internalServerError` | 服务器内部错误 |
| 501 | `notImplemented` | 未实现 |
| 502 | `badGateway` | 网关错误 |
| 503 | `serviceUnavailable` | 服务不可用 |
| 504 | `gatewayTimeout` | 网关超时 |

#### 使用示例

```dart
// 配置 HTTP 客户端
final client = HttpClient(
  baseUrl: ApiConstants.baseUrl,
  connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
);

// 发起登录请求
final response = await client.post(
  ApiConstants.endpoints.login,
  body: {'username': username, 'password': password},
);

// 检查状态码
if (response.statusCode == ApiConstants.statusCodes.ok) {
  // 请求成功
} else if (response.statusCode == ApiConstants.statusCodes.unauthorized) {
  // 未授权
}
```

### 3. StorageKeys - 存储键常量

定义本地存储的键名，避免字符串硬编码。

#### 用户相关

| 键名 | 说明 |
|------|------|
| `currentUser` | 当前用户信息 |
| `accessToken` | 用户 Token |
| `refreshToken` | 刷新 Token |
| `tokenExpireTime` | Token 过期时间 |

#### 设置相关

| 键名 | 说明 |
|------|------|
| `language` | 语言设置 |
| `theme` | 主题设置 |
| `notificationEnabled` | 是否开启通知 |

#### 缓存相关

| 键名 | 说明 |
|------|------|
| `homeCache` | 首页数据缓存 |
| `userListCache` | 用户列表缓存 |

#### 其他

| 键名 | 说明 |
|------|------|
| `isFirstLaunch` | 是否首次启动 |
| `lastLoginTime` | 最后登录时间 |
| `deviceId` | 设备 ID |
| `privacyAgreed` | 隐私协议已同意 |

#### 使用示例

```dart
// 保存 Token
await storage.setString(StorageKeys.accessToken, token);

// 获取用户信息
final userJson = await storage.getString(StorageKeys.currentUser);
final user = userJson != null ? User.fromJson(jsonDecode(userJson)) : null;

// 检查是否首次启动
final isFirstLaunch = await storage.getBool(StorageKeys.isFirstLaunch) ?? true;

// 清除用户相关数据
await storage.remove(StorageKeys.accessToken);
await storage.remove(StorageKeys.refreshToken);
await storage.remove(StorageKeys.currentUser);
```

### 4. RegexConstants - 正则表达式常量

定义常用的正则表达式，避免重复定义。

#### 数据验证正则

| 正则名 | 模式 | 说明 |
|--------|------|------|
| `phone` | `^1[3-9]\d{9}$` | 手机号（中国大陆） |
| `email` | `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` | 邮箱 |
| `idCard` | `^\d{17}[\dXx]$` | 身份证号（中国大陆） |
| `username` | `^[a-zA-Z0-9_]{4,20}$` | 用户名 |
| `password` | `^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,20}$` | 密码 |
| `url` | `^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$` | URL |
| `ipv4` | `^((25[0-5]\|2[0-4][0-9]\|[01]?[0-9][0-9]?)\.){3}(25[0-5]\|2[0-4][0-9]\|[01]?[0-9][0-9]?)$` | IPv4 地址 |

#### 业务相关正则

| 正则名 | 模式 | 说明 |
|--------|------|------|
| `licensePlate` | `^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-HJ-NP-Z0-9]{5,6}$` | 车牌号 |
| `bankCard` | `^\d{16,19}$` | 银行卡号 |
| `postalCode` | `^\d{6}$` | 邮政编码 |
| `wechatId` | `^[a-zA-Z][-a-zA-Z0-9_]{5,19}$` | 微信号 |
| `qq` | `^[1-9][0-9]{4,10}$` | QQ 号 |
| `hexColor` | `^#?([0-9A-Fa-f]{6}\|[0-9A-Fa-f]{3})$` | 颜色值 |
| `verificationCode` | `^\d{6}$` | 验证码 |

#### 基础正则

| 正则名 | 模式 | 说明 |
|--------|------|------|
| `numeric` | `^\d+$` | 纯数字 |
| `alpha` | `^[a-zA-Z]+$` | 纯字母 |
| `alphaNumeric` | `^[a-zA-Z0-9]+$` | 字母数字 |
| `color` | `^(0x)?[0-9A-Fa-f]+$` | 十六进制颜色 |

#### 使用示例

```dart
// 验证手机号
final phoneRegex = RegExp(RegexConstants.phone);
if (!phoneRegex.hasMatch(phoneNumber)) {
  throw '手机号格式不正确';
}

// 验证邮箱
final emailRegex = RegExp(RegexConstants.email);
if (!emailRegex.hasMatch(email)) {
  throw '邮箱格式不正确';
}

// 验证密码强度
final passwordRegex = RegExp(RegexConstants.password);
if (!passwordRegex.hasMatch(password)) {
  throw '密码必须为8-20位，且包含字母和数字';
}

// 提取数字
final numericRegex = RegExp(RegexConstants.numeric);
final numbers = numericRegex.allMatches(text).map((m) => m.group(0)).toList();
```

### 5. DateFormatConstants - 日期格式常量

定义日期时间的格式化字符串。

#### 常用格式

| 格式名 | 模式 | 示例 |
|--------|------|------|
| `fullDateTime` | `yyyy-MM-dd HH:mm:ss` | `2024-03-15 14:30:45` |
| `date` | `yyyy-MM-dd` | `2024-03-15` |
| `time` | `HH:mm:ss` | `14:30:45` |
| `dateTimeNoSeconds` | `yyyy-MM-dd HH:mm` | `2024-03-15 14:30` |
| `timeNoSeconds` | `HH:mm` | `14:30` |
| `month` | `yyyy-MM` | `2024-03` |
| `year` | `yyyy` | `2024` |

#### 中文格式

| 格式名 | 模式 | 示例 |
|--------|------|------|
| `chineseDate` | `yyyy年MM月dd日` | `2024年03月15日` |
| `chineseDateTime` | `yyyy年MM月dd日 HH:mm:ss` | `2024年03月15日 14:30:45` |

#### 特殊格式

| 格式名 | 模式 | 示例 | 说明 |
|--------|------|------|------|
| `iso8601` | `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'` | `2024-03-15T14:30:45.123Z` | ISO 8601 标准 |
| `httpDate` | `EEE, dd MMM yyyy HH:mm:ss GMT` | `Fri, 15 Mar 2024 14:30:45 GMT` | HTTP 头格式 |
| `fileSafe` | `yyyyMMdd_HHmmss` | `20240315_143045` | 文件名友好格式 |

#### 使用示例

```dart
// 格式化日期时间
final now = DateTime.now();
final formatted = DateFormat(DateFormatConstants.fullDateTime).format(now);
// 输出: 2024-03-15 14:30:45

// 解析日期字符串
final dateStr = '2024-03-15';
final parsed = DateFormat(DateFormatConstants.date).parse(dateStr);

// 文件名格式
final fileName = 'screenshot_${DateFormat(DateFormatConstants.fileSafe).format(now)}.png';
// 输出: screenshot_20240315_143045.png

// API 请求
final apiDate = DateFormat(DateFormatConstants.iso8601).format(now);
```

---

## 使用指南

### 场景 1：配置 HTTP 客户端

```dart
class HttpClient {
  HttpClient() : _client = IOClient();

  static final _baseUrl = ApiConstants.baseUrl;

  Future<Response> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    return await _client.get(uri).timeout(
      Duration(milliseconds: ApiConstants.connectTimeout),
    );
  }
}
```

### 场景 2：本地存储管理

```dart
class StorageManager {
  final SharedPreferences _prefs;

  // Token 管理
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(StorageKeys.accessToken, accessToken);
    await _prefs.setString(StorageKeys.refreshToken, refreshToken);
    await _prefs.setInt(
      StorageKeys.tokenExpireTime,
      DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
    );
  }

  Future<String?> getAccessToken() async {
    return _prefs.getString(StorageKeys.accessToken);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.tokenExpireTime);
  }

  // 用户信息管理
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(StorageKeys.currentUser, jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(StorageKeys.currentUser);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // 设置管理
  Future<void> setLanguage(String language) async {
    await _prefs.setString(StorageKeys.language, language);
  }

  Future<String> getLanguage() async {
    return _prefs.getString(StorageKeys.language) ??
        AppConstants.defaultLanguage;
  }
}
```

### 场景 3：表单验证

```dart
class FormValidator {
  // 验证手机号
  static String? validatePhone(String? value) {
    if (value.isNullOrEmpty) {
      return '请输入手机号';
    }
    final regex = RegExp(RegexConstants.phone);
    if (!regex.hasMatch(value!)) {
      return '请输入正确的手机号';
    }
    return null;
  }

  // 验证邮箱
  static String? validateEmail(String? value) {
    if (value.isNullOrEmpty) {
      return '请输入邮箱';
    }
    final regex = RegExp(RegexConstants.email);
    if (!regex.hasMatch(value!)) {
      return '请输入正确的邮箱';
    }
    return null;
  }

  // 验证密码
  static String? validatePassword(String? value) {
    if (value.isNullOrEmpty) {
      return '请输入密码';
    }
    if (value!.length < AppConstants.passwordMinLength) {
      return '密码长度不能少于 ${AppConstants.passwordMinLength} 位';
    }
    if (value.length > AppConstants.passwordMaxLength) {
      return '密码长度不能超过 ${AppConstants.passwordMaxLength} 位';
    }
    final regex = RegExp(RegexConstants.password);
    if (!regex.hasMatch(value)) {
      return '密码必须包含字母和数字';
    }
    return null;
  }

  // 验证验证码
  static String? validateVerificationCode(String? value) {
    if (value.isNullOrEmpty) {
      return '请输入验证码';
    }
    if (value!.length != AppConstants.verificationCodeLength) {
      return '请输入 ${AppConstants.verificationCodeLength} 位验证码';
    }
    final regex = RegExp(RegexConstants.verificationCode);
    if (!regex.hasMatch(value)) {
      return '请输入正确的验证码';
    }
    return null;
  }
}
```

### 场景 4：分页请求

```dart
class PaginatedRepository {
  final HttpClient _client;

  Future<PaginatedResult<T>> fetchPage<T>({
    required String endpoint,
    required int page,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    // 限制每页数量范围
    if (pageSize < AppConstants.minPageSize) {
      pageSize = AppConstants.minPageSize;
    } else if (pageSize > AppConstants.maxPageSize) {
      pageSize = AppConstants.maxPageSize;
    }

    final response = await _client.get(
      endpoint,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    return PaginatedResult<T>.fromJson(response.data);
  }
}
```

### 场景 5：文件上传

```dart
class FileUploadService {
  final HttpClient _client;

  Future<String> uploadImage(File file) async {
    // 检查文件大小
    final fileSize = await file.length();
    final maxSizeBytes = AppConstants.maxImageSizeMB * 1024 * 1024;
    if (fileSize > maxSizeBytes) {
      throw FileSizeLimitException(
        maxSize: AppConstants.maxImageSizeMB,
        actualSize: (fileSize / (1024 * 1024)).round(),
      );
    }

    // 检查文件类型
    final extension = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      throw FileNotSupportedException(fileType: extension);
    }

    // 压缩图片
    final compressed = await compressImage(file, AppConstants.defaultImageQuality);

    // 上传
    final response = await _client.post(
      ApiConstants.endpoints.upload,
      body: {'file': compressed},
    );

    return response.data['url'];
  }
}
```

---

## 最佳实践

### 1. 始终使用常量，避免魔法数字

```dart
// ✅ 好的做法：使用常量
if (retryCount >= AppConstants.maxRetryCount) {
  throw '超过最大重试次数';
}

// ❌ 不好的做法：魔法数字
if (retryCount >= 3) {
  throw '超过最大重试次数';
}
```

### 2. 使用常量避免字符串拼写错误

```dart
// ✅ 好的做法：使用常量
await prefs.setString(StorageKeys.accessToken, token);

// ❌ 不好的做法：字符串硬编码（容易拼写错误）
await prefs.setString('access_token', token);
await prefs.setString('access_tken', token); // 拼写错误！
```

### 3. 添加新常量时保持一致的命名风格

```dart
// ✅ 好的做法：一致的命名风格
static const String accessToken = 'access_token';
static const String refreshToken = 'refresh_token';
static const String tokenExpireTime = 'token_expire_time';

// ❌ 不好的做法：不一致的命名风格
static const String access_token = 'access_token';
static const String refreshToken = 'refresh_token';
static const String TOKEN_EXPIRE = 'token_expire_time';
```

### 4. 按功能分组常量

```dart
// ✅ 好的做法：使用注释分组
final class StorageKeys {
  const StorageKeys._();

  // ==================== 用户相关 ====================
  static const String currentUser = 'current_user';
  static const String accessToken = 'access_token';

  // ==================== 设置相关 ====================
  static const String language = 'language';
  static const String theme = 'theme';
}

// ❌ 不好的做法：没有分组，难以查找
final class StorageKeys {
  const StorageKeys._();
  static const String currentUser = 'current_user';
  static const String language = 'language';
  static const String accessToken = 'access_token';
  static const String theme = 'theme';
}
```

### 5. 常量值应该具有描述性

```dart
// ✅ 好的做法：描述性的值
static const String date = 'yyyy-MM-dd';  // 一看就知道是日期格式

// ❌ 不好的做法：难以理解的值
static const String format1 = 'yyyy-MM-dd';
```

### 6. 使用嵌套类组织相关常量

```dart
// ✅ 好的做法：使用嵌套类
final class ApiConstants {
  static const Endpoints endpoints = Endpoints._();
  static const StatusCodes statusCodes = StatusCodes._();
}

// 使用：ApiConstants.endpoints.login

// ❌ 不好的做法：所有常量平铺
final class ApiConstants {
  static const String login = '/auth/login';
  static const int ok = 200;
  // ... 更多常量，难以查找
}
```

### 7. 根据编译环境动态切换常量

```dart
// 在 api_constants.dart 中
import 'package:flutter/foundation.dart';

final class ApiConstants {
  // 根据编译环境选择基础 URL
  static const String baseUrl = kReleaseMode
      ? baseUrlProd
      : kDebugMode
          ? baseUrlDev
          : baseUrlTest;
}
```

---

## 总结

`core_constants` 提供了一套完整的常量管理方案：

1. **AppConstants** - 应用基础配置
2. **ApiConstants** - API 相关配置
3. **StorageKeys** - 本地存储键名
4. **RegexConstants** - 正则表达式
5. **DateFormatConstants** - 日期格式

通过使用这些常量，可以：
- **避免魔法数字**：提高代码可读性
- **减少拼写错误**：编译时检查
- **统一修改**：单一数据源
- **提高可维护性**：集中管理

记住：**任何可能变化的数据都应该定义为常量**！
