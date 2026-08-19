import '../../models/account_model.dart';
import '../../models/transaction_model.dart';

/// One point in the balance-over-time chart: a month label and the
/// total account balance as of that month's end.
class MonthlyBalancePoint {
  final DateTime month;
  final String label;
  final double balance;

  const MonthlyBalancePoint({required this.month, required this.label, required this.balance});
}

/// One category's spend this month vs. the previous month.
class CategoryComparison {
  final String category;
  final double current;
  final double previous;

  const CategoryComparison({required this.category, required this.current, required this.previous});

  double get delta => current - previous;

  /// Percent change vs. last month. Null if there's nothing to compare
  /// against (previous month had zero spend in this category).
  double? get deltaPercent => previous == 0 ? null : (delta / previous) * 100;
}

/// Derives report data from accounts/transactions — pure functions, no
/// stored history, so figures are always computed fresh from whatever
/// transactions currently exist.
class ReportSummary {
  ReportSummary._();

  static const _monthAbbrev = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

   /// Total account balance as of the end of [asOf]'s month (or right
  /// now, if [asOf] is the current month) — every account's
  /// initialBalance plus every transaction dated on/before [asOf].
  ///
  /// CORRIGIDO: antes somava o initialBalance de TODAS as contas
  /// incondicionalmente — isso fazia o gráfico mostrar saldo em meses
  /// anteriores à própria conta existir (o bug do valor fixo repetido).
  /// Agora só conta contas já criadas até [asOf]. Contas sem createdAt
  /// (registadas antes desta mudança) são tratadas como "sempre
  /// existiram", para não fazer o saldo delas desaparecer do histórico
  /// retroativamente.
  static double balanceAsOf(
    List<AccountModel> accounts,
    List<TransactionModel> transactions,
    DateTime asOf,
  ) {
    final relevantAccounts = accounts.where(
      (a) => a.createdAt == null || !a.createdAt!.isAfter(asOf),
    );
    final initial = relevantAccounts.fold<double>(0, (sum, a) => sum + a.initialBalance);
    final net = transactions
        .where((t) => !t.date.isAfter(asOf))
        .fold<double>(0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));
    return initial + net;
  }

  /// Balance at the end of each of the last [months] months (oldest
  /// first), ending with the current balance right now.
  static List<MonthlyBalancePoint> balanceHistory(
    List<AccountModel> accounts,
    List<TransactionModel> transactions, {
    int months = 6,
  }) {
    final now = DateTime.now();
    final points = <MonthlyBalancePoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      // Last moment of that month (or "now" if it's the current month,
      // so the final bar always reflects the live balance).
      final isCurrentMonth = monthDate.year == now.year && monthDate.month == now.month;
      final asOf = isCurrentMonth ? now : DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);

      points.add(MonthlyBalancePoint(
        month: monthDate,
        label: _monthAbbrev[monthDate.month - 1],
        balance: balanceAsOf(accounts, transactions, asOf),
      ));
    }
    return points;
  }

  static bool _isInMonth(DateTime date, DateTime monthStart) =>
      date.year == monthStart.year && date.month == monthStart.month;

  static double _spentInMonth(
    String category,
    List<TransactionModel> transactions,
    DateTime monthStart,
  ) {
    return transactions
        .where((t) => !t.isIncome && t.category == category && _isInMonth(t.date, monthStart))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Computes a simple linear regression (trend line) for the given
  /// balance history points. Returns `[slope, intercept]` where
  /// `y = slope * x + intercept`, with `x` being the index of the point.
  ///
  /// Useful for drawing a trend overlay on the balance chart.
  static List<double>? trendLine(List<MonthlyBalancePoint> points) {
    if (points.length < 2) return null;

    final n = points.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (var i = 0; i < points.length; i++) {
      final x = i.toDouble();
      final y = points[i].balance;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return [slope, intercept];
  }

  /// This month vs. last month, for every expense category that has
  /// spend in either period — sorted by current month's spend
  /// (biggest first).
  static List<CategoryComparison> categoryComparison(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final categories = transactions
        .where((t) => !t.isIncome && (_isInMonth(t.date, thisMonth) || _isInMonth(t.date, lastMonth)))
        .map((t) => t.category)
        .toSet();

    final comparisons = [
      for (final category in categories)
        CategoryComparison(
          category: category,
          current: _spentInMonth(category, transactions, thisMonth),
          previous: _spentInMonth(category, transactions, lastMonth),
        ),
    ]..sort((a, b) => b.current.compareTo(a.current));

    return comparisons;
  }
}