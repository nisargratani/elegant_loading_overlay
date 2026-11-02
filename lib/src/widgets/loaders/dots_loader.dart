/// A bouncing dots loading indicator.
///
/// Shows three dots that animate in a wave-like bouncing pattern,
/// commonly seen in chat applications and modern UIs.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';
import 'loader_extent.dart';

/// A bouncing dots loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const DotsLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.dots, the enum value for this loader.
class DotsLoader extends StatefulWidget {
  /// Creates a bouncing dots loading indicator.
  ///
  /// [dotCount] must be at least 1.
  const DotsLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.dotCount = 3,
  }) : assert(dotCount > 0, 'dotCount must be at least 1');

  /// The overall width of the loader; it is half as tall.
  ///
  /// The loader scales down to fit a smaller parent. A negative size
  /// draws nothing.
  final double size;

  /// The color of the dots.
  final Color color;

  /// The number of dots to display.
  ///
  /// Dots are shrunk as needed so they always fit within [size].
  final int dotCount;

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
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
  Widget build(BuildContext context) {
    final size = loaderExtent(widget.size);
    // Nothing to draw; FittedBox also asserts on an empty child on
    // Flutter 3.22.
    if (size == 0) return const SizedBox.shrink();
    // Each dot takes its size plus 0.25 of it as padding on each side,
    // so shrink dots to keep them inside `size` (only affects
    // dotCount > 3).
    final dotSize = math.min(size / 5, size / (widget.dotCount * 1.5));
    // Scales down (never up) when the parent offers less than `size`.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: size,
        height: size / 2,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.dotCount, (index) {
              final delay = index / widget.dotCount;
              final animation =
                  ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
              final bounce = _bounceCurve(animation);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: dotSize * 0.25),
                child: Transform.translate(
                  offset: Offset(0, -bounce * size * 0.25),
                  child: Opacity(
                    opacity: 0.4 + 0.6 * (1 - bounce),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(dimension: dotSize),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  double _bounceCurve(double t) {
    if (t < 0.3) {
      return Curves.easeOut.transform(t / 0.3);
    } else if (t < 0.6) {
      return Curves.easeIn.transform(1 - (t - 0.3) / 0.3);
    }
    return 0;
  }
}
