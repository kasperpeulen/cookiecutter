/// Functions for prompting the user for project info.
library cookiecutter.prompt;

import 'package:cookiecutter/mustache.dart';
import 'package:prompt/src/prompt.dart';
import 'package:prompt/src/question.dart';

export 'package:prompt/src/prompt.dart';
export 'package:prompt/src/question.dart';

/// The default [Prompt] used by [ask].
Prompt prompt = new Prompt();

/// Ask the user a [question] synchronously.
///
/// [question] can be a [String] or [Question].
ask(question) => prompt.askSync(question);

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

/// Prompt the user to choose from several options for the given variable.
///
/// The first item will be returned if no input happens.

/// [var_name] : Variable as specified in the context
/// [options] : Sequence of options that are available to select from
/// Returns exactly one item of [options] that has been chosen by the user
String readUserChoice(String varName, List options) {
  return ask(new Question(varName, allowed: options));
}

/// Prompt the user for the given variable and return the entered value
/// or the given default.
///
/// [varName] : Variable of the context to query the user
/// [defaultValue] : Value that will be returned if no input happens
readUserVariable(String varName, defaultValue) {
  return ask(new Question('$varName', defaultsTo: defaultValue));
}

/// Prompt the user to reply with 'yes' or 'no' (or equivalent values).
///
/// Note:
///   Possible choices are 'true', '1', 'yes', 'y' or 'false', '0', 'no', 'n'
///
/// [question] : Question to the user
/// [defaultValue] : Value that will be returned if no input happens
readUserYesNo(String question, defaultValue) {
  return ask(new Question.confirm(question, defaultsTo: defaultValue));
}

renderVariable(String raw, cookiecutterDict) {
  return render(raw, cookiecutterDict);
}
