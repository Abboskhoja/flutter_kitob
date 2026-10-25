import 'dart:io';

import 'package:kitob_dart/kitob_dart.dart';
import 'package:test/test.dart';

import 'negative_expected.dart';

void main() {
  group('haqiqiy Dart rad etadigan kod checker tomonidan ham rad etiladi', () {
    final files = Directory('test/negative').listSync().whereType<File>().where((f) => f.path.endsWith('.dart')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      final name = f.uri.pathSegments.last.replaceAll('.dart', '');
      test(name, () {
        final diags = KitobDart.analyze(f.readAsStringSync()).where((d) => d.isError).toList();
        expect(diags, isNotEmpty, reason: 'xato topilmadi');
        final line = expectedErrorLines[name]!;
        expect(diags.map((d) => d.line), contains(line), reason: diags.join('\n'));
        for (final d in diags) {
          expect(d.message, isNotEmpty);
          expect(d.original, isNotEmpty);
        }
      });
    }
  });

  group('to\'g\'ri kod — yolg\'on xato yo\'q', () {
    final ok = <String, String>{
      'promotion': '''
void main() {
  String? s = null;
  if (s != null) print(s.length);
  if (s == null) return;
  print(s.length);
}''',
      'early_exit': '''
int uzunlik(String? s) {
  if (s == null) {
    return 0;
  }
  return s.length;
}
void main() { print(uzunlik('abc')); }''',
      'and_promotion': '''
void main() {
  String? s = 'x';
  if (s != null && s.isNotEmpty) print(s);
  print(s == null || s.isEmpty);
}''',
      'int_to_double_literal': '''
void main() {
  double d = 5;
  List<double> l = [1, 2.5];
  print(d + l.first);
}''',
      'switch_exhaustive_return': '''
enum R { a, b }
String f(R r) {
  switch (r) {
    case R.a:
      return 'A';
    case R.b:
      return 'B';
  }
}
void main() { print(f(R.a)); }''',
      'while_true': '''
int f() {
  var i = 0;
  while (true) {
    i++;
    if (i > 3) return i;
  }
}
void main() { print(f()); }''',
      'throw_end': '''
int f(int x) {
  if (x > 0) return x;
  throw ArgumentError('manfiy');
}
void main() { print(f(1)); }''',
      'assign_promotes': '''
void main() {
  int? a;
  a = 5;
  print(a + 1);
}''',
      'lambda_params': '''
void main() {
  var l = ['a', 'bb'];
  print(l.map((s) => s.length).toList());
  l.forEach((s) => print(s.toUpperCase()));
  var m = {'a': 1};
  m.forEach((k, v) => print(k.length + v));
}''',
    };
    ok.forEach((name, src) {
      test(name, () {
        final errors = KitobDart.analyze(src).where((d) => d.isError).toList();
        expect(errors, isEmpty, reason: errors.join('\n'));
        final r = KitobDart.run(src);
        expect(r.error, isNull, reason: r.error?.message);
      });
    });
  });
}
