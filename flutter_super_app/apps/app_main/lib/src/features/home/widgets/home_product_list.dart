library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_commerce/service_commerce.dart';
import '../theme/home_theme.dart';
import '../providers/home_product_provider.dart';
import 'product_card.dart';

/// 首页商品列表组件
///
/// 显示商品列表，支持分页加载（待实现）
class HomeProductList extends ConsumerWidget {
  const HomeProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(homeProductsProvider);

    return ListView.separated(
      padding:
          EdgeInsets.symmetric(vertical: HomeTheme.productListVerticalPadding),
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: HomeTheme.productCardSpacing),
      itemBuilder: (context, index) {
        final product = products[index];
        return HomeProductCard(product: product);
      },
    );
  }
}
