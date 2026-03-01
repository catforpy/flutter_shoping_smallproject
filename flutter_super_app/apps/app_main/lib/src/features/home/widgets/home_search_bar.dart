library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../../../pages/search_page.dart';
import '../theme/home_theme.dart';

/// 首页搜索框组件
///
/// 包含：
/// - 搜索输入框（带轮播提示词）
/// - 搜索按钮
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  /// 跳转到搜索页面
  void _navigateToSearch(BuildContext context) {
    Navigator.push(context, SearchPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToSearch(context),
              child: Container(
                decoration: BoxDecoration(
                  color: HomeTheme.searchBackgroundColor,
                  borderRadius:
                      BorderRadius.circular(HomeTheme.searchBorderRadius),
                  border: Border.all(
                    color: HomeTheme.searchBorderColor,
                    width: 1,
                  ),
                ),
                child: SearchField(
                  hintText: '',
                  readOnly: true,
                  styleConfig: SearchFieldStyleConfig(
                    backgroundColor: Colors.transparent,
                    textColor: HomeTheme.primaryTextColor,
                    hintColor: HomeTheme.secondaryTextColor,
                    cursorColor: Colors.blue,
                    borderRadius: HomeTheme.searchBorderRadius,
                    padding: HomeTheme.searchPadding,
                  ),
                  animationConfig: const SearchFieldAnimationConfig(
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                  ),
                  actionConfig: SearchFieldActionConfig(
                    onTap: () => _navigateToSearch(context),
                  ),
                  prefix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search,
                          color: HomeTheme.searchIconColor, size: 20),
                      const SizedBox(width: HomeTheme.spacing8),
                      // 向上轮播动画的提示词
                      SearchHintRotator(
                        hintGroups: const [
                          SearchHintGroup(hints: ['零食']),
                          SearchHintGroup(hints: ['巧克力']),
                          SearchHintGroup(hints: ['茅台酒']),
                          SearchHintGroup(hints: ['休闲零食']),
                        ],
                        config: SearchHintRotatorConfig(
                          hintColor: HomeTheme.secondaryTextColor,
                          interval: const Duration(seconds: 1),
                          animationDuration: const Duration(milliseconds: 500),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  suffix: const Icon(
                    Icons.camera_alt_outlined,
                    color: HomeTheme.searchIconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // 搜索按钮
          const SizedBox(width: HomeTheme.spacing12),
          GestureDetector(
            onTap: () => _navigateToSearch(context),
            child: Container(
              padding: HomeTheme.buttonPadding,
              decoration: BoxDecoration(
                color: HomeTheme.searchButtonColor,
                borderRadius:
                    BorderRadius.circular(HomeTheme.buttonBorderRadius),
              ),
              child: const Text(
                '搜索',
                style: TextStyle(
                  color: HomeTheme.searchButtonTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
