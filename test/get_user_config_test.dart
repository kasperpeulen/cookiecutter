import 'dart:io';
import 'package:test/test.dart';
import 'package:cookiecutter/common.dart';
import 'package:cookiecutter/config.dart' as config;
import 'package:cookiecutter/exceptions.dart';

File get userConfig => new File(expandPath('~/.cookiecutterrc'));
File get userConfigBackup => new File(expandPath('~/.cookiecutterrc.backup'));

main() {
  setUp(backUpRc);
  tearDown(() {
    removeTestRc();
    restoreOriginalRc();
  });

  // Get config from a valid ~/.cookiecutterrc file
  test('get user config valid', () {
    new File('test/test-config/valid-config.yaml').copySync(userConfig.path);
    Map conf = config.getUserConfig();
    Map expectedConf = {
      'cookiecutters_dir': '/home/example/some-path-to-templates',
      'replay_dir': '/home/example/some-path-to-replay-files',
      'default_context': {
        'full_name': 'Firstname Lastname',
        'email': 'firstname.lastname@gmail.com',
        'github_username': 'example'
      }
    };
    expect(conf, expectedConf);
  });

  // Get config from an invalid ~/.cookiecutterrc file
  test("test_get_user_config_invalid", () {
    new File('test/test-config/invalid-config.yaml').copySync(userConfig.path);
    expect(() => config.getUserConfig(),
        throwsA(new isInstanceOf<InvalidConfiguration>()));
  });

  // Get config from a nonexistent ~/.cookiecutterrc file
  test("test_get_user_config_nonexistent", () {
    expect(config.getUserConfig(), config.DEFAULT_CONFIG);
  });
}


/// Back up an existing cookiecutter rc and restore it after the test.
/// If ~/.cookiecutterrc is pre-existing, move it to a temp location
backUpRc() {
  if (userConfig.existsSync()) {
    userConfig.copySync(userConfigBackup.path);
    userConfig.deleteSync();
  }
}

/// Remove the ~/.cookiecutterrc that has been created in the test.
removeTestRc() {
  if (userConfig.existsSync()) {
    userConfig.deleteSync();
  }
}

/// If it existed, restore the original ~/.cookiecutterrc
restoreOriginalRc() {
  if (userConfigBackup.existsSync()) {
    userConfigBackup.copySync(userConfig.path);
    userConfigBackup.deleteSync();
  }
}
