// models/expense.dart
import 'grocery_category.dart'; // for Period

class Expense {
  final String id;
  final String paidBy;
  final String description;
  final double amount;
  final List<String> splitBetween;
  final DateTime date;
  final Period period;

  Expense({
    required this.id,
    required this.paidBy,
    required this.description,
    required this.amount,
    required this.splitBetween,
    required this.date,
    this.period = Period.weekly,
  });

  double get sharePerPerson => amount / splitBetween.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'paidBy': paidBy,
    'description': description,
    'amount': amount,
    'splitBetween': splitBetween,
    'date': date.toIso8601String(),
    'period': period.name,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    paidBy: json['paidBy'],
    description: json['description'],
    amount: (json['amount'] as num).toDouble(),
    splitBetween: List<String>.from(json['splitBetween']),
    date: DateTime.parse(json['date']),
    period: Period.values.byName(json['period'] ?? 'weekly'),
  );
}