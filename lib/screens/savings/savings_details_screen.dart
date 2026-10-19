import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/savings_goal_model.dart';
import '../../providers/savings_provider.dart';

class SavingsDetailsScreen extends StatelessWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = ModalRoute.of(context)!.settings.arguments as SavingsGoalModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await context.read<SavingsProvider>().deleteGoal(goal.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('₹${goal.savedAmount.toStringAsFixed(0)} saved',
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (goal.percentage / 100).clamp(0, 1)),
          const SizedBox(height: 12),
          Text('Target: ₹${goal.targetAmount.toStringAsFixed(0)}'),
          Text(
              'Remaining: ₹${goal.remaining.clamp(0, double.infinity).toStringAsFixed(0)}'),
          Text('Monthly required: ₹${goal.monthlyRequired.toStringAsFixed(0)}'),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add savings'),
            onPressed: () async {
              final controller = TextEditingController();
              final amount = await showDialog<double>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add savings'),
                  content: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(
                          context, double.tryParse(controller.text)),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
              controller.dispose();
              if (amount != null && amount > 0 && context.mounted) {
                await context
                    .read<SavingsProvider>()
                    .addToGoal(goal.id, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
