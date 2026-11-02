/// A Cupertino-style spinner loading indicator.
///
/// Wraps Flutter's [CupertinoActivityIndicator] for a native
/// iOS loading experience.
library;

import 'package:flutter/cupertino.dart';

import '../../constants/defaults.dart';
import 'loader_extent.dart';

/// A Cupertino-style spinner loading indicator.
///
/// This loader wraps Flutter's built-in [CupertinoActivityIndicator]
/// to provide seamless iOS-style integration.
///
/// {@tool snippet}
/// ```dart
/// const CupertinoSpinnerLoader(
///   size: 48,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoaderType.cupertinoSpinner, the enum value for this loader.
///  * [CupertinoActivityIndicator], the underlying Flutter widget.
class CupertinoSpinnerLoader extends StatelessWidget {
  /// Creates a Cupertino-style spinner loading indicator.
  ///
  /// The spinner's radius is half of [size]; when [size] is 0 or less,
  /// nothing is drawn. When [color] is `null`,
  /// [CupertinoActivityIndicator] uses the system default color.
  const CupertinoSpinnerLoader({
    super.key,
    this.size = LoadingOverlayDefaults.loaderSize,
    this.color,
  });

  /// The size of the spinner.
  final double size;

  /// Optional color override for the spinner.
  ///
  /// When `null`, the system default color is used.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final extent = loaderExtent(size);
    // CupertinoActivityIndicator asserts radius > 0.
    if (extent == 0) return const SizedBox.shrink();
    return SizedBox.square(
      dimension: extent,
      child: CupertinoActivityIndicator(
        radius: extent / 2,
        color: color,
      ),
    );
  }
}
