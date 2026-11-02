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
/// Uses the [animation] provided by the parent to drive transitions;
/// rebuilding this widget does not add listeners to it.
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

  // Derived animations are built with drive() rather than
  // CurvedAnimation: CurvedAnimation registers a status listener on its
  // parent as soon as it is created, so creating one per build would
  // leak a listener on every rebuild (e.g. every progress update).
  //
  // The parent animation can leave [0, 1] when the overlay uses an
  // overshooting animationCurve (Curves.easeOutBack, Curves.elasticOut),
  // and curves assert on such values, so clamp before applying them.
  static final Animatable<double> _easeOutBack =
      CurveTween(curve: const _ClampedCurve(Curves.easeOutBack));
  static final Animatable<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).chain(CurveTween(curve: const _ClampedCurve(Curves.easeOutCubic)));
  static final Animatable<double> _zoomIn = Tween<double>(begin: 0.5, end: 1)
      .chain(CurveTween(curve: const _ClampedCurve(Curves.easeOutCubic)));
  static final Animatable<double> _halfTurn = Tween<double>(begin: 0.5, end: 1)
      .chain(CurveTween(curve: const _ClampedCurve(Curves.easeOutCubic)));

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
          scale: animation.drive(_easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.slide:
        return SlideTransition(
          position: animation.drive(_slideUp),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.zoom:
        return ScaleTransition(
          scale: animation.drive(_zoomIn),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case LoadingAnimationType.rotation:
        return RotationTransition(
          turns: animation.drive(_halfTurn),
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

/// Applies [inner] to `t` clamped to [0, 1], so that values outside that
/// range (from an overshooting parent animation) do not assert.
class _ClampedCurve extends Curve {
  const _ClampedCurve(this.inner);

  final Curve inner;

  // Overrides transform, not transformInternal: Curve.transform asserts
  // that t is in [0, 1] before calling transformInternal.
  @override
  double transform(double t) => inner.transform(t.clamp(0.0, 1.0));
}
