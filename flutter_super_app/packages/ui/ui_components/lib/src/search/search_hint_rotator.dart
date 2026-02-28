library;

import 'dart:async';
import 'package:flutter/material.dart';

/// 搜索提示词组
class SearchHintGroup {
  /// 提示词列表（会依次轮播显示）
  final List<String> hints;

  const SearchHintGroup({
    required this.hints,
  });

  /// 从单个提示词创建组
  factory SearchHintGroup.single(String hint) {
    return SearchHintGroup(hints: [hint]);
  }
}

/// 搜索提示词轮播配置
///
/// 采用不可变设计，支持链式调用
class SearchHintRotatorConfig {
  /// 轮播间隔时长
  final Duration interval;

  /// 动画时长
  final Duration animationDuration;

  /// 动画曲线
  final Curve animationCurve;

  /// 提示词颜色
  final Color hintColor;

  /// 提示词大小
  final double fontSize;

  /// 提示词粗细
  final FontWeight? fontWeight;

  /// 提示词间距
  final double spacing;

  /// 行高补偿（避免文字切换时跳动）
  final double lineHeightCompensation;

  /// 滑动动画起始位置偏移量（Y轴，0.0 = 无偏移，1.0 = 从完全下方开始）
  final double slideOffsetBegin;

  /// 是否启用淡入淡出动画
  final bool enableFadeAnimation;

  /// 是否启用滑动动画
  final bool enableSlideAnimation;

  const SearchHintRotatorConfig({
    this.interval = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    required this.hintColor,
    this.fontSize = 14,
    this.fontWeight,
    this.spacing = 4,
    this.lineHeightCompensation = 4,
    this.slideOffsetBegin = 0.5,
    this.enableFadeAnimation = true,
    this.enableSlideAnimation = true,
  });

  /// 链式调用：创建副本并修改部分属性
  SearchHintRotatorConfig copyWith({
    Duration? interval,
    Duration? animationDuration,
    Curve? animationCurve,
    Color? hintColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? spacing,
    double? lineHeightCompensation,
    double? slideOffsetBegin,
    bool? enableFadeAnimation,
    bool? enableSlideAnimation,
  }) {
    return SearchHintRotatorConfig(
      interval: interval ?? this.interval,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      hintColor: hintColor ?? this.hintColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      spacing: spacing ?? this.spacing,
      lineHeightCompensation: lineHeightCompensation ?? this.lineHeightCompensation,
      slideOffsetBegin: slideOffsetBegin ?? this.slideOffsetBegin,
      enableFadeAnimation: enableFadeAnimation ?? this.enableFadeAnimation,
      enableSlideAnimation: enableSlideAnimation ?? this.enableSlideAnimation,
    );
  }

  /// 函数式：设置轮播间隔
  SearchHintRotatorConfig withInterval(Duration interval) {
    return copyWith(interval: interval);
  }

  /// 函数式：设置动画时长
  SearchHintRotatorConfig withAnimationDuration(Duration duration) {
    return copyWith(animationDuration: duration);
  }

  /// 函数式：设置提示词颜色
  SearchHintRotatorConfig withHintColor(Color color) {
    return copyWith(hintColor: color);
  }

  /// 函数式：设置滑动起始位置
  SearchHintRotatorConfig withSlideOffset(double offset) {
    return copyWith(slideOffsetBegin: offset);
  }

  /// 函数式：仅淡入淡出动画（禁用滑动）
  SearchHintRotatorConfig fadeOnly() {
    return copyWith(
      enableSlideAnimation: false,
      enableFadeAnimation: true,
    );
  }

  /// 函数式：仅滑动动画（禁用淡入淡出）
  SearchHintRotatorConfig slideOnly() {
    return copyWith(
      enableSlideAnimation: true,
      enableFadeAnimation: false,
    );
  }
}

/// 搜索提示词轮播组件
///
/// ## 设计理念
/// - **自动轮播**：每隔一段时间自动切换到下一组提示词
/// - **向上滚动动画**：提示词向上滑出，新的提示词从下方滑入
/// - **组合提示**：支持一组提示词组合显示（如"电影 施瓦辛格 奥斯卡"）
/// - **高度灵活**：轮播间隔、动画时长、样式均可配置
///
/// ## 使用示例
/// ```dart
/// SearchHintRotator(
///   hintGroups: [
///     SearchHintGroup(hints: ['电影', '施瓦辛格', '奥斯卡']),
///     SearchHintGroup(hints: ['音乐', '周杰伦', '金曲奖']),
///     SearchHintGroup(hints: ['美食', '火锅', '麻辣']),
///     SearchHintGroup(hints: ['旅行', '三亚', '海滩']),
///   ],
///   config: SearchHintRotatorConfig(
///     hintColor: Colors.grey[600]!,
///     interval: Duration(seconds: 3),
///   ),
/// )
/// ```
class SearchHintRotator extends StatefulWidget {
  /// 提示词组列表
  final List<SearchHintGroup> hintGroups;

  /// 轮播配置
  final SearchHintRotatorConfig? config;

  const SearchHintRotator({
    super.key,
    required this.hintGroups,
    this.config,
  });

  @override
  State<SearchHintRotator> createState() => _SearchHintRotatorState();
}

class _SearchHintRotatorState extends State<SearchHintRotator>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;

  SearchHintRotatorConfig? get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(SearchHintRotator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hintGroups != oldWidget.hintGroups) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 启动定时器
  void _startTimer() {
    final config = _config;
    if (config == null || widget.hintGroups.length <= 1) return;

    _timer = Timer.periodic(config.interval, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.hintGroups.length;
        });
      }
    });
  }

  /// 重置定时器
  void _resetTimer() {
    _timer?.cancel();
    _currentIndex = 0;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (config == null || widget.hintGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentGroup = widget.hintGroups[_currentIndex];

    return ClipRect(
      child: AnimatedSize(
        duration: config.animationDuration,
        curve: config.animationCurve,
        child: SizedBox(
          height: config.fontSize + config.lineHeightCompensation,
          child: AnimatedSwitcher(
            duration: config.animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // 根据配置构建动画
              Widget animatedChild = child;

              // 滑动动画
              if (config.enableSlideAnimation) {
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(0, config.slideOffsetBegin),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: config.animationCurve,
                ));
                animatedChild = SlideTransition(
                  position: offsetAnimation,
                  child: animatedChild,
                );
              }

              // 淡入淡出动画
              if (config.enableFadeAnimation) {
                final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: config.animationCurve,
                  ),
                );
                animatedChild = FadeTransition(
                  opacity: fadeAnimation,
                  child: animatedChild,
                );
              }

              return animatedChild;
            },
            child: _buildHintGroup(
              currentGroup,
              config,
              key: ValueKey(_currentIndex),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建提示词组
  Widget _buildHintGroup(
    SearchHintGroup group,
    SearchHintRotatorConfig config,
    {Key? key}
  ) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: _buildHintSpans(group.hints, config),
    );
  }

  /// 构建提示词片段
  List<Widget> _buildHintSpans(List<String> hints, SearchHintRotatorConfig config) {
    final List<Widget> widgets = [];

    for (int i = 0; i < hints.length; i++) {
      // 添加提示词
      widgets.add(
        Text(
          hints[i],
          style: TextStyle(
            color: config.hintColor,
            fontSize: config.fontSize,
            fontWeight: config.fontWeight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

      // 添加间距（除了最后一个）
      if (i < hints.length - 1) {
        widgets.add(SizedBox(width: config.spacing));
      }
    }

    return widgets;
  }
}
