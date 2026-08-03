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
/// - Automatic disposal when the scope is removed
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
  /// overlays within this scope.
  const LoadingOverlayScope({
    required this.child,
    super.key,
    this.theme,
  });

  /// The widget below this scope in the tree.
  final Widget child;

  /// Optional theme data for overlays within this scope.
  ///
  /// When provided, a [LoadingOverlayTheme] is inserted above
  /// the child.
  final LoadingOverlayThemeData? theme;

  /// Returns the [LoadingOverlayController] from the nearest
  /// [LoadingOverlayScope] ancestor.
  ///
  /// Throws if no [LoadingOverlayScope] is found in the tree.
  ///
  /// ```dart
  /// final controller = LoadingOverlayScope.of(context);
  /// controller.show();
  /// ```
  static LoadingOverlayScopeState of(BuildContext context) {
    final state =
        context.findAncestorStateOfType<LoadingOverlayScopeState>();
    assert(
      state != null,
      'No LoadingOverlayScope found in the widget tree. '
      'Wrap your widget with LoadingOverlayScope.',
    );
    return state!;
  }

  @override
  State<LoadingOverlayScope> createState() =>
      LoadingOverlayScopeState();
}

/// State for [LoadingOverlayScope].
///
/// Provides [show], [hide], and [toggle] methods for controlling
/// the scoped overlay.
class LoadingOverlayScopeState extends State<LoadingOverlayScope> {
  final LoadingOverlayController _controller =
      LoadingOverlayController();
  final OverlayEntryManager _manager = OverlayEntryManager();

  /// Whether the scoped overlay is currently visible.
  bool get isShowing => _manager.isShowing;

  /// Shows the scoped overlay with an optional [config].
  ///
  /// Uses the scope's context to find the nearest [Overlay].
  void show([LoadingOverlayConfig? config]) {
    if (!mounted) return;
    final effectiveConfig = config ?? const LoadingOverlayConfig();
    _controller.show(effectiveConfig);
    _manager.show(context, effectiveConfig);
  }

  /// Hides the scoped overlay with an exit animation.
  Future<void> hide() async {
    _controller.hide();
    await _manager.hide();
  }

  /// Toggles the scoped overlay visibility.
  Future<void> toggle([LoadingOverlayConfig? config]) async {
    if (isShowing) {
      await hide();
    } else {
      show(config);
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;

    if (widget.theme != null) {
      child = LoadingOverlayTheme(
        data: widget.theme!,
        child: child,
      );
    }

    return child;
  }
}
