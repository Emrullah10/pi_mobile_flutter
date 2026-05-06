import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pulsing dot + status text indicator
/// "SYSTEM READY" with animated green/red dot
class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final bool isRecording;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isRecording
        ? 'RECORDING'
        : isOnline
            ? 'SYSTEM READY'
            : 'OFFLINE';

    final dotColor = isRecording
        ? AppColors.secondaryContainer
        : isOnline
            ? AppColors.primaryContainer
            : AppColors.error;

    return Row(
      children: [
        // Pulsing dot
        _PulsingDot(color: dotColor, isActive: isOnline || isRecording),
        const SizedBox(width: 8),
        // Status text
        Text(
          statusText,
          style: AppTypography.h3.copyWith(
            color: AppColors.onSurface,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool isActive;

  const _PulsingDot({required this.color, required this.isActive});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
