import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../widgets/custom_bottom_nav.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All'; // All, Income, Expense
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load transactions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##,##0', 'en_IN').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    List<TransactionModel> transactions = transactionProvider.transactions;

    // Apply Filter
    if (_selectedFilter == 'Income') {
      transactions = transactions.where((t) => t.type == 'income').toList();
    } else if (_selectedFilter == 'Expense') {
      transactions = transactions.where((t) => t.type == 'expense').toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      transactions = transactions
          .where((t) =>
              t.description.toLowerCase().contains(query) ||
              t.categoryName.toLowerCase().contains(query))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Clean light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.navyDark, size: 20),
        ),
        title: const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.navyDark),
            onPressed: () async {
              final controller = TextEditingController(text: _searchQuery);
              final query = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search transactions'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Description or category',
                    ),
                    onSubmitted: (value) => Navigator.pop(context, value),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, ''),
                      child: const Text('Clear'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              );
              controller.dispose();
              if (query != null && mounted) {
                setState(() => _searchQuery = query.trim());
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ── TABS (All / Income / Expense) ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterTab('All'),
                _buildFilterTab('Expense'),
                _buildFilterTab('Income'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── TRANSACTION LIST ──
          Expanded(
            child: transactionProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.teal))
                : transactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.teal,
                        onRefresh: () => transactionProvider.loadTransactions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(transactions[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  // ── UI WIDGETS ──

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.navyDark : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isExpense = tx.type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.success;
    final sign = isExpense ? '− ' : '+ ';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.transactionDetails, // Goes to details screen later
          arguments: tx,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(tx.categoryName).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getCategoryIcon(tx.categoryName),
                  size: 24,
                  color: _getCategoryColor(tx.categoryName),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description.isEmpty ? tx.categoryName : tx.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount + Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${_formatCurrency(tx.amount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(tx.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppColors.secondaryText.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new transaction',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.catFood;
      case 'transport':
        return AppColors.catTransport;
      case 'shopping':
        return AppColors.catShopping;
      case 'bills':
        return AppColors.catBills;
      case 'health':
        return AppColors.catHealth;
      case 'education':
        return AppColors.catEducation;
      default:
        return AppColors.catOthers;
    }
  }
}
