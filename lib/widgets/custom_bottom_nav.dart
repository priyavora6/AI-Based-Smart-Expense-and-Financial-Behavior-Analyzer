import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final routes = [
      AppRoutes.dashboard,
      AppRoutes.transactions,
      AppRoutes.addTransaction,
      AppRoutes.insights,
      AppRoutes.profile,
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.secondaryText,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 2) {
          Navigator.pushNamed(context, routes[index]);
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
            context, routes[index], (route) => false);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_rounded),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_rounded),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
