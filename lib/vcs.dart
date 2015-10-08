/// Helper functions for working with version control systems.
library cookiecutter.vcs;

import 'dart:io';

import 'package:which/which.dart';
import 'package:path/path.dart' as path;

import 'prompt.dart';
import 'exceptions.dart';
import 'common.dart';
import 'utils.dart' as utils;

/// Asks the user whether it's okay to delete the previously-cloned repo.
/// If yes, deletes it. Otherwise, Cookiecutter exits.
///
/// [repoDir] : Directory of previously-cloned repo.
/// [noInput] : Suppress prompt to delete repo and just delete it.
void promptAndDeleteRepo(String repoDir, {bool noInput: false}) {
  bool okToDelete = false;

  if (noInput) {
    okToDelete = true;
  } else {
    okToDelete = askSync(new Question.confirm(
        """
    You've cloned $repoDir before.
    Is it okay to delete and re-clone it?
    """,
        defaultsTo: true));
  }

  if (okToDelete) {
    new Directory(repoDir).deleteSync(recursive: true);
  } else {
    exitWithSuccess();
  }
}

/// Determines if `repo_url` should be treated as a URL to a git or hg repo.
/// Repos can be identified prepeding "hg+" or "git+" to repo URL.
///
/// [repoUrl] Repo URL of unknown type
/// [return] ["git", repoUrl], ["hg", repoUrl] or null
List<String> identifyRepo(String repoUrl) {
  var repoUrlValues = repoUrl.split('+');
  var repoType;
  if (repoUrlValues.length == 2) {
    repoType = repoUrlValues[0];
    if (["git", "hg"].contains(repoType)) {
      return [repoType, repoUrlValues[1]];
    } else {
      throw new UnknownRepoType();
    }
  } else {
    if (repoUrl.contains("git")) {
      return ["git", repoUrl];
    } else if (repoUrl.contains("bitbucket")) {
      return ["hg", repoUrl];
    } else {
      throw new UnknownRepoType();
    }
  }
}

/// Check if the version control system for a repo type is installed.
void checkThatVcsIsInstalled(String repoType) {
  if (whichSync(repoType, orElse: () => null) == null) {
    throw new VCSNotInstalled(repoType);
  }
}

/// Clone a repo to the current directory.
///
/// [repoUrl] : Repo URL of unknown type.
/// [checkout] : The branch, tag or commit ID to checkout after clone.
/// [cloneToDir] : The directory to clone to. Defaults to the current directory.
/// [noInput] : Suppress all user prompts when calling via API.
String clone(String repoUrl,
    {String checkout: null, cloneToDir: '.', noInput: false}) {
  // Ensure that cloneToDir exists
  cloneToDir = expandPath(cloneToDir);
  utils.makeSurePathExists(cloneToDir);

  // identify the repoType
  var list = identifyRepo(repoUrl);
  String repoType = list[0];
  repoUrl = list[1];

  // check that the appropriate VCS for the repoType is installed
  checkThatVcsIsInstalled(repoType);

  String repoDir;
  String tail = path.split(repoUrl).last;

  if (repoType == 'git') {
    repoDir = path.normalize(path.join(cloneToDir, tail.split('.git').first));
  } else if (repoType == 'hg') {
    repoDir = path.normalize(path.join(cloneToDir, tail));
  }
  logging.info('repoDir is $repoDir');

  if (new Directory(repoDir).existsSync()) {
    promptAndDeleteRepo(repoDir, noInput: noInput);
  }

  if (['git', 'hg'].contains(repoType)) {
    Process.runSync(repoType, ['clone', repoUrl], workingDirectory: cloneToDir);
    if (checkout != null) {
      Process.runSync(repoType, ['ckeckout', checkout],
          workingDirectory: repoDir);
    }
  }

  return repoDir;
}
