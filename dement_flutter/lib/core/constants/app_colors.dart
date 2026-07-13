// REPLACE lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ─── Primary brand — soft indigo-lavender ───────────────────────────
  static const Color primary        = Color(0xFF6B5FE4);   // indigo
  static const Color primaryLight   = Color(0xFF8B80F0);
  static const Color primaryDark    = Color(0xFF4A3FBF);

  // ─── Secondary — teal-mint ──────────────────────────────────────────
  static const Color secondary      = Color(0xFF3ECFB2);
  static const Color secondaryLight = Color(0xFF6BDECE);
  static const Color secondaryDark  = Color(0xFF28A896);

  // ─── Accent — warm coral ────────────────────────────────────────────
  static const Color accent         = Color(0xFFFF7B5E);
  static const Color accentLight    = Color(0xFFFF9E87);

  // ─── Semantic ───────────────────────────────────────────────────────
  static const Color danger         = Color(0xFFEF4444);
  static const Color dangerLight    = Color(0xFFFEE2E2);
  static const Color dangerSurface  = Color(0xFFFFF0F0);
  static const Color success        = Color(0xFF22C55E);
  static const Color successLight   = Color(0xFFDCFCE7);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningLight   = Color(0xFFFEF3C7);

  // ─── Backgrounds ────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF4F2FF);   // warm lavender tint
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEFECFD);   // soft purple wash
  static const Color cardSurface    = Color(0xFFFAF9FF);

  // ─── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1C1640);
  static const Color textSecondary  = Color(0xFF5C5480);
  static const Color textHint       = Color(0xFF9B94BB);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);
  static const Color textOnDark     = Color(0xFFFFFFFF);

  // ─── Borders ────────────────────────────────────────────────────────
  static const Color border         = Color(0xFFE2DEFF);
  static const Color borderLight    = Color(0xFFEDE9FF);

  // ─── Glass ──────────────────────────────────────────────────────────
  static const Color glassWhite     = Color(0xCCFFFFFF);   // 80% white
  static const Color glassBorder    = Color(0x40FFFFFF);   // 25% white

  // ─── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF4A3FBF), Color(0xFF6B5FE4), Color(0xFF3ECFB2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6B5FE4), Color(0xFF8B80F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient caregiverGradient = LinearGradient(
    colors: [Color(0xFF6B5FE4), Color(0xFF3ECFB2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient patientGradient = LinearGradient(
    colors: [Color(0xFF3ECFB2), Color(0xFF28A896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient1 = LinearGradient(
    colors: [Color(0xFF6B5FE4), Color(0xFF9B93F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient2 = LinearGradient(
    colors: [Color(0xFF3ECFB2), Color(0xFF5BE0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient3 = LinearGradient(
    colors: [Color(0xFFFF7B5E), Color(0xFFFF9E87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient4 = LinearGradient(
    colors: [Color(0xFF5B6EF5), Color(0xFF8B9FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFFF7B5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFF8F5), Color(0xFFF4F2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Shadows ────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF6B5FE4).withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF6B5FE4).withOpacity(0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> primaryShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}