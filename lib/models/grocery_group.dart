// models/grocery_group.dart
import 'roommate.dart';
import 'grocery_category.dart';
import 'expense.dart';

class GroceryGroup {
  final String id;
  final String name;
  final Period period;
  final List<Roommate> roommates;
  final List<GroceryCategory> categories;
  final List<Expense> expenses;

  GroceryGroup({
    required this.id,
    required this.name,
    required this.period,
    required this.roommates,
    required this.categories,
    List<Expense>? expenses,
  }) : expenses = expenses ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'period': period.name,
    'roommates': roommates.map((r) => r.toJson()).toList(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
  };

  factory GroceryGroup.fromJson(Map<String, dynamic> json) => GroceryGroup(
    id: json['id'],
    name: json['name'],
    period: Period.values.byName(json['period']),
    roommates: (json['roommates'] as List).map((r) => Roommate.fromJson(r)).toList(),
    categories: (json['categories'] as List).map((c) => GroceryCategory.fromJson(c)).toList(),
    expenses: (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
  );
}