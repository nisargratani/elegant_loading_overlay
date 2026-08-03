/// Factory widget that creates the appropriate built-in loader
/// based on the [LoaderType].
///
/// Maps each [LoaderType] enum value to its corresponding loader
/// widget implementation.
library;

import 'package:flutter/material.dart';

import '../../models/loader_type.dart';
import 'bars_loader.dart';
import 'circular_loader.dart';
import 'cube_loader.dart';
import 'cupertino_spinner_loader.dart';
import 'dots_loader.dart';
import 'gradient_spinner_loader.dart';
import 'material_spinner_loader.dart';
import 'minimal_spinner_loader.dart';
import 'pulse_loader.dart';
import 'ring_loader.dart';
import 'ripple_loader.dart';

/// A factory widget that renders the appropriate loading indicator
/// based on the specified [loaderType].
///
/// {@tool snippet}
/// ```dart
/// const LoadingIndicator(
///   loaderType: LoaderType.dots,
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [LoaderType], which defines the available loader types.
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator of the specified type.
  const LoadingIndicator({
    required this.loaderType,
    super.key,
    this.color,
    this.size,
  });

  /// The type of loader to display.
  final LoaderType loaderType;

  /// The color of the loader.
  ///
  /// When `null`, each loader uses its own default color.
  final Color? color;

  /// The size of the loader.
  ///
  /// When `null`, each loader uses its own default size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    switch (loaderType) {
      case LoaderType.circular:
        return CircularLoader(
          color: color ?? const CircularLoader().color,
          size: size ?? const CircularLoader().size,
        );
      case LoaderType.dots:
        return DotsLoader(
          color: color ?? const DotsLoader().color,
          size: size ?? const DotsLoader().size,
        );
      case LoaderType.pulse:
        return PulseLoader(
          color: color ?? const PulseLoader().color,
          size: size ?? const PulseLoader().size,
        );
      case LoaderType.ripple:
        return RippleLoader(
          color: color ?? const RippleLoader().color,
          size: size ?? const RippleLoader().size,
        );
      case LoaderType.bars:
        return BarsLoader(
          color: color ?? const BarsLoader().color,
          size: size ?? const BarsLoader().size,
        );
      case LoaderType.cube:
        return CubeLoader(
          color: color ?? const CubeLoader().color,
          size: size ?? const CubeLoader().size,
        );
      case LoaderType.ring:
        return RingLoader(
          color: color ?? const RingLoader().color,
          size: size ?? const RingLoader().size,
        );
      case LoaderType.gradientSpinner:
        return GradientSpinnerLoader(
          color: color ?? const GradientSpinnerLoader().color,
          size: size ?? const GradientSpinnerLoader().size,
        );
      case LoaderType.minimalSpinner:
        return MinimalSpinnerLoader(
          color: color ?? const MinimalSpinnerLoader().color,
          size: size ?? const MinimalSpinnerLoader().size,
        );
      case LoaderType.materialSpinner:
        return MaterialSpinnerLoader(
          color: color ?? const MaterialSpinnerLoader().color,
          size: size ?? const MaterialSpinnerLoader().size,
        );
      case LoaderType.cupertinoSpinner:
        return CupertinoSpinnerLoader(
          size: size ?? const CupertinoSpinnerLoader().size,
          color: color,
        );
    }
  }
}
