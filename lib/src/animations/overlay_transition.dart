/// Transition wrapper that applies the appropriate animation
/// to the overlay widget based on the [LoadingAnimationType].
///
/// Supports fade, scale, slide, zoom, rotation, and none
/// animation types.
library;

import 'package:flutter/material.dart';

import '../models/loading_animation_type.dart';

/// Wraps a child widget with the appropriate transition animation
/// based on the specified [LoadingAnimationType].
///
/// Uses [AnimationController] from the parent to drive transitions.
///
/// {@tool snippet}
/// ```dart
/// OverlayTransition(
///   animation: animation,
///   animationType: LoadingAnimationType.scale,
///   child: MyOverlayContent(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [LoadingAnimationType], the available animation types.
class OverlayTransition extends StatelessWidget {
  /// Creates an overlay transition wrapper.
  const OverlayTransition({
    required this.animation,
    required this.animationType,
    required this.child,
    super.key,
  });

  /// The animation driving the transition.
  final Animation<double> animation;

  /// The type of animation to apply.
  final LoadingAnimationType animationType;

  /// The child widget to animate.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (animationType) {
      case LoadingAnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case LoadingAnimationType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      case LoadingAnimationType.none:
        return child;
    }
  }
}
