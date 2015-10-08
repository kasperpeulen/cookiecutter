import 'package:test/test.dart';
import 'package:cookiecutter/main.dart';

main() {
  var tests = [
    ['gitolite@server:team/repo', isTrue],
    ['git@github.com:audreyr/cookiecutter.git', isTrue],
    ['https://github.com/audreyr/cookiecutter.git', isTrue],
    ['https://bitbucket.org/pokoli/cookiecutter.hg', isTrue],
    ['/audreyr/cookiecutter.git', isFalse],
    ['/home/audreyr/cookiecutter', isFalse]
  ];
  tests.forEach((t) {
    test('test_is_repo_url ${t[0]}', () {
        expect(isRepoUrl(t[0]), t[1]);
      });
  });
}