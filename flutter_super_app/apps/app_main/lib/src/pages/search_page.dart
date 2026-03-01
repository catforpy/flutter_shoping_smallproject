library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import 'package:ui_extensions/ui_extensions.dart';

/// 搜索页面
///
/// ## 功能
/// - 顶部导航栏：返回按钮 + 搜索框 + 搜索图标
/// - 搜索框提示文字："请输入搜索内容"
/// - 点击搜索框弹出键盘
/// - 输入文字时显示 X 按钮清除
/// - 从右侧滑入的转场动画
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  /// 创建带有从右侧滑入动画的路由
  static Route<T> route<T>() {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
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
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  /// 是否显示清除按钮
  bool _showClearButton = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSearchAppBar(),
      body: _buildContent(),
    );
  }

  /// 构建搜索页面顶部导航栏
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildBackButton(),
      title: _buildSearchField(),
      titleSpacing: 0,
      actions: [
        _buildSearchButton(),
      ],
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
      onPressed: () => Navigator.pop(context),
    );
  }

  /// 构建搜索框
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: SearchField(
        controller: _searchController,
        hintText: '请输入搜索内容',
        styleConfig: SearchFieldStyleConfig(
          backgroundColor: Colors.transparent,
          textColor: Colors.black87,
          hintColor: Colors.grey[600]!,
          cursorColor: Colors.blue,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        animationConfig: const SearchFieldAnimationConfig(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ),
        actionConfig: SearchFieldActionConfig(
          onTap: () {
            // 点击搜索框时，聚焦并弹出键盘
            // SearchField 内部会自动处理焦点
          },
          onChanged: (text) {
            setState(() {
              _showClearButton = text.isNotEmpty;
            });
          },
          onClear: () {
            _searchController.clear();
            setState(() {
              _showClearButton = false;
            });
          },
        ),
        prefix: const Icon(
          Icons.search,
          color: Colors.grey,
          size: 20,
        ),
        suffix: _showClearButton
            ? const Icon(Icons.close, color: Colors.grey, size: 20)
            : null,
      ),
    );
  }

  /// 构建搜索按钮
  Widget _buildSearchButton() {
    return IconButton(
      icon: Icon(Icons.search, color: Colors.black87),
      onPressed: () {
        final searchText = _searchController.text.trim();
        if (searchText.isNotEmpty) {
          // TODO: 执行搜索逻辑
          print('执行搜索: $searchText');
        }
      },
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search, size: 80, color: Colors.grey[300]),
        SizedBox(height: 16),
        Text(
          '搜索内容',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ],
    ).center();
  }
}
