# Flutter 超大型项目 - Package 详细说明

> **更新时间**: 2026-02-24
> **创建的 Package**: 20 个

---

## 📦 已创建的 Package 列表

### 🏗️ 基础设施层（5个）

这些是最底层的包，不依赖任何其他包，其他所有包都可能依赖它们。

| Package 中文名 | 英文名称 | 路径 | 作用 |
|---------|---------|------|------|
| 基础类型 | core_base | packages/core/core_base | 定义最基础的数据类型，比如：Result（结果）、Either（两者之一）、Pagination（分页） |
| 工具函数 | core_utils | packages/core/core_utils | 提供各种工具方法，比如：字符串转日期、手机号验证、文件大小格式化 |
| 常量定义 | core_constants | packages/core/core_constants | 定义所有常量，比如：API地址、默认配置、应用名称 |
| 异常处理 | core_exceptions | packages/core/core_exceptions | 定义所有错误类型，比如：网络错误、认证错误、参数错误 |
| 日志系统 | core_logging | packages/core/core_logging | 记录程序运行信息，方便调试和排查问题 |

**例子**：
```
你需要在任何地方验证手机号 → 从 core_utils 导入
你需要在任何地方定义异常 → 从 core_exceptions 导入
```

---

### 🔧 核心能力层（8个）

这些是技术能力包，提供具体的技术功能，业务服务层会依赖它们。

| Package 中文名 | 英文名称 | 路径 | 作用 | 依赖 |
|---------|---------|------|------|------|
| 网络请求 | core_network | packages/core/core_network | 处理所有HTTP请求，访问API接口 | core_utils, core_exceptions |
| 数据库 | core_database | packages/core/core_database | 本地数据存储，SQLite数据库 | core_utils, core_logging |
| 缓存系统 | core_cache | packages/core/core_cache | 临时存储数据，提升性能 | core_utils, core_database |
| 状态管理 | core_state | packages/core/core_state | 管理应用的数据状态（使用Riverpod） | core_utils |
| 路由管理 | core_router | packages/core/core_router | 管理页面跳转 | 无 |
| UI组件库 | core_ui | packages/core/core_ui | 通用的界面组件（按钮、输入框等） | core_utils |
| 媒体处理 | core_media | packages/core/core_media | 处理图片、视频 | core_utils |

**例子**：
```
你需要请求API → 从 core_network 导入
你需要存储数据 → 从 core_database 导入
你需要缓存数据 → 从 core_cache 导入
```

---

### 🏪 业务服务层（3个）

这些是具体的业务功能服务，每个服务对应一个业务领域。

| Package 中文名 | 英文名称 | 路径 | 作用 | 依赖 |
|---------|---------|------|------|------|
| 用户服务 | service_user | packages/services/service_user | 用户注册、登录、个人信息管理 | core_network, core_database |
| 认证服务 | service_auth | packages/services/service_auth | 登录验证、Token管理、权限验证 | core_network, core_database, service_user |
| 内容服务 | service_content | packages/services/service_content | 文章、动态等内容管理 | core_network, core_database |

**例子**：
```
你需要实现用户登录 → 从 service_auth 导入
你需要获取用户信息 → 从 service_user 导入
```

---

### 🎨 业务模块层（3个）

这些是具体的业务模块，包含UI和业务逻辑。

| Package 中文名 | 英文名称 | 路径 | 作用 | 依赖 |
|---------|---------|------|------|------|
| 公共模块 | module_common | packages/modules/module_common | 所有模块共用的组件和页面 | core_ui |
| 电商模块 | module_shop | packages/modules/module_shop | 商品浏览、购物车、下单 | service_user, service_order |
| 直播模块 | module_live | packages/modules/module_live | 直播间、推流、观看 | service_user, service_live |

**例子**：
```
你要开发购物功能 → 在 module_shop 里开发
你要开发直播功能 → 在 module_live 里开发
```

---

### 📱 应用层（1个）

这是最终的应用程序，用户安装的就是这个。

| Package 中文名 | 英文名称 | 路径 | 作用 | 依赖 |
|---------|---------|------|------|------|
| 主应用 | app_main | packages/apps/app_main | 综合应用，包含所有功能 | 所有模块 |

---

## 🔄 依赖关系图

```
app_main (应用)
    ↓ 依赖
module_shop, module_live (业务模块)
    ↓ 依赖
service_user, service_auth (业务服务)
    ↓ 依赖
core_network, core_database (核心能力)
    ↓ 依赖
core_utils, core_base (基础设施)
```

**简单理解**：
```
就像盖楼：
app_main = 顶楼（可以看到的房间）
modules = 楼层（不同的功能区）
services = 管道系统（水、电、气）
core_network, core_database = 墙体、地板
core_base = 地基

必须从下往上建！
```

---

## 📂 每个 Package 的内部结构

每个 Package 创建后都有这样的结构：

```
core_base/
├── lib/                           # 代码文件夹
│   └── core_base.dart            # 主文件（代码写在这里）
├── test/                          # 测试文件夹
│   └── core_base_test.dart       # 测试文件
├── pubspec.yaml                   # 配置文件（类似 package.json）
└── README.md                      # 说明文件
```

### 文件说明：

| 文件/文件夹 | 作用 | 你需要做什么 |
|-----------|------|-------------|
| **lib/** | 放代码 | **你的代码都写在这里** |
| **test/** | 放测试 | 测试代码写在这里 |
| **pubspec.yaml** | 配置文件 | 添加依赖的时候修改这个文件 |
| **README.md** | 说明文件 | 可以写这个 Package 的用途说明 |

---

## 🎯 如何开始开发？

### 第一步：理解结构

1. 查看《项目搭建指南.md》了解整体架构
2. 查看本文档了解每个 Package 的作用
3. 打开任意 Package 的 lib 文件夹查看代码

### 第二步：选择一个 Package 开始

建议从底层开始：

```
推荐开发顺序：
1. core_base（基础类型）
   - 定义 Result 类型（成功/失败）
   - 定义 Pagination 类型（分页）

2. core_utils（工具函数）
   - 字符串扩展方法
   - 日期格式化方法

3. core_network（网络请求）
   - 封装 HTTP 客户端
   - 配置拦截器

4. 然后再往上层开发...
```

### 第三步：添加依赖关系

假设你在开发 core_network，需要依赖 core_utils：

1. 打开 `packages/core/core_network/pubspec.yaml`
2. 在 dependencies 部分添加：
```yaml
dependencies:
  core_utils:
    path: ../core_utils
```

### 第四步：编写代码

在 lib 文件夹里创建 .dart 文件，开始编写代码。

---

## ❓ 常见问题

### Q1: 我应该从哪个 Package 开始开发？

**A**: 建议从底层开始，按这个顺序：
```
core_base → core_utils → core_network → service_user → module_shop
```

### Q2: 如何知道一个 Package 依赖哪些包？

**A**: 查看本文档的"依赖关系图"部分，或者查看每个 Package 的 pubspec.yaml 文件。

### Q3: 两个 Package 之间可以互相依赖吗？

**A**: **不可以！** 这会造成循环依赖。
- 上层可以依赖下层
- 下层不能依赖上层
- 同层之间最好也不要相互依赖

### Q4: 忘记某个 Package 是干什么的怎么办？

**A**: 查看本文档顶部的表格，或者查看该 Package 的 README.md 文件。

---

## 📚 相关文档

- [项目搭建指南.md](./项目搭建指南.md) - 整体架构说明
- [README.md](./README.md) - 项目快速开始

---

**最后更新**: 2026-02-24
