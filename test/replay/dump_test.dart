import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'conftest.dart';
import 'dart:io';
import 'package:cookiecutter/replay.dart' as replay;

/// Fixture to return a valid template_name.
String get templateName => 'cookiedozer';

/// Fixture to return a actual file name of the dump.
String get replayFile {
  String fileName = '$templateName.json';
  return path.join(replayTestDir, fileName);
}

main() {
  tearDown(() {
    // Remove the replay file created by tests.
    File f = new File(replayFile);
    if (f.existsSync()) {
      f.deleteSync();
    }
  });

  // Test that replay.dump raises if the tempate_name is not a valid str.
  test('type_error_if_no_template_name', () {
    expect(() => replay.dump(null, context),
        throwsA(new isInstanceOf<TypeError>()));
  });

  test('type_error_if_not_dict_context', () {
    expect(() => replay.dump(templateName, 'not_a_map'),
        throwsA(new isInstanceOf<TypeError>()));
  });

  test('value_error_if_key_missing_in_context', () {
    expect(() => replay.dump(templateName, {'foo': 'bar'}),
        throwsA(new isInstanceOf<ArgumentError>()));
  });

  // Test that replay.dump raises when the replay_dir cannot be created.
  test('ioerror_if_replay_dir_creation_fails', () {
    mockUserConfig();
    expect(
        () => replay.dump('foo', {
              'cookiecutter': {'hello': 'world'}
            }),
        throwsA(new isInstanceOf<FileSystemException>()));
    resetUserConfig();
  }, skip: true);

  // Test that replay.dump runs json.dump under the hood and that the context
  // is correctly written to the expected file in the replay_dir.
  test('run json dump', () {
    mockUserConfig();
    replay.dump(templateName, context);
    expect(mockCallCount, 1);
    // TODO
    resetUserConfig();
  }, skip: true);
}
