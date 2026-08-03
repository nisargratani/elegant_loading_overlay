/// Defines the types of animations available for loading overlay
/// transitions.
///
/// Each animation type controls how the overlay appears and
/// disappears when show and hide are called on LoadingOverlay.
///
/// {@tool snippet}
/// Use with LoadingOverlay.show to specify the entry animation:
///
/// ```dart
/// LoadingOverlay.show(
///   context: context,
///   animation: LoadingAnimationType.scale,
/// );
/// ```
/// {@end-tool}
library;

/// The type of animation used for overlay entry and exit transitions.
///
/// Each value corresponds to a specific transition animation that
/// is applied when the overlay is shown or hidden.
///
/// See also:
///
///  * LoadingOverlay.show, which accepts an animation type.
///  * OverlayTransition, which applies the animation.
enum LoadingAnimationType {
  /// A simple fade-in/fade-out transition.
  ///
  /// The overlay smoothly transitions from transparent to opaque
  /// and vice versa. This is the default animation type.
  fade,

  /// A scale transition that grows from center.
  ///
  /// The overlay scales from 0.0 to 1.0 when showing, and
  /// from 1.0 to 0.0 when hiding.
  scale,

  /// A slide transition from the bottom of the screen.
  ///
  /// The overlay slides up from below the visible area when
  /// showing, and slides back down when hiding.
  slide,

  /// A zoom transition combining scale and fade effects.
  ///
  /// Similar to [scale] but with an additional fade effect
  /// for a more dramatic appearance.
  zoom,

  /// A rotation transition that spins the overlay into view.
  ///
  /// The overlay rotates from 0 to 360 degrees while fading
  /// in when showing, and reverses when hiding.
  rotation,

  /// No animation; the overlay appears and disappears instantly.
  ///
  /// Useful for testing or when animations are not desired.
  none,
}
