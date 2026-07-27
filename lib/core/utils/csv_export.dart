import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';

/// Gera conteúdo CSV a partir dos dados financeiros do Loah.
/// Cada método retorna uma string formatada em CSV (separador `;`).
class CsvExport {
  CsvExport._();

  /// Cabeçalho padrão para exportação de transações.
  static const _transactionHeader = 'Data;Título;Categoria;Valor;Tipo;Conta';

  /// Escapa um campo CSV (se contiver `;`, `"` ou quebra de linha).
  static String _escape(String value) {
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Formata uma data no padrão brasileiro (dd/mm/aaaa).
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  /// Exporta uma lista de transações para CSV.
  static String transactionsToCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(_transactionHeader);

    for (final t in transactions) {
      final tipo = t.isIncome ? 'Receita' : 'Despesa';
      buffer.writeln(
        '${_formatDate(t.date)};'
        '${_escape(t.title)};'
        '${_escape(t.category)};'
        '${t.amount.toStringAsFixed(2)};'
        '$tipo;'
        '${_escape(t.accountId ?? '—')}',
      );
    }

    return buffer.toString();
  }

  /// Exporta uma lista de contas para CSV.
  static String accountsToCsv(List<AccountModel> accounts) {
    final buffer = StringBuffer();
    buffer.writeln('Nome;Tipo;Saldo Inicial');

    for (final a in accounts) {
      buffer.writeln(
        '${_escape(a.name)};'
        '${_escape(a.type.name)};'
        '${a.initialBalance.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }

  /// Exporta uma lista de ativos/patrimônio para CSV.
  static String assetsToCsv(List<AssetModel> assets) {
    final buffer = StringBuffer();
    buffer.writeln('Nome;Tipo;Valor Atual;Notas');

    for (final a in assets) {
      buffer.writeln(
        '${_escape(a.name)};'
        '${_escape(a.type.name)};'
        '${a.currentValue.toStringAsFixed(2)};'
        '${_escape(a.notes ?? '')}',
      );
    }

    return buffer.toString();
  }

  /// Relatório completo: transações, contas e patrimônio em um único CSV
  /// com seções separadas por linhas em branco.
  static String fullReportCsv({
    required List<TransactionModel> transactions,
    required List<AccountModel> accounts,
    required List<AssetModel> assets,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('=== TRANSAÇÕES ===');
    buffer.writeln(transactionsToCsv(transactions));

    buffer.writeln('=== CONTAS ===');
    buffer.writeln(accountsToCsv(accounts));

    buffer.writeln('=== PATRIMÔNIO ===');
    buffer.writeln(assetsToCsv(assets));

    return buffer.toString();
  }
}

