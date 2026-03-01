library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_commerce/service_commerce.dart';
import 'package:ui_components/ui_components.dart';
import '../../pages/search_page.dart';
import '../../widgets/main_shell.dart';
import 'providers/home_product_provider.dart';

/// 首页
///
/// 使用 CourseDetailTabBar 组件作为顶部导航栏
/// 标签：特价、首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  final List<UnderlineTabItem> _tabs = const [
    UnderlineTabItem(id: '0', title: '特价'),
    UnderlineTabItem(id: '1', title: '首页'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // 默认显示"首页"
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
      body: Column(
        children: [
          // 顶部标签栏（使用 SafeArea 确保不被刘海屏/状态栏遮挡）
          SafeArea(
            bottom: false,
            child: CourseDetailTabBar(
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
              centerTabs: true,
            ),
          ),

          // 内容区域（支持手势滑动）
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // PageView 滑动时，CourseDetailTabBar 会自动监听并更新
                // 这里不需要额外操作，CourseDetailTabBar 已经通过 listener 监听了
              },
              children: const [
                // 特价页面
                _SpecialPricePage(),
                // 首页内容
                _HomePageContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 特价页面
class _SpecialPricePage extends StatelessWidget {
  const _SpecialPricePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.05),
      child: Column(
        children: [
          // 搜索框区域
          const _HomeSearchBar(),

          // 内容区域
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '特价页面',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '← 向右滑动切换到首页 →',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页内容
class _HomePageContent extends ConsumerWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontalTabIndex = ref.watch(homeHorizontalTabProvider);

    return Container(
      color: Colors.grey.withValues(alpha: 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索框区域
          const _HomeSearchBar(),

          // 横向滑动标签栏
          _buildHorizontalTabs(context, horizontalTabIndex, ref),

          // 可展开网格轮播组件（会推开下面的内容）
          _buildExpandableGrid(context),

          // 商品列表区域
          _buildProductList(context),
        ],
      ),
    );
  }

  /// 构建横向滑动标签栏
  Widget _buildHorizontalTabs(BuildContext context, int currentIndex, WidgetRef ref) {
    // 首页横向滑动标签列表
    final List<TabItem> horizontalTabs = const [
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

    return Container(
      color: Colors.white,
      child: HorizontalTabs(
        tabs: horizontalTabs,
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(homeHorizontalTabProvider.notifier).state = index;
        },
        height: 40,
        spacing: 12,
        tabPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 20,
        backgroundColor: Colors.white,
        // "推荐"标签吸顶在左侧
        pinnedTabIndex: 0,
        // 吸顶标签样式
        pinnedBorder: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        pinnedSelectedColor: Colors.red, // "推荐"选中时红色
        pinnedUnselectedColor: Colors.red, // "推荐"未选中时也是红色
        pinnedSelectedBackgroundColor: Colors.white,
        pinnedUnselectedBackgroundColor: Colors.white,
        // 普通标签样式
        selectedColor: Colors.black,
        unselectedColor: Colors.grey[600],
        selectedBackgroundColor: Colors.grey.withValues(alpha: 0.1),
        unselectedBackgroundColor: Colors.transparent,
      ),
    );
  }

  /// 构建可展开网格轮播组件
  Widget _buildExpandableGrid(BuildContext context) {
    // 定义分类数据（名称 + 图标）
    final categoryData = [
      ('品质外卖', Icons.restaurant),
      ('新人福利', Icons.card_giftcard),
      ('签到', Icons.event_available),
      ('东东农场', Icons.agriculture),
      ('领红包', Icons.card_giftcard),
      ('万人团', Icons.groups),
      ('京东超市', Icons.shopping_cart),
      ('手机数码', Icons.phone_android),
      ('家电家居', Icons.tv),
      ('优惠充值', Icons.phone_in_talk),
      ('京东国际', Icons.public),
      ('看房买药', Icons.medical_services),
      ('拍拍二手', Icons.cached),
      ('京东拍卖', Icons.gavel),
      ('沃尔玛', Icons.store),
      ('京东生鲜', Icons.eco),
      ('京东到家', Icons.delivery_dining),
      ('大牌试用', Icons.stars),
      ('领券', Icons.local_offer),
      ('零食广场', Icons.fastfood),
    ];

    // 生成widget列表
    final categoryWidgets = categoryData.map((data) {
      return _buildCategoryItem(data.$1, data.$2);
    }).toList();

    return ExpandableGridPageView(
      children: categoryWidgets,
      crossAxisCount: 5,
      firstPageRows: 1,
      secondPageRows: 3,
      topPadding: 16,
      bottomPadding: 8,
      spacing: 8,
      runSpacing: 16,
      onTap: (index) {
        final categoryName = categoryData[index].$1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击了：$categoryName')),
        );
      },
      onMoreTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('查看全部频道')),
        );
      },
    );
  }

  /// 构建分类item
  Widget _buildCategoryItem(String title, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: Colors.grey[700],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建商品列表
  Widget _buildProductList(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final products = ref.watch(homeProductsProvider);

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  /// 构建单个商品卡片
  Widget _buildProductCard(BuildContext context, Product product) {
    // 价格转换：分 -> 元
    final price = product.price / 100;
    final originalPrice = product.originalPrice != null
        ? product.originalPrice! / 100
        : null;

    // 格式化评价数和销量
    final reviewCount = product.commentCount > 0
        ? '${product.commentCount >= 1000 ? '${(product.commentCount / 1000).toStringAsFixed(1)}k+' : '${product.commentCount}+'}条评论'
        : null;
    final salesCount = product.soldCount > 0
        ? '已售${product.soldCount >= 10000 ? '${(product.soldCount / 10000).toStringAsFixed(1)}万+' : '${product.soldCount}+'}'
        : null;

    return UniversalProductCard(
      image: NetworkImage(product.coverImage ?? ''),
      title: product.name,
      price: price,
      originalPrice: originalPrice,
      reviewCount: reviewCount,
      salesCount: salesCount,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查看商品: ${product.name}')),
        );
      },
      actionButtonText: '立即抢购',
      actionButtonColor: Colors.red,
      onActionTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('立即抢购: ${product.name}')),
        );
      },
    );
  }
}

/// 首页搜索框组件
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  /// 跳转到搜索页面
  void _navigateToSearch(BuildContext context) {
    Navigator.push(context, SearchPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToSearch(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: SearchField(
                  hintText: '',
                  readOnly: true,
                  styleConfig: SearchFieldStyleConfig(
                    backgroundColor: Colors.transparent,
                    textColor: Colors.black87,
                    hintColor: Colors.grey,
                    cursorColor: Colors.blue,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      // 向上轮播动画的提示词
                      SearchHintRotator(
                        hintGroups: const [
                          SearchHintGroup(hints: ['零食']),
                          SearchHintGroup(hints: ['巧克力']),
                          SearchHintGroup(hints: ['茅台酒']),
                          SearchHintGroup(hints: ['休闲零食']),
                        ],
                        config: SearchHintRotatorConfig(
                          hintColor: Colors.grey,
                          interval: const Duration(seconds: 1), // 每秒轮播
                          animationDuration: const Duration(milliseconds: 500),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  suffix: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // 搜索按钮
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _navigateToSearch(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '搜索',
                style: TextStyle(
                  color: Colors.white,
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
