import 'dart:async';

Future<void> ish(String nom, int ms) async {
  print('$nom: boshlandi');
  await Future.delayed(Duration(milliseconds: ms));
  print('$nom: tugadi');
}

Future<int> zanjir() async {
  final a = await Future.value(1);
  final b = await Future(() => a + 1);
  final c = await Future.microtask(() => b + 1);
  return c;
}

Stream<int> generator() async* {
  print('gen: boshlandi');
  yield 1;
  print('gen: 1 dan keyin');
  yield 2;
  print('gen: 2 dan keyin');
}

Future<void> main() async {
  final kutish = [ish('A', 30), ish('B', 10), ish('C', 20)];
  await Future.wait(kutish);
  print('zanjir: ${await zanjir()}');
  scheduleMicrotask(() => print('m1'));
  Future.value(0).then((_) => print('then1')).then((_) => print('then2'));
  scheduleMicrotask(() => print('m2'));
  await null;
  print('await null tugadi');
  await for (final v in generator()) {
    print('olindi: $v');
  }
  final ctrl = StreamController<int>();
  final sub = ctrl.stream.listen((v) => print('data $v'));
  ctrl.add(1);
  scheduleMicrotask(() => print('mt orasida'));
  ctrl.add(2);
  await Future.delayed(Duration.zero);
  await sub.cancel();
  print('bekor qilindi');
  final r = await Future.value(10).then((v) async {
    await Future.delayed(Duration(milliseconds: 1));
    return v * 2;
  });
  print('async then: $r');
}
