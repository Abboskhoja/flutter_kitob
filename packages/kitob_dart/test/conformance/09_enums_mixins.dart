enum Rang { qizil, yashil, kok }

enum Sayyora {
  yer(5.97),
  mars(0.642);

  final double massa;
  const Sayyora(this.massa);
  String get info => '$name: $massa';
}

mixin Uchuvchi {
  void uch() => print('Uchyapti');
}

mixin Suzuvchi {
  int chuqurlik = 10;
  void suz() => print('Suzyapti $chuqurlik m');
}

class Ordak with Uchuvchi, Suzuvchi {
  String ism = 'Ordak';
}

extension Kvadrat on int {
  int get kvadrat => this * this;
  bool bolinadimi(int n) => this % n == 0;
}

extension Matn on String {
  String get teskari => split('').reversed.join();
}

void main() {
  var r = Rang.yashil;
  print(r);
  print(r.name);
  print(r.index);
  print(Rang.values);
  switch (r) {
    case Rang.qizil:
      print('To\'xta');
    case Rang.yashil:
      print('Yur');
    case Rang.kok:
      print('Osmon');
  }
  print(Sayyora.mars.info);
  print(Sayyora.values.length);
  var o = Ordak();
  o.uch();
  o.suz();
  print(o is Uchuvchi);
  print(7.kvadrat);
  print(10.bolinadimi(5));
  print('salom'.teskari);
}
