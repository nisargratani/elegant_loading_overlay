/// The content widget displayed inside the loading overlay.
///
/// Composes the loader indicator, optional message, optional
/// subtitle, and optional progress bar into a cohesive layout.
library;

import 'package:flutter/material.dart';

import '../constants/defaults.dart';
import '../models/loading_overlay_config.dart';
import 'loaders/loading_indicator.dart';

/// Renders the loading overlay content including the loader,
/// message, subtitle, and progress indicator.
///
/// Text and icons default to a color that is readable on the card's
/// [LoadingOverlayConfig.backgroundColor], whatever the app's theme:
/// dark grey on light cards and white on dark cards. This also applies
/// to a custom [LoadingOverlayConfig.builder]. The message and subtitle
/// styles of the config are merged into these defaults.
///
/// This widget is used internally by the overlay system and is
/// not typically instantiated directly.
///
/// See also:
///
///  * [LoadingOverlayConfig], which provides the configuration.
///  * [LoadingIndicator], which renders the loader animation.
class LoadingContent extends StatelessWidget {
  /// Creates a loading content widget.
  const LoadingContent({
    required this.config,
    super.key,
  });

  /// The configuration that controls the content appearance.
  final LoadingOverlayConfig config;

  /// 15% opacity for the progress bar track.
  static const int _trackAlpha = 38;

  /// Message and subtitle styles used on dark cards.
  static final TextStyle _messageOnDark =
      LoadingOverlayDefaults.messageTextStyle.copyWith(color: Colors.white);
  static final TextStyle _subtitleOnDark =
      LoadingOverlayDefaults.subtitleTextStyle.copyWith(color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    // The card has its own background, so text inherited from the app
    // theme (light text in a dark app) can be unreadable on it.
    final darkCard =
        ThemeData.estimateBrightnessForColor(config.backgroundColor) ==
            Brightness.dark;
    final messageDefault =
        darkCard ? _messageOnDark : LoadingOverlayDefaults.messageTextStyle;
    final subtitleDefault =
        darkCard ? _subtitleOnDark : LoadingOverlayDefaults.subtitleTextStyle;
    final foreground = messageDefault.color;
    final builder = config.builder;

    return DefaultTextStyle.merge(
      style: TextStyle(color: foreground),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: builder != null
            // A Builder, so that the builder's context sees the defaults.
            ? Builder(builder: builder)
            : _buildDefaultContent(
                messageStyle: messageDefault.merge(config.messageStyle),
                subtitleStyle: subtitleDefault.merge(config.subtitleStyle),
              ),
      ),
    );
  }

  Widget _buildDefaultContent({
    required TextStyle messageStyle,
    required TextStyle subtitleStyle,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The loader repaints every frame; isolate it so the card's
          // shadow and text are not re-recorded with it.
          RepaintBoundary(
            child: LoadingIndicator(
              loaderType: config.loaderType,
              color: config.loaderColor,
              size: config.loaderSize,
            ),
          ),
          if (config.message != null) ...[
            SizedBox(height: config.spacing),
            Text(
              config.message!,
              style: messageStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (config.subtitle != null) ...[
            SizedBox(height: config.spacing / 2),
            Text(
              config.subtitle!,
              style: subtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (config.progress != null) ...[
            SizedBox(height: config.spacing),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: config.progress!.clamp(0.0, 1.0),
                  // withAlpha (not withValues) keeps Flutter 3.22 support.
                  backgroundColor: config.loaderColor.withAlpha(_trackAlpha),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    config.loaderColor,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ],
      );
}
