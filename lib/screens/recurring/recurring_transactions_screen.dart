import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/recurring_provider.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RecurringProvider>().loadRecurring(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : RefreshIndicator(
              onRefresh: context.read<RecurringProvider>().loadRecurring,
              child: provider.recurring.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No recurring transactions yet.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.recurring.length,
                      itemBuilder: (context, index) {
                        final item = provider.recurring[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.mint,
                              child: Icon(
                                item.type == 'income'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: AppColors.teal,
                              ),
                            ),
                            title: Text(item.description),
                            subtitle: Text(
                              '${item.frequency} • ${item.categoryName}\n'
                              'Next: ${item.nextDueDate.day}/${item.nextDueDate.month}/${item.nextDueDate.year}',
                            ),
                            isThreeLine: true,
                            trailing: Switch(
                              value: item.isActive,
                              onChanged: (value) => provider.toggleActive(
                                item.id,
                                value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addRecurring),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
