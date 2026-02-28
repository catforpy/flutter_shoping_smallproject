library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_components/ui_components.dart';

void main() {
  group('Animation Components Simple Tests', () {
    testWidgets('ShakeAnimation 组件渲染测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShakeAnimation(
              shakeIntensity: 10.0,
              child: const Text('Shake me'),
            ),
          ),
        ),
      );

      // 验证组件正常渲染
      expect(find.byType(ShakeAnimation), findsOneWidget);
      expect(find.text('Shake me'), findsOneWidget);
    });

    testWidgets('NumberRollingAnimation 组件渲染测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const NumberRollingAnimation(
              targetNumber: 100,
              duration: Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      // 验证组件正常渲染
      expect(find.byType(NumberRollingAnimation), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      // 初始显示 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('FadeAnimation 组件渲染测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FadeAnimation(
              delay: 0,
              child: const Text('Fade In'),
            ),
          ),
        ),
      );

      // 验证组件正常渲染
      expect(find.byType(FadeAnimation), findsOneWidget);
      expect(find.text('Fade In'), findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('NumberRollingAnimation 显示目标数字', (tester) async {
      const targetNumber = 50;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const NumberRollingAnimation(
              targetNumber: targetNumber,
              duration: Duration(milliseconds: 200),
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pump(const Duration(milliseconds: 250));

      // 验证显示目标数字
      expect(find.text('$targetNumber'), findsOneWidget);
    });

    testWidgets('FadeAnimation 完成后不透明', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FadeAnimation(
              delay: 0,
              child: const Text('Fade In'),
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pump(const Duration(milliseconds: 600));

      // 验证不透明度为 1
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });
  });
}
