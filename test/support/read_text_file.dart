/// Reads a text file in tests that also run on the web, where `dart:io`
/// is not available.
library;

export 'read_text_file_stub.dart' if (dart.library.io) 'read_text_file_io.dart';
