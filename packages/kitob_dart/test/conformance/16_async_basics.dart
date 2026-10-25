Future<int> kvadrat(int n) async {
  await Future.delayed(Duration(milliseconds: 100));
  return n * n;
}

Future<String> salom(String ism) async => 'Salom, $ism!';

Future<void> xato() async {
  await Future.delayed(Duration(milliseconds: 10));
  throw Exception('server javob bermadi');
}

Future<void> main() async {
  print('1. boshlandi');
  final k = await kvadrat(7);
  print('2. kvadrat: $k');
  print(await salom('Ali'));
  try {
    await xato();
  } catch (e) {
    print('3. ushlandi: $e');
  } finally {
    print('4. finally');
  }
  final f = kvadrat(3);
  print(f is Future<int>);
  print(await f);
  var jami = 0;
  for (var i = 1; i <= 3; i++) {
    jami += await kvadrat(i);
  }
  print('jami: $jami');
  final natijalar = await Future.wait([kvadrat(2), kvadrat(4), Future.value(10)]);
  print(natijalar);
  final ism = await Future.value('Vali');
  print(ism.toUpperCase());
  print('oxiri');
}
