int kvadrat(int n) => n * n;

int yigindi(int a, int b) {
  return a + b;
}

String salom(String ism, {String til = 'uz'}) {
  if (til == 'en') return 'Hello, $ism';
  return 'Salom, $ism';
}

void tanishtir({required String ism, int yosh = 0}) {
  print('$ism, $yosh yosh');
}

String toliqIsm(String ism, [String? familiya]) {
  return familiya == null ? ism : '$ism $familiya';
}

int faktorial(int n) {
  if (n <= 1) return 1;
  return n * faktorial(n - 1);
}

Function hisoblagich() {
  var son = 0;
  return () {
    son++;
    return son;
  };
}

void main() {
  print(kvadrat(5));
  print(yigindi(2, 3));
  print(salom('Ali'));
  print(salom('Ali', til: 'en'));
  tanishtir(ism: 'Vali', yosh: 20);
  tanishtir(ism: 'Gani');
  print(toliqIsm('Ali'));
  print(toliqIsm('Ali', 'Valiyev'));
  print(faktorial(5));
  var h = hisoblagich();
  h();
  h();
  print(h());
  var ikkiBarobar = (int x) => x * 2;
  print(ikkiBarobar(21));
  void ichki() {
    print('ichki funksiya');
  }
  ichki();
  var fns = <Function>[];
  for (var i = 0; i < 3; i++) {
    fns.add(() => i);
  }
  print(fns.map((f) => f()).toList());
  print([1, 2, 3].map(kvadrat).toList());
}
