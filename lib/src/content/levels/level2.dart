import 'package:flutter/material.dart';

import '../model.dart';

const level2Lessons = <Lesson>[
  // ───────────────────────── 2.1 ─────────────────────────
  Lesson(
    id: 'l2_if',
    title: 'if, else va else if',
    subtitle: 'Dastur qanday qaror qabul qiladi',
    icon: Icons.alt_route_rounded,
    minutes: 14,
    skills: ['dart.if'],
    prerequisites: ['bool va taqqoslash'],
    objectives: [
      '`if` bilan shartli kod yozasiz',
      '`else` va `else if` zanjirlarini tuzasiz',
      'Ichma-ich shartlar va mantiqiy operatorlarni birlashtirasiz',
    ],
    intro: [
      ParaBlock('**`if`** — "agar shart rost bo\'lsa, shu blokni bajar". Shart doim `bool` bo\'lishi kerak.'),
      ParaBlock('**`else`** — "aks holda". Shart yolg\'on bo\'lsa bajariladi.'),
      ParaBlock('**`else if`** — bir nechta shartni ketma-ket tekshirish. Dart yuqoridan pastga qaraydi va **birinchi rost** shartning blokini bajaradi, qolganlari o\'tkazib yuboriladi.'),
      CalloutBlock(CalloutKind.info, 'Tartib muhim', '`else if` zanjirida kattaroq shartlarni yuqoriga yozing: avval `>= 90`, keyin `>= 70`. Aks holda 95 ball ham "70 dan yuqori" bo\'lib qoladi.'),
    ],
    analogy: AnalogyBlock(
      'Svetofor',
      'Haydovchi: AGAR yashil bo\'lsa — yuradi, AKS HOLDA AGAR sariq bo\'lsa — sekinlashadi, AKS HOLDA — to\'xtaydi. Bu aynan if / else if / else zanjiri.',
      icon: Icons.traffic_rounded,
    ),
    why: 'Shartlarsiz dastur doim bir xil ishlaydi. Login, chegirmalar, baholash, xatolarni tekshirish — hammasi if bilan.',
    where: [
      'Parol tekshirish: `if (parol == togri)`',
      'Baholash tizimi: A/B/C',
      'Flutter: `if (yuklanmoqda) return CircularProgressIndicator();`',
    ],
    terms: [
      TermBlock(term: 'Condition', uz: 'Shart', meaning: 'true yoki false bo\'ladigan ifoda.', why: 'Qaror qabul qilish uchun.', example: 'yosh >= 18'),
      TermBlock(term: 'Branch', uz: 'Tarmoq', meaning: 'Shartga qarab tanlanadigan kod yo\'li.', why: 'Turli vaziyatlar uchun turli kod.'),
      TermBlock(term: 'Block', uz: 'Blok', meaning: '{ } ichidagi buyruqlar guruhi.', why: 'Bir nechta buyruqni birga bajarish.'),
    ],
    animation: AnimationBlock('if_branch', 'Shart rost — chap yo\'l, yolg\'on — o\'ng yo\'l. Qiymatni o\'zgartirib ko\'ring.'),
    syntax: SyntaxBlock(r'''if (shart1) {
  // shart1 rost bo'lsa
} else if (shart2) {
  // shart2 rost bo'lsa
} else {
  // hech biri rost bo'lmasa
}''', [
      SyntaxPart('if (shart)', 'shart true bo\'lsa blok bajariladi'),
      SyntaxPart('else if', 'oldingi shart false bo\'lsa, yangi shart'),
      SyntaxPart('else', 'hech qaysi shart bajarilmasa'),
    ]),
    example: CodeBlock(
      r'''void main() {
  int ball = 78;

  if (ball >= 90) {
    print("A'lo — 5");
  } else if (ball >= 70) {
    print('Yaxshi — 4');
  } else if (ball >= 50) {
    print('Qoniqarli — 3');
  } else {
    print('Qayta topshirish');
  }

  if (ball >= 50 && ball < 90) {
    print("O'qishni davom ettiring!");
  }
}''',
      title: 'Baholash tizimi',
      explain: {
        'if': 'Agar qavs ichidagi shart true bo\'lsa — blok bajariladi.',
        'else': 'Aks holda.',
        '>=': 'Katta yoki teng.',
        '&&': 'Ikkala shart ham bajarilishi kerak.',
      },
      expectedOutput: "Yaxshi — 4\nO'qishni davom ettiring!\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int harorat = 30;
  if (harorat = 30) {
    print('Issiq');
  }
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Tuzating.',
      why: 'Shart ichida `=` (qiymat berish) yozilgan. Taqqoslash uchun `==` kerak. Dart shart `bool` bo\'lishini talab qiladi.',
      fixed: r'''void main() {
  int harorat = 30;
  if (harorat == 30) {
    print('Issiq');
  }
}''',
      hint: 'Taqqoslash operatorini eslang.',
    ),
    task: CodeTask(
      title: 'Juft yoki toq, musbat yoki manfiy',
      instructions: 'Kiritilgan son uchun quyidagini chiqaring:\n- 0 bo\'lsa: `Nol`\n- musbat juft: `Musbat juft`\n- musbat toq: `Musbat toq`\n- manfiy: `Manfiy`\nSon `stdin` dan keladi.',
      starter: r'''import 'dart:io';

void main() {
  int son = int.parse(stdin.readLineSync() ?? '0');
  // shartlarni yozing
}''',
      checks: [
        OutputEquals('Musbat juft\n', stdin: ['8'], label: '8 → Musbat juft'),
        OutputEquals('Musbat toq\n', stdin: ['7'], label: '7 → Musbat toq'),
        OutputEquals('Nol\n', stdin: ['0'], hidden: true),
        OutputEquals('Manfiy\n', stdin: ['-3'], hidden: true),
        UsesConstruct(r'else\s+if', '`else if` ishlatilishi kerak'),
      ],
      hints: [
        'Avval son == 0 ni tekshiring.',
        'Juftlik: son % 2 == 0',
        r'''if (son == 0) {
  print('Nol');
} else if (son > 0 && son % 2 == 0) {''',
      ],
      solution: r'''import 'dart:io';

void main() {
  int son = int.parse(stdin.readLineSync() ?? '0');
  if (son == 0) {
    print('Nol');
  } else if (son > 0 && son % 2 == 0) {
    print('Musbat juft');
  } else if (son > 0) {
    print('Musbat toq');
  } else {
    print('Manfiy');
  }
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var x = 15;
  if (x > 10) {
    print('A');
  } else if (x > 5) {
    print('B');
  } else {
    print('C');
  }
}''',
        options: ['A', 'B', 'A\nB', 'C'],
        explanation: 'Birinchi rost shart (x > 10) bajariladi, qolganlari tekshirilmaydi.',
        topic: 'else if',
      ),
      FindBug(
        prompt: 'Mantiqiy xato qaysi qatorda? (95 ball "A" bo\'lishi kerak)',
        code: r'''void main() {
  var ball = 95;
  if (ball >= 70) {
    print('B');
  } else if (ball >= 90) {
    print('A');
  }
}''',
        bugLine: 3,
        explanation: 'Kichik shart (>= 70) birinchi turibdi, 95 ham unga mos keladi. Avval >= 90 tekshirilishi kerak.',
        topic: 'Shartlar tartibi',
      ),
      TrueFalse(
        prompt: 'Dartda `if (1) { }` yozish mumkin.',
        answer: false,
        explanation: 'Dartda shart faqat bool bo\'ladi. `if (1)` — xato (JavaScript dan farqli).',
        topic: 'if',
      ),
    ],
    summary: [
      'if (shart) { } — shart true bo\'lsa',
      'else if — keyingi shart, else — qolgan holat',
      'Birinchi rost shart bajariladi',
      'Shart doim bool; = emas, == ishlating',
    ],
    next: 'Ko\'p variantli tanlov uchun qulayroq vosita — switch ni o\'rganamiz.',
    revisionTip: 'Hafta kuni raqamiga (1-7) qarab "Ish kuni" yoki "Dam olish" chiqaradigan dastur yozing.',
    links: [DocLink('Branches', 'https://dart.dev/language/branches')],
  ),

  // ───────────────────────── 2.2 ─────────────────────────
  Lesson(
    id: 'l2_switch',
    title: 'switch va pattern',
    subtitle: 'Ko\'p variantdan birini tanlash',
    icon: Icons.call_split_rounded,
    minutes: 13,
    skills: ['dart.switch'],
    prerequisites: ['if, else va else if'],
    objectives: [
      '`switch` bayonoti bilan ko\'p tarmoqli tanlov yozasiz',
      'Dart 3 `switch` ifodasini (`=>`) ishlatasiz',
      'Relational va `||` patternlarini qo\'llaysiz',
    ],
    intro: [
      ParaBlock('Bitta qiymatni ko\'p variant bilan solishtirish kerak bo\'lsa, uzun `else if` zanjiri o\'rniga **`switch`** qulayroq.'),
      ParaBlock('Dart 3 da har bir `case` avtomatik tugaydi — `break` yozish shart emas. Bir nechta `case` ni ketma-ket yozsangiz, ular bitta blokni bo\'lishadi. `default` — hech biri mos kelmasa.'),
      HeadingBlock('switch ifodasi (Dart 3)'),
      ParaBlock('Qiymat qaytaruvchi qisqa shakl: `var nom = switch (kun) { 1 => \'Dushanba\', 2 => \'Seshanba\', _ => \'Noma\\\'lum\' };` Bu yerda `_` — "qolgan hamma narsa".'),
      ParaBlock('Patternlar: `>= 90` (relational), `6 || 7` (yoki), `>= 70 && < 90` (va).'),
    ],
    analogy: AnalogyBlock(
      'Lift tugmalari',
      'Liftda har bir tugma — bitta case: 1 bosilsa 1-qavat, 5 bosilsa 5-qavat. Mavjud bo\'lmagan qavat bosilsa — default: "Bunday qavat yo\'q".',
      icon: Icons.elevator_outlined,
    ),
    animation: AnimationBlock('switch_lanes', 'Qiymat `case` larni birma-bir tekshirib, mos keladigan yo\'lakka tushadi.'),
    why: 'Menyular, holatlar (yuklanmoqda / tayyor / xato), buyruqlar — switch bilan toza va xatosiz yoziladi. Dart hatto enum uchun barcha holatlar qamrab olinganini tekshiradi.',
    where: [
      'Navigatsiya tablari: indeksga qarab sahifa',
      'API holati: loading / success / error',
      'Kalkulyator: operator belgisiga qarab amal',
    ],
    terms: [
      TermBlock(term: 'switch', uz: 'Tanlash operatori', meaning: 'Qiymatni bir nechta variant bilan solishtiradi.', why: 'Uzun if zanjiridan qulay.'),
      TermBlock(term: 'case', uz: 'Holat', meaning: 'Bitta variant.', why: 'Har bir qiymat uchun alohida kod.'),
      TermBlock(term: 'Pattern', uz: 'Andoza', meaning: 'Qiymat mos kelishini tekshiruvchi shakl.', why: 'Murakkab moslashtirish uchun.', example: '>= 90, 6 || 7, _'),
    ],
    example: CodeBlock(
      r'''void main() {
  var amal = '*';
  var a = 6;
  var b = 3;

  switch (amal) {
    case '+':
      print(a + b);
    case '-':
      print(a - b);
    case '*':
      print(a * b);
    case '/':
      print(a / b);
    default:
      print("Noma'lum amal");
  }

  var kun = 6;
  var tur = switch (kun) {
    6 || 7 => 'Dam olish kuni',
    >= 1 && <= 5 => 'Ish kuni',
    _ => "Noto'g'ri kun",
  };
  print(tur);
}''',
      title: 'switch bayonoti va ifodasi',
      explain: {
        'switch': 'Qavs ichidagi qiymat case lar bilan solishtiriladi.',
        'case': 'Mos kelsa, shu blok bajariladi (break shart emas).',
        'default': 'Hech qaysi case mos kelmasa.',
        '=>': 'switch ifodasida natija qiymat.',
        '_': 'Wildcard — qolgan barcha holatlar.',
        '||': 'Pattern ichida "yoki".',
      },
      expectedOutput: '18\nDam olish kuni\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var rang = 'yashil';
  var harakat = switch (rang) {
    'qizil' => "To'xta",
    'sariq' => 'Tayyorlan',
    'yashil' => 'Yur'
    _ => 'Xato',
  };
  print(harakat);
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Tuzating.',
      why: 'switch ifodasida har bir holat vergul bilan ajratiladi. `\'Yur\'` dan keyin `,` yetishmayapti.',
      fixed: r'''void main() {
  var rang = 'yashil';
  var harakat = switch (rang) {
    'qizil' => "To'xta",
    'sariq' => 'Tayyorlan',
    'yashil' => 'Yur',
    _ => 'Xato',
  };
  print(harakat);
}''',
    ),
    task: CodeTask(
      title: 'Oy nomi',
      instructions: '`oyNomi(int oy)` funksiyasi berilgan raqam uchun fasl nomini qaytarsin (switch ifodasi bilan):\n- 12, 1, 2 → `Qish`\n- 3, 4, 5 → `Bahor`\n- 6, 7, 8 → `Yoz`\n- 9, 10, 11 → `Kuz`\n- boshqa → `Xato`',
      starter: r'''String oyNomi(int oy) {
  return switch (oy) {
    _ => 'Xato',
  };
}

void main() {
  print(oyNomi(1));
  print(oyNomi(7));
}''',
      checks: [
        EvaluatesTo('oyNomi(1)', 'Qish'),
        EvaluatesTo('oyNomi(4)', 'Bahor'),
        EvaluatesTo('oyNomi(8)', 'Yoz', hidden: true),
        EvaluatesTo('oyNomi(10)', 'Kuz', hidden: true),
        EvaluatesTo('oyNomi(12)', 'Qish', hidden: true),
        EvaluatesTo('oyNomi(13)', 'Xato', hidden: true),
        UsesConstruct(r'switch', '`switch` ishlatilishi kerak'),
      ],
      hints: ['12 || 1 || 2 => \'Qish\',', 'Har bir fasl uchun bitta qator yozing.', r'''12 || 1 || 2 => 'Qish',
3 || 4 || 5 => 'Bahor','''],
      solution: r'''String oyNomi(int oy) {
  return switch (oy) {
    12 || 1 || 2 => 'Qish',
    3 || 4 || 5 => 'Bahor',
    6 || 7 || 8 => 'Yoz',
    9 || 10 || 11 => 'Kuz',
    _ => 'Xato',
  };
}

void main() {
  print(oyNomi(1));
  print(oyNomi(7));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var x = 2;
  switch (x) {
    case 1:
      print('bir');
    case 2:
    case 3:
      print('ikki yoki uch');
    default:
      print('boshqa');
  }
}''',
        options: ['ikki yoki uch', 'ikki yoki uch\nboshqa', 'bir', 'boshqa'],
        explanation: 'Dart 3 da case avtomatik tugaydi, boshqa holatga "tushib ketmaydi".',
        topic: 'switch',
      ),
      SingleChoice(
        prompt: 'switch ifodasida `_` nimani bildiradi?',
        options: ['Bo\'sh qiymat', 'Qolgan barcha holatlar', 'Xato', 'Birinchi holat'],
        correct: 1,
        explanation: '`_` — wildcard pattern, default ga o\'xshaydi.',
        topic: 'Pattern',
      ),
    ],
    summary: [
      'switch — bitta qiymatni ko\'p variant bilan solishtirish',
      'Dart 3: case avtomatik tugaydi, break ixtiyoriy',
      'switch ifodasi: `qiymat => natija,` va `_`',
      'Patternlar: >= 90, 6 || 7, >= 1 && <= 5',
    ],
    next: 'Endi takrorlash — for sikli bilan bir xil ishni ko\'p marta bajarishni o\'rganamiz.',
    revisionTip: 'if-else bilan yozgan baholash dasturingizni switch ifodasi bilan qayta yozing.',
  ),

  // ───────────────────────── 2.3 ─────────────────────────
  Lesson(
    id: 'l2_for',
    title: 'for sikli',
    subtitle: 'Bir xil ishni ko\'p marta bajarish',
    icon: Icons.loop_rounded,
    minutes: 15,
    xp: 60,
    skills: ['dart.for'],
    prerequisites: ['Operatorlar to\'plami'],
    objectives: [
      'Klassik `for` siklini 3 qismi bilan yozasiz',
      'Har bir iteratsiyada nima bo\'lishini qadam-baqadam kuzatasiz',
      'Yig\'indi, ko\'paytma, sanash kabi algoritmlarni sikl bilan yechasiz',
    ],
    intro: [
      ParaBlock('**Sikl** (loop) — kodni bir necha marta takrorlash. 100 marta `print` yozish o\'rniga sikl ishlatamiz.'),
      ParaBlock('`for (var i = 0; i < 5; i++) { ... }` — 3 qismdan iborat:'),
      BulletsBlock([
        '**Boshlash**: `var i = 0` — hisoblagich yaratiladi (bir marta)',
        '**Shart**: `i < 5` — har aylanishdan oldin tekshiriladi; false bo\'lsa sikl tugaydi',
        '**Qadam**: `i++` — har aylanishdan keyin bajariladi',
      ], ordered: true),
      ParaBlock('Har bir aylanish **iteratsiya** deyiladi. Yuqoridagi sikl `i = 0, 1, 2, 3, 4` uchun 5 marta ishlaydi.'),
      ParaBlock('**for-in** — ro\'yxat elementlarini bittalab aylanish: `for (final meva in mevalar) { print(meva); }`'),
    ],
    analogy: AnalogyBlock(
      'Zinapoyadan chiqish',
      '1-zinadan boshlaysiz (boshlash), 10-zinaga yetmaguningizcha (shart) har safar bitta zina ko\'tarilasiz (qadam). Har bir qadam — bitta iteratsiya.',
      icon: Icons.stairs_outlined,
    ),
    why: 'Ro\'yxatdagi barcha mahsulotlarni ko\'rsatish, ballarni yig\'ish, ma\'lumotni qidirish — sikllar dasturlashning eng ko\'p ishlatiladigan vositasi.',
    where: [
      'Savatchadagi narxlar yig\'indisi',
      'Flutter: `ListView` elementlarini qurish',
      'Jadval chiqarish, qidirish, saralash',
    ],
    terms: [
      TermBlock(term: 'Loop', uz: 'Sikl', meaning: 'Kodni takroriy bajarish.', why: 'Takrorlanuvchi ishlar uchun.'),
      TermBlock(term: 'Iteration', uz: 'Iteratsiya (aylanish)', meaning: 'Siklning bitta bajarilishi.', why: 'Sikl nechta marta ishlashini tushunish uchun.'),
      TermBlock(term: 'Counter', uz: 'Hisoblagich', meaning: 'Har iteratsiyada o\'zgaradigan o\'zgaruvchi (i).', why: 'Sikl qachon tugashini boshqaradi.'),
      TermBlock(term: 'Accumulator', uz: 'Yig\'uvchi o\'zgaruvchi', meaning: 'Natija yig\'iladigan o\'zgaruvchi (jami).', why: 'Yig\'indi, ko\'paytma uchun.'),
    ],
    animation: AnimationBlock('loop_for', 'i = 0 dan boshlab har iteratsiyada shart tekshiriladi va i oshadi.'),
    syntax: SyntaxBlock(r'''for (boshlash; shart; qadam) {
  // takrorlanadigan kod
}''', [
      SyntaxPart('boshlash', 'bir marta: var i = 0'),
      SyntaxPart('shart', 'har aylanishdan oldin: i < n'),
      SyntaxPart('qadam', 'har aylanishdan keyin: i++'),
    ]),
    example: CodeBlock(
      r'''void main() {
  for (var i = 1; i <= 3; i++) {
    print('Salom #$i');
  }

  var jami = 0;
  for (var i = 1; i <= 5; i++) {
    jami += i;
  }
  print("1 dan 5 gacha yig'indi: $jami");
}''',
      title: 'Takrorlash va yig\'indi',
      explain: {
        'for': 'Sikl kalit so\'zi.',
        'var i = 1': 'Hisoblagich 1 dan boshlanadi.',
        'i <= 3': 'Shart: i 3 dan oshmaguncha davom etadi.',
        'i++': 'Har aylanishdan keyin i 1 ga oshadi.',
        'jami': 'Yig\'uvchi o\'zgaruvchi — har aylanishda i qo\'shiladi.',
        '+=': 'jami = jami + i.',
      },
      lineNotes: {2: '3 marta takrorlanadi', 7: 'jami: 1, 3, 6, 10, 15'},
      expectedOutput: "Salom #1\nSalom #2\nSalom #3\n1 dan 5 gacha yig'indi: 15\n",
      visualize: true,
    ),
    examples: [
      CodeBlock(
        r'''void main() {
  var mevalar = ['olma', 'anor', 'uzum'];
  for (final meva in mevalar) {
    print('Men $meva yaxshi ko\'raman');
  }

  for (var i = 1; i <= 5; i++) {
    print('3 x $i = ${3 * i}');
  }
}''',
        title: 'for-in va ko\'paytirish jadvali',
        expectedOutput: "Men olma yaxshi ko'raman\nMen anor yaxshi ko'raman\nMen uzum yaxshi ko'raman\n3 x 1 = 3\n3 x 2 = 6\n3 x 3 = 9\n3 x 4 = 12\n3 x 5 = 15\n",
        visualize: true,
      ),
    ],
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  // 1 dan 5 gacha sonlarni chiqarish kerak
  for (var i = 1; i < 5; i++) {
    print(i);
  }
}''',
      task: 'Sikl 1 dan 5 gacha (5 ham kirsin) chiqarishi kerak, lekin 5 chiqmayapti. Tuzating.',
      why: '`i < 5` sharti i = 5 bo\'lganda false bo\'ladi. 5 ni ham kiritish uchun `i <= 5` kerak. Bu "bittaga xato" (off-by-one) deb ataladi — eng mashhur xatolardan biri.',
      fixed: r'''void main() {
  // 1 dan 5 gacha sonlarni chiqarish kerak
  for (var i = 1; i <= 5; i++) {
    print(i);
  }
}''',
      hint: 'Shartdagi taqqoslash operatoriga qarang.',
    ),
    task: CodeTask(
      title: 'Faktorial',
      instructions: '`faktorial(int n)` funksiyasini **for sikli** bilan yozing: `n! = 1 × 2 × ... × n`.\nMasalan: `faktorial(5)` → `120`, `faktorial(0)` → `1`.',
      starter: r'''int faktorial(int n) {
  var natija = 1;
  // for sikli yozing
  return natija;
}

void main() {
  print(faktorial(5));
}''',
      checks: [
        EvaluatesTo('faktorial(5)', '120'),
        EvaluatesTo('faktorial(1)', '1'),
        EvaluatesTo('faktorial(0)', '1', hidden: true),
        EvaluatesTo('faktorial(10)', '3628800', hidden: true),
        UsesConstruct(r'for\s*\(', '`for` sikli ishlatilishi kerak'),
      ],
      hints: [
        'i ni 1 dan n gacha aylantiring.',
        'Har aylanishda natija *= i;',
        r'''for (var i = 1; i <= n; i++) {
  natija *= i;
}'''
      ],
      solution: r'''int faktorial(int n) {
  var natija = 1;
  for (var i = 1; i <= n; i++) {
    natija *= i;
  }
  return natija;
}

void main() {
  print(faktorial(5));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Sikl necha marta ishlaydi va nima chiqaradi?',
        code: r'''void main() {
  for (var i = 0; i < 6; i += 2) {
    print(i);
  }
}''',
        options: ['0\n2\n4', '0\n2\n4\n6', '2\n4\n6', '0\n1\n2\n3\n4\n5'],
        explanation: 'i: 0, 2, 4. i = 6 da shart (6 < 6) false — sikl tugaydi.',
        topic: 'for',
      ),
      PredictOutput(
        prompt: 'Natijani yozing',
        code: r'''void main() {
  var s = 0;
  for (var i = 1; i <= 4; i++) {
    s += i * i;
  }
  print(s);
}''',
        explanation: '1 + 4 + 9 + 16 = 30.',
        topic: 'Yig\'indi',
      ),
      ArrangeLines(
        prompt: '1 dan 3 gacha sonlarni chiqaradigan dasturni tartibga qo\'ying',
        lines: ['void main() {', '  for (var i = 1; i <= 3; i++) {', '    print(i);', '  }', '}'],
        explanation: 'main → for sarlavhasi → tana → yopuvchi qavslar.',
        topic: 'for',
      ),
    ],
    summary: [
      'for (boshlash; shart; qadam) — klassik sikl',
      'Shart har iteratsiyadan oldin tekshiriladi',
      'for-in — ro\'yxat elementlarini aylanish',
      'Off-by-one: < va <= farqiga e\'tibor bering',
    ],
    next: 'Keyingi darsda shart bajarilguncha ishlaydigan while va do-while sikllarini, break va continue ni o\'rganamiz.',
    revisionTip: '1 dan 100 gacha juft sonlar yig\'indisini hisoblang (javob: 2550).',
    links: [DocLink('Loops', 'https://dart.dev/language/loops')],
  ),

  // ───────────────────────── 2.4 ─────────────────────────
  Lesson(
    id: 'l2_while',
    title: 'while, do-while, break, continue',
    subtitle: 'Shartga bog\'liq takrorlash va siklni boshqarish',
    icon: Icons.replay_circle_filled_outlined,
    minutes: 13,
    skills: ['dart.while'],
    prerequisites: ['for sikli'],
    objectives: [
      '`while` va `do-while` farqini bilasiz',
      'Cheksiz sikl xavfini tushunasiz va undan qochasiz',
      '`break` va `continue` bilan siklni boshqarasiz',
    ],
    intro: [
      ParaBlock('**`while (shart) { }`** — shart true ekan, takrorlaydi. Necha marta takrorlanishi oldindan noma\'lum bo\'lganda qulay.'),
      ParaBlock('**`do { } while (shart);`** — avval bajaradi, keyin shartni tekshiradi. Demak tana **kamida bir marta** bajariladi.'),
      CalloutBlock(CalloutKind.warning, 'Cheksiz sikl', 'Agar sikl ichida shartga ta\'sir qiluvchi o\'zgaruvchi o\'zgarmasa, sikl hech qachon tugamaydi. Bu playground bunday dasturni avtomatik to\'xtatadi va sizga aytadi.'),
      HeadingBlock('break va continue'),
      BulletsBlock([
        '**`break`** — sikldan darhol chiqish',
        '**`continue`** — joriy iteratsiyaning qolganini o\'tkazib, keyingisiga o\'tish',
      ]),
    ],
    analogy: AnalogyBlock(
      'Kitob o\'qish',
      'while: "Charchamagunimcha o\'qiyman" — necha bet bo\'lishi noma\'lum. do-while: "Kamida bir bet o\'qiyman, keyin charchaganimni tekshiraman". break: "Qo\'ng\'iroq bo\'ldi — darhol to\'xtayman". continue: "Bu bet zerikarli — keyingisiga o\'taman".',
      icon: Icons.menu_book_outlined,
    ),
    why: 'Foydalanuvchi to\'g\'ri parol kiritguncha so\'rash, fayl tugaguncha o\'qish, o\'yin tugaguncha davom etish — while sikllari bilan.',
    where: [
      'Menyuni foydalanuvchi "chiqish" ni tanlaguncha ko\'rsatish',
      'Qidiruv: topilganda `break`',
      'Filtrlash: keraksiz elementda `continue`',
    ],
    terms: [
      TermBlock(term: 'while loop', uz: 'while sikli', meaning: 'Shart true ekan takrorlaydi.', why: 'Takrorlar soni noma\'lum bo\'lganda.'),
      TermBlock(term: 'Infinite loop', uz: 'Cheksiz sikl', meaning: 'Hech qachon tugamaydigan sikl.', why: 'Dasturni "qotirib" qo\'yadi — undan qochish kerak.'),
      TermBlock(term: 'break', uz: 'To\'xtatish', meaning: 'Sikldan chiqish.', why: 'Kerakli natija topilganda.'),
      TermBlock(term: 'continue', uz: 'Davom ettirish', meaning: 'Keyingi iteratsiyaga o\'tish.', why: 'Ba\'zi elementlarni o\'tkazib yuborish.'),
    ],
    animation: AnimationBlock('loop_while', 'while: shart → tana → shart... do-while: tana → shart → tana...'),
    example: CodeBlock(
      r'''void main() {
  var pul = 10000;
  var oy = 0;
  while (pul < 20000) {
    pul += 3000;
    oy++;
  }
  print('$oy oyda $pul so\'m yig\'iladi');

  var urinish = 0;
  do {
    urinish++;
    print('Urinish: $urinish');
  } while (urinish < 2);

  for (var i = 1; i <= 10; i++) {
    if (i % 3 == 0) continue;
    if (i > 7) break;
    print(i);
  }
}''',
      title: 'while, do-while, break, continue',
      explain: {
        'while': 'Shart true ekan takrorlanadi.',
        'do': 'Tana kamida bir marta bajariladi.',
        'continue': 'Bu iteratsiyaning qolganini o\'tkazib yuboradi.',
        'break': 'Sikldan butunlay chiqadi.',
      },
      expectedOutput: "4 oyda 22000 so'm yig'iladi\nUrinish: 1\nUrinish: 2\n1\n2\n4\n5\n7\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var i = 0;
  while (i < 3) {
    print(i);
  }
}''',
      task: 'Bu cheksiz sikl! Ishga tushiring, xabarni o\'qing va tuzating — natija 0, 1, 2 bo\'lsin.',
      why: 'Sikl ichida `i` hech qachon o\'zgarmaydi, shuning uchun `i < 3` doim true. Har iteratsiyada `i++` qilish kerak.',
      fixed: r'''void main() {
  var i = 0;
  while (i < 3) {
    print(i);
    i++;
  }
}''',
      hint: 'Shartdagi o\'zgaruvchi sikl ichida o\'zgaryaptimi?',
    ),
    task: CodeTask(
      title: 'Birinchi bo\'linuvchi',
      instructions: '`birinchiBolinuvchi(int n)` — n dan katta yoki teng bo\'lgan va **7 ga bo\'linadigan** birinchi sonni `while` bilan toping.\n`birinchiBolinuvchi(10)` → `14`, `birinchiBolinuvchi(21)` → `21`.',
      starter: r'''int birinchiBolinuvchi(int n) {
  var son = n;
  // while bilan qidiring
  return son;
}

void main() {
  print(birinchiBolinuvchi(10));
}''',
      checks: [
        EvaluatesTo('birinchiBolinuvchi(10)', '14'),
        EvaluatesTo('birinchiBolinuvchi(21)', '21'),
        EvaluatesTo('birinchiBolinuvchi(50)', '56', hidden: true),
        UsesConstruct(r'while\s*\(', '`while` ishlatilishi kerak'),
      ],
      hints: ['Shart: son % 7 != 0', 'Har iteratsiyada son++', r'''while (son % 7 != 0) {
  son++;
}'''],
      solution: r'''int birinchiBolinuvchi(int n) {
  var son = n;
  while (son % 7 != 0) {
    son++;
  }
  return son;
}

void main() {
  print(birinchiBolinuvchi(10));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var n = 5;
  do {
    print(n);
    n++;
  } while (n < 3);
}''',
        options: ['5', 'Hech narsa', '5\n6', 'Cheksiz sikl'],
        explanation: 'do-while tanasi shart tekshirilishidan oldin bir marta bajariladi.',
        topic: 'do-while',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  for (var i = 0; i < 5; i++) {
    if (i == 2) continue;
    if (i == 4) break;
    print(i);
  }
}''',
        options: ['0\n1\n3', '0\n1\n2\n3', '0\n1', '0\n1\n3\n4'],
        explanation: 'i=2 o\'tkazib yuboriladi (continue), i=4 da sikl to\'xtaydi (break).',
        topic: 'break/continue',
      ),
    ],
    summary: [
      'while — shart true ekan, do-while — kamida bir marta',
      'Sikl ichida shartga ta\'sir qiluvchi o\'zgarish bo\'lishi shart',
      'break — chiqish, continue — keyingi iteratsiya',
    ],
    next: 'Endi ko\'p qiymatni bitta o\'zgaruvchida saqlash — List (ro\'yxat) ni o\'rganamiz.',
    revisionTip: 'Sonning raqamlari yig\'indisini while bilan hisoblang: 1234 → 10 (maslahat: % 10 va ~/ 10).',
  ),

  // ───────────────────────── 2.5 ─────────────────────────
  Lesson(
    id: 'l2_list',
    title: 'List — ro\'yxatlar',
    subtitle: 'Ko\'p qiymatni tartib bilan saqlash',
    icon: Icons.format_list_numbered_rounded,
    minutes: 16,
    xp: 60,
    skills: ['dart.list'],
    prerequisites: ['for sikli'],
    objectives: [
      'List yaratish, element olish va o\'zgartirishni bilasiz',
      'Indekslar 0 dan boshlanishini tushunasiz',
      'add, remove, contains, map, where kabi metodlarni qo\'llaysiz',
    ],
    intro: [
      ParaBlock('**List** — tartiblangan qiymatlar ro\'yxati. `var mevalar = [\'olma\', \'nok\', \'uzum\'];`'),
      ParaBlock('Har bir elementning **indeksi** (tartib raqami) bor va u **0 dan boshlanadi**: `mevalar[0]` → `\'olma\'`, `mevalar[2]` → `\'uzum\'`. Oxirgi indeks = `length - 1`.'),
      ParaBlock('Turini aniq ko\'rsatish: `List<int> ballar = [90, 85, 77];` — bu ro\'yxatga faqat int qo\'shiladi.'),
      HeadingBlock('Asosiy amallar'),
      BulletsBlock([
        '`.add(x)` — oxiriga qo\'shish, `.insert(i, x)` — i-o\'ringa',
        '`.remove(x)`, `.removeAt(i)` — o\'chirish',
        '`.length`, `.first`, `.last`, `.isEmpty`',
        '`.contains(x)`, `.indexOf(x)`',
        '`.sort()` — saralash, `.reversed` — teskari',
      ]),
      HeadingBlock('Funksional metodlar'),
      BulletsBlock([
        '`.map((x) => x * 2)` — har bir elementni o\'zgartirish',
        '`.where((x) => x > 5)` — filtrlash',
        '`.reduce((a, b) => a + b)` — bitta qiymatga yig\'ish',
        '`.toList()` — natijani yana List ga aylantirish',
      ]),
    ],
    analogy: AnalogyBlock(
      'Poyezd vagonlari',
      'List — poyezd: vagonlar tartib bilan ulangan va raqamlangan. Lekin dasturchilar sanashni 0 dan boshlaydi: lokomotivdan keyingi birinchi vagon — 0-vagon. Vagon qo\'shish (add), uzish (remove), "3-vagonda nima bor?" (list[3]).',
      icon: Icons.train_outlined,
    ),
    why: 'Kontaktlar, xabarlar, mahsulotlar, postlar — ilovadagi deyarli har bir ekran ro\'yxat bilan ishlaydi. Flutter ListView aynan List ma\'lumotini ko\'rsatadi.',
    where: [
      'Chat xabarlari: `List<Xabar>`',
      'Savatcha: `List<Mahsulot>`',
      'Flutter: `ListView.builder(itemCount: royxat.length, ...)`',
    ],
    terms: [
      TermBlock(term: 'List', uz: 'Ro\'yxat', meaning: 'Tartiblangan elementlar to\'plami.', why: 'Ko\'p qiymatni bitta joyda saqlash.', example: '[1, 2, 3]'),
      TermBlock(term: 'Index', uz: 'Indeks', meaning: 'Elementning tartib raqami (0 dan).', why: 'Elementga murojaat qilish uchun.', example: 'list[0]'),
      TermBlock(term: 'Element', uz: 'Element', meaning: 'Ro\'yxatdagi bitta qiymat.', why: ''),
      TermBlock(term: 'Generic <T>', uz: 'Umumlashgan tur', meaning: 'List ichidagi elementlar turi.', why: 'Noto\'g\'ri turdagi qiymat qo\'shilishining oldini oladi.', example: 'List<String>'),
    ],
    animation: AnimationBlock('list_boxes', 'Indekslangan qutilar: add, remove va [i] amallarini sinab ko\'ring.'),
    example: CodeBlock(
      r'''void main() {
  List<String> mevalar = ['olma', 'nok', 'uzum'];
  print(mevalar[0]);
  print(mevalar.length);

  mevalar.add('anor');
  mevalar.remove('nok');
  mevalar[0] = 'behi';
  print(mevalar);

  List<int> ballar = [72, 95, 88, 64];
  ballar.sort();
  print(ballar);
  print(ballar.where((b) => b >= 80).toList());
  print(ballar.map((b) => b + 5).toList());
  var jami = ballar.reduce((a, b) => a + b);
  print("O'rtacha: ${jami / ballar.length}");
}''',
      title: 'List amallari',
      explain: {
        'List<String>': 'Faqat String lardan iborat ro\'yxat.',
        '[0]': 'Birinchi element (indeks 0).',
        'length': 'Elementlar soni.',
        'add': 'Oxiriga qo\'shadi.',
        'remove': 'Berilgan qiymatni o\'chiradi.',
        'sort': 'O\'sish tartibida saralaydi.',
        'where': 'Shartga mos elementlarni tanlaydi.',
        'map': 'Har bir elementni o\'zgartiradi.',
        'reduce': 'Barcha elementlarni bitta qiymatga yig\'adi.',
        'toList': 'Natijani List ga aylantiradi.',
      },
      expectedOutput: "olma\n3\n[behi, uzum, anor]\n[64, 72, 88, 95]\n[88, 95]\n[69, 77, 93, 100]\nO'rtacha: 79.75\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var shaharlar = ['Toshkent', 'Samarqand', 'Buxoro'];
  print(shaharlar[3]);
}''',
      task: 'Oxirgi shaharni chiqarish kerak edi. Ishga tushiring, xatoni o\'qing va tuzating.',
      why: '3 ta elementli ro\'yxatda indekslar 0, 1, 2. `[3]` mavjud emas — RangeError. Oxirgi element: `[length - 1]` yoki `.last`.',
      fixed: r'''void main() {
  var shaharlar = ['Toshkent', 'Samarqand', 'Buxoro'];
  print(shaharlar.last);
}''',
      hint: 'Indekslar qaysi sondan boshlanadi?',
    ),
    task: CodeTask(
      title: 'Ballar statistikasi',
      instructions: '`maksimal(List<int> l)` funksiyasini yozing: ro\'yxatdagi eng katta sonni qaytarsin. **`reduce` yoki sikl** ishlating (`max` kutubxona funksiyasisiz).\n`maksimal([3, 9, 2])` → `9`',
      starter: r'''int maksimal(List<int> l) {
  var eng = l[0];
  // qolganini yozing
  return eng;
}

void main() {
  print(maksimal([3, 9, 2]));
}''',
      checks: [
        EvaluatesTo('maksimal([3, 9, 2])', '9'),
        EvaluatesTo('maksimal([-5, -2, -9])', '-2', hidden: true),
        EvaluatesTo('maksimal([7])', '7', hidden: true),
        EvaluatesTo('maksimal([1, 2, 3, 100, 4])', '100', hidden: true),
      ],
      hints: ['Har bir elementni eng bilan solishtiring.', 'for (final x in l) { if (x > eng) eng = x; }', 'Yoki: return l.reduce((a, b) => a > b ? a : b);'],
      solution: r'''int maksimal(List<int> l) {
  var eng = l[0];
  for (final x in l) {
    if (x > eng) eng = x;
  }
  return eng;
}

void main() {
  print(maksimal([3, 9, 2]));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var l = [10, 20, 30];
  l.add(40);
  print(l[1] + l.last);
}''',
        explanation: 'l[1] = 20, l.last = 40. 20 + 40 = 60.',
        topic: 'List',
      ),
      SingleChoice(
        prompt: '5 elementli ro\'yxatning oxirgi indeksi?',
        options: ['5', '4', '6', '0'],
        correct: 1,
        explanation: 'Indekslar 0 dan boshlanadi: 0, 1, 2, 3, 4.',
        topic: 'Indeks',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var l = [1, 2, 3, 4, 5, 6];
  print(l.where((x) => x.isEven).map((x) => x * 10).toList());
}''',
        options: ['[20, 40, 60]', '[10, 30, 50]', '[2, 4, 6]', '(20, 40, 60)'],
        explanation: 'where juftlarni tanlaydi (2, 4, 6), map 10 ga ko\'paytiradi, toList List qiladi.',
        topic: 'map/where',
      ),
    ],
    summary: [
      'List — tartiblangan ro\'yxat, indeks 0 dan',
      'add, insert, remove, removeAt — o\'zgartirish',
      'length, first, last, contains, indexOf',
      'map, where, reduce — funksional uslub; .toList() bilan List',
      'Mavjud bo\'lmagan indeks — RangeError',
    ],
    next: 'Keyingi darsda "kalit — qiymat" juftliklari — Map (lug\'at) ni o\'rganamiz.',
    revisionTip: '5 ta do\'stingiz ismini List ga yozing, alifbo bo\'yicha saralang va har birini "1. Ali" ko\'rinishida chiqaring.',
    links: [DocLink('Collections', 'https://dart.dev/language/collections')],
  ),

  // ───────────────────────── 2.6 ─────────────────────────
  Lesson(
    id: 'l2_map',
    title: 'Map — kalit va qiymat',
    subtitle: 'Ma\'lumotni nom bo\'yicha topish',
    icon: Icons.menu_book_rounded,
    minutes: 14,
    skills: ['dart.map'],
    prerequisites: ['List — ro\'yxatlar'],
    objectives: [
      'Map yaratish, qiymat olish va qo\'shishni bilasiz',
      'Mavjud bo\'lmagan kalit `null` qaytarishini tushunasiz',
      'Map ni aylanish (keys, values, entries, forEach)',
    ],
    intro: [
      ParaBlock('**Map** — **kalit: qiymat** juftliklari to\'plami. `var yoshlar = {\'Ali\': 20, \'Vali\': 25};`'),
      ParaBlock('List da elementni indeks bo\'yicha topsak, Map da **kalit** bo\'yicha topamiz: `yoshlar[\'Ali\']` → `20`.'),
      BulletsBlock([
        'Qo\'shish/yangilash: `yoshlar[\'Gani\'] = 30;`',
        'O\'chirish: `yoshlar.remove(\'Vali\');`',
        'Tekshirish: `yoshlar.containsKey(\'Ali\')`',
        'Mavjud bo\'lmagan kalit: `yoshlar[\'Yo\\\'q\']` → `null`',
        '`.keys`, `.values`, `.entries`, `.length`',
      ]),
      ParaBlock('Turli: `Map<String, int> yoshlar = {};` — kalitlar String, qiymatlar int.'),
      CalloutBlock(CalloutKind.info, 'Kalitlar takrorlanmaydi', 'Bitta kalitga faqat bitta qiymat. `m[\'a\'] = 1; m[\'a\'] = 2;` — endi `a` ning qiymati 2.'),
    ],
    analogy: AnalogyBlock(
      'Telefon kitobchasi',
      'Kontaktlar ro\'yxatida ism (kalit) bo\'yicha raqamni (qiymat) topasiz. "Onam" ni qidirasiz — raqam chiqadi. Bitta ismda ikki xil yozuv bo\'lmaydi — yangisi eskisini almashtiradi.',
      icon: Icons.contacts_outlined,
    ),
    why: 'Sozlamalar, lug\'atlar, JSON ma\'lumotlar (API javoblari) — Map ko\'rinishida. Flutterda serverdan kelgan har bir obyekt dastlab Map bo\'ladi.',
    where: [
      'API javobi: `{"ism": "Ali", "yosh": 20}`',
      'Sozlamalar: `{\'tema\': \'qorong\\\'i\', \'til\': \'uz\'}`',
      'So\'zlarni sanash: `{\'olma\': 3, \'nok\': 1}`',
    ],
    terms: [
      TermBlock(term: 'Map', uz: 'Xarita / lug\'at', meaning: 'Kalit-qiymat juftliklari.', why: 'Nom bo\'yicha tez qidirish.', example: "{'a': 1}"),
      TermBlock(term: 'Key', uz: 'Kalit', meaning: 'Qiymatni topish uchun noyob nom.', why: ''),
      TermBlock(term: 'Value', uz: 'Qiymat', meaning: 'Kalitga bog\'langan ma\'lumot.', why: ''),
      TermBlock(term: 'Entry', uz: 'Yozuv', meaning: 'Bitta kalit-qiymat juftligi (MapEntry).', why: 'Map ni aylanish uchun.'),
    ],
    animation: AnimationBlock('map_pairs', 'Kalit → qiymat. Kalit bo\'yicha qidirish qanday ishlashini ko\'ring.'),
    example: CodeBlock(
      r'''void main() {
  Map<String, int> narxlar = {
    'non': 4000,
    'sut': 12000,
    'tuxum': 1500,
  };

  print(narxlar['sut']);
  print(narxlar['go\'sht']);

  narxlar['choy'] = 25000;
  narxlar['non'] = 4500;
  print(narxlar.length);
  print(narxlar.containsKey('choy'));

  for (final e in narxlar.entries) {
    print('${e.key}: ${e.value} so\'m');
  }

  var jami = 0;
  narxlar.forEach((nom, narx) => jami += narx);
  print('Jami: $jami');
}''',
      title: 'Do\'kon narxlari',
      explain: {
        'Map<String, int>': 'Kalitlari String, qiymatlari int bo\'lgan Map.',
        "['sut']": 'Kalit bo\'yicha qiymat olish.',
        'containsKey': 'Kalit bormi — bool.',
        'entries': 'Barcha kalit-qiymat juftliklari.',
        'forEach': 'Har bir juftlik uchun funksiyani chaqiradi.',
      },
      expectedOutput: "12000\nnull\n4\ntrue\nnon: 4500 so'm\nsut: 12000 so'm\ntuxum: 1500 so'm\nchoy: 25000 so'm\nJami: 43000\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var ballar = {'Ali': 90, 'Vali': 75};
  int aliBall = ballar['Ali'];
  print(aliBall + 5);
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Xatoni o\'qing va tuzating.',
      why: 'Map dan qiymat olish `int?` qaytaradi — chunki kalit bo\'lmasligi mumkin. `int` ga to\'g\'ridan-to\'g\'ri berib bo\'lmaydi. Yechim: `?? 0` (standart qiymat) yoki `!` (ishonch komil bo\'lsa).',
      fixed: r'''void main() {
  var ballar = {'Ali': 90, 'Vali': 75};
  int aliBall = ballar['Ali'] ?? 0;
  print(aliBall + 5);
}''',
      hint: 'Map[kalit] null bo\'lishi mumkin. ?? operatorini eslang.',
    ),
    task: CodeTask(
      title: 'So\'zlarni sanash',
      instructions: '`sanash(String matn)` — matndagi har bir so\'z necha marta uchraganini Map da qaytarsin.\n`sanash(\'olma nok olma\')` → `{olma: 2, nok: 1}`',
      starter: r'''Map<String, int> sanash(String matn) {
  var natija = <String, int>{};
  for (final soz in matn.split(' ')) {
    // har bir so'zni sanang
  }
  return natija;
}

void main() {
  print(sanash('olma nok olma'));
}''',
      checks: [
        EvaluatesTo("sanash('olma nok olma')", '{olma: 2, nok: 1}'),
        EvaluatesTo("sanash('a b c a b a')", '{a: 3, b: 2, c: 1}', hidden: true),
        EvaluatesTo("sanash('dart')", '{dart: 1}', hidden: true),
      ],
      hints: ['natija[soz] — hozirgi son (null bo\'lishi mumkin).', '(natija[soz] ?? 0) + 1', 'natija[soz] = (natija[soz] ?? 0) + 1;'],
      solution: r'''Map<String, int> sanash(String matn) {
  var natija = <String, int>{};
  for (final soz in matn.split(' ')) {
    natija[soz] = (natija[soz] ?? 0) + 1;
  }
  return natija;
}

void main() {
  print(sanash('olma nok olma'));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var m = {'a': 1, 'b': 2};
  m['a'] = 10;
  m['c'] = 3;
  print(m);
}''',
        options: ['{a: 1, b: 2, c: 3}', '{a: 10, b: 2, c: 3}', '{a: 1, a: 10, b: 2, c: 3}', 'Xato'],
        explanation: 'Mavjud kalitga qiymat berish uni yangilaydi, yangi kalit qo\'shiladi.',
        topic: 'Map',
      ),
      SingleChoice(
        prompt: "`{'x': 5}['y']` nima qaytaradi?",
        options: ['0', 'null', 'Xato', "''"],
        correct: 1,
        explanation: 'Mavjud bo\'lmagan kalit null qaytaradi.',
        topic: 'Map null',
      ),
      MatchPairs(
        prompt: 'Moslang',
        pairs: [('.keys', 'Barcha kalitlar'), ('.values', 'Barcha qiymatlar'), ('.containsKey', 'Kalit bormi?'), ('.remove', 'Juftlikni o\'chirish')],
        explanation: 'Map ning asosiy a\'zolari.',
        topic: 'Map metodlari',
      ),
    ],
    summary: [
      'Map — kalit: qiymat juftliklari',
      'm[kalit] — qiymat yoki null',
      'm[kalit] = qiymat — qo\'shish yoki yangilash',
      'keys, values, entries, forEach — aylanish',
    ],
    next: 'Keyingi darsda takrorlanmas to\'plam — Set va kolleksiyalarni qurishning zamonaviy usullarini (collection-if, for, spread) ko\'ramiz.',
    revisionTip: 'O\'zbekiston 5 ta shahri va aholisini Map da saqlang, eng katta aholili shaharni toping.',
  ),

  // ───────────────────────── 2.7 ─────────────────────────
  Lesson(
    id: 'l2_set_collections',
    title: 'Set, collection-if/for va spread',
    subtitle: 'Kolleksiyalarni zamonaviy usulda qurish',
    icon: Icons.bubble_chart_outlined,
    minutes: 12,
    skills: ['dart.set', 'dart.collections'],
    prerequisites: ['Map — kalit va qiymat'],
    objectives: [
      'Set — takrorlanmas to\'plamni ishlatasiz',
      'collection-if va collection-for bilan ro\'yxat qurasiz',
      'spread (`...`) operatori bilan ro\'yxatlarni birlashtirasiz',
    ],
    intro: [
      ParaBlock('**Set** — **takrorlanmaydigan** elementlar to\'plami: `var s = {1, 2, 2, 3};` → `{1, 2, 3}`. Element bormi-yo\'qligini juda tez tekshiradi.'),
      BulletsBlock([
        '`.add`, `.remove`, `.contains`',
        '`.union(b)` — birlashma, `.intersection(b)` — kesishma, `.difference(b)` — ayirma',
      ]),
      HeadingBlock('Collection-if va collection-for'),
      ParaBlock('Ro\'yxat ichida to\'g\'ridan-to\'g\'ri shart va sikl yozish mumkin:'),
      BulletsBlock([
        "`[ 'Bosh sahifa', if (admin) 'Boshqaruv' ]` — admin bo'lsagina qo'shiladi",
        '`[for (var i = 1; i <= 3; i++) i * i]` → `[1, 4, 9]`',
      ]),
      HeadingBlock('Spread operatori'),
      ParaBlock('`...` — bir ro\'yxat elementlarini boshqasiga "yoyib" qo\'yadi: `[...a, ...b]`. `...?` — agar ro\'yxat null bo\'lishi mumkin bo\'lsa.'),
      CalloutBlock(CalloutKind.success, 'Flutterda juda ko\'p ishlatiladi', 'Flutter widget ro\'yxatlarida: `children: [Sarlavha(), if (xato) XatoMatni(), ...elementlar]`'),
    ],
    analogy: AnalogyBlock(
      'Albom va stikerlar',
      'Set — stiker albomi: har bir stiker bir marta joylashadi, takroriysini qo\'ysangiz ham bitta qoladi. Spread — ikki qopdagi konfetlarni bitta idishga to\'kish.',
      icon: Icons.collections_bookmark_outlined,
    ),
    why: 'Noyob qiymatlar (teglar, foydalanuvchi ID lari) uchun Set, dinamik UI ro\'yxatlari uchun collection-if/for va spread — zamonaviy Dart/Flutter kodining asosiy uslubi.',
    where: [
      'Tanlangan elementlar: `Set<int> tanlangan`',
      'Shartli menyu bandlari',
      'Flutter: `children: [...widgetlar]`',
    ],
    terms: [
      TermBlock(term: 'Set', uz: 'To\'plam', meaning: 'Takrorlanmas elementlar.', why: 'Noyoblikni ta\'minlash.', example: '{1, 2, 3}'),
      TermBlock(term: 'Spread operator', uz: 'Yoyish operatori', meaning: '... — elementlarni boshqa kolleksiyaga yoyadi.', why: 'Ro\'yxatlarni birlashtirish.'),
      TermBlock(term: 'Collection if/for', uz: 'Kolleksiya ichidagi if/for', meaning: 'Ro\'yxat ichida shart va sikl.', why: 'Dinamik ro\'yxat qurish.'),
    ],
    example: CodeBlock(
      r'''void main() {
  var teglar = {'dart', 'flutter', 'dart', 'mobil'};
  print(teglar);
  print(teglar.length);

  var a = {1, 2, 3, 4};
  var b = {3, 4, 5};
  print(a.intersection(b));
  print(a.union(b));

  var admin = true;
  var menyu = ['Bosh sahifa', 'Profil', if (admin) 'Boshqaruv'];
  print(menyu);

  var kvadratlar = [for (var i = 1; i <= 5; i++) i * i];
  print(kvadratlar);

  var hammasi = [0, ...kvadratlar, 100];
  print(hammasi);
}''',
      title: 'Set va zamonaviy kolleksiyalar',
      explain: {
        'intersection': 'Ikkala to\'plamda ham bor elementlar.',
        'union': 'Ikkala to\'plamning barcha elementlari (takrorlarsiz).',
        'if (admin)': 'collection-if: shart true bo\'lsa element qo\'shiladi.',
        'for': 'collection-for: har iteratsiyada element hosil qilinadi.',
        '...': 'spread: ro\'yxat elementlarini yoyib qo\'yadi.',
      },
      expectedOutput: '{dart, flutter, mobil}\n3\n{3, 4}\n{1, 2, 3, 4, 5}\n[Bosh sahifa, Profil, Boshqaruv]\n[1, 4, 9, 16, 25]\n[0, 1, 4, 9, 16, 25, 100]\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var a = [1, 2];
  var b = [3, 4];
  var c = [a, b];
  print(c);
}''',
      task: 'Natija `[1, 2, 3, 4]` bo\'lishi kerak, lekin `[[1, 2], [3, 4]]` chiqyapti. Tuzating.',
      why: '`[a, b]` — ikki ro\'yxatdan iborat ro\'yxat (ichma-ich). Elementlarni birlashtirish uchun spread kerak: `[...a, ...b]`.',
      fixed: r'''void main() {
  var a = [1, 2];
  var b = [3, 4];
  var c = [...a, ...b];
  print(c);
}''',
    ),
    task: CodeTask(
      title: 'Noyob ismlar',
      instructions: '`noyob(List<String> ismlar)` — takrorlarni olib tashlab, **alifbo tartibida** saralangan List qaytarsin.\n`noyob([\'Vali\', \'Ali\', \'Vali\'])` → `[Ali, Vali]`',
      starter: r'''List<String> noyob(List<String> ismlar) {
  // Set dan foydalaning
  return ismlar;
}

void main() {
  print(noyob(['Vali', 'Ali', 'Vali']));
}''',
      checks: [
        EvaluatesTo("noyob(['Vali', 'Ali', 'Vali'])", '[Ali, Vali]'),
        EvaluatesTo("noyob(['c', 'a', 'b', 'a', 'c'])", '[a, b, c]', hidden: true),
        EvaluatesTo('noyob([])', '[]', hidden: true),
      ],
      hints: ['ismlar.toSet() takrorlarni olib tashlaydi.', '.toList() bilan yana List qiling, keyin .sort()', r'''var l = ismlar.toSet().toList();
l.sort();
return l;'''],
      solution: r'''List<String> noyob(List<String> ismlar) {
  var l = ismlar.toSet().toList();
  l.sort();
  return l;
}

void main() {
  print(noyob(['Vali', 'Ali', 'Vali']));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var s = {5, 1, 5, 2, 1};
  print(s.length);
}''',
        explanation: 'Set takrorlarni saqlamaydi: {5, 1, 2} — 3 ta.',
        topic: 'Set',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var vip = false;
  var l = ['A', if (vip) 'VIP', 'B'];
  print(l);
}''',
        options: ['[A, VIP, B]', '[A, B]', '[A, null, B]', 'Xato'],
        explanation: 'vip false — collection-if elementi qo\'shilmaydi.',
        topic: 'collection-if',
      ),
    ],
    summary: [
      'Set — noyob elementlar; union, intersection, difference',
      'collection-if: [if (shart) element]',
      'collection-for: [for (...) element]',
      'spread: [...a, ...b], null bo\'lishi mumkin bo\'lsa ...?',
    ],
    next: 'Keyingi darsda Dartning eng muhim xavfsizlik tizimi — null safety ni o\'rganamiz.',
    revisionTip: 'Ikki sinf o\'quvchilari ro\'yxatidan ikkala sinfda ham qatnashadigan sport to\'garagi a\'zolarini Set bilan toping.',
  ),

  // ───────────────────────── 2.8 ─────────────────────────
  Lesson(
    id: 'l2_null_safety',
    title: 'Null safety va null-aware operatorlar',
    subtitle: '"Bo\'sh qiymat" xatolaridan himoya',
    icon: Icons.shield_outlined,
    minutes: 15,
    xp: 60,
    skills: ['dart.null_safety'],
    prerequisites: ['Map — kalit va qiymat'],
    objectives: [
      'null nima va u nima uchun xavfli ekanini bilasiz',
      'Nullable (`String?`) va non-nullable (`String`) turlarni ajratasiz',
      '`?.`, `??`, `??=`, `!` operatorlarini to\'g\'ri qo\'llaysiz',
    ],
    intro: [
      ParaBlock('**null** — "qiymat yo\'q" degani. Masalan, foydalanuvchi telefon raqamini kiritmagan bo\'lsa.'),
      ParaBlock('Ko\'p tillarda null bilan ishlash eng ko\'p uchraydigan xatoga olib keladi ("null pointer exception"). Dart buni **null safety** bilan hal qiladi:'),
      BulletsBlock([
        '`String ism` — **hech qachon null bo\'lmaydi**',
        '`String? telefon` — null bo\'lishi **mumkin** (savol belgisi)',
      ]),
      ParaBlock('Dart null bo\'lishi mumkin bo\'lgan qiymatni to\'g\'ridan-to\'g\'ri ishlatishga **ruxsat bermaydi** — kod ishga tushmasdan oldin xato beradi. Bu sizni minglab ish vaqtidagi xatolardan himoya qiladi.'),
      HeadingBlock('Null-aware operatorlar'),
      BulletsBlock([
        '`a ?? b` — a null bo\'lsa b: `ism ?? \'Mehmon\'`',
        '`a?.metod()` — a null bo\'lsa, null qaytaradi (xato emas)',
        '`a ??= b` — a null bo\'lsagina b ni beradi',
        '`a!` — "bu null emas, ishon" — agar aslida null bo\'lsa, dastur to\'xtaydi. **Ehtiyot bo\'ling!**',
      ]),
      HeadingBlock('Type promotion (turni ko\'tarish)'),
      ParaBlock('`if (telefon != null) { print(telefon.length); }` — if ichida Dart `telefon` ni avtomatik `String` (null emas) deb biladi.'),
    ],
    analogy: AnalogyBlock(
      'Sovg\'a qutisi',
      '`String?` — ichida sovg\'a bo\'lishi ham, bo\'sh bo\'lishi ham mumkin bo\'lgan quti. `?.` — "ochib ko\'r, bo\'sh bo\'lsa qo\'y". `??` — "bo\'sh bo\'lsa, zaxira sovg\'ani ol". `!` — "ishonaman, ichida bor!" deb qo\'lni tiqish: bo\'sh chiqsa — uyat (xato).',
      icon: Icons.card_giftcard_outlined,
    ),
    why: 'Serverdan keladigan ma\'lumot, foydalanuvchi kiritmagan maydon, topilmagan element — null hamma joyda. Null safety ni tushunmasdan Flutterda bir qadam ham bosib bo\'lmaydi.',
    where: [
      'Formadagi ixtiyoriy maydon: `String? izoh`',
      'Map dan qiymat: `m[\'kalit\'] ?? 0`',
      'Flutter: `user?.name ?? \'Mehmon\'`',
    ],
    terms: [
      TermBlock(term: 'null', uz: 'Bo\'sh qiymat', meaning: 'Qiymat yo\'qligini bildiradi.', why: 'Ixtiyoriy ma\'lumotlar uchun.'),
      TermBlock(term: 'Nullable type', uz: 'Null bo\'la oladigan tur', meaning: 'Tur nomidan keyin ? qo\'yiladi.', why: 'Qiymat bo\'lmasligi mumkinligini aniq ko\'rsatish.', example: 'int?'),
      TermBlock(term: 'Sound null safety', uz: 'To\'liq null xavfsizligi', meaning: 'Non-nullable o\'zgaruvchi hech qachon null bo\'lmasligi kafolati.', why: 'Xatolarni kompilyatsiyada ushlaydi.'),
      TermBlock(term: 'Type promotion', uz: 'Turni ko\'tarish', meaning: 'Tekshiruvdan keyin Dart turni aniqroq deb biladi.', why: 'Qo\'shimcha ! yozmaslik uchun.'),
    ],
    animation: AnimationBlock('null_box', 'String? quti: ichi bo\'lishi yoki bo\'sh bo\'lishi mumkin. ??, ?. va ! ni sinab ko\'ring.'),
    example: CodeBlock(
      r'''void main() {
  String? telefon;
  print(telefon);
  print(telefon ?? 'Raqam kiritilmagan');
  print(telefon?.length);

  telefon ??= '+998 90 123 45 67';
  print(telefon);

  String? taxallus = null;
  String korinadi = taxallus ?? 'Mehmon';
  print('Salom, $korinadi');

  int? ball = int.tryParse('85');
  if (ball != null) {
    print(ball + 10);
  }
}''',
      title: 'Null bilan xavfsiz ishlash',
      explain: {
        'String?': 'Null bo\'lishi mumkin bo\'lgan String.',
        '??': 'Chap tomon null bo\'lsa, o\'ng tomonni oladi.',
        '?.': 'Null bo\'lsa — xato emas, null qaytaradi.',
        '??=': 'Faqat null bo\'lsa qiymat beradi.',
        'tryParse': 'Muvaffaqiyatsiz bo\'lsa null qaytaradi.',
        '!=': 'if ichida ball endi int (null emas) — type promotion.',
      },
      expectedOutput: 'null\nRaqam kiritilmagan\nnull\n+998 90 123 45 67\nSalom, Mehmon\n95\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  String? ism;
  print(ism.length);
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Xatoni o\'qing. `ism` null bo\'lsa `0` chiqsin.',
      why: '`ism` null bo\'lishi mumkin — `.length` ni to\'g\'ridan-to\'g\'ri chaqirib bo\'lmaydi. `ism?.length` null qaytaradi, `?? 0` esa uni 0 ga almashtiradi.',
      fixed: r'''void main() {
  String? ism;
  print(ism?.length ?? 0);
}''',
      hint: '?. va ?? ni birga ishlating.',
    ),
    task: CodeTask(
      title: 'Xavfsiz salomlashish',
      instructions: '`salom(String? ism)` — agar ism null yoki bo\'sh bo\'lsa `Salom, Mehmon!`, aks holda `Salom, <ism>!` qaytarsin.',
      starter: r'''String salom(String? ism) {
  // null va bo'sh holatni tekshiring
  return 'Salom!';
}

void main() {
  print(salom('Aziz'));
  print(salom(null));
}''',
      checks: [
        EvaluatesTo("salom('Aziz')", 'Salom, Aziz!'),
        EvaluatesTo('salom(null)', 'Salom, Mehmon!'),
        EvaluatesTo("salom('')", 'Salom, Mehmon!', hidden: true),
      ],
      hints: ['if (ism == null || ism.isEmpty) ...', "|| dan keyin ism endi null emas (promotion).", r'''if (ism == null || ism.isEmpty) {
  return 'Salom, Mehmon!';
}
return 'Salom, $ism!';'''],
      solution: r'''String salom(String? ism) {
  if (ism == null || ism.isEmpty) {
    return 'Salom, Mehmon!';
  }
  return 'Salom, $ism!';
}

void main() {
  print(salom('Aziz'));
  print(salom(null));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  int? a;
  int b = a ?? 7;
  print(b * 2);
}''',
        explanation: 'a null — b = 7. 7 * 2 = 14.',
        topic: '??',
      ),
      SingleChoice(
        prompt: 'Qaysi qator KOMPILYATSIYA xatosi beradi?',
        options: ["String a = 'x';", 'String? b = null;', 'String c = null;', 'int? d;'],
        correct: 2,
        explanation: 'Non-nullable `String` ga null berib bo\'lmaydi.',
        topic: 'Nullable',
      ),
      TrueFalse(
        prompt: '`x!` operatori x null bo\'lsa ham xavfsiz ishlaydi.',
        answer: false,
        explanation: '`!` null bo\'lsa dasturni to\'xtatadi ("Null check operator used on a null value"). Faqat aniq ishonganingizda ishlating.',
        topic: '!',
      ),
    ],
    summary: [
      'Tur? — null bo\'lishi mumkin; Tur — hech qachon null emas',
      '?? — standart qiymat, ?. — xavfsiz chaqiruv, ??= — null bo\'lsa ber',
      '! — xavfli: faqat ishonch komil bo\'lsa',
      'if (x != null) ichida x avtomatik non-nullable',
    ],
    next: 'Darajaning so\'nggi darsida o\'rganganlarni algoritmik masalalarda birlashtiramiz.',
    revisionTip: 'Map<String, String?> yarating (ism → telefon), ba\'zilarini null qiling va barchasini "Raqam yo\'q" bilan xavfsiz chiqaring.',
    links: [DocLink('Sound null safety', 'https://dart.dev/null-safety')],
  ),

  // ───────────────────────── 2.9 ─────────────────────────
  Lesson(
    id: 'l2_algorithms',
    title: 'Algoritmik masalalar',
    subtitle: 'Sikl, shart va ro\'yxatlarni birlashtirish',
    icon: Icons.psychology_outlined,
    minutes: 18,
    xp: 70,
    skills: ['dart.algorithms'],
    prerequisites: ['for sikli', 'List — ro\'yxatlar', 'if, else va else if'],
    objectives: [
      'Masalani qadamlarga bo\'lib, kodga aylantirasiz',
      'Klassik algoritmlar: qidirish, sanash, teskari aylantirish, tub sonlar',
      'O\'z yechimingizni testlar bilan tekshirasiz',
    ],
    intro: [
      ParaBlock('Endi sizda barcha "g\'ishtlar" bor: o\'zgaruvchilar, shartlar, sikllar, ro\'yxatlar. Dasturchi bo\'lishning asosiy ko\'nikmasi — ularni **birlashtirib masala yechish**.'),
      ParaBlock('Har bir masalaga 4 qadam bilan yondashing:'),
      BulletsBlock([
        '**Tushun**: kirish nima? chiqish nima? misol qiymatlar bilan tekshiring',
        '**Rejala**: qadamlarni oddiy so\'zlar bilan yozing (algoritm)',
        '**Yoz**: har bir qadamni kodga aylantiring',
        '**Tekshir**: chegaraviy holatlar — bo\'sh ro\'yxat, 0, manfiy son',
      ], ordered: true),
    ],
    analogy: AnalogyBlock(
      'Konstruktor (LEGO)',
      'Sizda endi turli shakldagi LEGO bo\'laklari bor. Ko\'rsatmaga qarab (algoritm) ularni yig\'ib, mashina, uy yoki robot (dastur) yasaysiz. Bir xil bo\'laklardan cheksiz narsa yasash mumkin.',
      icon: Icons.extension_outlined,
    ),
    why: 'Texnik intervyularda, real loyihalarda va har kungi ishda aynan shunday masalalar uchraydi. Bu ko\'nikma til va frameworkdan qat\'i nazar ishlaydi.',
    where: [
      'Qidiruv va filtrlash funksiyalari',
      'Statistika: o\'rtacha, maksimal, sanash',
      'Ma\'lumotni tekshirish (validatsiya)',
    ],
    example: CodeBlock(
      r'''bool tubmi(int n) {
  if (n < 2) return false;
  for (var i = 2; i * i <= n; i++) {
    if (n % i == 0) return false;
  }
  return true;
}

String teskari(String s) {
  var natija = '';
  for (var i = s.length - 1; i >= 0; i--) {
    natija += s[i];
  }
  return natija;
}

void main() {
  var tublar = <int>[];
  for (var i = 1; i <= 20; i++) {
    if (tubmi(i)) tublar.add(i);
  }
  print(tublar);

  print(teskari('kitob'));

  var soz = 'qoshiq';
  print(soz == teskari(soz) ? 'Palindrom' : 'Palindrom emas');
}''',
      title: 'Tub sonlar va teskari so\'z',
      lineNotes: {3: 'Faqat ildizgacha tekshirish yetarli', 11: 'Oxiridan boshiga qarab yuramiz'},
      expectedOutput: '[2, 3, 5, 7, 11, 13, 17, 19]\nbotik\nPalindrom emas\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''int juftlarSoni(List<int> l) {
  var soni = 0;
  for (final x in l) {
    if (x % 2 == 0) {
      soni = 1;
    }
  }
  return soni;
}

void main() {
  print(juftlarSoni([2, 4, 5, 6]));
}''',
      task: 'Natija `3` bo\'lishi kerak, lekin `1` chiqyapti. Mantiqiy xatoni toping.',
      why: '`soni = 1;` har safar qiymatni 1 ga **almashtiradi**. Sanash uchun **oshirish** kerak: `soni++;` yoki `soni += 1;`.',
      fixed: r'''int juftlarSoni(List<int> l) {
  var soni = 0;
  for (final x in l) {
    if (x % 2 == 0) {
      soni++;
    }
  }
  return soni;
}

void main() {
  print(juftlarSoni([2, 4, 5, 6]));
}''',
      hint: 'Hisoblagich har safar qanday o\'zgaryapti?',
    ),
    task: CodeTask(
      title: 'FizzBuzz',
      instructions: 'Klassik intervyu masalasi. 1 dan 15 gacha sonlarni chiqaring, lekin:\n- 3 ga bo\'linsa `Fizz`\n- 5 ga bo\'linsa `Buzz`\n- 15 ga bo\'linsa `FizzBuzz`\n- aks holda sonning o\'zi.',
      starter: r'''void main() {
  for (var i = 1; i <= 15; i++) {
    // shartlarni yozing
  }
}''',
      checks: [
        OutputEquals('1\n2\nFizz\n4\nBuzz\nFizz\n7\n8\nFizz\nBuzz\n11\nFizz\n13\n14\nFizzBuzz\n', label: '1..15'),
        UsesConstruct(r'%', '`%` operatori ishlatilishi kerak'),
      ],
      hints: [
        'Avval 15 ga bo\'linishni tekshiring!',
        'i % 15 == 0 → FizzBuzz, keyin % 3, keyin % 5',
        r'''if (i % 15 == 0) {
  print('FizzBuzz');
} else if (i % 3 == 0) {''',
      ],
      solution: r'''void main() {
  for (var i = 1; i <= 15; i++) {
    if (i % 15 == 0) {
      print('FizzBuzz');
    } else if (i % 3 == 0) {
      print('Fizz');
    } else if (i % 5 == 0) {
      print('Buzz');
    } else {
      print(i);
    }
  }
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Bu funksiya `f([3, 8, 1])` uchun nima qaytaradi?',
        code: r'''int f(List<int> l) {
  var r = 0;
  for (final x in l) {
    if (x > r) r = x;
  }
  return r;
}

void main() {
  print(f([3, 8, 1]));
}''',
        explanation: 'Bu — maksimal elementni topish algoritmi: 8.',
        topic: 'Algoritm',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var n = 1234;
  var s = 0;
  while (n > 0) {
    s += n % 10;
    n = n ~/ 10;
  }
  print(s);
}''',
        explanation: 'Raqamlar yig\'indisi: 4 + 3 + 2 + 1 = 10.',
        topic: 'while',
      ),
    ],
    summary: [
      'Tushun → Rejala → Yoz → Tekshir',
      'Chegaraviy holatlarni (bo\'sh, 0, manfiy) unutmang',
      'Klassik usullar: yig\'uvchi, hisoblagich, maksimal, teskari',
    ],
    next: 'Keyingi daraja — Funksiyalar va OOP: kodni qayta ishlatiladigan bo\'laklarga ajratish va obyektlar bilan fikrlash.',
    revisionTip: 'Ro\'yxatdagi ikkinchi eng katta sonni topadigan funksiya yozing.',
  ),
];
