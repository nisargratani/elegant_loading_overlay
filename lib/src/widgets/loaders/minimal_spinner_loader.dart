/// A thin line spinner loading indicator.
///
/// Displays a minimal, thin rotating line — ideal for clean
/// and modern UIs that require a subtle loading indicator.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A minimal thin line spinner loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const MinimalSpinnerLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.minimalSpinner, the enum value for this loader.
class MinimalSpinnerLoader extends StatefulWidget {
  /// Creates a minimal spinner loading indicator.
  const MinimalSpinnerLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.strokeWidth = 2.0,
  });

  /// The diameter of the spinner.
  final double size;

  /// The color of the spinner line.
  final Color color;

  /// The stroke width of the line.
  final double strokeWidth;

  @override
  State<MinimalSpinnerLoader> createState() => _MinimalSpinnerLoaderState();
}

class _MinimalSpinnerLoaderState extends State<MinimalSpinnerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
          painter: _MinimalSpinnerPainter(
            progress: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      );
}

class _MinimalSpinnerPainter extends CustomPainter {
  _MinimalSpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final startAngle = 2 * math.pi * progress - math.pi / 2;
    const sweepAngle = math.pi * 0.5;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_MinimalSpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
