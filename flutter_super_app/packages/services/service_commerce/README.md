# service_commerce

高度可扩展的电商服务 - 支持商品、购物车、订单管理。

## 核心特性

### 1. 完全可扩展
- 通过 `Product.metadata` 存储自定义商品属性
- 通过 `ProductType.custom` 实现自定义商品类型
- 支持 SKU、规格等复杂商品结构

### 2. 商品类型
- **physical** - 实体商品
- **virtual** - 虚拟商品
- **service** - 服务
- **membership** - 会员
- **gift** - 礼物
- **custom** - 自定义

### 3. 完整购物流程
- 商品浏览与搜索
- 购物车管理
- 订单创建与管理
- 物流跟踪

## 使用示例

### 商品管理

```dart
// 获取商品列表
final result = await service.getProducts(
  ProductQuery(sortType: ProductSortType.latest),
);

// 按价格筛选
final result = await service.getProducts(
  ProductQuery(
    minPrice: 1000,
    maxPrice: 5000,
    sortType: ProductSortType.priceAsc,
  ),
);

// 搜索商品
final result = await service.getProducts(
  ProductQuery(keyword: '手机'),
);
```

### 购物车

```dart
// 添加到购物车
await service.addToCart(
  userId: 'user123',
  productId: 'product123',
  quantity: 1,
);

// 获取购物车
final cart = await service.getCart('user123');

// 更新数量
await service.updateCartItem(
  cartItemId: 'cart1',
  quantity: 2,
);
```

### 订单

```dart
// 创建订单
final address = ShippingAddress(
  name: '张三',
  phone: '13800138000',
  province: '北京市',
  city: '北京市',
  district: '朝阳区',
  detail: 'xxx街道xxx号',
);

await service.createOrder(
  userId: 'user123',
  cartItemIds: ['cart1', 'cart2'],
  shippingAddress: address,
  remark: '请尽快发货',
);

// 获取用户订单
final orders = await service.getUserOrders(
  userId: 'user123',
  status: OrderStatus.pending,
);
```

## 扩展指南

### 自定义商品类型

```dart
Product(
  type: ProductType.custom,
  metadata: {
    'productSubType': 'course',
    'duration': 3600,
    'instructor': '讲师名',
  },
);
```
