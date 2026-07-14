import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';

/// Turns due [RecurringTransactionModel]s into real [TransactionModel]s.
///
/// Call [processDue] once per app session (e.g. in the Finances
/// screen's `initState`) — it mutates both lists in place: appends any
/// newly-due transactions and stamps `lastGeneratedMonth` on each
/// recurring item so it's never charged twice for the same month.
class RecurringEngine {
  RecurringEngine._();

  static void processDue(
    List<RecurringTransactionModel> recurring,
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    for (var i = 0; i < recurring.length; i++) {
      var item = recurring[i];
      if (!item.active) continue;

      // Never generated before: start catching up from the current
      // month only (don't backfill transactions from before the user
      // ever set this up).
      var cursor = item.lastGeneratedMonth == null
          ? currentMonthStart
          : DateTime(item.lastGeneratedMonth!.year, item.lastGeneratedMonth!.month + 1, 1);

      // Catch up month-by-month in case the app wasn't opened for a
      // while, stopping once we reach a month whose due day hasn't
      // happened yet.
      while (!cursor.isAfter(currentMonthStart)) {
        final dueDate = DateTime(cursor.year, cursor.month, item.dayOfMonth);
        if (dueDate.isAfter(now)) break;

        transactions.add(TransactionModel(
          id: 'txn_recurring_${item.id}_${cursor.year}_${cursor.month}',
          title: item.title,
          category: item.category,
          amount: item.amount,
          type: item.type,
          date: dueDate,
          accountId: item.accountId,
        ));

        item = item.copyWith(lastGeneratedMonth: DateTime(cursor.year, cursor.month, 1));
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }

      recurring[i] = item;
    }
  }
}