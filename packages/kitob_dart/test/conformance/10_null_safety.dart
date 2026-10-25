String? topish(int id) => id == 1 ? 'Ali' : null;

void main() {
  String? ism = topish(1);
  String? yoq = topish(2);
  print(ism);
  print(yoq);
  print(yoq ?? 'Mehmon');
  print(ism?.length);
  print(yoq?.length);
  print(ism!.toUpperCase());
  yoq ??= 'Standart';
  print(yoq);
  int? son;
  print(son);
  son = 5;
  print(son + 1);
  if (ism != null) {
    print(ism.length);
  }
  late String keyin;
  keyin = 'tayyor';
  print(keyin);
  List<int?> l = [1, null, 3];
  print(l);
  print(l.whereType<int>().toList());
}
