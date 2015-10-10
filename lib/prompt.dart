/// Functions for prompting the user for project info.
library cookiecutter.prompt;

import 'dart:async';

import 'package:prompt/src/prompt.dart';
export 'package:prompt/src/prompt.dart';
import 'package:prompt/src/question.dart';
import 'package:mustache4dart/mustache4dart.dart';
export 'package:prompt/src/question.dart';

/// Prompt the user for the given variable and return the entered value
/// or the given default.
///
/// [varName] : Variable of the context to query the user
/// [defaultValue] : Value that will be returned if no input happens
readUserVariable(String varName, defaultValue) {
  return askSync(new Question('$varName', defaultsTo: defaultValue));
}

/// Prompt the user to reply with 'yes' or 'no' (or equivalent values).
///
/// Note:
///   Possible choices are 'true', '1', 'yes', 'y' or 'false', '0', 'no', 'n'
///
/// [question] : Question to the user
/// [defaultValue] : Value that will be returned if no input happens
readUserYesNo(String question, defaultValue) {
  return askSync(new Question.confirm(question, defaultsTo: defaultValue));
}

/// Prompt the user to choose from several options for the given variable.
///
/// The first item will be returned if no input happens.

/// [var_name] : Variable as specified in the context
/// [options] : Sequence of options that are available to select from
/// Returns exactly one item of [options] that has been chosen by the user
String readUserChoice(String varName, List options) {
  return askSync(new Question(varName, allowed: options));
}

renderVariable(String raw, cookiecutterDict) {
  return render(raw, cookiecutterDict);
}

/// Prompt the user which option to choose from the given. Each of the
/// possible choices is rendered beforehand.
promptChoiceForConfig(
    Map cookiecutterDict, String key, List options, bool noInput) {
  List renderedOptions =
      options.map((raw) => renderVariable(raw, cookiecutterDict)).toList();
  return readUserChoice(key, renderedOptions);
}

/// Prompts the user to enter new config, using context as a source for the
/// field names and sample values.
///
/// [no_input] : Prompt the user at command line for manual configuration?
Map promptForConfig(Map<String, Map<String, dynamic>> context,
    {bool noInput: false}) {
  Map cookiecutterDict = {};
  context['cookiecutter'].forEach((key, raw) {
    if (key.startsWith('_')) {
      cookiecutterDict[key] = raw;
    }
    var val;
    if (raw is List) {
      val = promptChoiceForConfig(cookiecutterDict, key, raw, noInput);
    } else {
      val = renderVariable(raw, cookiecutterDict);
      if (!noInput) {
        val = readUserVariable(key, val);
      }
    }
    cookiecutterDict[key] = val;
  });
  return cookiecutterDict;
}

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
