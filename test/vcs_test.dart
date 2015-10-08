library cookiecutter.test.vcs_test;

import 'dart:io';
import 'package:test/test.dart';

import 'package:cookiecutter/vcs.dart' as vcs;
import 'package:cookiecutter/exceptions.dart';

main() {
  test("git clone", testGitClone);

  test("vcs not installed", () {
    var data = ["stringthatisntashellcommand", "anotherstringnotincommand"];
    data.forEach(testVcsNotInstalled);
  });

  test("indentify known repo", () {
    var data = [
      [
        "git+https://github.com/pytest-dev/cookiecutter-pytest-plugin.git",
        "git",
        "https://github.com/pytest-dev/cookiecutter-pytest-plugin.git"
      ],
      [
        "hg+https://bitbucket.org/foo/bar.hg",
        "hg",
        "https://bitbucket.org/foo/bar.hg"
      ],
      [
        "https://github.com/pytest-dev/cookiecutter-pytest-plugin.git",
        "git",
        "https://github.com/pytest-dev/cookiecutter-pytest-plugin.git"
      ],
      [
        "https://bitbucket.org/foo/bar.hg",
        "hg",
        "https://bitbucket.org/foo/bar.hg"
      ]
    ];
    data.forEach((d) => testIdentifyKnownRepo(d[0], d[1], d[2]));
  });

  test("indentify raise on unknown repo", () {
    var data = [
      "foo+git", // uses explicit identifier with 'git' in the wrong place
      "foo+hg", //uses explicit identifier with 'hg' in the wrong place
      "foo+bar", // uses explicit identifier with neither 'git' nor 'hg'
      "foobar" // no identifier but neither 'git' nor 'bitbucket' in url
    ];
    data.forEach(testIdentifyRaiseOnUnknownRepo);
  });
}

testGitClone() {
  String repoDir =
      vcs.clone('https://github.com/audreyr/cookiecutter-pypackage.git');

  expect(repoDir, 'cookiecutter-pypackage');
  expect(new File('cookiecutter-pypackage/README.rst').existsSync(), isTrue);
  var dir = new Directory('cookiecutter-pypackage');
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

testVcsNotInstalled(String vcSystem) {
  expect(() => vcs.checkThatVcsIsInstalled(vcSystem),
      throwsA(new isInstanceOf<VCSNotInstalled>()));
}

testIdentifyKnownRepo(String repoUrl, String expRepoType, String expRepoUrl) {
  expect(vcs.identifyRepo(repoUrl), [expRepoType, expRepoUrl]);
}

testIdentifyRaiseOnUnknownRepo(String unknownRepoTypeUrl) {
  expect(() => vcs.identifyRepo(unknownRepoTypeUrl),
      throwsA(new isInstanceOf<UnknownRepoType>()));
}
