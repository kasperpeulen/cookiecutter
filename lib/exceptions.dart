/// All exceptions used in the Cookiecutter code base are defined here.
library cookiecutter.exceptions;

/// Raised when a project's input dir is not templated.
/// The name of the input directory should always contain a string that is
/// rendered to something else, so that input_dir != output_dir.
class NonTemplatedInputDirException implements Exception {

}

/// Raised when Cookiecutter cannot determine which directory is the project
/// template, e.g. more than one dir appears to be a template dir.
class UnknownTemplateDirException implements Exception {

}

/// Raised during cleanup when remove_repo() can't find a generated project
/// directory inside of a repo.
class MissingProjectDir implements Exception {

}

/// Raised when get_config() is passed a path to a config file, but no file
/// is found at that path.
class ConfigDoesNotExistException implements Exception {
  toString() => '''
  ConfigDoesNotExistException: Raised when getConfig() is passed a path to a
  config file, but no file is found at that path.
  ''';
}

/// Raised if the global configuration file is not valid YAML or is
/// badly constructed.
class InvalidConfiguration implements Exception {

  final String path, problem;
  final int line;
  InvalidConfiguration(this.path, this.line, this.problem);

  String toString() => '$path is not a valid YAML file.\n'
      'Error on line $line: $problem';
}

/// Raised if a repo's type cannot be determined.
class UnknownRepoType implements Exception {
  toString() => "Exception: Repo type cannot be determined.";
}

/// Raised if the version control system (git or hg) is not installed.
class VCSNotInstalled implements Exception {
  final String vcs;

  const VCSNotInstalled(this.vcs);

  toString() => "Exception: $vcs is not installed";
}

///Raised when a project's JSON context file can not be decoded.
class ContextDecodingException implements Exception {

}

/// Raised when the output directory of the project exists already.
class OutputDirExistsException implements Exception {

}

/// Raised when cookiecutter is called with both `noInput==True` and
/// `replay==True` at the same time.
class InvalidModeException implements Exception {
  toString() =>
      "InvalidModeException: You can not use both replay and no_input or extra_context "
      "at the same time.";
}




