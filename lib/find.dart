/// Functions for finding Cookiecutter templates and other components.
library cookiecutter.find;

import 'package:cookiecutter/common.dart';
import 'dart:io';
import 'package:cookiecutter/exceptions.dart';

/// Determines which child directory of `repo_dir` is the project template.
///
/// [repoDir] : Local directory of newly cloned repo.
/// returns [projectTemplate] : Relative path to project template.
String findTemplate(String repoDir) {
  logging.info('Searching $repoDir for the project template.');

  List<FileSystemEntity> repoDirContents = new Directory(repoDir).listSync()
    ..retainWhere((e) => e is Directory);
  String projectTemplate;
  for (Directory dir in repoDirContents) {
    var path = dir.path;
    if (path.contains('cookiecutter') && path.contains('{{') && path.contains('}}')) {
      projectTemplate = path;
      break;
    }
  }
  if (projectTemplate != null) {
    logging.info('The project template appears to be $projectTemplate');
    return projectTemplate;
  } else {
    throw new NonTemplatedInputDirException();
  }
}
