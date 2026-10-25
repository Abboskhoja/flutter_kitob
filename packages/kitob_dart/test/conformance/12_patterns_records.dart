String baho(int ball) => switch (ball) {
  >= 90 => 'A\'lo',
  >= 70 && < 90 => 'Yaxshi',
  _ => 'Qoniqarli',
};

(String, int) foydalanuvchi() => ('Ali', 20);

void main() {
  print(baho(95));
  print(baho(75));
  print(baho(10));
  var r = foydalanuvchi();
  print(r);
  print(r.$1);
  print(r.$2);
  var nomli = (ism: 'Vali', yosh: 30);
  print(nomli.ism);
  print(nomli);
  Object x = 42;
  switch (x) {
    case int n when n > 40:
      print('katta son $n');
    case String s:
      print('matn $s');
    default:
      print('boshqa');
  }
  var kun = 6;
  var tur = switch (kun) {
    6 || 7 => 'Dam olish',
    _ => 'Ish kuni',
  };
  print(tur);
}
