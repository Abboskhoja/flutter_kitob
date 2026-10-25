import 'package:kitob_dart/kitob_dart.dart';
import 'package:test/test.dart';

void main() {
  test('ushlanmagan asinxron xato dasturni to\'xtatadi (Dart VM kabi)', () {
    final r = KitobDart.run('''
Future<void> ish() async {
  await Future.delayed(Duration(milliseconds: 10));
  throw Exception('hech kim ushlamadi');
}

void main() {
  print('boshlandi');
  ish();
  Future.delayed(Duration(milliseconds: 50), () => print('bu chiqmaydi'));
}''');
    expect(r.stdout, 'boshlandi\n');
    expect(r.error, isNotNull);
    expect(r.error!.message, contains('Exception: hech kim ushlamadi'));
    expect(r.error!.line, 3);
  });

  test('to\'xtatilmagan Timer.periodic cheksiz ishlamaydi', () {
    final r = KitobDart.run('''
import 'dart:async';
void main() {
  Timer.periodic(Duration(seconds: 1), (t) {});
}''');
    expect(r.error, isNotNull);
    expect(r.error!.type, anyOf('timer_limit', 'timeout'));
  });

  test('vaqt virtual: 10 soniyalik kutish darhol tugaydi, lekin DateTime ham surildi', () {
    final sw = Stopwatch()..start();
    final r = KitobDart.run('''
Future<void> main() async {
  final t = DateTime.now();
  await Future.delayed(Duration(seconds: 10));
  print(DateTime.now().difference(t).inSeconds);
}''');
    expect(r.error, isNull, reason: r.error?.explanation);
    expect(r.stdout, '10\n');
    expect(sw.elapsed.inSeconds, lessThan(2));
  });

  test('KitobSession: await ifodasini baholash', () {
    final (s, diags, err) = KitobSession.open('''
Future<int> kvadrat(int n) async {
  await Future.delayed(Duration(milliseconds: 100));
  return n * n;
}''');
    expect(diags.where((d) => d.isError), isEmpty);
    expect(err, isNull);
    expect(s!.evaluate('await kvadrat(5)').value, '25');
    expect(s.evaluate('kvadrat(2)').typeName, 'Future<int>');
  });

  test('trace await qadamlarini ko\'rsatadi', () {
    final r = KitobDart.run('''
Future<void> main() async {
  print('a');
  await Future.delayed(Duration(seconds: 1));
  print('b');
}''', options: const ExecutionOptions(trace: true));
    expect(r.stdout, 'a\nb\n');
    final waits = r.trace.where((t) => t.kind == TraceKind.wait).toList();
    expect(waits, isNotEmpty);
    expect(waits.first.line, 3);
  });

  test('sync* dangasa: faqat so\'ralgan elementlar hisoblanadi', () {
    final r = KitobDart.run('''
Iterable<int> sonlar() sync* {
  for (var i = 1; ; i++) {
    print('hisob \$i');
    yield i;
  }
}
void main() {
  print(sonlar().take(2).toList());
}''');
    expect(r.error, isNull, reason: r.error?.explanation);
    expect(r.stdout, 'hisob 1\nhisob 2\n[1, 2]\n');
  });

  test('Completer hech qachon tugamasa dastur shunchaki tugaydi', () {
    final r = KitobDart.run('''
import 'dart:async';
Future<void> main() async {
  print('kutyapman');
  await Completer<int>().future;
  print('bu chiqmaydi');
}''');
    expect(r.error, isNull);
    expect(r.stdout, 'kutyapman\n');
  });

  test('ikkinchi marta complete — StateError', () {
    final r = KitobDart.run('''
import 'dart:async';
void main() {
  final c = Completer<int>();
  c.complete(1);
  c.complete(2);
}''');
    expect(r.error?.message, contains('Future already completed'));
  });

  test('bir obunali oqimni ikki marta tinglash — StateError', () {
    final r = KitobDart.run('''
void main() {
  final s = Stream.fromIterable([1]);
  s.listen(print);
  s.listen(print);
}''');
    expect(r.error?.message, contains('Stream has already been listened to'));
  });

  test('checker: Timer import siz — tushunarli maslahat', () {
    final d = KitobDart.analyze('void main() {\n  Timer(Duration(seconds: 1), () {});\n}');
    expect(d.first.hint, contains("import 'dart:async'"));
  });
}
