library cookiecutter.prompt;

import 'dart:async';

import 'package:prompt/src/prompt.dart';
export 'package:prompt/src/prompt.dart';
import 'package:prompt/src/question.dart';
export 'package:prompt/src/question.dart';

/// The default [Prompt] used by [ask], [askSync], and [close].
Prompt prompt = new Prompt();

/// Ask the user a [question].
///
/// [question] can be a [String] or [Question].
Future ask(question) => prompt.ask(question);

/// Ask the user a [question] synchronously.
///
/// [question] can be a [String] or [Question].
askSync(question) => prompt.askSync(question);

/// Close the prompt.
///
/// Call this when you no longer need to [ask] any more questions.  You do
/// not need to call this method if you only use [askSync].
Future close() => prompt.close();

/// Prompts the user to enter new config, using context as a source for the
/// field names and sample values.
///
/// [no_input] : Prompt the user at command line for manual configuration?
Map promptForConfig(Map context, {bool noInput: false}) {

}