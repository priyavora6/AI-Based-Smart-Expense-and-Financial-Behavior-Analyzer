import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedIcon = 'restaurant';
  String _selectedColor = '#F97316';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'restaurant', 'icon': Icons.restaurant_rounded},
    {'name': 'groceries', 'icon': Icons.local_grocery_store_rounded},
    {'name': 'dining', 'icon': Icons.restaurant_menu_rounded},
    {'name': 'car', 'icon': Icons.directions_car_rounded},
    {'name': 'fuel', 'icon': Icons.local_gas_station_rounded},
    {'name': 'travel', 'icon': Icons.flight_takeoff_rounded},
    {'name': 'shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'clothing', 'icon': Icons.checkroom_rounded},
    {'name': 'bills', 'icon': Icons.receipt_rounded},
    {'name': 'rent', 'icon': Icons.home_work_rounded},
    {'name': 'utilities', 'icon': Icons.lightbulb_rounded},
    {'name': 'health', 'icon': Icons.local_hospital_rounded},
    {'name': 'education', 'icon': Icons.school_rounded},
    {'name': 'entertainment', 'icon': Icons.movie_rounded},
    {'name': 'subscriptions', 'icon': Icons.subscriptions_rounded},
    {'name': 'personal_care', 'icon': Icons.spa_rounded},
    {'name': 'gifts', 'icon': Icons.card_giftcard_rounded},
    {'name': 'insurance', 'icon': Icons.security_rounded},
    {'name': 'taxes', 'icon': Icons.account_balance_rounded},
    {'name': 'other', 'icon': Icons.more_horiz_rounded},
    {'name': 'salary', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'freelance', 'icon': Icons.work_rounded},
    {'name': 'investment', 'icon': Icons.trending_up_rounded},
    {'name': 'gift_income', 'icon': Icons.redeem_rounded},
  ];

  final List<String> _colors = [
    '#F97316', '#3B82F6', '#EC4899', '#EAB308',
    '#10B981', '#8B5CF6', '#17A89B', '#64748B',
  ];

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.addCategory(
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      type: _selectedType,
      colorValue: int.parse(_selectedColor.replaceAll('#', '0xFF')),
    );
    
    setState(() => _isLoading = false);

    if (success && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('New Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Icon
              Center(
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: _parseColor(_selectedColor).withValues(alpha: 0.15),
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
                validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Groceries',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: ['expense', 'income'].map((t) {
                    final isSelected = _selectedType == t;
                    final color = t == 'expense' ? AppColors.expense : AppColors.success;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? color : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Icon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon['name']),
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? _parseColor(_selectedColor).withValues(alpha: 0.15) : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? _parseColor(_selectedColor) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon['icon'],
                          color: isSelected ? _parseColor(_selectedColor) : AppColors.secondaryText,
                          size: 22,
                        ),
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
                  spacing: 12,
                  runSpacing: 12,
                  children: _colors.map((c) {
                    final isSelected = _selectedColor == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.navyDark : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: _isLoading ? null : _saveCategory,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealBright]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
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
