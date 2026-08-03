/// Default constant values used throughout the loading overlay package.
///
/// These constants provide sensible defaults for all configurable
/// properties, ensuring consistent behavior when no custom values
/// are specified.
library;

import 'dart:ui';

import 'package:flutter/material.dart';

/// Default constant values for the loading overlay.
///
/// This class provides sensible defaults that can be overridden
/// through LoadingOverlayConfig or LoadingOverlayThemeData.
///
/// All values are chosen to provide a visually appealing and
/// accessible loading experience across all platforms.
abstract final class LoadingOverlayDefaults {
  /// Default animation duration for overlay transitions.
  ///
  /// Set to 300ms for smooth, perceivable transitions without
  /// feeling sluggish.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Default animation curve for overlay transitions.
  ///
  /// Uses [Curves.easeInOut] for natural-feeling motion.
  static const Curve animationCurve = Curves.easeInOut;

  /// Default blur sigma for the background blur effect.
  ///
  /// Set to 3.0 for a subtle but noticeable blur.
  static const double blurSigma = 3;

  /// Default barrier color rendered behind the overlay.
  ///
  /// Uses semi-transparent black for a dimming effect.
  static const Color barrierColor = Color(0x80000000);

  /// Default background color for the loading indicator container.
  ///
  /// Uses white for light theme contexts.
  static const Color backgroundColor = Colors.white;

  /// Default color for the loading indicator.
  ///
  /// Uses the Material Design primary blue.
  static const Color loaderColor = Color(0xFF2196F3);

  /// Default border radius for the loading indicator container.
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(16));

  /// Default padding inside the loading indicator container.
  static const EdgeInsets padding = EdgeInsets.all(32);

  /// Default spacing between loader elements.
  static const double spacing = 16;

  /// Default size for the loading indicator.
  static const double loaderSize = 48;

  /// Default elevation for the loading indicator container.
  static const double elevation = 8;

  /// Default text style for the loading message.
  static const TextStyle messageTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF333333),
  );

  /// Default text style for the subtitle text.
  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF888888),
  );

  /// Whether the overlay is dismissible by tapping outside by default.
  static const bool dismissible = false;

  /// Whether to show a blur effect on the background by default.
  static const bool enableBlur = true;

  /// Image filter for the blur effect using the default [blurSigma].
  static final ImageFilter blurFilter = ImageFilter.blur(
    sigmaX: blurSigma,
    sigmaY: blurSigma,
  );
}
