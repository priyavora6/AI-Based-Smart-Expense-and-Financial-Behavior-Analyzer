import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  const AddRecurringTransactionScreen({super.key});

  @override
  State<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends State<AddRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  String? _categoryName;
  String _frequency = 'monthly';
  DateTime _nextDueDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CategoryProvider>().loadCategories(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryName == null) return;
    setState(() => _isSaving = true);
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.getCategoryByName(_categoryName!);
    final success = await context.read<RecurringProvider>().addRecurring(
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          categoryId: category?.id ?? '',
          categoryName: _categoryName!,
          type: _type,
          frequency: _frequency,
          nextDueDate: _nextDueDate,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save recurring transaction.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = (_type == 'expense'
            ? categoryProvider.expenseCategories
            : categoryProvider.incomeCategories)
        .map((category) => category.name)
        .toList();
    if (_categoryName != null && !categories.contains(_categoryName)) {
      _categoryName = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Recurring Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (value) => setState(() {
                _type = value.first;
                _categoryName = null;
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a description'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                return amount == null || amount <= 0
                    ? 'Enter a valid amount'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryName,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((name) =>
                      DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              onChanged: categories.isEmpty
                  ? null
                  : (value) => setState(() => _categoryName = value),
              validator: (value) => value == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) => setState(() => _frequency = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Next due date'),
              subtitle: Text(
                '${_nextDueDate.day}/${_nextDueDate.month}/${_nextDueDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _nextDueDate = date);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save recurring transaction'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
