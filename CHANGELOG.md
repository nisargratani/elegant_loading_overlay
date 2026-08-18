# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2026-08-18

### Changed

- Updated `description` in `pubspec.yaml` to be more concise.
- Updated `flutter_lints` dependency to `^6.0.0`.

## [0.0.1] - 2026-08-03

### Added

- Initial release of `elegant_loading_overlay`.
- One-line static API: `LoadingOverlay.show()` / `LoadingOverlay.hide()`.
- 11 built-in loading indicators: circular, dots, pulse, ripple, bars, cube, ring, gradient spinner, minimal spinner, material spinner, cupertino spinner.
- Smooth overlay animations: fade, scale, slide, zoom, rotation, none.
- Customizable blur background with configurable sigma.
- Barrier color and opacity control.
- Determinate and indeterminate progress indicators.
- Loading message and subtitle support.
- Custom loader builder for complete UI control.
- `LoadingOverlayTheme` and `LoadingOverlayThemeData` for theming.
- `LoadingOverlayScope` for scoped overlay management.
- `LoadingOverlayController` for programmatic control.
- `BuildContext` extensions for convenience: `context.showLoadingOverlay()` / `context.hideLoadingOverlay()`.
- Overlay stacking protection (only one overlay at a time).
- Dismissible overlay support with `onDismiss` callback.
- Keyboard-safe layout.
- Accessibility support with semantics labels.
- Full platform support: Android, iOS, Web, macOS, Windows, Linux.
- Dark mode support.
- Responsive design for mobile, tablet, and desktop.
- Comprehensive widget, controller, theme, and animation tests.
- Beautiful example app demonstrating all features.
- GitHub Actions CI workflow.
