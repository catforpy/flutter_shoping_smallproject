library;

import 'dart:ui';
import 'package:flutter/material.dart';

/// 毛玻璃容器组件
///
/// 通用的毛玻璃效果容器，支持可配置的模糊度、透明度、叠加颜色
///
/// ## 功能特性
/// - 背景模糊效果（ImageFilter.blur）
/// - 可配置的模糊度 X 和 Y
/// - 可配置的透明度和叠加颜色
/// - 支持圆角
/// - 支持内边距
/// - 可选的边框
///
/// ## 示例用法
/// ### 基础用法
/// ```dart
/// FrostedGlassContainer(
///   child: Text('毛玻璃效果'),
/// )
/// ```
///
/// ### 自定义模糊度
/// ```dart
/// FrostedGlassContainer(
///   sigmaX: 10,
///   sigmaY: 10,
///   opacity: 0.8,
///   child: Text('更强的模糊效果'),
/// )
/// ```
///
/// ### 带圆角和叠加颜色
/// ```dart
/// FrostedGlassContainer(
///   borderRadius: BorderRadius.circular(16),
///   overlayColor: Colors.black.withValues(alpha: 0.3),
///   child: Text('圆角毛玻璃'),
/// )
/// ```
///
/// ### 用于导航栏
/// ```dart
/// FrostedGlassContainer(
///   sigmaX: 10,
///   sigmaY: 10,
///   opacity: 0.1,
///   child: AppBar(
///     title: Text('标题'),
///     backgroundColor: Colors.transparent,
///     elevation: 0,
///   ),
/// )
/// ```
class FrostedGlassContainer extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 模糊度 X（水平方向）
  ///
  /// 默认值：5.0
  /// 值越大，模糊效果越强
  final double sigmaX;

  /// 模糊度 Y（垂直方向）
  ///
  /// 默认值：5.0
  /// 值越大，模糊效果越强
  final double sigmaY;

  /// 容器透明度
  ///
  /// 默认值：0.5（半透明）
  /// 范围：0.0（完全透明）- 1.0（完全不透明）
  final double opacity;

  /// 叠加颜色（可选）
  ///
  /// 用于在毛玻璃效果上叠加一层颜色
  /// 例如：Colors.black.withValues(alpha: 0.3) 会叠加黑色半透明层
  final Color? overlayColor;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 背景颜色（可选，在毛玻璃效果下方）
  ///
  /// 如果不指定，则完全透明
  final Color? backgroundColor;

  /// 边框（可选）
  final BoxBorder? border;

  /// 是否使用 ClipRect 裁剪
  ///
  /// 默认值：true
  /// 设置为 false 可以避免 BackdropFilter 溢出裁剪，但在某些情况下可能导致模糊效果超出边界
  final bool clip;

  const FrostedGlassContainer({
    super.key,
    required this.child,
    this.sigmaX = 5.0,
    this.sigmaY = 5.0,
    this.opacity = 0.5,
    this.overlayColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
    this.clip = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            decoration: BoxDecoration(
              color: (overlayColor ?? Colors.white).withValues(alpha: opacity),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (clip) {
      return ClipRect(child: container);
    }
    return container;
  }
}

/// 创建毛玻璃滤镜
///
/// 便捷函数，用于创建标准的毛玻璃 ImageFilter
///
/// ## 参数
/// - [sigmaX]: 水平模糊度，默认 10
/// - [sigmaY]: 垂直模糊度，默认 10
///
/// ## 返回
/// 返回一个 ImageFilter 对象，可直接用于 BackdropFilter
///
/// ## 示例
/// ```dart
/// BackdropFilter(
///   filter: createFrostedGlassFilter(sigmaX: 10, sigmaY: 10),
///   child: Container(...),
/// )
/// ```
ImageFilter createFrostedGlassFilter({double sigmaX = 10, double sigmaY = 10}) {
  return ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY);
}

/// 毛玻璃预设配置
///
/// 提供常用的毛玻璃效果预设
class FrostedGlassPreset {
  /// 轻度毛玻璃（导航栏常用）
  static const double lightSigma = 5.0;
  static const double lightOpacity = 0.1;

  /// 中度毛玻璃（标签栏常用）
  static const double mediumSigma = 10.0;
  static const double mediumOpacity = 0.5;

  /// 重度毛玻璃（模态框常用）
  static const double heavySigma = 15.0;
  static const double heavyOpacity = 0.8;

  /// 轻度毛玻璃滤镜
  static ImageFilter lightFilter() {
    return createFrostedGlassFilter(
      sigmaX: lightSigma,
      sigmaY: lightSigma,
    );
  }

  /// 中度毛玻璃滤镜
  static ImageFilter mediumFilter() {
    return createFrostedGlassFilter(
      sigmaX: mediumSigma,
      sigmaY: mediumSigma,
    );
  }

  /// 重度毛玻璃滤镜
  static ImageFilter heavyFilter() {
    return createFrostedGlassFilter(
      sigmaX: heavySigma,
      sigmaY: heavySigma,
    );
  }
}
