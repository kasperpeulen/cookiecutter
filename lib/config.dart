/// Global configuration handling
library cookiecutter.config;

import 'dart:io';
import 'package:yaml/yaml.dart';

import 'exceptions.dart';
import 'common.dart';

Map DEFAULT_CONFIG = {
  'cookiecutters_dir': expandPath('~/.cookiecutters/'),
  'replay_dir': expandPath('~/.cookiecutter_replay/'),
  'default_context': {}
};

/// Retrieve the config from the specified path, returning it as a config dict.
Map getConfig(String configPath) {
  File config = new File(configPath);

  if (!config.existsSync()) {
    throw new ConfigDoesNotExistException();
  }

  logging.info('configPath is $configPath');

  Map yaml;
  try {
    yaml = loadYaml(config.readAsStringSync());
  } on YamlException catch(e) {
    throw new InvalidConfiguration(configPath, e.span.start.line, e.message);
  }

  return {}..addAll(DEFAULT_CONFIG)..addAll(yaml);
}

/// Retrieve config from the user's ~/.cookiecutterrc, if it exists.
/// Otherwise, return null.
Map getUserConfig() {

  // TODO: test on windows...
  String USER_CONFIG_PATH = expandPath('~/.cookiecutterrc');
  File f = new File(USER_CONFIG_PATH);

  if (f.existsSync()) {
    return getConfig(USER_CONFIG_PATH);
  }
  return {}..addAll(DEFAULT_CONFIG);
}