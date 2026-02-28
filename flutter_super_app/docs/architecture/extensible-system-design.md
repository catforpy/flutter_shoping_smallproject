# 可扩展系统架构设计文档

> **版本**: 1.0.0
> **创建日期**: 2026-02-25
> **状态**: 设计阶段

---

## 📋 文档概述

本文档定义了一个**高度可扩展**的系统架构，支持：
- 用户信息扩展（实名、企业、VIP、角色等）
- 关系/分组系统（好友分组、群组分类等）
- 分类树系统（多级话题分类、行业分类等）

**设计原则**：核心稳定 + 接口预留 + 逐层扩展

---

## 🎯 设计目标

### 1. 核心稳定
- 核心模型字段极少，几乎不需要改动
- 向后兼容，新增字段不影响旧版本

### 2. 高度可扩展
- 预定义扩展（有类型检查）
- 完全自定义（无限制）
- 插件式扩展机制

### 3. 灵活配置
- 分类名称可自定义
- 角色类型可自定义
- VIP 级别可自定义

---

## 📦 核心架构

```
┌─────────────────────────────────────────────────────────────┐
│                     应用层 (Application)                     │
│         业务模块、UI 组件、自定义扩展插件                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   服务层 (Services)                         │
│    UserService, ContentService, IMService, ...             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   模型层 (Models)                           │
│  ┌─────────────┬─────────────┬─────────────────────────┐   │
│  │  核心模型    │  扩展模型    │   自定义扩展层            │   │
│  │  (Core)     │ (Extensions)│   (Custom/Plugin)       │   │
│  │             │             │                         │   │
│  │ • User      │ • UserAttrs  │ • customFields         │   │
│  │ • Relation  │ • Company    │ • dynamic config       │   │
│  │ • Category  │ • Membership │ • plugin system        │   │
│  └─────────────┴─────────────┴─────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   基础层 (Core)                             │
│    core_network, core_cache, core_database, ...            │
└─────────────────────────────────────────────────────────────┘
```

---

## 👤 用户系统设计

### 1. 核心用户模型（极简）

```dart
/// 核心用户 - 只包含最基础、最稳定的字段
/// 这些字段几乎永远不需要改动
final class User {
  /// 用户ID - 唯一标识，不可变
  final String id;

  /// 用户名 - 登录用，唯一，不可变
  final String username;

  /// 头像 URL
  final String? avatar;

  /// 用户状态
  final UserStatus status;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 扩展属性 - 关键扩展点
  final UserAttributes attributes;
}
```

**核心字段说明**：

| 字段 | 说明 | 是否可变 |
|------|------|---------|
| `id` | 用户唯一标识 | ❌ 不可变 |
| `username` | 用户名/登录名 | ❌ 不可变 |
| `avatar` | 头像 | ✅ 可变 |
| `status` | 状态（active/disabled） | ✅ 可变 |
| `createdAt` | 创建时间 | ❌ 不可变 |
| `updatedAt` | 更新时间 | ✅ 自动更新 |
| `attributes` | **扩展属性** | ✅ 可变 |

### 2. 用户扩展属性系统

```dart
/// 用户属性 - 高度可扩展
final class UserAttributes {
  // ========== 预定义扩展（有类型检查） ==========

  /// 实名认证信息
  final RealNameInfo? realNameInfo;

  /// 企业/商户信息
  final CompanyInfo? companyInfo;

  /// 会员信息（类型可配置）
  final MembershipInfo? membership;

  /// 用户角色列表（可扩展）
  final List<UserRole> roles;

  /// 用户统计数据
  final UserStats? stats;

  // ========== 自定义扩展（完全灵活） ==========

  /// 自定义字段 - 完全灵活的扩展点
  /// 存储格式：Map<String, dynamic>
  ///
  /// 示例：
  /// ```dart
  /// customFields: {
  ///   'industry': 'education',
  ///   'specialties': ['Flutter', 'Dart'],
  ///   'anyCustomField': 'any value',
  /// }
  /// ```
  final Map<String, dynamic> customFields;

  /// 获取自定义字段
  T? getCustom<T>(String key);

  /// 设置自定义字段
  UserAttributes setCustom<T>(String key, T value);
}
```

#### 2.1 实名认证信息

```dart
/// 实名认证信息
final class RealNameInfo {
  /// 是否已实名认证
  final bool isVerified;

  /// 真实姓名
  final String? realName;

  /// 身份证号
  final String? idCard;

  /// 认证时间
  final DateTime? verifiedAt;

  /// 认证机构
  final String? verifiedBy;
}
```

#### 2.2 企业信息

```dart
/// 企业/商户信息
final class CompanyInfo {
  /// 是否企业认证
  final bool isCompanyVerified;

  /// 企业名称
  final String? companyName;

  /// 营业执照 URL
  final String? businessLicense;

  /// 税务号
  final String? taxNumber;

  /// 资质证书列表
  final List<String>? certificates;

  /// 企业地址
  final String? address;

  /// 认证时间
  final DateTime? verifiedAt;
}
```

#### 2.3 会员信息（类型可配置）

```dart
/// 会员信息 - 类型完全可配置
final class MembershipInfo {
  /// 会员类型 - 可自定义
  /// 示例: "VIP", "SVIP", "PRO", "Premium", "Gold", "Platinum"...
  final String membershipType;

  /// 会员等级 - 可自定义
  /// 可以是数字: "1", "2", "3"
  /// 可以是名称: "Basic", "Advanced", "Expert"
  final String level;

  /// 到期时间
  final DateTime? expireAt;

  /// 扩展数据 - 存储会员相关自定义配置
  ///
  /// 示例：
  /// ```dart
  /// customData: {
  ///   'benefits': ['free_shipping', 'priority_support'],
  ///   'discountRate': 0.8,
  ///   'maxUploadSize': '100MB',
  /// }
  /// ```
  final Map<String, dynamic>? customData;

  /// 是否已过期
  bool get isExpired => expireAt != null && DateTime.now().isAfter(expireAt!);
}
```

#### 2.4 用户角色（可扩展）

```dart
/// 用户角色 - 类型可自定义
final class UserRole {
  /// 角色类型 - 可自定义
  /// 预定义示例:
  /// - "customer_service" - 客服
  /// - "teacher" - 老师
  /// - "expert" - 达人
  /// - "sales" - 销售
  /// - "admin" - 管理员
  /// - "custom" - 自定义
  final String roleType;

  /// 角色显示名称 - 可自定义
  /// 示例: "高级讲师", "金牌客服", "区域代理"
  final String? roleName;

  /// 权限配置 - 可自定义
  ///
  /// 示例：
  /// ```dart
  /// permissions: {
  ///   'canCreateCourse': true,
  ///   'canDeleteComment': true,
  ///   'maxDailyPosts': 100,
  /// }
  /// ```
  final Map<String, dynamic>? permissions;

  /// 角色获取时间
  final DateTime? obtainedAt;
}
```

#### 2.5 用户统计数据

```dart
/// 用户统计数据
final class UserStats {
  /// 粉丝数
  final int followersCount;

  /// 关注数
  final int followingCount;

  /// 发布内容数
  final int postsCount;

  /// 获得点赞数
  final int likesCount;

  /// 扩展统计字段
  final Map<String, dynamic>? customStats;
}
```

---

## 🤝 关系/分组系统设计

### 1. 关系模型

```dart
/// 用户关系 - 统一管理所有关系类型
final class UserRelation {
  /// 用户ID
  final String userId;

  /// 目标用户ID
  final String targetUserId;

  /// 关系类型
  final RelationType type;

  /// 分组列表 - 一个关系可以属于多个分组
  ///
  /// 示例：
  /// - ["同事", "技术部"]
  /// - ["家人", "亲属"]
  /// - ["客户", "VIP客户"]
  final List<String> categories;

  /// 扩展信息
  ///
  /// 示例：
  /// ```dart
  /// metadata: {
  ///   'remark': '备注名称',
  ///   'tags': ['重要', '优先'],
  ///   'lastContactTime': '2026-02-25',
  /// }
  /// ```
  final Map<String, dynamic>? metadata;

  /// 创建时间
  final DateTime createdAt;
}

/// 关系类型 - 可扩展
enum RelationType {
  /// 好友
  friend,

  /// 关注
  following,

  /// 粉丝
  follower,

  /// 黑名单
  blocked,

  /// 免打扰
  muted,

  /// 特别关注
  favorite,

  /// 自定义类型
  custom,
}
```

### 2. 分组/分类系统（树形结构）

```dart
/// 分组/分类 - 支持多级树形结构
final class RelationCategory {
  /// 分类ID
  final String id;

  /// 分类名称 - 可自定义
  final String name;

  /// 父分类ID - 支持多级
  final String? parentId;

  /// 分类类型
  final CategoryType type;

  /// 排序顺序
  final int sortOrder;

  /// 图标
  final String? icon;

  /// 自定义配置
  ///
  /// 示例：
  /// ```dart
  /// customConfig: {
  ///   'color': '#FF0000',
  ///   'isDefault': false,
  ///   'maxMembers': 500,
  /// }
  /// ```
  final Map<String, dynamic>? customConfig;

  /// 创建时间
  final DateTime createdAt;
}

/// 分类类型 - 可扩展
enum CategoryType {
  /// 好友分组
  friendGroup,

  /// 群组分类
  chatGroup,

  /// 话题分类
  topicCategory,

  /// 行业分类
  industry,

  /// 自定义类型
  custom,
}
```

### 3. 分组使用示例

```
好友分组树：
├── 工作相关
│   ├── 同事
│   ├── 客户
│   └── 合作伙伴
├── 生活相关
│   ├── 家人
│   ├── 朋友
│   └── 同学
└── 自定义分组...

群组分类树：
├── 工作群
│   ├── 技术交流
│   ├── 项目讨论
│   └── 部门群
├── 兴趣群
│   ├── 游戏群
│   ├── 运动群
│   └── 学习群
└── 自定义分类...

行业分类树：
├── 教育行业
│   ├── 在线教育
│   └── 线下培训
├── 电商行业
│   ├── B2C电商
│   └── B2B电商
└── 自定义行业...
```

---

## 📂 分类树系统设计

### 1. 分类树模型

```dart
/// 分类树 - 支持无限层级
final class CategoryTree {
  /// 分类ID
  final String id;

  /// 分类名称
  final String name;

  /// 父分类ID
  final String? parentId;

  /// 层级 (1, 2, 3...)
  final int level;

  /// 完整路径 - 从根到当前节点
  ///
  /// 示例：
  /// ```dart
  /// ["技术", "前端", "Flutter"]
  /// ["教育", "在线教育", "编程"]
  /// ```
  final List<String> path;

  /// 排序顺序
  final int sortOrder;

  /// 自定义配置
  ///
  /// 示例：
  /// ```dart
  /// customConfig: {
  ///   'icon': 'https://...',
  ///   'color': '#00FF00',
  ///   'description': '分类描述',
  ///   'isHot': true,
  ///   'tags': ['热门', '推荐'],
  /// }
  /// ```
  final Map<String, dynamic>? customConfig;

  /// 子分类列表
  final List<CategoryTree> children;

  /// 是否有子分类
  bool get hasChildren => children.isNotEmpty;

  /// 是否叶子节点
  bool get isLeaf => children.isEmpty;
}
```

### 2. 分类树使用示例

```
话题分类（3级）：
├── 技术
│   ├── 前端
│   │   ├── Flutter
│   │   ├── React
│   │   └── Vue
│   └── 后端
│       ├── Java
│       ├── Python
│       └── Go
├── 生活
│   ├── 美食
│   ├── 旅游
│   └── 娱乐
└── 自定义...

行业分类（3级）：
├── 教育培训
│   ├── K12教育
│   ├── 职业教育
│   └── 兴趣培训
├── 电子商务
│   ├── 零售电商
│   ├── 跨境电商
│   └── 社交电商
└── 自定义...
```

---

## 💾 存储格式

### 用户完整数据示例

```json
{
  "id": "user_123",
  "username": "john",
  "avatar": "https://example.com/avatar.jpg",
  "status": "active",
  "createdAt": "2026-01-01T00:00:00Z",
  "updatedAt": "2026-02-25T00:00:00Z",
  "attributes": {
    "realNameInfo": {
      "isVerified": true,
      "realName": "张三",
      "idCard": "110***********1234",
      "verifiedAt": "2026-01-15T00:00:00Z"
    },
    "companyInfo": {
      "isCompanyVerified": true,
      "companyName": "某某科技有限公司",
      "businessLicense": "https://example.com/license.pdf",
      "taxNumber": "91110000********",
      "certificates": [
        "https://example.com/cert1.pdf",
        "https://example.com/cert2.pdf"
      ],
      "verifiedAt": "2026-02-01T00:00:00Z"
    },
    "membership": {
      "membershipType": "VIP",
      "level": "3",
      "expireAt": "2027-02-25T00:00:00Z",
      "customData": {
        "benefits": ["free_shipping", "priority_support", "discount_20"],
        "discountRate": 0.8,
        "maxUploadSize": "100MB"
      }
    },
    "roles": [
      {
        "roleType": "teacher",
        "roleName": "高级讲师",
        "permissions": {
          "canCreateCourse": true,
          "canDeleteComment": true,
          "maxDailyPosts": 100
        },
        "obtainedAt": "2026-01-20T00:00:00Z"
      },
      {
        "roleType": "custom",
        "roleName": "区域代理",
        "permissions": {
          "region": ["北京", "天津"],
          "commissionRate": 0.15
        },
        "obtainedAt": "2026-02-10T00:00:00Z"
      }
    ],
    "stats": {
      "followersCount": 1000,
      "followingCount": 500,
      "postsCount": 200,
      "likesCount": 5000
    },
    "customFields": {
      "industry": "education",
      "specialties": ["Flutter", "Dart", "移动开发"],
      "website": "https://example.com",
      "bio": "专注于 Flutter 技术分享",
      "location": "北京",
      "anyCustomField": "任何自定义数据"
    }
  }
}
```

### 关系数据示例

```json
{
  "userId": "user_123",
  "targetUserId": "user_456",
  "type": "friend",
  "categories": ["同事", "技术部"],
  "metadata": {
    "remark": "前端工程师",
    "tags": ["重要", "合作"],
    "lastContactTime": "2026-02-25T10:30:00Z"
  },
  "createdAt": "2026-01-01T00:00:00Z"
}
```

### 分类树数据示例

```json
{
  "id": "cat_tech_frontend_flutter",
  "name": "Flutter",
  "parentId": "cat_tech_frontend",
  "level": 3,
  "path": ["技术", "前端", "Flutter"],
  "sortOrder": 1,
  "customConfig": {
    "icon": "https://example.com/flutter.png",
    "color": "#02569B",
    "description": "Google 开发的 UI 框架",
    "isHot": true,
    "tags": ["热门", "推荐"]
  },
  "children": []
}
```

---

## 🔧 扩展指南

### 1. 添加新的用户属性

**方式1：添加到预定义扩展（有类型检查）**

```dart
// 1. 在 UserAttributes 中添加新字段
final class UserAttributes {
  // ... 现有字段

  /// 新扩展：银行卡信息
  final BankCardInfo? bankCardInfo;
}

// 2. 定义新模型
final class BankCardInfo {
  final String? bankName;
  final String? cardNumber;
  final DateTime? boundAt;
}
```

**方式2：使用自定义字段（完全灵活）**

```dart
// 直接使用 customFields，无需修改代码
user.attributes.customFields['bankInfo'] = {
  'bankName': '招商银行',
  'cardNumber': '****1234',
};
```

### 2. 添加新的关系类型

```dart
// 在 RelationType 枚举中添加
enum RelationType {
  // ... 现有类型

  /// 自定义：业务伙伴
  businessPartner,

  /// 自定义：家人
  family,

  /// 完全自定义
  custom,
}
```

### 3. 添加新的分类类型

```dart
// 在 CategoryType 枚举中添加
enum CategoryType {
  // ... 现有类型

  /// 自定义：商品分类
  productCategory,

  /// 自定义：地区分类
  regionCategory,

  /// 完全自定义
  custom,
}
```

### 4. 创建自定义分类树

```dart
// 创建一个完全自定义的分类树
final customTree = CategoryTree(
  id: 'custom_1',
  name: '我的自定义分类',
  parentId: null,
  level: 1,
  path: ['我的自定义分类'],
  customConfig: {
    'anyKey': 'anyValue',
  },
  children: [
    CategoryTree(
      id: 'custom_1_1',
      name: '子分类',
      parentId: 'custom_1',
      level: 2,
      path: ['我的自定义分类', '子分类'],
      children: [],
    ),
  ],
);
```

---

## 📌 使用示例

### 获取用户扩展信息

```dart
// 获取实名信息
final realNameInfo = user.attributes.realNameInfo;
if (realNameInfo?.isVerified == true) {
  print('已实名：${realNameInfo?.realName}');
}

// 获取会员等级
final membership = user.attributes.membership;
if (membership != null) {
  print('会员类型：${membership.membershipType}');
  print('会员等级：${membership.level}');
}

// 获取角色列表
for (final role in user.attributes.roles) {
  print('${role.roleName} (${role.roleType})');
}

// 获取自定义字段
final industry = user.attributes.getCustom<String>('industry');
final specialties = user.attributes.getCustom<List<String>>('specialties');
```

### 操作关系/分组

```dart
// 添加好友到分组
final relation = UserRelation(
  userId: 'user_123',
  targetUserId: 'user_456',
  type: RelationType.friend,
  categories: ['同事', '技术部'],
);

// 创建自定义分组
final category = RelationCategory(
  id: 'cat_custom_1',
  name: 'VIP客户',
  type: CategoryType.friendGroup,
  sortOrder: 1,
);
```

### 操作分类树

```dart
// 获取完整路径
final path = category.path; // ["技术", "前端", "Flutter"]

// 遍历子分类
for (final child in category.children) {
  print('${child.name} (Level ${child.level})');
}
```

---

## ⚠️ 注意事项

### 1. 向后兼容
- 新增字段使用可空类型
- 旧版本代码可以正常处理新数据
- `customFields` 是最大的扩展缓冲

### 2. 性能考虑
- `customFields` 存储大量数据时考虑分表
- 分类树层级过深时考虑优化查询
- 关系数据量大时考虑缓存

### 3. 数据验证
- 预定义扩展有类型检查
- `customFields` 需要手动验证类型
- 建议在 Service 层做数据验证

### 4. 安全性
- 敏感信息（身份证、银行卡）需要加密存储
- 企业资质文件需要 CDN 存储
- 前端返回数据需要脱敏处理

---

## 📚 参考资料

- [Flutter 数据模型最佳实践](https://dart.dev/guides/language/effective-dart/usage)
- [JSON 序列化最佳实践](https://docs.flutter.dev/data-and-backend/serialization/json)
- [树形数据结构设计](https://en.wikipedia.org/wiki/Tree_(data_structure))

---

## 📝 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2026-02-25 | 初始版本 |

---

**维护者**: Development Team
**文档状态**: 活跃维护中
