class KamBalans implements Exception {
  final double kerak;
  KamBalans(this.kerak);
  @override
  String toString() => 'KamBalans: yana $kerak kerak';
}

void yech(double balans, double summa) {
  if (summa > balans) throw KamBalans(summa - balans);
  print('Yechildi: $summa');
}

void main() {
  try {
    var n = int.parse('abc');
    print(n);
  } on FormatException catch (e) {
    print('Xato: ${e.message}');
  }
  try {
    var l = [1, 2, 3];
    print(l[5]);
  } on RangeError catch (e) {
    print('RangeError ushlandi');
  }
  try {
    yech(100, 150);
  } on KamBalans catch (e) {
    print(e);
  } finally {
    print('finally doim ishlaydi');
  }
  try {
    throw Exception('Maxsus xato');
  } catch (e) {
    print(e);
  }
  try {
    throw 'oddiy matn';
  } catch (e) {
    print('Ushlandi: $e');
  }
  print(int.tryParse('12x'));
  print(int.tryParse('12'));
  try {
    print(10 ~/ 0);
  } catch (e) {
    print('nolga bo\'lish');
  }
  try {
    try {
      throw StateError('ichki');
    } catch (e) {
      print('ichki catch');
      rethrow;
    }
  } catch (e) {
    print('tashqi: $e');
  }
  try {
    [].first;
  } on StateError catch (e) {
    print(e.message);
  }
}
