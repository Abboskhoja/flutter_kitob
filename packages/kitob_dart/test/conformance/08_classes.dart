class Hayvon {
  final String ism;
  int yosh;

  Hayvon(this.ism, this.yosh);

  Hayvon.chaqaloq(String ism) : this(ism, 0);

  void ovozChiqar() {
    print('$ism ovoz chiqardi');
  }

  String get tavsif => '$ism ($yosh yosh)';

  @override
  String toString() => 'Hayvon($ism, $yosh)';
}

class It extends Hayvon {
  String zot;
  It(String ism, int yosh, this.zot) : super(ism, yosh);

  @override
  void ovozChiqar() {
    print('$ism: Vov-vov!');
  }

  void yugur() => print('$ism yuguryapti');
}

abstract class Shakl {
  double yuza();
  String nomi() => 'Shakl';
}

class Doira extends Shakl {
  final double r;
  Doira(this.r);
  @override
  double yuza() => 3.14 * r * r;
  @override
  String nomi() => 'Doira';
}

class Kvadrat implements Shakl {
  final double a;
  Kvadrat(this.a);
  @override
  double yuza() => a * a;
  @override
  String nomi() => 'Kvadrat';
}

class Hisob {
  double _balans = 0;
  static int soni = 0;
  Hisob() {
    soni++;
  }
  double get balans => _balans;
  set balans(double v) {
    if (v >= 0) _balans = v;
  }
  void qoy(double summa) => _balans += summa;
}

class Nuqta {
  final int x, y;
  const Nuqta(this.x, this.y);
  Nuqta operator +(Nuqta b) => Nuqta(x + b.x, y + b.y);
  @override
  bool operator ==(Object other) => other is Nuqta && other.x == x && other.y == y;
  @override
  int get hashCode => x * 31 + y;
  @override
  String toString() => '($x, $y)';
}

void main() {
  var mushuk = Hayvon('Mosh', 3);
  mushuk.ovozChiqar();
  print(mushuk.tavsif);
  print(mushuk);
  mushuk.yosh++;
  print(mushuk.yosh);
  var kuchuk = Hayvon.chaqaloq('Bobik');
  print(kuchuk);
  var it = It('Rex', 5, 'Ovcharka');
  it.ovozChiqar();
  it.yugur();
  print(it.zot);
  print(it is Hayvon);
  print(it is It);
  print(mushuk is It);
  Hayvon h = it;
  h.ovozChiqar();
  List<Shakl> shakllar = [Doira(1), Kvadrat(2)];
  for (final s in shakllar) {
    print('${s.nomi()}: ${s.yuza()}');
  }
  var hisob = Hisob();
  Hisob();
  hisob.qoy(100);
  hisob.balans = -5;
  print(hisob.balans);
  hisob.balans = 50;
  print(hisob.balans);
  print(Hisob.soni);
  var p = Nuqta(1, 2) + Nuqta(3, 4);
  print(p);
  print(Nuqta(1, 2) == Nuqta(1, 2));
  print(p.runtimeType);
  print(Object());
}
