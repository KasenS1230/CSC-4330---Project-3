// models/roommate.dart
class Roommate {
  final String id;
  final String name;

  Roommate({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Roommate.fromJson(Map<String, dynamic> json) =>
      Roommate(id: json['id'], name: json['name']);
}