import 'package:test/test.dart';
import 'package:cookiecutter/generate.dart' as generate;

main() {
  // Test the generated context for several input parameters against the
  // according expected context.
  test('generate context', () {
    Map context = generate.generateContext(
        contextFile: 'test/test-generate-context/test.json');
    Map expContext = {
      'test': {'1': 2, 'some_key': 'some_val'}
    };
    expect(context, expContext);
  });

  test('generate context with default', () {
    Map context = generate.generateContext(
        contextFile: 'test/test-generate-context/test.json', defaultContext: {'1': 3});
    Map expContext = {
      'test': {'1': 3, 'some_key': 'some_val'}
    };
    expect(context, expContext);
  });

  test('generate context with extra', () {
    Map context = generate.generateContext(
        contextFile: 'test/test-generate-context/test.json', extraContext:  {'1': 4});
    Map expContext =         {
      'test': {'1': 4, 'some_key': 'some_val'}
    };
    expect(context, expContext);
  });

  test('generate context with default and extra', () {
    Map context = generate.generateContext(
        contextFile: 'test/test-generate-context/test.json', defaultContext: {'1': 3}, extraContext:  {'1': 5});
    Map expContext =         {
      'test': {'1': 5, 'some_key': 'some_val'}
    };
    expect(context, expContext);
  });

  test('test choices', testChoices);

  test('apply overwrites does include unused variables',
      applyOverwriteDoesIncludeUnusedVariables);

  test('apply overwrites sets non list value', applyOverwriteSetsNonListValue);

  test('apply overwrites sets default for choice variable',
      applyOverwriteSetsDefaultForChoiceVariable);
}

Map get defaultContext => {
  'not_in_template': 'foobar',
  'project_name': 'Kivy Project',
  'orientation': 'landscape'
};

Map get extraContext =>
    {'also_not_in_template': 'foobar2', 'github_username': 'hackebrot'};

String get contextFile => 'test/test-generate-context/choices_template.json';

Map get templateContext => {
  'full_name': 'Raphael Pierzina',
  'github_username': 'hackebrot',
  'project_name': 'Kivy Project',
  'repo_name': '{{cookiecutter.project_name|lower}}',
  'orientation': ['all', 'landscape', 'portrait']
};

testChoices() {
  Map expectedContext = {
    'choices_template': {
      'full_name': 'Raphael Pierzina',
      'github_username': 'hackebrot',
      'project_name': 'Kivy Project',
      'repo_name': '{{cookiecutter.project_name|lower}}',
      'orientation': ['landscape', 'all', 'portrait'],
    }
  };

  Map generatedContext = generate.generateContext(
      contextFile: contextFile,
      defaultContext: defaultContext,
      extraContext: extraContext);

  expect(generatedContext, expectedContext);
}

applyOverwriteDoesIncludeUnusedVariables() {
  Map template = templateContext;
  generate.applyOverwritesToContext(template, {'not in teplate': 'foobar'});
  expect('not in template', isNot(isIn(template)));
}

applyOverwriteSetsNonListValue() {
  Map template = templateContext;
  generate.applyOverwritesToContext(template, {'repo_name': 'foobar'});

  expect(template['repo_name'], 'foobar');
}

applyOverwriteSetsDefaultForChoiceVariable() {
  Map template = templateContext;
  generate.applyOverwritesToContext(template, {'orientation': 'landscape'});
  expect(template['orientation'], ['landscape', 'all', 'portrait']);
}
