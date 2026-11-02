/// A spinning ring with a gap loading indicator.
///
/// Displays a ring with a visible gap that continuously rotates,
/// providing a clean, modern loading experience.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';
import 'loader_extent.dart';

/// A spinning ring with a gap loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const RingLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.ring, the enum value for this loader.
class RingLoader extends StatefulWidget {
  /// Creates a spinning ring loading indicator.
  const RingLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.strokeWidth = 3.0,
  });

  /// The diameter of the ring.
  final double size;

  /// The color of the ring.
  final Color color;

  /// The stroke width of the ring.
  final double strokeWidth;

  @override
  State<RingLoader> createState() => _RingLoaderState();
}

class _RingLoaderState extends State<RingLoader>
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

  // The painter listens to the controller directly, so each frame
  // only repaints instead of rebuilding this widget.
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(loaderExtent(widget.size)),
        painter: _RingPainter(
          animation: _controller,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter({
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
    // Background ring (faded).
    final bgPaint = Paint()
      // 15% opacity; withAlpha (not withValues) keeps Flutter 3.22 support.
      ..color = color.withAlpha(38)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawOval(rect, bgPaint);

    // Foreground arc.
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = 2 * math.pi * progress - math.pi / 2;
    const sweepAngle = math.pi * 0.8;

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      animation != oldDelegate.animation ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
