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

  final List<ModalRoute<dynamic>> _routes = [];

  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier<bool>(false);

  /// Registers this guard on [routes], replacing earlier registrations.
  void attach(Iterable<ModalRoute<dynamic>> routes) {
    detach();
    for (final route in routes) {
      if (_routes.contains(route)) continue;
      _routes.add(route);
      route.registerPopEntry(this);
    }
  }

  /// Unregisters this guard from every route it was attached to.
  void detach() {
    for (final route in _routes) {
      route.unregisterPopEntry(this);
    }
    _routes.clear();
  }

  /// Detaches and releases resources. The guard cannot be reused.
  void dispose() {
    detach();
    canPopNotifier.dispose();
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

  /// The routes that receive back navigation while an overlay is shown
  /// in [overlay]: the top route of the Navigator owning it and, if that
  /// Navigator is nested, the top route of the root Navigator.
  static List<ModalRoute<dynamic>> routesFor(OverlayState overlay) {
    if (!overlay.mounted) return const [];
    final context = overlay.context;
    return [
      for (final navigator in {
        Navigator.maybeOf(context),
        Navigator.maybeOf(context, rootNavigator: true),
      })
        if (topRouteOf(navigator) case final route?) route,
    ];
  }
}
