/// A gradient arc spinner loading indicator.
///
/// Shows a rotating arc with a gradient color effect for a
/// modern, polished appearance.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A gradient arc spinner loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const GradientSpinnerLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.gradientSpinner, the enum value for this loader.
class GradientSpinnerLoader extends StatefulWidget {
  /// Creates a gradient spinner loading indicator.
  const GradientSpinnerLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.strokeWidth = 3.5,
  });

  /// The diameter of the spinner.
  final double size;

  /// The primary color of the gradient.
  final Color color;

  /// The stroke width of the arc.
  final double strokeWidth;

  @override
  State<GradientSpinnerLoader> createState() =>
      _GradientSpinnerLoaderState();
}

class _GradientSpinnerLoaderState extends State<GradientSpinnerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: Size.square(widget.size),
          painter: _GradientSpinnerPainter(
            progress: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      );
}

class _GradientSpinnerPainter extends CustomPainter {
  _GradientSpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.7),
        color,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(2 * math.pi * progress),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi * 0.85, false, paint);
  }

  @override
  bool shouldRepaint(_GradientSpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
