library;

/// 支付方式枚举 - 完全可扩展
enum PaymentMethod {
  /// 微信支付
  wechat('wechat'),

  /// 支付宝
  alipay('alipay'),

  /// 余额支付
  balance('balance'),

  /// 苹果支付
  apple('apple'),

  /// 自定义支付方式
  custom('custom');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.custom,
    );
  }
}

/// 交易类型
enum TransactionType {
  /// 充值
  recharge('recharge'),

  /// 消费
  purchase('purchase'),

  /// 提现
  withdraw('withdraw'),

  /// 转账
  transfer('transfer'),

  /// 退款
  refund('refund'),

  /// 奖励
  reward('reward'),

  /// 自定义
  custom('custom');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.custom,
    );
  }
}

/// 交易状态
enum TransactionStatus {
  /// 待处理
  pending('pending'),

  /// 处理中
  processing('processing'),

  /// 成功
  success('success'),

  /// 失败
  failed('failed'),

  /// 已取消
  cancelled('cancelled');

  const TransactionStatus(this.value);
  final String value;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.pending,
    );
  }
}

/// 交易记录 - 高度可扩展
final class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;

  /// 变动前余额
  final int balanceBefore;

  /// 变动后余额
  final int balanceAfter;

  final TransactionStatus status;

  /// 支付方式
  final PaymentMethod? paymentMethod;

  /// 关联订单ID（如果有）
  final String? orderId;

  /// 交易号
  final String? transactionNo;

  /// 自定义元数据
  final Map<String, dynamic>? metadata;

  final DateTime createdAt;
  final DateTime? completedAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    this.paymentMethod,
    this.orderId,
    this.transactionNo,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: TransactionType.fromString(json['type'] as String),
      amount: json['amount'] as int,
      balanceBefore: json['balanceBefore'] as int,
      balanceAfter: json['balanceAfter'] as int,
      status: TransactionStatus.fromString(json['status'] as String),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromString(json['paymentMethod'] as String)
          : null,
      orderId: json['orderId'] as String?,
      transactionNo: json['transactionNo'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'status': status.value,
      'paymentMethod': paymentMethod?.value,
      'orderId': orderId,
      'transactionNo': transactionNo,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt?.toIso8601String(),
    };
  }

  T? getMetadata<T>(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 是否成功
  bool get isSuccess => status == TransactionStatus.success;

  /// 是否失败
  bool get isFailed => status == TransactionStatus.failed;

  /// 是否处理中
  bool get isProcessing => status == TransactionStatus.processing;

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    int? balanceBefore,
    int? balanceAfter,
    TransactionStatus? status,
    PaymentMethod? paymentMethod,
    String? orderId,
    String? transactionNo,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderId: orderId ?? this.orderId,
      transactionNo: transactionNo ?? this.transactionNo,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, type: ${type.value}, amount: $amount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 充值配置
final class RechargeConfig {
  final String id;
  final int amount;
  final int bonus; // 赠送金额
  final String? description;
  final bool isRecommended;

  const RechargeConfig({
    required this.id,
    required this.amount,
    this.bonus = 0,
    this.description,
    this.isRecommended = false,
  });

  factory RechargeConfig.fromJson(Map<String, dynamic> json) {
    return RechargeConfig(
      id: json['id'] as String,
      amount: json['amount'] as int,
      bonus: json['bonus'] as int? ?? 0,
      description: json['description'] as String?,
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'bonus': bonus,
      'description': description,
      'isRecommended': isRecommended,
    };
  }

  /// 实际到账金额
  int get totalAmount => amount + bonus;

  @override
  String toString() => 'RechargeConfig(amount: $amount, bonus: $bonus)';
}

/// 提现信息
final class WithdrawInfo {
  final String id;
  final String userId;
  final int amount;
  final WithdrawMethod method;
  final String? account;
  final String? accountName;
  final TransactionStatus status;
  final String? remark;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WithdrawInfo({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    this.account,
    this.accountName,
    required this.status,
    this.remark,
    required this.createdAt,
    this.completedAt,
  });

  factory WithdrawInfo.fromJson(Map<String, dynamic> json) {
    return WithdrawInfo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      method: WithdrawMethod.fromString(json['method'] as String),
      account: json['account'] as String?,
      accountName: json['accountName'] as String?,
      status: TransactionStatus.fromString(json['status'] as String),
      remark: json['remark'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'method': method.value,
      'account': account,
      'accountName': accountName,
      'status': status.value,
      'remark': remark,
      'createdAt': createdAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'WithdrawInfo(id: $id, amount: $amount)';
}

/// 提现方式
enum WithdrawMethod {
  /// 微信
  wechat('wechat'),

  /// 支付宝
  alipay('alipay'),

  /// 银行卡
  bank('bank'),

  /// 自定义
  custom('custom');

  const WithdrawMethod(this.value);
  final String value;

  static WithdrawMethod fromString(String value) {
    return WithdrawMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => WithdrawMethod.custom,
    );
  }
}

/// 交易查询条件
final class TransactionQuery {
  final String? userId;
  final TransactionType? type;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int pageSize;

  const TransactionQuery({
    this.userId,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (userId != null) 'userId': userId,
      if (type != null) 'type': type!.value,
      if (status != null) 'status': status!.value,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'page': page,
      'pageSize': pageSize,
    };
  }

  TransactionQuery copyWith({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) {
    return TransactionQuery(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
