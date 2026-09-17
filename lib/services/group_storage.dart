// services/group_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_group.dart';

class GroupStorage {
  static const _key = 'grocery_groups';

  static Future<List<GroceryGroup>> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => GroceryGroup.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> saveGroup(GroceryGroup group) async {
    final groups = await loadGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      groups[index] = group;
    } else {
      groups.add(group);
    }
    await _writeAll(groups);
  }

  static Future<void> deleteGroup(String groupId) async {
    final groups = await loadGroups();
    groups.removeWhere((g) => g.id == groupId);
    await _writeAll(groups);
  }

  static Future<void> _writeAll(List<GroceryGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = groups.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}