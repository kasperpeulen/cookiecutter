import 'package:test/test.dart';
import 'package:cookiecutter/replay.dart' as replay;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'conftest.dart';

/// Fixture to return a valid template_name.
String get templateName => 'cookiedozer_load';

/// Fixture to return a actual file name of the dump.
String replayFile(replayTestDir) {
  String fileName = '$templateName.json';
  return path.join(replayTestDir, fileName);
}

main() {
  setUp(mockUserConfig);
  tearDown(resetUserConfig);

  // Test that replay.load raises if the tempate_name is not a valid str.
  test('type error if no template name', () {
    expect(() => replay.load(null), throwsA(new isInstanceOf<TypeError>()));
  });

  // Test that replay.load raises if the loaded context does not contain
  // 'cookiecutter'.
  test('value_error_if_key_missing_in_context', () {
    expect(() => replay.load('invalid_replay'),
        throwsA(new isInstanceOf<ArgumentError>()));
  });

  test('io_error_if_no_replay_file', () {
    expect(() => replay.load('no_replay'),
        throwsA(new isInstanceOf<FileSystemException>()));
  });

  // Test that replay.load runs json.load under the hood and that the context
  // is correctly loaded from the file in replay_dir.
  test('run_json_load', (){
    Map loadedContext = replay.load(templateName);
    expect(mockCallCount, 1);
    expect(loadedContext, context);
    // TODO
  }, skip: true);
}

