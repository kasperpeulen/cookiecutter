import 'package:test/test.dart';
import 'dart:io';
import 'package:cookiecutter/utils.dart' as utils;
import 'package:path/path.dart' as path;

Directory get cwd => Directory.current;
Directory get chTo => new Directory('test/files');


main() {
  test('make sure path exists', () {
    String existingDir, uncreatableDir;
    if (Platform.isWindows) {
      existingDir = path.absolute(Directory.current.path);
      uncreatableDir = 'a*b';
    } else {
      existingDir = '/usr/';
      uncreatableDir = '/this-doesnt-exist-and-cant-be-created/';
    }
    expect(utils.makeSurePathExists(existingDir), isTrue);
    expect(utils.makeSurePathExists('test/blah'), isTrue);
    expect(utils.makeSurePathExists('test/trailingslash/'), isTrue);
    expect(utils.makeSurePathExists(uncreatableDir), isFalse);
    new Directory('test/blah/').deleteSync();
    new Directory('test/trailingslash/').deleteSync();
  });
  test('work in function', testWorkIn);
}


testWorkIn() {
  String currentPath = path.absolute(cwd.path);
  String chToPath = path.absolute(chTo.path);
  utils.workIn(chTo.path, () {
    expect(path.absolute(Directory.current.path), chToPath);
  });
  expect(path.absolute(currentPath), path.absolute(Directory.current.path));
}