import 'dart:async';

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
