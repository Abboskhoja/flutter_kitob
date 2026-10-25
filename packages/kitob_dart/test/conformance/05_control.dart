void main() {
  var ball = 85;
  if (ball >= 90) {
    print('A');
  } else if (ball >= 80) {
    print('B');
  } else {
    print('C');
  }
  for (var i = 0; i < 3; i++) {
    print('i = $i');
  }
  var j = 3;
  while (j > 0) {
    print(j);
    j--;
  }
  var k = 0;
  do {
    k += 2;
  } while (k < 7);
  print(k);
  for (var i = 1; i <= 10; i++) {
    if (i % 2 == 0) continue;
    if (i > 7) break;
    print('toq: $i');
  }
  var kun = 3;
  switch (kun) {
    case 1:
      print('Dushanba');
    case 2:
    case 3:
      print('Seshanba yoki Chorshanba');
    default:
      print('Boshqa');
  }
  var holat = ball > 50 ? 'O\'tdi' : 'Yiqildi';
  print(holat);
  outer:
  for (var a = 0; a < 3; a++) {
    for (var b = 0; b < 3; b++) {
      if (b == 2) continue outer;
      if (a == 2) break outer;
      print('$a$b');
    }
  }
}
