import 'package:flutter/material.dart';

/// 信息卡片组件
///
/// 通用的横向信息展示卡片，适用于评论、问答、消息等场景
///
/// ## 功能特性
/// - **横向布局**：左侧头像 + 中间信息 + 右侧 widget
/// - **灵活配置**：头像可选、右侧 widget 可选
/// - **纯展示组件**：不包含任何点击逻辑，由调用方控制交互
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// InfoCard(
///   avatar: NetworkImage('https://example.com/avatar.jpg'),
///   title: '张三',
///   subtitle: '2小时前',
///   content: '这是一条评论内容',
/// )
///
/// // 带右侧交互按钮（点赞）
/// InfoCard(
///   avatar: 'assets/avatar.png',
///   title: '李四',
///   subtitle: '3小时前',
///   content: '老师讲得很好',
///   trailing: _LikeButton(), // 自定义StatefulWidget处理点赞状态
/// )
///
/// // 整体可点击
/// InkWell(
///   onTap: () => print('跳转到详情'),
///   child: InfoCard(...),
/// )
/// ```
class InfoCard extends StatelessWidget {
  /// 头像图片（ImageProvider、Widget 或 String URL）
  final dynamic avatar;

  /// 头像大小
  final double avatarSize;

  /// 头像形状（圆形=0, 方形= borderRadius）
  final double avatarBorderRadius;

  /// 标题（用户名）
  final String title;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题（时间、等级等）
  final String? subtitle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 内容（评论、问题等）
  final String? content;

  /// 内容样式
  final TextStyle? contentStyle;

  /// 最大内容行数
  final int contentMaxLines;

  /// 内容超出显示方式
  final TextOverflow? contentOverflow;

  /// 右侧 widget（顶部对齐，可包含交互功能）
  final Widget? trailing;

  /// 左侧和中间的间距
  final double spacing;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  /// 背景颜色
  final Color? backgroundColor;

  /// 圆角
  final double borderRadius;

  const InfoCard({
    super.key,
    this.avatar,
    this.avatarSize = 40,
    this.avatarBorderRadius = 0, // 0 表示圆形
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    this.content,
    this.contentStyle,
    this.contentMaxLines = 999,
    this.contentOverflow,
    this.trailing,
    this.spacing = 12,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _buildAvatar();

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        if (avatarWidget != null) ...[
          avatarWidget,
          SizedBox(width: spacing),
        ],
        // 中间信息
        Expanded(
          child: _buildContent(),
        ),
        // 右侧 widget（可包含交互功能）
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );

    // 只处理容器样式，不处理点击
    if (backgroundColor != null || borderRadius > 0) {
      return Container(
        padding: padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: cardContent,
      );
    }

    if (padding != null) {
      return Padding(padding: padding!, child: cardContent);
    }

    return cardContent;
  }

  /// 构建头像
  Widget? _buildAvatar() {
    if (avatar == null) return null;

    Widget? avatarWidget;

    if (avatar is ImageProvider) {
      avatarWidget = Image(image: avatar as ImageProvider, fit: BoxFit.cover);
    } else if (avatar is Widget) {
      avatarWidget = avatar as Widget;
    } else if (avatar is String) {
      // URL 或 asset path
      avatarWidget = avatar.toString().startsWith('http')
          ? Image.network(avatar as String, fit: BoxFit.cover)
          : Image.asset(avatar as String, fit: BoxFit.cover);
    }

    if (avatarWidget == null) return null;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: avatarBorderRadius == 0
          ? const BoxDecoration(shape: BoxShape.circle)
          : BoxDecoration(
              borderRadius: BorderRadius.circular(avatarBorderRadius),
            ),
      child: ClipRRect(
        borderRadius: avatarBorderRadius == 0
            ? BorderRadius.circular(avatarSize / 2)
            : BorderRadius.circular(avatarBorderRadius),
        child: avatarWidget,
      ),
    );
  }

  /// 构建中间内容
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题 + 副标题
        Row(
          children: [
            Text(
              title,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                subtitle!,
                style: subtitleStyle ??
                    const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
              ),
            ],
          ],
        ),
        // 内容
        if (content != null && content!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            content!,
            style: contentStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
            maxLines: contentMaxLines,
            overflow: contentOverflow ?? TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
