library;

import 'package:flutter/widgets.dart';

/// List<Widget> 扩展方法
extension ListWidgetsExtensions on List<Widget> {
  /// 转为 Column
  Widget toColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) =>
      Column(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: this,
      );

  /// 转为 Row
  Widget toRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) =>
      Row(
        key: key,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: this,
      );

  /// 转为 Stack
  Widget toStack({
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
  }) =>
      Stack(
        key: key,
        alignment: alignment,
        fit: fit,
        children: this,
      );

  /// 转为 ListView（垂直）
  Widget toListView({
    Key? key,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) =>
      ListView(
        key: key,
        controller: controller,
        shrinkWrap: shrinkWrap,
        children: this,
      );

  /// 转为水平 ListView
  Widget toHorizontalListView({
    Key? key,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) =>
      ListView(
        key: key,
        controller: controller,
        shrinkWrap: shrinkWrap,
        scrollDirection: Axis.horizontal,
        children: this,
      );
}
