library;

import 'dart:math';
import 'package:flutter/widgets.dart';

/// 多轨道动画 Tween
///
/// 允许同时控制多个属性的动画
class MultiTrackTween extends Animatable<Map<String, dynamic>> {
  final Map<String, _TweenData> _tracksToTween = {};
  late int _maxDuration;

  /// 构造多轨道动画
  MultiTrackTween(List<Track> tracks)
      : assert(
          tracks.isNotEmpty,
          'Add a List<Track> to configure the tween.',
        ) {
    _computeMaxDuration(tracks);
    _computeTrackTweens(tracks);
  }

  /// 计算最大时长
  void _computeMaxDuration(List<Track> tracks) {
    _maxDuration = 0;
    for (final track in tracks) {
      final trackDuration = track.items
          .map((item) => item.duration.inMilliseconds)
          .fold(0, (sum, item) => sum + item);
      _maxDuration = max(_maxDuration, trackDuration);
    }
  }

  /// 计算每个轨道的 Tween
  void _computeTrackTweens(List<Track> tracks) {
    for (final track in tracks) {
      final trackDuration = track.items
          .map((item) => item.duration.inMilliseconds)
          .fold(0, (sum, item) => sum + item);

      // 构建序列动画
      final sequenceItems = track.items
          .map((item) => TweenSequenceItem(
                tween: item.tween!,
                weight: item.duration.inMilliseconds / _maxDuration,
              ))
          .toList();

      // 如果轨道时长小于最大时长，添加空白占位
      if (trackDuration < _maxDuration) {
        sequenceItems.add(
          TweenSequenceItem(
            tween: ConstantTween<dynamic>(null),
            weight: (_maxDuration - trackDuration) / _maxDuration,
          ),
        );
      }

      final sequence = TweenSequence(sequenceItems);

      _tracksToTween[track.name] = _TweenData(
        tween: sequence,
        maxTime: trackDuration / _maxDuration,
      );
    }
  }

  /// 获取动画总时长
  Duration get duration => Duration(milliseconds: _maxDuration);

  @override
  Map<String, dynamic> transform(double t) {
    final result = <String, dynamic>{};

    _tracksToTween.forEach((name, tweenData) {
      // 限制时间范围
      final tTween = max(0.0, min(t, tweenData.maxTime - 0.0001));
      result[name] = tweenData.tween.transform(tTween);
    });

    return result;
  }
}

/// 动画轨道
class Track<T> {
  final String name;
  final List<_TrackItem<T>> items = [];

  Track(this.name) : assert(name.isNotEmpty, 'Track name must not be empty.');

  /// 添加一段动画
  Track<T> add(Duration duration, Animatable<T> tween, {Curve? curve}) {
    items.add(_TrackItem<T>(duration, tween, curve: curve));
    return this;
  }
}

/// 轨道项
class _TrackItem<T> {
  final Duration duration;
  late final Animatable<T>? tween;

  _TrackItem(this.duration, Animatable<T>? tween, {Curve? curve}) {
    if (curve != null && tween != null) {
      this.tween = tween.chain(CurveTween(curve: curve));
    } else {
      this.tween = tween;
    }
  }
}

/// Tween 数据
class _TweenData<T> {
  final Animatable<T> tween;
  final double maxTime;

  _TweenData({required this.tween, required this.maxTime});
}
