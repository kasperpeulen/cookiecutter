/// Functions for generating a project from a project template.
library cookiecuter.generate;

import 'find.dart';
import 'hooks.dart';

import 'package:cookiecutter/common.dart';
import 'package:path/path.dart' as path;
import 'package:cookiecutter/exceptions.dart';
import 'package:cookiecutter/utils.dart';

/// Generates the context for a Cookiecutter project template.
/// Loads the JSON file as a Python object, with key being the JSON filename.
///
/// [context_file] : JSON file containing key/value pairs for populating
/// the cookiecutter's variables.
/// [default_context] : Dictionary containing config to take into account.
/// [extra_context] : Dictionary containing configuration overrides
Map generateContext(
    {contextFile: 'cookiecutter.json',
    defaultContext: null,
    extraContext: null}) {}

/// Ensures that dirname is a templated directory name.
bool unsureDirIsTemplated(String dirName) {
  if (dirName.contains('{{') && dirName.contains('}}')) {
    return true;
  } else {
    throw new NonTemplatedInputDirException();
  }
}

// TODO
/// Renders the name of a directory, creates the directory, and returns its path.
String renderAndCreateDir(String dirName, Map context, String outputDir,
    [bool overwriteIfExists = false]) {

}


/// Renders the templates and saves them to files.
///
/// [repoDir] : Project template input directory.
/// [context] : Dict for populating the template's variables.
/// [output_dir] : Where to output the generated project dir into.
/// [overwrite_if_exists] : Overwrite the contents of the output directory
/// if it exists
void generateFiles(
    {String repoDir,
    Map context,
    outputDir: '.',
    bool overwriteIfExists: false}) {
  context ??= {};

  String templateDir = findTemplate(repoDir);
  logging.info('Generating project from $templateDir');

  String unrenderedDir = path.split(templateDir)[1];
  unsureDirIsTemplated(unrenderedDir);
  String projectDir =
      renderAndCreateDir(unrenderedDir, context, outputDir, overwriteIfExists);

  // We want the Jinja path and the OS paths to match. Consequently, we'll:
  //   + CD to the template folder
  //   + Set Jinja's path to '.'
  //
  // In order to build our files to the correct folder(s), we'll use an
  // absolute path for the target folder (project_dir)

  projectDir = path.absolute(projectDir);
  logging.info('projectDir is $projectDir');

  // run pre-gen hook from repoDir
  workIn(repoDir, () => runHook('pre_gen_project', projectDir, context));

  workIn(templateDir, () {
    //TODO
  });

  // run post-gen hook from repo_dir
  workIn(repoDir, () => runHook('post_gen_project', projectDir, context));
}

