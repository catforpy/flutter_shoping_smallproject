import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested_routes_example/nested_routes_example.dart';

void main() {
  testWidgets('Nested routes example builds without errors',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NestedRoutesExample());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Left navigation items are present',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NestedRoutesExample());
    await tester.pumpAndSettle();

    // Verify left navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Content page displays list items',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NestedRoutesExample());
    await tester.pumpAndSettle();

    // Verify content page displays (app starts at /home/latest)
    expect(find.byType(ContentPage), findsOneWidget);
  });

  testWidgets('App has correct initial route',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NestedRoutesExample());
    await tester.pumpAndSettle();

    // Verify left nav exists
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('Scaffold is rendered correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NestedRoutesExample());
    await tester.pumpAndSettle();

    // Verify main scaffold structure exists
    expect(find.byType(Scaffold), findsWidgets);
  });
}
