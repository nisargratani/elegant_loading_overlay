import 'dart:async';

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a minimal app and returns a context below its Navigator.
Future<BuildContext> pumpHost(WidgetTester tester, {Widget? body}) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          ctx = context;
          return Scaffold(body: body);
        },
      ),
    ),
  );
  return ctx;
}

/// Advances past any overlay enter/exit animation.
///
/// `pumpAndSettle` cannot be used while an overlay is visible because the
/// built-in loaders animate forever.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

/// Hides the global overlay and pumps until its exit animation is done.
///
/// Awaiting `LoadingOverlay.hide()` without pumping would deadlock, since
/// the exit animation needs frames.
Future<void> hideAndPump(WidgetTester tester) async {
  final f = LoadingOverlay.hide();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await f;
}

/// Pumps an app with a second route pushed on [navKey] and returns that
/// route's context.
Future<BuildContext> pumpDetails(
  WidgetTester tester,
  GlobalKey<NavigatorState> navKey,
) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(navigatorKey: navKey, home: const Text('Home')),
  );
  unawaited(
    navKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) {
          ctx = context;
          return const Text('Details');
        },
      ),
    ),
  );
  await settle(tester);
  return ctx;
}

/// Simulates the Android system back button.
Future<void> pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Every label in the live semantics tree.
List<String> semanticsLabels(WidgetTester tester) {
  final labels = <String>[];
  bool visit(SemanticsNode node) {
    if (node.label.isNotEmpty) labels.add(node.label);
    node.visitChildren(visit);
    return true;
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return labels;
}

/// An [AnimationController] that tracks how many status listeners are
/// currently registered on it.
class _CountingController extends AnimationController {
  _CountingController({required super.vsync});

  int statusListeners = 0;

  @override
  void addStatusListener(AnimationStatusListener listener) {
    statusListeners++;
    super.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    statusListeners--;
    super.removeStatusListener(listener);
  }
}

void main() {
  tearDown(LoadingOverlay.controller.hide);

  testWidgets('overshooting animation curves do not assert', (tester) async {
    final ctx = await pumpHost(tester);

    LoadingOverlay.show(context: ctx, animationCurve: Curves.easeOutBack);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.takeException(), isNull);
    expect(LoadingOverlay.isShowing, isTrue);

    unawaited(LoadingOverlay.hide());
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('show() during the exit animation keeps the overlay visible',
      (tester) async {
    final ctx = await pumpHost(tester);

    LoadingOverlay.show(context: ctx, message: 'First');
    await settle(tester);

    var hideCompleted = false;
    unawaited(LoadingOverlay.hide().then((_) => hideCompleted = true));
    await tester.pump(const Duration(milliseconds: 100));

    LoadingOverlay.show(context: ctx, message: 'Second');
    await settle(tester);

    expect(LoadingOverlay.isShowing, isTrue);
    expect(find.text('Second'), findsOneWidget);
    // The interrupted hide() must still complete instead of hanging.
    expect(hideCompleted, isTrue);

    unawaited(LoadingOverlay.hide());
    await settle(tester);
    expect(LoadingOverlay.isShowing, isFalse);
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('onDismiss fires once and controller state is synced',
      (tester) async {
    final ctx = await pumpHost(tester);
    var dismissCount = 0;

    LoadingOverlay.show(
      context: ctx,
      dismissible: true,
      onDismiss: () => dismissCount++,
    );
    await settle(tester);
    expect(LoadingOverlay.controller.isShowing, isTrue);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 50));
    await settle(tester);

    expect(dismissCount, 1);
    expect(LoadingOverlay.isShowing, isFalse);
    expect(LoadingOverlay.controller.isShowing, isFalse);
  });

  testWidgets('recovers when the host Overlay is disposed while showing',
      (tester) async {
    final ctx = await pumpHost(tester);
    LoadingOverlay.show(context: ctx, message: 'Orphan');
    await settle(tester);

    // Replace the whole app: the Overlay hosting the entry is disposed.
    await tester.pumpWidget(const SizedBox());
    expect(LoadingOverlay.isShowing, isFalse);

    final ctx2 = await pumpHost(tester);
    LoadingOverlay.show(context: ctx2, message: 'Fresh');
    await settle(tester);
    expect(find.text('Fresh'), findsOneWidget);

    unawaited(LoadingOverlay.hide());
    await settle(tester);
  });

  testWidgets('show() can be called during build (e.g. from initState)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: _ShowsInInitState(message: 'From initState')),
    );
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('From initState'), findsOneWidget);

    unawaited(LoadingOverlay.hide());
    await settle(tester);
  });

  testWidgets('LoadingOverlayScope.show() applies the scope theme',
      (tester) async {
    late LoadingOverlayScopeState scope;
    await tester.pumpWidget(
      MaterialApp(
        home: LoadingOverlayScope(
          theme: const LoadingOverlayThemeData(
            loaderType: LoaderType.dots,
            loaderColor: Colors.purple,
          ),
          child: Builder(
            builder: (context) {
              scope = LoadingOverlayScope.of(context);
              return const Scaffold();
            },
          ),
        ),
      ),
    );

    scope.show();
    await settle(tester);
    final dots = tester.widget<DotsLoader>(find.byType(DotsLoader));
    expect(dots.color, Colors.purple);

    unawaited(scope.hide());
    await settle(tester);
  });

  testWidgets('OverlayTransition does not leak status listeners on rebuild',
      (tester) async {
    final controller = _CountingController(vsync: tester);
    addTearDown(controller.dispose);

    for (var i = 0; i < 10; i++) {
      await tester.pumpWidget(
        MaterialApp(
          home: OverlayTransition(
            animation: controller,
            animationType: LoadingAnimationType.rotation,
            child: Text('$i'),
          ),
        ),
      );
    }
    final afterTen = controller.statusListeners;

    for (var i = 0; i < 10; i++) {
      await tester.pumpWidget(
        MaterialApp(
          home: OverlayTransition(
            animation: controller,
            animationType: LoadingAnimationType.rotation,
            child: Text('again $i'),
          ),
        ),
      );
    }
    expect(controller.statusListeners, afterTen);
  });

  testWidgets('screen readers cannot reach content behind the overlay',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final ctx = await pumpHost(tester, body: const Text('Behind'));
    expect(semanticsLabels(tester), contains('Behind'));

    LoadingOverlay.show(context: ctx);
    await settle(tester);
    expect(semanticsLabels(tester), isNot(contains('Behind')));
    expect(semanticsLabels(tester), contains('Loading overlay'));

    unawaited(LoadingOverlay.hide());
    await settle(tester);
    expect(semanticsLabels(tester), contains('Behind'));
    semantics.dispose();
  });

  group('system back (issue 1)', () {
    testWidgets('is swallowed while a non-dismissible overlay shows',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final ctx = await pumpDetails(tester, navKey);

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      await pressBack(tester);

      expect(navKey.currentState!.canPop(), isTrue);
      expect(find.text('Details'), findsOneWidget);
      expect(LoadingOverlay.isShowing, isTrue);
      await hideAndPump(tester);
    });

    testWidgets('dismisses a dismissible overlay instead of popping',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final ctx = await pumpDetails(tester, navKey);
      var dismissed = 0;

      LoadingOverlay.show(
        context: ctx,
        dismissible: true,
        onDismiss: () => dismissed++,
      );
      await settle(tester);
      await pressBack(tester);

      expect(dismissed, 1);
      expect(LoadingOverlay.isShowing, isFalse);
      expect(navKey.currentState!.canPop(), isTrue);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('pops normally after hide()', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final ctx = await pumpDetails(tester, navKey);

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      await hideAndPump(tester);
      await pressBack(tester);

      expect(navKey.currentState!.canPop(), isFalse);
      expect(find.text('Details'), findsNothing);
    });

    testWidgets('programmatic Navigator.pop() still pops', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final ctx = await pumpDetails(tester, navKey);

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      navKey.currentState!.pop();
      await settle(tester);

      expect(find.text('Details'), findsNothing);
      await hideAndPump(tester);
    });

    testWidgets('is swallowed while a LoadingOverlayScope overlay shows',
        (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      late LoadingOverlayScopeState scope;
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navKey, home: const Text('Home')),
      );
      unawaited(
        navKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => LoadingOverlayScope(
              child: Builder(
                builder: (context) {
                  scope = LoadingOverlayScope.of(context);
                  return const Text('Details');
                },
              ),
            ),
          ),
        ),
      );
      await settle(tester);

      scope.show();
      await settle(tester);
      await pressBack(tester);
      expect(find.text('Details'), findsOneWidget);

      final f = scope.hide();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await f;
      await pressBack(tester);
      expect(find.text('Details'), findsNothing);
    });
  });

  group('keyboard focus (issue 2)', () {
    testWidgets('cannot activate widgets behind the overlay', (tester) async {
      var pressed = 0;
      final ctx = await pumpHost(
        tester,
        body: ElevatedButton(
          onPressed: () => pressed++,
          child: const Text('Behind'),
        ),
      );

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(pressed, 0);
      await hideAndPump(tester);
    });

    testWidgets('focus returns to the previously focused widget',
        (tester) async {
      final field = FocusNode();
      addTearDown(field.dispose);
      final ctx = await pumpHost(
        tester,
        body: TextField(focusNode: field),
      );
      field.requestFocus();
      await tester.pump();
      expect(field.hasFocus, isTrue);

      LoadingOverlay.show(context: ctx);
      await settle(tester);
      expect(field.hasFocus, isFalse);

      await hideAndPump(tester);
      await tester.pump();
      expect(field.hasFocus, isTrue);
    });

    testWidgets('focusable widgets in a custom builder still work',
        (tester) async {
      var cancelled = 0;
      final ctx = await pumpHost(tester);

      LoadingOverlay.show(
        context: ctx,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(key: Key('reason')),
            TextButton(
              onPressed: () => cancelled++,
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      await settle(tester);

      await tester.enterText(find.byKey(const Key('reason')), 'slow');
      expect(find.text('slow'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      expect(cancelled, 1);

      // Keyboard traversal stays inside the overlay and can reach Cancel.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(cancelled, 2);
      await hideAndPump(tester);
    });
  });

  group('content fits the screen (issue 3)', () {
    Future<void> showOn(
      WidgetTester tester, {
      required Size size,
      String message = 'Uploading your file',
      double textScale = 1,
      double keyboard = 0,
    }) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1
        ..viewInsets = FakeViewPadding(bottom: keyboard);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final ctx = await pumpHost(tester);
      LoadingOverlay.show(
        context: ctx,
        message: message,
        subtitle: 'This may take a moment',
        progress: 0.5,
      );
      await settle(tester);
    }

    testWidgets('very long message on a small screen', (tester) async {
      await showOn(
        tester,
        size: const Size(320, 480),
        message: List.filled(150, 'Uploading your file').join(' '),
      );
      expect(tester.takeException(), isNull);
      await hideAndPump(tester);
    });

    testWidgets('large text scale on a small screen', (tester) async {
      await showOn(tester, size: const Size(320, 480), textScale: 3);
      expect(tester.takeException(), isNull);
      await hideAndPump(tester);
    });

    testWidgets('keyboard on a short landscape screen', (tester) async {
      await showOn(tester, size: const Size(640, 360), keyboard: 200);
      expect(tester.takeException(), isNull);
      await hideAndPump(tester);
    });

    testWidgets('normal content keeps its compact centered card',
        (tester) async {
      final ctx = await pumpHost(tester);
      LoadingOverlay.show(context: ctx, message: 'Short');
      await settle(tester);

      final card = find
          .ancestor(of: find.text('Short'), matching: find.byType(Material))
          .first;
      final screen = tester.getSize(find.byType(MaterialApp));
      expect(tester.getCenter(card), screen.center(Offset.zero));
      expect(tester.getSize(card).height, lessThan(screen.height / 2));
      await hideAndPump(tester);
    });
  });

  testWidgets(
      'every loader handles runtime size/color changes incl. 0 '
      '(issue 4)', (tester) async {
    for (final type in LoaderType.values) {
      for (final (size, color) in [
        (24.0, Colors.red),
        (64.0, Colors.green),
        (0.0, Colors.blue),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: LoadingIndicator(
                loaderType: type,
                size: size,
                color: color,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$type at $size');
      }
    }
  });

  testWidgets(
      'copyWith clear flags remove fields via controller.update '
      '(issue 5)', (tester) async {
    final ctx = await pumpHost(tester);
    LoadingOverlay.show(
      context: ctx,
      message: 'Working',
      subtitle: 'Details',
      progress: 0.4,
    );
    await settle(tester);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    final config = LoadingOverlay.controller.value!;
    LoadingOverlay.controller.update(
      config.copyWith(clearProgress: true, clearSubtitle: true),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Details'), findsNothing);
    expect(find.text('Working'), findsOneWidget);

    final cleared = LoadingOverlay.controller.value!.copyWith(
      clearMessage: true,
      clearBuilder: true,
      clearOnDismiss: true,
    );
    expect(cleared.message, isNull);
    expect(cleared.builder, isNull);
    expect(cleared.onDismiss, isNull);
    // Without flags, null arguments still keep the current values.
    expect(config.copyWith().progress, 0.4);
    await hideAndPump(tester);
  });

  testWidgets('show() from onDismiss keeps the new overlay (issue 6)',
      (tester) async {
    final ctx = await pumpHost(tester);
    LoadingOverlay.show(
      context: ctx,
      dismissible: true,
      onDismiss: () => LoadingOverlay.show(context: ctx, message: 'Retry'),
    );
    await settle(tester);

    await tester.tapAt(const Offset(5, 5));
    await settle(tester);

    expect(find.text('Retry'), findsOneWidget);
    expect(LoadingOverlay.isShowing, isTrue);
    await hideAndPump(tester);
  });

  testWidgets('useRootOverlay moves an already visible overlay (issue 7)',
      (tester) async {
    var bottomTaps = 0;
    late BuildContext innerCtx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: TextButton(
            onPressed: () => bottomTaps++,
            child: const Text('Bottom'),
          ),
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) {
                innerCtx = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );

    LoadingOverlay.show(context: innerCtx, message: 'Moving');
    await settle(tester);
    LoadingOverlay.show(
      context: innerCtx,
      message: 'Moving',
      useRootOverlay: true,
    );
    await tester.pump();

    // Moved without replaying the entry animation.
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('Moving'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    await settle(tester);

    await tester.tap(find.text('Bottom'), warnIfMissed: false);
    await tester.pump();
    expect(bottomTaps, 0);
    expect(find.text('Moving'), findsOneWidget);
    await hideAndPump(tester);
  });

  group('controller.show() without an Overlay (issue 8)', () {
    testWidgets('global controller is reset to hidden', (tester) async {
      await tester.pumpWidget(const SizedBox());

      LoadingOverlay.controller.show();
      expect(tester.takeException(), isFlutterError);
      await tester.pump();

      expect(LoadingOverlay.controller.isShowing, isFalse);
      expect(LoadingOverlay.isShowing, isFalse);
    });

    testWidgets('scope with an external controller is reset to hidden',
        (tester) async {
      final controller = LoadingOverlayController();
      addTearDown(controller.dispose);
      // A scope above MaterialApp has no Overlay above it.
      await tester.pumpWidget(
        LoadingOverlayScope(
          controller: controller,
          child: const MaterialApp(home: SizedBox()),
        ),
      );

      controller.show();
      expect(tester.takeException(), isFlutterError);
      await tester.pump();
      expect(controller.isShowing, isFalse);
    });
  });

  group('loader layout does not overflow', () {
    for (final count in [1, 2, 3, 5, 8]) {
      testWidgets('BarsLoader(barCount: $count)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Center(child: BarsLoader(barCount: count))),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('DotsLoader(dotCount: $count)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Center(child: DotsLoader(dotCount: count))),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });
    }
  });
}

class _ShowsInInitState extends StatefulWidget {
  const _ShowsInInitState({required this.message});

  final String message;

  @override
  State<_ShowsInInitState> createState() => _ShowsInInitStateState();
}

class _ShowsInInitStateState extends State<_ShowsInInitState> {
  @override
  void initState() {
    super.initState();
    LoadingOverlay.show(context: context, message: widget.message);
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
