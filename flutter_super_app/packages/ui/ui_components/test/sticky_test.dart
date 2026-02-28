library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_components/ui_components.dart';

void main() {
  group('StickyMultiHeaderList Tests', () {
    testWidgets('StickyMultiHeaderList 基础功能测试', (tester) async {
      final sections = [
        const StickySectionModel(key: 'A', title: '分组 A', itemCount: 3),
        const StickySectionModel(key: 'B', title: '分组 B', itemCount: 2),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyMultiHeaderList(
              sections: sections,
              itemBuilder: (context, sectionKey, index) {
                return ListTile(
                  title: Text('Item $sectionKey-$index'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(StickyMultiHeaderList), findsOneWidget);
      expect(find.text('分组 A'), findsOneWidget);
      expect(find.text('分组 B'), findsOneWidget);
      expect(find.text('Item A-0'), findsOneWidget);
      expect(find.text('Item B-0'), findsOneWidget);
    });

    testWidgets('StickyMultiHeaderList 自定义样式测试', (tester) async {
      final sections = [
        const StickySectionModel(key: '1', title: '热门', itemCount: 2),
      ];

      const customStyle = TextStyle(
        fontSize: 18,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyMultiHeaderList(
              sections: sections,
              headerHeight: 50,
              headerBackgroundColor: Colors.blue.shade100,
              headerTextStyle: customStyle,
              itemBuilder: (context, sectionKey, index) {
                return ListTile(title: Text('Item $sectionKey-$index'));
              },
            ),
          ),
        ),
      );

      expect(find.byType(StickyMultiHeaderList), findsOneWidget);
      expect(find.text('热门'), findsOneWidget);
    });

    testWidgets('StickyMultiHeaderList 空分区测试', (tester) async {
      final sections = [
        const StickySectionModel(key: 'A', title: '分组 A', itemCount: 0),
        const StickySectionModel(key: 'B', title: '分组 B', itemCount: 0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyMultiHeaderList(
              sections: sections,
              itemBuilder: (context, sectionKey, index) {
                return ListTile(title: Text('Item $sectionKey-$index'));
              },
            ),
          ),
        ),
      );

      expect(find.byType(StickyMultiHeaderList), findsOneWidget);
      expect(find.text('分组 A'), findsOneWidget);
      expect(find.text('分组 B'), findsOneWidget);
    });
  });

  group('StickyBasicHeader Tests', () {
    testWidgets('StickyBasicHeader 基础功能测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyBasicHeader(
              headerChild: const Text('吸顶标题'),
              sliverChildren: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('Item $index'),
                    ),
                    childCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StickyBasicHeader), findsOneWidget);
      expect(find.text('吸顶标题'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('StickyBasicHeader 自定义样式测试', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyBasicHeader(
              headerHeight: 60,
              backgroundColor: Colors.blue.shade100,
              headerChild: const Text('自定义吸顶'),
              sliverChildren: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('Item $index'),
                    ),
                    childCount: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StickyBasicHeader), findsOneWidget);
      expect(find.text('自定义吸顶'), findsOneWidget);
    });
  });
}
