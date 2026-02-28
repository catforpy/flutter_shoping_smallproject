import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_ui/core_ui.dart';

void main() {
  group('AppButton', () {
    testWidgets('should render primary button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render secondary button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Secondary',
              type: AppButtonType.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('should render outline button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Outline',
              type: AppButtonType.outline,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render text button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Text Button',
              type: AppButtonType.text,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should render danger button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Delete',
              type: AppButtonType.danger,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should render loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render disabled button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppButton(
              text: 'Disabled',
            ),
          ),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, false);
    });

    testWidgets('should render button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'With Icon',
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });
  });

  group('AppLoading', () {
    testWidgets('should render circular loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppLoading(
              type: AppLoadingType.circular,
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render linear loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppLoading(
              type: AppLoadingType.linear,
            ),
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should render dots loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppLoading(
              type: AppLoadingType.dots,
            ),
          ),
        ),
      );
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render loading with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppLoading(
              message: 'Loading...',
            ),
          ),
        ),
      );
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('should render elevated card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              style: AppCardStyle.elevated,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should render outlined card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              style: AppCardStyle.outlined,
              child: const Text('Outlined Card'),
            ),
          ),
        ),
      );
      expect(find.text('Outlined Card'), findsOneWidget);
    });

    testWidgets('should render filled card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              style: AppCardStyle.filled,
              child: const Text('Filled Card'),
            ),
          ),
        ),
      );
      expect(find.text('Filled Card'), findsOneWidget);
    });

    testWidgets('should handle tap gesture', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });
  });

  group('AppEmpty', () {
    testWidgets('should render empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppEmpty(
              message: 'No data found',
            ),
          ),
        ),
      );
      expect(find.text('No data found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should render empty state with custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppEmpty(
              message: 'Custom Icon',
              icon: Icons.search,
            ),
          ),
        ),
      );
      expect(find.text('Custom Icon'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should render empty state with action', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty(
              message: 'Empty',
              actionText: 'Reload',
              onActionPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
    });
  });

  group('AppError', () {
    testWidgets('should render error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppError(
              message: 'Something went wrong',
            ),
          ),
        ),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render error state with retry', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppError(
              message: 'Error',
              onRetryPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });
  });

  group('AppListTile', () {
    testWidgets('should render navigation tile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              title: 'Settings',
              subtitle: 'Manage your preferences',
              leading: const Icon(Icons.settings),
            ),
          ),
        ),
      );
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage your preferences'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should render list tile with leading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              leading: const Icon(Icons.person),
              title: 'John Doe',
              subtitle: 'Software Engineer',
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);
    });

    testWidgets('should handle tap gesture', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              title: 'Tappable',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });

    testWidgets('should render toggle tile', (WidgetTester tester) async {
      bool toggleValue = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              title: 'Notifications',
              subtitle: 'Enable push notifications',
              type: AppListTileType.toggle,
              value: toggleValue,
              onChanged: (value) => toggleValue = value ?? false,
            ),
          ),
        ),
      );
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should render checkbox tile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListTile(
              title: 'Accept Terms',
              type: AppListTileType.checkbox,
              value: false,
              onChanged: (value) {},
            ),
          ),
        ),
      );
      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('AppTheme', () {
    test('should have primary color', () {
      expect(AppTheme.primaryColor, const Color(0xFF2196F3));
    });

    test('should have success color', () {
      expect(AppTheme.successColor, const Color(0xFF43A047));
    });

    test('should have warning color', () {
      expect(AppTheme.warningColor, const Color(0xFFFFB300));
    });

    test('should have radius constants', () {
      expect(AppTheme.radiusSmall, 4.0);
      expect(AppTheme.radiusMedium, 8.0);
      expect(AppTheme.radiusLarge, 12.0);
    });

    test('should have padding constants', () {
      expect(AppTheme.paddingSmall, 8.0);
      expect(AppTheme.paddingMedium, 16.0);
      expect(AppTheme.paddingLarge, 24.0);
    });
  });

  group('Widget Extensions', () {
    testWidgets('should add padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').padding(EdgeInsets.all(16)),
          ),
        ),
      );
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('should add margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').margin(EdgeInsets.all(16)),
          ),
        ),
      );
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should add center', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').center(),
          ),
        ),
      );
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should add expand', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const Text('Test').expand(),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('should add size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').size(100, 50),
          ),
        ),
      );
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 100);
      expect(sizedBox.height, 50);
    });
  });

  group('Color Extensions', () {
    test('should darken color', () {
      const color = Color(0xFF2196F3);
      final darkened = color.darken(0.1);
      expect(darkened, isNot(color));
    });

    test('should lighten color', () {
      const color = Color(0xFF2196F3);
      final lightened = color.lighten(0.1);
      expect(lightened, isNot(color));
    });

    test('should set opacity', () {
      const color = Color(0xFF2196F3);
      final withOpacity = color.withValues(alpha: 0.5);
      expect(withOpacity.a, lessThan(255));
    });
  });

  group('TimeOfDay Extensions', () {
    test('should convert to minutes', () {
      const time = TimeOfDay(hour: 1, minute: 30);
      expect(time.toMinutes(), 90);
    });

    test('should create from minutes', () {
      final time = TimeOfDayExtension.fromMinutes(90);
      expect(time.hour, 1);
      expect(time.minute, 30);
    });

    test('should compare times', () {
      const time1 = TimeOfDay(hour: 10, minute: 0);
      const time2 = TimeOfDay(hour: 12, minute: 0);
      expect(time1.isBefore(time2), true);
      expect(time2.isAfter(time1), true);
    });
  });
}
