/// InheritedWidget that provides [LoadingOverlayThemeData] to its
/// descendants.
///
/// Wrap a subtree with [LoadingOverlayTheme] to configure the
/// appearance of all loading overlays within that subtree.
library;

import 'package:flutter/material.dart';

import 'loading_overlay_theme.dart';

/// An inherited widget that provides [LoadingOverlayThemeData] to
/// loading overlays in the widget tree.
///
/// {@tool snippet}
/// Wrapping a MaterialApp with a loading overlay theme:
///
/// ```dart
/// LoadingOverlayTheme(
///   data: LoadingOverlayThemeData(
///     loaderColor: Colors.teal,
///     backgroundColor: Colors.white,
///     blurSigma: 5.0,
///   ),
///   child: MaterialApp(
///     home: MyHomePage(),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [LoadingOverlayThemeData], which defines the visual properties.
///  * LoadingOverlay, which uses this theme when showing overlays.
class LoadingOverlayTheme extends InheritedWidget {
  /// Creates a loading overlay theme.
  ///
  /// The [data] and [child] parameters are required.
  const LoadingOverlayTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The theme data provided to descendant loading overlays.
  final LoadingOverlayThemeData data;

  /// Returns the [LoadingOverlayThemeData] from the nearest
  /// [LoadingOverlayTheme] ancestor, or `null` if none exists.
  ///
  /// Typical usage:
  ///
  /// ```dart
  /// final theme = LoadingOverlayTheme.of(context);
  /// ```
  static LoadingOverlayThemeData? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LoadingOverlayTheme>()
      ?.data;

  @override
  bool updateShouldNotify(LoadingOverlayTheme oldWidget) =>
      data != oldWidget.data;
}
