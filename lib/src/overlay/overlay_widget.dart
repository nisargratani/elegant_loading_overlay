/// The rendered overlay widget that displays the loading content
/// with barrier, blur, and animation effects.
///
/// This widget is created by OverlayEntryManager and inserted
/// into the Flutter overlay.
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../animations/overlay_transition.dart';
import '../models/loading_overlay_config.dart';
import '../widgets/loading_content.dart';

/// The visual overlay widget rendered on top of the app content.
///
/// Composes the barrier, blur effect, and loading content into
/// a single animated overlay. Handles dismissible taps, the Escape key
/// and the screen reader dismiss action, blocks semantics of the content
/// behind it, traps keyboard focus while visible, and keeps the content
/// clear of the on-screen keyboard and system UI, scrolling it when it
/// does not fit.
///
/// This widget is used internally by OverlayEntryManager and
/// should not be instantiated directly.
///
/// See also:
///
///  * OverlayEntryManager, which manages this widget's lifecycle.
///  * [LoadingContent], which renders the loader and text.
class OverlayWidget extends StatefulWidget {
  /// Creates an overlay widget.
  const OverlayWidget({
    required this.config,
    required this.onDismiss,
    super.key,
    this.onDisposed,
  });

  /// The configuration controlling the overlay appearance.
  final LoadingOverlayConfig config;

  /// Called when the user taps the barrier, presses Escape or uses the
  /// screen reader dismiss action. The callee decides whether the
  /// overlay is dismissible.
  final VoidCallback onDismiss;

  /// Called when this widget's state is disposed.
  final VoidCallback? onDisposed;

  @override
  State<OverlayWidget> createState() => OverlayWidgetState();
}

/// State for [OverlayWidget] that manages the entry/exit animation.
///
/// Exposes [animateOut] and [animateIn] for the OverlayEntryManager.
class OverlayWidgetState extends State<OverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late CurvedAnimation _animation;

  /// Traps keyboard focus inside the overlay while it is visible.
  final FocusScopeNode _focusScope =
      FocusScopeNode(debugLabel: 'LoadingOverlay');

  /// The node that had focus before the overlay took it.
  FocusNode? _previousFocus;

  /// Whether focus was still inside the overlay when it was last
  /// removed from the tree. If it was not, something else (typically a
  /// route pushed while the overlay was visible) has taken focus since,
  /// and it must not be taken back.
  bool _hadFocusWhenRemoved = false;

  /// Escape (DismissIntent) dismisses a dismissible overlay, like a
  /// barrier tap or the back button; otherwise it does nothing.
  late final Map<Type, Action<Intent>> _actions = {
    DismissIntent: CallbackAction<DismissIntent>(
      onInvoke: (_) {
        if (widget.config.dismissible) widget.onDismiss();
        return null;
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    _previousFocus = FocusManager.instance.primaryFocus;
    // FocusScope.autofocus does nothing while the page behind already has
    // focus, so take it explicitly once the scope is attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusScope.requestFocus();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.config.animationCurve,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(OverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.animationDuration != widget.config.animationDuration) {
      _animationController.duration = widget.config.animationDuration;
    }
    if (oldWidget.config.animationCurve != widget.config.animationCurve) {
      _animation.dispose();
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.config.animationCurve,
      );
    }
  }

  @override
  void deactivate() {
    // Read before the FocusScope below is deactivated: by dispose() it
    // has already detached its node. When the entry is only moved to
    // another Overlay, the next deactivate() overwrites this.
    _hadFocusWhenRemoved = _focusScope.hasFocus;
    super.deactivate();
  }

  @override
  void dispose() {
    _animation.dispose();
    _animationController.dispose();
    _focusScope.dispose();
    if (_hadFocusWhenRemoved) _restoreFocus();
    _previousFocus = null;
    widget.onDisposed?.call();
    super.dispose();
  }

  /// Gives focus back to the widget that had it before the overlay, if
  /// that widget is still in the tree (for example the same page).
  void _restoreFocus() {
    final previous = _previousFocus;
    if (previous == null || previous.context == null) return;
    if (!previous.canRequestFocus) return;
    previous.requestFocus();
  }

  /// Plays the exit animation.
  ///
  /// The returned [Future] completes when the animation finishes, or
  /// early if it is interrupted by [animateIn] or by disposal. It never
  /// completes with an error.
  Future<void> animateOut() async {
    if (!mounted) return;
    try {
      await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // Interrupted by animateIn() or disposal; nothing to do.
    }
  }

  /// Plays the entry animation from the current position, cancelling
  /// an in-progress [animateOut].
  void animateIn() {
    if (!mounted) return;
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return RepaintBoundary(
      child: BlockSemantics(
        child: Semantics(
          label: config.semanticsLabel,
          liveRegion: true,
          // The screen reader equivalent of tapping the barrier, on this
          // labelled node instead of the unlabelled full-screen barrier.
          onDismiss: config.dismissible ? widget.onDismiss : null,
          // Escape maps to DismissIntent. Handle it while the overlay is
          // visible: dismiss when dismissible, otherwise swallow it so it
          // cannot reach routes behind the overlay. Above the FocusScope,
          // because focus can be on the scope node itself.
          child: Actions(
            actions: _actions,
            // Focus moves into this scope (see initState) and traversal
            // cannot leave a scope, so Tab/Enter/Space cannot reach
            // widgets behind the overlay.
            child: FocusScope(
              node: _focusScope,
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    // Barrier with optional blur.
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: config.dismissible ? widget.onDismiss : null,
                        behavior: HitTestBehavior.opaque,
                        // Exposed as the dismiss action above instead.
                        excludeFromSemantics: true,
                        child: FadeTransition(
                          opacity: _animation,
                          child: _buildBarrier(config),
                        ),
                      ),
                    ),

                    // Centered loading content, kept clear of the keyboard and
                    // system UI, and scrollable when it does not fit.
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: SafeArea(
                          child: Center(
                            child: OverlayTransition(
                              animation: _animation,
                              animationType: config.animationType,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                child: Material(
                                  color: config.backgroundColor,
                                  elevation: config.elevation,
                                  borderRadius: config.borderRadius,
                                  // Shrink-wraps when the content fits.
                                  child: SingleChildScrollView(
                                    padding: config.padding,
                                    child: LoadingContent(config: config),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarrier(LoadingOverlayConfig config) {
    final barrier = ColoredBox(color: config.barrierColor);

    if (!config.enableBlur || config.blurSigma <= 0) {
      return barrier;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: config.blurSigma,
        sigmaY: config.blurSigma,
      ),
      child: barrier,
    );
  }
}
