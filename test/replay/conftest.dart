import 'package:cookiecutter/config.dart' as config;

/// Fixture to return a valid context as known from a cookiecutter.json.
Map get context => {
      'cookiecutter': {
        'email': 'raphael@hackebrot.de',
        'full_name': 'Raphael Pierzina',
        'github_username': 'hackebrot',
        'version': '0.1.0'
      }
    };

String get replayTestDir => 'test/test-replay';

config.VoidToMap cacheGetUserConfig;

int mockCallCount = 0;

mockUserConfig() {
  cacheGetUserConfig = config.getUserConfig;
  Map userConfig = {}..addAll(config.DEFAULT_CONFIG);
  userConfig.addAll({'replay_dir': replayTestDir});
  config.getUserConfig = () {
    mockCallCount++;
    return userConfig;
  };
}

resetUserConfig() {
  mockCallCount = 0;
  config.getUserConfig = cacheGetUserConfig;
}