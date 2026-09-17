class GroceryCategory {
  final String id;
  final String name;
  String? assignedTo;

  GroceryCategory({required this.id, required this.name, this.assignedTo});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'assignedTo': assignedTo};

  factory GroceryCategory.fromJson(Map<String, dynamic> json) => GroceryCategory(
    id: json['id'],
    name: json['name'],
    assignedTo: json['assignedTo'],
  );
}

enum Period { weekly, monthly }