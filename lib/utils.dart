/// Helper functions used throughout Cookiecutter.
library cookiecutter.utils;

import 'dart:io';
import 'common.dart';




/// Ensures that a directory exists.
/// [path] : A Directory path.
makeSurePathExists(String path) {
  logging.info('Making sure that path exists: $path');
  try {
    new Directory(path).createSync(recursive: true);
  } on FileSystemException {
    return false;
  }
  return true;
}

/// Context manager version of os.chdir. When exited, returns to the working
/// directory prior to entering.
void workIn(String dirName, Function yield) {
  Directory curdir = Directory.current;
  try {
    if (dirName != null) {
      Directory.current = dirName;
      yield();
    }
  } finally {
    Directory.current = curdir;
  }
}