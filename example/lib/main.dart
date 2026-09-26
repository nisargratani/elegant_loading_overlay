// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LoadingOverlayExampleApp());
}

class LoadingOverlayExampleApp extends StatelessWidget {
  const LoadingOverlayExampleApp({super.key});

  @override
  Widget build(BuildContext context) => LoadingOverlayTheme(
        // App-wide defaults; every argument of LoadingOverlay.show()
        // overrides the matching theme value.
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

/// Simulates a network call.
Future<void> _fakeWork([Duration duration = const Duration(seconds: 2)]) =>
    Future<void>.delayed(duration);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _showBasic() async {
    LoadingOverlay.show(context: context);
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showWithMessage() async {
    LoadingOverlay.show(context: context, message: 'Loading data...');
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showWithSubtitle() async {
    LoadingOverlay.show(
      context: context,
      message: 'Uploading file',
      subtitle: 'This may take a moment',
    );
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showWithProgress() async {
    LoadingOverlay.show(
      context: context,
      message: 'Downloading... 0%',
      progress: 0,
    );

    for (var i = 1; i <= 10; i++) {
      await _fakeWork(const Duration(milliseconds: 300));
      // Update the visible overlay in place through the controller.
      final config = LoadingOverlay.controller.value;
      if (config == null) return; // Hidden elsewhere.
      LoadingOverlay.controller.update(
        config.copyWith(
          progress: i / 10,
          message: 'Downloading... ${i * 10}%',
        ),
      );
    }

    await _fakeWork(const Duration(milliseconds: 500));
    await LoadingOverlay.hide();
  }

  /// The recommended pattern: always hide in `finally`, so a failing
  /// task can never leave the overlay on screen.
  Future<void> _showFailingTask() async {
    LoadingOverlay.show(context: context, message: 'Saving...');
    try {
      await _fakeWork(const Duration(seconds: 1));
      throw Exception('Server unavailable');
    } on Exception catch (error) {
      _snack('Failed: $error');
    } finally {
      await LoadingOverlay.hide();
    }
  }

  void _showDismissible() {
    LoadingOverlay.show(
      context: context,
      message: 'Tap outside to dismiss',
      dismissible: true,
      onDismiss: () => _snack('Overlay dismissed'),
    );
  }

  Future<void> _showWithBlur() async {
    LoadingOverlay.show(
      context: context,
      message: 'With blur effect',
      enableBlur: true,
      blurSigma: 8,
    );
    await _fakeWork();
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showDarkStyle() async {
    LoadingOverlay.show(
      context: context,
      message: 'Dark style overlay',
      backgroundColor: const Color(0xFF1E1E2E),
      loaderColor: const Color(0xFF89B4FA),
      barrierColor: const Color(0xCC000000),
      messageStyle: const TextStyle(
        color: Color(0xFFCDD6F4),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showLoader(LoaderType type) async {
    LoadingOverlay.show(context: context, loaderType: type, message: type.name);
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  Future<void> _showAnimation(LoadingAnimationType animation) async {
    LoadingOverlay.show(
      context: context,
      animation: animation,
      message: animation.name,
    );
    await _fakeWork();
    await LoadingOverlay.hide();
  }

  void _openScopedPage() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ScopedPage()),
      ),
    );
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
            _DemoButton('With Subtitle', Icons.subtitles, _showWithSubtitle),
            _DemoButton('With Progress', Icons.download, _showWithProgress),
            _DemoButton('Failing Task', Icons.error_outline, _showFailingTask),
            _DemoButton('Dismissible', Icons.touch_app, _showDismissible),
            _DemoButton('Blur Background', Icons.blur_on, _showWithBlur),
            _DemoButton('Custom Builder', Icons.build, _showCustomBuilder),
            _DemoButton('Dark Style', Icons.dark_mode, _showDarkStyle),
            _DemoButton('Scoped Overlay Page', Icons.layers, _openScopedPage),
            const SizedBox(height: 24),
            const _SectionHeader('Built-in Loaders'),
            for (final type in LoaderType.values)
              _DemoButton(type.name, Icons.animation, () => _showLoader(type)),
            const SizedBox(height: 24),
            const _SectionHeader('Animations'),
            for (final animation in LoadingAnimationType.values)
              _DemoButton(
                animation.name,
                Icons.motion_photos_on,
                () => _showAnimation(animation),
              ),
            const SizedBox(height: 32),
          ],
        ),
      );
}

/// A page with its own, independently themed overlay. Leaving the page
/// while the overlay is visible removes it automatically.
class ScopedPage extends StatelessWidget {
  const ScopedPage({super.key});

  @override
  Widget build(BuildContext context) => LoadingOverlayScope(
        theme: const LoadingOverlayThemeData(
          loaderType: LoaderType.ripple,
          loaderColor: Colors.teal,
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Scoped Overlay')),
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  // No config: the scope's theme is used.
                  final scope = LoadingOverlayScope.of(context)..show();
                  await _fakeWork();
                  await scope.hide();
                },
                child: const Text('Show scoped overlay'),
              ),
            ),
          ),
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
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
}
