/// Manages the [OverlayEntry] lifecycle for loading overlays.
///
/// Handles creation, insertion, update, and removal of overlay
/// entries in the Flutter overlay system, with stacking protection
/// and safe context handling.
library;

import 'package:flutter/material.dart';

import '../models/loading_overlay_config.dart';
import 'overlay_widget.dart';

/// Manages the lifecycle of loading overlay entries.
///
/// This class is responsible for:
/// - Creating and inserting [OverlayEntry] instances
/// - Updating overlay content when config changes
/// - Animating exit before removal
/// - Stacking protection (only one overlay at a time)
/// - Safe handling of disposed contexts
///
/// This class is used internally by LoadingOverlay and
/// LoadingOverlayScope. It should not be instantiated directly.
///
/// See also:
///
///  * [OverlayWidget], the visual widget rendered by the entry.
///  * LoadingOverlayController, which drives the state changes.
class OverlayEntryManager {
  /// Creates an overlay entry manager.
  OverlayEntryManager();

  OverlayEntry? _overlayEntry;
  GlobalKey<OverlayWidgetState>? _widgetKey;
  bool _isAnimatingOut = false;

  /// Whether an overlay is currently visible.
  bool get isShowing => _overlayEntry != null;

  /// Shows the overlay with the given [config] using the
  /// provided [context] to find the nearest [Overlay].
  ///
  /// If an overlay is already showing, updates its config instead
  /// of creating a new entry (stacking protection).
  ///
  /// Does nothing if the [context] is no longer mounted.
  void show(BuildContext context, LoadingOverlayConfig config) {
    if (!context.mounted) return;

    // If already showing, update the existing overlay.
    if (_overlayEntry != null) {
      _currentConfig = config;
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _widgetKey = GlobalKey<OverlayWidgetState>();
    _currentConfig = config;

    _overlayEntry = OverlayEntry(
      builder: (context) => OverlayWidget(
        key: _widgetKey,
        config: _currentConfig!,
        onDismiss: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  LoadingOverlayConfig? _currentConfig;

  /// Updates the overlay config without removing and re-inserting.
  ///
  /// Does nothing if no overlay is currently showing.
  void update(LoadingOverlayConfig config) {
    if (_overlayEntry == null) return;
    _currentConfig = config;
    _overlayEntry!.markNeedsBuild();
  }

  /// Hides the overlay with an exit animation.
  ///
  /// The overlay entry is removed after the animation completes.
  /// Does nothing if no overlay is showing or if an exit animation
  /// is already in progress.
  Future<void> hide() async {
    if (_overlayEntry == null || _isAnimatingOut) return;

    _isAnimatingOut = true;

    // Animate out if the widget state is available.
    final widgetState = _widgetKey?.currentState;
    if (widgetState != null && widgetState.mounted) {
      await widgetState.animateOut();
    }

    _removeOverlay();
    _isAnimatingOut = false;
  }

  /// Immediately removes the overlay without animation.
  ///
  /// Use [hide] for animated removal. This method is for cleanup
  /// scenarios like disposal.
  void removeImmediately() {
    _isAnimatingOut = false;
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _widgetKey = null;
    _currentConfig = null;
  }

  /// Disposes of the manager, removing any active overlay.
  void dispose() {
    removeImmediately();
  }
}
