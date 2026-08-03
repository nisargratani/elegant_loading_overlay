/// A Material Design spinner loading indicator.
///
/// Wraps Flutter's [CircularProgressIndicator] for a native
/// Material Design loading experience.
library;

import 'package:flutter/material.dart';

import '../../constants/defaults.dart';

/// A Material Design spinner loading indicator.
///
/// This loader wraps Flutter's built-in [CircularProgressIndicator]
/// to provide seamless Material Design integration.
///
/// {@tool snippet}
/// ```dart
/// const MaterialSpinnerLoader(
///   color: Colors.blue,
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.materialSpinner, the enum value for this loader.
///  * [CircularProgressIndicator], the underlying Flutter widget.
class MaterialSpinnerLoader extends StatelessWidget {
  /// Creates a Material Design spinner loading indicator.
  const MaterialSpinnerLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color = LoadingOverlayDefaults.loaderColor,
    this.strokeWidth = 3.0,
  });

  /// The size (width and height) of the spinner.
  final double size;

  /// The color of the spinner.
  final Color color;

  /// The stroke width of the spinner.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: strokeWidth,
        ),
      );
}
