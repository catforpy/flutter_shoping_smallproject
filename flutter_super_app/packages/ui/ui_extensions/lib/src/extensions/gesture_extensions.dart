library;

import 'package:flutter/material.dart';

/// 手势扩展方法
extension GestureExtensions on Widget {
  /// 添加点击手势
  Widget onTap(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: this,
      );

  /// 添加双击手势
  Widget onDoubleTap(VoidCallback onDoubleTap) => GestureDetector(
        onDoubleTap: onDoubleTap,
        child: this,
      );

  /// 添加长按手势
  Widget onLongPress(VoidCallback onLongPress) => GestureDetector(
        onLongPress: onLongPress,
        child: this,
      );

  /// 添加水平拖动手势
  Widget onHorizontalDragUpdate(
    GestureDragUpdateCallback onHorizontalDragUpdate,
  ) => GestureDetector(
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        child: this,
      );

  /// 添加垂直拖动手势
  Widget onVerticalDragUpdate(GestureDragUpdateCallback onVerticalDragUpdate) =>
      GestureDetector(
        onVerticalDragUpdate: onVerticalDragUpdate,
        child: this,
      );

  /// 添加水波纹效果
  Widget ripple({
    Key? key,
    Color? splashColor,
    VoidCallback? onTap,
  }) =>
      InkWell(
        key: key,
        splashColor: splashColor,
        onTap: onTap,
        child: this,
      );
}
