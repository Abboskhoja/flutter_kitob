import 'package:kitob_dart/kitob_dart.dart';
import 'package:test/test.dart';

void main() {
  test('ushlanmagan FormatException tushuntiriladi', () {
    final r = KitobDart.run("void main() {\n  print('a');\n  int.parse('abc');\n}");
    expect(r.stdout, 'a\n');
    expect(r.error!.type, 'FormatException');
    expect(r.error!.line, 3);
    expect(r.error!.explanation, contains('songa'));
  });

  test('RangeError — haqiqiy Dart xabari', () {
    final r = KitobDart.run('void main() {\n  var l = [1, 2, 3];\n  print(l[5]);\n}');
    expect(r.error!.type, 'RangeError');
    expect(r.error!.message, contains('RangeError'));
    expect(r.error!.message, contains('0..2: 5'));
    expect(r.error!.line, 3);
  });

  test('cheksiz sikl to\'xtatiladi', () {
    final r = KitobDart.run('void main() {\n  var i = 0;\n  while (i < 5) {\n    print(i);\n  }\n}',
        options: const ExecutionOptions(maxSteps: 20000));
    expect(r.error, isNotNull);
    expect(r.error!.type, anyOf('timeout', 'output_limit'));
  });

  test('cheksiz rekursiya — Stack Overflow', () {
    final r = KitobDart.run('int f(int n) => f(n + 1);\nvoid main() {\n  f(0);\n}');
    expect(r.error!.type, 'stack_overflow');
  });

  test('stdin kiritish', () {
    final r = KitobDart.run(
        "import 'dart:io';\nvoid main() {\n  var ism = stdin.readLineSync();\n  print('Salom, \$ism!');\n}",
        options: const ExecutionOptions(stdin: ['Aziz']));
    expect(r.stdout, 'Salom, Aziz!\n');
  });

  test('null check xatosi', () {
    final r = KitobDart.run('void main() {\n  String? s;\n  print(s!.length);\n}');
    expect(r.error!.type, 'TypeError');
    expect(r.error!.message, contains('Null check'));
  });

  test('trace — o\'zgaruvchi qadamlari haqiqiy', () {
    final r = KitobDart.run('void main() {\n  int yosh = 18;\n  yosh = yosh + 1;\n  print(yosh);\n}',
        options: const ExecutionOptions(trace: true));
    expect(r.success, isTrue);
    final kinds = r.trace.map((t) => t.kind).toList();
    expect(kinds.first, TraceKind.start);
    expect(kinds, containsAllInOrder([TraceKind.declare, TraceKind.assign, TraceKind.output, TraceKind.end]));
    final decl = r.trace.firstWhere((t) => t.kind == TraceKind.declare);
    expect(decl.line, 2);
    expect(decl.vars.single.name, 'yosh');
    expect(decl.vars.single.value, '18');
    final assign = r.trace.firstWhere((t) => t.kind == TraceKind.assign);
    expect(assign.vars.single.value, '19');
    expect(assign.changed, ['yosh']);
  });

  test('trace — for sikli aylanishlari', () {
    final r = KitobDart.run('void main() {\n  for (var i = 0; i < 3; i++) {\n    print(i);\n  }\n}',
        options: const ExecutionOptions(trace: true));
    final loops = r.trace.where((t) => t.kind == TraceKind.loop).toList();
    expect(loops.length, 4); // 3 marta true + 1 marta false
    expect(loops.last.description, contains('false'));
  });

  test('JSON bo\'yicha natija uzatiladi (isolate uchun)', () {
    final r = KitobDart.run('void main() { print(1); }', options: const ExecutionOptions(trace: true));
    final back = ExecutionResult.fromJson(r.toJson());
    expect(back.stdout, r.stdout);
    expect(back.trace.length, r.trace.length);
  });

  test('KitobSession — funksiyani test qilish', () {
    final (s, diags, err) = KitobSession.open('int kvadrat(int n) {\n  return n * n;\n}');
    expect(diags.where((d) => d.isError), isEmpty);
    expect(err, isNull);
    expect(s!.evaluate('kvadrat(4)').value, '16');
    expect(s.evaluate('kvadrat(-3)').value, '9');
  });

  test('tezlik: 1 million amal', () {
    final sw = Stopwatch()..start();
    final r = KitobDart.run('void main() {\n  var s = 0;\n  for (var i = 0; i < 200000; i++) {\n    s += i % 7;\n  }\n  print(s);\n}');
    sw.stop();
    expect(r.stdout, '599994\n');
    // ignore: avoid_print
    print('200k iteratsiya: ${sw.elapsedMilliseconds} ms');
  });

  test('formatlash', () {
    const messy = 'void main() {\nvar x = 1;\n    if (x > 0) {\nprint(\'{ ichida }\');\n}\nswitch (x) {\ncase 1:\nprint(1);\ndefault:\nprint(2);\n}\n\n\n\n}\n';
    expect(formatDart(messy), "void main() {\n  var x = 1;\n  if (x > 0) {\n    print('{ ichida }');\n  }\n  switch (x) {\n    case 1:\n      print(1);\n    default:\n      print(2);\n  }\n}\n");
  });

  test('highlighter yarim kodda ham ishlaydi', () {
    for (final s in ["void main() { print('yopilmagan", 'class A { int x = ', r"'${a + ", '/* izoh']) {
      final t = highlightDart(s);
      expect(t, isNotEmpty);
      expect(t.last.end, lessThanOrEqualTo(s.length));
    }
  });
}
