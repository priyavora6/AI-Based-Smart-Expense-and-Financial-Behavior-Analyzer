import 'package:flutter/material.dart';

/// Neospend colour palette. Never hard-code hex values in widgets;
/// always use these constants.
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF142D4E);
  static const Color navyDark = Color(0xFF0C1D36);
  static const Color navyLight = Color(0xFF1D4272);
  static const Color primary = Color(0xFF142D4E); // Added for compatibility
  static const Color teal = Color(0xFF17A89B);
  static const Color tealBright = Color(0xFF3FD6C6);

  // Surfaces
  static const Color background = Color(0xFFF5F7FB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color mint = Color(0xFFE3F5F1);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = navy;
  static const Color secondaryText = Color(0xFF64748B);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color income = Color(0xFF16A34A); // Added for compatibility
  static const Color warning = Color(0xFFF59E0B);
  static const Color expense = Color(0xFFD9534F);
  static const Color anomaly = Color(0xFFF97316);

  // Category chart colours (fixed, so Food is always the same colour)
  static const Color catFood = Color(0xFFF97316);
  static const Color catTransport = Color(0xFF3B82F6);
  static const Color catShopping = Color(0xFFEC4899);
  static const Color catBills = Color(0xFFEAB308);
  static const Color catHealth = Color(0xFF10B981);
  static const Color catEducation = Color(0xFF8B5CF6);
  static const Color catOthers = Color(0xFF64748B);
}
