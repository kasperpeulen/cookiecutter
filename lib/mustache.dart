import 'package:cookiecutter/camelcase.dart';
import 'package:mustache4dart/mustache4dart.dart' as mustache;

const CLOSING_DELIMETER = '}}';

const OPENING_DELIMETER = '{{';
render(String template, Map context) {
  context = context..addAll({"camelcase": (String val) => camelCase(val),});
  return mustache.render(template, context,
      delimiter: new mustache.Delimiter(OPENING_DELIMETER, CLOSING_DELIMETER));
}
