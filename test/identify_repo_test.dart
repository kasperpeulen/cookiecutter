library cookiecutter.test.indentify_repo_test;

import 'package:test/test.dart';
import 'package:cookiecutter/vcs.dart' as vcs;
import 'package:cookiecutter/exceptions.dart';

main() {
  test("test_identify_git_github", () {
    String repoUrl = 'https://github.com/audreyr/cookiecutter-pypackage.git';
    expect(vcs.identifyRepo(repoUrl)[0], 'git');
  });
  test("test_identify_git_github_no_extension", () {
    String repoUrl = 'https://github.com/audreyr/cookiecutter-pypackage';
    expect(vcs.identifyRepo(repoUrl)[0], 'git');
  });
  test("test_identify_git_gitorious", () {
    String repoUrl =
        'git@gitorious.org:cookiecutter-gitorious/cookiecutter-gitorious.git';
    expect(vcs.identifyRepo(repoUrl)[0], 'git');
  });
  test("test_identify_hg_mercurial", () {
    String repoUrl =
        'https://audreyr@bitbucket.org/audreyr/cookiecutter-bitbucket';
    expect(vcs.identifyRepo(repoUrl)[0], 'hg');
  });
  test("test_unknown_repo_type", () {
    String repoUrl = 'http://norepotypespecified.com';
    expect(() => vcs.identifyRepo(repoUrl),
        throwsA(new isInstanceOf<UnknownRepoType>()));
  });
}
