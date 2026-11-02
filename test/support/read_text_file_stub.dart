/// The contents of the file at [path]. There is no file system on this
/// platform; skip tests that need it.
String readTextFile(String path) =>
    throw UnsupportedError('Cannot read $path on this platform.');
