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
/// a single animated overlay. Handles dismissible taps and
/// keyboard-safe layout.
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
  });

  /// The configuration controlling the overlay appearance.
  final LoadingOverlayConfig config;

  /// Called when the user dismisses the overlay (if dismissible).
  final VoidCallback onDismiss;

  @override
  State<OverlayWidget> createState() => OverlayWidgetState();
}

/// State for [OverlayWidget] that manages the entry/exit animation.
///
/// Exposes [animateOut] for the OverlayEntryManager to trigger
/// the exit animation before removing the overlay entry.
class OverlayWidgetState extends State<OverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;

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
    if (oldWidget.config.animationDuration !=
        widget.config.animationDuration) {
      _animationController.duration = widget.config.animationDuration;
    }
    if (oldWidget.config.animationCurve !=
        widget.config.animationCurve) {
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.config.animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Plays the exit animation and returns a [Future] that completes
  /// when the animation finishes.
  ///
  /// Called by OverlayEntryManager before removing the overlay
  /// entry to ensure a smooth exit animation.
  Future<void> animateOut() async {
    if (!mounted) return;
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return RepaintBoundary(
      child: Semantics(
        label: 'Loading overlay',
        liveRegion: true,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Barrier with optional blur.
              Positioned.fill(
                child: GestureDetector(
                  onTap: config.dismissible
                      ? () {
                          config.onDismiss?.call();
                          widget.onDismiss();
                        }
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) => Opacity(
                      opacity: _animation.value,
                      child: child,
                    ),
                    child: _buildBarrier(config),
                  ),
                ),
              ),

              // Centered loading content.
              Center(
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
            ],
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
