# elegant_loading_overlay example

A demo app showing every loader, animation and major option of
[`elegant_loading_overlay`](https://pub.dev/packages/elegant_loading_overlay):
messages, progress updates through the controller, error-safe
`try`/`finally` usage, dismissible overlays, custom builders, theming and a
page with its own `LoadingOverlayScope`.

The platform folders are not checked in. To run the example, generate them
once and start the app:

```bash
cd example
flutter create . --platforms=android,ios,web,macos,windows,linux
flutter run
```

The app code is in [`lib/main.dart`](lib/main.dart).
