# service_user

高度可扩展的用户服务 - 支持用户信息管理、可扩展属性系统、关注系统、分类树等。

## 核心特性

### 1. 高度可扩展的用户属性
- **预定义扩展**: 实名认证、企业信息、会员信息、角色系统
- **自定义字段**: 完全灵活的 `customFields` Map
- **类型安全**: 使用强类型模型，编译时检查

### 2. 用户关系系统
- 关注/取关
- 粉丝列表
- 互关列表
- 多级分类分组

### 3. 分类树系统
- 无限层级的话题分类
- 行业分类
- 商品分类
- 完全自定义分类树

## 架构层次

```
┌─────────────────────────────────────────┐
│           UI Layer (Widget)              │
│  Consumer(builder: (context, ref, watch) │
└─────────────────┬───────────────────────┘
                  │ 调用 Provider 方法
┌─────────────────▼───────────────────────┐
│      Provider Layer (UserProvider)       │
│  - 管理用户状态                           │
│  - 调用 UserService                        │
└─────────────────┬───────────────────────┘
                  │ 调用 Service 方法
┌─────────────────▼───────────────────────┐
│       Service Layer (UserService)         │
│  - 业务逻辑                               │
│  - 调用 Repository                         │
└─────────────────┬───────────────────────┘
                  │ 获取/保存数据
┌─────────────────▼───────────────────────┐
│    Repository Layer (UserRepository)      │
│  - API 调用                               │
│  - 缓存管理                               │
└─────────────────────────────────────────┘
```

## 使用示例

### 1. 在 main.dart 中配置 Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_user/service_user.dart';
import 'package:core_network/core_network.dart';
import 'package:core_cache/core_cache.dart';

// 创建 ApiClient 和 CacheManager
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://api.example.com');
});

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// 创建 UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

// 创建 UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    repository: ref.watch(userRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

// 创建 UserProvider
final userProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
  return UserProvider(ref.watch(userServiceProvider));
});
```

### 2. 在 Widget 中使用

```dart
class UserProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    // 加载状态
    if (userState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // 错误状态
    if (userState.error != null) {
      return Center(
        child: Text('错误: ${userState.error}'),
      );
    }

    // 未登录状态
    if (!userState.isLoggedIn) {
      return Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text('请先登录'),
        ),
      );
    }

    // 已登录 - 显示用户信息
    final user = userState.user!;

    return Column(
      children: [
        // 头像
        CircleAvatar(
          backgroundImage: NetworkImage(user.avatar ?? ''),
          radius: 40,
        ),

        // 昵称
        Text(user.displayName),

        // 关注数
        Text('关注: ${user.attributes.stats?.followingCount ?? 0}'),

        // 粉丝数
        Text('粉丝: ${user.attributes.stats?.followersCount ?? 0}'),

        // 更新昵称按钮
        ElevatedButton(
          onPressed: () async {
            await userNotifier.updateUserInfo(
              userId: user.id,
              nickname: '新昵称',
            );
          },
          child: Text('更新昵称'),
        ),

        // 登出按钮
        ElevatedButton(
          onPressed: () async {
            await userNotifier.logout();
          },
          child: Text('登出'),
        ),
      ],
    );
  }
}
```

### 3. 用户搜索

```dart
class UserSearchPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final userNotifier = ref.read(userProvider.notifier);

        return TextField(
          decoration: InputDecoration(hintText: '搜索用户'),
          onSubmitted: (keyword) async {
            final result = await userNotifier.searchUsers(keyword: keyword);
            
            if (result.isSuccess) {
              final users = result.value.data;
              // 显示用户列表
            }
          },
        );
      },
    );
  }
}
```

### 4. 关注功能

```dart
// 关注用户
ElevatedButton(
  onPressed: () async {
    await ref.read(userProvider.notifier).followUser('targetUserId');
    // 刷新用户信息
    await ref.read(userProvider.notifier).refreshUser();
  },
  child: Text('关注'),
),

// 检查是否关注
FutureBuilder<bool>(
  future: ref.read(userProvider.notifier).isFollowing('targetUserId'),
  builder: (context, snapshot) {
    final isFollowing = snapshot.data ?? false;
    return Text(isFollowing ? '已关注' : '未关注');
  },
),
```

## 扩展指南

### 1. 添加用户自定义属性

```dart
// 方式1: 使用预定义扩展
final user = User(
  id: 'user123',
  username: 'john',
  attributes: UserAttributes(
    membership: MembershipInfo(
      membershipType: 'VIP',
      level: '2',
      expireAt: DateTime(2026, 12, 31),
    ),
  ),
);

// 方式2: 使用自定义字段
final user = User(
  id: 'user123',
  username: 'john',
  attributes: UserAttributes(
    customFields: {
      'industry': 'education',
      'specialties': ['Flutter', 'Dart'],
      'website': 'https://example.com',
    },
  ),
);

// 读取自定义字段
final industry = user.attributes.getCustom<String>('industry');
final specialties = user.attributes.getCustom<List<dynamic>>('specialties');
```

### 2. 添加用户角色

```dart
final user = User(
  id: 'user123',
  username: 'john',
  attributes: UserAttributes(
    roles: [
      UserRole(
        roleType: 'teacher',
        roleName: '高级讲师',
        permissions: {
          'can_create_course': true,
          'max_students': 100,
        },
      ),
    ],
  ),
);

// 检查用户是否有某个角色
if (user.attributes.hasRole('teacher')) {
  print('是讲师');
}
```

### 3. 使用分类树

```dart
// 创建话题分类树
final topicCategories = [
  CategoryTree(
    id: 'tech',
    name: '技术',
    parentId: null,
    level: 1,
    path: ['技术'],
    children: [
      CategoryTree(
        id: 'frontend',
        name: '前端',
        parentId: 'tech',
        level: 2,
        path: ['技术', '前端'],
      ),
      CategoryTree(
        id: 'backend',
        name: '后端',
        parentId: 'tech',
        level: 2,
        path: ['技术', '后端'],
      ),
    ],
  ),
];

// 查询分类
final query = CategoryQuery(
  parentId: null,  // 查询根分类
  type: 'topic',
);
```

## 状态管理

### UserState 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `user` | `User?` | 当前登录用户 |
| `isLoading` | `bool` | 是否正在加载 |
| `error` | `String?` | 错误信息 |
| `isLoggedIn` | `bool` | 是否已登录（计算属性）|

### UserProvider 常用方法

| 方法 | 说明 |
|------|------|
| `getCurrentUser()` | 获取当前用户 |
| `refreshUser()` | 刷新用户信息 |
| `updateUserInfo()` | 更新用户基本信息 |
| `updateUserProfile()` | 更新用户详细资料 |
| `uploadAvatar()` | 上传头像 |
| `logout()` | 登出 |
| `searchUsers()` | 搜索用户 |
| `followUser()` | 关注用户 |
| `unfollowUser()` | 取关用户 |

## 注意事项

1. **状态管理**: 使用 Riverpod 的 `StateNotifier` 进行状态管理
2. **缓存**: UserRepository 会自动缓存当前用户信息
3. **扩展性**: 所有扩展信息都通过 `attributes` 字段存储
4. **类型安全**: 使用枚举而非字符串，编译时检查
