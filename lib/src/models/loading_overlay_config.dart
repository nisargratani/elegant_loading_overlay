/// Configuration data class for the loading overlay.
///
/// Holds all configurable properties that control the appearance
/// and behavior of a loading overlay instance.
library;

import 'package:flutter/widgets.dart';

import '../constants/defaults.dart';
import '../models/loader_type.dart';
import '../models/loading_animation_type.dart';

/// Immutable configuration for a loading overlay instance.
///
/// This class encapsulates all parameters that can be customized
/// when showing a loading overlay. It is used internally by the
/// LoadingOverlayController and passed to the overlay widget.
///
/// {@tool snippet}
/// Creating a config with a message and progress:
///
/// ```dart
/// const config = LoadingOverlayConfig(
///   message: 'Uploading...',
///   progress: 0.45,
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoadingOverlay.show, which accepts these parameters directly.
///  * LoadingOverlayController, which manages the config state.
class LoadingOverlayConfig {
  /// Creates a loading overlay configuration.
  ///
  /// All parameters are optional and default to values defined
  /// in [LoadingOverlayDefaults].
  const LoadingOverlayConfig({
    this.message,
    this.subtitle,
    this.progress,
    this.dismissible = LoadingOverlayDefaults.dismissible,
    this.animationType = LoadingAnimationType.fade,
    this.animationDuration = LoadingOverlayDefaults.animationDuration,
    this.animationCurve = LoadingOverlayDefaults.animationCurve,
    this.barrierColor = LoadingOverlayDefaults.barrierColor,
    this.backgroundColor = LoadingOverlayDefaults.backgroundColor,
    this.loaderColor = LoadingOverlayDefaults.loaderColor,
    this.blurSigma = LoadingOverlayDefaults.blurSigma,
    this.enableBlur = LoadingOverlayDefaults.enableBlur,
    this.borderRadius = LoadingOverlayDefaults.borderRadius,
    this.padding = LoadingOverlayDefaults.padding,
    this.spacing = LoadingOverlayDefaults.spacing,
    this.loaderSize = LoadingOverlayDefaults.loaderSize,
    this.elevation = LoadingOverlayDefaults.elevation,
    this.loaderType = LoaderType.circular,
    this.builder,
    this.onDismiss,
    this.messageStyle,
    this.subtitleStyle,
  });

  /// The primary message displayed below the loader.
  ///
  /// When `null`, no message text is shown.
  ///
  /// Example: `'Loading...'`, `'Please wait'`.
  final String? message;

  /// The subtitle text displayed below the [message].
  ///
  /// When `null`, no subtitle text is shown. Requires [message]
  /// to also be set for proper visual layout.
  ///
  /// Example: `'This may take a moment'`.
  final String? subtitle;

  /// The progress value for a determinate loading indicator.
  ///
  /// Must be between 0.0 and 1.0, or `null` for indeterminate.
  /// When set, a linear progress indicator is shown below the loader.
  final double? progress;

  /// Whether the overlay can be dismissed by tapping outside.
  ///
  /// Defaults to `false`. When `true`, tapping the barrier area
  /// will hide the overlay and call [onDismiss] if provided.
  final bool dismissible;

  /// The type of animation for overlay entry and exit.
  ///
  /// Defaults to [LoadingAnimationType.fade].
  final LoadingAnimationType animationType;

  /// Duration of the overlay entry and exit animation.
  ///
  /// Defaults to [LoadingOverlayDefaults.animationDuration] (300ms).
  final Duration animationDuration;

  /// The curve applied to the overlay animation.
  ///
  /// Defaults to [LoadingOverlayDefaults.animationCurve]
  /// ([Curves.easeInOut]).
  final Curve animationCurve;

  /// The color of the barrier rendered behind the overlay.
  ///
  /// Defaults to [LoadingOverlayDefaults.barrierColor]
  /// (semi-transparent black).
  final Color barrierColor;

  /// The background color of the loading indicator container.
  ///
  /// Defaults to [LoadingOverlayDefaults.backgroundColor] (white).
  final Color backgroundColor;

  /// The color of the loading indicator.
  ///
  /// Defaults to [LoadingOverlayDefaults.loaderColor] (blue).
  final Color loaderColor;

  /// The blur sigma for the background blur effect.
  ///
  /// Defaults to [LoadingOverlayDefaults.blurSigma] (3.0).
  /// Only applies when [enableBlur] is `true`.
  final double blurSigma;

  /// Whether to enable the background blur effect.
  ///
  /// Defaults to `true`. Set to `false` to disable the blur
  /// for better performance on low-end devices.
  final bool enableBlur;

  /// The border radius of the loading indicator container.
  ///
  /// Defaults to [LoadingOverlayDefaults.borderRadius] (16.0).
  final BorderRadius borderRadius;

  /// The padding inside the loading indicator container.
  ///
  /// Defaults to [LoadingOverlayDefaults.padding] (32.0 all sides).
  final EdgeInsets padding;

  /// The spacing between loader elements (loader, message, subtitle).
  ///
  /// Defaults to [LoadingOverlayDefaults.spacing] (16.0).
  final double spacing;

  /// The size of the loading indicator.
  ///
  /// Defaults to [LoadingOverlayDefaults.loaderSize] (48.0).
  final double loaderSize;

  /// The elevation of the loading indicator container.
  ///
  /// Defaults to [LoadingOverlayDefaults.elevation] (8.0).
  final double elevation;

  /// The type of built-in loader to display.
  ///
  /// Defaults to [LoaderType.circular]. Ignored when [builder]
  /// is provided.
  final LoaderType loaderType;

  /// A custom builder for the loading indicator content.
  ///
  /// When provided, this replaces the entire default loading
  /// indicator (loader + message + progress). The [loaderType]
  /// parameter is ignored.
  ///
  /// {@tool snippet}
  /// ```dart
  /// LoadingOverlay.show(
  ///   builder: (context) => const Column(
  ///     mainAxisSize: MainAxisSize.min,
  ///     children: [
  ///       Icon(Icons.cloud_upload, size: 48),
  ///       SizedBox(height: 16),
  ///       Text('Uploading...'),
  ///     ],
  ///   ),
  /// );
  /// ```
  /// {@end-tool}
  final WidgetBuilder? builder;

  /// Called when the overlay is dismissed by the user.
  ///
  /// Only called when [dismissible] is `true` and the user taps
  /// the barrier to dismiss the overlay.
  final VoidCallback? onDismiss;

  /// Custom text style for the [message] text.
  ///
  /// When `null`, uses [LoadingOverlayDefaults.messageTextStyle]
  /// or the theme's text style.
  final TextStyle? messageStyle;

  /// Custom text style for the [subtitle] text.
  ///
  /// When `null`, uses [LoadingOverlayDefaults.subtitleTextStyle]
  /// or the theme's text style.
  final TextStyle? subtitleStyle;

  /// Creates a copy of this config with the given fields replaced.
  ///
  /// All parameters are optional; only specified parameters will
  /// be changed in the returned copy.
  LoadingOverlayConfig copyWith({
    String? message,
    String? subtitle,
    double? progress,
    bool? dismissible,
    LoadingAnimationType? animationType,
    Duration? animationDuration,
    Curve? animationCurve,
    Color? barrierColor,
    Color? backgroundColor,
    Color? loaderColor,
    double? blurSigma,
    bool? enableBlur,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? spacing,
    double? loaderSize,
    double? elevation,
    LoaderType? loaderType,
    WidgetBuilder? builder,
    VoidCallback? onDismiss,
    TextStyle? messageStyle,
    TextStyle? subtitleStyle,
  }) =>
      LoadingOverlayConfig(
        message: message ?? this.message,
        subtitle: subtitle ?? this.subtitle,
        progress: progress ?? this.progress,
        dismissible: dismissible ?? this.dismissible,
        animationType: animationType ?? this.animationType,
        animationDuration: animationDuration ?? this.animationDuration,
        animationCurve: animationCurve ?? this.animationCurve,
        barrierColor: barrierColor ?? this.barrierColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        loaderColor: loaderColor ?? this.loaderColor,
        blurSigma: blurSigma ?? this.blurSigma,
        enableBlur: enableBlur ?? this.enableBlur,
        borderRadius: borderRadius ?? this.borderRadius,
        padding: padding ?? this.padding,
        spacing: spacing ?? this.spacing,
        loaderSize: loaderSize ?? this.loaderSize,
        elevation: elevation ?? this.elevation,
        loaderType: loaderType ?? this.loaderType,
        builder: builder ?? this.builder,
        onDismiss: onDismiss ?? this.onDismiss,
        messageStyle: messageStyle ?? this.messageStyle,
        subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingOverlayConfig &&
        other.message == message &&
        other.subtitle == subtitle &&
        other.progress == progress &&
        other.dismissible == dismissible &&
        other.animationType == animationType &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.barrierColor == barrierColor &&
        other.backgroundColor == backgroundColor &&
        other.loaderColor == loaderColor &&
        other.blurSigma == blurSigma &&
        other.enableBlur == enableBlur &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.spacing == spacing &&
        other.loaderSize == loaderSize &&
        other.elevation == elevation &&
        other.loaderType == loaderType &&
        other.builder == builder &&
        other.onDismiss == onDismiss &&
        other.messageStyle == messageStyle &&
        other.subtitleStyle == subtitleStyle;
  }

  @override
  int get hashCode => Object.hashAll([
        message,
        subtitle,
        progress,
        dismissible,
        animationType,
        animationDuration,
        animationCurve,
        barrierColor,
        backgroundColor,
        loaderColor,
        blurSigma,
        enableBlur,
        borderRadius,
        padding,
        spacing,
        loaderSize,
        elevation,
        loaderType,
        builder,
        onDismiss,
        messageStyle,
        subtitleStyle,
      ]);

  @override
  String toString() => 'LoadingOverlayConfig('
      'message: $message, '
      'loaderType: $loaderType, '
      'progress: $progress, '
      'dismissible: $dismissible'
      ')';
}
