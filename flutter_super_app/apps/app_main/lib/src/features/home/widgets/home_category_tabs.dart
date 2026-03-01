library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../theme/home_theme.dart';
import '../../../pages/newcomer_subsidy_page.dart';

/// 首页横向分类标签组件
///
/// 显示首页的商品分类标签，支持横向滑动和吸顶功能
class HomeCategoryTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeCategoryTabs({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// 首页分类标签数据
  static const List<TabItem> categoryTabs = [
    TabItem(id: '0', title: '推荐'),
    TabItem(id: '1', title: '新人补贴'),
    TabItem(id: '2', title: '大家电'),
    TabItem(id: '3', title: '手机'),
    TabItem(id: '4', title: '电脑办公'),
    TabItem(id: '5', title: '酒水'),
    TabItem(id: '6', title: '小家电'),
    TabItem(id: '7', title: '食品饮料'),
    TabItem(id: '8', title: '美妆'),
    TabItem(id: '9', title: '数码'),
    TabItem(id: '10', title: '运动'),
    TabItem(id: '11', title: '全球购'),
    TabItem(id: '12', title: '男装'),
    TabItem(id: '13', title: '箱包皮具'),
    TabItem(id: '14', title: '家居厨具'),
    TabItem(id: '15', title: '爱车'),
    TabItem(id: '16', title: '珠宝首饰'),
    TabItem(id: '17', title: '玩具乐器'),
    TabItem(id: '18', title: '房产'),
    TabItem(id: '19', title: '图书'),
    TabItem(id: '20', title: '内衣'),
    TabItem(id: '21', title: '童装'),
    TabItem(id: '22', title: '装修定制'),
    TabItem(id: '23', title: '工业品'),
    TabItem(id: '24', title: '个人护理'),
    TabItem(id: '25', title: '文具'),
    TabItem(id: '26', title: '奢侈品'),
    TabItem(id: '27', title: '拍拍二手'),
    TabItem(id: '28', title: '女装'),
    TabItem(id: '29', title: '家庭清洁'),
    TabItem(id: '30', title: '粮油调味'),
    TabItem(id: '31', title: '生活旅行'),
    TabItem(id: '32', title: '家纺'),
    TabItem(id: '33', title: '宠物'),
    TabItem(id: '34', title: '女鞋'),
    TabItem(id: '35', title: '生鲜'),
    TabItem(id: '36', title: '男鞋'),
    TabItem(id: '37', title: '自有品牌'),
    TabItem(id: '38', title: '医药健康'),
    TabItem(id: '39', title: '钟表眼镜'),
    TabItem(id: '40', title: '鲜花绿植'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTheme.backgroundColor,
      child: HorizontalTabs(
        tabs: categoryTabs,
        currentIndex: currentIndex,
        onTap: (index) {
          // 点击"新人补贴"标签时跳转到新人补贴页面
          if (categoryTabs[index].title == '新人补贴') {
            Navigator.push(context, NewcomerSubsidyPage.route());
            return;
          }
          // 其他标签正常切换
          onTap(index);
        },
        height: HomeTheme.horizontalTabsHeight,
        spacing: HomeTheme.horizontalTabsSpacing,
        tabPadding: HomeTheme.horizontalTabsPadding,
        borderRadius: HomeTheme.horizontalTabsBorderRadius,
        backgroundColor: HomeTheme.backgroundColor,
        // "推荐"标签吸顶在左侧
        pinnedTabIndex: 0,
        // 吸顶标签样式
        pinnedBorder: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        pinnedSelectedColor: HomeTheme.primaryColor, // "推荐"选中时红色
        pinnedUnselectedColor: HomeTheme.primaryColor, // "推荐"未选中时也是红色
        pinnedSelectedBackgroundColor: HomeTheme.backgroundColor,
        pinnedUnselectedBackgroundColor: HomeTheme.backgroundColor,
        // 普通标签样式
        selectedColor: HomeTheme.tabSelectedColor,
        unselectedColor: HomeTheme.tabUnselectedColor,
        selectedBackgroundColor: HomeTheme.tabSelectedBackgroundColor,
        unselectedBackgroundColor: Colors.transparent,
      ),
    );
  }
}
