/// An equalizer-style bars loading indicator.
///
/// Displays vertical bars that animate up and down at different
/// rates, similar to an audio equalizer visualization.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// An equalizer-style bars loading indicator.
///
/// {@tool snippet}
/// ```dart
/// const BarsLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.bars, the enum value for this loader.
class BarsLoader extends StatefulWidget {
  /// Creates an equalizer bars loading indicator.
  const BarsLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.barCount = 5,
  });

  /// The overall size of the loader.
  final double size;

  /// The color of the bars.
  final Color color;

  /// The number of bars to display.
  final int barCount;

  @override
  State<BarsLoader> createState() => _BarsLoaderState();
}

class _BarsLoaderState extends State<BarsLoader>
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
  Widget build(BuildContext context) {
    final barWidth = widget.size / (widget.barCount * 2 - 1);
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (index) {
            final delay = index / widget.barCount;
            final phase =
                ((_controller.value + delay) % 1.0) * 2 * math.pi;
            final heightFactor = 0.3 + 0.7 * ((math.sin(phase) + 1) / 2);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: barWidth * 0.3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius:
                      BorderRadius.all(Radius.circular(barWidth / 2)),
                ),
                child: SizedBox(
                  width: barWidth,
                  height: widget.size * heightFactor,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
