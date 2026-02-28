library;

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
}
