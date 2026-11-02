# elegant_loading_overlay

[![pub package](https://img.shields.io/pub/v/elegant_loading_overlay.svg)](https://pub.dev/packages/elegant_loading_overlay)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.22-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.4-blue.svg)](https://dart.dev)

A customizable, modal loading overlay for Flutter with a one-line API:
`LoadingOverlay.show(context: context)` / `LoadingOverlay.hide()`.

It blocks interaction with the screen while work is running and shows one
of 11 built-in loaders (or your own widget), with optional message,
subtitle, progress bar, blurred barrier and entry/exit animations. It has
no dependencies beyond the Flutter SDK.

## Features

- **One-line API**: `LoadingOverlay.show()` / `LoadingOverlay.hide()`, plus
  `context.showLoadingOverlay()` extensions
- **11 built-in loaders**: circular, dots, pulse, ripple, bars, cube, ring,
  gradient spinner, minimal spinner, Material spinner, Cupertino spinner
- **Animations**: fade, scale, slide, zoom, rotation, or none
- **Progress**: optional determinate progress bar, updatable in place
- **Messages**: message and subtitle text
- **Custom builder**: replace the built-in content with any widget
- **Theming**: app-wide defaults with `LoadingOverlayTheme`
- **Scoped overlays**: independent overlays per page with
  `LoadingOverlayScope`, optionally driven by your own controller
- **Single overlay**: calling `show()` again updates the visible overlay
  instead of stacking another one
- **Truly modal**: blocks taps, keyboard focus and the system back button
  while visible (back dismisses the overlay when it is dismissible)
- **Accessibility**: a live-region label (localizable), and content behind
  the overlay is hidden from screen readers while it is visible
- **Fits any screen**: the content stays above the on-screen keyboard and
  scrolls when it does not fit (small screens, large text)
- **All platforms**: Android, iOS, web, macOS, Windows, Linux

## Installation

```yaml
dependencies:
  elegant_loading_overlay: ^0.0.5
```

```bash
flutter pub get
```

Requires Flutter 3.22 or newer (Dart 3.4 or newer).

## Quick start

```dart
import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';

LoadingOverlay.show(context: context);
try {
  await saveOrder();
} finally {
  await LoadingOverlay.hide();
}
```

Hide the overlay in `finally` so that an exception can never leave it on
screen.

To show an error dialog, hide the overlay first: dialogs and pages pushed
while the overlay is visible open underneath it (see
[Behavior notes](#behavior-notes-and-limitations)).

```dart
LoadingOverlay.show(context: context);
try {
  await saveOrder();
} catch (e) {
  await LoadingOverlay.hide(); // before showing the dialog
  if (context.mounted) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(title: Text('Could not save: $e')),
    );
  }
} finally {
  await LoadingOverlay.hide(); // completes at once if already hidden
}
```

`context` must be below a `Navigator` (for example any widget inside a
page of your `MaterialApp`). The overlay is inserted into that Navigator's
`Overlay` and covers the whole route area.

## Usage

### Message and subtitle

```dart
LoadingOverlay.show(
  context: context,
  message: 'Uploading file',
  subtitle: 'This may take a moment',
);
```

### Progress

Pass `progress` (0.0 to 1.0) to show a progress bar. To update it, call
`show()` again: the visible overlay is updated instead of being replaced.

```dart
for (var i = 0; i <= 10; i++) {
  if (!context.mounted) break;
  LoadingOverlay.show(
    context: context,
    message: 'Downloading ${i * 10}%',
    progress: i / 10,
  );
  await downloadChunk(i);
}
await LoadingOverlay.hide();
```

You can also update the visible overlay through the controller, without a
`BuildContext`:

```dart
final config = LoadingOverlay.controller.value;
if (config != null) {
  LoadingOverlay.controller.update(config.copyWith(progress: 0.8));
}
```

`copyWith` keeps the current value when an argument is `null`. To remove
an optional value, use the matching flag: `clearMessage`, `clearSubtitle`,
`clearProgress`, `clearBuilder` or `clearOnDismiss`.

```dart
// Switch from a progress bar to an indeterminate "Finishing up" state.
LoadingOverlay.controller.update(
  config.copyWith(message: 'Finishing up', clearProgress: true),
);
```

### Dismissible

```dart
LoadingOverlay.show(
  context: context,
  message: 'Tap outside to cancel',
  dismissible: true,
  onDismiss: () => request.cancel(),
);
```

`onDismiss` is called once, when the user taps the barrier, presses the
system back button or Escape, or uses the screen reader's dismiss action;
it is not called when you call `hide()` yourself. It may call `show()`
again (for example to show a retry message); that new overlay stays
visible.

### Back button and keyboard

While an overlay is visible, the system back button (Android back,
browser back, `Navigator.maybePop`) does not pop the page behind it:

- a non-dismissible overlay ignores it;
- a dismissible overlay is dismissed, calling `onDismiss`.

This applies to the top route of the Navigator hosting the overlay, of the
Navigator around the code that showed it (the `context` passed to `show()`,
or the `LoadingOverlayScope`) and every Navigator above that one, and of
the root Navigator. So back is also blocked when it is forwarded to a
nested Navigator (by `NavigatorPopHandler` or go_router's
`StatefulShellRoute`) while the overlay covers the whole app with
`useRootOverlay: true`. Programmatic `Navigator.pop()` is not blocked, so
code that pops a page before hiding the overlay keeps working. Back
navigation works normally again as soon as `hide()` is called.

`show()` and `hide()` can be called from a `PopScope` callback, for example
to show a "Saving draft" overlay when the user presses back:

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    LoadingOverlay.show(context: context, message: 'Saving draft');
    await saveDraft();
    await LoadingOverlay.hide();
    if (context.mounted) Navigator.pop(context);
  },
  child: editor,
)
```

On Flutter 3.22, use `onPopInvoked: (didPop) async { ... }` instead.

Keyboard focus moves into the overlay while it is visible, so Tab, Enter
and Space cannot reach widgets behind it. Escape dismisses a dismissible
overlay and does nothing otherwise. Focusable widgets in a custom
`builder` (a Cancel button, a text field) work and can be reached with
Tab. When the overlay is removed, focus returns to the widget that had it
before, if that widget is still on screen and focus has not moved on in
the meantime (for example to a page pushed while the overlay was visible).
If a text field had focus, the on-screen keyboard closes while the overlay
is visible and may reopen afterwards.

### Status and toggle

```dart
if (LoadingOverlay.isShowing) {
  await LoadingOverlay.hide();
}

await LoadingOverlay.toggle(context: context);
```

`isShowing` becomes `false` as soon as `hide()` is called, while the exit
animation is still playing. Calling `show()` during that exit animation
cancels it and keeps the overlay on screen.

### Animation

```dart
LoadingOverlay.show(
  context: context,
  animation: LoadingAnimationType.scale,
  animationDuration: const Duration(milliseconds: 400),
  animationCurve: Curves.easeOutBack,
);
```

### Loader type

```dart
LoadingOverlay.show(context: context, loaderType: LoaderType.dots);
```

The loader widgets are also exported (`CircularLoader`, `DotsLoader`,
`BarsLoader`, ...) and can be used anywhere in your UI, or through
`LoadingIndicator(loaderType: ...)`. They scale down to fit a parent that
is smaller than their `size`; a negative `size` draws nothing.

### Custom content

`builder` replaces the loader, message and progress bar. The result is
still shown inside the overlay's card (background, padding, elevation),
and text and icons in it default to a color that is readable on the card
(see [Theming](#theming)).

The card is limited to the space between the system UI and the on-screen
keyboard; when its content is taller (long messages, large text scale,
small or landscape screens), the content scrolls inside the card. Content
that fits is shown exactly as before.

```dart
LoadingOverlay.show(
  context: context,
  builder: (_) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
      SizedBox(height: 16),
      Text('Uploading...'),
    ],
  ),
);
```

### Blur and styling

```dart
LoadingOverlay.show(
  context: context,
  enableBlur: true,
  blurSigma: 5,
  barrierColor: Colors.black54,
  backgroundColor: Colors.white,
  loaderColor: Colors.teal,
  borderRadius: BorderRadius.circular(20),
  elevation: 12,
);
```

Background blur uses a `BackdropFilter`, which is comparatively expensive
to render. Set `enableBlur: false` (or `blurSigma: 0`) on low-end devices.

### Nested navigators

When `context` is inside a nested `Navigator` (for example a tab with its
own navigation stack), the overlay only covers that Navigator. Use
`useRootOverlay: true` to cover the whole app, including a bottom
navigation bar:

```dart
LoadingOverlay.show(context: context, useRootOverlay: true);
```

Back is still blocked on the nested page, also when back is forwarded to
the nested Navigator (`NavigatorPopHandler`, go_router's
`StatefulShellRoute`).

### Calling from `initState`

`show()` can be called from `initState` or during a build; the overlay is
inserted at the end of the current frame.

```dart
@override
void initState() {
  super.initState();
  LoadingOverlay.show(context: context, message: 'Loading');
  _load().whenComplete(LoadingOverlay.hide);
}
```

### Context extensions

```dart
context.showLoadingOverlay(message: 'Loading...');
context.hideLoadingOverlay();
```

`showLoadingOverlay` accepts the same parameters as `LoadingOverlay.show`.

## Theming

Wrap your app with `LoadingOverlayTheme` to set defaults. Arguments passed
to `show()` override the theme, and the theme overrides the package
defaults.

```dart
LoadingOverlayTheme(
  data: LoadingOverlayThemeData(
    loaderColor: Colors.tealAccent,
    backgroundColor: Colors.grey.shade900,
    messageTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
    blurSigma: 5,
    animationDuration: const Duration(milliseconds: 400),
    animationType: LoadingAnimationType.scale,
    loaderType: LoaderType.gradientSpinner,
    semanticsLabel: 'Please wait', // localize for screen readers
  ),
  child: MaterialApp(home: MyHomePage()),
)
```

The default card is white in both light and dark apps. Text and icons in
the card default to a color that is readable on its `backgroundColor`,
whatever the app's theme: dark grey on a light card and white on a dark
card. This includes text and icons in a custom `builder`. A
`messageStyle`/`subtitleStyle` (or the theme's `messageTextStyle`/
`subtitleTextStyle`) is merged into that default, so
`TextStyle(fontSize: 20)` only changes the size.

## Scoped overlays

`LoadingOverlayScope` gives a subtree its own overlay, independent of the
global `LoadingOverlay`. Its overlay is removed automatically when the
scope leaves the tree (for example when its page is popped).

```dart
LoadingOverlayScope(
  theme: const LoadingOverlayThemeData(loaderColor: Colors.purple),
  child: MyPage(),
)

// In MyPage:
final scope = LoadingOverlayScope.of(context);
scope.show(); // uses the scope's theme
await scope.hide();
```

`show()` without arguments uses the scope's theme. An explicit
`LoadingOverlayConfig` is used as given; start from the theme with
`LoadingOverlayConfig.fromTheme`:

```dart
scope.show(
  LoadingOverlayConfig.fromTheme(LoadingOverlayTheme.of(context))
      .copyWith(message: 'Saving'),
);
```

Place the scope below `MaterialApp` (for example around a page), because
its overlay is inserted into the nearest `Overlay` above the scope.

`LoadingOverlayScope.of(context)` and `LoadingOverlayTheme.of(context)` also
work inside the scope's overlay, for example for a Cancel button in a
custom `builder`:

```dart
scope.show(
  LoadingOverlayConfig(
    builder: (context) => TextButton(
      onPressed: () => LoadingOverlayScope.of(context).hide(),
      child: const Text('Cancel'),
    ),
  ),
);
```

### Driving a scope from outside the widget tree

Pass your own `LoadingOverlayController` to control the overlay from a
view model or service. The scope does not dispose a controller you pass
in.

```dart
final controller = LoadingOverlayController();

LoadingOverlayScope(controller: controller, child: const MyPage());

controller.show(const LoadingOverlayConfig(message: 'Syncing'));
controller.hide();
```

## Built-in loaders

| Loader | Description |
|--------|-------------|
| `circular` | Rotating arc spinner (default) |
| `dots` | Bouncing wave dots |
| `pulse` | Pulsing circle |
| `ripple` | Expanding ripple rings |
| `bars` | Equalizer-style bars |
| `cube` | Rotating 3D square |
| `ring` | Spinning arc on a faded ring |
| `gradientSpinner` | Gradient arc spinner |
| `minimalSpinner` | Thin line spinner |
| `materialSpinner` | Material `CircularProgressIndicator` |
| `cupertinoSpinner` | iOS `CupertinoActivityIndicator` |

## Animations

| Animation | Description |
|-----------|-------------|
| `fade` | Fade in and out (default) |
| `scale` | Grows from the center with a slight overshoot |
| `slide` | Slides up from below |
| `zoom` | Scales from half size while fading in |
| `rotation` | Turns half a rotation into place while scaling in |
| `none` | No card animation (the barrier still fades) |

## API reference

### `LoadingOverlay`

| Member | Description |
|--------|-------------|
| `show({required context, ...})` | Shows the overlay, or updates the visible one |
| `hide()` | Hides with the exit animation; the future completes when removed |
| `toggle({context, message, loaderType})` | Hides if showing, otherwise shows |
| `isShowing` | Whether an overlay is visible and not animating out |
| `controller` | The global `LoadingOverlayController` |
| `of(context)` | The nearest `LoadingOverlayThemeData`, or `null` |

### Options

Accepted by `LoadingOverlay.show`, `context.showLoadingOverlay` and
`LoadingOverlayConfig` (where `animation` is called `animationType`).
`useRootOverlay` exists only on the two `show` methods.

| Parameter | Type | Default |
|-----------|------|---------|
| `message` | `String?` | `null` |
| `subtitle` | `String?` | `null` |
| `progress` | `double?` | `null` (no progress bar) |
| `dismissible` | `bool` | `false` |
| `animation` / `animationType` | `LoadingAnimationType` | `fade` |
| `animationDuration` | `Duration` | 300 ms |
| `animationCurve` | `Curve` | `Curves.easeInOut` |
| `barrierColor` | `Color` | `Color(0x80000000)` (50% black) |
| `backgroundColor` | `Color` | `Colors.white` |
| `loaderColor` | `Color` | `Color(0xFF2196F3)` (Material blue) |
| `blurSigma` | `double` | `3.0` |
| `enableBlur` | `bool` | `true` |
| `borderRadius` | `BorderRadius` | 16 |
| `padding` | `EdgeInsets` | 32 on all sides |
| `spacing` | `double` | `16.0` |
| `loaderSize` | `double` | `48.0` |
| `elevation` | `double` | `8.0` |
| `loaderType` | `LoaderType` | `circular` |
| `builder` | `WidgetBuilder?` | `null` |
| `onDismiss` | `VoidCallback?` | `null` |
| `messageStyle` | `TextStyle?` | 16 px, medium, dark grey (white on a dark card); merged into this default |
| `subtitleStyle` | `TextStyle?` | 13 px, grey (white70 on a dark card); merged into this default |
| `semanticsLabel` | `String` | `'Loading overlay'` |
| `useRootOverlay` | `bool` | `false` |

All defaults are available as constants on `LoadingOverlayDefaults`.

## Testing

Two things behave differently in widget tests (`testWidgets`), where time
only advances when you pump frames:

1. **Don't use `pumpAndSettle()` while an overlay is visible.** The
   built-in loaders repeat forever, so there is never a settled frame and
   `pumpAndSettle()` times out. Pump a fixed duration instead:

   ```dart
   LoadingOverlay.show(context: context);
   await tester.pump();
   await tester.pump(const Duration(milliseconds: 500));
   expect(find.byType(CircularLoader), findsOneWidget);
   ```

2. **Don't `await LoadingOverlay.hide()` without pumping.** Its future
   completes only after the exit animation, and that animation needs
   frames. Awaiting it directly deadlocks the test. Start the hide, pump,
   then await:

   ```dart
   final f = LoadingOverlay.hide();
   await tester.pump();
   await tester.pump(const Duration(milliseconds: 400));
   await f;
   ```

   The same applies to `LoadingOverlayScope.of(context).hide()`.

After the overlay is gone, `pumpAndSettle()` works normally again.

**Leak tracking.** `LoadingOverlay.controller` lives as long as the app and
is never disposed. The package reports it to Flutter's leak tracker as
released, so tests run with `LeakTesting.enable()` (from
`leak_tracker_flutter_testing`) need no ignore entry for it.

## Behavior notes and limitations

- **One global overlay.** `LoadingOverlay` shows at most one overlay at a
  time. Use `LoadingOverlayScope` for independent overlays.
- **Routes pushed while the overlay is visible open underneath the
  overlay.** This applies to pages, dialogs and bottom sheets: they cannot
  be seen or used until `hide()` is called. Call
  `await LoadingOverlay.hide()` before `showDialog` (see
  [Quick start](#quick-start)); otherwise code like
  `catch (e) { await showDialog(...); } finally { await LoadingOverlay.hide(); }`
  never reaches `hide()`, because nobody can close the dialog. The overlay
  is an `OverlayEntry`, which the Navigator always keeps above its routes.
- **Back button and new routes.** Back is blocked on the routes that were
  on top when the overlay was shown. If your code pushes another route
  while the overlay is still visible, back on that new route is not
  blocked.
- **Host removed.** If the `Navigator` hosting the overlay is removed from
  the tree, the overlay is dropped and `isShowing` becomes `false`; the next
  `show()` works normally.
- **`controller.show()` without a context** reuses the `Overlay` of the most
  recent `LoadingOverlay.show()` call. Before the first `show()` call there
  is no Overlay to use, and an error is reported instead. Do not dispose
  `LoadingOverlay.controller`.

## Platform support

The package is pure Dart and Flutter, with no platform channels. It works
on Android, iOS, web, macOS, Windows and Linux.

## Contributing

Contributions are welcome. Please read the
[contributing guide](CONTRIBUTING.md) and the
[code of conduct](CODE_OF_CONDUCT.md) first.

## License

MIT; see [LICENSE](LICENSE).
