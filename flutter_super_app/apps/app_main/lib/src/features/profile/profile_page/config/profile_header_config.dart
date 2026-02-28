library;

import 'package:flutter/material.dart';

/// 用户信息配置
///
/// 采用不可变设计，支持链式调用
class ProfileHeaderConfig {
  /// 头像
  final Widget avatar;

  /// 用户名称
  final String name;

  /// 用户简介/副标题
  final String? subtitle;

  /// 背景颜色
  final Color? backgroundColor;

  /// 头部高度
  final double? height;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 名称文字样式
  final TextStyle? nameStyle;

  /// 副标题文字样式
  final TextStyle? subtitleStyle;

  /// 头像大小
  final double avatarSize;

  /// 头像形状
  final BoxShape avatarShape;

  /// 点击回调
  final VoidCallback? onTap;

  const ProfileHeaderConfig({
    required this.avatar,
    required this.name,
    this.subtitle,
    this.backgroundColor,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.nameStyle,
    this.subtitleStyle,
    this.avatarSize = 80,
    this.avatarShape = BoxShape.circle,
    this.onTap,
  });

  /// 链式调用：创建副本并修改部分属性
  ProfileHeaderConfig copyWith({
    Widget? avatar,
    String? name,
    String? subtitle,
    Color? backgroundColor,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? nameStyle,
    TextStyle? subtitleStyle,
    double? avatarSize,
    BoxShape? avatarShape,
    VoidCallback? onTap,
  }) {
    return ProfileHeaderConfig(
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      nameStyle: nameStyle ?? this.nameStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      avatarSize: avatarSize ?? this.avatarSize,
      avatarShape: avatarShape ?? this.avatarShape,
      onTap: onTap ?? this.onTap,
    );
  }

  /// 函数式：设置背景颜色
  ProfileHeaderConfig withBackgroundColor(Color color) {
    return copyWith(backgroundColor: color);
  }

  /// 函数式：设置高度
  ProfileHeaderConfig withHeight(double height) {
    return copyWith(height: height);
  }

  /// 函数式：设置内边距
  ProfileHeaderConfig withPadding(EdgeInsetsGeometry padding) {
    return copyWith(padding: padding);
  }

  /// 函数式：设置头像大小
  ProfileHeaderConfig withAvatarSize(double size) {
    return copyWith(avatarSize: size);
  }

  /// 函数式：设置点击事件
  ProfileHeaderConfig withOnTap(VoidCallback onTap) {
    return copyWith(onTap: onTap);
  }

  /// 函数式：设置文字样式
  ProfileHeaderConfig withNameStyle(TextStyle style) {
    return copyWith(nameStyle: style);
  }

  /// 函数式：设置副标题样式
  ProfileHeaderConfig withSubtitleStyle(TextStyle style) {
    return copyWith(subtitleStyle: style);
  }
}
