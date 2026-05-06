import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Waveform visualizer using CustomPaint
/// Renders vertical bars with varying heights — static mockup or real data
class WaveformVisualizer extends StatelessWidget {
  final int barCount;
  final double height;
  final Color? activeColor;
  final bool isActive;
  final List<double>? data;

  const WaveformVisualizer({
    super.key,
    this.barCount = 10,
    this.height = 48,
    this.activeColor,
    this.isActive = false,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          barCount: barCount,
          activeColor: activeColor ?? AppColors.primaryContainer,
          isActive: isActive,
          data: data,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final int barCount;
  final Color activeColor;
  final bool isActive;
  final List<double>? data;
  final Random _random = Random(42); // Fixed seed for consistent look

  _WaveformPainter({
    required this.barCount,
    required this.activeColor,
    required this.isActive,
    this.data,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = (size.width - (barCount - 1) * 2) / barCount;
    final maxHeight = size.height;

    for (int i = 0; i < barCount; i++) {
      final heightFraction = data != null && i < data!.length
          ? data![i].clamp(0.0, 1.0)
          : _random.nextDouble() * 0.8 + 0.1;

      final barHeight = maxHeight * heightFraction;
      final opacity = isActive ? heightFraction : heightFraction * 0.5;

      final paint = Paint()
        ..color = activeColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          i * (barWidth + 2),
          maxHeight - barHeight,
          barWidth,
          barHeight,
        ),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.data != data;
  }
}
