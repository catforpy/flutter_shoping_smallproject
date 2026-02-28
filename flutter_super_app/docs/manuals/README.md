# 开发者手册索引

> 本手册系统帮助你快速理解项目架构、追踪代码调用链路

---

## 📚 手册结构

### 1. [基础设施层手册](./00-基础设施层手册.md)
包含以下包的详细说明：
- core_base - 基础类型
- core_utils - 工具函数
- core_constants - 常量定义
- core_exceptions - 异常处理
- core_logging - 日志系统

### 2. [核心能力层手册](./01-核心能力层手册.md)
包含以下包的详细说明：
- core_network - 网络请求
- core_database - 数据库
- core_cache - 缓存系统
- core_state - 状态管理
- core_router - 路由管理
- core_ui - UI组件库
- core_media - 媒体处理

### 3. [业务服务层手册](./02-业务服务层手册.md)
包含以下包的详细说明：
- service_user - 用户服务
- service_auth - 认证服务
- service_content - 内容服务

### 4. [调用关系图谱](./03-调用关系图谱.md)
追踪方法之间的调用关系

---

## 🔍 如何使用本手册

### 场景 1：我想了解某个包的功能

1. 进入对应层级的手册
2. 查找包的章节
3. 查看「功能概述」和「核心方法」

### 场景 2：我想知道某个方法被哪些地方调用了

1. 在手册中搜索方法名
2. 查看「调用关系」部分
3. 找到调用该方法的上层方法

### 场景 3：我想知道某个方法内部调用了哪些方法

1. 找到方法的文档
2. 查看「内部调用」部分
3. 逐层深入理解

### 场景 4：我想快速定位某个文件

1. 查看包的「文件结构」
2. 找到对应文件的路径
3. 在 IDE 中打开

---

## 📖 符号说明

| 符号 | 含义 |
|------|------|
| 📦 | Package（包） |
| 📄 | File（文件） |
| 🔧 | Function/Method（方法/函数） |
| 🏗️ | Class（类） |
| 📊 | Enum（枚举） |
| ⬆️ | 被上层调用（谁调用了我） |
| ⬇️ | 调用下层（我调用了谁） |
| 🔗 | 相互依赖 |

---

## 🎯 快速导航

### 按功能查找

- **数据类型定义** → [core_base](./00-基础设施层手册.md#core_base)
- **字符串处理** → [core_utils](./00-基础设施层手册.md#core_utils)
- **网络请求** → [core_network](./01-核心能力层手册.md#core_network)
- **异常处理** → [core_exceptions](./00-基础设施层手册.md#core_exceptions)

### 按包名查找

- [core_base](./00-基础设施层手册.md#core_base)
- [core_utils](./00-基础设施层手册.md#core_utils)
- [core_constants](./00-基础设施层手册.md#core_constants)
- [core_exceptions](./00-基础设施层手册.md#core_exceptions)
- [core_logging](./00-基础设施层手册.md#core_logging)
- [core_network](./01-核心能力层手册.md#core_network)

---

## 📝 手册更新日志

| 日期 | 更新内容 | 作者 |
|------|---------|------|
| 2026-02-24 | 创建基础设施层手册 | Claude |
| 2026-02-24 | 创建核心能力层手册 | Claude |

---

**💡 提示**：建议将本目录添加到 IDE 的书签中，方便随时查阅。
