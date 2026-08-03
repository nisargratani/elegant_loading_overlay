/// Controller for managing loading overlay state.
///
/// Uses [ValueNotifier] for lightweight, reactive state management
/// without requiring streams or external dependencies.
library;

import 'package:flutter/foundation.dart';

import '../models/loading_overlay_config.dart';

/// Controls the visibility and configuration of a loading overlay.
///
/// This controller uses [ValueNotifier] to notify listeners when
/// the overlay state changes. It provides methods to show, hide,
/// and toggle the overlay, with built-in stacking protection to
/// ensure only one overlay is displayed at a time.
///
/// {@tool snippet}
/// Using the controller directly:
///
/// ```dart
/// final controller = LoadingOverlayController();
///
/// // Show with default config
/// controller.show();
///
/// // Show with custom config
/// controller.show(
///   const LoadingOverlayConfig(message: 'Loading...'),
/// );
///
/// // Check visibility
/// if (controller.isShowing) {
///   controller.hide();
/// }
///
/// // Don't forget to dispose
/// controller.dispose();
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [LoadingOverlayConfig], which defines the overlay appearance.
///  * LoadingOverlay, which provides a static API using this
///    controller internally.
class LoadingOverlayController extends ValueNotifier<LoadingOverlayConfig?> {
  /// Creates a loading overlay controller.
  ///
  /// The overlay is initially hidden (value is `null`).
  LoadingOverlayController() : super(null);

  bool _isDisposed = false;

  /// Whether the loading overlay is currently visible.
  ///
  /// Returns `true` when [show] has been called and [hide] has not
  /// yet been called.
  bool get isShowing => value != null;

  /// Whether this controller has been disposed.
  ///
  /// A disposed controller cannot show or hide overlays.
  bool get isDisposed => _isDisposed;

  /// Shows the loading overlay with the given [config].
  ///
  /// If the overlay is already visible, the config is updated
  /// without creating a new overlay (stacking protection).
  ///
  /// If [config] is `null`, a default [LoadingOverlayConfig] is used.
  ///
  /// Does nothing if the controller has been disposed.
  ///
  /// ```dart
  /// controller.show(
  ///   const LoadingOverlayConfig(message: 'Please wait...'),
  /// );
  /// ```
  void show([LoadingOverlayConfig? config]) {
    if (_isDisposed) return;
    value = config ?? const LoadingOverlayConfig();
  }

  /// Hides the loading overlay.
  ///
  /// Does nothing if the overlay is not currently showing or if
  /// the controller has been disposed.
  ///
  /// ```dart
  /// controller.hide();
  /// ```
  void hide() {
    if (_isDisposed) return;
    value = null;
  }

  /// Toggles the loading overlay visibility.
  ///
  /// If the overlay is currently showing, it will be hidden.
  /// If it is hidden, it will be shown with the given [config]
  /// or a default config.
  ///
  /// Does nothing if the controller has been disposed.
  ///
  /// ```dart
  /// controller.toggle();
  /// ```
  void toggle([LoadingOverlayConfig? config]) {
    if (_isDisposed) return;
    if (isShowing) {
      hide();
    } else {
      show(config);
    }
  }

  /// Updates the current overlay configuration without hiding and
  /// re-showing.
  ///
  /// Does nothing if the overlay is not currently showing or if
  /// the controller has been disposed.
  ///
  /// This is useful for updating progress values or messages while
  /// the overlay is visible.
  ///
  /// ```dart
  /// controller.update(
  ///   controller.value!.copyWith(progress: 0.75),
  /// );
  /// ```
  void update(LoadingOverlayConfig config) {
    if (_isDisposed || !isShowing) return;
    value = config;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
