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
/// a single animated overlay. Handles dismissible taps, blocks
/// semantics of the content behind it, and keeps the content clear
/// of the on-screen keyboard.
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

  /// Called when the user taps the barrier. The callee decides
  /// whether the overlay is dismissible.
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _animation.dispose();
    _animationController.dispose();
    widget.onDisposed?.call();
    super.dispose();
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
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // Barrier with optional blur.
                Positioned.fill(
                  child: GestureDetector(
                    onTap: config.dismissible ? widget.onDismiss : null,
                    behavior: HitTestBehavior.opaque,
                    child: FadeTransition(
                      opacity: _animation,
                      child: _buildBarrier(config),
                    ),
                  ),
                ),

                // Centered loading content, kept above the keyboard.
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Center(
                      child: OverlayTransition(
                        animation: _animation,
                        animationType: config.animationType,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          child: Material(
                            color: config.backgroundColor,
                            elevation: config.elevation,
                            borderRadius: config.borderRadius,
                            child: Padding(
                              padding: config.padding,
                              child: LoadingContent(config: config),
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
