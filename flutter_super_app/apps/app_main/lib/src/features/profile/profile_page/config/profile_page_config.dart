library;

import 'package:flutter/material.dart';
import 'profile_header_config.dart';

/// 个人中心页面配置
///
/// 采用不可变设计，支持链式调用
class ProfilePageConfig {
  /// 头部配置
  final ProfileHeaderConfig headerConfig;

  /// 页面背景颜色
  final Color? backgroundColor;

  /// 是否显示顶部安全区域
  final bool showTopSafeArea;

  /// 页面内边距
  final EdgeInsetsGeometry padding;

  /// 滚动行为
  final ScrollBehavior? scrollBehavior;

  ProfilePageConfig({
    ProfileHeaderConfig? headerConfig,
    this.backgroundColor,
    this.showTopSafeArea = true,
    this.padding = EdgeInsets.zero,
    this.scrollBehavior,
  }) : headerConfig = headerConfig ?? _defaultHeaderConfig();

  /// 默认头部配置
  static ProfileHeaderConfig _defaultHeaderConfig() {
    return ProfileHeaderConfig(
      avatar: Icon(Icons.person, size: 80),
      name: '未登录',
      subtitle: '点击登录',
      avatarSize: 80,
    );
  }

  /// 链式调用：创建副本并修改部分属性
  ProfilePageConfig copyWith({
    ProfileHeaderConfig? headerConfig,
    Color? backgroundColor,
    bool? showTopSafeArea,
    EdgeInsetsGeometry? padding,
    ScrollBehavior? scrollBehavior,
  }) {
    return ProfilePageConfig(
      headerConfig: headerConfig ?? this.headerConfig,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showTopSafeArea: showTopSafeArea ?? this.showTopSafeArea,
      padding: padding ?? this.padding,
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
    );
  }

  /// 函数式：设置头部配置
  ProfilePageConfig withHeader(ProfileHeaderConfig headerConfig) {
    return copyWith(headerConfig: headerConfig);
  }

  /// 函数式：设置背景颜色
  ProfilePageConfig withBackgroundColor(Color color) {
    return copyWith(backgroundColor: color);
  }

  /// 函数式：设置页面内边距
  ProfilePageConfig withPagePadding(EdgeInsetsGeometry padding) {
    return copyWith(padding: padding);
  }

  /// 函数式：设置顶部安全区域
  ProfilePageConfig withTopSafeArea(bool show) {
    return copyWith(showTopSafeArea: show);
  }
}
