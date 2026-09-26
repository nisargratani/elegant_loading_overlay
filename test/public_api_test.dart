// Consumer-style tests: only the public library import is used.
import 'dart:async';

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<BuildContext> pumpHost(WidgetTester tester) async {
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
  return ctx;
}

void main() {
  tearDown(LoadingOverlay.controller.hide);

  group('LoadingOverlay + controller', () {
    testWidgets('controller mirrors show/hide and drives updates',
        (tester) async {
      final ctx = await pumpHost(tester);
      final states = <bool>[];
      void listener() => states.add(LoadingOverlay.controller.isShowing);
      LoadingOverlay.controller.addListener(listener);
      addTearDown(() => LoadingOverlay.controller.removeListener(listener));

      LoadingOverlay.show(context: ctx, message: 'Uploading', progress: 0);
      await settle(tester);
      expect(LoadingOverlay.controller.value?.message, 'Uploading');

      final config = LoadingOverlay.controller.value!;
      LoadingOverlay.controller.update(config.copyWith(progress: 0.75));
      await tester.pump();
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.75);

      LoadingOverlay.controller.hide();
      expect(LoadingOverlay.isShowing, isFalse);
      await settle(tester);
      expect(find.text('Uploading'), findsNothing);
      // show, update, hide.
      expect(states, [true, true, false]);
    });

    testWidgets('controller.show() reuses the last Overlay', (tester) async {
      final ctx = await pumpHost(tester);
      LoadingOverlay.show(context: ctx, message: 'One');
      await settle(tester);
      unawaited(LoadingOverlay.hide());
      await settle(tester);

      LoadingOverlay.controller.show(
        const LoadingOverlayConfig(message: 'From controller'),
      );
      await settle(tester);
      expect(find.text('From controller'), findsOneWidget);
      expect(LoadingOverlay.isShowing, isTrue);

      unawaited(LoadingOverlay.hide());
      await settle(tester);
    });

    testWidgets('hide() future completes after the exit animation',
        (tester) async {
      final ctx = await pumpHost(tester);
      LoadingOverlay.show(context: ctx, message: 'Bye');
      await settle(tester);

      var done = false;
      unawaited(LoadingOverlay.hide().then((_) => done = true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(done, isFalse);
      expect(find.text('Bye'), findsOneWidget); // Still animating out.

      await settle(tester);
      expect(done, isTrue);
      expect(find.text('Bye'), findsNothing);
    });

    testWidgets('rapid show/hide cycles leave a single, clean overlay',
        (tester) async {
      final ctx = await pumpHost(tester);
      for (var i = 0; i < 20; i++) {
        LoadingOverlay.show(context: ctx, message: 'Cycle $i');
        await tester.pump(const Duration(milliseconds: 20));
        unawaited(LoadingOverlay.hide());
        await tester.pump(const Duration(milliseconds: 20));
      }
      LoadingOverlay.show(context: ctx, message: 'Final');
      await settle(tester);

      expect(find.text('Final'), findsOneWidget);
      expect(find.textContaining('Cycle'), findsNothing);
      expect(find.byType(CircularLoader), findsOneWidget);

      unawaited(LoadingOverlay.hide());
      await settle(tester);
      expect(find.text('Final'), findsNothing);
    });

    testWidgets('theme values apply and explicit arguments override them',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        LoadingOverlayTheme(
          data: const LoadingOverlayThemeData(
            loaderType: LoaderType.bars,
            loaderColor: Colors.teal,
            semanticsLabel: 'Cargando',
          ),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                ctx = context;
                return const Scaffold();
              },
            ),
          ),
        ),
      );

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      expect(
        tester.widget<BarsLoader>(find.byType(BarsLoader)).color,
        Colors.teal,
      );
      expect(find.bySemanticsLabel('Cargando'), findsOneWidget);

      LoadingOverlay.show(context: ctx, loaderColor: Colors.red);
      await tester.pump();
      expect(
        tester.widget<BarsLoader>(find.byType(BarsLoader)).color,
        Colors.red,
      );

      unawaited(LoadingOverlay.hide());
      await settle(tester);
    });

    testWidgets('useRootOverlay covers content outside a nested Navigator',
        (tester) async {
      late BuildContext nestedCtx;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: const SizedBox(
              height: 80,
              child: Text('Tabs'),
            ),
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) {
                  nestedCtx = context;
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      final screen = tester.getSize(find.byType(MaterialApp));

      LoadingOverlay.show(context: nestedCtx);
      await settle(tester);
      final nestedSize = tester.getSize(find.byType(BlockSemantics).last);
      expect(nestedSize.height, lessThan(screen.height));
      unawaited(LoadingOverlay.hide());
      await settle(tester);

      LoadingOverlay.show(context: nestedCtx, useRootOverlay: true);
      await settle(tester);
      final rootSize = tester.getSize(find.byType(BlockSemantics).last);
      expect(rootSize, screen);

      unawaited(LoadingOverlay.hide());
      await settle(tester);
    });

    testWidgets('content stays above the keyboard', (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      final ctx = await pumpHost(tester);

      LoadingOverlay.show(context: ctx, message: 'Typing');
      await settle(tester);
      final screenHeight = tester.getSize(find.byType(MaterialApp)).height;
      final keyboardTop = screenHeight - 300 / tester.view.devicePixelRatio;
      expect(
        tester.getBottomLeft(find.text('Typing')).dy,
        lessThan(keyboardTop),
      );

      unawaited(LoadingOverlay.hide());
      await settle(tester);
    });

    testWidgets('every loader and animation type shows and hides cleanly',
        (tester) async {
      final ctx = await pumpHost(tester);
      for (final loader in LoaderType.values) {
        for (final animation in LoadingAnimationType.values) {
          LoadingOverlay.show(
            context: ctx,
            loaderType: loader,
            animation: animation,
            message: '${loader.name}/${animation.name}',
            subtitle: 'subtitle',
            progress: 0.5,
          );
          await settle(tester);
          expect(find.text('${loader.name}/${animation.name}'), findsOneWidget);
          unawaited(LoadingOverlay.hide());
          await settle(tester);
          expect(LoadingOverlay.isShowing, isFalse);
        }
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('LoadingOverlayScope', () {
    testWidgets('an external controller drives the scoped overlay',
        (tester) async {
      final controller = LoadingOverlayController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayScope(
            controller: controller,
            child: const Scaffold(),
          ),
        ),
      );

      controller.show(const LoadingOverlayConfig(message: 'Syncing'));
      await settle(tester);
      expect(find.text('Syncing'), findsOneWidget);

      controller.hide();
      await settle(tester);
      expect(find.text('Syncing'), findsNothing);
    });

    testWidgets('scope exposes its controller and independent state',
        (tester) async {
      late LoadingOverlayScopeState scope;
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingOverlayScope(
            child: Builder(
              builder: (context) {
                scope = LoadingOverlayScope.of(context);
                ctx = context;
                return const Scaffold();
              },
            ),
          ),
        ),
      );

      scope.show(const LoadingOverlayConfig(message: 'Scoped'));
      await settle(tester);
      expect(scope.controller.isShowing, isTrue);
      expect(LoadingOverlay.isShowing, isFalse); // Independent of global.

      LoadingOverlay.show(context: ctx, message: 'Global');
      await settle(tester);
      expect(find.text('Scoped'), findsOneWidget);
      expect(find.text('Global'), findsOneWidget);

      unawaited(LoadingOverlay.hide());
      unawaited(scope.hide());
      await settle(tester);
      expect(find.text('Scoped'), findsNothing);
      expect(scope.controller.isShowing, isFalse);
    });

    testWidgets('overlay is removed when the scope is disposed',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: const Scaffold()),
      );

      late LoadingOverlayScopeState scope;
      unawaited(
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => LoadingOverlayScope(
              child: Builder(
                builder: (context) {
                  scope = LoadingOverlayScope.of(context);
                  return const Scaffold();
                },
              ),
            ),
          ),
        ),
      );
      await settle(tester);

      scope.show(const LoadingOverlayConfig(message: 'Page work'));
      await settle(tester);
      expect(find.text('Page work'), findsOneWidget);

      navigatorKey.currentState!.pop();
      await settle(tester);
      expect(find.text('Page work'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('of() throws a helpful error, maybeOf() returns null',
        (tester) async {
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
      expect(LoadingOverlayScope.maybeOf(ctx), isNull);
      expect(
        () => LoadingOverlayScope.of(ctx),
        throwsA(
          isA<FlutterError>().having(
            (e) => e.message,
            'message',
            contains('No LoadingOverlayScope found'),
          ),
        ),
      );
    });
  });

  group('LoadingOverlayConfig.fromTheme', () {
    test('uses defaults for a null theme', () {
      final config = LoadingOverlayConfig.fromTheme(null);
      expect(config, const LoadingOverlayConfig());
    });

    test('copies every theme value', () {
      const theme = LoadingOverlayThemeData(
        backgroundColor: Colors.black,
        loaderColor: Colors.amber,
        barrierColor: Colors.transparent,
        messageTextStyle: TextStyle(fontSize: 20),
        subtitleTextStyle: TextStyle(fontSize: 10),
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.all(4),
        animationDuration: Duration(seconds: 1),
        animationCurve: Curves.linear,
        animationType: LoadingAnimationType.slide,
        blurSigma: 9,
        enableBlur: false,
        spacing: 2,
        loaderSize: 20,
        elevation: 0,
        loaderType: LoaderType.ring,
        dismissible: true,
        semanticsLabel: 'Bitte warten',
      );
      final config = LoadingOverlayConfig.fromTheme(theme);
      expect(config.backgroundColor, Colors.black);
      expect(config.loaderColor, Colors.amber);
      expect(config.barrierColor, Colors.transparent);
      expect(config.messageStyle, theme.messageTextStyle);
      expect(config.subtitleStyle, theme.subtitleTextStyle);
      expect(config.borderRadius, BorderRadius.zero);
      expect(config.padding, const EdgeInsets.all(4));
      expect(config.animationDuration, const Duration(seconds: 1));
      expect(config.animationCurve, Curves.linear);
      expect(config.animationType, LoadingAnimationType.slide);
      expect(config.blurSigma, 9);
      expect(config.enableBlur, isFalse);
      expect(config.spacing, 2);
      expect(config.loaderSize, 20);
      expect(config.elevation, 0);
      expect(config.loaderType, LoaderType.ring);
      expect(config.dismissible, isTrue);
      expect(config.semanticsLabel, 'Bitte warten');
    });

    test('invalid sizes are rejected in debug mode', () {
      expect(
        () => LoadingOverlayConfig(loaderSize: -1),
        throwsAssertionError,
      );
      expect(() => LoadingOverlayConfig(spacing: -1), throwsAssertionError);
      expect(() => LoadingOverlayConfig(elevation: -1), throwsAssertionError);
      expect(() => BarsLoader(barCount: 0), throwsAssertionError);
    });
  });
}
