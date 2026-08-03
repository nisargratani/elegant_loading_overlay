/// Beautiful, customizable loading overlay for Flutter with
/// one-line API.
///
/// {@category Widgets}
///
/// ## Getting Started
///
/// The simplest way to use this package:
///
/// ```dart
/// import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
///
/// // Show
/// LoadingOverlay.show(context: context);
///
/// // Hide
/// LoadingOverlay.hide();
/// ```
///
/// ## Features
///
/// - 11 beautiful built-in loading indicators
/// - Smooth fade, scale, slide, zoom, and rotation animations
/// - Customizable blur background, barrier color, and opacity
/// - Determinate and indeterminate progress indicators
/// - Custom loader builder for complete control
/// - Theme support via LoadingOverlayTheme
/// - Scoped overlays via LoadingOverlayScope
/// - BuildContext extensions for convenience
/// - Full platform support (Android, iOS, Web, macOS, Windows, Linux)
/// - Accessibility support with semantics
///
/// ## Main Classes
///
/// - LoadingOverlay — Main static API
/// - LoadingOverlayController — Programmatic controller
/// - LoadingOverlayScope — Scoped overlay widget
/// - LoadingOverlayTheme — Theme provider
/// - LoadingOverlayThemeData — Theme data
/// - LoadingOverlayConfig — Configuration data
/// - LoadingAnimationType — Animation enum
/// - LoaderType — Loader style enum
///
/// See the README for detailed usage examples.
library;

export 'src/animations/overlay_transition.dart';
export 'src/constants/defaults.dart';
export 'src/controller/loading_overlay_controller.dart';
export 'src/extensions/context_extensions.dart';
export 'src/models/loader_type.dart';
export 'src/models/loading_animation_type.dart';
export 'src/models/loading_overlay_config.dart';
export 'src/overlay/loading_overlay.dart';
export 'src/overlay/loading_overlay_scope.dart';
export 'src/theme/loading_overlay_theme.dart';
export 'src/theme/loading_overlay_theme_widget.dart';
export 'src/utils/platform_utils.dart';
export 'src/widgets/loaders/bars_loader.dart';
export 'src/widgets/loaders/circular_loader.dart';
export 'src/widgets/loaders/cube_loader.dart';
export 'src/widgets/loaders/cupertino_spinner_loader.dart';
export 'src/widgets/loaders/dots_loader.dart';
export 'src/widgets/loaders/gradient_spinner_loader.dart';
export 'src/widgets/loaders/loading_indicator.dart';
export 'src/widgets/loaders/material_spinner_loader.dart';
export 'src/widgets/loaders/minimal_spinner_loader.dart';
export 'src/widgets/loaders/pulse_loader.dart';
export 'src/widgets/loaders/ring_loader.dart';
export 'src/widgets/loaders/ripple_loader.dart';
