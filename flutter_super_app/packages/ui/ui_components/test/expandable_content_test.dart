library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_components/ui_components.dart';

void main() {
  group('ExpandableContent Tests', () {
    testWidgets('ExpandableContent 组件渲染测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableContent(
              title: '测试标题',
              expandText: '这是一段很长的文本内容，需要展开才能看到全部内容。这里是为了测试可展开内容组件的基本功能。',
            ),
          ),
        ),
      );

      expect(find.byType(ExpandableContent), findsOneWidget);
      expect(find.text('测试标题'), findsOneWidget);
    });

    testWidgets('ExpandableContent 点击展开测试', (tester) async {
      const longText = '这是一段很长的文本内容，需要展开才能看到全部内容。';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableContent(
              title: '商家名称',
              expandText: longText,
            ),
          ),
        ),
      );

      // 初始状态应该显示部分文本
      expect(find.text(longText), findsOneWidget);

      // 点击标题区域展开
      await tester.tap(find.text('商家名称'));
      await tester.pump();

      // 验证图标变化
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('ExpandableContent 自定义信息区域测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableContent(
              title: '商品标题',
              expandText: '商品描述',
              infoWidget: const Text('¥99.00'),
            ),
          ),
        ),
      );

      expect(find.byType(ExpandableContent), findsOneWidget);
      expect(find.text('¥99.00'), findsOneWidget);
    });

    testWidgets('ExpandableContent 自定义图标测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableContent(
              title: '测试标题',
              expandText: '测试内容',
              titleRightWidget: const Icon(Icons.expand_more),
            ),
          ),
        ),
      );

      expect(find.byType(ExpandableContent), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
