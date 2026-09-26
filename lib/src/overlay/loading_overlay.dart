/// The main static API for showing and hiding loading overlays.
///
/// Provides a simple one-line API for common loading overlay
/// operations while also supporting advanced customization.
library;

import 'package:flutter/widgets.dart';

import '../constants/defaults.dart';
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
/// ## Always hide, even on errors
///
/// ```dart
/// LoadingOverlay.show(context: context);
/// try {
///   await fetchData();
/// } finally {
///   await LoadingOverlay.hide();
/// }
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
  static final LoadingOverlayController _controller =
      LoadingOverlayController();
  // Weak, so a Navigator that has been removed from the tree can be
  // garbage collected together with its routes.
  static WeakReference<OverlayState>? _host;
  static final OverlayEntryManager _manager = OverlayEntryManager(
    controller: _controller,
    resolveHost: () => _host?.target,
  );

  /// Whether a loading overlay is currently visible.
  ///
  /// Returns `true` when [show] has been called and [hide] has not
  /// yet been called. Becomes `false` as soon as [hide] is called
  /// (while the exit animation is still playing), when the overlay is
  /// dismissed by a barrier tap, or when the [Overlay] hosting it is
  /// removed from the tree.
  ///
  /// ```dart
  /// if (LoadingOverlay.isShowing) {
  ///   LoadingOverlay.hide();
  /// }
  /// ```
  static bool get isShowing => _manager.isShowing;

  /// The global controller instance.
  ///
  /// Its value is the config of the visible overlay, or `null` when
  /// hidden. Listen to it to react to state changes, or drive the
  /// visible overlay with it:
  ///
  /// ```dart
  /// LoadingOverlay.controller.addListener(() {
  ///   debugPrint('Overlay showing: ${LoadingOverlay.controller.isShowing}');
  /// });
  ///
  /// // Update progress without rebuilding the whole config:
  /// final config = LoadingOverlay.controller.value;
  /// if (config != null) {
  ///   LoadingOverlay.controller.update(config.copyWith(progress: 0.8));
  /// }
  /// ```
  ///
  /// `controller.show()` reuses the [Overlay] of the most recent [show]
  /// call; before the first [show] there is no Overlay to use and an
  /// error is reported. Do not dispose this controller.
  static LoadingOverlayController get controller => _controller;

  /// Shows a loading overlay.
  ///
  /// The [context] parameter is required to find the nearest
  /// [Overlay] in the widget tree (normally the one of the enclosing
  /// [Navigator]). Set [useRootOverlay] to `true` to use the root
  /// Overlay instead, so the overlay also covers widgets outside a
  /// nested Navigator (for example a bottom navigation bar).
  ///
  /// All other parameters are optional and override the values of the
  /// nearest [LoadingOverlayTheme], which in turn override
  /// [LoadingOverlayDefaults].
  ///
  /// If an overlay is already showing, it is updated with the new
  /// configuration instead of creating a duplicate; calling [show]
  /// repeatedly is the simplest way to update a message or [progress].
  /// If it is animating out, the exit is cancelled.
  ///
  /// It is safe to call this from `initState` or during a build; the
  /// overlay is then inserted at the end of the current frame. Does
  /// nothing if [context] is no longer mounted.
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
    String? semanticsLabel,
    bool useRootOverlay = false,
  }) {
    if (!context.mounted) return;

    final overlay = Overlay.of(context, rootOverlay: useRootOverlay);
    // A plain lookup (no dependency) so that show() also works from
    // initState and does not make the caller rebuild on theme changes.
    final theme =
        context.getInheritedWidgetOfExactType<LoadingOverlayTheme>()?.data;
    final base = LoadingOverlayConfig.fromTheme(theme);

    final config = LoadingOverlayConfig(
      message: message,
      subtitle: subtitle,
      progress: progress,
      dismissible: dismissible ?? base.dismissible,
      animationType: animation ?? base.animationType,
      animationDuration: animationDuration ?? base.animationDuration,
      animationCurve: animationCurve ?? base.animationCurve,
      barrierColor: barrierColor ?? base.barrierColor,
      backgroundColor: backgroundColor ?? base.backgroundColor,
      loaderColor: loaderColor ?? base.loaderColor,
      blurSigma: blurSigma ?? base.blurSigma,
      enableBlur: enableBlur ?? base.enableBlur,
      borderRadius: borderRadius ?? base.borderRadius,
      padding: padding ?? base.padding,
      spacing: spacing ?? base.spacing,
      loaderSize: loaderSize ?? base.loaderSize,
      elevation: elevation ?? base.elevation,
      loaderType: loaderType ?? base.loaderType,
      builder: builder,
      onDismiss: onDismiss,
      messageStyle: messageStyle ?? base.messageStyle,
      subtitleStyle: subtitleStyle ?? base.subtitleStyle,
      semanticsLabel: semanticsLabel ?? base.semanticsLabel,
    );

    _host = WeakReference(overlay);
    _manager.show(overlay, config);
  }

  /// Hides the loading overlay with an exit animation.
  ///
  /// The returned future completes once the overlay has been removed
  /// (or immediately if nothing is showing). If [show] is called while
  /// the exit animation is running, the overlay stays visible and the
  /// future completes right away.
  ///
  /// ```dart
  /// await LoadingOverlay.hide();
  /// ```
  static Future<void> hide() => _manager.hide();

  /// Toggles the loading overlay visibility.
  ///
  /// If an overlay is showing, it will be hidden. If no overlay
  /// is showing, one will be displayed with the given parameters.
  ///
  /// The [context] is required when showing (not when hiding); without
  /// it, calling [toggle] while hidden does nothing.
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
