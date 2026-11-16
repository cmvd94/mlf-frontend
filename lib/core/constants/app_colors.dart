import 'package:flutter/material.dart';

class AppColors {
  // Brand Blue extracted from reference: Bold Royal / Cobalt Blue
  static const Color primary = Color(0xFF1544B2); // Vivid Royal Blue
  static const Color primaryDark = Color(0xFF0C255E); // Deep Navy Blue for sidebar & dark surfaces
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Accent Blue
  static const Color primaryContainer = Color(0xFFEDF2FE); // Soft Blue background tint

  // Brand Yellow extracted from reference: Vibrant Canary / Golden Yellow
  static const Color yellow = Color(0xFFFFD600); // Vivid Canary Yellow
  static const Color yellowDark = Color(0xFFD49B00); // Deep Amber Gold for text/borders
  static const Color yellowLight = Color(0xFFFFF9C4); // Light Yellow tint
  static const Color yellowContainer = Color(0xFFFEF9C3); // Soft Yellow container

  // Accent & Secondary mapped to Brand Yellow
  static const Color accent = Color(0xFFFFD600); // Canary Yellow Accent
  static const Color secondary = Color(0xFFFFD600); // Secondary Brand Color

  // Neutrals & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Semantic Status Colors
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color success = Color(0xFF10B981); // Green 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
}
