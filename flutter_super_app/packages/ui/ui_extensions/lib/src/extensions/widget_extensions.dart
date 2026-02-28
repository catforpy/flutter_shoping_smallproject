library;

import 'package:flutter/material.dart';

/// Widget 扩展方法 - 链式调用简化布局代码
extension WidgetExtensions on Widget {
  /// 用外部 Widget 包裹当前 Widget
  Widget parent(Widget Function({required Widget child}) outer) =>
      outer(child: this);

  /// 添加内边距
  Widget padding({
    Key? key,
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) =>
      Padding(
        key: key,
        padding: EdgeInsets.only(
          top: top ?? vertical ?? all ?? 0.0,
          bottom: bottom ?? vertical ?? all ?? 0.0,
          left: left ?? horizontal ?? all ?? 0.0,
          right: right ?? horizontal ?? all ?? 0.0,
        ),
        child: this,
      );

  /// 设置透明度
  Widget opacity(double opacity, {Key? key}) => Opacity(
        key: key,
        opacity: opacity,
        child: this,
      );

  /// 设置对齐方式
  Widget alignment(AlignmentGeometry alignment, {Key? key}) => Align(
        key: key,
        alignment: alignment,
        child: this,
      );

  /// 设置背景色
  Widget backgroundColor(Color color, {Key? key}) => DecoratedBox(
        key: key,
        decoration: BoxDecoration(color: color),
        child: this,
      );

  /// 设置圆角
  Widget borderRadius({
    Key? key,
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft ?? all ?? 0.0),
        topRight: Radius.circular(topRight ?? all ?? 0.0),
        bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
        bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
      ),
      child: this,
    );
  }

  /// 设置边框
  Widget border({
    Key? key,
    double? all,
    double? left,
    double? right,
    double? top,
    double? bottom,
    Color color = const Color(0xFF000000),
  }) {
    return DecoratedBox(
      key: key,
      decoration: BoxDecoration(
        border: Border(
          left: (left ?? all) == null
              ? BorderSide.none
              : BorderSide(color: color, width: left ?? all ?? 0),
          right: (right ?? all) == null
              ? BorderSide.none
              : BorderSide(color: color, width: right ?? all ?? 0),
          top: (top ?? all) == null
              ? BorderSide.none
              : BorderSide(color: color, width: top ?? all ?? 0),
          bottom: (bottom ?? all) == null
              ? BorderSide.none
              : BorderSide(color: color, width: bottom ?? all ?? 0),
        ),
      ),
      child: this,
    );
  }

  /// 添加阴影
  Widget boxShadow({
    Key? key,
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
  }) {
    return DecoratedBox(
      key: key,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// 设置固定宽度
  Widget width(double width, {Key? key}) => ConstrainedBox(
        key: key,
        constraints: BoxConstraints.tightFor(width: width),
        child: this,
      );

  /// 设置固定高度
  Widget height(double height, {Key? key}) => ConstrainedBox(
        key: key,
        constraints: BoxConstraints.tightFor(height: height),
        child: this,
      );

  /// 设置宽高
  Widget size(double width, double height, {Key? key}) => ConstrainedBox(
        key: key,
        constraints: BoxConstraints.tightFor(width: width, height: height),
        child: this,
      );

  /// 使 Widget 可滚动
  Widget scrollable({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
  }) =>
      SingleChildScrollView(
        key: key,
        scrollDirection: scrollDirection,
        controller: controller,
        child: this,
      );

  /// 在 Flex 布局中占满剩余空间
  Widget expanded({Key? key, int flex = 1}) => Expanded(
        key: key,
        flex: flex,
        child: this,
      );

  /// 居中
  Widget center({Key? key}) => Center(
        key: key,
        child: this,
      );

  /// 添加卡片样式
  Widget card({
    Key? key,
    Color? color,
    double? elevation,
    EdgeInsetsGeometry? margin,
  }) =>
      Card(
        key: key,
        color: color,
        elevation: elevation,
        margin: margin,
        child: this,
      );

  /// 裁剪为圆角矩形
  Widget clipRRect({
    Key? key,
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    Clip clipBehavior = Clip.antiAlias,
  }) =>
      ClipRRect(
        key: key,
        clipBehavior: clipBehavior,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeft ?? all ?? 0.0),
          topRight: Radius.circular(topRight ?? all ?? 0.0),
          bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
          bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
        ),
        child: this,
      );

  /// 避开系统UI
  Widget safeArea({
    Key? key,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) =>
      SafeArea(
        key: key,
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: this,
      );

  /// 在 Stack 中定位
  Widget positioned({
    Key? key,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) =>
      Positioned(
        key: key,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: width,
        height: height,
        child: this,
      );

  /// 设置宽高比
  Widget aspectRatio(double aspectRatio, {Key? key}) => AspectRatio(
        key: key,
        aspectRatio: aspectRatio,
        child: this,
      );

  /// 给Widget设置背景图片
  Widget backgroundImage(DecorationImage image, {Key? key}) => DecoratedBox(
        key: key,
        decoration: BoxDecoration(image: image),
        child: this,
      );

  /// 给Widget设置综合装饰（背景、边框、阴影、圆角、渐变等）
  Widget decorated({
    Key? key,
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape shape = BoxShape.rectangle,
    DecorationPosition position = DecorationPosition.background,
  }) {
    BoxDecoration decoration = BoxDecoration(
      color: color,
      image: image,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      backgroundBlendMode: backgroundBlendMode,
      shape: shape,
    );
    return DecoratedBox(
      key: key,
      decoration: decoration,
      position: position,
      child: this,
    );
  }

  /// 限制Widget的大小约束
  Widget constrained({
    Key? key,
    double? width,
    double? height,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) {
    BoxConstraints constraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
    constraints = (width != null || height != null)
        ? constraints.tighten(width: width, height: height)
        : constraints;
    return ConstrainedBox(
      key: key,
      constraints: constraints,
      child: this,
    );
  }

  /// 给Widget添加水波纹点击效果（自动关联父级GestureDetector）
  Widget ripple({
    Key? key,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    InteractiveInkFeatureFactory? splashFactory,
    double? radius,
    ShapeBorder? customBorder,
    bool enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    bool autoFocus = false,
    bool enable = true,
  }) =>
      enable
          ? Builder(
              key: key,
              builder: (BuildContext context) {
                GestureDetector? gestures =
                    context.findAncestorWidgetOfExactType<GestureDetector>();
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: focusColor,
                    hoverColor: hoverColor,
                    highlightColor: highlightColor,
                    splashColor: splashColor,
                    splashFactory: splashFactory,
                    radius: radius,
                    customBorder: customBorder,
                    enableFeedback: enableFeedback,
                    excludeFromSemantics: excludeFromSemantics,
                    focusNode: focusNode,
                    canRequestFocus: canRequestFocus,
                    autofocus: autoFocus,
                    onTap: gestures?.onTap,
                    child: this,
                  ),
                );
              },
            )
          : Builder(
              key: key,
              builder: (context) => this,
            );

  /// 旋转Widget
  Widget rotate({
    Key? key,
    required double angle,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
  }) =>
      Transform.rotate(
        key: key,
        angle: angle,
        alignment: alignment,
        origin: origin,
        transformHitTests: transformHitTests,
        child: this,
      );

  /// 缩放Widget
  Widget scale({
    Key? key,
    double? all,
    double? x,
    double? y,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
  }) =>
      Transform.scale(
        key: key,
        scaleX: x ?? all ?? 1.0,
        scaleY: y ?? all ?? 1.0,
        alignment: alignment,
        origin: origin,
        transformHitTests: transformHitTests,
        child: this,
      );

  /// 平移Widget
  Widget translate({
    Key? key,
    required Offset offset,
    bool transformHitTests = true,
  }) =>
      Transform.translate(
        key: key,
        offset: offset,
        transformHitTests: transformHitTests,
        child: this,
      );

  /// 自定义矩阵变换Widget
  Widget transform({
    Key? key,
    required Matrix4 transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
  }) =>
      Transform(
        key: key,
        transform: transform,
        alignment: alignment,
        origin: origin,
        transformHitTests: transformHitTests,
        child: this,
      );

  /// 在Flex布局中可伸缩（不强制占满空间）
  Widget flexible({
    Key? key,
    int flex = 1,
    FlexFit fit = FlexFit.loose,
  }) =>
      Flexible(
        key: key,
        flex: flex,
        fit: fit,
        child: this,
      );

  /// 添加完整的手势识别
  Widget gestures({
    Key? key,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapCancelCallback? onTapCancel,
    GestureTapUpCallback? onTapUp,
    GestureLongPressStartCallback? onLongPressStart,
    GestureLongPressEndCallback? onLongPressEnd,
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
  }) =>
      GestureDetector(
        key: key,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        onLongPressStart: onLongPressStart,
        onLongPressEnd: onLongPressEnd,
        onHorizontalDragStart: onHorizontalDragStart,
        onHorizontalDragUpdate: onHorizontalDragUpdate,
        onHorizontalDragEnd: onHorizontalDragEnd,
        onVerticalDragStart: onVerticalDragStart,
        onVerticalDragUpdate: onVerticalDragUpdate,
        onVerticalDragEnd: onVerticalDragEnd,
        behavior: behavior,
        excludeFromSemantics: excludeFromSemantics,
        child: this,
      );

  /// 给Widget添加InkWell效果（水波纹+手势）
  Widget inkWell({
    Key? key,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapCancelCallback? onTapCancel,
    GestureTapUpCallback? onTapUp,
    ValueChanged<bool>? onHighlightChanged,
    ValueChanged<bool>? onHover,
    MouseCursor? mouseCursor,
  }) =>
      InkWell(
        key: key,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        onHighlightChanged: onHighlightChanged,
        onHover: onHover,
        mouseCursor: mouseCursor,
        child: this,
      );

  /// 裁剪为矩形
  Widget clipRect({Key? key, Clip clipBehavior = Clip.hardEdge}) => ClipRect(
        key: key,
        clipBehavior: clipBehavior,
        child: this,
      );

  /// 裁剪为椭圆
  Widget clipOval({Key? key}) => ClipOval(
        key: key,
        child: this,
      );
}
