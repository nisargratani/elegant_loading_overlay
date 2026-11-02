/// A widget that provides a scoped loading overlay controller and
/// optional theme to its subtree.
///
/// Use [LoadingOverlayScope] when you need independent overlay
/// control for different parts of your app, or when you want to
/// provide a loading overlay theme to a specific subtree.
library;

import 'package:flutter/material.dart';

import '../controller/loading_overlay_controller.dart';
import '../models/loading_overlay_config.dart';
import '../overlay/back_guard.dart';
import '../overlay/overlay_entry_manager.dart';
import '../theme/loading_overlay_theme.dart';
import '../theme/loading_overlay_theme_widget.dart';

/// A widget that provides a scoped [LoadingOverlayController] to
/// its descendants.
///
/// Unlike the static LoadingOverlay API which uses a global
/// singleton, [LoadingOverlayScope] creates an independent
/// controller for its subtree. This is useful for:
///
/// - Having multiple independent loading overlays in different
///   parts of the app
/// - Providing different themes to different sections
/// - Automatic removal of the overlay when the scope is removed
/// - Driving an overlay from outside the widget tree by passing your
///   own [controller]
///
/// The scope must be placed below a [Navigator] or [Overlay] (for
/// example around a page's body, not around `MaterialApp`), because
/// the overlay is inserted into the nearest Overlay above the scope.
///
/// {@tool snippet}
/// ```dart
/// LoadingOverlayScope(
///   child: MyPage(),
/// )
///
/// // Then in MyPage:
/// LoadingOverlayScope.of(context).show();
/// ```
/// {@end-tool}
///
/// See also:
///
///  * LoadingOverlay, the global static API.
///  * [LoadingOverlayController], the underlying controller.
///  * [LoadingOverlayTheme], for theming.
class LoadingOverlayScope extends StatefulWidget {
  /// Creates a loading overlay scope.
  ///
  /// Optionally provide [theme] to configure the appearance of
  /// overlays within this scope, and [controller] to control the
  /// overlay from outside the widget tree.
  const LoadingOverlayScope({
    required this.child,
    super.key,
    this.theme,
    this.controller,
  });

  /// The widget below this scope in the tree.
  final Widget child;

  /// Optional theme data for overlays within this scope.
  ///
  /// When provided, a [LoadingOverlayTheme] is inserted above
  /// the child, and [LoadingOverlayScopeState.show] uses it when called
  /// without an explicit config.
  final LoadingOverlayThemeData? theme;

  /// An optional controller that drives this scope's overlay.
  ///
  /// Calling `show`, `update`, `toggle` or `hide` on it shows, updates
  /// or hides the overlay. The scope does not dispose a controller
  /// passed in here; its owner must. When `null`, the scope creates and
  /// disposes its own controller.
  final LoadingOverlayController? controller;

  /// Returns the state of the nearest [LoadingOverlayScope] ancestor,
  /// which provides `show`, `hide`, `toggle` and `controller`.
  ///
  /// This also works inside the scope's own overlay (for example from a
  /// Cancel button in a custom `builder`), although the overlay is
  /// inserted into an [Overlay] above the scope.
  ///
  /// Throws a [FlutterError] if no [LoadingOverlayScope] is found in
  /// the tree. Use [maybeOf] to handle that case.
  ///
  /// ```dart
  /// final scope = LoadingOverlayScope.of(context);
  /// scope.show();
  /// ```
  static LoadingOverlayScopeState of(BuildContext context) {
    final state = maybeOf(context);
    if (state == null) {
      throw FlutterError.fromParts([
        ErrorSummary('No LoadingOverlayScope found in the widget tree.'),
        ErrorHint(
          'Wrap the widget that calls LoadingOverlayScope.of() in a '
          'LoadingOverlayScope, or use LoadingOverlayScope.maybeOf().',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return state;
  }

  /// Returns the state of the nearest [LoadingOverlayScope] ancestor,
  /// or `null` if there is none.
  ///
  /// Like [of], this also finds the scope from inside its own overlay.
  static LoadingOverlayScopeState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ScopeMarker>()?.state;

  @override
  State<LoadingOverlayScope> createState() => LoadingOverlayScopeState();
}

/// State for [LoadingOverlayScope].
///
/// Provides [show], [hide], and [toggle] methods for controlling
/// the scoped overlay.
class LoadingOverlayScopeState extends State<LoadingOverlayScope> {
  LoadingOverlayController? _ownedController;
  late OverlayEntryManager _manager;

  /// The controller driving this scope's overlay.
  ///
  /// This is [LoadingOverlayScope.controller] when provided, otherwise
  /// a controller owned by this scope. Listen to it to react to the
  /// overlay being shown or hidden, or call `update` to change the
  /// visible overlay's config (for example its progress).
  LoadingOverlayController get controller =>
      widget.controller ?? (_ownedController ??= LoadingOverlayController());

  /// Whether the scoped overlay is currently visible.
  bool get isShowing => _manager.isShowing;

  @override
  void initState() {
    super.initState();
    _manager = _createManager();
    // A provided controller may already be showing.
    if (controller.isShowing) _manager.sync();
  }

  @override
  void didUpdateWidget(LoadingOverlayScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _manager.dispose();
      _manager = _createManager();
      if (controller.isShowing) _manager.sync();
    } else if (oldWidget.theme != widget.theme) {
      // The overlay content reads the theme (see _wrapOverlayContent).
      _manager.markNeedsBuild();
    }
  }

  OverlayEntryManager _createManager() => OverlayEntryManager(
        controller: controller,
        resolveHost: () => mounted ? Overlay.maybeOf(context) : null,
        wrapContent: _wrapOverlayContent,
      );

  /// The overlay is inserted into an [Overlay] above this scope, outside
  /// its subtree. Wrap it so that [LoadingOverlayScope.of] and
  /// [LoadingOverlayTheme.of] work the same inside it (for example in a
  /// custom `builder`) as below the scope.
  Widget _wrapOverlayContent(Widget child) {
    final theme = widget.theme;
    return _ScopeMarker(
      state: this,
      child: theme == null
          ? child
          : LoadingOverlayTheme(data: theme, child: child),
    );
  }

  /// Shows the scoped overlay.
  ///
  /// When [config] is `null`, a config is built from this scope's
  /// [LoadingOverlayScope.theme] (or the nearest [LoadingOverlayTheme]
  /// above the scope) using [LoadingOverlayConfig.fromTheme]. An
  /// explicit [config] is used as given.
  ///
  /// Uses the scope's context to find the nearest [Overlay]. Does
  /// nothing if the scope is no longer mounted.
  void show([LoadingOverlayConfig? config]) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    _manager.show(
      overlay,
      config ?? LoadingOverlayConfig.fromTheme(_theme),
      navigators: BackGuard.navigatorsOf(context),
    );
  }

  /// Hides the scoped overlay with an exit animation.
  ///
  /// The returned future completes once the overlay has been removed.
  Future<void> hide() => _manager.hide();

  /// Toggles the scoped overlay visibility.
  Future<void> toggle([LoadingOverlayConfig? config]) async {
    if (isShowing) {
      await hide();
    } else {
      show(config);
    }
  }

  LoadingOverlayThemeData? get _theme =>
      widget.theme ??
      context.getInheritedWidgetOfExactType<LoadingOverlayTheme>()?.data;

  @override
  void dispose() {
    _manager.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return _ScopeMarker(
      state: this,
      child: theme == null
          ? widget.child
          : LoadingOverlayTheme(data: theme, child: widget.child),
    );
  }
}

/// Makes a [LoadingOverlayScopeState] findable below its scope and
/// inside its overlay, which lives outside the scope's subtree.
class _ScopeMarker extends InheritedWidget {
  const _ScopeMarker({required this.state, required super.child});

  final LoadingOverlayScopeState state;

  // Looked up without a dependency (like findAncestorStateOfType), so
  // nothing needs to be notified.
  @override
  bool updateShouldNotify(_ScopeMarker oldWidget) => false;
}
