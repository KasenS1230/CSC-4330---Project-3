// widgets/add_expense_dialog.dart
import 'package:flutter/material.dart';
import '../models/roommate.dart';
import '../models/expense.dart';

class AddExpenseDialog extends StatefulWidget {
  final List<Roommate> roommates;
  final void Function(Expense) onAdd;

  const AddExpenseDialog({super.key, required this.roommates, required this.onAdd});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String? _paidBy;
  final Set<String> _splitBetween = {};

  @override
  void initState() {
    super.initState();
    // default: split between everyone
    _splitBetween.addAll(widget.roommates.map((r) => r.id));
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (_descController.text.trim().isEmpty || amount == null || _paidBy == null || _splitBetween.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill out all fields')),
      );
      return;
    }

    widget.onAdd(Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      paidBy: _paidBy!,
      description: _descController.text.trim(),
      amount: amount,
      splitBetween: _splitBetween.toList(),
      date: DateTime.now(),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'What did you buy?'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (\$)'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              hint: const Text('Who paid?'),
              value: _paidBy,
              items: widget.roommates
                  .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                  .toList(),
              onChanged: (id) => setState(() => _paidBy = id),
            ),
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: Text('Split between:')),
            ...widget.roommates.map((r) => CheckboxListTile(
              title: Text(r.name),
              value: _splitBetween.contains(r.id),
              onChanged: (checked) {
                setState(() {
                  checked! ? _splitBetween.add(r.id) : _splitBetween.remove(r.id);
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}