// widgets/set_budget_dialog.dart
import 'package:flutter/material.dart';
import '../models/grocery_category.dart'; // for Period

class SetBudgetDialog extends StatefulWidget {
  final double? initialAmount;
  final Period initialPeriod;
  final void Function(double amount, Period period) onSave;

  const SetBudgetDialog({
    super.key,
    this.initialAmount,
    this.initialPeriod = Period.weekly,
    required this.onSave,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late final _amountController = TextEditingController(
    text: widget.initialAmount == null ? '' : widget.initialAmount!.toStringAsFixed(2),
  );
  late Period _period = widget.initialPeriod;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget amount')),
      );
      return;
    }
    widget.onSave(amount, _period);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Budget amount (\$)'),
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Resets:')),
          const SizedBox(height: 8),
          SegmentedButton<Period>(
            segments: const [
              ButtonSegment(value: Period.weekly, label: Text('Weekly')),
              ButtonSegment(value: Period.monthly, label: Text('Monthly')),
            ],
            selected: {_period},
            onSelectionChanged: (selection) => setState(() => _period = selection.first),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
