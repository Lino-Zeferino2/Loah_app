import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/transaction_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../utils/currency_formatter.dart';
import 'report_summary.dart';

/// Gera relatórios em PDF com os dados financeiros do Loah.
/// Usa a biblioteca `pdf` (Dart puro, sem dependência nativa).
class PdfExport {
  PdfExport._();

  /// Gera um relatório financeiro completo em PDF.
  ///
  /// Inclui:
  /// - Título e data de geração
  /// - Evolução do saldo (tabela)
  /// - Comparação de gastos por categoria
  /// - Transações recentes
  /// - Patrimônio
  static Future<Uint8List> generateReport({
    required List<AccountModel> accounts,
    required List<TransactionModel> transactions,
    required List<AssetModel> assets,
    required List<MonthlyBalancePoint> balanceHistory,
    required List<CategoryComparison> comparisons,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(context),
          pw.SizedBox(height: 16),
          _buildBalanceTable(context, balanceHistory),
          pw.SizedBox(height: 24),
          if (comparisons.isNotEmpty) ...[
            _buildComparisonSection(context, comparisons),
            pw.SizedBox(height: 24),
          ],
          _buildRecentTransactions(context, transactions),
          pw.SizedBox(height: 24),
          _buildAssetsSection(context, assets),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Context context) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Loah — Relatório Financeiro',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado em $dateStr',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildBalanceTable(
    pw.Context context,
    List<MonthlyBalancePoint> history,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Evolução do Saldo',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _tableCell('Mês', isHeader: true),
                _tableCell('Saldo', isHeader: true),
              ],
            ),
            ...history.map(
              (point) => pw.TableRow(
                children: [
                  _tableCell(point.label),
                  _tableCell(
                    CurrencyFormatter.format(point.balance),
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildComparisonSection(
    pw.Context context,
    List<CategoryComparison> comparisons,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Gasto por Categoria',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _tableCell('Categoria', isHeader: true),
                _tableCell('Este Mês', isHeader: true),
                _tableCell('Mês Anterior', isHeader: true),
                _tableCell('Variação', isHeader: true),
              ],
            ),
            ...comparisons.map(
              (c) => pw.TableRow(
                children: [
                  _tableCell(c.category),
                  _tableCell(
                    CurrencyFormatter.format(c.current),
                    align: pw.TextAlign.right,
                  ),
                  _tableCell(
                    CurrencyFormatter.format(c.previous),
                    align: pw.TextAlign.right,
                  ),
                  _tableCell(
                    c.deltaPercent != null
                        ? '${c.deltaPercent!.abs().toStringAsFixed(0)}%'
                        : '—',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildRecentTransactions(
    pw.Context context,
    List<TransactionModel> transactions,
  ) {
    final recent = transactions.take(20).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transações Recentes',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (recent.isEmpty)
          pw.Text('Nenhuma transação registrada.')
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.3),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                children: [
                  _tableCell('Data', isHeader: true),
                  _tableCell('Título', isHeader: true),
                  _tableCell('Valor', isHeader: true),
                  _tableCell('Tipo', isHeader: true),
                ],
              ),
              ...recent.map(
                (t) => pw.TableRow(
                  children: [
                    _tableCell(
                      '${t.date.day.toString().padLeft(2, '0')}/'
                      '${t.date.month.toString().padLeft(2, '0')}',
                    ),
                    _tableCell(t.title),
                    _tableCell(
                      CurrencyFormatter.format(t.amount),
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(t.isIncome ? 'Receita' : 'Despesa'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildAssetsSection(
    pw.Context context,
    List<AssetModel> assets,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Patrimônio',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (assets.isEmpty)
          pw.Text('Nenhum ativo registrado.')
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                children: [
                  _tableCell('Nome', isHeader: true),
                  _tableCell('Tipo', isHeader: true),
                  _tableCell('Valor', isHeader: true),
                ],
              ),
              ...assets.map(
                (a) => pw.TableRow(
                  children: [
                    _tableCell(a.name),
                    _tableCell(a.type.name),
                    _tableCell(
                      CurrencyFormatter.format(a.currentValue),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: align,
      ),
    );
  }
}

