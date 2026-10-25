void main() {
  var s = 'Flutter Kitob';
  print(s.toUpperCase());
  print(s.toLowerCase());
  print(s.length);
  print(s[0]);
  print(s.substring(0, 7));
  print(s.substring(8));
  print(s.contains('Kit'));
  print(s.indexOf('t'));
  print(s.split(' '));
  print('  bo\'shliq  '.trim());
  print(s.replaceAll('t', 'T'));
  print(s.startsWith('Flu'));
  print('ab' * 3);
  print('5'.padLeft(3, '0'));
  print(s.isEmpty);
  print(''.isEmpty);
  print('a' + 'b');
  print('Dart'.codeUnitAt(0));
  var multi = '''Birinchi
Ikkinchi''';
  print(multi);
  print(r'Raw: $nom \n');
  print('Salom' 'Dunyo');
  print('apple'.compareTo('banana'));
  print('${1 + 2} = 3');
  print('\$ belgisi');
}
