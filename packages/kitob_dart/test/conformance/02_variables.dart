void main() {
  int yosh = 18;
  double boy = 1.75;
  String ism = 'Ali';
  bool talaba = true;
  var shahar = 'Toshkent';
  final yil = 2024;
  const pi = 3.14159;
  print(yosh);
  print(boy);
  print(ism);
  print(talaba);
  print(shahar);
  print(yil);
  print(pi);
  yosh = yosh + 1;
  print('Keyingi yil: $yosh');
  print('Ism uzunligi: ${ism.length}');
  print('$ism ${yosh} yoshda, bo\'yi $boy m');
  print(yosh.runtimeType);
  print(boy.runtimeType);
  print(ism.runtimeType);
}
