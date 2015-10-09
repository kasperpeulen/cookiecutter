import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:cookiecutter/utils.dart' as utils;
import 'package:cookiecutter/generate.dart' as generate;

main() {
  tearDown(() {
    Directory testDir = new Directory('test_copy_without_render');
    if (testDir.existsSync()) {
      utils.rmTree('test_copy_without_render');
    }
  });

  test('generate copy without render extension', () {
    generate.generateFiles(context: {
      'cookiecutter': {
        'repo_name': 'test_copy_without_render',
        'render_test': 'I have been rendered!',
        '_copy_without_render': [
          '*not-rendered',
          'rendered/not_rendered.yml',
          '*.txt',
        ]
      }
    }, repoDir: 'test/test-generate-copy-without-render');

    List<String> dirContents =
        new Directory('test_copy_without_render').listSync().map((e) => e.path);

    expect(dirContents, ['']);
  }, skip: true);
}
