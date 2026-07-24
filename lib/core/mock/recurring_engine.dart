import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../services/finance_service.dart';

/// Turns due [RecurringTransactionModel]s into real [TransactionModel]s.
///
/// Call [processDue] once per app session (e.g. in the Finances
/// screen's `initState`) — it reads recurring items from Firestore via
/// [FinanceService], creates any newly-due transactions (also saved to
/// Firestore), and updates each recurring item's `lastGeneratedMonth`.
///
/// This is the 100% Firebase-integrated version.
class RecurringEngine {
  RecurringEngine._();

  /// Processes all due recurring transactions for the current month.
  /// Returns a list of newly created transactions (already saved).
  static Future<List<TransactionModel>> processDue({
    required FinanceService financeService,
  }) async {
    final recurring = await financeService.getAllRecurring();
    final created = <TransactionModel>[];
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    for (final item in recurring) {
      if (!item.active) continue;

      var updatedItem = item;
      var cursor = item.lastGeneratedMonth == null
          ? currentMonthStart
          : DateTime(item.lastGeneratedMonth!.year, item.lastGeneratedMonth!.month + 1, 1);

      while (!cursor.isAfter(currentMonthStart)) {
        // Se o dia escolhido (ex: 31) não existe no mês (ex: Fevereiro),
        // usa o último dia do mês.
        final lastDay = DateTime(cursor.year, cursor.month + 1, 0).day;
        final safeDay = item.dayOfMonth > lastDay ? lastDay : item.dayOfMonth;
        final dueDate = DateTime(cursor.year, cursor.month, safeDay);
        if (dueDate.isAfter(now)) break;

        final newTxn = TransactionModel(
          id: 'recurring_${item.id}_${cursor.year}_${cursor.month}',
          title: item.title,
          category: item.category,
          amount: item.amount,
          type: item.type,
          date: dueDate,
          accountId: item.accountId,
        );

        // Salva no Firestore
        await financeService.addTransaction(newTxn);
        created.add(newTxn);

        updatedItem = updatedItem.copyWith(
          lastGeneratedMonth: DateTime(cursor.year, cursor.month, 1),
        );
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }

      // Atualiza o lastGeneratedMonth no Firestore
      if (updatedItem.lastGeneratedMonth != item.lastGeneratedMonth) {
        await financeService.updateRecurring(updatedItem);
      }
    }

    return created;
  }
}
