library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../widgets/mixed_media_carousel.dart';
import '../../course/course_detail_page.dart';

/// 推荐标签页
///
/// 特性：
/// - 顶部显示混合媒体轮播图（视频+图片）
/// - 下方显示商品卡片列表
class RecommendTab extends StatefulWidget {
  const RecommendTab({super.key});

  @override
  State<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<RecommendTab> {
  /// 商品列表数据
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'course_flutter_complete_guide',
      'imageUrl': 'https://picsum.photos/200/200?random=101',
      'title': 'Flutter 完整开发指南',
      'subtitle': '从入门到精通',
      'tagType': ProductTagType.vip,
      'tagText': 'VIP专享',
      'price': 19900,
      'originalPrice': 29900,
      'studyCount': 12345,
      // 图片左上角标签
      'imageBadgeType': ProductImageBadgeType.upgrade,
      'imageBadgeText': '升级',
      // 底部剩余时间
      'remainingText': '剩余：3天',
    },
    {
      'id': 'course_dart_async',
      'imageUrl': 'https://picsum.photos/200/200?random=102',
      'title': 'Dart 异步编程实战',
      'subtitle': '深入理解 Isolate 和 Future',
      'tagType': ProductTagType.discount,
      'tagText': '上新优惠',
      'price': 9900,
      'originalPrice': 19900,
      'studyCount': 5678,
      // 图片左上角标签
      'imageBadgeType': ProductImageBadgeType.new_,
      'imageBadgeText': '新课',
      // 底部剩余时间
      'remainingText': '剩余：7天',
    },
    {
      'id': 'course_flutter_state_management',
      'imageUrl': 'https://picsum.photos/200/200?random=103',
      'title': 'Flutter 状态管理精讲',
      'subtitle': 'Provider、Riverpod、Bloc 全解析',
      'tagType': ProductTagType.new_,
      'tagText': '新品',
      'price': 14900,
      'originalPrice': null,
      'studyCount': 2345,
      // 图片左上角标签
      'imageBadgeType': ProductImageBadgeType.hot,
      'imageBadgeText': '热门',
      // 底部剩余时间
      'remainingText': '剩余：5天',
    },
    {
      'id': 'course_flutter_performance_home',
      'imageUrl': 'https://picsum.photos/200/200?random=104',
      'title': 'Flutter 性能优化实战',
      'subtitle': '让你的应用丝滑流畅',
      'tagType': ProductTagType.hot,
      'tagText': '热销',
      'price': 17900,
      'originalPrice': 24900,
      'studyCount': 8901,
      // 图片左上角标签
      'imageBadgeType': ProductImageBadgeType.limited,
      'imageBadgeText': '限时',
      // 底部剩余时间
      'remainingText': '剩余：1天',
    },
    {
      'id': 'course_flutter_animation',
      'imageUrl': 'https://picsum.photos/200/200?random=105',
      'title': 'Flutter 动画开发大师课',
      'subtitle': '从基础到高级动画',
      'tagType': ProductTagType.limited,
      'tagText': '限时优惠',
      'price': 12900,
      'originalPrice': 18900,
      'studyCount': 4567,
      // 图片左上角标签
      'imageBadgeType': ProductImageBadgeType.recommend,
      'imageBadgeText': '推荐',
      // 底部剩余时间
      'remainingText': '剩余：2天',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 混合媒体轮播图
          _buildMediaCarousel(),
          const SizedBox(height: 16),
          // 商品列表标题
          _buildSectionTitle('精选课程'),
          const SizedBox(height: 12),
          // 商品卡片列表
          _buildProductList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 构建混合媒体轮播图
  Widget _buildMediaCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MixedMediaCarousel(
        videoUrl: 'https://fuyin15190311094.oss-cn-beijing.aliyuncs.com/%5B2.7%5D--2-7Dart%E7%9A%84%E7%BA%BF%E7%A8%8B%E7%AE%A1%E7%90%86%E5%8F%8A%E6%A1%86%E6%9E%B6%20.mp4',
        imageUrls: [
          'https://picsum.photos/800/400?random=1',
          'https://picsum.photos/800/400?random=2',
          'https://picsum.photos/800/400?random=3',
        ],
        height: 200,
        borderRadius: BorderRadius.circular(12),
        showMuteButton: true,
      ),
    );
  }

  /// 构建分节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建商品列表
  Widget _buildProductList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _products
            .map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProductCard(product),
                ))
            .toList(),
      ),
    );
  }

  /// 构建商品卡片
  Widget _buildProductCard(Map<String, dynamic> product) {
    return ProductCard(
      imageUrl: product['imageUrl'] as String,
      title: product['title'] as String,
      subtitle: product['subtitle'] as String,
      tag: ProductTag(
        type: product['tagType'] as ProductTagType,
        text: product['tagText'] as String,
      ),
      price: product['price'] as int,
      originalPrice: product['originalPrice'] as int?,
      studyCount: product['studyCount'] as int?,
      // 图片左上角标签
      imageBadgeType: product['imageBadgeType'] as ProductImageBadgeType?,
      imageBadgeText: product['imageBadgeText'] as String?,
      // 底部剩余时间
      remainingText: product['remainingText'] as String?,
      onTap: () {
        // 跳转到课程详情页（从右边滑入动画）
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => CourseDetailPage(
              courseId: product['id'] as String,
              imageUrl: product['imageUrl'] as String,
              title: product['title'] as String,
              subtitle: product['subtitle'] as String?,
            ),
          ),
        );
      },
    );
  }
}
