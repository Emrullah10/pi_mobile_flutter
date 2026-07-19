import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable Glassmorphic container widget
/// Matches the Stitch "glass-panel" CSS class
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double? borderOpacity;
  final double blurSigma;
  final bool showTopLeftBorder;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.borderOpacity,
    this.blurSigma = 24,
    this.showTopLeftBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassPanel,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor?.withValues(alpha: borderOpacity ?? 0.3) ??
                  (showTopLeftBorder 
                      ? AppColors.glassBorder 
                      : AppColors.outlineVariant.withValues(alpha: 0.3)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
