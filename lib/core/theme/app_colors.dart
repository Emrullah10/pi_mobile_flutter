import 'package:flutter/material.dart';

/// Whisper Pi Summary Hub — Design Token Colors
/// Extracted from Stitch Project ID: 16952241547918640548
class AppColors {
  AppColors._();

  // ─── Background & Surface ───
  static const Color background = Color(0xFF0D1516);
  static const Color surface = Color(0xFF0D1516);
  static const Color surfaceDim = Color(0xFF0D1516);
  static const Color surfaceBright = Color(0xFF333A3C);
  static const Color surfaceContainerLowest = Color(0xFF080F11);
  static const Color surfaceContainerLow = Color(0xFF161D1F);
  static const Color surfaceContainer = Color(0xFF1A2123);
  static const Color surfaceContainerHigh = Color(0xFF242B2D);
  static const Color surfaceContainerHighest = Color(0xFF2F3638);
  static const Color surfaceVariant = Color(0xFF2F3638);

  // ─── Primary (Electric Blue) ───
  static const Color primary = Color(0xFFBAF2FF);
  static const Color primaryContainer = Color(0xFF00E0FF);
  static const Color primaryFixed = Color(0xFFA5EEFF);
  static const Color primaryFixedDim = Color(0xFF00DAF8);
  static const Color onPrimary = Color(0xFF00363F);
  static const Color onPrimaryContainer = Color(0xFF005F6D);
  static const Color inversePrimary = Color(0xFF006877);

  // ─── Secondary (Vibrant Red — Record) ───
  static const Color secondary = Color(0xFFFFB3B2);
  static const Color secondaryContainer = Color(0xFFFF525C);
  static const Color onSecondary = Color(0xFF680012);
  static const Color onSecondaryContainer = Color(0xFF5B000F);

  // ─── Tertiary (Amber/Gold — Highlights) ───
  static const Color tertiary = Color(0xFFFFE6B6);
  static const Color tertiaryContainer = Color(0xFFFEC42E);
  static const Color tertiaryFixed = Color(0xFFFFDF9D);
  static const Color tertiaryFixedDim = Color(0xFFF7BE27);
  static const Color onTertiary = Color(0xFF3F2E00);
  static const Color onTertiaryContainer = Color(0xFF6F5200);

  // ─── On Surface ───
  static const Color onBackground = Color(0xFFDCE4E6);
  static const Color onSurface = Color(0xFFDCE4E6);
  static const Color onSurfaceVariant = Color(0xFFBAC9CD);

  // ─── Error ───
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ─── Outline ───
  static const Color outline = Color(0xFF859397);
  static const Color outlineVariant = Color(0xFF3B494C);

  // ─── Inverse ───
  static const Color inverseSurface = Color(0xFFDCE4E6);
  static const Color inverseOnSurface = Color(0xFF2A3233);

  // ─── Functional (Semantic shortcuts) ───
  static const Color cyan400 = Color(0xFF22D3EE); // Tailwind cyan-400 approx
  static const Color zinc950 = Color(0xFF09090B);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF525252);

  // ─── Glassmorphism ───
  static const Color glassPanel = Color(0xCC1A2123); // surface-container @ 80%
  static const Color glassPanelLight = Color(0x661A2123); // @ 40%
  static const Color glassBorder = Color(0x1AFFFFFF); // white @ 10%
  static const Color glassBorderDark = Color(0x80000000); // black @ 50%
}
