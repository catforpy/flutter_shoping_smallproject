library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_components/ui_components.dart';

void main() {
  group('Animation Components Tests', () {
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

      expect(find.byType(NumberRollingAnimation), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
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

      expect(find.byType(FadeAnimation), findsOneWidget);
      expect(find.text('Fade In'), findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('所有动画组件可以共存', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShakeAnimation(
                  shakeIntensity: 5.0,
                  child: const Text('Shake'),
                ),
                const NumberRollingAnimation(
                  targetNumber: 50,
                  duration: Duration(milliseconds: 100),
                ),
                FadeAnimation(
                  delay: 0,
                  child: const Text('Fade'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShakeAnimation), findsOneWidget);
      expect(find.byType(NumberRollingAnimation), findsOneWidget);
      expect(find.byType(FadeAnimation), findsOneWidget);
    });
  });
}
