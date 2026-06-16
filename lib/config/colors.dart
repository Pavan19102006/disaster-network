import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surface colors (deep navy/charcoal)
  static const Color surface = Color(0xFF0A0E1A);
  static const Color surfaceLight = Color(0xFF111827);
  static const Color surfaceMedium = Color(0xFF1F2937);
  static const Color surfaceElevated = Color(0xFF374151);

  // Emergency / SOS
  static const Color emergency = Color(0xFFEF4444);
  static const Color emergencyDark = Color(0xFFDC2626);
  static const Color emergencyLight = Color(0xFFFCA5A5);

  // Safe / Success
  static const Color safe = Color(0xFF10B981);
  static const Color safeDark = Color(0xFF059669);
  static const Color safeLight = Color(0xFF6EE7B7);

  // Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFCD34D);

  // Info
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFF7DD3FC);

  // Accent (electric indigo)
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentDark = Color(0xFF4F46E5);

  // Mesh active (cyan glow)
  static const Color meshActive = Color(0xFF06B6D4);
  static const Color meshActiveLight = Color(0xFF22D3EE);
  static const Color meshGlow = Color(0x4006B6D4);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Glass
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
  );

  static const RadialGradient sosGlow = RadialGradient(
    colors: [Color(0x66EF4444), Color(0x00EF4444)],
    radius: 0.8,
  );
}
