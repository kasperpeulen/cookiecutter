import 'package:test/test.dart';
import 'package:cookiecutter/vcs.dart' as vcs;
import 'package:cookiecutter/exceptions.dart';

main() {
  test("existing repo type", () {
    expect(vcs.checkThatVcsIsInstalled('git'), isNull);
    expect(() => vcs.checkThatVcsIsInstalled('stringthatisntashellcommand'),
        throwsA(new isInstanceOf<VCSNotInstalled>()));
  });
}