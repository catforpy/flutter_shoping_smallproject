library;

import 'package:service_commerce/service_commerce.dart';
import '../models/home_tab_model.dart';

/// Mock 数据集中管理
///
/// 开发阶段使用，后期接入后端时可直接删除此文件
class MockData {
  /// 首页标签列表（Mock 数据）
  ///
  /// 对应后端 API: GET /api/home/tabs
  static const List<HomeTabModel> homeTabs = [
    HomeTabModel(id: '0', title: '推荐'),
    HomeTabModel(id: '1', title: '关注'),
    HomeTabModel(id: '2', title: '热门'),
    HomeTabModel(id: '3', title: '视频'),
    HomeTabModel(id: '5', title: '话题'),
    HomeTabModel(id: '8', title: '活动'),
  ];

  /// 首页内容（Mock 数据）
  ///
  /// 对应后端 API: GET /api/home/content?tabId={tabId}
  static Map<String, dynamic> getHomeContent(String tabId) {
    // 根据 tabId 返回不同的模拟内容
    final tabTitles = {
      '0': '推荐',
      '1': '关注',
      '2': '热门',
      '3': '视频',
      '5': '话题',
      '8': '活动',
    };

    final title = tabTitles[tabId] ?? '未知';

    return {
      'tabId': tabId,
      'tabTitle': title,
      'items': [
        {
          'id': '1',
          'title': '$title - 内容1',
          'description': '这里是$title的内容展示',
          'author': '用户A',
          'likes': 100,
        },
        {
          'id': '2',
          'title': '$title - 内容2',
          'description': '更多$title内容',
          'author': '用户B',
          'likes': 200,
        },
      ],
    };
  }

  /// 搜索提示词组（Mock 数据）
  ///
  /// 对应后端 API: GET /api/search/hint-groups
  static const List<Map<String, dynamic>> searchHintGroups = [
    {'hints': ['电影', '施瓦辛格', '奥斯卡']},
    {'hints': ['音乐', '周杰伦', '金曲奖']},
    {'hints': ['美食', '火锅', '麻辣']},
    {'hints': ['旅行', '三亚', '海滩']},
  ];

  /// 个人中心菜单（Mock 数据）
  ///
  /// 对应后端 API: GET /api/profile/menu
  static const Map<String, dynamic> profileMenu = {
    'commonFunctions': [
      {'id': '1', 'title': '我的收藏', 'icon': 'favorite', 'color': 'red'},
      {'id': '2', 'title': '浏览历史', 'icon': 'history', 'color': 'orange'},
      {'id': '3', 'title': '我的订单', 'icon': 'shopping_bag', 'color': 'blue'},
    ],
    'settings': [
      {'id': '4', 'title': '账号与安全', 'icon': 'security', 'color': 'purple'},
      {'id': '5', 'title': '消息通知', 'icon': 'notifications', 'color': 'green'},
      {'id': '6', 'title': '隐私设置', 'icon': 'lock', 'color': 'grey'},
      {'id': '7', 'title': '关于我们', 'icon': 'info', 'color': 'blue'},
    ],
  };

  /// 首页推荐商品列表（Mock 数据）
  ///
  /// 对应后端 API: GET /api/home/products
  static List<Product> getHomeProducts() {
    return const [
      Product(
        id: '1',
        sellerId: 'seller_001',
        sellerName: 'Apple官方旗舰店',
        type: ProductType.physical,
        name: 'Apple iPhone 15 Pro Max 256GB 钛金属原色',
        description: 'A17 Pro芯片 | 钛金属边框 | 4800万像素主摄',
        coverImage: 'https://picsum.photos/seed/iphone15/200/200',
        price: 999900, // 单位：分
        originalPrice: 1099900,
        stock: 100,
        soldCount: 100000,
        categoryId: 'category_001',
        viewCount: 500000,
        likeCount: 20000,
        commentCount: 5000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '2',
        sellerId: 'seller_002',
        sellerName: '小米官方旗舰店',
        type: ProductType.physical,
        name: '小米14 Ultra 徕卡光学镜头 16GB+512GB 黑色',
        description: '骁龙8 Gen3 | 徕卡可变光圈 | 2K超视感屏',
        coverImage: 'https://picsum.photos/seed/xiaomi14/200/200',
        price: 649900,
        originalPrice: 699900,
        stock: 200,
        soldCount: 80000,
        categoryId: 'category_001',
        viewCount: 300000,
        likeCount: 15000,
        commentCount: 3000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '3',
        sellerId: 'seller_003',
        sellerName: '华为官方旗舰店',
        type: ProductType.physical,
        name: '华为 Mate 60 Pro 雅川青 12GB+512GB',
        description: '卫星通话 | 昆仑玻璃 | 鸿蒙4.0系统',
        coverImage: 'https://picsum.photos/seed/huawei60/200/200',
        price: 699900,
        originalPrice: 799900,
        stock: 50,
        soldCount: 150000,
        categoryId: 'category_001',
        viewCount: 600000,
        likeCount: 30000,
        commentCount: 6000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '4',
        sellerId: 'seller_004',
        sellerName: 'Dell官方旗舰店',
        type: ProductType.physical,
        name: '戴尔 XPS 13 Plus 13.4英寸触控本 i7/16GB/512GB',
        description: 'Intel i7-1360P | 3.5K OLED触控屏 | Windows 11',
        coverImage: 'https://picsum.photos/seed/dellxps/200/200',
        price: 999900,
        originalPrice: 1199900,
        stock: 80,
        soldCount: 20000,
        categoryId: 'category_002',
        viewCount: 100000,
        likeCount: 5000,
        commentCount: 1000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '5',
        sellerId: 'seller_005',
        sellerName: 'Sony官方旗舰店',
        type: ProductType.physical,
        name: 'Sony WH-1000XM5 头戴式无线降噪耳机 黑色',
        description: '30小时续航 | 8麦克风系统 | Hi-Res音质',
        coverImage: 'https://picsum.photos/seed/sonywh/200/200',
        price: 249900,
        originalPrice: 289900,
        stock: 150,
        soldCount: 50000,
        categoryId: 'category_003',
        viewCount: 200000,
        likeCount: 10000,
        commentCount: 2000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '6',
        sellerId: 'seller_006',
        sellerName: 'Nike官方旗舰店',
        type: ProductType.physical,
        name: 'Nike Air Force 1 \'07 纯白经典板鞋',
        description: '经典纯白配色 | 舒适缓震 | 耐磨鞋底',
        coverImage: 'https://picsum.photos/seed/nikeaf1/200/200',
        price: 74900,
        originalPrice: 89900,
        stock: 300,
        soldCount: 200000,
        categoryId: 'category_004',
        viewCount: 800000,
        likeCount: 40000,
        commentCount: 8000,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '7',
        sellerId: 'seller_007',
        sellerName: 'Apple官方旗舰店',
        type: ProductType.physical,
        name: 'Apple Watch Series 9 GPS款 45毫米',
        description: '新S9芯片 | 全天候视网膜显示屏 | 健康监测',
        coverImage: 'https://picsum.photos/seed/watch9/200/200',
        price: 319900,
        originalPrice: 349900,
        stock: 120,
        soldCount: 60000,
        categoryId: 'category_005',
        viewCount: 250000,
        likeCount: 12000,
        commentCount: 2500,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
      Product(
        id: '8',
        sellerId: 'seller_008',
        sellerName: 'Lenovo官方旗舰店',
        type: ProductType.physical,
        name: '联想拯救者 Y9000P 2024 16英寸游戏本',
        description: 'i9-14900HX | RTX 4060 | 32GB内存 | 1TB SSD',
        coverImage: 'https://picsum.photos/seed/lenovo/200/200',
        price: 1299900,
        originalPrice: 1499900,
        stock: 60,
        soldCount: 15000,
        categoryId: 'category_002',
        viewCount: 120000,
        likeCount: 6000,
        commentCount: 1200,
        status: ProductStatus.onSale,
        createdAt: null,
      ),
    ];
  }
}
