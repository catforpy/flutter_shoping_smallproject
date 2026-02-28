library;

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 瀑布流布局模版
class WaterfallLayout extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets padding;
  final ScrollController? controller;

  const WaterfallLayout({
    super.key,
    required this.children,
    this.columns = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding = const EdgeInsets.all(8),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: MasonryGridView.count(
        crossAxisCount: columns,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        controller: controller,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
