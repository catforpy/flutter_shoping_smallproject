library;

import '../models/home_tab_model.dart';
import '../mocks/mock_data.dart';

/// 首页数据仓库
///
/// 抽象数据源，支持一键切换 Mock 数据和真实 API
abstract class HomeRepository {
  /// 获取首页标签列表
  Future<List<HomeTabModel>> getHomeTabs();

  /// 获取首页内容（根据标签ID）
  Future<dynamic> getHomeContent(String tabId);
}

/// Mock 数据仓库实现
///
/// 开发阶段使用，返回假数据
class MockHomeRepository implements HomeRepository {
  @override
  Future<List<HomeTabModel>> getHomeTabs() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 返回 Mock 数据
    return MockData.homeTabs;
  }

  @override
  Future<dynamic> getHomeContent(String tabId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 返回 Mock 数据
    return MockData.getHomeContent(tabId);
  }
}

/// API 数据仓库实现
///
/// 后期接入后端时使用，请求真实 API
///
/// TODO: 后期实现真实的网络请求
class ApiHomeRepository implements HomeRepository {
  final String baseUrl;

  ApiHomeRepository({required this.baseUrl});

  @override
  Future<List<HomeTabModel>> getHomeTabs() async {
    // TODO: 实现真实的网络请求
    // 示例代码：
    // final response = await http.get(Uri.parse('$baseUrl/api/home/tabs'));
    // final json = jsonDecode(response.body) as List;
    // return json.map((item) => HomeTabModel.fromJson(item)).toList();

    throw UnimplementedError('API 请求尚未实现，请使用 MockHomeRepository');
  }

  @override
  Future<dynamic> getHomeContent(String tabId) async {
    // TODO: 实现真实的网络请求
    throw UnimplementedError('API 请求尚未实现，请使用 MockHomeRepository');
  }
}
