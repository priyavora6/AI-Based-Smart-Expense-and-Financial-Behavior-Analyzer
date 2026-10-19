import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
        title: const Text('Categories',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDark)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addCategory),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : categories.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.editCategory,
                          arguments: cat),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _parseColor(cat.color).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getIconData(cat.icon),
                                  color: _parseColor(cat.color), size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDark),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cat.type,
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 60, color: AppColors.secondaryText.withOpacity(0.3)),
          const SizedBox(height: 14),
          const Text('No categories yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark)),
          const SizedBox(height: 6),
          Text('Tap + to create one',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        ],
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
    switch (name.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'groceries':
        return Icons.local_grocery_store_rounded;
      case 'dining':
        return Icons.restaurant_menu_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'rent':
        return Icons.home_work_rounded;
      case 'utilities':
        return Icons.lightbulb_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'subscriptions':
        return Icons.subscriptions_rounded;
      case 'personal_care':
        return Icons.spa_rounded;
      case 'gifts':
        return Icons.card_giftcard_rounded;
      case 'insurance':
        return Icons.security_rounded;
      case 'taxes':
        return Icons.account_balance_rounded;
      case 'other':
        return Icons.more_horiz_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift_income':
        return Icons.redeem_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
