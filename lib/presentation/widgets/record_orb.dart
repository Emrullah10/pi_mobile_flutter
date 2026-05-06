import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Animated Record Orb — the signature interaction element
/// 160x160 circle with mic icon, pulsing red ring when recording
class RecordOrb extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordOrb({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<RecordOrb> createState() => _RecordOrbState();
}

class _RecordOrbState extends State<RecordOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RecordOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Orb
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isRecording ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHighest,
                    border: Border.all(
                      color: widget.isRecording
                          ? AppColors.secondaryContainer
                              .withValues(alpha: _pulseAnimation.value)
                          : AppColors.outlineVariant,
                      width: 2,
                    ),
                    boxShadow: widget.isRecording
                        ? [
                            BoxShadow(
                              color: AppColors.secondaryContainer
                                  .withValues(alpha: _pulseAnimation.value * 0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: widget.isRecording
                          ? Container(
                              key: const ValueKey('stop'),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : Icon(
                              Icons.mic,
                              key: const ValueKey('mic'),
                              size: 64,
                              color: AppColors.secondaryContainer,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Label
        Text(
          widget.isRecording ? 'TAP TO STOP' : 'INITIATE CAPTURE',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
