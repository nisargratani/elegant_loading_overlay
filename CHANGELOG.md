# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2026-10-22

No code changes are required when upgrading. Because `^0.0.3` only allows
`0.0.3`, update your constraint to `^0.0.4`.

### Fixed

- The system back button (Android back, browser back,
  `Navigator.maybePop`) no longer pops the page behind a visible overlay.
  A non-dismissible overlay ignores it; a dismissible overlay is dismissed
  and calls `onDismiss`. Applies to `LoadingOverlay` and
  `LoadingOverlayScope`. Programmatic `Navigator.pop()` is not blocked.
- Keyboard focus is trapped in the overlay while it is visible, so Tab,
  Enter and Space can no longer activate widgets behind it. Focus returns
  to the previously focused widget when the overlay is removed.
- The overlay card no longer overflows on small screens, with large text
  scales or with the on-screen keyboard open. It is limited to the safe
  area above the keyboard and its content scrolls when it does not fit.
- `CupertinoSpinnerLoader` (and `LoaderType.cupertinoSpinner`) no longer
  throws an assertion at size 0.
- Calling `show()` from `onDismiss` (for example to show a retry message)
  now keeps the new overlay visible instead of hiding it immediately.
- `show(useRootOverlay: true)` while an overlay is already visible in a
  nested Navigator now moves it to the root Overlay (without replaying the
  entry animation).
- `controller.show()` with no Overlay available still reports an error,
  and now also resets the controller to hidden, so `controller.isShowing`
  and `LoadingOverlay.isShowing` agree.

### Added

- `clearMessage`, `clearSubtitle`, `clearProgress`, `clearBuilder` and
  `clearOnDismiss` flags on `LoadingOverlayConfig.copyWith`, to remove
  optional values (for example the progress bar via `controller.update`).

### Deprecated

- `LoadingOverlayThemeData.iconColor` (and its constructor and `copyWith`
  parameters): it never had any effect. It will be removed in a future
  release.

### Changed

- While an overlay is visible, keyboard focus moves into it, so a focused
  text field behind it loses focus (closing the on-screen keyboard) until
  the overlay is removed.
- The overlay card keeps a 16 px vertical margin from the screen edges and
  stays inside the system safe area.
- README: new "Back button and keyboard" section, clearing fields with
  `copyWith`, and a rewritten "Testing" section.

## [0.0.3] - 2026-09-26

No code changes are required when upgrading. Because `^0.0.2` only allows
`0.0.2`, update your constraint to `^0.0.3`.

### Fixed

- The package now works on Flutter 3.22 (Dart 3.4) and newer, as the
  README always stated. 0.0.2 required Dart 3.5 and used
  `Color.withValues`, which does not exist in older Flutter versions such
  as 3.22.
- Overlays using an overshooting `animationCurve` (for example
  `Curves.easeOutBack`) no longer throw an `Opacity` assertion.
- Calling `show()` while the overlay is animating out now keeps it on
  screen. Previously it disappeared anyway, and the interrupted `hide()`
  future could never complete.
- Tapping a dismissible barrier several times calls `onDismiss` only once.
- `LoadingOverlay.controller` now stays in sync: it resets when the overlay
  is dismissed by a tap, and `controller.update()`, `controller.hide()` and
  `controller.show()` now change the visible overlay (they had no visible
  effect before).
- If the `Navigator`/`Overlay` hosting the overlay is removed from the tree,
  the overlay is dropped. Previously `isShowing` stayed `true` and every
  later `show()` silently did nothing.
- `LoadingOverlay.show()` can be called from `initState` and during a
  build. It previously threw a "setState() called during build" error.
- `LoadingOverlayScope.show()` without a config now uses the scope's
  `theme` (it previously ignored it).
- Fixed memory leaks: `OverlayEntry` objects are now disposed, the overlay
  no longer adds an animation listener on every rebuild (for example every
  progress update), `CurvedAnimation`s are disposed, and the global API no
  longer keeps a removed `Navigator` or the last config's callbacks alive.
- `BarsLoader` with `barCount` below 3, and `DotsLoader` with `dotCount`
  above 3, no longer overflow.
- `LoadingOverlayScope.of()` throws a descriptive `FlutterError` in release
  mode too, instead of a null-check error.

### Added

- `useRootOverlay` on `LoadingOverlay.show()` and
  `context.showLoadingOverlay()`, to cover the whole app from inside a
  nested `Navigator`.
- `semanticsLabel` on `show()`, `LoadingOverlayConfig` and
  `LoadingOverlayThemeData`, to localize the screen-reader label
  (default `'Loading overlay'`).
- `LoadingOverlayConfig.fromTheme()`, to build a config from a theme.
- `LoadingOverlayScope(controller: ...)`, to drive a scoped overlay from
  outside the widget tree, plus `LoadingOverlayScopeState.controller` and
  `LoadingOverlayScope.maybeOf()`.
- `LoadingOverlayDefaults.semanticsLabel`.

### Changed

- Screen readers can no longer reach content behind a visible overlay.
- The overlay content is kept above the on-screen keyboard.
- `LoadingOverlay.isShowing` (and the scope's `isShowing`) become `false`
  as soon as `hide()` is called, as documented, rather than after the exit
  animation.
- Debug-mode assertions now reject negative `spacing`, `loaderSize` and
  `elevation`, and loader counts below 1 (these previously crashed during
  layout).
- Rendering: spinners repaint without rebuilding widgets, the loader
  repaints separately from the card, and the barrier fades without
  rebuilding every frame.
- README rewritten to match actual behavior, including testing tips and
  limitations. The example app now shows error-safe usage, progress updates
  and a scoped overlay.

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
