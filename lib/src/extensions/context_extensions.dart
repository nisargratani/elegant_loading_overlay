/// BuildContext extension methods for convenient loading overlay
/// access.
///
/// Provides quick access to show, hide, and check loading overlay
/// state directly from a [BuildContext].
library;

import 'package:flutter/widgets.dart';

import '../models/loader_type.dart';
import '../models/loading_animation_type.dart';
import '../overlay/loading_overlay.dart';

/// Extension on [BuildContext] for convenient loading overlay access.
///
/// {@tool snippet}
/// ```dart
/// // Show overlay
/// context.showLoadingOverlay(message: 'Loading...');
///
/// // Hide overlay
/// context.hideLoadingOverlay();
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [LoadingOverlay], the main static API.
extension LoadingOverlayContextExtension on BuildContext {
  /// Shows the loading overlay using this context.
  ///
  /// All parameters are optional and default to sensible values.
  ///
  /// This is a convenience method equivalent to calling
  /// [LoadingOverlay.show] with this context.
  ///
  /// ```dart
  /// context.showLoadingOverlay(
  ///   message: 'Please wait...',
  /// );
  /// ```
  void showLoadingOverlay({
    String? message,
    String? subtitle,
    double? progress,
    bool? dismissible,
    LoadingAnimationType? animation,
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
  }) {
    LoadingOverlay.show(
      context: this,
      message: message,
      subtitle: subtitle,
      progress: progress,
      dismissible: dismissible,
      animation: animation,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      barrierColor: barrierColor,
      backgroundColor: backgroundColor,
      loaderColor: loaderColor,
      blurSigma: blurSigma,
      enableBlur: enableBlur,
      borderRadius: borderRadius,
      padding: padding,
      spacing: spacing,
      loaderSize: loaderSize,
      elevation: elevation,
      loaderType: loaderType,
      builder: builder,
      onDismiss: onDismiss,
      messageStyle: messageStyle,
      subtitleStyle: subtitleStyle,
    );
  }

  /// Hides the loading overlay.
  ///
  /// This is a convenience method equivalent to calling
  /// [LoadingOverlay.hide].
  ///
  /// ```dart
  /// context.hideLoadingOverlay();
  /// ```
  void hideLoadingOverlay() {
    LoadingOverlay.hide();
  }
}
