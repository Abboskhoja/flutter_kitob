bool tubmi(int n) {
  if (n < 2) return false;
  for (var i = 2; i * i <= n; i++) {
    if (n % i == 0) return false;
  }
  return true;
}

List<int> fibonachchi(int n) {
  var natija = <int>[0, 1];
  while (natija.length < n) {
    natija.add(natija[natija.length - 1] + natija[natija.length - 2]);
  }
  return natija.sublist(0, n);
}

int maksimal(List<int> l) {
  var m = l[0];
  for (final x in l) {
    if (x > m) m = x;
  }
  return m;
}

String teskari(String s) {
  var t = '';
  for (var i = s.length - 1; i >= 0; i--) {
    t += s[i];
  }
  return t;
}

void main() {
  print([for (var i = 1; i <= 30; i++) if (tubmi(i)) i]);
  print(fibonachchi(10));
  print(maksimal([3, 9, 2, 7]));
  print(teskari('kitob'));
  var sanoq = <String, int>{};
  for (final h in 'assalom'.split('')) {
    sanoq[h] = (sanoq[h] ?? 0) + 1;
  }
  print(sanoq);
  var yulduz = '';
  for (var i = 1; i <= 3; i++) {
    yulduz += '${'*' * i}\n';
  }
  print(yulduz);
  var sum = 0;
  for (var i = 1; i <= 100; i++) {
    sum += i;
  }
  print(sum);
  var l = [5, 2, 9, 1, 7];
  for (var i = 0; i < l.length; i++) {
    for (var j = 0; j < l.length - 1 - i; j++) {
      if (l[j] > l[j + 1]) {
        var t = l[j];
        l[j] = l[j + 1];
        l[j + 1] = t;
      }
    }
  }
  print(l);
  var sb = StringBuffer();
  sb.write('a');
  sb.write(1);
  sb.writeln('!');
  sb.write('end');
  print(sb.toString());
  print(sb.length);
}
