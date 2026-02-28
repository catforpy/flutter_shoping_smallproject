library;

import 'dart:ui';
import 'package:flutter/material.dart';

/// 带背景图的透明导航栏
///
/// 专为课程详情页设计的透明导航栏组件，支持：
/// - 背景图从顶部平铺
/// - 毛玻璃效果叠加
/// - 标题淡入淡出（基于滚动进度）
/// - 自定义返回/分享按钮
///
/// ## 功能特性
/// - 背景图从手机顶部开始平铺，延伸到页面内容区域
/// - 毛玻璃效果叠加在背景图上
/// - 标题根据滚动进度淡入显示（0.0 → 1.0）
/// - 支持长标题自动省略（在初始化时计算）
/// - 返回/分享按钮带半透明背景
///
/// ## 示例用法
/// ```dart
/// TransparentAppBarWithImage(
///   backgroundImageUrl: 'https://example.com/course.jpg',
///   title: 'Flutter 完整开发指南',
///   scrollProgress: 0.5, // 0.0 = 隐藏标题, 1.0 = 显示标题
///   onBack: () => Navigator.pop(context),
///   onShare: () {
///     // 处理分享
///   },
/// )
/// ```
///
/// ## 滚动效果
/// - scrollProgress = 0.0: 标题完全透明（只显示返回/分享按钮）
/// - scrollProgress = 0.5: 标题半透明
/// - scrollProgress = 1.0: 标题完全不透明
class TransparentAppBarWithImage extends StatelessWidget implements PreferredSizeWidget {
  /// 背景图URL
  ///
  /// 从手机顶部开始平铺，延伸到内容区域
  final String backgroundImageUrl;

  /// 标题（可选）
  ///
  /// 根据滚动进度淡入显示
  /// 支持长标题自动省略
  final Widget? title;

  /// 返回按钮回调
  final VoidCallback? onBack;

  /// 分享按钮回调
  final VoidCallback? onShare;

  /// 滚动进度（0.0 - 1.0）
  ///
  /// 用于控制标题的淡入淡出
  /// - 0.0: 标题完全透明
  /// - 1.0: 标题完全不透明
  final double scrollProgress;

  /// 毛玻璃模糊度 X
  final double sigmaX;

  /// 毛玻璃模糊度 Y
  final double sigmaY;

  /// 毛玻璃透明度
  final double frostedOpacity;

  /// 返回按钮图标
  final IconData? backIcon;

  /// 分享按钮图标
  final IconData? shareIcon;

  /// 按钮背景色
  final Color? buttonBackgroundColor;

  /// 按钮图标颜色
  final Color? buttonIconColor;

  /// 标题对齐方式
  final MainAxisAlignment titleAlignment;

  /// AppBar 高度
  final double? appBarHeight;

  /// 是否显示分享按钮
  final bool showShareButton;

  const TransparentAppBarWithImage({
    super.key,
    required this.backgroundImageUrl,
    this.title,
    this.onBack,
    this.onShare,
    this.scrollProgress = 0.0,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.frostedOpacity = 0.1,
    this.backIcon,
    this.shareIcon,
    this.buttonBackgroundColor,
    this.buttonIconColor,
    this.titleAlignment = MainAxisAlignment.center,
    this.appBarHeight,
    this.showShareButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // 计算当前的毛玻璃透明度（基于滚动进度）
    // scrollProgress = 0.0 时完全透明（无毛玻璃）
    // scrollProgress = 1.0 时达到设置的毛玻璃透明度
    final currentFrostedOpacity = frostedOpacity * scrollProgress.clamp(0.0, 1.0);

    // 关键修复：始终使用 BackdropFilter，确保安全区域始终和导航栏保持一致的背景
    // 当 scrollProgress = 0 时，sigma = 0，opacity = 0，相当于透明
    // 当 scrollProgress > 0 时，逐渐显示毛玻璃效果
    return Container(
      height: preferredSize.height,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: sigmaX * scrollProgress.clamp(0.0, 1.0),
            sigmaY: sigmaY * scrollProgress.clamp(0.0, 1.0),
          ),
          child: Container(
            color: Colors.white.withValues(alpha: currentFrostedOpacity),
            // SafeArea 在 BackdropFilter 内部，确保安全区域始终跟随导航栏背景
            child: SafeArea(
              bottom: false,
              child: _buildAppBarContent(context),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建 AppBar 内容
  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // 返回按钮
          _buildBackButton(),

          // 标题（居中）
          Expanded(
            child: _buildTitle(),
          ),

          // 分享按钮（保持宽度，让标题居中）
          if (showShareButton)
            _buildShareButton()
          else
            const SizedBox(width: 48), // 与返回按钮宽度一致
        ],
      ),
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: buttonBackgroundColor ?? Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(backIcon ?? Icons.arrow_back),
          color: buttonIconColor ?? Colors.white,
          onPressed: onBack ?? () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          iconSize: 20,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }

  /// 构建分享按钮
  Widget _buildShareButton() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: buttonBackgroundColor ?? Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(shareIcon ?? Icons.share),
        color: buttonIconColor ?? Colors.white,
        onPressed: onShare,
        padding: EdgeInsets.zero,
        iconSize: 20,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    if (title == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: scrollProgress.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: title!,
        ),
      ),
    );
  }
}

