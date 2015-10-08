library cookiecutter.test.get_config_test;

import 'package:test/test.dart';
import 'package:cookiecutter/config.dart' as config;
import 'package:cookiecutter/exceptions.dart';
import 'package:cookiecutter/common.dart';

main() {
  // opening and reading a config file
  test('get config', () {
    Map conf = config.getConfig('test/test-config/valid-config.yaml');
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

  // Check that `exceptions.ConfigDoesNotExistException` is raised when
  // attempting to get a non-existent config file.
  test('get config does not exist', () {
    expect(() => config.getConfig('test/test-config/this-does-not-exist.yaml'),
        throwsA(new isInstanceOf<ConfigDoesNotExistException>()));
  });

  // An invalid config file should raise an `InvalidConfiguration` exception.
  test('invalid config', () {
    expect(() => config.getConfig('test/test-config/invalid-config.yaml'),
        throwsA(new isInstanceOf<InvalidConfiguration>()));
  });

  // A config file that overrides 1 of 3 defaults
  test('get config with defaults', () {
    Map conf = config.getConfig('test/test-config/valid-partial-config.yaml');
    String defaultCookiecuttersDir = expandPath('~/.cookiecutters/');
    String defaultReplayDir = expandPath('~/.cookiecutter_replay/');
    Map expectedConf = {
      'cookiecutters_dir': defaultCookiecuttersDir,
      'replay_dir': defaultReplayDir,
      'default_context': {
        'full_name': 'Firstname Lastname',
        'email': 'firstname.lastname@gmail.com',
        'github_username': 'example'
      }
    };
    expect(conf, expectedConf);
  });
}
