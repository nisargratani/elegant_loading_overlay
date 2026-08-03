/// An expanding ripple rings loading indicator.
///
/// Shows concentric rings that expand outward from the center
/// while fading out, creating a radar/sonar effect.
library;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// An expanding ripple rings loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const RippleLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.ripple, the enum value for this loader.
class RippleLoader extends StatefulWidget {
  /// Creates a ripple rings loading indicator.
  const RippleLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.ringCount = 2,
  });

  /// The maximum size of the ripple.
  final double size;

  /// The color of the ripple rings.
  final Color color;

  /// The number of concurrent ripple rings.
  final int ringCount;

  @override
  State<RippleLoader> createState() => _RippleLoaderState();
}

class _RippleLoaderState extends State<RippleLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
        builder: (context, child) => SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(widget.ringCount, (index) {
              final delay = index / widget.ringCount;
              final progress =
                  ((_controller.value + delay) % 1.0).clamp(0.0, 1.0);
              final scale = 0.2 + 0.8 * progress;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color,
                        width: 2.5,
                      ),
                    ),
                    child: SizedBox.square(dimension: widget.size),
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
