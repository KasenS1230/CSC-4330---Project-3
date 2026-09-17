// screens/create_group_screen.dart
import 'package:flutter/material.dart';
import '../models/roommate.dart';
import '../models/grocery_category.dart';
import '../models/grocery_group.dart';
import 'dashboard_screen.dart';
import '../services/group_storage.dart';
import '../models/grocery_category.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final _roommateController = TextEditingController();
  final _categoryController = TextEditingController();

  Period _period = Period.weekly;

  final List<Roommate> _roommates = [];
  final List<GroceryCategory> _categories = [];

  void _addRoommate() {
    if (_roommateController.text.trim().isEmpty) return;
    setState(() {
      _roommates.add(Roommate(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _roommateController.text.trim(),
      ));
      _roommateController.clear();
    });
  }

  void _addCategory() {
    if (_categoryController.text.trim().isEmpty) return;
    setState(() {
      _categories.add(GroceryCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _categoryController.text.trim(),
      ));
      _categoryController.clear();
    });
  }

  void _finishCreatingGroup() async {
    if (_groupNameController.text.trim().isEmpty || _roommates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a group name and at least one roommate')),
      );
      return;
    }

    final group = GroceryGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _groupNameController.text.trim(),
      period: _period,
      roommates: _roommates,
      categories: _categories,
    );

    await GroupStorage.saveGroup(group);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Roommate Group')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            DropdownButton<Period>(
              value: _period,
              items: const [
                DropdownMenuItem(value: Period.weekly, child: Text('Weekly')),
                DropdownMenuItem(value: Period.monthly, child: Text('Monthly')),
              ],
              onChanged: (val) => setState(() => _period = val!),
            ),
            const SizedBox(height: 24),
            const Text('Roommates', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roommateController,
                    decoration: const InputDecoration(labelText: 'Roommate name'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addRoommate),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _roommates.map((r) => Chip(label: Text(r.name))).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Grocery Categories', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'e.g. Produce, Snacks'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addCategory),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _categories.map((c) => Chip(label: Text(c.name))).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _finishCreatingGroup,
              child: const Text('Finish Creating Group'),
            ),
          ],
        ),
      ),
    );
  }
}
