import 'package:flutter/material.dart';

/// Widget 扩展
extension WidgetExtension on Widget {
  /// 添加内边距
  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  /// 添加外边距
  Widget margin(EdgeInsetsGeometry margin) {
    return Container(
      margin: margin,
      child: this,
    );
  }

  /// 添加圆角
  Widget borderRadius(BorderRadius borderRadius) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: this,
    );
  }

  /// 添加背景
  Widget background(Color color) {
    return ColoredBox(
      color: color,
      child: this,
    );
  }

  /// 添加圆角裁剪
  Widget clipRadius(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  /// 添加圆形裁剪
  Widget clipCircle() {
    return ClipOval(
      child: this,
    );
  }

  /// 添加透明度
  Widget opacity(double opacity) {
    return Opacity(
      opacity: opacity,
      child: this,
    );
  }

  /// 添加旋转
  Widget rotate(double angle) {
    return Transform.rotate(
      angle: angle,
      child: this,
    );
  }

  /// 添加缩放
  Widget scale(double scale) {
    return Transform.scale(
      scale: scale,
      child: this,
    );
  }

  /// 添加平移
  Widget translate(Offset offset) {
    return Transform.translate(
      offset: offset,
      child: this,
    );
  }

  /// 添加可见性控制
  Widget visible(bool visible, {Widget? placeholder}) {
    return Visibility(
      visible: visible,
      maintainSize: placeholder != null,
      maintainAnimation: placeholder != null,
      maintainState: placeholder != null,
      replacement: placeholder ?? const SizedBox.shrink(),
      child: this,
    );
  }

  /// 添加手势检测
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  /// 添加长按手势
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: this,
    );
  }

  /// 添加安全区域
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }

  /// 添加扩展
  Widget expand([int flex = 1]) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  /// 添加居中
  Widget center() {
    return Center(
      child: this,
    );
  }

  /// 添加对齐
  Widget align(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: this,
    );
  }

  /// 添加宽高
  Widget size(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }

  /// 添加宽度
  Widget width(double width) {
    return SizedBox(
      width: width,
      child: this,
    );
  }

  /// 添加高度
  Widget height(double height) {
    return SizedBox(
      height: height,
      child: this,
    );
  }

  /// 添加装饰
  Widget decorate(BoxDecoration decoration) {
    return Container(
      decoration: decoration,
      child: this,
    );
  }

  /// 添加阴影
  Widget shadow({
    Color color = Colors.black,
    double blurRadius = 10,
    Offset offset = const Offset(0, 2),
    double spreadRadius = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            offset: offset,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: this,
    );
  }

  /// 添加约束
  Widget constrain(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: constraints,
      child: this,
    );
  }

  /// 添加滚动视图
  Widget scroll({
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      physics: physics,
      child: this,
    );
  }

  /// 添加英雄动画
  Widget hero(Object tag) {
    return Hero(
      tag: tag,
      child: this,
    );
  }

  /// 添加动画
  Widget animated({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedOpacity(
      opacity: 1,
      duration: duration,
      curve: curve,
      child: AnimatedSize(
        duration: duration,
        curve: curve,
        child: this,
      ),
    );
  }
}

/// BuildContext 扩展
extension ContextExtension on BuildContext {
  /// 获取主题
  ThemeData get theme => Theme.of(this);

  /// 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 获取颜色方案
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 获取屏幕大小
  Size get screenSize => MediaQuery.of(this).size;

  /// 获取屏幕宽度
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 获取屏幕高度
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 获取设备像素比
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// 获取 padding
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// 获取视图内边距
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// 获取视图填充
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  /// 是否为暗色模式
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// 获取焦点
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// 隐藏键盘
  void hideKeyboard() {
    focusScope.unfocus();
  }

  /// 显示 SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 2),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
      ),
    );
  }

  /// 显示底部 Sheet
  Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
    );
  }

  /// 显示对话框
  Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }

  /// 推送到新页面
  Future<T?> push<T>(Route<T> route) {
    return Navigator.of(this).push(route);
  }

  /// 替换当前页面
  Future<T?> pushReplacement<T>(Route<T> route) {
    return Navigator.of(this).pushReplacement(route);
  }

  /// 返回上一页
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}

/// Color 扩展
extension ColorExtension on Color {
  /// 获取较暗的颜色
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// 获取较亮的颜色
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// 获取透明度变化的颜色
  Color withOpacity(double opacity) {
    return withAlpha((255 * opacity).round());
  }
}

/// TimeOfDay 扩展
extension TimeOfDayExtension on TimeOfDay {
  /// 转换为 DateTime
  DateTime toDateTime([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 转换为分钟数
  int toMinutes() {
    return hour * 60 + minute;
  }

  /// 从分钟数创建
  static TimeOfDay fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  /// 判断是否在另一个时间之前
  bool isBefore(TimeOfDay other) {
    return toMinutes() < other.toMinutes();
  }

  /// 判断是否在另一个时间之后
  bool isAfter(TimeOfDay other) {
    return toMinutes() > other.toMinutes();
  }
}
