// models/expense.dart
class Expense {
  final String id;
  final String paidBy;          // Roommate id
  final String description;
  final double amount;
  final List<String> splitBetween; // Roommate ids sharing this expense
  final DateTime date;

  Expense({
    required this.id,
    required this.paidBy,
    required this.description,
    required this.amount,
    required this.splitBetween,
    required this.date,
  });

  // Each person's share of this expense (even split)
  double get sharePerPerson => amount / splitBetween.length;
}