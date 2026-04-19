import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDeepPurple = Color(0xFF7C3AED);
  static const Color primaryGreen = Color(0xFF059669);
  static const Color primaryRed = Color(0xFFDC2626);
  static const Color primaryOrange = Color(0xFFEA580C);

  // Gradient Colors
  static const List<Color> heroGradient = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF3B82F6),
    Color(0xFF2563EB),
  ];

  static const List<Color> successGradient = [
    Color(0xFF059669),
    Color(0xFF10B981),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFEA580C),
    Color(0xFFF59E0B),
  ];

  // Neutral
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);

  // Status
  static const Color pending = Color(0xFFF59E0B);
  static const Color accepted = Color(0xFF3B82F6);
  static const Color completed = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);

  // Text
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF64748B);
  static const Color textLight = Color(0xFFCBD5E1);
}
