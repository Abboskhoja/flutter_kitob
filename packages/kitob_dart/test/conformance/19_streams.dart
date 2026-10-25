import 'dart:async';

Stream<int> sanash(int n) async* {
  for (var i = 1; i <= n; i++) {
    await Future.delayed(Duration(milliseconds: 100));
    yield i;
  }
}

Stream<String> harflar() async* {
  yield 'a';
  yield 'b';
  yield* Stream.fromIterable(['c', 'd']);
}

Iterable<int> juftlar(int max) sync* {
  for (var i = 0; i <= max; i += 2) {
    yield i;
  }
}

Iterable<int> fib() sync* {
  var a = 0, b = 1;
  while (true) {
    yield a;
    final t = a + b;
    a = b;
    b = t;
  }
}

Future<void> main() async {
  await for (final x in sanash(3)) {
    print('keldi: $x');
  }
  print(await harflar().toList());
  print(juftlar(8).toList());
  print(fib().take(10).toList());
  print(juftlar(4));
  final s = Stream.fromIterable([1, 2, 3, 4, 5, 6]);
  final kv = await s.where((x) => x.isEven).map((x) => x * x).toList();
  print(kv);
  final ctrl = StreamController<String>();
  ctrl.stream.listen((v) => print('listen: $v'), onDone: () => print('listen: tugadi'));
  ctrl.add('bir');
  ctrl.add('ikki');
  await ctrl.close();
  final b = StreamController<int>.broadcast();
  b.stream.listen((v) => print('A: $v'));
  b.stream.listen((v) => print('B: $v'));
  b.add(1);
  b.add(2);
  await b.close();
  var yigindi = 0;
  await for (final x in Stream.fromIterable([10, 20, 30])) {
    yigindi += x;
    if (x == 20) break;
  }
  print('yigindi: $yigindi');
  final tick = await Stream.periodic(Duration(milliseconds: 10), (i) => i * 10).take(4).toList();
  print(tick);
  final sub = Stream.fromIterable([1, 2, 3]).listen(null);
  sub.onDone(() {});
  print(await Stream.value('yagona').first);
  try {
    await for (final x in Stream<int>.error(FormatException('buzuq'))) {
      print(x);
    }
  } on FormatException catch (e) {
    print('stream xatosi: ${e.message}');
  }
  print(await sanash(3).length);
  print(await sanash(4).fold<int>(0, (a, b) => a + b));
}
