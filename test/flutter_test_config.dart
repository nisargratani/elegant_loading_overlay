import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Set with `--dart-define=LEGACY_FLUTTER=true` when testing on old
/// Flutter versions (such as the 3.22 minimum), whose MaterialApp page
/// transitions leak CurvedAnimations on their own.
const bool _legacyFlutter = bool.fromEnvironment('LEGACY_FLUTTER');

/// Runs every widget test with leak tracking, so undisposed or retained
/// overlay entries, animations and controllers fail the test.
///
/// The app-lifetime `LoadingOverlay.controller` needs no entry here: the
/// package reports it to the leak tracker as released (ELO-08), as an
/// app's own test config would expect.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withTrackedAll().withIgnored(
    notDisposed: {
      if (_legacyFlutter) 'CurvedAnimation': null,
    },
  );
  await testMain();
}
