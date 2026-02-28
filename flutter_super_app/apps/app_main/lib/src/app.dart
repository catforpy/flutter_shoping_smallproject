library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import 'package:flutter_pickers/pickers.dart';
import 'features/home/home_page.dart';
import 'features/category/category_page.dart';
import 'features/discovery/discovery_page.dart';
import 'features/study/study_page.dart';
import 'pages/search_page.dart';
import 'pages/message_page.dart';
import 'features/profile/profile_page/profile_page.dart';
import 'data.dart';

/// 主应用框架 - 底部导航栏 + 顶部导航栏
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  /// 当前选中的省份
  String _selectedProvince = '北京';

  /// 当前选中的城市
  String _selectedCity = '东城区';

  // 页面列表
  final List<_PageItem> _pages = [
    const _PageItem(
      title: '首页',
      icon: Icons.home,
      page: HomePage(),
    ),
    const _PageItem(
      title: '分类',
      icon: Icons.category,
      page: CategoryPage(),
    ),
    const _PageItem(
      title: '发现',
      icon: Icons.explore,
      page: DiscoveryPage(),
    ),
    const _PageItem(
      title: '学习',
      icon: Icons.school,
      page: StudyPage(),
    ),
    _PageItem(
      title: '我的',
      icon: Icons.person,
      page: ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      // 顶部导航栏（首页显示搜索框，其他页面显示标题）
      appBar: _currentIndex == 0 ? _buildSearchAppBar() : _buildTitleAppBar(currentPage.title),
      // 内容区域
      body: currentPage.page,
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _pages
            .map(
              (page) => BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.title,
              ),
            )
            .toList(),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// 构建搜索框导航栏（首页使用）
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white, // 白色背景
      elevation: 0, // 移除阴影
      title: SearchField(
        controller: _searchController,
        hintText: '',
        readOnly: true, // 首页搜索框只读，不显示光标和键盘
        styleConfig: SearchFieldStyleConfig(
          backgroundColor: Color(0xFFF5F5F5), // 稍灰一点的背景
          textColor: Colors.black87,
          hintColor: Colors.grey[600]!,
          cursorColor: Colors.blue,
          borderRadius: 20,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        animationConfig: SearchFieldAnimationConfig(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ),
        actionConfig: SearchFieldActionConfig(
          onTap: () {
            // 点击搜索框时，跳转到搜索页面（从右侧滑入）
            Navigator.push(context, SearchPage.route());
          },
        ),
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            SizedBox(width: 8),
            SearchHintRotator(
              hintGroups: MockData.searchHintGroups
                  .map((group) => SearchHintGroup(
                        hints: List<String>.from(group['hints'] as List),
                      ))
                  .toList(),
              config: SearchHintRotatorConfig(
                hintColor: Colors.grey[600]!,
                interval: Duration(seconds: 2),
                animationDuration: Duration(milliseconds: 500),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
      titleSpacing: 8,
      // AppBar 右侧的图标（搜索框外部）
      actions: [
        // 位置
        GestureDetector(
          onTap: _showCitySelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.grey[700], size: 20),
              SizedBox(width: 4),
              Text('$_selectedProvince-$_selectedCity', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            ],
          ),
        ),
        SizedBox(width: 16),
        // 邮件图标
        GestureDetector(
          onTap: () {
            // 点击邮件图标时，跳转到站内信页面（从右侧滑入）
            Navigator.push(context, MessagePage.route());
          },
          child: Icon(Icons.mail_outline, color: Colors.grey[700], size: 20),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  /// 显示城市选择器（使用 flutter_pickers 插件）
  void _showCitySelector() {
    Pickers.showAddressPicker(
      context,
      initProvince: _selectedProvince,
      initCity: _selectedCity,
      initTown: '', // 设置为空字符串，不显示区级
      onConfirm: (p, c, t) {
        setState(() {
          _selectedProvince = p;
          _selectedCity = c;
        });

        // 打印选中的省市数据（方便后续对接后端）
        print('===== 城市选择数据 =====');
        print('省份: $_selectedProvince');
        print('城市: $_selectedCity');
        print('完整地址: $_selectedProvince $_selectedCity');
        print('======================');
      },
    );
  }

  /// 构建标题导航栏（其他页面使用）
  PreferredSizeWidget _buildTitleAppBar(String title) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}

/// 页面项
class _PageItem {
  final String title;
  final IconData icon;
  final Widget page;

  const _PageItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}
