/// Platform utility helpers for the loading overlay package.
///
/// Provides platform detection without requiring `dart:io`,
/// ensuring web compatibility.
library;

import 'package:flutter/foundation.dart';

/// Utility class for platform detection.
///
/// Uses [defaultTargetPlatform] and [kIsWeb] for cross-platform
/// compatibility without importing `dart:io`.
///
/// See also:
///
///  * [TargetPlatform], Flutter's platform enum.
abstract final class PlatformUtils {
  /// Whether the app is running on the web.
  static bool get isWeb => kIsWeb;

  /// Whether the app is running on a mobile platform (iOS/Android).
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// Whether the app is running on a desktop platform.
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// Whether the app is running on iOS.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the app is running on Android.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the app is running on macOS.
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
}
