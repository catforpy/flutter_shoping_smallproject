library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';

/// UniversalProductCard 使用示例页面
///
/// 展示各种配置的商品卡片效果
class UniversalProductCardExamples extends StatelessWidget {
  const UniversalProductCardExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品卡片示例'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionTitle('基础用法'),
          _buildBasicExample(),

          const SizedBox(height: 24),

          _buildSectionTitle('完整配置'),
          _buildFullConfigExample(),

          const SizedBox(height: 24),

          _buildSectionTitle('促销活动'),
          _buildPromoExample(),

          const SizedBox(height: 24),

          _buildSectionTitle('新人专享'),
          _buildNewUserExample(),

          const SizedBox(height: 24),

          _buildSectionTitle('服务标签'),
          _buildServiceExample(),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 基础用法示例
  Widget _buildBasicExample() {
    return UniversalProductCard(
      image: const NetworkImage(
        'https://picsum.photos/seed/iphone/200/200',
      ),
      title: 'Apple iPhone 15 Pro Max 256GB 钛金属原色',
      price: 9999.00,
      originalPrice: 10999.00,
      reviewCount: '500+条评论',
      salesCount: '已售10万+',
      onTap: () {
        debugPrint('点击了基础卡片');
      },
    );
  }

  /// 完整配置示例
  Widget _buildFullConfigExample() {
    return UniversalProductCard(
      image: const NetworkImage(
        'https://picsum.photos/seed/laptop/200/200',
      ),
      title: 'MacBook Pro 14英寸 M3 Pro芯片 18GB内存 512GB存储',
      price: 16999.00,
      originalPrice: 18999.00,
      currencySymbol: '¥',

      // 顶部标签
      topTags: [
        _buildTag('自营', Colors.red, Colors.white),
        _buildTag('包邮', Colors.orange, Colors.white),
        _buildTag('新品', Colors.purple, Colors.white),
      ],

      // 左下角角标
      cornerBadgeText: '京喜自营 包邮',
      cornerBadgeBgColor: Colors.red,

      // 促销标签
      promoTags: [
        _buildTag('30天最低价', Colors.red[50]!, Colors.red),
        _buildTag('焕新补贴立减15%', Colors.orange[50]!, Colors.orange),
      ],

      // 服务标签
      serviceTags: [
        _buildTag('先用后付', Colors.green[50]!, Colors.green),
        _buildTag('闪电退款', Colors.blue[50]!, Colors.blue),
      ],

      // 评价/销量
      reviewCount: '2000+条评论',
      salesCount: '已售50万+',

      // 行动按钮
      actionButtonText: '下单',
      actionButtonColor: Colors.red,
      onActionTap: () {
        debugPrint('点击下单按钮');
      },

      // 整体点击
      onTap: () {
        debugPrint('点击卡片跳转详情');
      },

      // 样式配置
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// 促销活动示例
  Widget _buildPromoExample() {
    return UniversalProductCard(
      image: const NetworkImage(
        'https://picsum.photos/seed/watch/200/200',
      ),
      title: 'Apple Watch Series 9 GPS款 45毫米 深色铝金属',
      price: 2999.00,
      originalPrice: 3199.00,

      // 顶部促销标签
      topTags: [
        _buildTag('限时特惠', Colors.red, Colors.white),
        _buildTag('热销', Colors.orange, Colors.white),
      ],

      // 角标
      cornerBadgeText: '限时特价 包邮',

      // 促销标签
      promoTags: [
        _buildTag('每满1000减100', Colors.red[50]!, Colors.red),
        _buildTag('12期免息', Colors.green[50]!, Colors.green),
      ],

      // 评价/销量
      reviewCount: '10000+条评论',
      salesCount: '已售100万+',

      // 自定义行动按钮
      customActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '加入购物车',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '立即抢购',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),

      onActionTap: () {
        debugPrint('点击立即抢购');
      },
      onTap: () {
        debugPrint('跳转详情');
      },
    );
  }

  /// 新人专享示例
  Widget _buildNewUserExample() {
    return UniversalProductCard(
      image: const NetworkImage(
        'https://picsum.photos/seed/headphone/200/200',
      ),
      title: 'Sony WH-1000XM5 头戴式无线降噪耳机 黑色',
      price: 2499.00,
      originalPrice: 2899.00,

      // 新人价
      newUserPrice: 1999.00,
      newUserLabel: '新人专享',

      // 顶部标签
      topTags: [
        _buildTag('新人专享', Colors.purple, Colors.white, Icons.card_giftcard),
      ],

      // 服务标签
      serviceTags: [
        _buildTag('包邮', Colors.green[50]!, Colors.green),
        _buildTag('7天无理由', Colors.blue[50]!, Colors.blue),
      ],

      // 评价/销量
      reviewCount: '500+条评论',
      salesCount: '已售5万+',

      actionButtonText: '立即抢购',
      onActionTap: () {
        debugPrint('新人立即抢购');
      },
      onTap: () {
        debugPrint('跳转详情');
      },
    );
  }

  /// 服务标签示例
  Widget _buildServiceExample() {
    return UniversalProductCard(
      image: const NetworkImage(
        'https://picsum.photos/seed/camera/200/200',
      ),
      title: 'Canon EOS R6 Mark II 全画幅微单相机',
      price: 16999.00,

      // 顶部标签
      topTags: [
        _buildTag('企业购', Colors.blue, Colors.white),
      ],

      // 左上角徽章
      topLeftBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '新品',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),

      // 右上角徽章（视频标识）
      topRightBadge: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 14,
        ),
      ),

      // 服务标签
      serviceTags: [
        _buildTag('先用后付', Colors.green[50]!, Colors.green),
        _buildTag('闪电退款', Colors.blue[50]!, Colors.blue),
        _buildTag('全国联保', Colors.orange[50]!, Colors.orange),
      ],

      // 评价/销量
      reviewCount: '100+条评论',
      salesCount: '已售1万+',

      actionButtonText: '咨询客服',
      actionButtonColor: Colors.blue,
      onActionTap: () {
        debugPrint('咨询客服');
      },
      onTap: () {
        debugPrint('跳转详情');
      },
    );
  }

  /// 构建标签辅助方法
  Widget _buildTag(
    String text,
    Color bgColor,
    Color textColor, [
    IconData? icon,
  ]) {
    return ProductCardTag(
      text: text,
      bgColor: bgColor,
      textColor: textColor,
      icon: icon,
    );
  }
}
