/// Blocks system back navigation while a loading overlay is visible.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

/// A [PopEntry] that stops `Navigator.maybePop` (the system back button,
/// the browser back button, `BackButton`) from popping the routes it is
/// registered on, and reports those attempts to [onBack].
///
/// Programmatic `Navigator.pop()` is not affected, so code that pops a
/// page while the overlay is still visible keeps working.
///
/// The guard never adds itself to, or removes itself from, a route
/// synchronously. A route iterates its pop entries while it calls them,
/// and app code running in one of those callbacks (for example a
/// `PopScope` that calls `LoadingOverlay.show` or `LoadingOverlay.hide`)
/// would otherwise change that set mid-iteration and throw a
/// `ConcurrentModificationError`. [attach], [detach] and [dispose] only
/// record the routes the guard should be on; a single microtask then
/// registers and unregisters it to match.
///
/// `PopEntry` changed shape after Flutter 3.22: there, `onPopInvoked` is
/// a getter returning a callback; from 3.24 on, `onPopInvoked` and
/// `onPopInvokedWithResult` are methods and the class is generic. No
/// single class can declare members matching both, so this class
/// implements the interface and answers those members in
/// [noSuchMethod], which works on every supported version.
// ignore: strict_raw_type
class BackGuard implements PopEntry {
  /// Creates a guard that reports blocked back attempts to [onBack].
  BackGuard({required this.onBack});

  /// Called when a back navigation was blocked by this guard.
  final VoidCallback onBack;

  /// The routes this guard is registered on.
  final List<ModalRoute<dynamic>> _registered = [];

  /// The routes this guard should be registered on.
  List<ModalRoute<dynamic>> _wanted = const [];

  bool _syncScheduled = false;
  bool _disposed = false;

  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier<bool>(false);

  /// Registers this guard on [routes], replacing earlier registrations.
  ///
  /// Takes effect in a microtask.
  void attach(Iterable<ModalRoute<dynamic>> routes) {
    if (_disposed) return;
    _wanted = routes.toSet().toList();
    _scheduleSync();
  }

  /// Unregisters this guard from every route it was attached to.
  ///
  /// Takes effect in a microtask.
  void detach() {
    if (_disposed) return;
    _wanted = const [];
    _scheduleSync();
  }

  /// Detaches and releases resources. The guard cannot be reused.
  ///
  /// Takes effect in a microtask.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _wanted = const [];
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    scheduleMicrotask(_sync);
  }

  /// Makes the registrations match [_wanted].
  void _sync() {
    _syncScheduled = false;
    for (final route in List.of(_registered)) {
      if (_wanted.contains(route)) continue;
      _registered.remove(route);
      route.unregisterPopEntry(this);
    }
    for (final route in _wanted) {
      // A route removed from its Navigator meanwhile needs no guard.
      if (_registered.contains(route) || !route.isActive) continue;
      _registered.add(route);
      route.registerPopEntry(this);
    }
    if (_disposed) canPopNotifier.dispose();
  }

  void _handlePopInvoked(bool didPop) {
    // The route is iterating its pop entries right now, and onBack may
    // detach this guard, so run it once that iteration has finished.
    if (!didPop) scheduleMicrotask(onBack);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    // Flutter 3.22: `PopInvokedCallback? get onPopInvoked`.
    if (name == #onPopInvoked && invocation.isGetter) {
      return _handlePopInvoked;
    }
    // Flutter 3.24+: `onPopInvokedWithResult(bool didPop, T? result)`
    // and the deprecated `onPopInvoked(bool didPop)`.
    if ((name == #onPopInvokedWithResult || name == #onPopInvoked) &&
        invocation.isMethod) {
      _handlePopInvoked(invocation.positionalArguments.first as bool);
      return null;
    }
    return super.noSuchMethod(invocation);
  }

  /// The top-most [ModalRoute] of [navigator], or `null`.
  static ModalRoute<dynamic>? topRouteOf(NavigatorState? navigator) {
    if (navigator == null || !navigator.mounted) return null;
    Route<dynamic>? top;
    // popUntil with an always-true predicate only reads the top route.
    navigator.popUntil((route) {
      top = route;
      return true;
    });
    final route = top;
    return route is ModalRoute<dynamic> ? route : null;
  }

  /// The [Navigator] enclosing [context] and every Navigator above it,
  /// innermost first.
  ///
  /// Back navigation can be delivered to any of them: the root
  /// Navigator receives it from the platform, and `NavigatorPopHandler`,
  /// go_router's `StatefulShellRoute` or a custom `RouterDelegate` can
  /// forward it to a nested one.
  static List<NavigatorState> navigatorsOf(BuildContext context) {
    final navigators = <NavigatorState>[];
    var navigator = Navigator.maybeOf(context);
    while (navigator != null) {
      navigators.add(navigator);
      // Not Navigator.maybeOf(navigator.context): for a Navigator's own
      // context that returns the same Navigator.
      navigator = navigator.context.findAncestorStateOfType<NavigatorState>();
    }
    return navigators;
  }

  /// The routes that receive back navigation while an overlay is shown
  /// in [overlay]: the top route of the Navigator owning it and, if that
  /// Navigator is nested, the top route of the root Navigator, plus the
  /// top route of each of [navigators] (typically [navigatorsOf] the
  /// context that showed the overlay).
  static List<ModalRoute<dynamic>> routesFor(
    OverlayState overlay, [
    Iterable<NavigatorState> navigators = const [],
  ]) {
    final candidates = <NavigatorState?>{
      if (overlay.mounted) ...[
        Navigator.maybeOf(overlay.context),
        Navigator.maybeOf(overlay.context, rootNavigator: true),
      ],
      ...navigators,
    };
    return [
      for (final navigator in candidates)
        if (topRouteOf(navigator) case final route?) route,
    ];
  }
}
