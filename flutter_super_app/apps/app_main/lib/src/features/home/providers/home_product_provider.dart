library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_commerce/service_commerce.dart';
import '../data/mocks/mock_data.dart';

/// 首页商品列表状态
final homeProductsProvider = Provider<List<Product>>((ref) {
  // 从 Mock 数据获取商品列表
  // 后期接入后端时，可改为使用 FutureProvider 或 StreamProvider
  return MockData.getHomeProducts();
});
