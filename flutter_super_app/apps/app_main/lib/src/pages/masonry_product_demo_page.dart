library;

import 'package:flutter/material.dart';
import 'package:service_commerce/service_commerce.dart';
import 'package:ui_components/ui_components.dart';
import 'package:ui_templates/ui_templates.dart';

/// 瀑布流商品示例页面
///
/// 展示如何使用 MasonryProductCard 和 WaterfallLayout
class MasonryProductDemoPage extends StatelessWidget {
  const MasonryProductDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('瀑布流商品示例'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.withValues(alpha: 0.05),
      body: WaterfallLayout(
        columns: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: _buildProductCards(),
      ),
    );
  }

  /// 构建示例商品卡片列表
  List<Widget> _buildProductCards() {
    // 生成示例商品数据
    final products = MockData.getHomeProducts();

    // 转换为错落商品卡片
    return products.map((product) {
      return _buildCard(product);
    }).toList();
  }

  /// 构建单个商品卡片（不同样式）
  Widget _buildCard(Product product) {
    // 根据商品ID选择不同的卡片样式
    final style = (int.parse(product.id) % 5);

    switch (style) {
      case 0:
        // 样式1：基础卡片 + 角标
        return MasonryProductCard(
          data: product.toMasonryCardData(
            cornerBadge: '自营',
          ),
        );

      case 1:
        // 样式2：基础卡片 + 角标 + 标签
        return MasonryProductCard(
          data: product.toMasonryCardData(
            cornerBadge: '京东自营',
            cornerBadgeColor: Colors.red,
            tags: [
              MasonryProductCardTag(
                text: '7天无理由退货',
                bgColor: Colors.green.shade50,
                textColor: Colors.green.shade700,
                borderColor: Colors.green.shade200,
              ),
            ],
          ),
        );

      case 2:
        // 样式3：基础卡片 + 角标 + 服务
        return MasonryProductCard(
          data: product.toMasonryCardData(
            cornerBadge: '包邮',
            cornerBadgeColor: Colors.orange,
            services: [
              MasonryProductCardTag(
                text: '买贵双倍赔',
                bgColor: Colors.orange.shade50,
                textColor: Colors.orange.shade700,
              ),
              MasonryProductCardTag(
                text: '6期免息',
                bgColor: Colors.orange.shade50,
                textColor: Colors.orange.shade700,
              ),
            ],
          ),
        );

      case 3:
        // 样式4：完整卡片（角标 + 标签 + 服务）
        return MasonryProductCard(
          data: product.toMasonryCardData(
            cornerBadge: '百亿补贴',
            cornerBadgeColor: Colors.red,
            tags: [
              MasonryProductCardTag(
                text: '新品',
                bgColor: Colors.red.shade50,
                textColor: Colors.red.shade700,
                borderColor: Colors.red.shade200,
              ),
              MasonryProductCardTag(
                text: '赠品',
                bgColor: Colors.purple.shade50,
                textColor: Colors.purple.shade700,
                borderColor: Colors.purple.shade200,
              ),
            ],
            services: [
              MasonryProductCardTag(
                text: '包邮',
                bgColor: Colors.orange.shade50,
                textColor: Colors.orange.shade700,
              ),
              MasonryProductCardTag(
                text: '先用后付',
                bgColor: Colors.blue.shade50,
                textColor: Colors.blue.shade700,
              ),
            ],
          ),
        );

      default:
        // 样式5：带浮标
        return MasonryProductCard(
          data: product.toMasonryCardData(
            cornerBadge: '自营',
            floatingBadge: _buildFloatingBadge(),
          ),
        );
    }
  }

  /// 构建浮标组件
  Widget _buildFloatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '补',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
