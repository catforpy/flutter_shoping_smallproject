# GroupedListSection 组件使用说明

## 📖 简介

`GroupedListSection` 是一个高度灵活的分组列表组件，基于 `AppListTile` 组合而成，支持函数式链式调用。

## ✨ 特性

- ✅ **函数式风格**：配置类不可变，通过 `copyWith` 和函数式方法实现链式调用
- ✅ **高度灵活**：所有样式均可外部配置，避免硬编码
- ✅ **组合式设计**：基于 `AppListTile` 组合而成，而非重新实现
- ✅ **可扩展性**：支持自定义 Tile，支持卡片效果
- ✅ **完整注释**：所有代码都有详细的中文注释

## 🎯 快速开始

### 基础用法

```dart
import 'package:ui_components/ui_components.dart';

// 最简单的用法
GroupedListSection(
  config: GroupedListSectionConfig(
    items: [
      GroupedListItemConfig(title: '项目 A'),
      GroupedListItemConfig(title: '项目 B'),
      GroupedListItemConfig(title: '项目 C'),
    ],
  ),
)
```

### 带标题的分组

```dart
GroupedListSection(
  config: GroupedListSectionConfig(
    titleConfig: GroupedListTitleConfig(
      title: '我的企业',
      backgroundColor: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    items: [
      GroupedListItemConfig(
        title: '联系人 A',
        leading: Icon(Icons.person),
        onTap: () => print('点击'),
      ),
    ],
  ),
)
```

### 函数式链式调用

```dart
// 链式调用构建配置
final config = GroupedListSectionConfig()
    .withTitle(
      GroupedListTitleConfig(title: '我的企业'),
    )
    .withDivider(
      GroupedListDividerConfig(
        color: Colors.blue,
        opacity: 0.5,
      ),
    )
    .addItem(GroupedListItemConfig(title: '项目 A'))
    .addItem(GroupedListItemConfig(title: '项目 B'))
    .withCardEffect(
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );

GroupedListSection(config: config);
```

### 多个分组

```dart
GroupedListView(
  sections: [
    // 第一组
    GroupedListSectionConfig(
      titleConfig: GroupedListTitleConfig(title: '企业联系人'),
      items: [
        GroupedListItemConfig(title: '张三'),
        GroupedListItemConfig(title: '李四'),
      ],
    ),

    // 第二组（空标题作为间距）
    GroupedListSectionConfig(
      titleConfig: GroupedListTitleConfig(
        title: '',
        padding: EdgeInsets.only(top: 16),
      ),
      items: [
        GroupedListItemConfig(title: '项目组 A'),
      ],
    ),
  ],
)
```

## ⚙️ 配置说明

### GroupedListTitleConfig（标题配置）

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | String | `''` | 标题文字（空字符串表示不显示） |
| `textStyle` | TextStyle? | `null` | 标题文字样式 |
| `padding` | EdgeInsetsGeometry | `horizontal: 16, vertical: 12` | 标题区域内边距 |
| `align` | GroupedListTitleAlign | `left` | 对齐方式（left/center/right） |
| `backgroundColor` | Color? | `null` | 背景颜色（null=透明） |
| `border` | Border? | `null` | 边框 |
| `borderRadius` | BorderRadius? | `null` | 圆角 |
| `height` | double? | `null` | 标题高度（null=自适应） |

### GroupedListDividerConfig（分割线配置）

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `color` | Color | `Colors.grey` | 分割线颜色 |
| `opacity` | double | `0.3` | 透明度（0.0-1.0） |
| `height` | double | `1.0` | 分割线高度（厚度） |
| `indent` | double? | `null` | 左边距（null=延伸到左边缘） |
| `endIndent` | double? | `null` | 右边距（null=延伸到右边缘） |

### GroupedListItemConfig（Tile 配置）

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | String | 必填 | Tile 标题 |
| `subtitle` | String? | `null` | Tile 副标题 |
| `leading` | Widget? | `null` | 前缀图标 |
| `trailing` | Widget? | `null` | 后缀组件 |
| `onTap` | VoidCallback? | `null` | 点击回调 |
| `type` | AppListTileType | `navigation` | Tile 类型 |
| `backgroundColor` | Color? | `null` | 背景颜色 |
| `enabled` | bool | `true` | 是否启用 |
| `customTile` | Widget? | `null` | 自定义 Tile |

### GroupedListSectionConfig（分组配置）

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `titleConfig` | GroupedListTitleConfig | 默认配置 | 标题配置 |
| `dividerConfig` | GroupedListDividerConfig | 默认配置 | 分割线配置 |
| `sectionSpacing` | EdgeInsetsGeometry | `bottom: 24` | 组间距 |
| `items` | List | `[]` | Tile 列表 |
| `showCardEffect` | bool | `false` | 是否显示卡片效果 |
| `cardBackgroundColor` | Color? | `null` | 卡片背景色 |
| `cardBorderRadius` | BorderRadius? | `null` | 卡片圆角 |
| `cardPadding` | EdgeInsetsGeometry | `zero` | 卡片内边距 |
| `cardMargin` | EdgeInsetsGeometry | `zero` | 卡片外边距 |

## 🔧 函数式方法

### GroupedListSectionConfig 方法

```dart
// 复制并修改部分属性
config.copyWith(
  titleConfig: newTitleConfig,
  dividerConfig: newDividerConfig,
);

// 添加单个 item
config.addItem(itemConfig);

// 添加多个 items
config.addItems([item1, item2]);

// 更新标题
config.withTitle(newTitleConfig);

// 更新分割线
config.withDivider(newDividerConfig);

// 启用卡片效果
config.withCardEffect(
  backgroundColor: Colors.white,
  borderRadius: BorderRadius.circular(12),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
);
```

## 🎨 实际使用场景

### 场景 1：设置页面

```dart
GroupedListSection(
  config: GroupedListSectionConfig(
    titleConfig: GroupedListTitleConfig(title: '设置'),
    items: [
      GroupedListItemConfig(
        title: '账号与安全',
        leading: Icon(Icons.security),
        onTap: () => navigator.push(AccountSecurityPage()),
      ),
      GroupedListItemConfig(
        title: '消息通知',
        leading: Icon(Icons.notifications),
      ),
      GroupedListItemConfig(
        title: '隐私设置',
        leading: Icon(Icons.lock),
      ),
    ],
  ).withCardEffect(),
)
```

### 场景 2：企业联系人列表

```dart
GroupedListView(
  sections: [
    // 企业联系人
    GroupedListSectionConfig(
      titleConfig: GroupedListTitleConfig(
        title: '我的企业',
        backgroundColor: Colors.grey[100],
      ),
      items: [
        GroupedListItemConfig(
          title: '张三',
          subtitle: '总经理',
          leading: CircleAvatar(child: Text('张')),
        ),
        GroupedListItemConfig(
          title: '李四',
          subtitle: '技术总监',
          leading: CircleAvatar(child: Text('李')),
        ),
      ],
    ),

    // 项目组
    GroupedListSectionConfig(
      titleConfig: GroupedListTitleConfig(
        title: '',
        padding: EdgeInsets.only(top: 16),
      ),
      items: [
        GroupedListItemConfig(
          title: '项目组 A',
          leading: Icon(Icons.group),
        ),
      ],
    ),
  ],
)
```

### 场景 3：自定义样式

```dart
GroupedListSection(
  config: GroupedListSectionConfig(
    titleConfig: GroupedListTitleConfig(
      title: '自定义样式',
      align: GroupedListTitleAlign.center,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      border: Border(
        bottom: BorderSide(color: Colors.blue, width: 2),
      ),
    ),
    dividerConfig: GroupedListDividerConfig(
      color: Colors.blue,
      opacity: 0.5,
      height: 2,
      indent: 16,
      endIndent: 16,
    ),
    items: [
      GroupedListItemConfig(
        title: '选项 1',
        backgroundColor: Colors.blue[50],
      ),
    ],
  ),
)
```

## 📝 文件位置

- **组件文件**：`packages/ui/ui_components/lib/src/lists/grouped_list_section.dart`
- **示例文件**：`packages/ui/ui_components/lib/src/lists/grouped_list_section_example.dart`
- **导出位置**：`packages/ui/ui_components/lib/ui_components.dart`

## 🚀 下一步

可以基于这个组件继续扩展：

1. **添加更多 Tile 类型支持**（如开关、复选框等）
2. **添加展开/折叠功能**
3. **添加拖拽排序功能**
4. **添加滑动删除功能**
5. **添加分组动画效果**
