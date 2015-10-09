import 'dart:io';

import 'package:test/test.dart';
import 'package:cookiecutter/generate.dart' as generate;

main() {
  tearDown(() {
    var file = new File('test/files/cheese.txt');
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  test('generate file', () {
    String inFile = 'test/files/{{generate_file}}.txt';
    generate.generateFile(
        projectDir: '.', inFile: inFile, context: {'generate_file': 'cheese'});
    var file = new File('test/files/cheese.txt');
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), 'Testing cheese');
  });

  test('generate_file_verbose_template_syntax_error', () {
    expect(
        () => generate.generateFile(
            projectDir: '.',
            inFile: 'test/files/syntax_error.txt',
            context: {'syntax_error': 'syntax_error'}),
        throwsA(new isInstanceOf<Exception>()));
  }, skip: 'In mustache this is no syntax error.');
}
