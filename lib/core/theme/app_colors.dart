import 'package:material_ui/material_ui.dart';

/// Palet warna terpusat dan aksesibel untuk Simple E-Learning Platform.
final class AppColors {
  const AppColors._();

  // Primary Branding (Indigo / Slate Blue)
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimaryContainer = Color(0xFF312E81);

  // Secondary & Accent (Teal / Cyan)
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // Neutral Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Outline, Borders & Dividers
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic Status
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);

  // Category Badges
  static const Color categoryBadgeBg = Color(0xFFEEF2FF);
  static const Color categoryBadgeText = Color(0xFF4338CA);

  // Level Badges Helper
  static Color levelBadgeBg(String level) {
    return switch (level.toLowerCase()) {
      'beginner' => const Color(0xFFDCFCE7),
      'intermediate' => const Color(0xFFFEF3C7),
      'advanced' => const Color(0xFFFCE7F3),
      _ => const Color(0xFFF1F5F9),
    };
  }

  static Color levelBadgeText(String level) {
    return switch (level.toLowerCase()) {
      'beginner' => const Color(0xFF166534),
      'intermediate' => const Color(0xFF92400E),
      'advanced' => const Color(0xFF9D174D),
      _ => const Color(0xFF475569),
    };
  }
}
