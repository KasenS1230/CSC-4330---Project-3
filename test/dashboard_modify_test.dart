import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project3/models/grocery_group.dart';
import 'package:project3/models/roommate.dart';
import 'package:project3/models/grocery_category.dart';
import 'package:project3/screens/dashboard_screen.dart';

void main() {
  GroceryGroup buildGroup() {
    return GroceryGroup(
      id: 'g1',
      name: 'Maple Street Apartment',
      period: Period.weekly,
      roommates: [Roommate(id: 'r1', name: 'Alex')],
      categories: [GroceryCategory(id: 'c1', name: 'Produce')],
    );
  }

  Future<void> pumpDashboard(WidgetTester tester, GroceryGroup group) async {
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(group: group),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Add roommate from DashboardScreen', () {
    testWidgets('adding a roommate shows a new chip with their name',
            (tester) async {
          final group = buildGroup();
          await pumpDashboard(tester, group);

          expect(find.widgetWithText(Chip, 'Alex'), findsOneWidget);
          expect(find.widgetWithText(Chip, 'Sam'), findsNothing);

          await tester.enterText(
            find.widgetWithText(TextField, 'Add roommate'),
            'Sam',
          );
          await tester.tap(find.byKey(const Key('addRoommateButton')));
          await tester.pumpAndSettle();

          expect(find.widgetWithText(Chip, 'Alex'), findsOneWidget);
          expect(find.widgetWithText(Chip, 'Sam'), findsOneWidget);
          expect(group.roommates.map((r) => r.name), containsAll(['Alex', 'Sam']));
        });

    testWidgets('clears the input field after adding a roommate',
            (tester) async {
          final group = buildGroup();
          await pumpDashboard(tester, group);

          await tester.enterText(
            find.widgetWithText(TextField, 'Add roommate'),
            'Sam',
          );
          await tester.tap(find.byKey(const Key('addRoommateButton')));
          await tester.pumpAndSettle();

          final field = tester.widget<TextField>(
            find.widgetWithText(TextField, 'Add roommate'),
          );
          expect(field.controller?.text, isEmpty);
        });

    testWidgets('does not add a roommate when the field is left blank',
            (tester) async {
          final group = buildGroup();
          await pumpDashboard(tester, group);

          final roommateCountBefore = group.roommates.length;

          await tester.tap(find.byKey(const Key('addRoommateButton')));
          await tester.pumpAndSettle();

          expect(group.roommates.length, roommateCountBefore);
        });
  });

  group('Add category from DashboardScreen', () {
    testWidgets('adding a category shows it in the category list',
            (tester) async {
          final group = buildGroup();
          await pumpDashboard(tester, group);

          expect(find.text('Produce'), findsOneWidget);
          expect(find.text('Snacks'), findsNothing);

          await tester.enterText(
            find.widgetWithText(TextField, 'Add category'),
            'Snacks',
          );
          await tester.tap(find.byKey(const Key('addCategoryButton')));
          await tester.pumpAndSettle();

          expect(find.text('Produce'), findsOneWidget);
          expect(find.text('Snacks'), findsOneWidget);
          expect(group.categories.map((c) => c.name), containsAll(['Produce', 'Snacks']));
        });

    testWidgets('a newly added category starts Unassigned', (tester) async {
      final group = buildGroup();
      await pumpDashboard(tester, group);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add category'),
        'Snacks',
      );
      await tester.tap(find.byKey(const Key('addCategoryButton')));
      await tester.pumpAndSettle();

      final snacksCategory = group.categories.firstWhere((c) => c.name == 'Snacks');
      expect(snacksCategory.assignedTo, isNull);
    });

    testWidgets('does not add a category when the field is left blank',
            (tester) async {
          final group = buildGroup();
          await pumpDashboard(tester, group);

          final categoryCountBefore = group.categories.length;

          await tester.tap(find.byKey(const Key('addCategoryButton')));
          await tester.pumpAndSettle();

          expect(group.categories.length, categoryCountBefore);
        });
  });
}