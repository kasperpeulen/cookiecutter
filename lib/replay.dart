library cookiecutter.replay;

import 'dart:convert';
import 'dart:io';

import 'package:cookiecutter/common.dart';
import 'package:cookiecutter/utils.dart';
import 'package:path/path.dart' as path;

import 'config.dart';

void dump(String templateName, Map context) {
  if (templateName == null) {
    throw new TypeError();
  }

  if (!context.containsKey('cookiecutter')) {
    throw new ArgumentError(
        'Context is required to contain a cookiecutter key');
  }
  String replayDir = expandPath(getUserConfig()['replay_dir']);

  if (!makeSurePathExists(replayDir)) {
    throw new FileSystemException('Unable to create replay dir at $replayDir');
  }
  File replayFile = new File(getFileName(replayDir, templateName));

  context['cookiecutter']
      .keys
      .where((key) => context['cookiecutter'][key] is Function)
      .toList()
      .forEach(context['cookiecutter'].remove);

  replayFile.writeAsStringSync(JSON.encode(context));
}

String getFileName(replayDir, templateName) {
  return path.join(replayDir, '$templateName.json');
}

Map load(String templateName) {
  if (templateName == null) {
    throw new TypeError();
  }

  String replayDir = expandPath(getUserConfig()['replay_dir']);
  File replayFile = new File(getFileName(replayDir, templateName));

  Map context = JSON.decode(replayFile.readAsStringSync());
  if (!context.containsKey('cookiecutter')) {
    throw new ArgumentError(
        'Context is required to contain a cookiecutter key');
  }

  return context;
}
