// ignore_for_file: public_member_api_docs

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LoadingOverlayExampleApp());
}

class LoadingOverlayExampleApp extends StatelessWidget {
  const LoadingOverlayExampleApp({super.key});

  @override
  Widget build(BuildContext context) => LoadingOverlayTheme(
        data: const LoadingOverlayThemeData(
          loaderColor: Color(0xFF6C63FF),
          animationType: LoadingAnimationType.scale,
        ),
        child: MaterialApp(
          title: 'Loading Overlay Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF6C63FF),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF6C63FF),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: const HomePage(),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _progress = 0;

  Future<void> _showBasic() async {
    LoadingOverlay.show(context: context);
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showWithMessage() async {
    LoadingOverlay.show(
      context: context,
      message: 'Loading data...',
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showWithSubtitle() async {
    LoadingOverlay.show(
      context: context,
      message: 'Uploading file',
      subtitle: 'This may take a moment',
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showWithProgress() async {
    _progress = 0;
    LoadingOverlay.show(
      context: context,
      message: 'Downloading...',
      progress: _progress,
    );

    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _progress = i / 10;
      LoadingOverlay.show(
        context: context,
        message: 'Downloading... ${(_progress * 100).toInt()}%',
        progress: _progress,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    await LoadingOverlay.hide();
  }

  Future<void> _showDismissible() async {
    LoadingOverlay.show(
      context: context,
      message: 'Tap outside to dismiss',
      dismissible: true,
    );
  }

  Future<void> _showWithBlur() async {
    LoadingOverlay.show(
      context: context,
      message: 'With blur effect',
      enableBlur: true,
      blurSigma: 8,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showCustomBuilder() async {
    LoadingOverlay.show(
      context: context,
      builder: (_) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload, size: 56, color: Color(0xFF6C63FF)),
          SizedBox(height: 16),
          Text(
            'Uploading to cloud...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showLoader(LoaderType type) async {
    LoadingOverlay.show(
      context: context,
      loaderType: type,
      message: type.name,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showAnimation(LoadingAnimationType animation) async {
    LoadingOverlay.show(
      context: context,
      animation: animation,
      message: animation.name,
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  Future<void> _showDarkMode() async {
    LoadingOverlay.show(
      context: context,
      message: 'Dark mode overlay',
      backgroundColor: const Color(0xFF1E1E2E),
      loaderColor: const Color(0xFF89B4FA),
      barrierColor: const Color(0xCC000000),
      messageStyle: const TextStyle(
        color: Color(0xFFCDD6F4),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    await LoadingOverlay.hide();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Loading Overlay Demo'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader('Basic'),
            _DemoButton('Basic Loading', Icons.hourglass_empty, _showBasic),
            _DemoButton('With Message', Icons.message, _showWithMessage),
            _DemoButton(
              'With Subtitle',
              Icons.subtitles,
              _showWithSubtitle,
            ),
            _DemoButton('With Progress', Icons.download, _showWithProgress),
            _DemoButton(
              'Dismissible',
              Icons.touch_app,
              _showDismissible,
            ),
            _DemoButton('Blur Background', Icons.blur_on, _showWithBlur),
            _DemoButton(
              'Custom Builder',
              Icons.build,
              _showCustomBuilder,
            ),
            _DemoButton('Dark Mode', Icons.dark_mode, _showDarkMode),
            const SizedBox(height: 24),
            const _SectionHeader('Built-in Loaders'),
            ...LoaderType.values.map(
              (type) => _DemoButton(
                type.name,
                Icons.animation,
                () => _showLoader(type),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader('Animations'),
            ...LoadingAnimationType.values.map(
              (animation) => _DemoButton(
                animation.name,
                Icons.motion_photos_on,
                () => _showAnimation(animation),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
}

class _DemoButton extends StatelessWidget {
  const _DemoButton(this.label, this.icon, this.onPressed);
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      );
}
