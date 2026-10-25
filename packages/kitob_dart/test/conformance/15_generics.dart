class Quti<T> {
  T qiymat;
  Quti(this.qiymat);
  T ol() => qiymat;
  @override
  String toString() => 'Quti($qiymat)';
}

T birinchi<T>(List<T> l) => l.first;

class Juftlik<A, B> {
  final A a;
  final B b;
  Juftlik(this.a, this.b);
}

void main() {
  var q = Quti<int>(5);
  print(q.ol() + 1);
  var s = Quti('matn');
  print(s);
  print(birinchi([3, 4]));
  print(birinchi<String>(['x']));
  var j = Juftlik('a', 1);
  print('${j.a} ${j.b}');
  List<num> sonlar = [1, 2.5];
  print(sonlar);
  Map<String, List<String>> guruhlar = {'A': ['Ali'], 'B': []};
  guruhlar['B']!.add('Bek');
  print(guruhlar);
}
