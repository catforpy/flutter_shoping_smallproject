library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_commerce/service_commerce.dart';
import 'package:ui_components/ui_components.dart';
import 'package:ui_templates/ui_templates.dart';
import '../features/home/widgets/home_search_bar.dart';
import '../features/home/theme/home_theme.dart';
import '../features/home/data/mocks/mock_data.dart';

/// 新人补贴页面
///
/// 页面结构：
/// - 顶部导航栏（返回按钮 + 标题）
/// - 搜索框
/// - 滑动标签栏（推荐、数码、小家电等）
/// - 瀑布流商品列表（两列展示）
class NewcomerSubsidyPage extends ConsumerStatefulWidget {
  const NewcomerSubsidyPage({super.key});

  static Route<Route> route() {
    return MaterialPageRoute(
      builder: (context) => const NewcomerSubsidyPage(),
    );
  }

  @override
  ConsumerState<NewcomerSubsidyPage> createState() => _NewcomerSubsidyPageState();
}

class _NewcomerSubsidyPageState extends ConsumerState<NewcomerSubsidyPage> {
  /// 当前选中的标签索引
  int _currentTabIndex = 0;

  /// PageView 控制器（用于滑动标签栏）
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
      body: Column(
        children: [
          // 搜索框
          const HomeSearchBar(),

          // 滑动标签栏
          _buildTabBar(),

          // 内容区域（PageView）
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              children: _buildTabPages(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        '新人补贴',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  /// 构建滑动标签栏
  Widget _buildTabBar() {
    return CourseDetailTabBar(
      tabs: _tabs,
      pageController: _pageController,
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      height: 50,
      topBorderRadius: 0,
      centerTabs: false,
    );
  }

  /// 标签列表
  static const List<UnderlineTabItem> _tabs = [
    UnderlineTabItem(id: '0', title: '推荐'),
    UnderlineTabItem(id: '1', title: '数码'),
    UnderlineTabItem(id: '2', title: '小家电'),
    UnderlineTabItem(id: '3', title: '日用'),
    UnderlineTabItem(id: '4', title: '家装建材'),
    UnderlineTabItem(id: '5', title: '微波炉'),
    UnderlineTabItem(id: '6', title: '洗碗机'),
    UnderlineTabItem(id: '7', title: '电脑'),
    UnderlineTabItem(id: '8', title: '净水器'),
    UnderlineTabItem(id: '9', title: '平板'),
    UnderlineTabItem(id: '10', title: '洗衣机'),
    UnderlineTabItem(id: '11', title: '母婴宠物'),
    UnderlineTabItem(id: '12', title: '耳机音响'),
    UnderlineTabItem(id: '13', title: '汽车用品'),
    UnderlineTabItem(id: '14', title: '冰箱'),
    UnderlineTabItem(id: '15', title: '厨具'),
    UnderlineTabItem(id: '16', title: '家用灶具'),
    UnderlineTabItem(id: '17', title: '空调'),
    UnderlineTabItem(id: '18', title: '手机'),
    UnderlineTabItem(id: '19', title: '吸油烟机'),
    UnderlineTabItem(id: '20', title: '电饭煲'),
    UnderlineTabItem(id: '21', title: '电视'),
    UnderlineTabItem(id: '22', title: '热水器'),
    UnderlineTabItem(id: '23', title: '其他'),
  ];

  /// 构建所有标签页
  List<Widget> _buildTabPages() {
    return List.generate(
      _tabs.length,
      (index) => _NewcomerSubsidyTabPage(
        tabIndex: index,
        tabTitle: _tabs[index].title,
      ),
    );
  }
}

/// 新人补贴标签页内容
class _NewcomerSubsidyTabPage extends StatelessWidget {
  final int tabIndex;
  final String tabTitle;

  const _NewcomerSubsidyTabPage({
    required this.tabIndex,
    required this.tabTitle,
  });

  @override
  Widget build(BuildContext context) {
    // 获取该标签的商品数据
    final products = _getTabProducts(tabIndex);

    return Container(
      color: HomeTheme.lightGreyBackground,
      child: WaterfallLayout(
        columns: 2,
        mainAxisSpacing: HomeTheme.productCardSpacing,
        crossAxisSpacing: HomeTheme.productCardSpacing,
        padding: const EdgeInsets.symmetric(
          horizontal: HomeTheme.horizontalSpacing,
          vertical: HomeTheme.spacing8,
        ),
        children: _buildProductCards(products),
      ),
    );
  }

  /// 构建商品卡片列表
  List<Widget> _buildProductCards(List<Product> products) {
    return products.map((product) {
      return MasonryProductCard(
        data: _buildMasonryCardData(product),
      );
    }).toList();
  }

  /// 构建 MasonryProductCardData
  MasonryProductCardData _buildMasonryCardData(Product product) {
    return MasonryProductCardData(
      title: product.name,
      subtitle: _getSubtitle(product),
      image: NetworkImage(product.coverImage ?? ''),
      price: product.priceInYuan,
      originalPrice: product.originalPriceInYuan,
      cornerBadge: '百亿补贴',
      cornerBadgeColor: Colors.red,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查看商品: ${product.name}')),
        );
      },
    );
  }

  /// 从规格信息中提取副标题
  String? _getSubtitle(Product product) {
    if (product.specifications == null || product.specifications!.isEmpty) {
      return null;
    }

    // 取第一个规格的第一个值作为副标题
    final firstSpec = product.specifications!.entries.first;
    if (firstSpec.value.isNotEmpty) {
      return firstSpec.value.first;
    }

    return null;
  }

  /// 根据标签索引获取商品数据
  List<Product> _getTabProducts(int index) {
    // 所有商品数据
    final allProducts = MockData.getNewcomerSubsidyProducts();

    // 根据标签索引返回不同的商品子集
    // 这里简单地通过取模的方式分配商品
    final startIndex = (index * 5) % allProducts.length;
    final endIndex = ((index + 1) * 5 + 3) % allProducts.length;

    // 确保 endIndex > startIndex，否则循环到数组开头
    if (endIndex > startIndex) {
      return allProducts.sublist(startIndex, endIndex);
    } else {
      return [
        ...allProducts.sublist(startIndex),
        ...allProducts.sublist(0, endIndex),
      ];
    }
  }
}
