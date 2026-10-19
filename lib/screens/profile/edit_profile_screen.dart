import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _incomeController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _incomeController = TextEditingController(
      text: user?.monthlyIncome.toStringAsFixed(0) ?? '0',
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().updateProfile(
          name: _nameController.text,
          monthlyIncome: double.parse(_incomeController.text),
        );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().errorMessage),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incomeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monthly income'),
              validator: (value) {
                final income = double.tryParse(value ?? '');
                return income == null || income < 0
                    ? 'Enter a valid income'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: loading ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
              child: Text(loading ? 'Saving...' : 'Save profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }
}
