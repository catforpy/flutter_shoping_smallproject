import 'package:flutter/material.dart';

/// 悬浮窗控制器
///
/// 用于控制悬浮窗的显示、隐藏和状态
class FloatingController extends ChangeNotifier {
  bool _isShowing = false;

  /// 是否正在显示
  bool get isShowing => _isShowing;

  /// 显示悬浮窗
  void show(OverlayEntry entry) {
    _isShowing = true;
    notifyListeners();
  }

  /// 隐藏悬浮窗
  /// 注意：不调用 remove()，由外部管理器负责移除
  void hide() {
    _isShowing = false;
    notifyListeners();
  }

  /// 切换显示/隐藏
  void toggle(OverlayEntry? entry) {
    if (_isShowing) {
      hide();
    } else if (entry != null) {
      show(entry);
    }
  }
}

/// 悬浮窗数据
class FloatingData<T> {
  T? data;
  String? url;
  String? routeName;
  Map<String, dynamic>? extraData;
  OverlayEntry? floatingEntry;
  dynamic floatingOverlayManager;
  bool isShowing; // 是否正在显示
  Widget? bottomButton; // 保存底部按钮 widget（避免重复创建导致 stream 重复订阅）

  FloatingData({
    this.data,
    this.url,
    this.routeName,
    this.extraData,
    this.floatingEntry,
    this.floatingOverlayManager,
    this.isShowing = true,
    this.bottomButton,
  });
}

/// 全局悬浮窗状态管理
///
/// 支持多个悬浮窗并存，用栈式管理
class FloatingState<T> {
  static final Map<Type, dynamic> _instances = {};

  /// 所有悬浮窗数据（key是courseId）
  static final Map<String, FloatingData> _floatingWindows = {};

  /// 当前显示的悬浮窗的courseId
  static String? _currentShowingCourseId;

  /// 获取指定类型的实例
  static FloatingState<T> getInstance<T>() {
    if (!_instances.containsKey(T)) {
      _instances[T] = FloatingState<T>._internal();
    }
    return _instances[T] as FloatingState<T>;
  }

  factory FloatingState() => getInstance<T>();

  FloatingState._internal();

  // ========== 旧的兼容方法（保持向后兼容） ==========

  T? _data;
  String? _currentUrl;
  String? _routeName;
  Map<String, dynamic>? _extraData;
  OverlayEntry? _floatingEntry;
  dynamic _floatingOverlayManager;

  /// 保存数据（兼容旧方法，但内部使用新的存储结构）
  void saveData(
    T data,
    String url, {
    String? routeName,
    Map<String, dynamic>? extraData,
    OverlayEntry? floatingEntry,
    dynamic floatingOverlayManager,
    Widget? bottomButton,
  }) {
    // 从 extraData 中获取 courseId
    final courseId = extraData?['courseId'] as String?;

    print('💾 saveData 调用 - courseId: $courseId, url: $url');

    if (courseId == null) {
      // 旧逻辑：如果没有 courseId，使用单实例模式
      print('💾 使用旧逻辑（单实例模式）');
      _data = data;
      _currentUrl = url;
      _routeName = routeName;
      _extraData = extraData;
      _floatingEntry = floatingEntry;
      _floatingOverlayManager = floatingOverlayManager;
    } else {
      // 新逻辑：使用 Map 存储，支持多个悬浮窗
      print('💾 使用新逻辑（Map模式）- courseId: $courseId');
      _floatingWindows[courseId] = FloatingData(
        data: data,
        url: url,
        routeName: routeName,
        extraData: extraData,
        floatingEntry: floatingEntry,
        floatingOverlayManager: floatingOverlayManager,
        isShowing: true,
        bottomButton: bottomButton,
      );
      _currentShowingCourseId = courseId;
      print('💾 悬浮窗数据已保存 - courseId: $courseId, bottomButton: $bottomButton');
    }
  }

  /// 获取保存的数据
  T? getData() => _data;

  /// 获取当前 URL
  String? getUrl() => _currentUrl;

  /// 获取路由名称
  String? getRouteName() => _routeName;

  /// 获取额外的页面参数
  Map<String, dynamic>? getExtraData() => _extraData;

  /// 获取悬浮窗的 OverlayEntry
  OverlayEntry? getFloatingEntry() => _floatingEntry;

  /// 获取悬浮窗管理器
  dynamic getFloatingOverlayManager() => _floatingOverlayManager;

  /// 关闭悬浮窗（如果正在显示）
  void closeFloatingWindow() {
    if (_floatingEntry != null) {
      if (_floatingOverlayManager != null) {
        _floatingOverlayManager.remove(_floatingEntry!);
      } else {
        _floatingEntry!.remove();
      }
      _floatingEntry = null;
    }
  }

  /// 清除保存的数据（当悬浮窗关闭或页面真正销毁时调用）
  void clearData({bool disposeData = true}) {
    // 🔥 关键：从 extraData 中获取 courseId
    final courseId = _extraData?['courseId'] as String?;

    // 释放 controller（如果需要）
    if (disposeData && _data is ChangeNotifier) {
      (_data as ChangeNotifier).dispose();
    }

    // 清除实例变量
    _data = null;
    _currentUrl = null;
    _routeName = null;
    _extraData = null;
    _floatingEntry = null;
    _floatingOverlayManager = null;

    // 🔥 关键：同时清除 Map 中的数据（重要！）
    if (courseId != null) {
      print('🧹 clearData: 从 Map 中清除悬浮窗数据 - courseId: $courseId');
      _floatingWindows.remove(courseId);
      if (_currentShowingCourseId == courseId) {
        _currentShowingCourseId = null;
      }
    }
  }

  /// 是否有活跃的数据
  bool hasActiveData() => _data != null;

  /// 检查是否有指定 URL 的缓存
  bool hasCachedUrl(String url) => _currentUrl == url && hasActiveData();

  /// 检查缓存是否匹配（同时检查 URL 和页面参数）
  bool hasCachedUrlWithParams(String url, Map<String, dynamic>? extraData) {
    if (_currentUrl != url || !hasActiveData()) {
      return false;
    }

    // 如果提供了 extraData，检查关键参数是否匹配
    if (extraData != null && _extraData != null) {
      // 检查 courseId 是否匹配（如果双方都有）
      if (extraData.containsKey('courseId') && _extraData!.containsKey('courseId')) {
        if (extraData['courseId'] != _extraData!['courseId']) {
          return false;
        }
      }
    }

    return true;
  }

  // ========== 新的多悬浮窗管理方法 ==========

  /// 隐藏当前显示的悬浮窗（但不销毁）
  static void hideCurrentFloating() {
    print('👁️ hideCurrentFloating 调用 - _currentShowingCourseId: $_currentShowingCourseId');
    print('👁️ 所有缓存悬浮窗: ${_floatingWindows.keys.toList()}');
    if (_currentShowingCourseId != null) {
      final data = _floatingWindows[_currentShowingCourseId];
      print('👁️ 找到悬浮窗数据: ${data != null}, isShowing: ${data?.isShowing}');
      print('👁️ data.data (controller): ${data?.data}');
      print('👁️ data.floatingEntry: ${data?.floatingEntry}');
      print('👁️ data.floatingOverlayManager: ${data?.floatingOverlayManager}');

      if (data != null && data.isShowing) {
        // 移除悬浮窗显示（但不销毁数据）
        if (data.floatingEntry != null) {
          if (data.floatingOverlayManager != null) {
            data.floatingOverlayManager.remove(data.floatingEntry!);
            print('👁️ 通过 floatingOverlayManager 移除悬浮窗');
          } else {
            data.floatingEntry!.remove();
            print('👁️ 直接移除悬浮窗');
          }
        }
        data.isShowing = false;
        print('✅ 悬浮窗已【隐藏】- courseId: $_currentShowingCourseId');
        print('✅ 悬浮窗【数据保留】- data.data: ${data.data}');
      } else {
        print('⚠️ 悬浮窗无法隐藏 - data: $data, isShowing: ${data?.isShowing}');
      }
    } else {
      print('⚠️ _currentShowingCourseId 为 null，没有悬浮窗需要隐藏');
    }
  }

  /// 显示指定 courseId 的悬浮窗
  static void showFloating(String courseId) {
    print('📱 showFloating 调用 - courseId: $courseId');
    final data = _floatingWindows[courseId];
    print('📱 找到悬浮窗数据: $data, isShowing: ${data?.isShowing}');
    if (data != null && !data.isShowing) {
      // 重新插入悬浮窗
      if (data.floatingEntry != null) {
        if (data.floatingOverlayManager != null) {
          print('📱 重新插入悬浮窗到 overlay');
          data.floatingOverlayManager.insert(data.floatingEntry!);
        } else {
          // 降级方案：需要全局 context，这里暂时跳过
          print('⚠️ floatingOverlayManager 为 null，无法插入悬浮窗');
        }
      } else {
        print('⚠️ floatingEntry 为 null');
      }
      data.isShowing = true;
      _currentShowingCourseId = courseId;
      print('✅ 悬浮窗已显示 - courseId: $courseId');
    } else {
      print('⚠️ 悬浮窗无法显示 - data: $data, isShowing: ${data?.isShowing}');
    }
  }

  /// 清除指定 courseId 的悬浮窗数据（从 Map 中移除，但不 dispose controller）
  static void clearDataByCourseId(String courseId) {
    print('🧹 clearDataByCourseId: 清除悬浮窗数据 - courseId: $courseId');
    final data = _floatingWindows[courseId];
    print('🧹 找到数据: $data');

    if (data != null) {
      // 移除悬浮窗（如果正在显示）
      if (data.isShowing && data.floatingEntry != null) {
        if (data.floatingOverlayManager != null) {
          data.floatingOverlayManager.remove(data.floatingEntry!);
        } else {
          data.floatingEntry!.remove();
        }
        print('🧹 悬浮窗已移除');
      }

      // 从 Map 中移除（但不 dispose controller，因为页面会使用）
      _floatingWindows.remove(courseId);
      if (_currentShowingCourseId == courseId) {
        _currentShowingCourseId = null;
      }
      print('🧹 已从 Map 中移除 - courseId: $courseId');
      print('🧹 剩余悬浮窗: ${_floatingWindows.keys.toList()}');
    } else {
      print('⚠️ 未找到悬浮窗数据 - courseId: $courseId');
    }
  }

  /// 销毁除指定 courseId 外的所有悬浮窗
  static void destroyAllExcept(String courseId) {
    final List<String> toRemove = [];
    _floatingWindows.forEach((key, data) {
      if (key != courseId) {
        // 移除悬浮窗
        if (data.isShowing && data.floatingEntry != null) {
          if (data.floatingOverlayManager != null) {
            data.floatingOverlayManager.remove(data.floatingEntry!);
          } else {
            data.floatingEntry!.remove();
          }
        }
        // 释放 controller
        if (data.data != null && data.data is ChangeNotifier) {
          (data.data as ChangeNotifier).dispose();
        }
        // 标记需要移除
        toRemove.add(key);
      }
    });

    // 从 Map 中移除
    for (final key in toRemove) {
      _floatingWindows.remove(key);
    }

    // 更新当前显示的悬浮窗
    _currentShowingCourseId = courseId;
  }

  /// 恢复显示上次隐藏的悬浮窗（如果缓存中有悬浮窗数据）
  static void restoreFloating() {
    print('🔄 restoreFloating 调用 - _currentShowingCourseId: $_currentShowingCourseId');
    print('🔄 所有缓存悬浮窗: ${_floatingWindows.keys.toList()}');
    if (_currentShowingCourseId != null) {
      final courseId = _currentShowingCourseId!;
      final data = _floatingWindows[courseId];
      print('🔄 找到悬浮窗数据 - courseId: $courseId');
      print('🔄 data: $data');
      print('🔄 isShowing: ${data?.isShowing}');
      print('🔄 floatingEntry: ${data?.floatingEntry}');
      print('🔄 data (controller): ${data?.data}');

      // 🔥 关键：检查悬浮窗是否真实存在且可用
      // 1. 数据存在
      // 2. 当前未显示
      // 3. floatingEntry 存在（未被销毁）
      // 4. controller 存在（未被释放）
      if (data != null &&
          !data.isShowing &&
          data.floatingEntry != null &&
          data.data != null) {
        print('✅ 悬浮窗真实存在，开始恢复');
        showFloating(courseId);
      } else {
        print('⚠️ 悬浮窗不可恢复，原因：');
        if (data == null) print('  - data 为 null');
        if (data != null && data.isShowing) print('  - 悬浮窗正在显示');
        if (data != null && data.floatingEntry == null) print('  - floatingEntry 为 null（已销毁）');
        if (data != null && data.data == null) print('  - controller 为 null（已释放）');
      }
    } else {
      print('⚠️ _currentShowingCourseId 为 null，无悬浮窗可恢复');
    }
  }

  /// 获取指定 courseId 的数据
  static FloatingData? getFloatingData(String courseId) {
    return _floatingWindows[courseId];
  }
}

/// 悬浮窗配置
class FloatingWidgetConfig {
  /// 悬浮窗内容
  final Widget child;

  /// 悬浮窗宽度
  final double width;

  /// 悬浮窗宽高比（例如：16/9 表示视频，1/1 表示正方形）
  final double aspectRatio;

  /// 圆角半径
  final double? borderRadius;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 阴影颜色
  final Color? shadowColor;

  /// 阴影模糊半径
  final double? shadowBlur;

  /// 阴影偏移
  final Offset? shadowOffset;

  /// 左上角按钮（例如：返回按钮）
  final Widget? leadingButton;

  /// 右上角按钮（例如：关闭按钮）
  final Widget? trailingButton;

  /// 底部中间按钮（例如：播放/暂停按钮）
  final Widget? bottomButton;

  const FloatingWidgetConfig({
    required this.child,
    required this.width,
    required this.aspectRatio,
    this.borderRadius,
    this.backgroundColor,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth,
    this.shadowColor,
    this.shadowBlur,
    this.shadowOffset,
    this.leadingButton,
    this.trailingButton,
    this.bottomButton,
  });

  /// 复制并修改部分属性
  FloatingWidgetConfig copyWith({
    Widget? child,
    double? width,
    double? aspectRatio,
    double? borderRadius,
    Color? backgroundColor,
    bool? showBorder,
    Color? borderColor,
    double? borderWidth,
    Color? shadowColor,
    double? shadowBlur,
    Offset? shadowOffset,
    Widget? leadingButton,
    Widget? trailingButton,
    Widget? bottomButton,
  }) {
    return FloatingWidgetConfig(
      child: child ?? this.child,
      width: width ?? this.width,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      leadingButton: leadingButton ?? this.leadingButton,
      trailingButton: trailingButton ?? this.trailingButton,
      bottomButton: bottomButton ?? this.bottomButton,
    );
  }
}

/// 通用悬浮窗组件
///
/// ## 功能特性
/// - 可拖拽到屏幕任意位置
/// - 可配置宽高比（视频、音频、图片等）
/// - 可自定义内容、按钮
/// - 支持透明背景
///
/// ## 使用示例
/// ```dart
/// // 视频悬浮窗
/// FloatingWidget(
///   controller: _floatingController,
///   config: FloatingWidgetConfig(
///     width: 200,
///     aspectRatio: 16 / 9,
///     child: VideoPlayer(controller),
///     leadingButton: 返回按钮,
///     trailingButton: 关闭按钮,
///     bottomButton: 播放/暂停按钮,
///   ),
///   onClose: () {},
/// )
///
/// // 音频悬浮窗
/// FloatingWidget(
///   controller: _floatingController,
///   config: FloatingWidgetConfig(
///     width: 280,
///     aspectRatio: 1 / 1,  // 正方形封面
///     child: Column([
///       Image.asset('封面'),
///       播放控制栏,
///     ]),
///     leadingButton: 返回按钮,
///     trailingButton: 关闭按钮,
///   ),
///   onClose: () {},
/// )
/// ```
class FloatingWidget extends StatefulWidget {
  /// 悬浮窗控制器
  final FloatingController controller;

  /// 悬浮窗配置
  final FloatingWidgetConfig config;

  /// 关闭悬浮窗回调
  final VoidCallback onClose;

  const FloatingWidget({
    super.key,
    required this.controller,
    required this.config,
    required this.onClose,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> {
  /// 悬浮窗位置（左上角坐标）
  Offset _position = const Offset(16, 100);

  /// 屏幕尺寸
  Size _screenSize = const Size(375, 812); // 默认屏幕尺寸

  @override
  void initState() {
    super.initState();
    // 获取屏幕尺寸（使用 window，不依赖 context）
    _updateScreenSize();
  }

  /// 更新屏幕尺寸（不依赖 context）
  void _updateScreenSize() {
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    final physicalSize = window.physicalSize / window.devicePixelRatio;
    if (mounted) {
      setState(() {
        _screenSize = Size(physicalSize.width, physicalSize.height);
        _clampPosition();
      });
    }
  }

  /// 限制位置在屏幕范围内
  void _clampPosition() {
    final floatingWidth = widget.config.width;
    final floatingHeight = widget.config.width / widget.config.aspectRatio;

    _position = Offset(
      _position.dx.clamp(0.0, _screenSize.width - floatingWidth),
      _position.dy.clamp(0.0, _screenSize.height - floatingHeight),
    );
  }

  /// 处理拖拽更新
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _clampPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final floatingHeight = widget.config.width / widget.config.aspectRatio;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: _onDragUpdate,
          child: Container(
            width: widget.config.width,
            height: floatingHeight,
            decoration: BoxDecoration(
              color: widget.config.backgroundColor,
              borderRadius: BorderRadius.circular(
                widget.config.borderRadius ?? 8,
              ),
              border: widget.config.showBorder
                  ? Border.all(
                      color: widget.config.borderColor ??
                          Colors.white.withValues(alpha: 0.3),
                      width: widget.config.borderWidth ?? 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: widget.config.shadowColor ??
                      Colors.black.withValues(alpha: 0.3),
                  blurRadius: widget.config.shadowBlur ?? 10,
                  offset: widget.config.shadowOffset ?? const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.config.borderRadius ?? 8,
              ),
              child: Stack(
                children: [
                  // 内容区域
                  widget.config.child,

                  // 左上角按钮（如果提供）
                  if (widget.config.leadingButton != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: widget.config.leadingButton!,
                    ),

                  // 右上角按钮（如果提供）
                  if (widget.config.trailingButton != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: widget.config.trailingButton!,
                    ),

                  // 底部中间按钮（如果提供）
                  if (widget.config.bottomButton != null)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(child: widget.config.bottomButton),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示通用悬浮窗
///
/// 在当前页面显示可拖拽的悬浮窗
///
/// ## 参数
/// - context: 上下文
/// - navigatorKey: 全局导航 Key（可选，用于独立 context）
/// - controller: 悬浮窗控制器
/// - config: 悬浮窗配置
/// - onClose: 关闭悬浮窗回调
/// - floatingOverlayManager: 悬浮窗管理器（可选，用于应用级别的悬浮窗）
///
/// ## 使用示例
/// ```dart
/// showFloating(
///   context: context,
///   navigatorKey: navigatorKey,
///   controller: _floatingController,
///   config: FloatingWidgetConfig(
///     width: 200,
///     aspectRatio: 16 / 9,
///     child: VideoPlayer(controller),
///     leadingButton: 返回按钮,
///     trailingButton: 关闭按钮,
///     bottomButton: 播放按钮,
///   ),
///   onClose: () {
///     // 清理资源
///   },
/// );
/// ```
OverlayEntry showFloating({
  required BuildContext context,
  GlobalKey<NavigatorState>? navigatorKey,
  required FloatingController controller,
  required FloatingWidgetConfig config,
  required VoidCallback onClose,
  dynamic floatingOverlayManager,
}) {
  OverlayEntry? overlayEntry;
  bool usingOverlayManager = floatingOverlayManager != null;

  overlayEntry = OverlayEntry(
    builder: (context) => FloatingWidget(
      controller: controller,
      config: config,
      onClose: () {
        // 如果使用管理器，先从管理器中移除悬浮窗
        if (usingOverlayManager && floatingOverlayManager != null) {
          floatingOverlayManager.remove(overlayEntry!);
        } else if (!usingOverlayManager) {
          overlayEntry?.remove();
        }

        // 然后调用外部回调
        onClose();
      },
    ),
  );

  // 如果提供了悬浮窗管理器，使用它（悬浮窗会独立于路由系统）
  if (floatingOverlayManager != null) {
    floatingOverlayManager.insert(overlayEntry);
  } else {
    // 降级方案：使用全局 navigatorKey 的 overlay
    final navigatorState = navigatorKey?.currentState;
    if (navigatorState != null && navigatorState.overlay != null) {
      navigatorState.overlay!.insert(overlayEntry);
    } else {
      // 如果没有提供 navigatorKey，使用当前 context 的 root overlay
      Overlay.of(context, rootOverlay: true).insert(overlayEntry);
    }
  }

  // 通知控制器已显示
  controller.show(overlayEntry);

  return overlayEntry;
}
