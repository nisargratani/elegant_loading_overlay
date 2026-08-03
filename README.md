# elegant_loading_overlay

[![pub package](https://img.shields.io/pub/v/elegant_loading_overlay.svg)](https://pub.dev/packages/elegant_loading_overlay)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.22-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.5-blue.svg)](https://dart.dev)

Beautiful, customizable loading overlay for Flutter with a one-line API. Features 11 built-in loaders, smooth animations, progress indicators, blur backgrounds, theme support, and full platform compatibility.

## ✨ Features

- 🚀 **One-line API** — `LoadingOverlay.show()` / `LoadingOverlay.hide()`
- 🎨 **11 Built-in Loaders** — Circular, Dots, Pulse, Ripple, Bars, Cube, Ring, Gradient Spinner, Minimal Spinner, Material Spinner, Cupertino Spinner
- 🎬 **Smooth Animations** — Fade, Scale, Slide, Zoom, Rotation
- 🌫️ **Blur Background** — Configurable blur sigma
- 📊 **Progress Indicators** — Determinate and indeterminate
- 💬 **Messages & Subtitles** — Customizable text content
- 🎯 **Custom Builder** — Full control with custom widgets
- 🎭 **Theme Support** — `LoadingOverlayTheme` for consistent styling
- 🔒 **Stacking Protection** — Only one overlay at a time
- ♿ **Accessibility** — Full semantics support
- 🌍 **Cross-Platform** — Android, iOS, Web, macOS, Windows, Linux
- 🌙 **Dark Mode** — Fully supported
- 📱 **Responsive** — Mobile, Tablet, Desktop
- ⚡ **Performant** — RepaintBoundary, ValueNotifier, const widgets
- 🧪 **Well Tested** — Comprehensive widget and unit tests
- 📦 **Zero Dependencies** — Flutter SDK only

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  elegant_loading_overlay: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';

// Show
LoadingOverlay.show(context: context);

// Hide
await LoadingOverlay.hide();
```

## 📖 Usage

### Basic Loading

```dart
LoadingOverlay.show(context: context);

await doSomeWork();

await LoadingOverlay.hide();
```

### With Message

```dart
LoadingOverlay.show(
  context: context,
  message: 'Loading...',
);
```

### With Message & Subtitle

```dart
LoadingOverlay.show(
  context: context,
  message: 'Uploading file',
  subtitle: 'This may take a moment',
);
```

### With Progress

```dart
LoadingOverlay.show(
  context: context,
  message: 'Downloading...',
  progress: 0.45,
);
```

### Dismissible

```dart
LoadingOverlay.show(
  context: context,
  dismissible: true,
  onDismiss: () => print('Dismissed!'),
);
```

### Check Status & Toggle

```dart
if (LoadingOverlay.isShowing) {
  await LoadingOverlay.hide();
}

// Or toggle
await LoadingOverlay.toggle(context: context);
```

### Custom Animation

```dart
LoadingOverlay.show(
  context: context,
  animation: LoadingAnimationType.scale,
  animationDuration: const Duration(milliseconds: 400),
  animationCurve: Curves.easeOutBack,
);
```

### Different Loaders

```dart
// Dots loader
LoadingOverlay.show(
  context: context,
  loaderType: LoaderType.dots,
);

// Pulse loader
LoadingOverlay.show(
  context: context,
  loaderType: LoaderType.pulse,
);

// Ripple loader
LoadingOverlay.show(
  context: context,
  loaderType: LoaderType.ripple,
);

// ... and 8 more!
```

### Custom Loader (Builder)

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

### Blur & Styling

```dart
LoadingOverlay.show(
  context: context,
  enableBlur: true,
  blurSigma: 5.0,
  barrierColor: Colors.black54,
  backgroundColor: Colors.white,
  loaderColor: Colors.teal,
  borderRadius: BorderRadius.circular(20),
  elevation: 12,
);
```

### Context Extensions

```dart
// Show
context.showLoadingOverlay(message: 'Loading...');

// Hide
context.hideLoadingOverlay();
```

## 🎨 Theming

Wrap your app with `LoadingOverlayTheme` for consistent styling:

```dart
LoadingOverlayTheme(
  data: LoadingOverlayThemeData(
    loaderColor: Colors.tealAccent,
    backgroundColor: Colors.grey.shade900,
    messageTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    blurSigma: 5.0,
    animationDuration: const Duration(milliseconds: 400),
    animationType: LoadingAnimationType.scale,
    loaderType: LoaderType.gradientSpinner,
  ),
  child: MaterialApp(
    home: MyHomePage(),
  ),
)
```

## 🔧 Scoped Overlays

Use `LoadingOverlayScope` for independent overlay control in different parts of your app:

```dart
LoadingOverlayScope(
  theme: const LoadingOverlayThemeData(
    loaderColor: Colors.purple,
  ),
  child: MyPage(),
)

// In MyPage:
final scope = LoadingOverlayScope.of(context);
scope.show();
await scope.hide();
```

## 🎬 Available Animations

| Animation | Description |
|-----------|-------------|
| `fade` | Smooth fade-in/fade-out (default) |
| `scale` | Grows from center with bounce |
| `slide` | Slides up from bottom |
| `zoom` | Scale + fade combination |
| `rotation` | Spins into view |
| `none` | Instant, no animation |

## 🎡 Built-in Loaders

| Loader | Description |
|--------|-------------|
| `circular` | Rotating arc spinner (default) |
| `dots` | Bouncing wave dots |
| `pulse` | Pulsing circle |
| `ripple` | Expanding ripple rings |
| `bars` | Equalizer-style bars |
| `cube` | Rotating 3D cube |
| `ring` | Spinning ring with gap |
| `gradientSpinner` | Gradient arc spinner |
| `minimalSpinner` | Thin line spinner |
| `materialSpinner` | Material CircularProgressIndicator |
| `cupertinoSpinner` | iOS CupertinoActivityIndicator |

## 📐 API Reference

### LoadingOverlay (Static API)

| Method | Description |
|--------|-------------|
| `show({required context, ...})` | Show the overlay |
| `hide()` | Hide the overlay |
| `toggle({context, ...})` | Toggle visibility |
| `isShowing` | Check if overlay is visible |
| `of(context)` | Get theme data from context |
| `controller` | Access global controller |

### LoadingOverlayConfig

All configuration options for `show()`:

| Parameter | Type | Default |
|-----------|------|---------|
| `message` | `String?` | `null` |
| `subtitle` | `String?` | `null` |
| `progress` | `double?` | `null` |
| `dismissible` | `bool` | `false` |
| `animationType` | `LoadingAnimationType` | `fade` |
| `animationDuration` | `Duration` | `300ms` |
| `animationCurve` | `Curve` | `easeInOut` |
| `barrierColor` | `Color` | `Colors.black54` |
| `backgroundColor` | `Color` | `Colors.white` |
| `loaderColor` | `Color` | `Colors.blue` |
| `blurSigma` | `double` | `3.0` |
| `enableBlur` | `bool` | `true` |
| `borderRadius` | `BorderRadius` | `16.0` |
| `padding` | `EdgeInsets` | `32.0` |
| `spacing` | `double` | `16.0` |
| `loaderSize` | `double` | `48.0` |
| `elevation` | `double` | `8.0` |
| `loaderType` | `LoaderType` | `circular` |
| `builder` | `WidgetBuilder?` | `null` |
| `onDismiss` | `VoidCallback?` | `null` |

## 🌍 Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## ⚡ Performance Notes

- Uses `RepaintBoundary` to isolate overlay repaints
- `ValueNotifier`-based controller avoids stream overhead
- `const` constructors used throughout
- `CustomPainter`-based loaders for efficient rendering
- Stacking protection prevents duplicate overlay creation

## ❓ FAQ

**Q: Can I show multiple overlays at once?**
A: The global `LoadingOverlay` API enforces single-overlay mode. Use `LoadingOverlayScope` for independent overlays in different subtrees.

**Q: What happens if I call `hide()` without calling `show()`?**
A: Nothing. The method safely returns without error.

**Q: What happens if I call `show()` twice?**
A: The existing overlay is updated with the new configuration — no duplicate overlay is created.

**Q: Does it work with `Navigator.push`?**
A: Yes. The overlay is inserted into the root `Overlay` and appears above all routes.

**Q: Does it support keyboard avoidance?**
A: Yes. The overlay content is properly positioned to avoid keyboard overlap.

## 🗺️ Roadmap

- [ ] Shimmer effect loader
- [ ] Lottie animation support
- [ ] Progress stream support
- [ ] Global configuration
- [ ] Timeout with auto-dismiss
- [ ] Success/Error state transitions
- [ ] Haptic feedback option
- [ ] Sound effect option

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) first.

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
