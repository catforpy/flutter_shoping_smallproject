# service_payment

高度可扩展的支付服务 - 支持充值、提现、交易记录管理。

## 核心特性

### 1. 完全可扩展
- 通过 `Transaction.metadata` 存储自定义交易数据
- 通过 `PaymentMethod.custom` 实现自定义支付方式
- 通过 `TransactionType.custom` 实现自定义交易类型

### 2. 支付方式
- **wechat** - 微信支付
- **alipay** - 支付宝
- **balance** - 余额支付
- **apple** - 苹果支付
- **custom** - 自定义

### 3. 交易类型
- **recharge** - 充值
- **purchase** - 消费
- **withdraw** - 提现
- **transfer** - 转账
- **refund** - 退款
- **reward** - 奖励
- **custom** - 自定义

## 使用示例

### 余额查询

```dart
final balance = await service.getBalance('user123');
// 返回值单位为分
```

### 充值

```dart
// 获取充值配置
final configs = await service.getRechargeConfigs();

// 创建充值订单
final result = await service.createRecharge(
  userId: 'user123',
  configId: 'config1',
  paymentMethod: PaymentMethod.wechat,
);

// 返回支付参数
// {
//   'orderId': 'xxx',
//   'providerParams': {...}, // 微信支付参数
// }
```

### 提现

```dart
await service.createWithdraw(
  userId: 'user123',
  amount: 10000, // 100元
  method: WithdrawMethod.wechat,
  account: '微信账号',
);
```

### 交易记录

```dart
// 获取所有交易
final result = await service.getTransactions(
  TransactionQuery(userId: 'user123'),
);

// 只获取充值记录
final result = await service.getTransactions(
  TransactionQuery(
    userId: 'user123',
    type: TransactionType.recharge,
  ),
);

// 按时间范围查询
final result = await service.getTransactions(
  TransactionQuery(
    userId: 'user123',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 31),
  ),
);
```

## 扩展指南

### 自定义交易类型

```dart
Transaction(
  type: TransactionType.custom,
  metadata: {
    'action': 'exchange',
    'from': 'coin',
    'to': 'diamond',
  },
);
```
