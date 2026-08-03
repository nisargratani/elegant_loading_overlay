/// A rotating circular arc loading indicator.
///
/// Displays a colored arc that continuously rotates, providing
/// a familiar loading spinner experience.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A rotating circular arc loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const CircularLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.circular, the enum value for this loader.
class CircularLoader extends StatefulWidget {
  /// Creates a circular loading indicator.
  ///
  /// The [size] defaults to [LoadingOverlayDefaults.loaderSize].
  /// The [color] defaults to [LoadingOverlayDefaults.loaderColor].
  /// The [strokeWidth] defaults to 3.0.
  const CircularLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.strokeWidth = 3.0,
  });

  /// The size (width and height) of the loader.
  final double size;

  /// The color of the arc.
  final Color color;

  /// The width of the arc stroke.
  final double strokeWidth;

  @override
  State<CircularLoader> createState() => _CircularLoaderState();
}

class _CircularLoaderState extends State<CircularLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
          painter: _CircularPainter(
            progress: _controller.value,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      );
}

class _CircularPainter extends CustomPainter {
  _CircularPainter({
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
    const sweepAngle = math.pi * 1.4;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_CircularPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
