/// Defines the types of built-in loading indicators available.
///
/// Each loader type corresponds to a visually distinct loading
/// animation that can be displayed in the overlay.
///
/// {@tool snippet}
/// Use with LoadingOverlay.show to specify the loader style:
///
/// ```dart
/// LoadingOverlay.show(
///   context: context,
///   loaderType: LoaderType.dots,
/// );
/// ```
/// {@end-tool}
library;

/// The type of built-in loading indicator to display.
///
/// The loading overlay package provides 11 beautiful built-in loaders,
/// each with a unique visual style. All loaders are implemented using
/// pure Dart and Flutter — no images or external dependencies.
///
/// See also:
///
///  * LoadingOverlay.show, which accepts a loader type.
///  * LoadingIndicator, which renders the selected loader.
enum LoaderType {
  /// A rotating circular arc indicator.
  ///
  /// Displays a colored arc that continuously rotates, similar
  /// to common loading spinners.
  circular,

  /// A bouncing dots indicator.
  ///
  /// Shows three dots that animate in a wave-like bouncing pattern.
  dots,

  /// A pulsing circle indicator.
  ///
  /// Displays a circle that rhythmically scales up and down with
  /// an opacity change.
  pulse,

  /// An expanding ripple rings indicator.
  ///
  /// Shows concentric rings that expand outward from the center
  /// while fading out.
  ripple,

  /// An equalizer-style bars indicator.
  ///
  /// Displays vertical bars that animate up and down at different
  /// rates, similar to an audio equalizer.
  bars,

  /// A rotating 3D cube indicator.
  ///
  /// Shows a square that rotates along the Y-axis, creating a
  /// pseudo-3D cube effect.
  cube,

  /// A spinning ring with a gap indicator.
  ///
  /// Displays a ring with a visible gap that continuously rotates.
  ring,

  /// A gradient arc spinner indicator.
  ///
  /// Shows a rotating arc with a gradient color effect for a
  /// modern, polished look.
  gradientSpinner,

  /// A thin line spinner indicator.
  ///
  /// Displays a minimal, thin rotating line — ideal for clean
  /// and modern UIs.
  minimalSpinner,

  /// A Material Design spinner indicator.
  ///
  /// Uses Flutter's CircularProgressIndicator for a native
  /// Material Design loading experience.
  materialSpinner,

  /// A Cupertino-style spinner indicator.
  ///
  /// Uses Flutter's CupertinoActivityIndicator for a native
  /// iOS loading experience.
  cupertinoSpinner,
}
