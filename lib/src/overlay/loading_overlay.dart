/// The main static API for showing and hiding loading overlays.
///
/// Provides a simple one-line API for common loading overlay
/// operations while also supporting advanced customization.
library;

import 'package:flutter/widgets.dart';

import '../controller/loading_overlay_controller.dart';
import '../models/loader_type.dart';
import '../models/loading_animation_type.dart';
import '../models/loading_overlay_config.dart';
import '../overlay/overlay_entry_manager.dart';
import '../theme/loading_overlay_theme.dart';
import '../theme/loading_overlay_theme_widget.dart';

/// A simple, powerful API for showing loading overlays in Flutter.
///
/// The [LoadingOverlay] class provides static methods for common
/// operations, and also supports advanced usage through the
/// [LoadingOverlayController] and LoadingOverlayScope.
///
/// ## Simple Usage
///
/// ```dart
/// // Show a basic loading overlay
/// LoadingOverlay.show(context: context);
///
/// // Do some async work
/// await fetchData();
///
/// // Hide the overlay
/// LoadingOverlay.hide();
/// ```
///
/// ## With Message
///
/// ```dart
/// LoadingOverlay.show(
///   context: context,
///   message: 'Loading...',
/// );
/// ```
///
/// ## With Progress
///
/// ```dart
/// LoadingOverlay.show(
///   context: context,
///   message: 'Uploading...',
///   progress: 0.45,
/// );
/// ```
///
/// ## Custom Loader
///
/// ```dart
/// LoadingOverlay.show(
///   context: context,
///   builder: (_) => const MyCustomLoader(),
/// );
/// ```
///
/// See also:
///
///  * [LoadingOverlayController], for programmatic control.
///  * LoadingOverlayScope, for scoped configuration.
///  * [LoadingOverlayTheme], for theming.
///  * [LoadingAnimationType], for animation options.
///  * [LoaderType], for built-in loader styles.
abstract final class LoadingOverlay {
  static final OverlayEntryManager _manager = OverlayEntryManager();
  static final LoadingOverlayController _controller =
      LoadingOverlayController();

  /// Whether a loading overlay is currently visible.
  ///
  /// Returns `true` when [show] has been called and [hide] has not
  /// yet been called.
  ///
  /// ```dart
  /// if (LoadingOverlay.isShowing) {
  ///   LoadingOverlay.hide();
  /// }
  /// ```
  static bool get isShowing => _manager.isShowing;

  /// The global controller instance.
  ///
  /// Use this for advanced control scenarios, such as listening
  /// to state changes.
  ///
  /// ```dart
  /// LoadingOverlay.controller.addListener(() {
  ///   print('Overlay state changed');
  /// });
  /// ```
  static LoadingOverlayController get controller => _controller;

  /// Shows a loading overlay.
  ///
  /// The [context] parameter is required to find the nearest
  /// [Overlay] in the widget tree. All other parameters are
  /// optional and override the defaults or theme values.
  ///
  /// If an overlay is already showing, it will be updated with
  /// the new configuration instead of creating a duplicate.
  ///
  /// ```dart
  /// LoadingOverlay.show(
  ///   context: context,
  ///   message: 'Loading...',
  ///   animation: LoadingAnimationType.scale,
  ///   loaderType: LoaderType.dots,
  /// );
  /// ```
  ///
  /// See also:
  ///
  ///  * [hide], to dismiss the overlay.
  ///  * [toggle], to toggle visibility.
  static void show({
    required BuildContext context,
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
    if (!context.mounted) return;

    // Resolve theme values.
    final theme = LoadingOverlayTheme.of(context);

    final config = LoadingOverlayConfig(
      message: message,
      subtitle: subtitle,
      progress: progress,
      dismissible:
          dismissible ?? theme?.dismissible ?? false,
      animationType:
          animation ?? theme?.animationType ?? LoadingAnimationType.fade,
      animationDuration: animationDuration ??
          theme?.animationDuration ??
          const LoadingOverlayConfig().animationDuration,
      animationCurve: animationCurve ??
          theme?.animationCurve ??
          const LoadingOverlayConfig().animationCurve,
      barrierColor: barrierColor ??
          theme?.barrierColor ??
          const LoadingOverlayConfig().barrierColor,
      backgroundColor: backgroundColor ??
          theme?.backgroundColor ??
          const LoadingOverlayConfig().backgroundColor,
      loaderColor: loaderColor ??
          theme?.loaderColor ??
          const LoadingOverlayConfig().loaderColor,
      blurSigma: blurSigma ??
          theme?.blurSigma ??
          const LoadingOverlayConfig().blurSigma,
      enableBlur: enableBlur ??
          theme?.enableBlur ??
          const LoadingOverlayConfig().enableBlur,
      borderRadius: borderRadius ??
          theme?.borderRadius ??
          const LoadingOverlayConfig().borderRadius,
      padding: padding ??
          theme?.padding ??
          const LoadingOverlayConfig().padding,
      spacing: spacing ??
          theme?.spacing ??
          const LoadingOverlayConfig().spacing,
      loaderSize: loaderSize ??
          theme?.loaderSize ??
          const LoadingOverlayConfig().loaderSize,
      elevation: elevation ??
          theme?.elevation ??
          const LoadingOverlayConfig().elevation,
      loaderType: loaderType ??
          theme?.loaderType ??
          const LoadingOverlayConfig().loaderType,
      builder: builder,
      onDismiss: onDismiss,
      messageStyle:
          messageStyle ?? theme?.messageTextStyle,
      subtitleStyle:
          subtitleStyle ?? theme?.subtitleTextStyle,
    );

    _controller.show(config);
    _manager.show(context, config);
  }

  /// Hides the loading overlay with an exit animation.
  ///
  /// Does nothing if no overlay is currently showing.
  ///
  /// ```dart
  /// LoadingOverlay.hide();
  /// ```
  static Future<void> hide() async {
    _controller.hide();
    await _manager.hide();
  }

  /// Toggles the loading overlay visibility.
  ///
  /// If an overlay is showing, it will be hidden. If no overlay
  /// is showing, one will be displayed with the given parameters.
  ///
  /// The [context] is required when showing (not when hiding).
  ///
  /// ```dart
  /// LoadingOverlay.toggle(context: context);
  /// ```
  static Future<void> toggle({
    BuildContext? context,
    String? message,
    LoaderType? loaderType,
  }) async {
    if (isShowing) {
      await hide();
    } else if (context != null) {
      show(
        context: context,
        message: message,
        loaderType: loaderType,
      );
    }
  }

  /// Returns the [LoadingOverlayThemeData] from the nearest
  /// [LoadingOverlayTheme] ancestor of the given [context].
  ///
  /// Returns `null` if no [LoadingOverlayTheme] is found.
  ///
  /// ```dart
  /// final theme = LoadingOverlay.of(context);
  /// ```
  static LoadingOverlayThemeData? of(BuildContext context) =>
      LoadingOverlayTheme.of(context);
}
