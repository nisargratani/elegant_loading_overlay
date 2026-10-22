/// Manages the [OverlayEntry] lifecycle for loading overlays.
///
/// Handles creation, insertion, update, and removal of overlay
/// entries in the Flutter overlay system, with stacking protection
/// and safe context handling.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../controller/loading_overlay_controller.dart';
import '../models/loading_overlay_config.dart';
import 'back_guard.dart';
import 'overlay_widget.dart';

/// Resolves the [OverlayState] a new overlay entry should be inserted
/// into, or `null` when none is available.
typedef OverlayHostResolver = OverlayState? Function();

/// Manages the lifecycle of a single loading overlay entry and keeps
/// it in sync with a [LoadingOverlayController].
///
/// The controller is the source of truth: calling `show`, `update`,
/// or `hide` on it is reflected on screen, and dismissing the overlay
/// by tapping the barrier resets the controller.
///
/// This class is responsible for:
/// - Creating and inserting [OverlayEntry] instances
/// - Updating overlay content when config changes
/// - Animating exit before removal, and cancelling that exit when the
///   overlay is shown again mid-animation
/// - Stacking protection (only one overlay at a time)
/// - Deferring overlay mutations requested during a build/layout phase
/// - Recovering when the host [Overlay] is disposed underneath it
/// - Blocking system back navigation while visible (dismissing instead
///   when the overlay is dismissible)
/// - Moving the entry when it is shown again in a different [Overlay]
///
/// This class is used internally by LoadingOverlay and
/// LoadingOverlayScope. It is not part of the public API.
class OverlayEntryManager {
  /// Creates a manager bound to [controller].
  ///
  /// [resolveHost] provides the [Overlay] used when the controller is
  /// shown without an explicit host (for example `controller.show()`).
  OverlayEntryManager({
    required this.controller,
    required OverlayHostResolver resolveHost,
  }) : _resolveHost = resolveHost {
    controller.addListener(_handleControllerChanged);
  }

  /// The controller whose value drives this manager.
  final LoadingOverlayController controller;

  final OverlayHostResolver _resolveHost;

  OverlayEntry? _entry;
  GlobalKey<OverlayWidgetState>? _widgetKey;
  LoadingOverlayConfig? _config;

  /// The Overlay [_entry] is (or is about to be) inserted into.
  OverlayState? _host;

  /// Incremented by every show/update, so callbacks can tell whether
  /// the overlay was shown again while they ran.
  int _generation = 0;

  BackGuard? _backGuard;

  /// Whether [_entry] is waiting for a post-frame insertion.
  bool _insertPending = false;

  /// Non-null while an exit animation is running.
  Completer<void>? _hideCompleter;

  bool _disposed = false;

  /// Whether an overlay is visible and not currently animating out.
  bool get isShowing => _entry != null && _hideCompleter == null;

  /// Shows the overlay in [overlay] with [config], or updates the
  /// visible overlay if one is already showing.
  void show(OverlayState overlay, LoadingOverlayConfig config) {
    if (_disposed) return;
    _present(config, overlay);
    // The listener sees the identical config and does nothing further.
    controller.show(config);
  }

  /// Hides the overlay with its exit animation.
  ///
  /// The returned future completes when the overlay has been removed,
  /// or when the exit is cancelled by a new `show`. Calling this while
  /// nothing is showing completes immediately.
  Future<void> hide() {
    controller.hide();
    return _dismiss();
  }

  /// Re-applies the controller's current value. Useful after binding
  /// to a controller that is already showing.
  void sync() => _handleControllerChanged();

  /// Removes any overlay immediately and stops listening to the
  /// controller. The controller itself is not disposed.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    controller.removeListener(_handleControllerChanged);
    _completeHide();
    _removeEntry();
    _detachBackGuard();
  }

  void _handleControllerChanged() {
    if (_disposed) return;
    final config = controller.value;
    if (config == null) {
      unawaited(_dismiss());
    } else if (!identical(config, _config) || !isShowing) {
      _present(config, null);
    }
  }

  void _present(LoadingOverlayConfig config, OverlayState? host) {
    _config = config;
    _generation++;

    final entry = _entry;
    if (entry != null) {
      if (_hideCompleter != null) {
        // Shown again while animating out: cancel the exit.
        _completeHide();
        _widgetKey?.currentState?.animateIn();
      }
      if (host != null && !identical(host, _host) && host.mounted) {
        _moveEntry(entry, host);
      } else {
        _runWhenSafe(() {
          if (identical(_entry, entry) && !_insertPending) {
            entry.markNeedsBuild();
          }
        });
        _attachBackGuard();
      }
      return;
    }

    final overlay = host ?? _resolveHost();
    if (overlay == null || !overlay.mounted) {
      _config = null;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError.fromParts([
            ErrorSummary('No Overlay available to show the loading overlay.'),
            ErrorDescription(
              'A LoadingOverlayController was shown before any Overlay '
              'was known to it, or after that Overlay was disposed.',
            ),
            ErrorHint(
              'Call LoadingOverlay.show(context: context) with a context '
              'below a Navigator/Overlay, or place LoadingOverlayScope '
              'below MaterialApp/WidgetsApp.',
            ),
          ]),
          library: 'elegant_loading_overlay',
        ),
      );
      // Nothing is visible, so the controller must not claim otherwise.
      // We are inside the controller's own listener here; reset it once
      // the current notification has finished.
      final generation = _generation;
      scheduleMicrotask(() {
        if (!_disposed && _entry == null && _generation == generation) {
          controller.hide();
        }
      });
      return;
    }

    final widgetKey = _widgetKey = GlobalKey<OverlayWidgetState>();
    late final OverlayEntry newEntry;
    newEntry = OverlayEntry(
      builder: (context) => OverlayWidget(
        key: widgetKey,
        config: _config ?? config,
        onDismiss: _handleDismissTap,
        onDisposed: () => _handleEntryDisposed(newEntry),
      ),
    );
    _entry = newEntry;
    _host = overlay;

    if (_isBuilding) {
      // Inserting during build/layout would call setState on the
      // Overlay mid-frame, so wait for the frame to finish.
      _insertPending = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!identical(_entry, newEntry)) return; // Hidden meanwhile.
        _insertPending = false;
        final target = _host;
        if (target != null && target.mounted) {
          target.insert(newEntry);
          _attachBackGuard();
        } else {
          _abandonEntry();
        }
      });
    } else {
      overlay.insert(newEntry);
      _attachBackGuard();
    }
  }

  /// Moves the visible [entry] into [host]. Its widget keeps its state
  /// (the entry is re-parented with its GlobalKey within one frame), so
  /// the entry animation is not replayed.
  void _moveEntry(OverlayEntry entry, OverlayState host) {
    _host = host;
    if (_insertPending) return; // The pending insertion reads _host.
    _runWhenSafe(() {
      if (!identical(_entry, entry) || _insertPending) return;
      if (!host.mounted || !identical(_host, host)) return;
      entry.remove();
      host.insert(entry);
      _attachBackGuard();
    });
  }

  /// Blocks back navigation on the routes in front of the current host
  /// while the overlay is showing.
  void _attachBackGuard() {
    final host = _host;
    if (_disposed || !isShowing || _insertPending || host == null) return;
    (_backGuard ??= BackGuard(onBack: _handleBack))
        .attach(BackGuard.routesFor(host));
  }

  void _detachBackGuard() {
    _backGuard?.dispose();
    _backGuard = null;
  }

  Future<void> _dismiss() {
    if (_entry == null) return Future<void>.value();
    final pending = _hideCompleter;
    if (pending != null) return pending.future;

    final completer = _hideCompleter = Completer<void>();
    // Back navigation works again as soon as hiding starts.
    _detachBackGuard();
    final state = _widgetKey?.currentState;
    if (_insertPending || state == null || !state.mounted) {
      _completeHide();
      _removeEntry();
    } else {
      unawaited(
        state.animateOut().then((_) {
          // A newer show() cancelled this exit; keep the entry.
          if (!identical(_hideCompleter, completer)) return;
          _completeHide();
          _removeEntry();
        }),
      );
    }
    return completer.future;
  }

  void _handleDismissTap() {
    final config = _config;
    if (!isShowing || config == null || !config.dismissible) return;
    final generation = _generation;
    config.onDismiss?.call();
    // onDismiss may already have hidden the overlay, or shown a new one
    // (for example a retry message); only hide what was dismissed.
    if (isShowing && _generation == generation) unawaited(hide());
  }

  /// Handles a blocked system back press: dismissible overlays are
  /// dismissed as if the barrier was tapped; others swallow it.
  void _handleBack() => _handleDismissTap();

  /// Called when the entry's widget is disposed. If this happens
  /// while the entry is still current, its [Overlay] was torn down
  /// (for example the Navigator was removed) and we must forget it.
  void _handleEntryDisposed(OverlayEntry entry) {
    if (!identical(_entry, entry)) return;
    _completeHide();
    _detachBackGuard();
    _entry = null;
    _widgetKey = null;
    _host = null;
    // The element tree is locked while widgets are being disposed, so
    // release the entry and notify listeners afterwards.
    _config = null;
    scheduleMicrotask(() {
      entry
        ..remove()
        ..dispose();
      if (!_disposed && _entry == null) controller.hide();
    });
  }

  void _abandonEntry() {
    _completeHide();
    _detachBackGuard();
    _entry?.dispose();
    _entry = null;
    _widgetKey = null;
    _host = null;
    _config = null;
    if (!_disposed) controller.hide();
  }

  void _removeEntry() {
    _detachBackGuard();
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    _widgetKey = null;
    _host = null;
    // Release user callbacks (builder, onDismiss) held by the config.
    _config = null;
    if (_insertPending) {
      // Never inserted; the pending callback will see it is stale.
      _insertPending = false;
    } else {
      entry.remove();
    }
    entry.dispose();
  }

  void _completeHide() {
    final completer = _hideCompleter;
    _hideCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  static bool get _isBuilding =>
      SchedulerBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks;

  static void _runWhenSafe(VoidCallback action) {
    if (_isBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) => action());
    } else {
      action();
    }
  }
}
