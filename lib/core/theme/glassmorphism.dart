import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Glassmorphism decoration utilities
/// "High-Fidelity Intelligence" — frosted glass panels with light-leak edges
class Glassmorphism {
  Glassmorphism._();

  /// Standard glass panel — cards, containers
  /// background: surface-container @ 80% + blur(24px)
  /// top+left border: white @ 10%, bottom+right: black @ 50%
  static BoxDecoration glassPanel({
    double borderRadius = 12,
    Color? borderColor,
    double borderOpacity = 0.3,
  }) {
    return BoxDecoration(
      color: AppColors.glassPanel,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Light glass panel — status bars, floating elements
  static BoxDecoration glassPanelLight({
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: const Color(0x66303638), // surface-variant @ 40%
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Card with cyan border glow — AI summary, analysis cards
  static BoxDecoration glassCardCyan({
    double borderRadius = 8,
    double glowIntensity = 0.15,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceContainer.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.primaryFixedDim.withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryFixedDim.withValues(alpha: glowIntensity),
          blurRadius: 20,
        ),
        const BoxShadow(
          color: Color(0x1AFFFFFF), // inner top-left light leak
          blurRadius: 0,
          spreadRadius: 0,
          offset: Offset(1, 1),
        ),
      ],
    );
  }

  /// Red glow — recording state
  static BoxDecoration glowRed({
    double borderRadius = 100,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.secondaryContainer.withValues(alpha: 0.2),
          blurRadius: 40,
        ),
      ],
    );
  }

  /// Cyan glow — active/powered-on
  static BoxDecoration glowCyan({
    double borderRadius = 8,
    double intensity = 0.15,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryContainer.withValues(alpha: intensity),
          blurRadius: 20,
        ),
      ],
    );
  }

  /// BackdropFilter wrapper for blur effect
  static Widget blurBackground({
    required Widget child,
    double sigma = 24,
    double borderRadius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }
}
