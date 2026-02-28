import 'package:flutter_test/flutter_test.dart';

import 'package:core_media_example/main.dart';

void main() {
  testWidgets('Media test app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify app title is displayed.
    expect(find.text('Core Media 测试'), findsOneWidget);

    // Verify test sections are displayed.
    expect(find.text('1. 网络图片加载'), findsOneWidget);
    expect(find.text('2. 圆形头像'), findsOneWidget);
    expect(find.text('3. MediaUtils 工具类'), findsOneWidget);
  });
}
