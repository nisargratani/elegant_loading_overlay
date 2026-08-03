/// A pulsing circle loading indicator.
///
/// Displays a circle that rhythmically scales up and down with
/// an opacity change for a breathing effect.
library;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A pulsing circle loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const PulseLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.pulse, the enum value for this loader.
class PulseLoader extends StatefulWidget {
  /// Creates a pulsing circle loading indicator.
  const PulseLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
  });

  /// The maximum size of the pulse circle.
  final double size;

  /// The color of the pulse circle.
  final Color color;

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          child: Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(dimension: widget.size),
                ),
              ),
            ),
          ),
        ),
      );
}
