// models/grocery_category.dart
class GroceryCategory {
  final String id;
  final String name;       // e.g. "Produce", "Snacks", "Cleaning Supplies"
  String? assignedTo;      // Roommate id, null if unassigned

  GroceryCategory({required this.id, required this.name, this.assignedTo});
}