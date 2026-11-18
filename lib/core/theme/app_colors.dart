import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents (ShefsCloud MVP Palette)
  static const Color primary = Color(0xFFC2410C); // Burnt Terracotta Orange
  static const Color primaryLight = Color(0xFFEA580C); // Vibrant Orange
  static const Color primaryDark = Color(0xFF9A3412); // Deep Rust
  static const Color charcoal = Color(0xFF1B1B1A); // Primary Ink / Dark Pill
  static const Color accent = Color(0xFFD97706); // Warm Amber

  // Background & Surfaces
  static const Color background = Color(0xFFFAF7F2); // Warm Sand Paper
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3EFE6); // Soft Cream
  static const Color cardBorder = Color(0xFFE6E0D6); // Warm Hairline Border

  // Text Colors
  static const Color textPrimary = Color(0xFF1B1B1A); // Deep Charcoal
  static const Color textSecondary = Color(0xFF5F5B55); // Warm Muted Slate
  static const Color textMuted = Color(0xFF8C867E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusPlaced = Color(0xFF4F46E5); // Indigo
  static const Color statusAccepted = Color(0xFF0284C7); // Sky
  static const Color statusAssigned = Color(0xFF7C3AED); // Violet
  static const Color statusPickedUp = Color(0xFFC2410C); // Burnt Orange
  static const Color statusOnTheWay = Color(0xFF0D9488); // Teal
  static const Color statusDelivered = Color(0xFF1B5E20); // Deep Forest Green
  static const Color statusCancelled = Color(0xFF5F5B55); // Muted Gray
  static const Color statusFailed = Color(0xFFB3261E); // Crimson

  // Feedback Colors
  static const Color success = Color(0xFF1B5E20);
  static const Color successLight = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFB3261E);
  static const Color info = Color(0xFF2563EB);

  // Unique High-Contrast Multi-Order Palette for Rider Live Map
  static const List<Color> orderPalette = <Color>[
    Color(0xFFC2410C), // 0: Burnt Orange
    Color(0xFF2563EB), // 1: Royal Blue
    Color(0xFF059669), // 2: Emerald Green
    Color(0xFF7C3AED), // 3: Vivid Purple
    Color(0xFFE11D48), // 4: Crimson Rose
    Color(0xFF0891B2), // 5: Deep Cyan
    Color(0xFFD97706), // 6: Golden Amber
    Color(0xFF4F46E5), // 7: Deep Indigo
    Color(0xFFBE185D), // 8: Magenta
    Color(0xFF15803D), // 9: Forest Green
  ];

  static Color colorForOrderIndex(int index) {
    return orderPalette[index.abs() % orderPalette.length];
  }
}
