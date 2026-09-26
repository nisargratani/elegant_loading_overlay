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
  State<GradientSpinnerLoader> createState() => _GradientSpinnerLoaderState();
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

  // The painter listens to the controller directly, so each frame
  // only repaints instead of rebuilding this widget.
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(widget.size),
        painter: _GradientSpinnerPainter(
          animation: _controller,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
        ),
      );
}

class _GradientSpinnerPainter extends CustomPainter {
  _GradientSpinnerPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [
        // 0%, 30% and 70% opacity; withAlpha (not withValues) keeps
        // Flutter 3.22 support.
        color.withAlpha(0),
        color.withAlpha(77),
        color.withAlpha(179),
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
      animation != oldDelegate.animation ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
