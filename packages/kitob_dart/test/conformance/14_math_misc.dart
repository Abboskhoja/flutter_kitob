import 'dart:math';
import 'dart:convert';

class Talaba {
  final String ism;
  final int ball;
  Talaba(this.ism, this.ball);
  Map<String, dynamic> toJson() => {'ism': ism, 'ball': ball};
}

void main() {
  print(max(3, 7));
  print(min(2.5, 1.5));
  print(sqrt(16));
  print(pow(2, 10));
  print(pow(2.0, 3));
  print(pi.toStringAsFixed(4));
  var t = [Talaba('Ali', 90), Talaba('Vali', 75)];
  t.sort((a, b) => a.ball.compareTo(b.ball));
  print(t.map((e) => e.ism).toList());
  print(jsonEncode(t.first));
  var d = jsonDecode('{"a": 1, "b": [true, null, 2.5], "c": "x"}');
  print(d);
  print(d['b'][2]);
  print(jsonEncode({'list': [1, 2], 'ok': false}));
  var buf = [1, 2, 3, 4, 5, 6];
  print(buf.where((x) => x.isEven).map((x) => x * 10).toList());
  print(identical(t[0], t[0]));
  var m = <String, List<int>>{};
  m.putIfAbsent('a', () => []).add(1);
  m.putIfAbsent('a', () => []).add(2);
  print(m);
  print(Duration(minutes: 90));
  print(Duration(seconds: 125).inMinutes);
  var cascade = <int>[]..add(1)..add(2)..addAll([3, 4]);
  print(cascade);
  print('${[1, 2]}');
  print(5.compareTo(3));
  print(['b', 'a', 'c']..sort());
  print([1.5, 2.5].map((x) => x * 2).toList());
}
