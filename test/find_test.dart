import 'package:test/test.dart';
import 'package:cookiecutter/find.dart' as find;
import 'package:path/path.dart' as path;

main() {
  test('find template', () {
    var fakeRepos = [
      'test/fake-repo-pre', 'test/fake-repo-pre2'
    ];
    for(String repoDir in fakeRepos) {
      String template = find.findTemplate(repoDir);
      String testDir = path.join(repoDir, '{{cookiecutter.repo_name}}');
      expect(template, testDir);
    }
  });
}