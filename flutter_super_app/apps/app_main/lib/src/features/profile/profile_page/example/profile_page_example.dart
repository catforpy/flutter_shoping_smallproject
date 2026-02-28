library;

import 'package:flutter/material.dart';
import '../config/config.dart';
import '../profile_page.dart';

/// 个人中心页面示例 - 函数式链式调用
///
/// 展示如何使用链式调用构建复杂的个人中心页面
class ProfilePageExample extends StatelessWidget {
  const ProfilePageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      config: ProfilePageConfig()
          .withBackgroundColor(Colors.grey[100]!)
          .withHeader(
        ProfileHeaderConfig(
          avatar: Icon(Icons.person, size: 80),
          name: '张三',
          subtitle: '产品经理 | 北京',
        )
            .withBackgroundColor(Colors.white)
            .withAvatarSize(100)
            .withPadding(EdgeInsets.symmetric(vertical: 32))
            .withOnTap(() {
          print('点击头像');
        }),
      )
          .withPagePadding(EdgeInsets.only(top: 16)),
    );
  }
}

/// 个人中心页面示例 - 完全自定义
///
/// 展示如何完全自定义头部和菜单
class ProfilePageCustomExample extends StatelessWidget {
  const ProfilePageCustomExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      config: ProfilePageConfig(
        headerConfig: ProfileHeaderConfig(
          avatar: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 50,
          ),
          name: '李四',
          subtitle: '全栈开发工程师',
          backgroundColor: Colors.blue[50],
          padding: EdgeInsets.all(24),
          nameStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
          subtitleStyle: TextStyle(
            fontSize: 16,
            color: Colors.blue[700],
          ),
          avatarShape: BoxShape.circle,
          onTap: () => print('跳转到个人资料页'),
        ),
        backgroundColor: Colors.grey[200],
        showTopSafeArea: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// 个人中心页面示例 - 简洁版
///
/// 展示最简洁的使用方式
class ProfilePageSimpleExample extends StatelessWidget {
  const ProfilePageSimpleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      config: ProfilePageConfig(
        headerConfig: ProfileHeaderConfig(
          avatar: Icon(Icons.person_outline, size: 60),
          name: '游客',
          subtitle: '登录后查看更多',
        ),
        backgroundColor: Colors.grey[50],
      ),
    );
  }
}
