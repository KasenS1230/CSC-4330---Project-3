// test/expense_period_test.dart
//
// Covers the "each expense can be weekly or monthly" feature:
//   1. The Expense model stores whichever Period it's constructed with.
//   2. AddExpenseDialog defaults to Weekly and correctly passes Monthly
//      through to the Expense it creates when the user picks it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project3/models/roommate.dart';
import 'package:project3/models/expense.dart';
import 'package:project3/widgets/add_expense_dialog.dart';

void main() {
  group('Expense.period', () {
    test('stores Period.weekly when constructed with it', () {
      final expense = Expense(
        id: '1',
        paidBy: 'r1',
        description: 'Milk',
        amount: 4.50,
        splitBetween: ['r1', 'r2'],
        date: DateTime(2026, 1, 1),
        period: Period.weekly,
      );

      expect(expense.period, Period.weekly);
    });

    test('stores Period.monthly when constructed with it', () {
      final expense = Expense(
        id: '2',
        paidBy: 'r2',
        description: 'Paper towels',
        amount: 12.00,
        splitBetween: ['r1', 'r2'],
        date: DateTime(2026, 1, 1),
        period: Period.monthly,
      );

      expect(expense.period, Period.monthly);
    });
  });

  group('AddExpenseDialog period selection', () {
    final roommates = [
      Roommate(id: 'r1', name: 'Alex'),
      Roommate(id: 'r2', name: 'Sam'),
    ];

    // Pumps a screen with a button that opens AddExpenseDialog, then taps it.
    Future<void> pumpDialog(
      WidgetTester tester, {
      required void Function(Expense) onAdd,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddExpenseDialog(
                    roommates: roommates,
                    onAdd: onAdd,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    Future<void> fillRequiredFields(WidgetTester tester) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'What did you buy?'),
        'Eggs',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount (\$)'),
        '3.00',
      );

      // Choose who paid (first DropdownButton in the dialog).
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alex').last);
      await tester.pumpAndSettle();
    }

    testWidgets('defaults to Weekly when the period is left untouched',
        (tester) async {
      Expense? addedExpense;
      await pumpDialog(tester, onAdd: (e) => addedExpense = e);
      await fillRequiredFields(tester);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(addedExpense, isNotNull);
      expect(addedExpense!.period, Period.weekly);
    });

    testWidgets('submits Monthly when selected from the period dropdown',
        (tester) async {
      Expense? addedExpense;
      await pumpDialog(tester, onAdd: (e) => addedExpense = e);
      await fillRequiredFields(tester);

      // Open the period dropdown and pick Monthly.
      await tester.tap(find.byType(DropdownButton<Period>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(addedExpense, isNotNull);
      expect(addedExpense!.period, Period.monthly);
    });

    testWidgets('does not submit if required fields are missing',
        (tester) async {
      Expense? addedExpense;
      await pumpDialog(tester, onAdd: (e) => addedExpense = e);

      // Switch to Monthly but leave description/amount/payer empty.
      await tester.tap(find.byType(DropdownButton<Period>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(addedExpense, isNull);
      expect(find.text('Fill out all fields'), findsOneWidget);
    });
  });
}
