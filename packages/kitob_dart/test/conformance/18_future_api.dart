import 'dart:async';

Future<int> bolish(int a, int b) async {
  if (b == 0) throw ArgumentError('nolga bo\'lib bo\'lmaydi');
  return a ~/ b;
}

Future<String> sekin() => Future.delayed(Duration(seconds: 5), () => 'kech');

void main() async {
  final r = await bolish(10, 2).then((v) => v * 3);
  print('then: $r');
  await bolish(1, 0).then((v) => print('bu chiqmaydi')).catchError((e) {
    print('catchError: $e');
  });
  await Future.value(5).whenComplete(() => print('whenComplete'));
  final t = await sekin().timeout(Duration(seconds: 1), onTimeout: () => 'vaqt tugadi');
  print(t);
  try {
    await sekin().timeout(Duration(milliseconds: 10));
  } on TimeoutException catch (e) {
    print('TimeoutException: ${e.message}');
  }
  try {
    await Future.error(StateError('yomon holat'));
  } catch (e) {
    print('xato: $e');
  }
  final tez = await Future.any([
    Future.delayed(Duration(milliseconds: 30), () => 'sekin'),
    Future.delayed(Duration(milliseconds: 10), () => 'tez'),
  ]);
  print('any: $tez');
  final c = Completer<int>();
  print('isCompleted: ${c.isCompleted}');
  Timer(Duration(milliseconds: 5), () => c.complete(42));
  print('kutildi: ${await c.future}');
  print('isCompleted: ${c.isCompleted}');
  final kech = DateTime.now();
  await Future.delayed(Duration(seconds: 2));
  print('o\'tgan vaqt: ${DateTime.now().difference(kech).inSeconds} s');
  print(Future.value(1));
  final list = await Future.wait(<Future<int>>[]);
  print(list);
  final x = await Future.sync(() => 7);
  print(x);
  var v = await (Future.value(2));
  print(v + 1);
}
