library;

import 'package:flutter/material.dart';
import 'package:service_commerce/service_commerce.dart';
import 'package:ui_components/ui_components.dart';
import '../theme/home_theme.dart';

/// 首页商品卡片组件
///
/// 基于 UniversalProductCard，封装首页特有的交互和样式
class HomeProductCard extends StatelessWidget {
  final Product product;

  const HomeProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalProductCard(
      image: NetworkImage(product.coverImage ?? ''),
      title: product.name,
      price: product.priceInYuan,
      originalPrice: product.originalPriceInYuan,
      reviewCount: product.formattedReviewCount,
      salesCount: product.formattedSalesCount,
      imageHeight: HomeTheme.productImageHeight,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查看商品: ${product.name}')),
        );
      },
      actionButtonText: '立即抢购',
      actionButtonColor: HomeTheme.productActionButtonColor,
      onActionTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('立即抢购: ${product.name}')),
        );
      },
    );
  }
}
