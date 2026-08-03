/// A rotating 3D cube loading indicator.
///
/// Shows a square that rotates along the Y-axis, creating a
/// pseudo-3D cube effect.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A rotating 3D cube loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const CubeLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.cube, the enum value for this loader.
class CubeLoader extends StatefulWidget {
  /// Creates a rotating cube loading indicator.
  const CubeLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
  });

  /// The size of the cube face.
  final double size;

  /// The color of the cube.
  final Color color;

  @override
  State<CubeLoader> createState() => _CubeLoaderState();
}

class _CubeLoaderState extends State<CubeLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubeSize = widget.size * 0.6;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;
          final scaleX = math.cos(angle).abs().clamp(0.15, 1.0);
          return Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Opacity(
                opacity: 0.5 + 0.5 * scaleX,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius:
                        BorderRadius.all(Radius.circular(cubeSize * 0.15)),
                  ),
                  child: SizedBox.square(dimension: cubeSize),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
