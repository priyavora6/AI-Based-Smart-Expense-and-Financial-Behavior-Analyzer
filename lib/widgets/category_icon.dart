import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../utils/app_helpers.dart';

class CategoryIcon extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;
  final bool showBackground;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.color,
    this.size = 24,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.teal;
    final icon = AppHelpers.getCategoryIcon(iconName);

    if (!showBackground) {
      return Icon(icon, color: iconColor, size: size);
    }

    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}