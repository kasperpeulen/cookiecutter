import 'package:test/test.dart';
import 'package:cookiecutter/generate.dart' as generate;
import 'package:cookiecutter/exceptions.dart';
import 'dart:io';
import 'package:cookiecutter/utils.dart';
import 'package:path/path.dart' as path;

main() {
  test('ensure_dir_is_templated_raises', () {
    var invalidDirnames = ['', '{foo}', '{{foo', 'bar}}'];
    invalidDirnames.forEach((invalidDirname) {
      expect(() => generate.ensureDirIsTemplated(invalidDirname),
          throwsA(new isInstanceOf<NonTemplatedInputDirException>()));
    });
  });

  group('', () {
    tearDown(() {
      var dirs = [
        'inputpizzä',
        'inputgreen',
        'inputbinary_files',
        'test/custom_output_dir',
        'inputpermissions'
      ];
      dirs.forEach((path) {
        var d = new Directory(path);
        if (d.existsSync()) {
          d.deleteSync(recursive: true);
        }
      });
    });

    test('generate_files_nontemplated_exception', () {
      expect(
          () => generate.generateFiles(
              context: {'cookiecutter': {'food': 'pizza'}},
              repoDir: 'test/test-generate-files-nontemplated'),
          throwsA(new isInstanceOf<NonTemplatedInputDirException>()));
    });

    test('generate files', () {
      generate.generateFiles(context: {
        'cookiecutter': {'food': 'pizzä'}
      }, repoDir: 'test/test-generate-files');

      File simpleFile = new File('inputpizzä/simple.txt');
      expect(simpleFile.existsSync(), isTrue);
      expect(simpleFile.readAsStringSync(), 'I eat pizzä');
    });

    test('generate files with trailing newline', () {
      generate.generateFiles(context: {
        'cookiecutter': {'food': 'pizzä'}
      }, repoDir: 'test/test-generate-files');

      File  newlineFile = new File('inputpizzä/simple-with-newline.txt');
      expect(newlineFile.existsSync(), isTrue);
      expect(newlineFile.readAsStringSync(), 'I eat pizzä\n');
    });

    test('generate_files_binaries', () {
      generate.generateFiles(context: {
        'cookiecutter': {'binary_test': 'binary_files'}
      }, repoDir: 'test/test-generate-binaries');
      expect(new File('inputbinary_files/logo.png').existsSync(), isTrue);
      expect(new File('inputbinary_files/readme.txt').existsSync(), isTrue);
      expect(new File('inputbinary_files/some_font.otf').existsSync(), isTrue);
      expect(new File('inputbinary_files/binary_files/readme.txt').existsSync(), isTrue);
      expect(new File('inputbinary_files/binary_files/some_font.otf').existsSync(), isTrue);
      expect(new File('inputbinary_files/binary_files/binary_files/logo.png').existsSync(), isTrue);
    });

    test('generate files absolute path', () {
      generate.generateFiles(context: {
        'cookiecutter': {'food': 'pizzä'}
      }, repoDir: path.absolute('test/test-generate-files'));

      File simpleFile = new File('inputpizzä/simple.txt');
      expect(simpleFile.existsSync(), isTrue);
      expect(simpleFile.readAsStringSync(), 'I eat pizzä');
    });

    test('generate files output dir', () {
      generate.generateFiles(context: {
        'cookiecutter': {'food': 'pizzä'}
      }, repoDir: path.absolute('test/test-generate-files'),
          outputDir: 'test/custom_output_dir' );

      File simpleFile = new File('test/custom_output_dir/inputpizzä/simple.txt');
      expect(simpleFile.existsSync(), isTrue);
      expect(simpleFile.readAsStringSync(), 'I eat pizzä');
    });

  });
}
