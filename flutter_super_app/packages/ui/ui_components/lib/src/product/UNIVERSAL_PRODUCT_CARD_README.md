# UniversalProductCard - 通用电商商品卡片组件

## 📦 组件概述

`UniversalProductCard` 是一个高度可配置的通用电商商品卡片组件，采用"左图右文"的布局方式，支持各种电商场景的商品展示需求。

## 🎯 功能特性

### 核心区域（从上到下）

1. ✅ **顶部标签区** - 多个标签横向排列（如"自营"、"包邮"）
2. ✅ **主图区** - 商品图片 + 左下角角标
3. ✅ **标题区** - 商品名称（多行截断）
4. ✅ **促销/价格信息区** - 主价格、原价、促销标签、服务标签
5. ✅ **评价/销量区** - 评论数、销量统计
6. ✅ **行动按钮区** - 下单、加入购物车等按钮

### 高级特性

- 🎨 高度可配置的样式
- 🖱️ 完整的点击事件支持
- 📱 响应式布局（左图右文）
- 🌈 支持自定义颜色、字体、间距
- 🔧 灵活的扩展性（自定义 Widget）

## 🚀 快速开始

### 基础用法

```dart
import 'package:ui_components/ui_components.dart';

UniversalProductCard(
  image: NetworkImage('https://example.com/product.jpg'),
  title: 'Apple iPhone 15 Pro Max 256GB',
  price: 9999.00,
  originalPrice: 10999.00,
  onTap: () {
    print('跳转到商品详情');
  },
)
```

### 完整配置示例

```dart
UniversalProductCard(
  // ========== 主图 ==========
  image: NetworkImage('https://example.com/product.jpg'),

  // ========== 标题 ==========
  title: 'Apple iPhone 15 Pro Max 256GB 钛金属原色',

  // ========== 价格 ==========
  price: 9999.00,
  originalPrice: 10999.00,
  currencySymbol: '¥',

  // ========== 顶部标签 ==========
  topTags: [
    ProductCardTag(
      text: '自营',
      bgColor: Colors.red,
      textColor: Colors.white,
    ),
    ProductCardTag(
      text: '包邮',
      bgColor: Colors.orange,
      textColor: Colors.white,
    ),
    ProductCardTag(
      text: '新人价',
      icon: Icons.card_giftcard,
      bgColor: Colors.purple[50],
      textColor: Colors.purple,
    ),
  ],

  // ========== 主图角标 ==========
  cornerBadgeText: '京喜自营 包邮',
  cornerBadgeBgColor: Colors.red,

  // ========== 促销标签 ==========
  promoTags: [
    ProductCardTag(
      text: '30天最低价',
      bgColor: Colors.red[50],
      textColor: Colors.red,
    ),
    ProductCardTag(
      text: '焕新补贴立减15%',
      bgColor: Colors.orange[50],
      textColor: Colors.orange,
    ),
  ],

  // ========== 服务标签 ==========
  serviceTags: [
    ProductCardTag(
      text: '先用后付',
      bgColor: Colors.green[50],
      textColor: Colors.green,
    ),
    ProductCardTag(
      text: '闪电退款',
      bgColor: Colors.blue[50],
      textColor: Colors.blue,
    ),
  ],

  // ========== 新人价 ==========
  newUserPrice: 8999.00,
  newUserLabel: '新人价',

  // ========== 评价/销量 ==========
  reviewCount: '500+条评论',
  salesCount: '已售10万+',

  // ========== 行动按钮 ==========
  actionButtonText: '下单',
  actionButtonColor: Colors.red,
  onActionTap: () {
    print('立即下单');
  },

  // ========== 整体点击 ==========
  onTap: () {
    print('跳转到商品详情页');
  },

  // ========== 样式配置 ==========
  padding: const EdgeInsets.all(12),
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  borderRadius: BorderRadius.circular(12),
  backgroundColor: Colors.white,
  showShadow: true,

  // ========== 布局配置 ==========
  imageFlex: 2,        // 主图宽度比例
  contentFlex: 3,      // 内容宽度比例
  imageHeight: 120,    // 主图固定高度
)
```

## 📐 参数详解

### 必填参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `image` | `ImageProvider` | 商品图片 |
| `title` | `String` | 商品标题 |
| `price` | `double` | 主价格 |

### 图片相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `cornerBadgeText` | `String?` | `null` | 左下角角标文字 |
| `cornerBadgeBgColor` | `Color?` | `Colors.red` | 角标背景色 |
| `cornerBadgeTextColor` | `Color?` | `Colors.white` | 角标文字颜色 |
| `topLeftBadge` | `Widget?` | `null` | 左上角徽章（如"新品"） |
| `topRightBadge` | `Widget?` | `null` | 右上角徽章（如"视频"） |
| `imageFlex` | `int` | `2` | 图片宽度比例 |
| `imageHeight` | `double?` | `null` | 图片固定高度 |

### 标题相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `maxTitleLines` | `int` | `2` | 标题最大行数 |
| `titleStyle` | `TextStyle?` | 默认样式 | 标题文字样式 |

### 价格相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `originalPrice` | `double?` | `null` | 原价（划线价） |
| `currencySymbol` | `String` | `'¥'` | 货币符号 |
| `priceStyle` | `TextStyle?` | 默认样式 | 主价格样式 |
| `originalPriceStyle` | `TextStyle?` | 默认样式 | 原价样式 |

### 标签相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `topTags` | `List<Widget>?` | `null` | 顶部标签列表 |
| `promoTags` | `List<Widget>?` | `null` | 促销标签列表 |
| `serviceTags` | `List<Widget>?` | `null` | 服务标签列表 |

### 新人价相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `newUserPrice` | `double?` | `null` | 新人专享价格 |
| `newUserLabel` | `String?` | `'新人价'` | 新人价标签文字 |
| `specialPriceIndicator` | `Widget?` | `null` | 新人价指示器 |

### 统计信息

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `reviewCount` | `String?` | `null` | 评价数量（如"500+条评论"） |
| `salesCount` | `String?` | `null` | 销量（如"已售10万+"） |
| `statsStyle` | `TextStyle?` | 默认样式 | 统计文字样式 |

### 按钮相关

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `actionButtonText` | `String?` | `null` | 按钮文字 |
| `actionButtonColor` | `Color?` | `Colors.red` | 按钮背景色 |
| `actionButtonTextColor` | `Color?` | `Colors.white` | 按钮文字颜色 |
| `onActionTap` | `VoidCallback?` | `null` | 按钮点击回调 |
| `customActionButton` | `Widget?` | `null` | 自定义按钮（优先） |

### 样式配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `backgroundColor` | `Color?` | `Colors.white` | 卡片背景色 |
| `borderRadius` | `BorderRadius?` | `8px` | 卡片圆角 |
| `padding` | `EdgeInsetsGeometry?` | `12px` | 卡片内边距 |
| `margin` | `EdgeInsetsGeometry?` | `16px 8px` | 卡片外边距 |
| `showShadow` | `bool` | `true` | 是否显示阴影 |

### 事件回调

| 参数 | 类型 | 说明 |
|------|------|------|
| `onTap` | `VoidCallback?` | 整个卡片点击回调 |
| `onActionTap` | `VoidCallback?` | 行动按钮点击回调 |

## 🎨 ProductCardTag 标签组件

### 基础用法

```dart
ProductCardTag(
  text: '自营',
  bgColor: Colors.red,
  textColor: Colors.white,
)
```

### 带图标

```dart
ProductCardTag(
  text: '包邮',
  icon: Icons.local_shipping,
  bgColor: Colors.orange,
  textColor: Colors.white,
)
```

### 自定义样式

```dart
ProductCardTag(
  text: '30天最低价',
  bgColor: Colors.red[50],
  textColor: Colors.red,
  fontSize: 11,
  fontWeight: FontWeight.w500,
  borderRadius: BorderRadius.circular(4),
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
)
```

## 💡 使用场景

### 场景1：商品列表（瀑布流）

```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return UniversalProductCard(
      image: NetworkImage(product.imageUrl),
      title: product.title,
      price: product.price,
      originalPrice: product.originalPrice,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        ),
      ),
    );
  },
)
```

### 场景2：搜索结果

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  itemCount: searchResults.length,
  itemBuilder: (context, index) {
    final result = searchResults[index];
    return UniversalProductCard(
      image: NetworkImage(result.imageUrl),
      title: result.title,
      price: result.price,
      reviewCount: result.reviewCount,
      salesCount: result.salesCount,
      padding: const EdgeInsets.all(8),
    );
  },
)
```

### 场景3：推荐商品

```dart
Column(
  children: [
    UniversalProductCard(
      image: NetworkImage(product.imageUrl),
      title: product.title,
      price: product.price,
      cornerBadgeText: '京喜自营 包邮',
      topTags: [
        ProductCardTag(text: '推荐', bgColor: Colors.red, textColor: Colors.white),
      ],
      actionButtonText: '立即抢购',
      onActionTap: () => _buyNow(product),
    ),
    UniversalProductCard(
      image: NetworkImage(product2.imageUrl),
      title: product2.title,
      price: product2.price,
      newUserPrice: product2.newUserPrice,
      promoTags: [
        ProductCardTag(text: '限时特惠', bgColor: Colors.orange, textColor: Colors.white),
      ],
    ),
  ],
)
```

## 🔧 高级用法

### 自定义行动按钮

```dart
UniversalProductCard(
  image: NetworkImage(product.imageUrl),
  title: product.title,
  price: product.price,
  customActionButton: Row(
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.shopping_cart, size: 16),
        label: const Text('加入购物车'),
        onPressed: () => _addToCart(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _buyNow(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('立即购买'),
      ),
    ],
  ),
)
```

### 自定义主图徽章

```dart
UniversalProductCard(
  image: NetworkImage(product.imageUrl),
  title: product.title,
  price: product.price,
  topLeftBadge: Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      '新品',
      style: TextStyle(color: Colors.white, fontSize: 10),
    ),
  ),
  topRightBadge: Container(
    padding: const EdgeInsets.all(4),
    decoration: const BoxDecoration(
      color: Colors.black54,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
  ),
)
```

### 响应式布局

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isTablet = constraints.maxWidth > 600;
    return UniversalProductCard(
      image: NetworkImage(product.imageUrl),
      title: product.title,
      price: product.price,
      imageFlex: isTablet ? 1 : 2,
      contentFlex: isTablet ? 2 : 3,
      imageHeight: isTablet ? 150 : 120,
    );
  },
)
```

## 🎯 最佳实践

1. **图片加载优化**：使用 `CachedNetworkImage` 替代 `NetworkImage`
2. **价格格式化**：后端返回的价格单位统一（如：分），前端显示时转换
3. **标签复用**：将常用标签封装成常量或方法
4. **点击事件**：卡片整体跳转详情页，按钮触发具体操作
5. **样式统一**：通过 Theme 配置全局样式，保持视觉一致性

## 📚 相关组件

- `ProductCard` - 课程商品卡片
- `ProductImage` - 商品图片组件
- `ProductTag` - 商品标签组件
- `ProductImageBadge` - 图片徽章组件

## 🔗 相关链接

- [Flutter 官方文档](https://flutter.dev/docs)
- [商品卡片设计规范](https://design.alibaba.com/)
