library cookiecutter.camelcase;

String camelCase(String string) => string
        .replaceAll(new RegExp(r'^[_.\- ]+'), '')
        .toLowerCase()
        .replaceAllMapped(new RegExp(r'[_.\- ]+(\w|$)'), (Match m) {
      return m[1].toUpperCase();
    });
