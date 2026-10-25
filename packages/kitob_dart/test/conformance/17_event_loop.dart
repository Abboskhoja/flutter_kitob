import 'dart:async';

Future<void> a() async {
  print('a: boshlandi');
  await null;
  print('a: await dan keyin');
}

void main() {
  print('1 main boshlandi');
  Future(() => print('6 Future (event queue)'));
  scheduleMicrotask(() => print('4 microtask'));
  Future.delayed(Duration(milliseconds: 50), () => print('8 delayed 50ms'));
  Future.delayed(Duration.zero, () => print('7 delayed 0'));
  Future.value(1).then((v) => print('5 then: $v'));
  a().then((_) => print('a: then'));
  Timer(Duration(milliseconds: 20), () => print('7b timer 20ms'));
  Future.microtask(() => print('5b Future.microtask'));
  print('2 main tugadi');
  final c = Completer<String>();
  c.future.then((v) => print('9 completer: $v'));
  Timer(Duration(milliseconds: 100), () => c.complete('tayyor'));
  var n = 0;
  Timer.periodic(Duration(milliseconds: 30), (t) {
    n++;
    print('periodic $n tick=${t.tick}');
    if (n == 3) t.cancel();
  });
  print('3 sinxron kod tugadi');
}
