import 'package:test/test.dart';
import 'package:cookiecutter/main.dart';

main() {
  test("abbreviation expansion", () {
    String inputDir = expandAbbreviations('foo', {
      'abbreviations': {'foo': 'bar'}
    });
    expect(inputDir, 'bar');
  });

  test("abbreviation expansion not an abbreviation", () {
    String inputDir = expandAbbreviations('baz', {
      'abbreviations': {'foo': 'bar'}
    });
    expect(inputDir, 'baz');
  });

  test("abbreviation expansion prefix", () {
    String inputDir = expandAbbreviations('xx:a', {
      'abbreviations': {'xx': '<{0}>'}
    });
    expect(inputDir, '<a>');
  });

  test("abbreviation expansion builtin", () {
    String inputDir = expandAbbreviations('gh:a', {});
    expect(inputDir, 'https://github.com/a.git');
  });

  test("abbreviation expansion override builtin", () {
    String inputDir = expandAbbreviations('gh:a', {
      'abbreviations': {'gh': '<{0}>'}
    });
    expect(inputDir, '<a>');
  });

  test("abbreviation expansion prefix ignores suffix", () {
    String inputDir = expandAbbreviations('xx:a', {
      'abbreviations': {'xx': '<>'}
    });
    expect(inputDir, '<>');
  });

  test('abbreviation expansion prefix not 0 in braces', () {
    expect(
        expandAbbreviations('xx:a', {
              'abbreviations': {'xx': '{1}'}
            }),
        throwsA(new isInstanceOf<IndexError>()));
  }, skip: true);
}
