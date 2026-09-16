// test/dashboard_title_bar_test.dart
//
// Covers the "current date underneath the group name" feature in the
// DashboardScreen's AppBar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project3/models/grocery_group.dart';
import 'package:project3/screens/dashboard_screen.dart';

void main() {
  // Mirrors the month list in DashboardScreen._months so the test can
  // compute the exact label the widget should render, without relying on
  // a fixed/injected clock.
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String expectedTodayLabel() {
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  GroceryGroup buildGroup({String name = 'Maple Street Apartment'}) {
    return GroceryGroup(
      id: 'g1',
      name: name,
      roommates: const [],
      categories: const [],
    );
  }

  Future<void> pumpDashboard(WidgetTester tester, GroceryGroup group) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(group: group),
      ),
    );
  }

  group('DashboardScreen title bar', () {
    testWidgets('shows the group name in the app bar', (tester) async {
      final group = buildGroup(name: 'Maple Street Apartment');
      await pumpDashboard(tester, group);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Maple Street Apartment'),
        ),
        findsOneWidget,
      );
    });

    testWidgets("shows today's date underneath the group name", (tester) async {
      final group = buildGroup();
      await pumpDashboard(tester, group);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(expectedTodayLabel()),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the name above the date, in that order', (tester) async {
      final group = buildGroup();
      await pumpDashboard(tester, group);

      final titleColumn = tester.widget<Column>(
        find
            .descendant(of: find.byType(AppBar), matching: find.byType(Column))
            .first,
      );

      final texts = titleColumn.children.whereType<Text>().map((t) => t.data).toList();

      expect(texts, [group.name, expectedTodayLabel()]);
    });

    testWidgets('updates the app bar title when the group name changes',
        (tester) async {
      final group = buildGroup(name: 'Oak Avenue Flat');
      await pumpDashboard(tester, group);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Oak Avenue Flat'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Maple Street Apartment'),
        ),
        findsNothing,
      );
    });
  });
}
