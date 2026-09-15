// utils/balance_calculator.dart
import '../models/expense.dart';
import '../models/roommate.dart';

class Debt {
  final String fromId;   // owes money
  final String toId;     // is owed money
  final double amount;

  Debt({required this.fromId, required this.toId, required this.amount});
}

class BalanceCalculator {
  /// Returns net balance per roommate: positive = owed money, negative = owes money
  static Map<String, double> calculateNetBalances(
      List<Roommate> roommates,
      List<Expense> expenses,
      ) {
    final balances = {for (var r in roommates) r.id: 0.0};

    for (final expense in expenses) {
      // Payer gets credited the full amount
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;

      // Everyone splitting the expense gets debited their share
      for (final roommateId in expense.splitBetween) {
        balances[roommateId] = (balances[roommateId] ?? 0) - expense.sharePerPerson;
      }
    }

    return balances;
  }

  /// Simplifies net balances into a minimal list of who-pays-who transactions
  static List<Debt> simplifyDebts(Map<String, double> netBalances) {
    final creditors = <MapEntry<String, double>>[];
    final debtors = <MapEntry<String, double>>[];

    netBalances.forEach((id, balance) {
      if (balance > 0.01) creditors.add(MapEntry(id, balance));
      if (balance < -0.01) debtors.add(MapEntry(id, -balance));
    });

    // Sort largest first so we settle big debts first
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    final debts = <Debt>[];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      final debtor = debtors[i];
      final creditor = creditors[j];
      final settleAmount = debtor.value < creditor.value ? debtor.value : creditor.value;

      debts.add(Debt(fromId: debtor.key, toId: creditor.key, amount: settleAmount));

      debtors[i] = MapEntry(debtor.key, debtor.value - settleAmount);
      creditors[j] = MapEntry(creditor.key, creditor.value - settleAmount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return debts;
  }
}