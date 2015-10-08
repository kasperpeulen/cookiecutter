library cookiecutter.replay;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'config.dart';
import 'dart:convert';
import 'package:cookiecutter/utils.dart';

String getFileName(replayDir, templateName) {
  return path.join(replayDir, '$templateName.json');
}

Map load(String templateName) {
  String replayDir = getUserConfig()['replayDir'];
  File replayFile = new File(getFileName(replayDir, templateName));

  Map context = JSON.decode(replayFile.readAsStringSync());

  if (!context.containsKey('cookiecutter')) {
    throw new ArgumentError('Context is required to contain a cookiecutter key');
  }

  return context;
}

void dump(String templateName, Map context) {
  if (!context.containsKey('cookiecutter')) {
    throw new ArgumentError('Context is required to contain a cookiecutter key');
  }
  String replayDir = getUserConfig()['replay_dir'];

  if(!makeSurePathExists(replayDir)) {
    throw new FileSystemException('Unable to create replay dir at $replayDir');
  }
  File replayFile = new File(getFileName(replayDir, templateName));
  replayFile.writeAsStringSync(JSON.encode(context));
}