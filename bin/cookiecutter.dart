import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cookiecutter/main.dart';
import 'package:args/src/help_command.dart';
import 'package:cookiecutter/exceptions.dart';
import 'dart:io';
import 'package:cookiecutter/common.dart';
import 'package:logging/logging.dart';

/// Create a project from a Cookiecutter project template (TEMPLATE).
main(List<String> arguments) {
  try {
    new CookiecutterCommandRunner(arguments);
  } on OutputDirExistsException catch (e) {
    print(e);
    exit(1);
  } on InvalidModeException catch (e) {
    print(e);
    exit(1);
  }
}

class CookiecutterCommandRunner extends CommandRunner {
  ArgResults argResults;

  ArgParser argParser = new ArgParser(allowTrailingOptions: true);

  CookiecutterCommandRunner(List<String> args)
      : super('cookiecutter',
            'Create a project from a Cookiecutter project template.') {
    argParser
      ..addFlag("no-input",
          negatable: false,
          help: 'Do not prompt for parameters and only use cookiecutter.json '
              'file content.')
      ..addFlag('verbose', abbr: 'v', help: 'Print debug information')
      ..addFlag("replay",
          negatable: false,
          help: 'Do not prompt for parameters and only use information entered '
              'previously')
      ..addFlag("overwrite-if-exists",
          abbr: 'f',
          negatable: false,
          help: 'Overwrite the contents of the output directory if it already'
              ' exists')
      ..addOption('output-dir',
          abbr: 'o',
          defaultsTo: '.',
          help: 'Where to output the generated project dir into')
      ..addOption('checkout',
          abbr: 'c',
          defaultsTo: '.',
          help: 'branch, tag or commit to checkout after git clone');

    argResults = parse(args);

    logging.onRecord.listen((LogRecord rec) =>
        print('${rec.level.name}: ${rec.time}: ${rec.message}'));

    bool verbose = argResults['verbose'];

    // TODO: remove this later
    verbose = true;

    hierarchicalLoggingEnabled = true;

    if (verbose) {
      logging.level = Level.FINE;
    } else {
      logging.level = Level.WARNING;
    }

    logging.fine("hello");
    String template = argResults.rest[0];

    cookiecutter(template,
        noInput: argResults['no-input'],
        checkout: argResults['checkout'],
        replay: argResults['replay'],
        overwriteIfExists: argResults['overwrite-if-exists']);
  }
}
