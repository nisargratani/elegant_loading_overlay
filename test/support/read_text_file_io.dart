import 'dart:io';

/// The contents of the file at [path], relative to the package root.
String readTextFile(String path) => File(path).readAsStringSync();
