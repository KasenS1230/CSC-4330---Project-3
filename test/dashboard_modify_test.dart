import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project3/models/grocery_group.dart';
import 'package:project3/models/roommate.dart';
import 'package:project3/models/grocery_category.dart';
import 'package:project3/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen shows the group name and its roommates', (tester) async {
    final group = GroceryGroup(
      id: 'g1',
      name: 'Maple Street Apartment',
      period: Period.weekly,
      roommates: [Roommate(id: 'r1', name: 'Alex')],
      categories: [GroceryCategory(id: 'c1', name: 'Produce')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(group: group),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maple Street Apartment'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Alex'), findsOneWidget);
  });
}