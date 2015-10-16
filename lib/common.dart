library cookiecutter.common;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';

Function exitWithSuccess = () {
  exit(0);
};

final Logger logging = new Logger('cookiecutter');

String get userHomeDir =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

// Having this as a global variable, so that it can be mocked.
String expandPath(String path) {
  if (path[0] != '~') {
    return path;
  }
  if (path == '~') {
    return userHomeDir;
  }
  if (path.substring(0, 2) != '~/') {
    return path;
  }
  return join(userHomeDir, path.substring(2));
}

bool isBinary(String inFile) {
  bool b;
  try {
    b = new File(inFile)
        .readAsStringSync()
        .contains('\u0000\u0000\u0000\u0000');
  } catch (e) {
    b = true;
  }
  return b;
}
