/// Functions for discovering and executing various cookiecutter hooks.
library cookiecutter.hooks;
import 'package:cookiecutter/common.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:grinder/grinder.dart' as grind;
import 'package:grinder/grinder.dart';
import 'package:cookiecutter/utils.dart';

List _HOOKS = <String>[
  'pre_gen_project',
  'post_gen_project'
  // TODO (original) : other hooks should be listed here
];

/// Must be called with the project template as the current working directory.
/// Returns a dict of all hook scripts provided.
/// Dict's key will be the hook/script's name, without extension, while
/// values will be the absolute path to the script.
/// Missing scripts will not be included in the returned dict.
Map findHooks() {
  String hooksDir = 'hooks';
  Map r = {};
  logging.fine('hooksDir is $hooksDir');

  if (!new Directory(hooksDir).existsSync()) {
    logging.fine('No hooks dir in template_dir');
    return r;
  }
  for (File f in new Directory(hooksDir).listSync()) {
    String basename = path.basenameWithoutExtension(f.path);
    if (_HOOKS.contains(basename)) {
      r[basename] = path.absolute(f.path);
    }
  }
  return r;
}

/// Executes a script from a working directory.
///
/// [scriptPath] : Absolute path to the script to run.
/// [cwd] : The directory to run the script from.
void runScript(String scriptPath, {cwd: '.'}) {
  RunOptions options = new RunOptions(workingDirectory: cwd, runInShell: true);
  grind.run(scriptPath, arguments: [], runOptions: options);
//  Process.runSync(scriptPath, [], workingDirectory: cwd);
}

/// Executes a script after rendering with it Jinja.
/// [scriptPath] : Absolute path to the script to run.
/// [cwd] : The directory to run the script from.
/// [context] : Cookiecutter project template context.
void runScriptWithContext(String scriptPath, String cwd, Map context) {
  // TODO
  makeExecutable(scriptPath);
  runScript(scriptPath, cwd: cwd);
}

void runHook(hookName, projectDir, context) {
  var script = findHooks()[hookName];
  if (script == null) {
    logging.fine('No hooks found');
    return;
  }
  runScriptWithContext(script, projectDir, context);
}