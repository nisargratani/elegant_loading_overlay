/// Theme data for the loading overlay package.
///
/// Provides a centralized way to configure the visual appearance
/// of all loading overlays in an application.
library;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/defaults.dart';
import '../models/loader_type.dart';
import '../models/loading_animation_type.dart';

/// Defines the visual properties for loading overlays.
///
/// Used by LoadingOverlayTheme to provide consistent styling
/// across all overlays in a widget subtree.
///
/// {@tool snippet}
/// Creating a custom theme:
///
/// ```dart
/// LoadingOverlayThemeData(
///   backgroundColor: Colors.grey.shade900,
///   loaderColor: Colors.tealAccent,
///   blurSigma: 5.0,
///   animationDuration: const Duration(milliseconds: 400),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoadingOverlayTheme, the InheritedWidget that provides
///    this data.
///  * [LoadingOverlayDefaults], for default values.
@immutable
class LoadingOverlayThemeData with Diagnosticable {
  /// Creates a loading overlay theme data.
  ///
  /// All parameters are optional. When `null`, the corresponding
  /// default from [LoadingOverlayDefaults] is used.
  const LoadingOverlayThemeData({
    this.backgroundColor,
    this.loaderColor,
    this.barrierColor,
    this.messageTextStyle,
    this.subtitleTextStyle,
    this.borderRadius,
    this.padding,
    this.animationDuration,
    this.animationCurve,
    this.animationType,
    this.blurSigma,
    this.enableBlur,
    this.spacing,
    this.loaderSize,
    this.elevation,
    this.loaderType,
    this.dismissible,
    this.iconColor,
  });

  /// Background color of the loading indicator container.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.backgroundColor].
  final Color? backgroundColor;

  /// Color of the loading indicator.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.loaderColor].
  final Color? loaderColor;

  /// Color of the barrier behind the overlay.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.barrierColor].
  final Color? barrierColor;

  /// Text style for the loading message.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.messageTextStyle].
  final TextStyle? messageTextStyle;

  /// Text style for the subtitle text.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.subtitleTextStyle].
  final TextStyle? subtitleTextStyle;

  /// Border radius of the loading indicator container.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.borderRadius].
  final BorderRadius? borderRadius;

  /// Padding inside the loading indicator container.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.padding].
  final EdgeInsets? padding;

  /// Duration of overlay transition animations.
  ///
  /// When `null`, defaults to
  /// [LoadingOverlayDefaults.animationDuration].
  final Duration? animationDuration;

  /// Curve for overlay transition animations.
  ///
  /// When `null`, defaults to
  /// [LoadingOverlayDefaults.animationCurve].
  final Curve? animationCurve;

  /// Default animation type for overlay transitions.
  ///
  /// When `null`, defaults to [LoadingAnimationType.fade].
  final LoadingAnimationType? animationType;

  /// Blur sigma for the background blur effect.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.blurSigma].
  final double? blurSigma;

  /// Whether to enable the background blur effect.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.enableBlur].
  final bool? enableBlur;

  /// Spacing between loader elements.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.spacing].
  final double? spacing;

  /// Size of the loading indicator.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.loaderSize].
  final double? loaderSize;

  /// Elevation of the loading indicator container.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.elevation].
  final double? elevation;

  /// Default loader type.
  ///
  /// When `null`, defaults to [LoaderType.circular].
  final LoaderType? loaderType;

  /// Whether overlays are dismissible by default.
  ///
  /// When `null`, defaults to [LoadingOverlayDefaults.dismissible].
  final bool? dismissible;

  /// Color for icons displayed in the overlay.
  ///
  /// When `null`, defaults to [loaderColor].
  final Color? iconColor;

  /// The effective background color, falling back to the default.
  Color get effectiveBackgroundColor =>
      backgroundColor ?? LoadingOverlayDefaults.backgroundColor;

  /// The effective loader color, falling back to the default.
  Color get effectiveLoaderColor =>
      loaderColor ?? LoadingOverlayDefaults.loaderColor;

  /// The effective barrier color, falling back to the default.
  Color get effectiveBarrierColor =>
      barrierColor ?? LoadingOverlayDefaults.barrierColor;

  /// The effective blur sigma, falling back to the default.
  double get effectiveBlurSigma =>
      blurSigma ?? LoadingOverlayDefaults.blurSigma;

  /// Creates a copy of this theme data with the given fields replaced.
  LoadingOverlayThemeData copyWith({
    Color? backgroundColor,
    Color? loaderColor,
    Color? barrierColor,
    TextStyle? messageTextStyle,
    TextStyle? subtitleTextStyle,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,
    LoadingAnimationType? animationType,
    double? blurSigma,
    bool? enableBlur,
    double? spacing,
    double? loaderSize,
    double? elevation,
    LoaderType? loaderType,
    bool? dismissible,
    Color? iconColor,
  }) =>
      LoadingOverlayThemeData(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        loaderColor: loaderColor ?? this.loaderColor,
        barrierColor: barrierColor ?? this.barrierColor,
        messageTextStyle: messageTextStyle ?? this.messageTextStyle,
        subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
        borderRadius: borderRadius ?? this.borderRadius,
        padding: padding ?? this.padding,
        animationDuration: animationDuration ?? this.animationDuration,
        animationCurve: animationCurve ?? this.animationCurve,
        animationType: animationType ?? this.animationType,
        blurSigma: blurSigma ?? this.blurSigma,
        enableBlur: enableBlur ?? this.enableBlur,
        spacing: spacing ?? this.spacing,
        loaderSize: loaderSize ?? this.loaderSize,
        elevation: elevation ?? this.elevation,
        loaderType: loaderType ?? this.loaderType,
        dismissible: dismissible ?? this.dismissible,
        iconColor: iconColor ?? this.iconColor,
      );

  /// Linearly interpolates between two [LoadingOverlayThemeData].
  ///
  /// Used by animations to smoothly transition between themes.
  ///
  /// The [t] parameter represents the interpolation factor, where
  /// 0.0 returns [a] and 1.0 returns [b].
  static LoadingOverlayThemeData? lerp(
    LoadingOverlayThemeData? a,
    LoadingOverlayThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return LoadingOverlayThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      loaderColor: Color.lerp(a?.loaderColor, b?.loaderColor, t),
      barrierColor: Color.lerp(a?.barrierColor, b?.barrierColor, t),
      messageTextStyle:
          TextStyle.lerp(a?.messageTextStyle, b?.messageTextStyle, t),
      subtitleTextStyle:
          TextStyle.lerp(a?.subtitleTextStyle, b?.subtitleTextStyle, t),
      borderRadius:
          BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      animationDuration: t < 0.5 ? a?.animationDuration : b?.animationDuration,
      animationCurve: t < 0.5 ? a?.animationCurve : b?.animationCurve,
      animationType: t < 0.5 ? a?.animationType : b?.animationType,
      blurSigma: lerpDouble(a?.blurSigma, b?.blurSigma, t),
      enableBlur: t < 0.5 ? a?.enableBlur : b?.enableBlur,
      spacing: lerpDouble(a?.spacing, b?.spacing, t),
      loaderSize: lerpDouble(a?.loaderSize, b?.loaderSize, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      loaderType: t < 0.5 ? a?.loaderType : b?.loaderType,
      dismissible: t < 0.5 ? a?.dismissible : b?.dismissible,
      iconColor: Color.lerp(a?.iconColor, b?.iconColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingOverlayThemeData &&
        other.backgroundColor == backgroundColor &&
        other.loaderColor == loaderColor &&
        other.barrierColor == barrierColor &&
        other.messageTextStyle == messageTextStyle &&
        other.subtitleTextStyle == subtitleTextStyle &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.animationType == animationType &&
        other.blurSigma == blurSigma &&
        other.enableBlur == enableBlur &&
        other.spacing == spacing &&
        other.loaderSize == loaderSize &&
        other.elevation == elevation &&
        other.loaderType == loaderType &&
        other.dismissible == dismissible &&
        other.iconColor == iconColor;
  }

  @override
  int get hashCode => Object.hashAll([
        backgroundColor,
        loaderColor,
        barrierColor,
        messageTextStyle,
        subtitleTextStyle,
        borderRadius,
        padding,
        animationDuration,
        animationCurve,
        animationType,
        blurSigma,
        enableBlur,
        spacing,
        loaderSize,
        elevation,
        loaderType,
        dismissible,
        iconColor,
      ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(ColorProperty('loaderColor', loaderColor))
      ..add(ColorProperty('barrierColor', barrierColor))
      ..add(
        DiagnosticsProperty<TextStyle>(
          'messageTextStyle',
          messageTextStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<TextStyle>(
          'subtitleTextStyle',
          subtitleTextStyle,
        ),
      )
      ..add(
        DiagnosticsProperty<BorderRadius>('borderRadius', borderRadius),
      )
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(
        DiagnosticsProperty<Duration>(
          'animationDuration',
          animationDuration,
        ),
      )
      ..add(DoubleProperty('blurSigma', blurSigma))
      ..add(DoubleProperty('spacing', spacing))
      ..add(DoubleProperty('loaderSize', loaderSize))
      ..add(DoubleProperty('elevation', elevation))
      ..add(EnumProperty<LoaderType>('loaderType', loaderType))
      ..add(
        DiagnosticsProperty<bool>('dismissible', dismissible),
      )
      ..add(ColorProperty('iconColor', iconColor));
  }
}
