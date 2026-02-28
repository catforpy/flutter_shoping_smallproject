# Service Auth - 认证服务

> **版本**: 0.1.0
> **最后更新**: 2026-02-25

---

## 📦 概述

认证服务（service_auth）是项目的业务逻辑层服务，负责处理用户认证相关的所有功能。它组合了 core_network、core_cache、core_state 等基础能力来实现认证业务。

### 分层架构

```
┌─────────────────────────────────────────┐
│  UI 层 (登录页面、注册页面)                  │
└──────────────────┬──────────────────────┘
                   ↓ 调用
┌─────────────────────────────────────────┐
│  Provider 层 (AuthProvider)               │
│  - 状态管理、用户操作封装                     │
└──────────────────┬──────────────────────┘
                   ↓ 调用
┌─────────────────────────────────────────┐
│  业务逻辑层 (AuthService)    ← 当前层       │
│  - loginWithPassword(), loginWithWechat() │
│  - Token 管理、用户信息保存                  │
└──────────────────┬──────────────────────┘
                   ↓ 调用
┌─────────────────────────────────────────┐
│  底层/基础层 (Core)                       │
│  - ApiClient (HTTP)                       │
│  - CacheManager (存储)                     │
│  - TokenRefreshInterceptor (Token 刷新)     │
└─────────────────────────────────────────┘
```

---

## 🔑 认证类型

系统支持四种认证方式，每种方式有不同的权限级别：

| 认证类型 | 说明 | 核心功能 | 互动 | 浏览 | 微信支付 |
|---------|------|---------|------|------|---------|
| **guest** | 游客模式 | ❌ | ❌ | ✅ | ❌ |
| **phone** | 手机验证码 | 需实名 | ✅ | ✅ | ❌ |
| **password** | 密码登录 | 需实名 | ✅ | ✅ | ❌ |
| **wechat** | 微信授权 | 需实名 | ✅ | ✅ | ✅ |

### 权限说明

- **游客模式**: 仅可浏览，使用硬件编码（deviceId）标识
- **手机/密码登录**: 需要完成实名认证才能使用核心功能
- **微信授权**: 与手机登录权限相同，但可使用微信支付（微信侧负责实名验证）

---

## 📁 文件结构

```
lib/
├── service_auth.dart                    # 导出文件
├── src/
│   ├── models/
│   │   ├── auth_type.dart               # 认证类型枚举
│   │   ├── auth_token.dart              # Token 数据模型
│   │   └── auth_result.dart             # 认证结果模型
│   ├── services/
│   │   ├── auth_service.dart            # 认证服务接口和实现
│   │   └── token_refresh_interceptor.dart  # Token 自动刷新拦截器
│   └── providers/
│       └── auth_provider.dart           # Riverpod Provider
```

---

## 🚀 使用方法

### 1. 提供 AuthService

```dart
import 'package:service_auth/service_auth.dart';
import 'package:core_network/core_network.dart';
import 'package:core_cache/core_cache.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl(
    apiClient: ref.watch(apiClientProvider),
    cacheManager: ref.watch(cacheManagerProvider),
  );
});
```

### 2. 使用 Provider

```dart
import 'package:service_auth/service_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // 密码登录
    ref.read(authStateProvider.notifier).loginWithPassword(
      phone: '13800138000',
      password: 'password123',
    );

    // 验证码登录
    ref.read(authStateProvider.notifier).loginWithVerifyCode(
      phone: '13800138000',
      code: '123456',
    );

    // 微信授权登录
    ref.read(authStateProvider.notifier).loginWithWechat(
      authCode: 'wx_auth_code',
    );

    // 游客模式登录
    ref.read(authStateProvider.notifier).loginAsGuest(
      deviceId: 'unique_device_id',
    );

    return Container();
  }
}
```

### 3. 检查权限

```dart
final authState = ref.watch(authStateProvider);

// 检查是否可以互动
if (authState.canInteract) {
  // 允许点赞、评论、收藏
} else {
  // 提示登录或实名认证
}

// 检查是否可以使用微信支付
if (authState.canUseWeChatPay) {
  // 显示微信支付按钮
}
```

---

## 🔄 Token 自动刷新

### 工作原理

Token 自动刷新拦截器会：
1. 在请求发送前检查 Token 是否即将过期
2. 检测到 401 响应时自动刷新 Token
3. 避免并发刷新，多个请求共享一次刷新过程

### 使用方法

```dart
final interceptor = TokenRefreshInterceptor(
  getCurrentToken: () => authState.token,
  onRefreshToken: (refreshToken) async {
    final result = await authService.refreshToken(refreshToken);
    return result.isSuccess ? result.valueOrThrow : null;
  },
  onTokenUpdated: (newToken) {
    // 更新状态
    ref.read(authStateProvider.notifier).updateToken(newToken);
  },
  onRefreshFailed: () async {
    // 刷新失败，退出登录
    await ref.read(authStateProvider.notifier).logout();
  },
);
```

---

## 📋 API 列表

### AuthService 接口

| 方法 | 说明 | 参数 |
|------|------|------|
| `loginWithPassword()` | 密码登录 | `phone`, `password` |
| `loginWithVerifyCode()` | 验证码登录 | `phone`, `code` |
| `loginWithWechat()` | 微信授权登录 | `authCode` |
| `loginAsGuest()` | 游客模式登录 | `deviceId` |
| `register()` | 用户注册 | `phone`, `password`, `verifyCode` |
| `sendVerifyCode()` | 发送验证码 | `phone` |
| `refreshToken()` | 刷新 Token | `refreshToken` |
| `logout()` | 登出 | - |
| `isLoggedIn()` | 检查登录状态 | - |
| `getCurrentToken()` | 获取当前 Token | - |

### AuthProvider 方法

| 方法 | 说明 |
|------|------|
| `initialize()` | 初始化认证状态 |
| `loginWithPassword()` | 密码登录 |
| `loginWithVerifyCode()` | 验证码登录 |
| `loginWithWechat()` | 微信授权登录 |
| `loginAsGuest()` | 游客模式登录 |
| `register()` | 注册 |
| `logout()` | 登出 |
| `refreshToken()` | 刷新 Token |

### AuthState 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `user` | `User?` | 当前用户（游客为 null） |
| `token` | `AuthToken?` | 当前 Token |
| `isAuthenticated` | `bool` | 是否已认证 |
| `isLoading` | `bool` | 是否正在加载 |
| `authType` | `AuthType` | 认证类型 |
| `isGuest` | `bool` | 是否为游客 |
| `canInteract` | `bool` | 是否允许互动 |
| `canUseWeChatPay` | `bool` | 是否可使用微信支付 |

---

## 🔐 实名认证说明

### 实名认证 ≠ 微信授权

- **微信授权登录**: 只是一种登录方式，权限等同于手机验证码登录
- **实名认证**: 独立的认证流程，需要用户上传身份证等资料
- **微信支付**: 由微信侧负责实名验证，所以微信授权登录可以直接使用

### 认证流程

```
游客登录 → 浏览内容
    ↓
手机/微信登录 → 可互动（点赞、评论）
    ↓
完成实名认证 → 可使用核心功能（发布、交易等）
```

---

## 🔗 依赖关系

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1

  # Core 基础层
  core_base:
  core_utils:
  core_network:
  core_cache:
  core_state:
  core_logging:
  core_exceptions:

  # Service 业务层
  service_user:
```

---

## 📝 后续开发计划

- [ ] 添加忘记密码功能
- [ ] 添加第三方登录（QQ、支付宝等）
- [ ] 添加实名认证接口
- [ ] 添加手机号绑定/更换
- [ ] 添加账号注销功能

---

**维护者**: Development Team
**许可证**: MIT
