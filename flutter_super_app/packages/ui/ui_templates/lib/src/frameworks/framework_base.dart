library;

import 'package:flutter/widgets.dart';

/// 页面框架类型
enum FrameworkType {
  /// 单列框架
  single,

  /// 双列框架
  double,

  /// 三级嵌套
  threeLevelNested,

  /// 四级嵌套
  fourLevelNested,

  /// TabBar 框架
  tabBar,

  /// 抽屉框架
  drawer,

  /// 自定义
  custom,
}

/// 页面框架基类
abstract base class FrameworkConfig {
  final FrameworkType type;
  final Map<String, dynamic> params;

  const FrameworkConfig({
    required this.type,
    this.params = const {},
  });
}

/// 页面框架 Widget 基类
abstract class FrameworkWidget extends StatelessWidget {
  final FrameworkConfig config;

  const FrameworkWidget({
    super.key,
    required this.config,
  });
}
