import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:cookiecutter/replay.dart' as replay;
import 'package:cookiecutter/main.dart' as mainLib;
import 'package:cookiecutter/exceptions.dart';

main() {
  // Make sure that replay.get_file_name generates a valid json file path.
  test('get replay file name', () {
    expect(replay.getFileName('foo', 'bar'), path.join('foo', 'bar.json'));
  });

  test('raise on invalid mode', () {
    expect(() => mainLib.cookiecutter('foo', replay: true, noInput: true),
        throwsA(new isInstanceOf<InvalidModeException>()));
    expect(() => mainLib.cookiecutter('foo', replay: true, extraContext: {}),
        throwsA(new isInstanceOf<InvalidModeException>()));
    expect(() => mainLib.cookiecutter('foo', replay: true, noInput: true, extraContext: {}),
        throwsA(new isInstanceOf<InvalidModeException>()));
  });

  test('main_does_not_invoke_dump_but_load', () {
    // TODO
  }, skip: true);

  test('main_does_not_invoke_load_but_dump', () {
    // TODO
  }, skip: true);
}
