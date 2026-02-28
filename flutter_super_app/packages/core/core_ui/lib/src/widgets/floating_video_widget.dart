import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:core_media/core_media.dart';

/// 视频悬浮窗控制器
///
/// 用于控制悬浮窗的显示、隐藏和状态
class FloatingVideoController extends ChangeNotifier {
  OverlayEntry? _overlayEntry;
  bool _isShowing = false;

  /// 是否正在显示
  bool get isShowing => _isShowing;

  /// 显示悬浮窗
  void show(OverlayEntry entry) {
    _overlayEntry = entry;
    _isShowing = true;
    notifyListeners();
  }

  /// 隐藏悬浮窗
  /// 注意：不调用 remove()，由外部管理器负责移除
  void hide() {
    _overlayEntry = null;
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

/// 全局悬浮窗状态管理
///
/// 用于在页面关闭后保持悬浮窗和视频控制器的引用
class FloatingVideoState {
  static final FloatingVideoState _instance = FloatingVideoState._internal();
  factory FloatingVideoState() => _instance;
  FloatingVideoState._internal();

  AppVideoPlayerController? _videoController;
  String? _currentVideoUrl;
  FloatingVideoController? _floatingController;
  OverlayEntry? _overlayEntry;
  dynamic _floatingOverlayManager;

  /// 保存视频控制器（当页面关闭时调用）
  void saveController(AppVideoPlayerController controller, String videoUrl) {
    _videoController = controller;
    _currentVideoUrl = videoUrl;
  }

  /// 保存悬浮窗信息（当显示悬浮窗时调用）
  void saveFloatingInfo({
    required FloatingVideoController floatingController,
    required OverlayEntry overlayEntry,
    required dynamic floatingOverlayManager,
  }) {
    _floatingController = floatingController;
    _overlayEntry = overlayEntry;
    _floatingOverlayManager = floatingOverlayManager;
  }

  /// 获取保存的控制器
  AppVideoPlayerController? getController() => _videoController;

  /// 获取当前视频 URL
  String? getVideoUrl() => _currentVideoUrl;

  /// 隐藏当前悬浮窗（当进入课程播放页时调用）
  void hideCurrentFloating() {
    if (_overlayEntry != null && _floatingOverlayManager != null) {
      _floatingOverlayManager.remove(_overlayEntry!);
      _overlayEntry = null;
      _floatingController?.hide();
    }
  }

  /// 显示之前保存的悬浮窗
  void showSavedFloating() {
    // 重新显示悬浮窗的逻辑
    // 暂时不需要实现，因为悬浮窗通过 onBack 回调重新打开页面
  }

  /// 清除悬浮窗信息（不包括 controller）
  void clearFloatingInfo() {
    _floatingController = null;
    _overlayEntry = null;
    _floatingOverlayManager = null;
  }

  /// 清除保存的控制器（当悬浮窗关闭时调用）
  /// disposeController: 是否释放控制器（默认 true，如果已经在别处释放了，传入 false）
  void clearController({bool disposeController = true}) {
    if (disposeController) {
      _videoController?.dispose();
    }
    _videoController = null;
    _currentVideoUrl = null;
    _floatingController = null;
    _overlayEntry = null;
    _floatingOverlayManager = null;
  }

  /// 是否有活跃的控制器
  bool hasActiveController() => _videoController != null;

  /// 是否有正在显示的悬浮窗
  bool hasActiveFloating() => _overlayEntry != null;
}

/// 视频悬浮窗
///
/// ## 功能特性
/// - 16:9 固定宽高比
/// - 可拖拽到屏幕任意位置
/// - 左上角：返回原页面按钮
/// - 右上角：关闭按钮
/// - 底部中间：播放/暂停按钮
/// - 支持透明背景
///
/// ## 使用示例
/// ```dart
/// // 1. 创建控制器
/// final _floatingController = FloatingVideoController();
///
/// // 2. 显示悬浮窗
/// showFloatingVideo(
///   context: context,
///   controller: _videoController,
///   floatingController: _floatingController,
///   onBack: () {
///     // 返回原页面逻辑
///     Navigator.pop(context);
///   },
/// );
/// ```
class FloatingVideoWidget extends StatefulWidget {
  /// 视频控制器
  final AppVideoPlayerController videoController;

  /// 悬浮窗控制器
  final FloatingVideoController floatingController;

  /// 返回原页面回调
  final VoidCallback onBack;

  /// 关闭悬浮窗回调
  final VoidCallback onClose;

  /// 悬浮窗宽度（默认 200）
  final double width;

  /// 悬浮窗背景颜色
  final Color backgroundColor;

  /// 按钮颜色
  final Color buttonColor;

  /// 是否显示边框
  final bool showBorder;

  /// 是否自动释放视频控制器（默认 true）
  final bool autoDispose;

  const FloatingVideoWidget({
    super.key,
    required this.videoController,
    required this.floatingController,
    required this.onBack,
    required this.onClose,
    this.width = 200,
    this.backgroundColor = Colors.black,
    this.buttonColor = Colors.white,
    this.showBorder = true,
    this.autoDispose = true,
  });

  @override
  State<FloatingVideoWidget> createState() => _FloatingVideoWidgetState();
}

class _FloatingVideoWidgetState extends State<FloatingVideoWidget> {
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

  @override
  void dispose() {
    // 如果设置了自动释放，则释放视频控制器
    if (widget.autoDispose) {
      widget.videoController.dispose();
    }
    super.dispose();
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
    final floatingWidth = widget.width;
    final floatingHeight = widget.width * 9 / 16; // 16:9

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
    final floatingHeight = widget.width * 9 / 16; // 16:9

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: _onDragUpdate,
          child: Container(
            width: widget.width,
            height: floatingHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: widget.showBorder
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // 视频播放器（使用原生 VideoPlayer）
                  VideoPlayer(widget.videoController.controller),

                  // 顶部控制栏
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 返回按钮
                            _buildControlButton(
                              icon: Icons.arrow_back,
                              onTap: widget.onBack,
                            ),
                            // 关闭按钮
                            _buildControlButton(
                              icon: Icons.close,
                              onTap: widget.onClose,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 底部播放/暂停按钮
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildPlayPauseButton(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: widget.buttonColor,
          size: 18,
        ),
      ),
    );
  }

  /// 构建播放/暂停按钮
  Widget _buildPlayPauseButton() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        final isPlaying = widget.videoController.isPlaying;

        return InkWell(
          onTap: () {
            if (isPlaying) {
              widget.videoController.pause();
            } else {
              widget.videoController.play();
            }
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.buttonColor,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

/// 显示视频悬浮窗
///
/// 在当前页面显示可拖拽的视频悬浮窗
///
/// ## 画中画模式说明
/// - 点击悬浮按钮后，当前页面应自动关闭（Navigator.pop）
/// - 悬浮窗接管视频控制器的所有权
/// - 点击返回按钮可重新打开播放页面
/// - 点击关闭按钮则完全停止播放并释放资源
///
/// ## 参数
/// - context: 上下文
/// - navigatorKey: 全局导航 Key（可选，用于独立 context）
/// - controller: 视频播放器控制器
/// - floatingController: 悬浮窗控制器
/// - onBack: 返回原页面回调（用于重新打开播放页面）
/// - onClose: 关闭悬浮窗回调
/// - width: 悬浮窗宽度（默认 200）
/// - autoDispose: 是否自动释放视频控制器（默认 false）
///
/// ## 使用示例
/// ```dart
/// // 画中画模式：显示悬浮窗后自动关闭当前页面
/// showFloatingVideo(
///   context: context,
///   navigatorKey: navigatorKey, // 传入全局 key
///   controller: _videoController,
///   floatingController: _floatingController,
///   onBack: () {
///     // 重新打开播放页面
///     Navigator.push(
///       navigatorKey.currentContext!,
///       MaterialPageRoute(
///         builder: (_) => FreeCoursePlayPage(
///           videoUrl: _videoUrl,
///           title: _title,
///           coverImage: _coverImage,
///           restoreController: _videoController,
///         ),
///       ),
///     );
///   },
///   onClose: () {
///     _videoController.dispose();
///   },
///   autoDispose: false,
/// );
/// ```
OverlayEntry showFloatingVideo({
  required BuildContext context,
  GlobalKey<NavigatorState>? navigatorKey,
  required AppVideoPlayerController controller,
  required FloatingVideoController floatingController,
  required VoidCallback onBack,
  required VoidCallback onClose,
  double width = 200,
  bool autoDispose = false,
  // 悬浮窗管理器（可选，用于应用级别的悬浮窗）
  dynamic floatingOverlayManager,
}) {
  OverlayEntry? overlayEntry;
  bool usingOverlayManager = floatingOverlayManager != null;

  overlayEntry = OverlayEntry(
    builder: (context) => FloatingVideoWidget(
      videoController: controller,
      floatingController: floatingController,
      onBack: onBack,
      onClose: () {
        // 如果使用管理器，先从管理器中移除悬浮窗
        // 这样 Flutter 会销毁 FloatingVideoWidget，确保它不再使用 controller
        if (usingOverlayManager && floatingOverlayManager != null) {
          floatingOverlayManager.remove(overlayEntry!);
        } else if (!usingOverlayManager) {
          overlayEntry?.remove();
        }

        // 清理全局状态中的悬浮窗信息（不包括 controller）
        FloatingVideoState().clearFloatingInfo();

        // 然后调用外部回调（会在 post-frame-callback 中释放 controller）
        // 此时悬浮窗 widget 已经被移除，不会再访问 controller
        onClose();
      },
      width: width,
      autoDispose: autoDispose,
    ),
  );

  // 如果提供了悬浮窗管理器，使用它（悬浮窗会独立于路由系统）
  if (floatingOverlayManager != null) {
    floatingOverlayManager.insert(overlayEntry);
  } else {
    // 降级方案：使用全局 navigatorKey 的 overlay
    // Navigator 的 overlay 独立于具体页面，会在路由变化时保持存在
    final navigatorState = navigatorKey?.currentState;
    if (navigatorState != null && navigatorState.overlay != null) {
      navigatorState.overlay!.insert(overlayEntry);
    } else {
      // 如果没有提供 navigatorKey，使用当前 context 的 root overlay
      Overlay.of(context, rootOverlay: true).insert(overlayEntry);
    }
  }

  // 通知控制器已显示
  floatingController.show(overlayEntry);

  // 保存悬浮窗信息到全局状态（用于后续管理）
  FloatingVideoState().saveFloatingInfo(
    floatingController: floatingController,
    overlayEntry: overlayEntry,
    floatingOverlayManager: floatingOverlayManager,
  );

  return overlayEntry;
}
