import '../../models/account_model.dart';
import '../../models/transaction_model.dart';

/// Computes an [AccountModel]'s current balance. Kept as a pure
/// function (not a stored field) so it's never stale — always
/// `initialBalance + sum(linked transactions, income positive/expense
/// negative)`, derived fresh from the current transaction list.
class AccountBalance {
  AccountBalance._();

  static double of(AccountModel account, List<TransactionModel> allTransactions) {
    final net = allTransactions
        .where((t) => t.accountId == account.id)
        .fold<double>(0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));
    return account.initialBalance + net;
  }

  /// Sum of every account's balance — the app-wide "saldo total".
  static double totalOf(List<AccountModel> accounts, List<TransactionModel> allTransactions) {
    return accounts.fold<double>(0, (sum, a) => sum + of(a, allTransactions));
  }
}