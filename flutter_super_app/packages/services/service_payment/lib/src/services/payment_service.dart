library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import '../models/payment.dart';
import '../repositories/payment_repository.dart';

/// 支付服务 - 高度可扩展的支付系统
///
/// 核心功能：
/// 1. 余额查询
/// 2. 充值 - 支持多种支付方式
/// 3. 提现
/// 4. 交易记录查询
///
/// 扩展性：
/// - 通过 Transaction.metadata 存储自定义交易数据
/// - 通过 PaymentMethod.custom 实现自定义支付方式
/// - 通过 TransactionType.custom 实现自定义交易类型
final class PaymentService {
  final PaymentRepository _repository;
  final ApiClient _apiClient;

  PaymentService({
    required PaymentRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        _apiClient = apiClient;

  // ==================== 余额管理 ====================

  /// 获取用户余额
  ///
  /// 返回值单位为分
  Future<Result<int>> getBalance(String userId) async {
    return await _repository.getBalance(userId);
  }

  // ==================== 充值 ====================

  /// 获取充值配置列表
  ///
  /// 使用示例：
  /// ```dart
  /// final configs = await service.getRechargeConfigs();
  /// // configs: [
  /// //   RechargeConfig(amount: 1000, bonus: 0),
  /// //   RechargeConfig(amount: 5000, bonus: 500),
  /// //   RechargeConfig(amount: 10000, bonus: 1500),
  /// // ]
  /// ```
  Future<Result<List<RechargeConfig>>> getRechargeConfigs() async {
    return await _repository.getRechargeConfigs();
  }

  /// 创建充值订单
  ///
  /// 返回支付所需的参数（如微信支付参数、支付宝参数等）
  ///
  /// 使用示例：
  /// ```dart
  /// final result = await service.createRecharge(
  ///   userId: 'user123',
  ///   configId: 'config1',
  ///   paymentMethod: PaymentMethod.wechat,
  /// );
  ///
  /// // 返回支付参数
  /// // {
  /// //   'orderId': 'xxx',
  /// //   'providerParams': {...}, // 微信/支付宝参数
  /// // }
  /// ```
  Future<Result<Map<String, dynamic>>> createRecharge({
    required String userId,
    required String configId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      Log.i('创建充值订单: $userId, $configId, ${paymentMethod.value}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payment/recharge',
        body: {
          'userId': userId,
          'configId': configId,
          'paymentMethod': paymentMethod.value,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;

        Log.i('创建充值订单成功');
        return Result.success(data);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '创建充值订单失败'),
      );
    } catch (e) {
      Log.e('创建充值订单失败', error: e);
      return Result.failure(Exception('创建充值订单失败: $e'));
    }
  }

  /// 查询充值订单状态
  Future<Result<TransactionStatus>> checkRechargeStatus(String orderId) async {
    try {
      Log.i('查询充值订单状态: $orderId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/payment/recharge/$orderId/status',
      );

      if (response.data != null && response.data!['success'] == true) {
        final statusStr = response.data!['data']['status'] as String;
        final status = TransactionStatus.fromString(statusStr);

        return Result.success(status);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '查询充值订单状态失败'),
      );
    } catch (e) {
      Log.e('查询充值订单状态失败', error: e);
      return Result.failure(Exception('查询充值订单状态失败: $e'));
    }
  }

  // ==================== 提现 ====================

  /// 申请提现
  ///
  /// 使用示例：
  /// ```dart
  /// await service.createWithdraw(
  ///   userId: 'user123',
  ///   amount: 10000, // 100元
  ///   method: WithdrawMethod.wechat,
  ///   account: '微信账号',
  /// );
  /// ```
  Future<Result<WithdrawInfo>> createWithdraw({
    required String userId,
    required int amount,
    required WithdrawMethod method,
    String? account,
    String? accountName,
    String? remark,
  }) async {
    return await _repository.createWithdraw(
      userId: userId,
      amount: amount,
      method: method,
      account: account,
      accountName: accountName,
      remark: remark,
    );
  }

  /// 获取提现记录
  Future<Result<List<WithdrawInfo>>> getWithdraws(String userId) async {
    return await _repository.getWithdraws(userId);
  }

  // ==================== 交易记录 ====================

  /// 获取交易记录详情
  Future<Result<Transaction>> getTransaction(String transactionId) async {
    return await _repository.getTransaction(transactionId);
  }

  /// 获取用户的交易记录列表
  ///
  /// 使用示例：
  /// ```dart
  /// // 获取所有交易记录
  /// final result = await service.getTransactions(
  ///   TransactionQuery(userId: 'user123'),
  /// );
  ///
  /// // 只获取充值记录
  /// final result = await service.getTransactions(
  ///   TransactionQuery(
  ///     userId: 'user123',
  ///     type: TransactionType.recharge,
  ///   ),
  /// );
  ///
  /// // 按时间范围查询
  /// final result = await service.getTransactions(
  ///   TransactionQuery(
  ///     userId: 'user123',
  ///     startDate: DateTime(2026, 1, 1),
  ///     endDate: DateTime(2026, 1, 31),
  ///   ),
  /// );
  /// ```
  Future<Result<PagedResult<Transaction>>> getTransactions(
    TransactionQuery query,
  ) async {
    try {
      Log.i('获取交易记录');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/transactions',
        queryParameters: query.toQueryParams(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final transactionsData = data['items'] as List;
        final transactions = transactionsData
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取交易记录成功: ${transactions.length} 条');
        return Result.success(
          PagedResult(
            data: transactions,
            pagination: Pagination(
              page: query.page,
              pageSize: query.pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取交易记录失败'),
      );
    } catch (e) {
      Log.e('获取交易记录失败', error: e);
      return Result.failure(Exception('获取交易记录失败: $e'));
    }
  }

  // ==================== 支付回调 ====================

  /// 处理支付回调（内部使用）
  ///
  /// 这个方法通常由后端调用，前端不需要直接调用
  Future<Result<void>> handlePaymentCallback({
    required String orderId,
    required Map<String, dynamic> callbackData,
  }) async {
    try {
      Log.i('处理支付回调: $orderId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/payment/callback/$orderId',
        body: callbackData,
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('处理支付回调成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '处理支付回调失败'),
      );
    } catch (e) {
      Log.e('处理支付回调失败', error: e);
      return Result.failure(Exception('处理支付回调失败: $e'));
    }
  }
}
