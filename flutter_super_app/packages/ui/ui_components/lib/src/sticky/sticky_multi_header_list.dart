library;

import 'package:flutter/material.dart';

/// 吸顶分区数据模型
class StickySectionModel {
  /// 分区唯一标识（如 "A"/"B"/"数码"/"家居"）
  final String key;

  /// 分区标题（吸顶显示的文字）
  final String title;

  /// 分区内 item 数量
  final int itemCount;

  const StickySectionModel({
    required this.key,
    required this.title,
    required this.itemCount,
  });
}

/// 多标签顺序吸顶列表组件
///
/// 适用于：联系人列表、商品分类、多话题内容等场景
class StickyMultiHeaderList extends StatelessWidget {
  /// 吸顶标签数据（每个标签对应一个分区）
  final List<StickySectionModel> sections;

  /// 标签吸顶高度
  final double headerHeight;

  /// 标签背景色
  final Color headerBackgroundColor;

  /// 标签文字样式
  final TextStyle headerTextStyle;

  /// 列表项构建器（业务侧自定义每个 item 的样式）
  final Widget Function(BuildContext context, String sectionKey, int index)
      itemBuilder;

  const StickyMultiHeaderList({
    super.key,
    required this.sections,
    required this.itemBuilder,
    this.headerHeight = 40,
    this.headerBackgroundColor = Colors.grey,
    this.headerTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    // 构建所有分区的 Sliver 组件
    List<Widget> buildSlivers() {
      final List<Widget> slivers = [];

      for (final section in sections) {
        // 1. 当前分区的吸顶标签
        slivers.add(
          SliverPersistentHeader(
            pinned: true,
            delegate: _MultiStickyDelegate(
              height: headerHeight,
              backgroundColor: headerBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  section.title,
                  style: headerTextStyle,
                ),
              ),
            ),
          ),
        );

        // 2. 当前分区的列表内容
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(context, section.key, index),
              childCount: section.itemCount,
            ),
          ),
        );
      }

      return slivers;
    }

    return CustomScrollView(
      slivers: buildSlivers(),
    );
  }
}

/// 多分区吸顶代理类
class _MultiStickyDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color backgroundColor;
  final Widget child;

  _MultiStickyDelegate({
    required this.height,
    required this.backgroundColor,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_MultiStickyDelegate oldDelegate) {
    return height != oldDelegate.height ||
        backgroundColor != oldDelegate.backgroundColor ||
        child != oldDelegate.child;
  }
}
