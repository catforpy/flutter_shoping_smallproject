library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import 'package:ui_extensions/ui_extensions.dart';

/// 站内信页面
///
/// ## 功能
/// - 顶部导航栏：返回按钮 + 横向滑动标签（推送、通知、私信）
/// - 标签样式：选中文字黑色+加粗+放大，未选中灰色
/// - 下划线：黑色，带动画
/// - 红点提示：有新内容时显示
/// - 从右侧滑入的转场动画
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  /// 创建带有从右侧滑入动画的路由
  static Route<T> route<T>() {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => MessagePage(),
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 从右侧滑入的动画
        const begin = Offset(1.0, 0.0); // 从屏幕右侧开始
        const end = Offset.zero; // 到屏幕中心
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  /// 当前选中的标签索引
  int _currentIndex = 0;

  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  final List<UnderlineTabItem> _tabs = [
    UnderlineTabItem(
      id: '0',
      title: '推送',
      hasNewContent: false, // TODO: 根据实际数据判断是否有新内容
    ),
    UnderlineTabItem(
      id: '1',
      title: '通知',
      hasNewContent: false, // TODO: 根据实际数据判断是否有新内容
    ),
    UnderlineTabItem(
      id: '2',
      title: '私信',
      hasNewContent: false, // TODO: 根据实际数据判断是否有新内容
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildBackButton(),
      title: _buildTabs(),
      centerTitle: true, // 标签居中显示
      titleSpacing: 0,
      actions: _currentIndex != 0 ? [_buildActionButton()] : [], // 推送标签不显示按钮
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
      onPressed: () => Navigator.pop(context),
    );
  }

  /// 构建右侧操作按钮
  Widget _buildActionButton() {
    return TextButton(
      onPressed: () => _handleActionButton(),
      child: Text(
        _getActionButtonText(),
        style: TextStyle(color: Colors.black87, fontSize: 15),
      ),
    ).padding(horizontal: 8);
  }

  /// 获取操作按钮文字
  String _getActionButtonText() {
    switch (_currentIndex) {
      case 0: // 推送
        return '';
      case 1: // 通知
        return '全部已读';
      case 2: // 私信
        return '设置';
      default:
        return '';
    }
  }

  /// 处理操作按钮点击事件
  void _handleActionButton() {
    switch (_currentIndex) {
      case 1: // 通知 - 全部已读
        print('全部已读');
        // TODO: 实现全部已读逻辑
        break;
      case 2: // 私信 - 设置
        print('设置');
        // TODO: 跳转到设置页面或显示设置对话框
        break;
    }
  }

  /// 构建横向滑动标签
  Widget _buildTabs() {
    return UnderlineTabs(
      tabs: _tabs,
      currentIndex: _currentIndex,
      onTap: (index) {
        // 点击标签时，同步滚动 PageView
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = index;
        });
      },
      indicatorConfig: UnderlineIndicatorConfig(
        color: Colors.black, // 黑色下划线
        height: 2,
        widthFactor: 0.6,
        animationDuration: Duration(milliseconds: 250),
      ),
      styleConfig: UnderlineTabStyleConfig(
        selectedColor: Colors.black, // 选中文字黑色
        unselectedColor: Colors.grey, // 未选中文字灰色
        selectedFontSize: 17, // 选中文字放大一点点
        unselectedFontSize: 15,
        selectedFontWeight: FontWeight.bold, // 选中文字加粗
        unselectedFontWeight: FontWeight.normal,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// 构建内容区域（使用 PageView 支持滑动切换）
  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      children: _tabs.map((tab) => _buildTabPage(tab)).toList(),
    );
  }

  /// 构建单个标签页
  Widget _buildTabPage(UnderlineTabItem tab) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_getTabIcon(tab.id), size: 80, color: Colors.grey[300]),
        SizedBox(height: 16),
        Text(
          '${tab.title}内容',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        Text(
          '暂无${tab.title}',
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ],
    ).center();
  }

  /// 根据标签ID获取对应图标
  IconData _getTabIcon(String tabId) {
    switch (tabId) {
      case '0':
        return Icons.notifications; // 推送
      case '1':
        return Icons.notification_important; // 通知
      case '2':
        return Icons.mail; // 私信
      default:
        return Icons.message;
    }
  }
}
