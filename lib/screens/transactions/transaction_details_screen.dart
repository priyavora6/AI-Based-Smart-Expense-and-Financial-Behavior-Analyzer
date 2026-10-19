import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transaction = ModalRoute.of(context)?.settings.arguments;
    if (transaction is! TransactionModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final isExpense = transaction.isExpense;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.pushNamed<bool>(
                context,
                AppRoutes.editTransaction,
                arguments: transaction,
              );
              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isExpense ? '−' : '+'} ₹${NumberFormat('#,##,##0.00', 'en_IN').format(transaction.amount)}',
              style: TextStyle(
                color: isExpense ? AppColors.expense : AppColors.success,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _detailRow('Description', transaction.description),
            _detailRow('Category', transaction.categoryName),
            _detailRow('Type', isExpense ? 'Expense' : 'Income'),
            _detailRow(
              'Date',
              DateFormat('MMM d, yyyy').format(transaction.date),
            ),
            _detailRow('Payment method', transaction.paymentMethod),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete transaction'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,
                ),
                onPressed: () async {
                  final deleted = await context
                      .read<TransactionProvider>()
                      .deleteTransaction(transaction.id);
                  if (deleted && context.mounted) {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(AppRoutes.transactions),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.secondaryText)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
