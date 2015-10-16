/// Main entry point for the `cookiecutter` command.
///
/// The code in this module is also a good example of how to use Cookiecutter as
/// a library rather than a script.
library cookiecutter.main;

import 'package:path/path.dart' as path;

import 'exceptions.dart';
import 'config.dart';
import 'vcs.dart';
import 'package:cookiecutter/common.dart';
import 'package:cookiecutter/generate.dart';
import 'package:cookiecutter/prompt.dart';
import 'package:cookiecutter/replay.dart' as replayLib;

Map<String, String> builtinAbbreviations = {
  'gh': 'https://github.com/{0}.git',
  'bb': 'https://bitbucket.org/{0}'
};

String REPO_REGEX =
'('
'((git|ssh|https|http):(//)?)'    // something like git:// ssh:// etc.
  '|'                             // or
  '(\\w+@[\\w\\.]+)'              // something like user@...
')'
'.*';

/// Return true if value is a repository URL.
bool isRepoUrl(String value) => new RegExp(REPO_REGEX).hasMatch(value);

/// Expand abbreviations in a template name.
///
/// [template] : the project template name.
/// [config_dict] : The user config, which will contain abbreviation definitions.
String expandAbbreviations(String template, Map<String, Map> config_dict) {
  var abbreviations = builtinAbbreviations;
  abbreviations.addAll(config_dict.containsKey('abbreviations')
      ? config_dict['abbreviations']
      : {});

  if (abbreviations.containsKey(template)) {
    return abbreviations[template];
  }

  // Split on colon. If there is no colon, rest will be empty
  // and prefix will be the whole template
  String prefix, rest;
  if (!template.contains(':')) {
    prefix = template;
    if (abbreviations.containsKey(prefix)) {
      return abbreviations[prefix];
    }
  } else {
    var split = template.split(':');
    prefix = split[0];
    rest = split[1];
    if (abbreviations.containsKey(prefix)) {
      return abbreviations[prefix].replaceAll('{0}', rest);
    }
  }

  return template;
}

/// API equivalent to using Cookiecutter at the command line.
///
/// [param] : A directory containing a project template directory, or a URL to
/// a git repository.
/// [noInput] : Prompt the user at command line for manual configuration?
/// [extraContent] : A dictionary of context that overrides default and user
/// configuration.
/// [overwriteIfExists] : Overwrite the contents of output directory if it exists
/// [outputDir] : Where to output the generated project dir into.
void cookiecutter(String template,
    {checkout: null,
    noInput: false,
    extraContext: null,
    replay: false,
    overwriteIfExists: false,
    outputDir: '.'}) {
  if (replay && (noInput || extraContext != null)) {
    throw new InvalidModeException();
  }

  Map configDict = getUserConfig();

  // Get user config from ~/.cookiecutterrc or equivalent
  // If no config file, sensible defaults from config.DEFAULT_CONFIG are used
  template = expandAbbreviations(template, configDict);

  String repoDir;
  if (isRepoUrl(template)) {
    repoDir = clone(template,
        checkout: checkout,
        cloneToDir: configDict['cookiecutters_dir'],
        noInput: noInput);
  } else {
    // If it's a local repo, no need to clone or copy to your
    // cookiecutters_dir
    repoDir = template;
  }

  String templateName = path.basename(template);

  Map context;
  String contextFile;
  if (replay) {
    context = replayLib.load(templateName);
  } else {
    contextFile = path.join(repoDir, 'cookiecutter.json');
    logging.fine('contextFile is $contextFile');

    context = generateContext(
      contextFile: contextFile,
      defaultContext: configDict['default_context'],
      extraContext: extraContext
    );

    // prompt the user to manually configure at the command line
    // except when `noInput` flag is set
    context['cookiecutter'] = promptForConfig(context, noInput: noInput);

    replayLib.dump(templateName, context);
  }

  // Create project from local context and project template.
  generateFiles(
    repoDir: repoDir,
    context: context,
    overwriteIfExists: overwriteIfExists,
    outputDir: outputDir
  );
}
