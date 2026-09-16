// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/grocery_group.dart';
import '../models/roommate.dart';
import '../models/grocery_category.dart';
import '../models/expense.dart';
import '../utils/balance_calculator.dart';
import '../widgets/add_expense_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final GroceryGroup group;

  const DashboardScreen({super.key, required this.group});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _newCategoryController = TextEditingController();
  final _newRoommateController = TextEditingController();

  // Add this widget-building method inside _DashboardScreenState
  Widget _buildBalancesSection() {
    final balances = BalanceCalculator.calculateNetBalances(
      widget.group.roommates,
      widget.group.expenses,
    );
    final debts = BalanceCalculator.simplifyDebts(balances);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Balances', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (debts.isEmpty)
          const Text('Everyone is settled up!')
        else
          ...debts.map((debt) {
            final fromName = _roommateName(debt.fromId);
            final toName = _roommateName(debt.toId);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$fromName owes $toName \$${debt.amount.toStringAsFixed(2)}'),
            );
          }),
      ],
    );
  }

  // Designated place for per-expense period: each logged expense now shows
  // whether it counts as a weekly or monthly expense.
  Widget _buildExpensesSection() {
    final expenses = widget.group.expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (expenses.isEmpty)
          const Text('No expenses logged yet.')
        else
          ...expenses.map((expense) {
            final periodLabel = expense.period == Period.weekly ? 'Weekly' : 'Monthly';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(expense.description),
                subtitle: Text('Paid by ${_roommateName(expense.paidBy)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${expense.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 4, width: 8),
                    Chip(
                      label: Text(periodLabel, style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _openAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (_) => AddExpenseDialog(
        roommates: widget.group.roommates,
        onAdd: (expense) {
          setState(() {
            widget.group.expenses.add(expense);
          });
        },
      ),
    );
  }

  void _assignCategory(GroceryCategory category, Roommate? roommate) {
    setState(() {
      category.assignedTo = roommate?.id;
    });
  }

  void _addCategory() {
    if (_newCategoryController.text.trim().isEmpty) return;
    setState(() {
      widget.group.categories.add(
        GroceryCategory(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _newCategoryController.text.trim(),
        ),
      );
      _newCategoryController.clear();
    });
  }

  void _addRoommate() {
    if (_newRoommateController.text.trim().isEmpty) return;
    setState(() {
      widget.group.roommates.add(
        Roommate(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _newRoommateController.text.trim(),
        ),
      );
      _newRoommateController.clear();
    });
  }

  String _roommateName(String? id) {
    if (id == null) return 'Unassigned';
    return widget.group.roommates
        .firstWhere((r) => r.id == id, orElse: () => Roommate(id: '', name: 'Unassigned'))
        .name;
  }
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formattedToday() {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(group.name),
            Text(
              _formattedToday(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Roommates section
          const Text('Roommates', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: group.roommates
                .map((r) => Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text(r.name),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newRoommateController,
                  decoration: const InputDecoration(labelText: 'Add roommate'),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addRoommate),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          _buildBalancesSection(),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _openAddExpenseDialog,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Expense'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          _buildExpensesSection(),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // Category assignment section
          const Text('Grocery Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (group.categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No categories yet. Add one below.'),
            ),

          ...group.categories.map((category) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(category.name),
                subtitle: Text('Assigned to: ${_roommateName(category.assignedTo)}'),
                trailing: DropdownButton<String>(
                  hint: const Text('Assign'),
                  value: category.assignedTo,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...group.roommates.map(
                          (r) => DropdownMenuItem<String>(
                        value: r.id,
                        child: Text(r.name),
                      ),
                    ),
                  ],
                  onChanged: (id) {
                    final roommate = id == null
                        ? null
                        : group.roommates.firstWhere((r) => r.id == id);
                    _assignCategory(category, roommate);
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(labelText: 'Add category'),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _addCategory),
            ],
          ),
        ],
      ),
    );
  }
}
