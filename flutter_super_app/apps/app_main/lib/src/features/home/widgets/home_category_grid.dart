library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../theme/home_theme.dart';

/// 首页分类网格组件
///
/// 显示可展开的分类网格，第一页显示 1 行，第二页显示 3 行
class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({super.key});

  /// 分类数据（名称 + 图标）
  static const categoryData = [
    ('品质外卖', Icons.restaurant),
    ('新人福利', Icons.card_giftcard),
    ('签到', Icons.event_available),
    ('东东农场', Icons.agriculture),
    ('领红包', Icons.card_giftcard),
    ('万人团', Icons.groups),
    ('京东超市', Icons.shopping_cart),
    ('手机数码', Icons.phone_android),
    ('家电家居', Icons.tv),
    ('优惠充值', Icons.phone_in_talk),
    ('京东国际', Icons.public),
    ('看房买药', Icons.medical_services),
    ('拍拍二手', Icons.cached),
    ('京东拍卖', Icons.gavel),
    ('沃尔玛', Icons.store),
    ('京东生鲜', Icons.eco),
    ('京东到家', Icons.delivery_dining),
    ('大牌试用', Icons.stars),
    ('领券', Icons.local_offer),
    ('零食广场', Icons.fastfood),
  ];

  @override
  Widget build(BuildContext context) {
    // 生成 widget 列表
    final categoryWidgets =
        categoryData.map((data) => _CategoryItem(title: data.$1, icon: data.$2)).toList();

    return Container(
      color: HomeTheme.backgroundColor,
      child: ExpandableGridPageView(
        children: categoryWidgets,
        crossAxisCount: HomeTheme.gridCrossAxisCount,
        firstPageRows: HomeTheme.gridFirstPageRows,
        secondPageRows: HomeTheme.gridSecondPageRows,
        topPadding: HomeTheme.gridTopPadding,
        bottomPadding: HomeTheme.gridBottomPadding,
        spacing: HomeTheme.gridSpacing,
        runSpacing: HomeTheme.gridRunSpacing,
        onTap: (index) {
          final categoryName = categoryData[index].$1;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了：$categoryName')),
          );
        },
        onMoreTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('查看全部频道')),
          );
        },
      ),
    );
  }
}

/// 单个分类 item 组件
class _CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CategoryItem({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: HomeTheme.categoryIconSize,
          color: Colors.grey[700],
        ),
        SizedBox(height: HomeTheme.categoryIconTextSpacing),
        Text(
          title,
          style: TextStyle(
            fontSize: HomeTheme.categoryFontSize,
            color: Colors.grey[700],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
