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
}