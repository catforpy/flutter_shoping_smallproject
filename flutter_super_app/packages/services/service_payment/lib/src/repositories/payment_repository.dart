library;

import 'package:core_base/core_base.dart';
import '../models/payment.dart';

/// 支付仓库接口
abstract class PaymentRepository {
  /// 获取用户余额
  Future<Result<int>> getBalance(String userId);

  /// 获取充值配置列表
  Future<Result<List<RechargeConfig>>> getRechargeConfigs();

  /// 创建充值订单
  Future<Result<Map<String, dynamic>>> createRecharge({
    required String userId,
    required String configId,
    required PaymentMethod paymentMethod,
  });

  /// 创建交易记录
  Future<Result<Transaction>> createTransaction(Transaction transaction);

  /// 获取交易记录详情
  Future<Result<Transaction>> getTransaction(String transactionId);

  /// 获取用户的交易记录列表
  Future<Result<PagedResult<Transaction>>> getTransactions(TransactionQuery query);

  /// 申请提现
  Future<Result<WithdrawInfo>> createWithdraw({
    required String userId,
    required int amount,
    required WithdrawMethod method,
    String? account,
    String? accountName,
    String? remark,
  });

  /// 获取提现记录
  Future<Result<List<WithdrawInfo>>> getWithdraws(String userId);

  /// 清除缓存
  Future<void> clearCache();
}
