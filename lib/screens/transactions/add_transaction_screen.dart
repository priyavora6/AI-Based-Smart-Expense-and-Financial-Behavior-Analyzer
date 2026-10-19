import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  String _selectedType = 'expense'; // 'expense' or 'income'
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CategoryProvider>().loadCategories(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navyDark, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppColors.navyDark, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final availableCategories = _selectedType == 'expense'
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;
    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Create a category before adding a transaction.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = TransactionModel(
      id: '', // Generated in service
      userId: '', // Attached in provider
      amount: double.parse(_amountController.text),
      type: _selectedType,
      categoryId:
          categoryProvider.getCategoryByName(_selectedCategory)?.id ?? '',
      categoryName: _selectedCategory,
      description: _titleController.text.trim(),
      createdAt: DateTime.now(),
      date: _selectedDate,
    );

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final success = await provider.addTransaction(
      amount: transaction.amount,
      description: transaction.description,
      categoryId: transaction.categoryId,
      categoryName: transaction.categoryName,
      type: transaction.type,
      date: transaction.date,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isEmpty
              ? 'Failed to add'
              : provider.errorMessage),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = (_selectedType == 'expense'
            ? categoryProvider.expenseCategories
            : categoryProvider.incomeCategories)
        .map((category) => category.name)
        .toList();

    // Reset category if type changes and current category doesn't match
    if (categories.isNotEmpty && !categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded,
              color: AppColors.navyDark, size: 24),
        ),
        title: const Text(
          'New Transaction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── TOP AMOUNT HEADER ──
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                children: [
                  Text(
                    'How much?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹ ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _selectedType == 'expense'
                              ? AppColors.expense
                              : AppColors.success,
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: _selectedType == 'expense'
                                ? AppColors.expense
                                : AppColors.success,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── FORM SECTION ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Toggle (Expense / Income)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedType = 'expense'),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'expense'
                                      ? AppColors.expense.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Expense',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _selectedType == 'expense'
                                          ? AppColors.expense
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedType = 'income'),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'income'
                                      ? AppColors.success.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Income',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _selectedType == 'income'
                                          ? AppColors.success
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Title',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      validator: (v) => v!.isEmpty ? 'Enter a title' : null,
                      decoration: InputDecoration(
                        hintText: 'e.g. Lunch at Cafe',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : null,
                          isExpanded: true,
                          hint: Text(
                            categories.isEmpty
                                ? 'No categories available'
                                : 'Select a category',
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: categories.map((String cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                          onChanged: categories.isEmpty
                              ? null
                              : (String? newValue) {
                                  if (newValue != null) {
                                    setState(
                                        () => _selectedCategory = newValue);
                                  }
                                },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date
                    const Text(
                      'Date',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyDark),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d, yyyy')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.teal),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    GestureDetector(
                      onTap: _isLoading ? null : _saveTransaction,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.teal, AppColors.tealBright],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Transaction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
