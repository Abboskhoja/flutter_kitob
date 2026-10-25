import 'dart:async';

Future<int> tezXato() async {
  throw FormatException('darhol');
}

Stream<int> cheksiz() async* {
  var i = 0;
  try {
    while (true) {
      yield i++;
    }
  } finally {
    print('cheksiz: finally (bekor qilindi)');
  }
}

Future<String> ism(int id) async {
  await Future.delayed(Duration(milliseconds: id * 10));
  return 'foydalanuvchi$id';
}

class Hisob {
  int balans = 0;
  Future<void> toldir(int s) async {
    await Future.delayed(Duration(milliseconds: 5));
    balans += s;
  }
}

Future<void> main() async {
  final f = tezXato();
  f.catchError((e) {
    print('kech ulangan handler: $e');
    return 0;
  });
  await Future.delayed(Duration.zero);
  await for (final x in cheksiz()) {
    if (x == 3) break;
    print('x=$x');
  }
  print('ism: ${await ism(2)} va ${await ism(1)}');
  final royxat = [await ism(1), await ism(3)];
  print(royxat);
  if (await ism(1) == 'foydalanuvchi1') print('shart: rost');
  var n = 0;
  while (await Future.value(n < 3)) {
    n++;
  }
  print('n=$n');
  final h = Hisob();
  await h.toldir(100);
  await Future.wait([h.toldir(10), h.toldir(20)]);
  print('balans: ${h.balans}');
  final ctrl = StreamController<int>();
  ctrl.stream.listen((v) => print('qiymat $v'), onError: (e) => print('oqim xatosi: $e'), onDone: () => print('yopildi'));
  ctrl.add(1);
  ctrl.addError('nimadir buzildi');
  ctrl.add(2);
  await ctrl.close();
  final sub = Stream.periodic(Duration(milliseconds: 10), (i) => i).listen((v) => print('davriy $v'));
  await Future.delayed(Duration(milliseconds: 35));
  await sub.cancel();
  print('davriy tugadi');
  final natija = await Future.wait([
    Future.delayed(Duration(milliseconds: 20), () => 'a'),
    Future.error('b xato'),
  ]).catchError((e) => ['ushlandi: $e']);
  print(natija);
  final sw = DateTime.now();
  await Future.wait([Future.delayed(Duration(seconds: 1)), Future.delayed(Duration(seconds: 2))]);
  print('parallel: ${DateTime.now().difference(sw).inSeconds} s');
  final jami = await Stream.fromIterable([1, 2, 3]).map((x) => x * 10).reduce((a, b) => a + b);
  print('jami: $jami');
  print(await Stream.fromIterable(['a', 'b']).join('-'));
  print(await Stream.fromIterable([5, 8, 11]).firstWhere((x) => x > 6));
  print(await Stream.fromIterable([1, 2]).contains(2));
  var son = 0;
  son += await Future.value(5);
  print(son);
  try {
    await Future.delayed(Duration(milliseconds: 1), () => throw StateError('kechikkan xato'));
  } on StateError catch (e) {
    print(e.message);
  }
  print('tugadi');
}
