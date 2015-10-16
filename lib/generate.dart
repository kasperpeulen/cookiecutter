/// Functions for generating a project from a project template.
library cookiecuter.generate;

import 'dart:convert';
import 'dart:io';

import 'package:cookiecutter/common.dart';
import 'package:cookiecutter/exceptions.dart';
import 'package:cookiecutter/utils.dart';
import 'package:glob/glob.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:path/path.dart' as path;

import 'common.dart';
import 'find.dart';
import 'hooks.dart';

/// Modify the given context in place based on the overwrite_context.
void applyOverwritesToContext(
    Map context, Map<String, String> overwriteContext) {
  overwriteContext.forEach((variable, overwrite) {
    if (!context.containsKey(variable)) {
      return;
    }
    dynamic contextValue = context[variable];
    if (contextValue is List) {
      // We are dealing with a choice variable
      if (contextValue.contains(overwrite)) {
        // This overwrite is actually valid for the given context
        // Let's set it as default (by definition first item in list)
        // see ``cookiecutter.prompt.prompt_choice_for_config``
        contextValue.remove(overwrite);
        contextValue.insert(0, overwrite);
      }
    } else {
      //Simply overwrite the value for this variable
      context[variable] = overwrite;
    }
  });
}

/// Returns true if `path` matches some pattern in the
/// `_copy_without_render` context setting.
///
/// [path] : A file-system path referring to a file or dir that
/// should be rendered or just copied.
/// [context] : cookiecutter context.
bool copyWithoutRender(String path, Map context) {
  try {
    for (var dontRender in context['cookiecutter']['_copy_without_render']) {
      if (new Glob(dontRender).matches(path)) {
        return true;
      }
    }
  } catch (e) {
    return false;
  }
  return false;
}

/// Ensures that dirname is a templated directory name.
bool ensureDirIsTemplated(String dirName) {
  if (dirName.contains('{{') && dirName.contains('}}')) {
    return true;
  } else {
    throw new NonTemplatedInputDirException();
  }
}

/// Generates the context for a Cookiecutter project template.
/// Loads the JSON file as a Python object, with key being the JSON filename.
///
/// [context_file] : JSON file containing key/value pairs for populating
/// the cookiecutter's variables.
/// [default_context] : Dictionary containing config to take into account.
/// [extra_context] : Dictionary containing configuration overrides
Map generateContext(
    {String contextFile: 'cookiecutter.json',
    Map defaultContext,
    Map extraContext}) {
  Map context = {};

  File contextF = new File(contextFile);
  Map obj;
  try {
    obj = JSON.decode(contextF.readAsStringSync());
  } catch (e) {
    // JSON decoding error.  Let's throw a new exception that is more
    // friendly for the developer or user.
    // TODO
    throw new ContextDecodingException();
  }

  String fileName = path.split(contextFile).last;
  String fileStem = fileName.split('.').first;
  context[fileStem] = obj;

  // Overwrite context variable defaults with the default context from the
  // user's global config, if available
  if (defaultContext != null) {
    applyOverwritesToContext(obj, defaultContext);
  }
  if (extraContext != null) {
    applyOverwritesToContext(obj, extraContext);
  }

  logging.fine('Context generated is $context');
  return context;
}

/// 1. Render the filename of infile as the name of outfile.
/// 2. Deal with infile appropriately:
///
///     a. If infile is a binary file, copy it over without rendering.
///     b. If infile is a text file, render its contents and write the
///        rendered infile to outfile.
///
/// Precondition:
///
///     When calling `generate_file()`, the root template dir must be the
///     current working directory. Using `utils.work_in()` is the recommended
///     way to perform this directory change.
///
/// [project_dir] : Absolute path to the resulting generated project.
/// [param infile] : Input file to generate the file from. Relative to the root
///     template dir.
/// [context] : Dict for populating the cookiecutter's variables.
/// [env] : Jinja2 template execution environment.
void generateFile({String projectDir, String inFile, String outfile, Map context}) {
  logging.fine('Generating file $inFile');

  // Render the path to the output file (not including the root project dir)
//  outfile ??= path.join(projectDir, render(path.relative(inFile), context));
  // logging.fine('outfile is $outfile');

  // just copy over binary files. Don't render.
  logging.fine('Check $inFile to see if it\' is a binary');

  if (isBinary(inFile)) {
    logging.fine('Copying binary $inFile to $outfile without rendering');
    try {
      new File(inFile).copySync(outfile);
    } catch(e) {
      print(e);
    }
  } else {
    var renderedFile;
    try {
      var file = new File(inFile);
      renderedFile = render(file.readAsStringSync(), context);
    } catch (e) {
      print(e);
    }

    logging.fine('Writing $outfile');

    try {
      new File(outfile).writeAsStringSync(renderedFile);
    } catch(e) {
      print(e);
    }

  }

  // Apply file permissions to output file
  // TODO
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
  String templateDir = findTemplate(repoDir);
  logging.fine('Generating project from $templateDir');
  context ??= {};

  String unrenderedDir = path.split(templateDir).last;
  ensureDirIsTemplated(unrenderedDir);
  String projectDir =
      renderAndCreateDir(unrenderedDir, context, outputDir, overwriteIfExists);

  // We want the Jinja path and the OS paths to match. Consequently, we'll:
  //   + CD to the template folder
  //   + Set Jinja's path to '.'
  //
  // In order to build our files to the correct folder(s), we'll use an
  // absolute path for the target folder (project_dir)
  projectDir = path.absolute(projectDir);
  logging.fine('projectDir is $projectDir');

  // run pre-gen hook from repoDir
  // TODO workIn(repoDir, () => runHook('pre_gen_project', projectDir, context));

  workIn(templateDir, () {
    List<Directory> dirs = Directory.current.listSync(recursive: true)
      ..retainWhere((e) => e is Directory)..add(Directory.current);
    dirs.sort((a,b) => a.path.length.compareTo(b.path.length));
    for (Directory rootDir in dirs) {
      String root = rootDir.path;

      List<Directory> ds = rootDir.listSync()..retainWhere((e) => e is Directory);
      List<String> dirs = ds.map((d) => path.relative(d.path)).toList();

      List<File> fs = rootDir.listSync()..retainWhere((e) => e is File);
      List<String> files = fs.map((f) => f.path).toList();

      // We must separate the two types of dirs into different lists.
      // The reason is that we don't want ``os.walk`` to go through the
      // unrendered directories, since they will just be copied.
      List copyDirs = [];
      List renderDirs = [];

      for (var d in dirs) {
        String d_ = path.normalize(path.join(root, d));
        // We check the full path, because that's how it can be
        // specified in the ``_copy_without_render`` setting, but
        // we store just the dir name
        if (copyWithoutRender(d_, context)) {
          copyDirs.add(d);
        } else {
          renderDirs.add(d);
        }
      }
      for (String copyDir in copyDirs) {
        String indir = path.normalize(path.join(root, copyDir));
        String outdir = path.normalize(path.join(projectDir, indir));
        logging.fine('Copying dir $indir to $outdir without rendering');
        Process.runSync('cp', [indir, outdir]);
      }
      dirs = renderDirs;
      for (var d in dirs) {
        unrenderedDir = path.join(projectDir, d);
        renderAndCreateDir(unrenderedDir, context, outputDir, overwriteIfExists);
      }
      for (var f in files) {
        String infile = f;
        String outfile = path.join(projectDir,  render(path.relative(infile), context));
        if (copyWithoutRender(infile, context)) {
          String outfileRendered = render(infile, context);
          String outfile = path.join(projectDir, outfileRendered);
          logging.fine('Copying file $infile to $outfile without rendering');
          new File(infile).copy(outfile);
          continue;
        }
        logging.fine('f is $f');
        generateFile(projectDir: projectDir, inFile: infile, outfile: outfile, context: context);
      }
    }
  });

  // run post-gen hook from repo_dir
  // TODO workIn(repoDir, () => runHook('post_gen_project', projectDir, context));
}

/// Renders the name of a directory, creates the directory, and returns its path.
String renderAndCreateDir(String dirName, Map context, String outputDir,
    [bool overwriteIfExists = false]) {
  String renderedDirname = render(dirName, context);
  logging.fine(
      'Rendered dir $renderedDirname must exists in outputDir $outputDir');
  String dirToCreate = path.normalize(path.join(outputDir, renderedDirname));
  bool outputDirExists = new Directory(dirToCreate).existsSync();

  if (overwriteIfExists) {
    if (outputDirExists) {
      logging
          .info('Output directory $dirToCreate already exists, overwriting it');
    }
  } else {
    if (outputDirExists) {
      throw new OutputDirExistsException(dirToCreate);
    }
  }
  makeSurePathExists(dirToCreate);
  return dirToCreate;
}
