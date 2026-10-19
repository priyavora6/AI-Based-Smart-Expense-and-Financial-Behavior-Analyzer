import 'dart:convert';
import '../models/transaction_model.dart';
import 'transaction_service.dart';

/// Exports transaction data to CSV format.
/// PDF export can be added later using the `pdf` package.
class ExportService {
  final TransactionService _transactionService = TransactionService();

  // ── Export to CSV String ──────────────────────

  Future<String> exportToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await _transactionService.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    if (transactions.isEmpty) return 'No transactions to export.';

    // CSV Header
    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Type,Amount,Category,Description,Payment Method,Anomaly',
    );

    // CSV Rows
    for (final t in transactions) {
      buffer.writeln([
        _formatDate(t.date),
        t.type,
        t.amount.toStringAsFixed(2),
        _escapeCSV(t.categoryName),
        _escapeCSV(t.description),
        t.paymentMethod,
        t.isAnomaly ? 'Yes' : 'No',
      ].join(','));
    }

    return buffer.toString();
  }

  // ── Export Monthly Summary to CSV ─────────────

  Future<String> exportMonthlySummary({
    required int month,
    required int year,
  }) async {
    final totals = await _transactionService.getMonthlyTotals(
      month: month,
      year: year,
    );

    final categorySpending = await _transactionService.getCategorySpending(
      month: month,
      year: year,
    );

    final buffer = StringBuffer();
    buffer.writeln('Neospend Monthly Summary');
    buffer.writeln('Month: $month/$year');
    buffer.writeln('');
    buffer.writeln('Total Income,${totals['income']?.toStringAsFixed(2)}');
    buffer.writeln('Total Expense,${totals['expense']?.toStringAsFixed(2)}');
    buffer.writeln('Balance,${totals['balance']?.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Category,Amount');

    categorySpending.forEach((category, amount) {
      buffer.writeln('$category,${amount.toStringAsFixed(2)}');
    });

    return buffer.toString();
  }

  // ── Get Transactions as JSON ──────────────────

  Future<String> exportToJSON({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await _transactionService.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    final jsonList = transactions.map((t) => t.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // ── Helpers ───────────────────────────────────

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}