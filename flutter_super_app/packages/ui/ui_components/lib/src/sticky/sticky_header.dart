library;

import 'package:flutter/material.dart';

/// 基础吸顶代理类
class BasicStickyDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color backgroundColor;
  final Widget child;

  BasicStickyDelegate({
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
      color: backgroundColor,
      height: height,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(BasicStickyDelegate oldDelegate) {
    return height != oldDelegate.height ||
        backgroundColor != oldDelegate.backgroundColor ||
        child != oldDelegate.child;
  }
}

/// 基础吸顶导航栏组件（固定高度，无渐变）
class StickyBasicHeader extends StatelessWidget {
  /// 吸顶标题/内容
  final Widget headerChild;

  /// 吸顶区域高度（默认 50）
  final double headerHeight;

  /// 吸顶区域背景色
  final Color backgroundColor;

  /// 吸顶下方的列表内容（必须是 Sliver 组件）
  final List<Widget> sliverChildren;

  const StickyBasicHeader({
    super.key,
    required this.headerChild,
    required this.sliverChildren,
    this.headerHeight = 50,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 核心：固定吸顶的 Header
        SliverPersistentHeader(
          pinned: true,
          delegate: BasicStickyDelegate(
            height: headerHeight,
            backgroundColor: backgroundColor,
            child: headerChild,
          ),
        ),
        // 业务侧传入的列表内容（SliverList/SliverGrid 等）
        ...sliverChildren,
      ],
    );
  }
}
