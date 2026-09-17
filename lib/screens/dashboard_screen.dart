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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _newCategoryController = TextEditingController();
  final _newRoommateController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newCategoryController.dispose();
    _newRoommateController.dispose();
    super.dispose();
  }

  String _roommateName(String? id) {
    if (id == null) return 'Unassigned';
    return widget.group.roommates
        .firstWhere((r) => r.id == id, orElse: () => Roommate(id: '', name: 'Unassigned'))
        .name;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  // ---------- Actions ----------
  void _assignCategory(GroceryCategory category, Roommate? roommate) {
    setState(() => category.assignedTo = roommate?.id);
  }

  void _addCategory() {
    if (_newCategoryController.text.trim().isEmpty) return;
    final name = _newCategoryController.text.trim();
    setState(() {
      widget.group.categories.add(
        GroceryCategory(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name),
      );
      _newCategoryController.clear();
    });
    _showSnack('Added "$name" ✓');
  }

  void _addRoommate() {
    if (_newRoommateController.text.trim().isEmpty) return;
    final name = _newRoommateController.text.trim();
    setState(() {
      widget.group.roommates.add(
        Roommate(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name),
      );
      _newRoommateController.clear();
    });
    _showSnack('Added $name ✓');
  }

  void _deleteExpense(Expense expense) {
    final index = widget.group.expenses.indexOf(expense);
    setState(() => widget.group.expenses.remove(expense));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed "${expense.description}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => widget.group.expenses.insert(index, expense)),
        ),
      ));
  }

  void _deleteCategory(GroceryCategory category) {
    final index = widget.group.categories.indexOf(category);
    setState(() => widget.group.categories.remove(category));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed "${category.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => widget.group.categories.insert(index, category)),
        ),
      ));
  }

  void _openAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (_) => AddExpenseDialog(
        roommates: widget.group.roommates,
        onAdd: (expense) {
          setState(() => widget.group.expenses.add(expense));
          _showSnack('Expense added ✓');
        },
      ),
    );
  }

  Color _avatarColor(String seed) {
    final colors = [Colors.teal, Colors.indigo, Colors.deepOrange, Colors.purple, Colors.blueGrey, Colors.pink];
    if (seed.isEmpty) return colors.first;
    return colors[seed.codeUnitAt(0) % colors.length];
  }

  // ---------- Tab 1: Overview (roommates + balances) ----------
  Widget _buildOverviewTab() {
    final balances = BalanceCalculator.calculateNetBalances(widget.group.roommates, widget.group.expenses);
    final debts = BalanceCalculator.simplifyDebts(balances);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text('Balances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (debts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 10),
                Text('Everyone is settled up!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        else
          ...debts.map((debt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: _roommateName(debt.fromId), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: '  owes  '),
                          TextSpan(text: _roommateName(debt.toId), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  Text('\$${debt.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15)),
                ],
              ),
            );
          }),
        const SizedBox(height: 28),
        const Text('Roommates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.group.roommates.map((r) {
            final color = _avatarColor(r.name);
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: color,
                child: Text(r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              label: Text(r.name),
              backgroundColor: color.withOpacity(0.08),
              side: BorderSide(color: color.withOpacity(0.3)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newRoommateController,
                decoration: const InputDecoration(labelText: 'Add roommate', isDense: true, border: OutlineInputBorder()),
                onSubmitted: (_) => _addRoommate(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(key: const Key('addRoommateButton'), icon: const Icon(Icons.add), onPressed: _addRoommate),
          ],
        ),
      ],
    );
  }

  // ---------- Tab 2: Expenses ----------
  Widget _buildExpensesTab() {
    final expenses = widget.group.expenses;

    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No expenses yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              Text('Tap + to log your first grocery run', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final periodLabel = expense.period == Period.weekly ? 'Weekly' : 'Monthly';
        final payerName = _roommateName(expense.paidBy);

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) => _deleteExpense(expense),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _avatarColor(payerName),
                  child: Text(payerName.isNotEmpty ? payerName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Paid by $payerName', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(periodLabel,
                          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Tab 3: Categories ----------
  Widget _buildCategoriesTab() {
    final group = widget.group;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (group.categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(Icons.local_grocery_store_rounded, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No categories yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Text('Add one below, like "Produce" or "Snacks"', style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          )
        else
          ...group.categories.map((category) {
            return Dismissible(
              key: ValueKey(category.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) => _deleteCategory(category),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(_roommateName(category.assignedTo), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      underline: const SizedBox(),
                      hint: const Text('Assign'),
                      value: category.assignedTo,
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('Unassigned')),
                        ...group.roommates.map((r) => DropdownMenuItem<String>(value: r.id, child: Text(r.name))),
                      ],
                      onChanged: (id) {
                        final roommate = id == null ? null : group.roommates.firstWhere((r) => r.id == id);
                        _assignCategory(category, roommate);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newCategoryController,
                decoration: const InputDecoration(labelText: 'Add category', isDense: true, border: OutlineInputBorder()),
                onSubmitted: (_) => _addCategory(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(key: const Key('addCategoryButton'), icon: const Icon(Icons.add), onPressed: _addCategory),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text(group.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Expenses'),
            Tab(icon: Icon(Icons.local_grocery_store_rounded), text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildExpensesTab(),
          _buildCategoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseDialog,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}