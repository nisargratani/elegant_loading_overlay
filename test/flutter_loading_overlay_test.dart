import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper to wrap test widgets with MaterialApp + Overlay.
Widget buildTestApp({Widget? child}) => MaterialApp(
      home: child ?? const Scaffold(),
    );

void main() {
  group('LoadingOverlayController', () {
    late LoadingOverlayController controller;

    setUp(() {
      controller = LoadingOverlayController();
    });

    tearDown(() {
      if (!controller.isDisposed) {
        controller.dispose();
      }
    });

    test('initially not showing', () {
      expect(controller.isShowing, isFalse);
      expect(controller.value, isNull);
    });

    test('show sets value to config', () {
      controller.show();
      expect(controller.isShowing, isTrue);
      expect(controller.value, isNotNull);
    });

    test('show with custom config', () {
      const config = LoadingOverlayConfig(message: 'Test');
      controller.show(config);
      expect(controller.value?.message, 'Test');
    });

    test('hide clears value', () {
      controller
        ..show()
        ..hide();
      expect(controller.isShowing, isFalse);
      expect(controller.value, isNull);
    });

    test('hide when not showing does nothing', () {
      controller.hide(); // should not throw
      expect(controller.isShowing, isFalse);
    });

    test('toggle shows when hidden', () {
      controller.toggle();
      expect(controller.isShowing, isTrue);
    });

    test('toggle hides when showing', () {
      controller
        ..show()
        ..toggle();
      expect(controller.isShowing, isFalse);
    });

    test('toggle with config shows with config', () {
      const config = LoadingOverlayConfig(message: 'Toggle');
      controller.toggle(config);
      expect(controller.value?.message, 'Toggle');
    });

    test('update changes config while showing', () {
      const config1 = LoadingOverlayConfig(message: 'First');
      const config2 = LoadingOverlayConfig(message: 'Second');
      controller
        ..show(config1)
        ..update(config2);
      expect(controller.value?.message, 'Second');
    });

    test('update does nothing when not showing', () {
      const config = LoadingOverlayConfig(message: 'Test');
      controller.update(config); // should not throw
      expect(controller.isShowing, isFalse);
    });

    test('notifies listeners on show', () {
      var notified = false;
      controller
        ..addListener(() {
          notified = true;
        })
        ..show();
      expect(notified, isTrue);
    });

    test('notifies listeners on hide', () {
      controller.show();
      var notified = false;
      controller
        ..addListener(() {
          notified = true;
        })
        ..hide();
      expect(notified, isTrue);
    });

    test('does nothing after dispose', () {
      controller
        ..dispose()
        ..show(); // should not throw
      expect(controller.isDisposed, isTrue);
    });

    test('show after dispose does nothing', () {
      controller
        ..dispose()
        ..show();
      expect(controller.isDisposed, isTrue);
    });

    test('hide after dispose does nothing', () {
      controller
        ..dispose()
        ..hide(); // should not throw
      expect(controller.isDisposed, isTrue);
    });

    test('toggle after dispose does nothing', () {
      controller
        ..dispose()
        ..toggle(); // should not throw
      expect(controller.isDisposed, isTrue);
    });
  });

  group('LoadingOverlayConfig', () {
    test('default values', () {
      const config = LoadingOverlayConfig();
      expect(config.message, isNull);
      expect(config.subtitle, isNull);
      expect(config.progress, isNull);
      expect(config.dismissible, isFalse);
      expect(config.animationType, LoadingAnimationType.fade);
      expect(config.loaderType, LoaderType.circular);
      expect(config.builder, isNull);
      expect(config.onDismiss, isNull);
      expect(config.enableBlur, isTrue);
    });

    test('copyWith creates modified copy', () {
      const config = LoadingOverlayConfig(message: 'Original');
      final copy = config.copyWith(message: 'Modified');
      expect(copy.message, 'Modified');
      expect(config.message, 'Original'); // original unchanged
    });

    test('copyWith preserves unmodified values', () {
      const config = LoadingOverlayConfig(
        message: 'Test',
        dismissible: true,
      );
      final copy = config.copyWith(message: 'New');
      expect(copy.dismissible, isTrue); // preserved
    });

    test('equality', () {
      const config1 = LoadingOverlayConfig(message: 'Test');
      const config2 = LoadingOverlayConfig(message: 'Test');
      const config3 = LoadingOverlayConfig(message: 'Other');
      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('hashCode consistency', () {
      const config1 = LoadingOverlayConfig(message: 'Test');
      const config2 = LoadingOverlayConfig(message: 'Test');
      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString contains key info', () {
      const config = LoadingOverlayConfig(
        message: 'Hello',
        loaderType: LoaderType.dots,
      );
      final str = config.toString();
      expect(str, contains('Hello'));
      expect(str, contains('dots'));
    });
  });

  group('LoadingOverlayThemeData', () {
    test('default values are null', () {
      const theme = LoadingOverlayThemeData();
      expect(theme.backgroundColor, isNull);
      expect(theme.loaderColor, isNull);
      expect(theme.barrierColor, isNull);
    });

    test('effective values use defaults', () {
      const theme = LoadingOverlayThemeData();
      expect(
        theme.effectiveBackgroundColor,
        LoadingOverlayDefaults.backgroundColor,
      );
      expect(
        theme.effectiveLoaderColor,
        LoadingOverlayDefaults.loaderColor,
      );
    });

    test('effective values use overrides', () {
      const theme = LoadingOverlayThemeData(
        backgroundColor: Colors.red,
      );
      expect(theme.effectiveBackgroundColor, Colors.red);
    });

    test('copyWith', () {
      const theme = LoadingOverlayThemeData(loaderColor: Colors.blue);
      final copy = theme.copyWith(loaderColor: Colors.red);
      expect(copy.loaderColor, Colors.red);
    });

    test('equality', () {
      const theme1 = LoadingOverlayThemeData(loaderColor: Colors.blue);
      const theme2 = LoadingOverlayThemeData(loaderColor: Colors.blue);
      const theme3 = LoadingOverlayThemeData(loaderColor: Colors.red);
      expect(theme1, equals(theme2));
      expect(theme1, isNot(equals(theme3)));
    });

    test('lerp between themes', () {
      const a = LoadingOverlayThemeData(blurSigma: 0);
      const b = LoadingOverlayThemeData(blurSigma: 10);
      final result = LoadingOverlayThemeData.lerp(a, b, 0.5);
      expect(result?.blurSigma, 5);
    });

    test('lerp with identical returns same', () {
      const a = LoadingOverlayThemeData(blurSigma: 5);
      final result = LoadingOverlayThemeData.lerp(a, a, 0.5);
      expect(identical(result, a), isTrue);
    });
  });

  group('LoadingOverlayTheme widget', () {
    testWidgets('provides theme data to descendants', (tester) async {
      const themeData = LoadingOverlayThemeData(
        loaderColor: Colors.green,
      );

      LoadingOverlayThemeData? foundTheme;

      await tester.pumpWidget(
        LoadingOverlayTheme(
          data: themeData,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                foundTheme = LoadingOverlayTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(foundTheme, equals(themeData));
      expect(foundTheme?.loaderColor, Colors.green);
    });

    testWidgets('of returns null without ancestor', (tester) async {
      LoadingOverlayThemeData? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              foundTheme = LoadingOverlayTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundTheme, isNull);
    });
  });

  group('LoadingAnimationType', () {
    test('has expected values', () {
      expect(LoadingAnimationType.values, hasLength(6));
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.fade),
      );
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.scale),
      );
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.slide),
      );
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.zoom),
      );
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.rotation),
      );
      expect(
        LoadingAnimationType.values,
        contains(LoadingAnimationType.none),
      );
    });
  });

  group('LoaderType', () {
    test('has 11 values', () {
      expect(LoaderType.values, hasLength(11));
    });
  });

  group('LoadingOverlayDefaults', () {
    test('animationDuration is 300ms', () {
      expect(
        LoadingOverlayDefaults.animationDuration,
        const Duration(milliseconds: 300),
      );
    });

    test('dismissible is false', () {
      expect(LoadingOverlayDefaults.dismissible, isFalse);
    });

    test('enableBlur is true', () {
      expect(LoadingOverlayDefaults.enableBlur, isTrue);
    });

    test('loaderSize is 48', () {
      expect(LoadingOverlayDefaults.loaderSize, 48);
    });
  });

  group('Built-in loaders render', () {
    testWidgets('CircularLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: CircularLoader()),
          ),
        ),
      );
      expect(find.byType(CircularLoader), findsOneWidget);
    });

    testWidgets('DotsLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: DotsLoader()),
          ),
        ),
      );
      expect(find.byType(DotsLoader), findsOneWidget);
    });

    testWidgets('PulseLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: PulseLoader()),
          ),
        ),
      );
      expect(find.byType(PulseLoader), findsOneWidget);
    });

    testWidgets('RippleLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: RippleLoader()),
          ),
        ),
      );
      expect(find.byType(RippleLoader), findsOneWidget);
    });

    testWidgets('BarsLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: BarsLoader()),
          ),
        ),
      );
      expect(find.byType(BarsLoader), findsOneWidget);
    });

    testWidgets('CubeLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: CubeLoader()),
          ),
        ),
      );
      expect(find.byType(CubeLoader), findsOneWidget);
    });

    testWidgets('RingLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: RingLoader()),
          ),
        ),
      );
      expect(find.byType(RingLoader), findsOneWidget);
    });

    testWidgets('GradientSpinnerLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: GradientSpinnerLoader()),
          ),
        ),
      );
      expect(find.byType(GradientSpinnerLoader), findsOneWidget);
    });

    testWidgets('MinimalSpinnerLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: MinimalSpinnerLoader()),
          ),
        ),
      );
      expect(find.byType(MinimalSpinnerLoader), findsOneWidget);
    });

    testWidgets('MaterialSpinnerLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: MaterialSpinnerLoader()),
          ),
        ),
      );
      expect(find.byType(MaterialSpinnerLoader), findsOneWidget);
    });

    testWidgets('CupertinoSpinnerLoader renders', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Scaffold(
            body: Center(child: CupertinoSpinnerLoader()),
          ),
        ),
      );
      expect(find.byType(CupertinoSpinnerLoader), findsOneWidget);
    });
  });

  group('LoadingIndicator factory', () {
    for (final type in LoaderType.values) {
      testWidgets('renders ${type.name}', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: Scaffold(
              body: Center(
                child: LoadingIndicator(loaderType: type),
              ),
            ),
          ),
        );
        expect(find.byType(LoadingIndicator), findsOneWidget);
      });
    }
  });

  group('OverlayTransition', () {
    testWidgets('renders child for each animation type', (tester) async {
      for (final type in LoadingAnimationType.values) {
        final animCtrl = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        )..value = 1;

        await tester.pumpWidget(
          buildTestApp(
            child: Scaffold(
              body: OverlayTransition(
                animation: animCtrl,
                animationType: type,
                child: const Text('Test'),
              ),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
        animCtrl.dispose();
      }
    });
  });

  group('LoadingOverlay static API', () {
    // Reset global state between tests.
    tearDown(() async {
      if (LoadingOverlay.isShowing) {
        await LoadingOverlay.hide();
      }
    });

    testWidgets('isShowing is false initially', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(LoadingOverlay.isShowing, isFalse);
    });

    testWidgets('show displays overlay', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx);
      await tester.pump(const Duration(milliseconds: 500));

      expect(LoadingOverlay.isShowing, isTrue);
      expect(
        find.bySemanticsLabel('Loading overlay'),
        findsOneWidget,
      );
    });

    testWidgets('hide removes overlay', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx);
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isTrue);

      await LoadingOverlay.hide();
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isFalse);
    });

    testWidgets('hide without show does nothing', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await LoadingOverlay.hide(); // should not throw
      expect(LoadingOverlay.isShowing, isFalse);
    });

    testWidgets('show with message displays text', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx, message: 'Please wait');
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Please wait'), findsOneWidget);
    });

    testWidgets('show with progress displays indicator', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(
        context: ctx,
        message: 'Loading',
        progress: 0.5,
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('dismissible overlay hides on barrier tap', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx, dismissible: true);
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isTrue);

      // Tap on the barrier (top-left corner, away from center).
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isFalse);
    });

    testWidgets('double show updates overlay', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx, message: 'First');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('First'), findsOneWidget);

      LoadingOverlay.show(context: ctx, message: 'Second');
      await tester.pump(const Duration(milliseconds: 500));
      // Should update, not stack.
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('custom builder renders', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(
        context: ctx,
        builder: (_) => const Text('Custom Loader'),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Custom Loader'), findsOneWidget);
    });
  });

  group('LoadingOverlayScope', () {
    testWidgets('provides scoped controller', (tester) async {
      late LoadingOverlayScopeState scope;

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayScope(
            child: Builder(
              builder: (context) {
                scope = LoadingOverlayScope.of(context);
                return const Scaffold();
              },
            ),
          ),
        ),
      );

      expect(scope.isShowing, isFalse);
      scope.show();
      await tester.pump(const Duration(milliseconds: 500));
      expect(scope.isShowing, isTrue);

      await scope.hide();
      await tester.pump(const Duration(milliseconds: 500));
      expect(scope.isShowing, isFalse);
    });

    testWidgets('applies theme', (tester) async {
      LoadingOverlayThemeData? foundTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayScope(
            theme: const LoadingOverlayThemeData(
              loaderColor: Colors.purple,
            ),
            child: Builder(
              builder: (context) {
                foundTheme = LoadingOverlayTheme.of(context);
                return const Scaffold();
              },
            ),
          ),
        ),
      );

      expect(foundTheme?.loaderColor, Colors.purple);
    });
  });

  group('PlatformUtils', () {
    test('provides platform info', () {
      // These should not throw on any platform.
      expect(PlatformUtils.isWeb, isA<bool>());
      expect(PlatformUtils.isMobile, isA<bool>());
      expect(PlatformUtils.isDesktop, isA<bool>());
      expect(PlatformUtils.isIOS, isA<bool>());
      expect(PlatformUtils.isAndroid, isA<bool>());
      expect(PlatformUtils.isMacOS, isA<bool>());
    });
  });

  group('Context extensions', () {
    tearDown(() async {
      if (LoadingOverlay.isShowing) {
        await LoadingOverlay.hide();
      }
    });

    testWidgets('showLoadingOverlay works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.showLoadingOverlay(message: 'Extension');
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(LoadingOverlay.isShowing, isTrue);
      expect(find.text('Extension'), findsOneWidget);
    });

    testWidgets('hideLoadingOverlay works', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const Scaffold();
            },
          ),
        ),
      );

      LoadingOverlay.show(context: ctx);
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isTrue);

      ctx.hideLoadingOverlay();
      await tester.pump(const Duration(milliseconds: 500));
      expect(LoadingOverlay.isShowing, isFalse);
    });
  });
}
