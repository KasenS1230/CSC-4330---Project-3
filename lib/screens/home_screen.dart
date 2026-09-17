// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/grocery_group.dart';
import '../services/group_storage.dart';
import 'create_group_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryGroup> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await GroupStorage.loadGroups();
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  Future<void> _deleteGroup(GroceryGroup group) async {
    await GroupStorage.deleteGroup(group.id);
    _loadGroups();
  }

  Future<void> _openGroup(GroceryGroup group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen(group: group)),
    );
    _loadGroups(); // refresh in case it changed or was deleted from inside
  }

  Future<void> _createGroup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_groups.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_basket, size: 96),
                const SizedBox(height: 24),
                const Text(
                  'Split grocery costs\nwith your roommates',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Create Roommate Group'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Groups')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return Dismissible(
            key: ValueKey(group.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete group?'),
                content: Text('This will permanently delete "${group.name}" and all its data.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            onDismissed: (_) => _deleteGroup(group),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.groups_rounded),
                title: Text(group.name),
                subtitle: Text('${group.roommates.length} roommates · ${group.expenses.length} expenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openGroup(group),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGroup,
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }
}