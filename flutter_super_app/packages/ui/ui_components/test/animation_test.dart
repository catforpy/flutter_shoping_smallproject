library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_components/ui_components.dart';

void main() {
  group('ControlledAnimation Tests', () {
    testWidgets('播放模式枚举值正确', (tester) async {
      // 验证所有播放模式都有正确的值
      expect(Playback.pause.index, 0);
      expect(Playback.playForward.index, 1);
      expect(Playback.playReverse.index, 2);
      expect(Playback.startOverForward.index, 3);
      expect(Playback.startOverReverse.index, 4);
      expect(Playback.loop.index, 5);
      expect(Playback.mirror.index, 6);
    });

    testWidgets('ControlledAnimation 基础功能测试', (tester) async {
      final tween = Tween<double>(begin: 0.0, end: 1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlledAnimation<double>(
              playback: Playback.playForward,
              duration: const Duration(milliseconds: 100),
              tween: tween,
              builder: (context, value) {
                return Text('Value: ${value.toStringAsFixed(2)}');
              },
            ),
          ),
        ),
      );

      // 初始状态
      expect(find.text('Value: 0.00'), findsOneWidget);

      // 动画播放到一半
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Value: 0.50'), findsOneWidget);

      // 动画完成
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Value: 1.00'), findsOneWidget);
    });

    testWidgets('MultiTrackTween 多轨道动画测试', (tester) async {
      final tween = MultiTrackTween([
        Track('opacity')
            .add(const Duration(milliseconds: 200), Tween(begin: 0.0, end: 1.0)),
        Track('width')
            .add(const Duration(milliseconds: 200), Tween(begin: 50.0, end: 100.0)),
      ]);

      expect(tween.duration, const Duration(milliseconds: 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlledAnimation(
              playback: Playback.playForward,
              duration: tween.duration,
              tween: tween,
              builder: (context, animation) {
                return SizedBox(
                  width: animation['width'] as double,
                  child: Opacity(
                    opacity: animation['opacity'] as double,
                    child: const Text('Test'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // 初始状态
      expect(find.byType(SizedBox), findsOneWidget);

      // 动画播放到一半
      await tester.pump(const Duration(milliseconds: 100));

      // 验证动画在运行
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, greaterThan(50.0));
      expect(sizedBox.width, lessThan(100.0));
    });

    testWidgets('builderWithChild 性能优化模式测试', (tester) async {
      final child = Container(key: const Key('test_child'), width: 100, height: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlledAnimation<double>(
              playback: Playback.playForward,
              duration: const Duration(milliseconds: 100),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builderWithChild: (context, child, value) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: child,
            ),
          ),
        ),
      );

      // 验证子组件被正确传递
      expect(find.byKey(const Key('test_child')), findsOneWidget);

      // 验证初始透明度
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.0);

      // 验证动画播放
      await tester.pump(const Duration(milliseconds: 50));
      final updatedOpacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(updatedOpacity.opacity, greaterThan(0.0));
      expect(updatedOpacity.opacity, lessThan(1.0));
    });
  });
}
