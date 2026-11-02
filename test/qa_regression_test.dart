// Regression tests for the issues found by the external QA pass on 0.0.4
// (ELO-01 to ELO-10). Each test fails on 0.0.4 and passes with the fix.
import 'dart:async';

import 'package:elegant_loading_overlay/elegant_loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/read_text_file.dart';

/// Pumps a minimal app and returns a context below its Navigator.
Future<BuildContext> pumpHost(
  WidgetTester tester, {
  Widget? body,
  ThemeData? theme,
}) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
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
/// Pumps until the hide completes (at most 2 s), so that a long
/// animationDuration cannot deadlock the test.
Future<void> hideAndPump(WidgetTester tester) async {
  var done = false;
  final f = LoadingOverlay.hide().whenComplete(() => done = true);
  await tester.pump();
  for (var i = 0; i < 20 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await f;
}

/// Pumps [count] frames of 16 ms, as a device would during an animation.
Future<void> pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Sends the platform's back button message (Android back) through the
/// same path as a real device, and pumps.
Future<void> sendSystemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
    (_) {},
  );
  await settle(tester);
}

/// Records the calls made on the platform channel; `SystemNavigator.pop`
/// closes the app on Android.
List<MethodCall> recordPlatformCalls(WidgetTester tester) {
  final calls = <MethodCall>[];
  final messenger = tester.binding.defaultBinaryMessenger
    ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return calls;
}

/// Every node in the live semantics tree.
List<SemanticsNode> semanticsNodes(WidgetTester tester) {
  final nodes = <SemanticsNode>[];
  bool visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren(visit);
    return true;
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return nodes;
}

/// Every label in the live semantics tree.
List<String> semanticsLabels(WidgetTester tester) => [
      for (final node in semanticsNodes(tester))
        if (node.label.isNotEmpty) node.label,
    ];

/// The style [text] is painted with.
TextStyle paintedStyle(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

/// The background color of the overlay card that shows [text].
Color cardColorBehind(WidgetTester tester, String text) => tester
    .widget<Material>(
      find.ancestor(of: find.text(text), matching: find.byType(Material)).first,
    )
    .color!;

/// The WCAG contrast ratio of two opaque colors.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Pushes 'Detail' on the nested Navigator [nested], shows the global
/// overlay from it in the root Overlay, and checks that system back does
/// not pop the page behind the overlay, but does again after hide().
Future<void> expectBackBlockedOnNestedPage(
  WidgetTester tester,
  GlobalKey<NavigatorState> nested,
) async {
  late BuildContext detailCtx;
  unawaited(
    nested.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) {
          detailCtx = context;
          return const Text('Detail');
        },
      ),
    ),
  );
  await settle(tester);

  LoadingOverlay.show(context: detailCtx, useRootOverlay: true);
  await settle(tester);
  await sendSystemBack(tester);

  expect(
    find.text('Detail'),
    findsOneWidget,
    reason: 'back popped the page behind the overlay',
  );
  expect(LoadingOverlay.isShowing, isTrue);

  await hideAndPump(tester);
  await sendSystemBack(tester);
  expect(find.text('Detail'), findsNothing, reason: 'back works after hide');
}

/// A [RouterDelegate] that, like go_router's `StatefulShellRoute`,
/// forwards system back to a Navigator nested in the root one.
class _ShellRouterDelegate extends RouterDelegate<Object> with ChangeNotifier {
  _ShellRouterDelegate(this.nested);

  final GlobalKey<NavigatorState> nested;

  @override
  Widget build(BuildContext context) => Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Navigator(
              key: nested,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const Text('Tab root'),
              ),
            ),
            bottomNavigationBar: const Text('Bottom bar'),
          ),
        ),
      );

  @override
  Future<bool> popRoute() async {
    final navigator = nested.currentState;
    return navigator != null && await navigator.maybePop();
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

/// LoadingOverlayController memory allocation events, which Flutter's leak
/// tracker consumes. Recorded from before anything touches LoadingOverlay.
final Set<Object> _createdControllers = {};
final Set<Object> _disposedControllers = {};

void _recordControllerEvent(ObjectEvent event) {
  if (event.object is! LoadingOverlayController) return;
  if (event is ObjectCreated) _createdControllers.add(event.object);
  if (event is ObjectDisposed) _disposedControllers.add(event.object);
}

void main() {
  setUpAll(() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.addListener(_recordControllerEvent);
    }
  });
  tearDownAll(() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.removeListener(_recordControllerEvent);
    }
  });
  // Not a tear-off: that would create LoadingOverlay's controller before
  // setUpAll starts recording (ELO-08).
  tearDown(() => LoadingOverlay.controller.hide());

  testWidgets(
      'ELO-01: show()/hide() inside PopScope.onPopInvokedWithResult throws '
      'ConcurrentModificationError, and on Android the back press then '
      'closes the app', (tester) async {
    final platformCalls = recordPlatformCalls(tester);
    Iterable<MethodCall> appExits() =>
        platformCalls.where((call) => call.method == 'SystemNavigator.pop');
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navKey, home: const Text('Home')),
    );

    // "Save before leaving": the page's pop callback shows the overlay.
    // (onPopInvoked, because onPopInvokedWithResult does not exist on
    // Flutter 3.22; both run in the same loop over the route's entries.)
    unawaited(
      navKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) => PopScope(
            canPop: false,
            // ignore: deprecated_member_use
            onPopInvoked: (didPop) {
              if (didPop) return;
              LoadingOverlay.show(context: context, message: 'Saving draft');
            },
            child: const Text('Editor'),
          ),
        ),
      ),
    );
    await settle(tester);
    await sendSystemBack(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Saving draft'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(appExits(), isEmpty, reason: 'the back press closed the app');

    await hideAndPump(tester);
    navKey.currentState!.pop();
    await settle(tester);

    // "Back cancels the upload": the pop callback hides the overlay.
    late BuildContext uploaderCtx;
    unawaited(
      navKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) {
            uploaderCtx = context;
            return PopScope(
              canPop: false,
              // ignore: deprecated_member_use
              onPopInvoked: (didPop) {
                if (!didPop) unawaited(LoadingOverlay.hide());
              },
              child: const Text('Uploader'),
            );
          },
        ),
      ),
    );
    await settle(tester);
    LoadingOverlay.show(context: uploaderCtx, message: 'Uploading');
    await settle(tester);
    await sendSystemBack(tester);

    expect(tester.takeException(), isNull);
    expect(appExits(), isEmpty, reason: 'the back press closed the app');
    expect(LoadingOverlay.isShowing, isFalse);
    expect(find.text('Uploading'), findsNothing);
    expect(find.text('Uploader'), findsOneWidget);
  });

  group(
      'ELO-02: useRootOverlay: true from inside a nested Navigator '
      "doesn't block back on the nested page", () {
    testWidgets('NavigatorPopHandler', (tester) async {
      final nested = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigatorPopHandler(
              // onPopWithResult does not exist on Flutter 3.22.
              // ignore: deprecated_member_use
              onPop: () => unawaited(nested.currentState!.maybePop()),
              child: Navigator(
                key: nested,
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => const Text('Tab root'),
                ),
              ),
            ),
            bottomNavigationBar: const Text('Bottom bar'),
          ),
        ),
      );

      await expectBackBlockedOnNestedPage(tester, nested);
    });

    testWidgets('RouterDelegate forwarding back (like go_router shells)',
        (tester) async {
      final nested = GlobalKey<NavigatorState>();
      final delegate = _ShellRouterDelegate(nested);
      addTearDown(delegate.dispose);
      await tester.pumpWidget(MaterialApp.router(routerDelegate: delegate));

      await expectBackBlockedOnNestedPage(tester, nested);
    });
  });

  testWidgets(
      'ELO-03: hide() moves focus (and the keyboard) back to a text field on '
      'a route that is no longer current', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    final phone = FocusNode(debugLabel: 'phone');
    final otp = FocusNode(debugLabel: 'otp');
    addTearDown(phone.dispose);
    addTearDown(otp.dispose);
    late BuildContext loginCtx;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        home: Builder(
          builder: (context) {
            loginCtx = context;
            return Scaffold(
              body: TextField(focusNode: phone, autofocus: true),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(phone.hasFocus, isTrue);

    // "Send OTP": overlay, request, push the OTP page, then hide.
    LoadingOverlay.show(context: loginCtx, message: 'Sending OTP');
    await settle(tester);
    unawaited(
      navKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: TextField(focusNode: otp, autofocus: true),
          ),
        ),
      ),
    );
    await settle(tester);
    await hideAndPump(tester);
    await tester.pumpAndSettle();

    expect(phone.hasFocus, isFalse, reason: 'focus went to the covered page');
    expect(otp.hasFocus, isTrue, reason: 'the OTP page lost its focus');
  });

  testWidgets(
      'ELO-04: An overshooting animationCurve asserts for scale, slide, '
      'zoom and rotation, including the README "Animation" example',
      (tester) async {
    final ctx = await pumpHost(tester);

    // The README "Animation" example, verbatim.
    LoadingOverlay.show(
      context: ctx,
      animation: LoadingAnimationType.scale,
      animationDuration: const Duration(milliseconds: 400),
      animationCurve: Curves.easeOutBack,
    );
    await pumpFrames(tester, 30);
    expect(tester.takeException(), isNull);
    await hideAndPump(tester);

    final failures = <String>[];
    for (final curve in <Curve>[Curves.easeOutBack, Curves.elasticOut]) {
      for (final type in LoadingAnimationType.values) {
        LoadingOverlay.show(
          context: ctx,
          animation: type,
          animationDuration: const Duration(milliseconds: 400),
          animationCurve: curve,
        );
        await pumpFrames(tester, 30);
        final onShow = tester.takeException();
        final hidden = LoadingOverlay.hide();
        await pumpFrames(tester, 40);
        await hidden;
        final onHide = tester.takeException();
        for (final error in [onShow, onHide]) {
          if (error != null) {
            failures.add('${type.name} + $curve: ${'$error'.split('\n')[0]}');
          }
        }
      }
    }
    expect(failures, isEmpty);
  });

  testWidgets(
      'ELO-05: In dark apps, text on the default white card is unreadable',
      (tester) async {
    final ctx = await pumpHost(tester, theme: ThemeData.dark());

    // Partial styles: only a bigger font, only italics.
    LoadingOverlay.show(
      context: ctx,
      message: 'Saving',
      subtitle: 'Almost there',
      messageStyle: const TextStyle(fontSize: 20),
      subtitleStyle: const TextStyle(fontStyle: FontStyle.italic),
    );
    await settle(tester);
    final card = cardColorBehind(tester, 'Saving');
    expect(card, LoadingOverlayDefaults.backgroundColor);
    final message = paintedStyle(tester, 'Saving');
    final subtitle = paintedStyle(tester, 'Almost there');
    expect(contrast(message.color!, card), greaterThanOrEqualTo(4.5));
    expect(contrast(subtitle.color!, card), greaterThanOrEqualTo(3));
    // Merged into the defaults: 16 px, medium, dark grey / 13 px, grey.
    expect(message.fontSize, 20);
    expect(message.fontWeight, FontWeight.w500);
    expect(message.color, LoadingOverlayDefaults.messageTextStyle.color);
    expect(subtitle.fontSize, 13);
    expect(subtitle.fontStyle, FontStyle.italic);
    expect(subtitle.color, LoadingOverlayDefaults.subtitleTextStyle.color);
    await hideAndPump(tester);

    // The README "Custom content" example, verbatim.
    LoadingOverlay.show(
      context: ctx,
      builder: (_) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
          SizedBox(height: 16),
          Text('Uploading...'),
        ],
      ),
    );
    await settle(tester);
    expect(
      contrast(
        paintedStyle(tester, 'Uploading...').color!,
        cardColorBehind(tester, 'Uploading...'),
      ),
      greaterThanOrEqualTo(4.5),
    );
    await hideAndPump(tester);

    // A dark card gets light text without any text style.
    LoadingOverlay.show(
      context: ctx,
      message: 'Dark card',
      subtitle: 'Light text',
      backgroundColor: Colors.grey.shade900,
    );
    await settle(tester);
    final darkCard = cardColorBehind(tester, 'Dark card');
    expect(
      contrast(paintedStyle(tester, 'Dark card').color!, darkCard),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(paintedStyle(tester, 'Light text').color!, darkCard),
      greaterThanOrEqualTo(3),
    );
    await hideAndPump(tester);
  });

  test(
    'ELO-06: Undocumented: routes pushed while the overlay is visible '
    '(pages, dialogs, bottom sheets) open underneath it',
    () {
      final readme = readTextFile('README.md').replaceAll(RegExp(r'\s+'), ' ');
      expect(readme, contains('open underneath the overlay'));
    },
    skip: kIsWeb ? 'The README cannot be read on the web' : null,
  );

  testWidgets(
      "ELO-07: A dismissible overlay can't be dismissed with Escape, and its "
      'barrier is an unlabeled tap target for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    final ctx = await pumpHost(tester);
    var dismissed = 0;

    bool hasDismissAction(SemanticsNode node) =>
        node.getSemanticsData().hasAction(SemanticsAction.dismiss);

    // Every tap/dismiss target has a label, and the dismiss action works
    // like a barrier tap.
    LoadingOverlay.show(
      context: ctx,
      dismissible: true,
      onDismiss: () => dismissed++,
    );
    await settle(tester);
    final actionable = semanticsNodes(tester).where((node) {
      final data = node.getSemanticsData();
      return data.hasAction(SemanticsAction.tap) || hasDismissAction(node);
    }).toList();
    expect(actionable, isNotEmpty);
    expect(actionable.where((node) => node.label.trim().isEmpty), isEmpty);
    final dismissTarget = semanticsNodes(tester).singleWhere(hasDismissAction);
    expect(dismissTarget.label, LoadingOverlayDefaults.semanticsLabel);
    tester.binding.renderViews.first.owner!.semanticsOwner!
        .performAction(dismissTarget.id, SemanticsAction.dismiss);
    await tester.pump();
    expect(dismissed, 1);
    expect(LoadingOverlay.isShowing, isFalse);
    await settle(tester);

    // Escape dismisses a dismissible overlay.
    LoadingOverlay.show(
      context: ctx,
      dismissible: true,
      onDismiss: () => dismissed++,
    );
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissed, 2);
    expect(LoadingOverlay.isShowing, isFalse);
    await settle(tester);

    // A non-dismissible overlay ignores Escape and offers no dismiss action.
    LoadingOverlay.show(context: ctx, onDismiss: () => dismissed++);
    await settle(tester);
    expect(semanticsNodes(tester).where(hasDismissAction), isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissed, 2);
    expect(LoadingOverlay.isShowing, isTrue);
    await hideAndPump(tester);
    semantics.dispose();
  });

  testWidgets(
    'ELO-08: The global LoadingOverlay.controller makes '
    "Flutter's leak tracker fail consumers' tests "
    '("notDisposed: LoadingOverlayController")',
    (tester) async {
      final ctx = await pumpHost(tester);
      LoadingOverlay.show(context: ctx, message: 'Leak check');
      await settle(tester);
      await hideAndPump(tester);

      expect(_createdControllers, isNotEmpty, reason: 'nothing was recorded');
      expect(
        _createdControllers.difference(_disposedControllers),
        isEmpty,
        reason: 'reported as created and never disposed, which fails '
            'LeakTesting.enable() in apps using the package',
      );
    },
    skip: !kFlutterMemoryAllocationsEnabled,
  );

  testWidgets(
      'ELO-09: DotsLoader/BarsLoader overflow in tighter constraints. Six '
      'loaders throw for a negative size', (tester) async {
    final failures = <String>[];
    void collect(String what) {
      final error = tester.takeException();
      if (error != null) failures.add('$what: ${'$error'.split('\n')[0]}');
    }

    for (final loader in const <Widget>[DotsLoader(), BarsLoader()]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: SizedBox.square(dimension: 24, child: loader)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      collect('${loader.runtimeType} in 24x24');
    }

    for (final type in LoaderType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: LoadingIndicator(loaderType: type, size: -8)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      collect('LoadingIndicator ${type.name} at size -8');
    }

    for (final loader in const <Widget>[
      DotsLoader(size: -8),
      PulseLoader(size: -8),
      RippleLoader(size: -8),
      BarsLoader(size: -8),
      CubeLoader(size: -8),
      MaterialSpinnerLoader(size: -8),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: loader)));
      await tester.pump(const Duration(milliseconds: 100));
      collect('${loader.runtimeType} at size -8');
    }

    // Inside the overlay: a loader wider than the card on a 360 px phone
    // (the card's content is 360 - 2 * 40 - 2 * 32 = 216 px wide).
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ctx = await pumpHost(tester);
    for (final type in [LoaderType.dots, LoaderType.bars]) {
      LoadingOverlay.show(context: ctx, loaderType: type, loaderSize: 300);
      await settle(tester);
      collect('overlay ${type.name} with loaderSize 300');
      await hideAndPump(tester);
    }

    expect(failures, isEmpty);
  });

  testWidgets(
      "ELO-10: Inside a LoadingOverlayScope overlay's builder, "
      "LoadingOverlayScope.of(context) throws, and the scope's theme isn't "
      'visible', (tester) async {
    const theme = LoadingOverlayThemeData(loaderColor: Colors.purple);
    final scopeKey = GlobalKey<LoadingOverlayScopeState>();
    await tester.pumpWidget(
      MaterialApp(
        home: LoadingOverlayScope(
          key: scopeKey,
          theme: theme,
          child: const Scaffold(),
        ),
      ),
    );

    LoadingOverlayScopeState? fromBuilder;
    LoadingOverlayThemeData? themeInBuilder;
    scopeKey.currentState!.show(
      LoadingOverlayConfig(
        builder: (context) {
          themeInBuilder = LoadingOverlayTheme.of(context);
          return TextButton(
            onPressed: () {
              fromBuilder = LoadingOverlayScope.of(context);
              unawaited(fromBuilder!.hide());
            },
            child: const Text('Cancel'),
          );
        },
      ),
    );
    await settle(tester);
    expect(themeInBuilder, same(theme));

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(fromBuilder, same(scopeKey.currentState));
    expect(scopeKey.currentState!.isShowing, isFalse);
    expect(find.text('Cancel'), findsNothing);
  });
}
