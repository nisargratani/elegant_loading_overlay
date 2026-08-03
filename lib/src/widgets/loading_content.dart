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

  @override
  Widget build(BuildContext context) {
    // Use custom builder if provided.
    if (config.builder != null) {
      return config.builder!(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingIndicator(
          loaderType: config.loaderType,
          color: config.loaderColor,
          size: config.loaderSize,
        ),
        if (config.message != null) ...[
          SizedBox(height: config.spacing),
          Text(
            config.message!,
            style: config.messageStyle ??
                LoadingOverlayDefaults.messageTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
        if (config.subtitle != null) ...[
          SizedBox(height: config.spacing / 2),
          Text(
            config.subtitle!,
            style: config.subtitleStyle ??
                LoadingOverlayDefaults.subtitleTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
        if (config.progress != null) ...[
          SizedBox(height: config.spacing),
          SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                value: config.progress!.clamp(0.0, 1.0),
                backgroundColor:
                    config.loaderColor.withValues(alpha: 0.15),
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
}
