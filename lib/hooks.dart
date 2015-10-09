/// Functions for discovering and executing various cookiecutter hooks.
library cookiecutter.hooks;
import 'package:cookiecutter/common.dart';

var _HOOKS = <String>[
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
  Map r = {};
  // TODO
  return r;
}

/// Executes a script from a working directory.
///
/// [scriptPath] : Absolute path to the script to run.
/// [cwd] : The directory to run the script from.
void runScript(String scriptPath, {cwd: '.'}) {
  // TODO
}

/// Executes a script after rendering with it Jinja.
/// [scriptPath] : Absolute path to the script to run.
/// [cwd] : The directory to run the script from.
/// [context] : Cookiecutter project template context.
void runScriptWithContext(String scriptPath, Stringcwd, Map context) {
  // TODO
}

void runHook(hookName, projectDir, context) {
  var script = findHooks()[hookName];
  if (script == null) {
    logging.info('No hooks found');
  }
  runScriptWithContext(script, projectDir, context);
}