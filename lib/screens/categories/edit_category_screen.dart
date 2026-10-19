import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late CategoryModel _original;
  bool _isInit = false;
  bool _isLoading = false;

  String _selectedType = 'expense';
  String _selectedIcon = 'restaurant';
  String _selectedColor = '#F97316';

  final List<Map<String, dynamic>> _icons = [
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded},
    {'name': 'car', 'icon': Icons.directions_car_rounded},
    {'name': 'shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'bills', 'icon': Icons.receipt_rounded},
    {'name': 'health', 'icon': Icons.local_hospital_rounded},
    {'name': 'education', 'icon': Icons.school_rounded},
    {'name': 'entertainment', 'icon': Icons.movie_rounded},
    {'name': 'salary', 'icon': Icons.account_balance_wallet_rounded},
  ];

  final List<String> _colors = [
    '#F97316', '#3B82F6', '#EC4899', '#EAB308',
    '#10B981', '#8B5CF6', '#17A89B', '#64748B',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is! CategoryModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
        return;
      }
      _original = arguments;
      _nameController.text = _original.name;
      _selectedType = _original.type;
      _selectedIcon = _original.icon;
      _selectedColor = _original.color;
      _isInit = true;
    }
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updated = _original.copyWith(
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      colorValue: _parseColor(_selectedColor).value,
    );

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.updateCategory(updated);
    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update category')),
      );
    }
  }

  Future<void> _deleteCategory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category'),
        content: const Text('Are you sure? Transactions using this category will remain but be uncategorized.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<CategoryProvider>(context, listen: false);
              final deleted = await provider.deleteCategory(_original.id);
              if (deleted && context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: AppColors.navyDark),
        ),
        title: const Text('Edit Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
        actions: [
          if (!_original.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: _parseColor(_selectedColor).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconData(_selectedIcon), color: _parseColor(_selectedColor), size: 40),
                ),
              ),

              const SizedBox(height: 32),

              const Text('Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_original.isDefault,
                validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Icon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon['name']),
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? _parseColor(_selectedColor).withOpacity(0.15) : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? _parseColor(_selectedColor) : Colors.transparent, width: 2),
                        ),
                        child: Icon(icon['icon'], color: isSelected ? _parseColor(_selectedColor) : AppColors.secondaryText, size: 22),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _colors.map((c) {
                    final isSelected = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(c),
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.navyDark : Colors.transparent, width: 3),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: _isLoading ? null : _updateCategory,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealBright]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppColors.teal;
    }
  }

  IconData _getIconData(String name) {
    final found = _icons.firstWhere((i) => i['name'] == name, orElse: () => _icons[0]);
    return found['icon'];
  }
}