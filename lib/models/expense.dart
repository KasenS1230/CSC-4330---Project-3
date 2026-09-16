// models/expense.dart

// Moved here from grocery_category.dart: period is now a property of each
// expense, not the group as a whole.
enum Period { weekly, monthly }

class Expense {
  final String id;
  final String paidBy;          // Roommate id
  final String description;
  final double amount;
  final List<String> splitBetween; // Roommate ids sharing this expense
  final DateTime date;
  final Period period;          // Whether this expense counts as weekly or monthly

  Expense({
    required this.id,
    required this.paidBy,
    required this.description,
    required this.amount,
    required this.splitBetween,
    required this.date,
    required this.period,
  });

  // Each person's share of this expense (even split)
  double get sharePerPerson => amount / splitBetween.length;
}