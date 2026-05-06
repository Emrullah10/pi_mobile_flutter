import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Color-coded speaker badge pill
/// SPEAKER 1 = cyan, SPEAKER 2 = gold, SPEAKER 3 = red
class SpeakerBadge extends StatelessWidget {
  final String speaker;
  final int speakerIndex;

  const SpeakerBadge({
    super.key,
    required this.speaker,
    required this.speakerIndex,
  });

  Color get _color {
    switch (speakerIndex % 3) {
      case 0:
        return AppColors.primaryFixedDim;
      case 1:
        return AppColors.tertiaryFixedDim;
      case 2:
        return AppColors.secondary;
      default:
        return AppColors.primaryFixedDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        speaker.toUpperCase(),
        style: AppTypography.labelCaps.copyWith(
          color: _color,
          fontSize: 10,
        ),
      ),
    );
  }
}
