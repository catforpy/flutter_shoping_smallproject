library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import 'package:ui_extensions/ui_extensions.dart';
import 'config/config.dart';
import '../../test/file_cache_test_page.dart';

/// 我的页面
///
/// ## 设计理念
/// - **函数式风格**：配置类不可变，通过 copyWith 和函数式方法实现链式调用
/// - **高度灵活**：所有样式均可外部配置，避免硬编码
/// - **组合式设计**：基于 GroupedListSection 组合菜单列表
/// - **可扩展性**：支持自定义头部、自定义菜单项
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// ProfilePage(
///   config: ProfilePageConfig(),
/// )
///
/// // 函数式链式调用
/// ProfilePage(
///   config: ProfilePageConfig()
///       .withHeader(
///         ProfileHeaderConfig(
///           avatar: CircleAvatar(
///             backgroundImage: NetworkImage('url'),
///           ),
///           name: '张三',
///           subtitle: '产品经理',
///         )
///             .withBackgroundColor(Colors.blue[50])
///             .withAvatarSize(100)
///             .withOnTap(() => print('点击头像')),
///       )
///       .withBackgroundColor(Colors.grey[100]),
/// )
/// ```
class ProfilePage extends StatelessWidget {
  /// 页面配置（函数式风格，支持链式调用）
  final ProfilePageConfig config;

  ProfilePage({
    super.key,
    ProfilePageConfig? config,
  }) : config = config ?? ProfilePageConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: config.padding,
          children: [
            // 顶部安全区域
            if (config.showTopSafeArea) SizedBox(height: 8),

            // 头部区域
            _buildHeader(),

            // SizedBox(height: 12),

            // 菜单列表
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    final headerConfig = config.headerConfig;

    // 头像容器
    Widget avatarWidget = Container(
      width: headerConfig.avatarSize,
      height: headerConfig.avatarSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: headerConfig.avatarShape,
      ),
      child: headerConfig.avatar is Icon
          ? IconTheme(
              data: IconThemeData(
                size: headerConfig.avatarSize * 0.6,
                color: Colors.grey[600],
              ),
              child: headerConfig.avatar,
            )
          : headerConfig.avatar,
    ).decorated(
      color: Colors.grey[300],
      borderRadius: headerConfig.avatarShape == BoxShape.circle
          ? BorderRadius.circular(50)
          : null,
    );

    // 用户信息行（头像 + 文字横向排列）
    Widget userInfoRow = Row(
      children: [
        // 头像
        avatarWidget,
        SizedBox(width: 16),
        // 名称和副标题（纵向排列）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 名称
              Text(
                headerConfig.name,
                style: headerConfig.nameStyle ??
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              // 副标题
              if (headerConfig.subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  headerConfig.subtitle!,
                  style: headerConfig.subtitleStyle ??
                      TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // 包装整个头部
    Widget headerWidget = Padding(
      padding: headerConfig.padding,
      child: userInfoRow,
    ).decorated(
      color: headerConfig.backgroundColor,
    );

    // 如果有点击事件，包装 InkWell
    if (headerConfig.onTap != null) {
      headerWidget = InkWell(
        onTap: headerConfig.onTap,
        child: headerWidget,
      );
    }

    return headerWidget;
  }

  /// 构建菜单列表
  Widget _buildMenuList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 第一组：常用功能
        _buildMenuCard(
          title: '常用功能',
          items: [
            GroupedListItemConfig(
              title: '我的收藏',
              leading: Icon(Icons.favorite, color: Colors.red),
              onTap: () => print('我的收藏'),
            ),
            GroupedListItemConfig(
              title: '浏览历史',
              leading: Icon(Icons.history, color: Colors.orange),
              onTap: () => print('浏览历史'),
            ),
            GroupedListItemConfig(
              title: '我的订单',
              leading: Icon(Icons.shopping_bag, color: Colors.blue),
              onTap: () => print('我的订单'),
            ),
          ],
        ),

        // SizedBox(height: 0),

        // 第二组：设置
        _buildMenuCard(
          title: '设置',
          items: [
            GroupedListItemConfig(
              title: '账号与安全',
              leading: Icon(Icons.security, color: Colors.purple),
              onTap: () => print('账号与安全'),
            ),
            GroupedListItemConfig(
              title: '消息通知',
              leading: Icon(Icons.notifications, color: Colors.green),
              onTap: () => print('消息通知'),
            ),
            GroupedListItemConfig(
              title: '隐私设置',
              leading: Icon(Icons.lock, color: Colors.grey),
              onTap: () => print('隐私设置'),
            ),
            GroupedListItemConfig(
              title: '关于我们',
              leading: Icon(Icons.info, color: Colors.blue),
              onTap: () => print('关于我们'),
            ),
            GroupedListItemConfig(
              title: '文件缓存测试',
              leading: Icon(Icons.storage, color: Colors.orange),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FileCacheTestPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建单个菜单卡片（手动包裹，标题在卡片外）
  Widget _buildMenuCard({
    required String title,
    required List<GroupedListItemConfig> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题（在卡片外）
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ).padding(horizontal: 16, vertical: 12),
        // 列表卡片（白色背景）
        GroupedListSection(
          config: GroupedListSectionConfig(
            titleConfig: GroupedListTitleConfig(
              padding: EdgeInsets.zero, // 移除默认 padding，避免空白
            ),
            items: items,
            dividerConfig: GroupedListDividerConfig(
              color: Colors.grey[300]!,
              opacity: 0.5,
              height: 1,
              indent: 56,
            ),
          ),
        ).padding(horizontal: 16).decorated(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
