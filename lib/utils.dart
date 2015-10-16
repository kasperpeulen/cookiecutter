/// Helper functions used throughout Cookiecutter.
library cookiecutter.utils;

import 'dart:io';
import 'common.dart';

/// Error handler for `shutil.rmtree()` equivalent to `rm -rf`
/// Usage: `shutil.rmtree(path, onerror=force_delete)`
/// From stackoverflow.com/questions/1889597
forceDelete(func, path, excInfo) {

}

/// Removes a directory and all its contents. Like rm -rf on Unix.
rmTree(path) {
  new Directory(path).deleteSync(recursive: true);
}


/// Ensures that a directory exists.
/// [path] : A Directory path.
makeSurePathExists(String path) {
  logging.fine('Making sure that path exists: $path');
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

/// Makes [scriptPath] executable
///
/// [scriptPath] : The file to change
makeExecutable(scriptPath) {
  if (!Platform.isWindows) {
    var result = Process.runSync("chmod", ["u+x", scriptPath]);
    if (result.exitCode != 0) throw new Exception(result.stderr);
  }
}
