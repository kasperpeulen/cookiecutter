library cookiecutter.test.vcs_prompt_test;

import 'dart:io';

import 'package:test/test.dart';
import 'package:prompt/testing.dart';

import 'package:cookiecutter/vcs.dart' as vcs;
import 'package:cookiecutter/prompt.dart';
import 'package:cookiecutter/common.dart' as common;

main() {
  setUp(cleanCookiecutterDirs);
  tearDown(removeCookiecutterDirs);

  test("git clone overwrite", testGitCloneOverwrite);
  test("git clone overwrite with no prompt", testGitCloneOverwriteWithNoPrompt);
  test("git clone cancel", testGitCloneCancel);
  test("hg clone overwrite", testHgCloneOverwrite);
  test("hg clone cancel", testHgCloneCancel);
}

testGitCloneOverwrite() {
  prompt = new MockPrompt((question) => true);
  String repoDir =
      vcs.clone('https://github.com/audreyr/cookiecutter-pypackage.git');

  expect(repoDir, 'cookiecutter-pypackage');
  expect(new File('cookiecutter-pypackage/README.rst').existsSync(), isTrue);
}

testGitCloneOverwriteWithNoPrompt() {
  String repoDir = vcs.clone(
      'https://github.com/audreyr/cookiecutter-pypackage.git',
      noInput: true);

  expect(repoDir, 'cookiecutter-pypackage');
  expect(new File('cookiecutter-pypackage/README.rst').existsSync(), isTrue);
}

testGitCloneCancel() {
  prompt = new MockPrompt((question) => false);
  common.exitWithSuccess = () => throw new ExitWithSuccess();
  expect(
      () => vcs.clone('https://github.com/audreyr/cookiecutter-pypackage.git'),
      throwsA(new isInstanceOf<ExitWithSuccess>()));
}

class ExitWithSuccess {}

testHgCloneOverwrite() {
  cleanCookiecutterDirs();

  prompt = new MockPrompt((question) => true);
  String repoDir =
      vcs.clone('https://bitbucket.org/pokoli/cookiecutter-trytonmodule');

  expect(repoDir, 'cookiecutter-trytonmodule');
  expect(new File('cookiecutter-trytonmodule/README.rst').existsSync(), isTrue);

  removeCookiecutterDirs();
}

testHgCloneCancel() {
  cleanCookiecutterDirs();

  prompt = new MockPrompt((question) => false);
  common.exitWithSuccess = () => throw new ExitWithSuccess();
  expect(
      () => vcs.clone('https://bitbucket.org/pokoli/cookiecutter-trytonmodule'),
      throwsA(new isInstanceOf<ExitWithSuccess>()));

  removeCookiecutterDirs();
}

Directory get gitRepo => new Directory('cookiecutter-pypackage');
Directory get hgRepo => new Directory('cookiecutter-trytonmodule');

cleanCookiecutterDirs() {
  removeCookiecutterDirs();
  gitRepo.createSync();
  hgRepo.createSync();
}

removeCookiecutterDirs() {
  if (gitRepo.existsSync()) gitRepo.deleteSync(recursive: true);
  if (hgRepo.existsSync()) hgRepo.deleteSync(recursive: true);
}
