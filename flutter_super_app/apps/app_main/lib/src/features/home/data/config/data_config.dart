library;

import '../repositories/home_repository.dart';

/// 数据源配置
///
/// 集中管理数据源切换，方便后期一键替换
class DataConfig {
  /// 是否使用 Mock 数据
  ///
  /// 开发阶段：true（使用假数据）
  /// 生产环境：false（使用真实 API）
  static const bool useMockData = true;

  /// API 基础地址
  static const String apiBaseUrl = 'https://api.example.com';

  /// 获取首页数据仓库实例
  ///
  /// 根据 useMockData 自动切换数据源
  static HomeRepository get homeRepository {
    if (useMockData) {
      return MockHomeRepository();
    } else {
      return ApiHomeRepository(baseUrl: apiBaseUrl);
    }
  }
}
