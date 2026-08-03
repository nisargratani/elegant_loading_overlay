/// A bouncing dots loading indicator.
///
/// Shows three dots that animate in a wave-like bouncing pattern,
/// commonly seen in chat applications and modern UIs.
library;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

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
  const DotsLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.dotCount = 3,
  });

  /// The overall size of the loader.
  final double size;

  /// The color of the dots.
  final Color color;

  /// The number of dots to display.
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
    final dotSize = widget.size / 5;
    return SizedBox(
      width: widget.size,
      height: widget.size / 2,
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
                offset: Offset(0, -bounce * widget.size * 0.25),
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
