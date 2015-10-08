library cookiecutter.common;

import 'dart:io';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

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

String get userHomeDir =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

final Logger logging = new Logger('cookiecutter');

// Having this as a global variable, so that it can be mocked.
Function exitWithSuccess = () {
  exit(0);
};