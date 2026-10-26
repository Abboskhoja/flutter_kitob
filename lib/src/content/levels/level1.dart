import 'package:flutter/material.dart';

import '../model.dart';

const _dartDocs = DocLink('Dart tili turi (rasmiy)', 'https://dart.dev/language');

const level1Lessons = <Lesson>[
  // ───────────────────────── 1.1 ─────────────────────────
  Lesson(
    id: 'l1_dart_intro',
    title: 'Dart nima va nega yaratilgan?',
    subtitle: 'Flutterning "yuragi" bilan tanishuv',
    icon: Icons.flutter_dash_rounded,
    minutes: 9,
    skills: ['dart.intro'],
    prerequisites: ['Dasturchi asboblari: IDE, Terminal, SDK, Git'],
    objectives: [
      'Dart qachon, kim tomonidan va nima uchun yaratilganini bilasiz',
      'Dart va Flutter farqini aniq tushuntira olasiz',
      'Dart dasturi qanday bajarilishini (JIT va AOT) tushunasiz',
    ],
    intro: [
      ParaBlock('**Dart** — Google tomonidan yaratilgan zamonaviy dasturlash tili. Birinchi versiyasi 2011-yilda e\'lon qilingan, bugungi kuchli ko\'rinishi esa (Dart 3, to\'liq null safety bilan) 2023-yilda chiqdi.'),
      ParaBlock('Dart **nega yaratilgan?** Google katta va tez ilovalar yaratish uchun til izlagan: o\'qish oson, xatolarni oldindan ushlaydigan va telefonda ham, brauzerda ham tez ishlaydigan til. Dart aynan shu maqsadda paydo bo\'ldi.'),
      ParaBlock('Dartning asosiy xususiyatlari:'),
      BulletsBlock([
        '**Tushunarli sintaksis** — C, Java, JavaScript ga o\'xshaydi',
        '**Turli tekshiruv** (type-safe) — xatolarni kod ishga tushmasdan oldin topadi',
        '**Null safety** — "bo\'sh qiymat" xatolaridan himoya qiladi',
        '**Tez** — mashina kodiga (AOT) va JavaScript/WebAssembly ga kompilyatsiya bo\'ladi',
        '**Hot reload** — kodni o\'zgartirsangiz, ilova bir soniyada yangilanadi (JIT)',
      ]),
      HeadingBlock('Dart va Flutter farqi'),
      ParaBlock('**Dart — til**, **Flutter — framework** (tayyor qismlar to\'plami). Flutter ilovalari Dart tilida yoziladi. Ya\'ni avval Dartni bilish kerak, keyin Flutter bilan chiroyli interfeys quriladi.'),
    ],
    analogy: AnalogyBlock(
      'Til va konstruktor',
      'Dart — o\'zbek tili kabi: so\'zlar va grammatika. Flutter — shu tilda yozilgan "uy qurish qo\'llanmasi va tayyor g\'ishtlar". G\'ishtlarni (widgetlarni) terish uchun avval qo\'llanma tilini bilishingiz kerak.',
      icon: Icons.foundation_outlined,
    ),
    why: 'Flutterdagi har bir tugma, sahifa va animatsiya Dart kodi. Dartni puxta bilsangiz, Flutterni o\'rganish ikki barobar tez bo\'ladi.',
    where: [
      'Flutter mobil ilovalari (Android, iOS)',
      'Flutter Web va Desktop ilovalari',
      'Server dasturlari (Dart Frog, Serverpod, shelf)',
      'Buyruq qatori (CLI) dasturlari',
    ],
    terms: [
      TermBlock(term: 'Framework', uz: 'Freymvork', meaning: 'Dastur qurish uchun tayyor qismlar va qoidalar to\'plami.', why: 'Hammasini noldan yozmaslik uchun.', example: 'Flutter'),
      TermBlock(term: 'JIT (Just-In-Time)', uz: 'Ish vaqtida kompilyatsiya', meaning: 'Kod ishlash jarayonida kompilyatsiya qilinadi.', why: 'Ishlab chiqishda hot reload ni ta\'minlaydi.'),
      TermBlock(term: 'AOT (Ahead-Of-Time)', uz: 'Oldindan kompilyatsiya', meaning: 'Kod ilova chiqarilishidan oldin mashina kodiga aylantiriladi.', why: 'Tayyor ilova tez ishga tushadi va tez ishlaydi.'),
      TermBlock(term: 'Hot reload', uz: 'Issiq qayta yuklash', meaning: 'O\'zgarishni ilovani o\'chirmasdan bir zumda ko\'rish.', why: 'Dizayn ustida ishlash juda tezlashadi.'),
    ],
    animation: AnimationBlock('dart_flutter', 'Dart (til) → Flutter (framework) → Android, iOS, Web, Desktop.'),
    example: CodeBlock(
      r'''void main() {
  print('Dart — til');
  print('Flutter — framework');
  print('Birgalikda — kuchli ilovalar!');
}''',
      title: 'Dart dasturi',
      expectedOutput: 'Dart — til\nFlutter — framework\nBirgalikda — kuchli ilovalar!\n',
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  print('Dart — til');
  Print('Flutter — framework');
}''',
      task: 'Ikkinchi qator ishlamayapti. Xato xabarini o\'qing va tuzating.',
      why: 'Dart katta-kichik harfni farqlaydi: `Print` va `print` — boshqa-boshqa nomlar. Funksiya nomi kichik harf bilan: `print`.',
      fixed: r'''void main() {
  print('Dart — til');
  print('Flutter — framework');
}''',
      hint: 'Ikkinchi qatordagi funksiya nomining birinchi harfiga qarang.',
    ),
    task: CodeTask(
      title: 'Dart haqida 3 fakt',
      instructions: 'Dart haqida o\'rgangan **3 ta faktni** alohida qatorlarda chiqaring. Birinchi qator aynan `Dart Google tomonidan yaratilgan` bo\'lsin.',
      starter: r'''void main() {
  print('Dart Google tomonidan yaratilgan');
}''',
      checks: [
        OutputContains('Dart Google tomonidan yaratilgan', label: 'Birinchi fakt'),
        UsesConstruct(r"print[\s\S]*print[\s\S]*print", 'Kamida 3 ta print() kerak'),
      ],
      hints: ['Yana ikkita print() qo\'shing.', "print('Flutter Dart tilida yoziladi');", 'Har bir print() oxirida ; bo\'lishini unutmang.'],
      solution: r'''void main() {
  print('Dart Google tomonidan yaratilgan');
  print('Flutter Dart tilida yoziladi');
  print('Dart null safety ga ega');
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Dart va Flutter o\'rtasidagi to\'g\'ri munosabat qaysi?',
        options: ['Dart — framework, Flutter — til', 'Dart — til, Flutter — shu tilda yozilgan framework', 'Ikkalasi bir narsa', 'Flutter Python tilida yozilgan'],
        correct: 1,
        explanation: 'Flutter ilovalari Dart tilida yoziladi. Dart — til, Flutter — framework.',
        topic: 'Dart va Flutter',
      ),
      SingleChoice(
        prompt: 'Hot reload ni nima ta\'minlaydi?',
        options: ['AOT kompilyatsiya', 'JIT kompilyatsiya', 'Git', 'Terminal'],
        correct: 1,
        explanation: 'Ishlab chiqish paytida Dart JIT rejimida ishlaydi va o\'zgarishlarni darhol qo\'llaydi.',
        topic: 'JIT/AOT',
      ),
      MultiChoice(
        prompt: 'Dart qayerlarda ishlatiladi? (bir nechtasini tanlang)',
        options: ['Mobil ilovalar', 'Web ilovalar', 'Server dasturlari', 'Faqat Windows'],
        correct: {0, 1, 2},
        explanation: 'Dart ko\'p platformali til: mobil, web, desktop va server.',
        topic: 'Dart',
      ),
    ],
    summary: [
      'Dart — Google yaratgan, tez va xavfsiz til',
      'Dart — til, Flutter — Dartda yozilgan framework',
      'JIT — ishlab chiqishda (hot reload), AOT — tayyor ilovada (tezlik)',
    ],
    next: 'Keyingi darsda har bir Dart dasturining kirish nuqtasi — main() va ekranga chiqarish — print() ni chuqur o\'rganamiz.',
    revisionTip: 'Do\'stingizga Dart va Flutter farqini 2 gapda tushuntirib bering.',
    links: [DocLink('Dart rasmiy sayti', 'https://dart.dev'), DocLink('Dart overview', 'https://dart.dev/overview')],
  ),

  // ───────────────────────── 1.2 ─────────────────────────
  Lesson(
    id: 'l1_main_print',
    title: 'main() va print() — birinchi dastur',
    subtitle: 'Dastur qayerdan boshlanadi va qanday natija chiqaradi',
    icon: Icons.play_circle_outline_rounded,
    minutes: 12,
    skills: ['dart.main', 'dart.print'],
    prerequisites: ['Dart nima va nega yaratilgan?'],
    objectives: [
      '`main()` funksiyasi nima uchun kerakligini bilasiz',
      '`print()` bilan istalgan matnni chiqara olasiz',
      'Qavslar va `;` xatolarini mustaqil tuzata olasiz',
    ],
    intro: [
      ParaBlock('Har bir Dart dasturi **`main()`** funksiyasidan boshlanadi. Kompyuter dasturni ishga tushirganda birinchi bo\'lib aynan `main` ni qidiradi. U bo\'lmasa — dastur ishga tushmaydi.'),
      ParaBlock('`main` ichidagi buyruqlar **jingalak qavslar** `{ }` orasiga yoziladi va **yuqoridan pastga**, birin-ketin bajariladi.'),
      ParaBlock('**`print()`** — qavs ichidagi qiymatni **konsolga** (natija oynasiga) chiqaradi va keyingi qatorga o\'tadi. Matn qo\'shtirnoq ichida yoziladi: `\'Salom\'` yoki `"Salom"`.'),
      ParaBlock('Har bir buyruq oxirida **nuqtali vergul** `;` qo\'yiladi — bu "buyruq tugadi" degani.'),
    ],
    analogy: AnalogyBlock(
      'Uyning eshigi',
      '`main()` — uyning kirish eshigi. Mehmon (kompyuter) har doim shu eshikdan kiradi va ichkaridagi xonalarni (buyruqlarni) tartib bilan aylanadi. `print()` esa uyning derazasi — ichkarida nima bo\'layotganini tashqariga ko\'rsatadi.',
      icon: Icons.door_front_door_outlined,
    ),
    why: '`print()` — dasturchining eng birinchi va eng ko\'p ishlatiladigan "ko\'zi". Kod nima qilayotganini, qiymatlar qanday ekanini ko\'rish va xatolarni topish uchun ishlatiladi.',
    where: [
      'Har bir Dart va Flutter dasturining boshlanishi — main()',
      'Debugging: o\'zgaruvchi qiymatini tekshirish uchun print()',
      'Konsol (CLI) dasturlarida natija chiqarish',
    ],
    terms: [
      TermBlock(term: 'Function', uz: 'Funksiya', meaning: 'Nomga ega buyruqlar bloki.', why: 'Kodni tartibli bo\'laklarga ajratadi.', example: 'main()'),
      TermBlock(term: 'Console', uz: 'Konsol', meaning: 'Dastur matn chiqaradigan oyna.', why: 'print() natijasi shu yerda ko\'rinadi.'),
      TermBlock(term: 'String', uz: 'Satr (matn)', meaning: 'Qo\'shtirnoq ichidagi belgilar ketma-ketligi.', why: 'Matnli ma\'lumot uchun.', example: "'Salom'"),
      TermBlock(term: 'Statement', uz: 'Buyruq (operator)', meaning: 'Bitta to\'liq ko\'rsatma.', why: 'Dastur buyruqlardan tuziladi.', example: "print('Hi');"),
    ],
    animation: AnimationBlock('program_flow', 'main() boshlanadi → buyruqlar tartib bilan bajariladi → konsolga natija.'),
    syntax: SyntaxBlock(r'''void main() {
  print(qiymat);
}''', [
      SyntaxPart('void', 'main hech qanday natija qaytarmaydi'),
      SyntaxPart('main()', 'dasturning kirish nuqtasi (nomi o\'zgarmaydi!)'),
      SyntaxPart('{ ... }', 'funksiya tanasi — buyruqlar shu yerda'),
      SyntaxPart('print(...)', 'qavs ichidagini konsolga chiqaradi'),
      SyntaxPart(';', 'har bir buyruq oxirida'),
    ]),
    example: CodeBlock(
      r'''void main() {
  print('Assalomu alaykum!');
  print("Men Dart o'rganyapman");
  print(2024);
  print(10 + 5);
}''',
      title: 'print() turli qiymatlar bilan',
      explain: {
        'void': 'main hech narsa qaytarmaydi.',
        'main': 'Dastur shu yerdan boshlanadi.',
        'print': 'Qiymatni konsolga chiqaradi va yangi qatorga o\'tadi.',
        "'Assalomu alaykum!'": 'Bitta qo\'shtirnoqli matn.',
        "\"Men Dart o'rganyapman\"": 'Ichida \' bor matnni qo\'sh qo\'shtirnoqda yozish qulay.',
        '2024': 'Son — qo\'shtirnoqsiz yoziladi.',
        '10': 'Son.',
        '+': 'Qo\'shish amali — print natijani (15) chiqaradi.',
      },
      lineNotes: {1: 'Kirish nuqtasi', 2: 'Matn', 3: 'Ichida apostrof bor matn', 4: 'Son', 5: 'Avval hisoblanadi, keyin chiqariladi'},
      expectedOutput: "Assalomu alaykum!\nMen Dart o'rganyapman\n2024\n15\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  print('Salom')
  print('Dunyo');
}''',
      task: 'Kod ishlamayapti. Xatoni toping va tuzating.',
      why: '2-qatorda buyruq oxirida `;` yetishmayapti. Dart har bir buyruq qayerda tugashini aynan `;` orqali biladi.',
      fixed: r'''void main() {
  print('Salom');
  print('Dunyo');
}''',
      hint: 'Har bir print() qatorining oxiriga qarang.',
    ),
    task: CodeTask(
      title: 'Tashrif qog\'ozi',
      instructions: 'Quyidagi 3 qatorni aynan shu tartibda chiqaring:\n`Ism: Aziz`\n`Yosh: 20`\n`Shahar: Toshkent`',
      starter: r'''void main() {
  // Bu yerga yozing
}''',
      checks: [OutputEquals('Ism: Aziz\nYosh: 20\nShahar: Toshkent\n', label: 'Aniq 3 qator')],
      hints: [
        'Har bir qator uchun alohida print() kerak.',
        "Birinchi qator: print('Ism: Aziz');",
        r'''print('Ism: Aziz');
print('Yosh: 20');''',
      ],
      solution: r'''void main() {
  print('Ism: Aziz');
  print('Yosh: 20');
  print('Shahar: Toshkent');
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Dart dasturi qaysi funksiyadan boshlanadi?',
        options: ['start()', 'main()', 'print()', 'run()'],
        correct: 1,
        explanation: 'Har bir Dart dasturining kirish nuqtasi — main().',
        topic: 'main',
      ),
      PredictOutput(
        prompt: 'Natijani taxmin qiling',
        code: r'''void main() {
  print(3 + 4);
  print('3 + 4');
}''',
        options: ['7\n7', '3 + 4\n3 + 4', '7\n3 + 4', 'Xato'],
        explanation: 'Qo\'shtirnoqsiz `3 + 4` — hisoblanadi (7). Qo\'shtirnoq ichidagisi — oddiy matn.',
        topic: 'print',
      ),
      FindBug(
        prompt: 'Qaysi qatorda xato bor?',
        code: r'''void main() {
  print('Bir');
  print('Ikki';
  print('Uch');
}''',
        bugLine: 3,
        explanation: '3-qatorda yopuvchi qavs `)` yetishmayapti: print(\'Ikki\');',
        topic: 'Sintaksis',
      ),
      FillBlank(
        prompt: 'Bo\'sh joyni to\'ldiring, natija `Dart` bo\'lsin',
        template: "void main() {\n  ____('Dart');\n}",
        accepted: ['print'],
        expectedOutput: 'Dart\n',
        explanation: 'Konsolga chiqarish funksiyasi — print.',
        topic: 'print',
      ),
    ],
    summary: [
      'Dastur `main()` dan boshlanadi',
      '`print()` qiymatni konsolga chiqaradi',
      'Matn qo\'shtirnoqda, son qo\'shtirnoqsiz yoziladi',
      'Har bir buyruq oxirida `;`',
    ],
    next: 'Keyingi darsda kodga izoh (comment) yozish va Dart sintaksisining asosiy qoidalarini o\'rganamiz.',
    revisionTip: 'Ataylab `;` ni o\'chirib, xato xabarini o\'qing — so\'ng tuzating. Xatolarni o\'qishni o\'rganish juda muhim.',
    links: [_dartDocs],
  ),

  // ───────────────────────── 1.3 ─────────────────────────
  Lesson(
    id: 'l1_comments',
    title: 'Izohlar va sintaksis qoidalari',
    subtitle: 'Kodni odamlar uchun ham tushunarli qilish',
    icon: Icons.notes_rounded,
    minutes: 8,
    skills: ['dart.syntax'],
    prerequisites: ['main() va print() — birinchi dastur'],
    objectives: [
      'Bir qatorli va ko\'p qatorli izoh yoza olasiz',
      'Dart katta-kichik harfni farqlashini bilasiz',
      'Kodni toza va o\'qishli yozish qoidalarini qo\'llaysiz',
    ],
    intro: [
      ParaBlock('**Izoh** (comment) — kodga yoziladigan, lekin **bajarilmaydigan** matn. U kompyuter uchun emas, **odamlar uchun**: siz va jamoangiz kodni tushunishi uchun.'),
      BulletsBlock([
        '`// ...` — bir qatorli izoh. `//` dan keyingi hamma narsa e\'tiborsiz qoldiriladi.',
        '`/* ... */` — ko\'p qatorli izoh.',
        '`/// ...` — hujjat izohi (documentation). Funksiya yoki class nimaligini tushuntirish uchun.',
      ]),
      HeadingBlock('Asosiy sintaksis qoidalari'),
      BulletsBlock([
        'Dart **katta-kichik harfni farqlaydi**: `print` to\'g\'ri, `Print` — xato',
        'Har bir buyruq `;` bilan tugaydi',
        'Har bir ochilgan qavs yopilishi kerak: `( )`, `{ }`, `[ ]`',
        'Bloklar ichidagi kod 2 ta bo\'shliq bilan suriladi (chekinish) — o\'qishni osonlashtiradi',
      ]),
    ],
    analogy: AnalogyBlock(
      'Daftardagi qaydlar',
      'Matematika masalasini yechayotganda chetga "bu yerda formulani qo\'lladim" deb qayd yozasiz. O\'qituvchi qaydni baholamaydi, lekin u yechimni tushunishga yordam beradi. Izohlar ham xuddi shunday.',
      icon: Icons.edit_note_rounded,
    ),
    why: 'Professional loyihalarda kodni bir kishi yozadi, o\'nlab kishi o\'qiydi. Yaxshi izoh va toza sintaksis jamoaviy ishning asosi. Shuningdek, izoh bilan kod qatorini vaqtincha "o\'chirib" sinab ko\'rish mumkin.',
    where: [
      'Murakkab algoritmni tushuntirish',
      'Funksiya nima qilishini hujjatlashtirish (///)',
      'Debug paytida kodni vaqtincha o\'chirish',
    ],
    terms: [
      TermBlock(term: 'Comment', uz: 'Izoh', meaning: 'Bajarilmaydigan tushuntirish matni.', why: 'Kodni tushunarli qiladi.', example: '// hisoblash'),
      TermBlock(term: 'Case-sensitive', uz: 'Harf registriga sezgir', meaning: 'Katta va kichik harflar farqlanadi.', why: 'print va Print — boshqa-boshqa nomlar.'),
      TermBlock(term: 'Indentation', uz: 'Chekinish', meaning: 'Qator boshidagi bo\'shliqlar.', why: 'Kod tuzilishini ko\'rsatadi.'),
    ],
    example: CodeBlock(
      r'''/// Dastur boshlanadi.
void main() {
  // Bu bir qatorli izoh — bajarilmaydi
  print('Birinchi');
  /* Bu ko'p qatorli izoh.
     print('Ko\'rinmaydi'); */
  // print('Bu ham bajarilmaydi');
  print('Oxirgi'); // izoh qator oxirida ham bo'ladi
}''',
      title: 'Izoh turlari',
      expectedOutput: 'Birinchi\nOxirgi\n',
      lineNotes: {1: 'Hujjat izohi', 3: 'Bir qatorli izoh', 5: 'Ko\'p qatorli izoh boshlanishi', 7: 'Izohga aylantirilgan kod'},
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  Print('Salom');
}''',
      task: 'Xato xabarini o\'qing va kodni tuzating.',
      why: 'Dart katta-kichik harfni farqlaydi. Funksiya nomi `print` — kichik harf bilan.',
      fixed: r'''void main() {
  print('Salom');
}''',
      hint: 'Funksiya nomidagi birinchi harfga qarang.',
    ),
    task: CodeTask(
      title: 'Izohni boshqarish',
      instructions: 'Kodda 3 ta print bor. Faqat `Ko\'rinadi` matni chiqishi uchun qolgan ikkitasini **o\'chirmasdan**, izohga aylantiring.',
      starter: r'''void main() {
  print('Yashirin 1');
  print("Ko'rinadi");
  print('Yashirin 2');
}''',
      checks: [
        OutputEquals("Ko'rinadi\n", label: 'Faqat bitta qator chiqishi kerak'),
        UsesConstruct(r"//\s*print\('Yashirin 1'\)|/\*", 'Qatorlarni o\'chirmang — izohga aylantiring', inComments: true),
      ],
      hints: ['Qator boshiga // qo\'ying.', "// print('Yashirin 1');", 'Ikkala "Yashirin" qatorini ham // bilan boshlang.'],
      solution: r'''void main() {
  // print('Yashirin 1');
  print("Ko'rinadi");
  // print('Yashirin 2');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija nechta qator bo\'ladi va qanday?',
        code: r'''void main() {
  print('A');
  // print('B');
  print('C'); // print('D');
}''',
        options: ['A\nB\nC\nD', 'A\nC', 'A\nC\nD', 'A'],
        explanation: '`//` dan keyingi hamma narsa izoh. Faqat A va C chiqadi.',
        topic: 'Izohlar',
      ),
      TrueFalse(
        prompt: 'Dartda `Main()` va `main()` bir xil.',
        answer: false,
        explanation: 'Dart katta-kichik harfni farqlaydi. Dastur faqat `main` (kichik harf) dan boshlanadi.',
        topic: 'Sintaksis',
      ),
      SingleChoice(
        prompt: 'Ko\'p qatorli izoh qanday yoziladi?',
        options: ['// ... //', '/* ... */', '<!-- ... -->', '# ...'],
        correct: 1,
        explanation: 'Dartda ko\'p qatorli izoh `/*` bilan boshlanib `*/` bilan tugaydi.',
        topic: 'Izohlar',
      ),
    ],
    summary: [
      '`//` — bir qatorli, `/* */` — ko\'p qatorli, `///` — hujjat izohi',
      'Izohlar bajarilmaydi — ular odamlar uchun',
      'Dart katta-kichik harfga sezgir',
      'Qavslar juft bo\'lishi va `;` qo\'yilishi shart',
    ],
    next: 'Endi dasturlashning eng muhim tushunchasi — o\'zgaruvchilarga o\'tamiz!',
    revisionTip: 'Oldingi darsdagi kodlarga har bir qator nima qilishini tushuntiruvchi izoh yozib chiqing.',
  ),

  // ───────────────────────── 1.4 — VERTIKAL SLAYS ─────────────────────────
  Lesson(
    id: 'l1_variables',
    title: 'O\'zgaruvchilar',
    subtitle: 'Ma\'lumotni nom bilan saqlash va o\'zgartirish',
    icon: Icons.inventory_2_outlined,
    minutes: 15,
    xp: 60,
    skills: ['dart.variables'],
    prerequisites: ['main() va print() — birinchi dastur'],
    objectives: [
      'O\'zgaruvchi nima ekanini va nima uchun kerakligini bilasiz',
      'O\'zgaruvchi e\'lon qilish, qiymat berish va o\'zgartirishni o\'rganasiz',
      'O\'zgaruvchiga to\'g\'ri nom berish qoidalarini qo\'llaysiz',
      'Kodni qadam-baqadam bajarib, xotirada nima bo\'layotganini ko\'rasiz',
    ],
    intro: [
      ParaBlock('**O\'zgaruvchi** (variable) — xotiradagi **nomlangan quti**. Unga qiymat (son, matn va h.k.) solamiz va keyin shu nom orqali ishlatamiz.'),
      ParaBlock('Dartda o\'zgaruvchi shunday e\'lon qilinadi:'),
      ParaBlock('`int yosh = 18;` — bu "**int** turidagi **yosh** nomli quti yarat va unga **18** qiymatini sol" degani.'),
      BulletsBlock([
        '**`int`** — tur: bu qutiga faqat butun son solinadi',
        '**`yosh`** — o\'zgaruvchi nomi',
        '**`=`** — qiymat berish (tenglik emas!)',
        '**`18`** — qiymat',
      ]),
      ParaBlock('Nomi "**o\'zgaruvchi**", chunki qiymatini keyinchalik **o\'zgartirish** mumkin: `yosh = 19;` — endi qutida 19 turadi (eski 18 o\'chadi).'),
      HeadingBlock('Nom berish qoidalari'),
      BulletsBlock([
        'Harf yoki `_` bilan boshlanadi: `yosh`, `_hisob` ✓, `2ism` ✗',
        'Bo\'shliq bo\'lmaydi: `talabaIsmi` ✓, `talaba ismi` ✗',
        'Kalit so\'zlar nom bo\'lolmaydi: `int`, `void`, `class` ✗',
        'Dart uslubi — **lowerCamelCase**: `foydalanuvchiYoshi`, `umumiyNarx`',
        'Ma\'noli nom tanlang: `x` emas, `narx`',
      ]),
    ],
    analogy: AnalogyBlock(
      'Yorliqli quti',
      'Ko\'chish paytida qutilarga yorliq yopishtirasiz: "Kitoblar", "Idishlar". Keyin "Kitoblar" qutisini ochsangiz, ichida kitob bo\'ladi. O\'zgaruvchi ham shunday: yorlig\'i — nomi, ichidagisi — qiymati. Qutini bo\'shatib, boshqa narsa solish ham mumkin — bu qiymatni o\'zgartirish.',
      icon: Icons.inventory_2_outlined,
    ),
    why: 'Deyarli har bir dastur ma\'lumotni eslab qolishi kerak: foydalanuvchi ismi, savatchadagi narx, o\'yindagi ball. O\'zgaruvchilarsiz dastur hech narsani "eslay olmaydi".',
    where: [
      'O\'yindagi ball: `int ball = 0;`',
      'Login sahifasidagi email: `String email = \'...\';`',
      'Savatchadagi umumiy narx: `double jami = 125.5;`',
      'Flutterda ekrandagi hamma o\'zgaruvchan ma\'lumot',
    ],
    terms: [
      TermBlock(term: 'Variable', uz: 'O\'zgaruvchi', meaning: 'Qiymat saqlanadigan nomlangan xotira joyi.', why: 'Ma\'lumotni eslab qolish va qayta ishlatish uchun.', example: 'int yosh = 18;'),
      TermBlock(term: 'Declaration', uz: 'E\'lon qilish', meaning: 'Yangi o\'zgaruvchi yaratish.', why: 'Ishlatishdan oldin o\'zgaruvchi e\'lon qilinishi shart.'),
      TermBlock(term: 'Assignment', uz: 'Qiymat berish', meaning: '`=` orqali o\'zgaruvchiga qiymat yozish.', why: 'Qiymatni yangilash uchun.', example: 'yosh = 19;'),
      TermBlock(term: 'Type', uz: 'Tur', meaning: 'Qutiga qanday qiymat solinishini belgilaydi.', why: 'Xatolarni oldindan ushlash uchun.', example: 'int, String'),
      TermBlock(term: 'camelCase', uz: 'Tuya uslubi', meaning: 'So\'zlar birlashtirilib, keyingilari katta harf bilan.', why: 'Dart nomlash standarti.', example: 'umumiyNarx'),
    ],
    animation: AnimationBlock('variable_box', '`int yosh = 18;` — xotirada "yosh" nomli quti paydo bo\'ladi va unga 18 joylanadi.'),
    syntax: SyntaxBlock('Tur nom = qiymat;', [
      SyntaxPart('Tur', 'qanday qiymat saqlanadi: int, double, String, bool'),
      SyntaxPart('nom', 'o\'zgaruvchi nomi (lowerCamelCase)'),
      SyntaxPart('=', 'qiymat berish operatori'),
      SyntaxPart('qiymat', 'boshlang\'ich qiymat'),
      SyntaxPart(';', 'buyruq oxiri'),
    ]),
    example: CodeBlock(
      r'''void main() {
  int yosh = 18;
  print(yosh);
}''',
      title: 'Birinchi o\'zgaruvchi',
      explain: {
        'void': '`main` funksiyasi hech qanday qiymat qaytarmaydi.',
        'main': 'Dastur shu funksiyadan boshlanadi.',
        'int': 'Integer — butun son turi. Bu qutiga faqat butun son (…, -1, 0, 1, 2, …) solinadi.',
        'yosh': 'O\'zgaruvchi nomi. Shu nom orqali qiymatga murojaat qilamiz.',
        '=': 'Qiymat berish operatori: o\'ngdagi qiymat chapdagi o\'zgaruvchiga yoziladi.',
        '18': 'Qiymat — butun son. Xotirada "yosh" qutisiga joylanadi.',
        'print': 'Qavs ichidagi o\'zgaruvchining qiymatini konsolga chiqaradi (nomini emas!).',
        ';': 'Buyruq tugadi.',
      },
      lineNotes: {2: '"yosh" qutisi yaratiladi va 18 solinadi', 3: 'Qutidagi qiymat (18) chiqariladi'},
      expectedOutput: '18\n',
      visualize: true,
    ),
    examples: [
      CodeBlock(
        r'''void main() {
  String ism = 'Malika';
  int yosh = 18;
  print(ism);
  print(yosh);

  yosh = yosh + 1;
  print('Bir yildan keyin:');
  print(yosh);
}''',
        title: 'Qiymatni o\'zgartirish',
        lineNotes: {7: 'Avval o\'ng tomon hisoblanadi: 18 + 1 = 19, keyin yosh ga yoziladi'},
        expectedOutput: 'Malika\n18\nBir yildan keyin:\n19\n',
        visualize: true,
      ),
    ],
    extra: [
      CalloutBlock(CalloutKind.warning, '`=` — tenglik emas!', 'Matematikada `x = x + 1` mantiqsiz. Dasturlashda esa bu: "x ning hozirgi qiymatiga 1 qo\'shib, natijani yana x ga yoz". Taqqoslash uchun `==` ishlatiladi — buni keyinroq o\'rganamiz.'),
      CalloutBlock(CalloutKind.tip, 'Qadam-baqadam ko\'ring', 'Kod ostidagi **"Qadam-baqadam"** tugmasini bosing: xotirada qutilar qanday yaratilib, qiymatlari qanday o\'zgarishini ko\'rasiz. Bu interpretator haqiqatda bajargan qadamlar.'),
    ],
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int yosh = 'o\'n sakkiz';
  print(yosh);
}''',
      task: 'Kod ishga tushmayapti. Xato xabarini o\'qing va `yosh` ga to\'g\'ri qiymat bering.',
      why: '`int` turidagi qutiga faqat butun son solinadi. `\'o\'n sakkiz\'` — bu matn (String). Dart buni kod ishga tushmasdan oldin aniqlaydi — bu **tur xavfsizligi** (type safety).',
      fixed: r'''void main() {
  int yosh = 18;
  print(yosh);
}''',
      hint: 'Qo\'shtirnoq ichidagi narsa — matn. int ga son kerak.',
    ),
    task: CodeTask(
      title: 'Yoshni o\'zgartiring',
      instructions: '1) `yosh` nomli `int` o\'zgaruvchi yarating va unga **25** bering.\n2) Uni chiqaring.\n3) Keyin `yosh` ni **5 ga oshiring** (`yosh = yosh + 5;`) va yana chiqaring.\nNatija:\n`25`\n`30`',
      starter: r'''void main() {
  // 1. O'zgaruvchi yarating

  // 2. Chiqaring

  // 3. 5 ga oshiring va yana chiqaring
}''',
      checks: [
        OutputEquals('25\n30\n', label: 'Natija 25 va 30'),
        UsesConstruct(r'int\s+yosh\s*=\s*25', '`int yosh = 25;` e\'lon qilinishi kerak'),
        UsesConstruct(r'yosh\s*(=\s*yosh\s*\+\s*5|\+=\s*5)', '`yosh` qiymati 5 ga oshirilishi kerak (30 ni to\'g\'ridan-to\'g\'ri yozmang)'),
      ],
      hints: [
        'Avval: int yosh = 25;',
        'Chiqarish: print(yosh);',
        r'''int yosh = 25;
print(yosh);
yosh = yosh + 5;''',
      ],
      solution: r'''void main() {
  int yosh = 25;
  print(yosh);
  yosh = yosh + 5;
  print(yosh);
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: '`int narx = 5000;` qatorida o\'zgaruvchining nomi qaysi?',
        options: ['int', 'narx', '5000', '='],
        correct: 1,
        explanation: '`int` — tur, `narx` — nom, `5000` — qiymat.',
        topic: 'O\'zgaruvchilar',
      ),
      PredictOutput(
        prompt: 'Natija nima bo\'ladi?',
        code: r'''void main() {
  int a = 10;
  a = a + 5;
  a = a + 5;
  print(a);
}''',
        options: ['10', '15', '20', 'a'],
        explanation: '10 → 15 → 20. Har safar o\'ng tomon hisoblanib, a ga qayta yoziladi.',
        topic: 'Qiymat berish',
      ),
      MultiChoice(
        prompt: 'Qaysi nomlar Dartda TO\'G\'RI? (bir nechtasini tanlang)',
        options: ['talabaIsmi', '2ball', 'umumiy_narx', 'int', '_maxfiy'],
        correct: {0, 2, 4},
        explanation: 'Nom raqam bilan boshlanmaydi va kalit so\'z (int) bo\'lolmaydi. Dart uslubida camelCase tavsiya etiladi, lekin `umumiy_narx` ham sintaktik jihatdan to\'g\'ri.',
        topic: 'Nomlash',
      ),
      FillBlank(
        prompt: 'Bo\'sh joyni to\'ldiring: natija `7` bo\'lsin',
        template: 'void main() {\n  int son = ____;\n  print(son);\n}',
        expectedOutput: '7\n',
        explanation: '`son` ga 7 qiymati berilishi kerak.',
        topic: 'O\'zgaruvchilar',
      ),
    ],
    summary: [
      'O\'zgaruvchi — nomlangan quti: `Tur nom = qiymat;`',
      '`=` — qiymat berish, `==` — taqqoslash',
      'Qiymatni o\'zgartirish: `yosh = yosh + 1;`',
      'Nom: harf bilan boshlanadi, bo\'shliqsiz, lowerCamelCase',
      'Dart turga mos kelmaydigan qiymatni oldindan rad etadi',
    ],
    next: 'Keyingi darsda o\'zgaruvchi yaratishning uch usuli — `var`, `final` va `const` ni o\'rganamiz.',
    revisionTip: 'O\'zingiz haqingizda 4 ta o\'zgaruvchi yarating (ism, yosh, shahar, bo\'y) va ularni chiqaring. Keyin "Qadam-baqadam" bilan tekshiring.',
    links: [DocLink('Variables (rasmiy hujjat)', 'https://dart.dev/language/variables')],
  ),

  // ───────────────────────── 1.5 ─────────────────────────
  Lesson(
    id: 'l1_var_final_const',
    title: 'var, final va const',
    subtitle: 'O\'zgaradigan va o\'zgarmaydigan qiymatlar',
    icon: Icons.lock_outline_rounded,
    minutes: 12,
    skills: ['dart.final_const'],
    prerequisites: ['O\'zgaruvchilar'],
    objectives: [
      '`var` bilan turni avtomatik aniqlashni (type inference) tushunasiz',
      '`final` va `const` farqini bilasiz',
      'Qachon qaysi birini ishlatishni tanlay olasiz',
    ],
    intro: [
      ParaBlock('**`var`** — "turini o\'zing aniqla" degani. `var shahar = \'Buxoro\';` — Dart o\'ng tomonga qarab `shahar` ning turi `String` ekanini o\'zi tushunadi. Bu **type inference** (turni xulosa qilish) deyiladi.'),
      CalloutBlock(CalloutKind.warning, 'Diqqat', '`var` turni **bir marta** aniqlaydi. `var son = 5;` dan keyin `son = \'besh\';` — xato, chunki `son` endi abadiy `int`.'),
      ParaBlock('**`final`** — qiymat **faqat bir marta** beriladi va keyin o\'zgarmaydi. Masalan, foydalanuvchining tug\'ilgan yili.'),
      ParaBlock('**`const`** — **kompilyatsiya vaqtidayoq** ma\'lum bo\'lgan o\'zgarmas. Masalan, `const pi = 3.14159;`. Uning qiymati kod yozilayotgandayoq aniq bo\'lishi kerak.'),
      HeadingBlock('final va const farqi'),
      BulletsBlock([
        '`final` — qiymat dastur **ishlayotganda** aniqlanishi mumkin: `final hozir = DateTime.now();` ✓',
        '`const` — qiymat **kod yozilganda** aniq bo\'lishi kerak: `const hozir = DateTime.now();` ✗',
      ]),
      ParaBlock('**Qoida:** avval `final` ni ishlating. Faqat qiymat haqiqatan o\'zgarishi kerak bo\'lsa — `var` (yoki tur nomi). Doimiy sozlamalar uchun — `const`.'),
    ],
    analogy: AnalogyBlock(
      'Doska, pasport va tosh yozuv',
      '`var` — doska: yozib, o\'chirib, qayta yozish mumkin. `final` — pasport: bir marta beriladi, keyin o\'zgarmaydi, lekin u siz tug\'ilgandan keyin (dastur ishlaganda) beriladi. `const` — toshga o\'yilgan yozuv: haykaltarosh uni ustaxonadayoq (kompilyatsiya vaqtida) o\'yadi.',
      icon: Icons.badge_outlined,
    ),
    why: 'O\'zgarmas qiymatlar dasturni xavfsizroq qiladi: tasodifan muhim qiymatni o\'zgartirib yuborolmaysiz. Flutterda `const` widgetlar ilovani tezroq ham qiladi.',
    where: [
      '`const` — ranglar, o\'lchamlar, API manzillar',
      '`final` — serverdan kelgan ma\'lumot, foydalanuvchi ID si',
      '`var` — hisoblagich, o\'yindagi ball',
      'Flutter: `const Text(\'Salom\')` — qayta qurilmaydi, tez',
    ],
    terms: [
      TermBlock(term: 'Type inference', uz: 'Turni xulosa qilish', meaning: 'Dart turni qiymatdan o\'zi aniqlaydi.', why: 'Kod qisqa, lekin xavfsiz bo\'ladi.', example: 'var x = 5; // int'),
      TermBlock(term: 'Immutable', uz: 'O\'zgarmas', meaning: 'Yaratilgandan keyin o\'zgartirib bo\'lmaydigan.', why: 'Xatolarning oldini oladi.'),
      TermBlock(term: 'Compile-time constant', uz: 'Kompilyatsiya vaqtidagi o\'zgarmas', meaning: 'Qiymati kod yozilganda aniq.', why: 'Tezlik va xotira tejash.', example: 'const pi = 3.14;'),
    ],
    animation: AnimationBlock('final_const', 'var — o\'zgaradi, final — qulflanadi, const — oldindan muhrlanadi.'),
    example: CodeBlock(
      r'''void main() {
  var ball = 10;
  ball = ball + 5;
  print(ball);

  final ism = 'Jasur';
  print(ism);

  const pi = 3.14159;
  print(pi);

  final yuza = pi * 2 * 2;
  print(yuza);
}''',
      title: 'Uchalasi birga',
      explain: {
        'var': 'Tur avtomatik aniqlanadi (bu yerda int). Qiymatni o\'zgartirish mumkin.',
        'final': 'Bir marta beriladi. Qayta qiymat berib bo\'lmaydi.',
        'const': 'Kompilyatsiya vaqtidagi o\'zgarmas.',
        'pi': 'const o\'zgaruvchi — qiymati doim 3.14159.',
      },
      expectedOutput: '15\nJasur\n3.14159\n12.56636\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  final shahar = 'Samarqand';
  shahar = 'Xiva';
  print(shahar);
}''',
      task: '`shahar` qiymati o\'zgarishi kerak. Kodni ishlaydigan qiling.',
      why: '`final` o\'zgaruvchiga faqat bir marta qiymat beriladi. Qiymat o\'zgarishi kerak bo\'lsa, `var` ishlatiladi.',
      fixed: r'''void main() {
  var shahar = 'Samarqand';
  shahar = 'Xiva';
  print(shahar);
}''',
      hint: 'Qaysi kalit so\'z qayta qiymat berishga ruxsat beradi?',
    ),
    task: CodeTask(
      title: 'Do\'kon hisobi',
      instructions: '1) `const` bilan `soliq` = `0.12` yarating.\n2) `final` bilan `narx` = `1000` yarating.\n3) `var` bilan `jami` = `narx + narx * soliq` hisoblang va chiqaring.\nNatija: `1120.0`',
      starter: r'''void main() {
  // const, final va var dan foydalaning
}''',
      checks: [
        OutputEquals('1120.0\n', label: 'Natija 1120.0'),
        UsesConstruct(r'const\s+soliq', '`soliq` — const bo\'lishi kerak'),
        UsesConstruct(r'final\s+narx', '`narx` — final bo\'lishi kerak'),
        UsesConstruct(r'var\s+jami', '`jami` — var bo\'lishi kerak'),
      ],
      hints: ['const soliq = 0.12;', 'final narx = 1000;', 'var jami = narx + narx * soliq;\nprint(jami);'],
      solution: r'''void main() {
  const soliq = 0.12;
  final narx = 1000;
  var jami = narx + narx * soliq;
  print(jami);
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Qaysi qator XATO beradi?',
        code: 'var a = 5;\nfinal b = 6;\nconst c = 7;',
        options: ['a = 10;', 'b = 10;', 'print(c);', 'var d = a + c;'],
        correct: 1,
        explanation: '`b` — final, unga qayta qiymat berib bo\'lmaydi.',
        topic: 'final',
      ),
      TrueFalse(
        prompt: '`var son = 5;` dan keyin `son = \'besh\';` yozish mumkin.',
        answer: false,
        explanation: '`var` turni bir marta aniqlaydi: son — int. Unga String berib bo\'lmaydi.',
        topic: 'var',
      ),
      SingleChoice(
        prompt: 'Joriy vaqtni (`DateTime.now()`) saqlash uchun qaysi biri to\'g\'ri?',
        options: ['const', 'final', 'Ikkalasi ham', 'Hech qaysi'],
        correct: 1,
        explanation: 'Joriy vaqt dastur ishlaganda ma\'lum bo\'ladi — shuning uchun `final`. `const` qiymati kompilyatsiyada aniq bo\'lishi kerak.',
        topic: 'final va const',
      ),
    ],
    summary: [
      '`var` — tur avtomatik, qiymat o\'zgaradi',
      '`final` — bir marta beriladi, ish vaqtida aniqlanishi mumkin',
      '`const` — kompilyatsiya vaqtidagi o\'zgarmas',
      'Odatiy tanlov: avval final, kerak bo\'lsa var',
    ],
    next: 'Keyingi darsda sonlar bilan ishlash — `int` va `double` turlarini va arifmetik amallarni o\'rganamiz.',
    revisionTip: 'O\'zingiz haqingizda: tug\'ilgan yil — final, yosh — var, sayyoramiz nomi — const. Uchalasini yozing.',
    links: [DocLink('final and const', 'https://dart.dev/language/variables#final-and-const')],
  ),

  // ───────────────────────── 1.6 ─────────────────────────
  Lesson(
    id: 'l1_numbers',
    title: 'Sonlar: int va double',
    subtitle: 'Butun va kasr sonlar, arifmetik amallar',
    icon: Icons.calculate_outlined,
    minutes: 14,
    skills: ['dart.numbers', 'dart.operators'],
    prerequisites: ['var, final va const'],
    objectives: [
      '`int` va `double` farqini bilasiz',
      'Arifmetik operatorlar: `+ - * / ~/ %` ni qo\'llaysiz',
      'Sonlarni yaxlitlash va formatlashni o\'rganasiz',
    ],
    intro: [
      ParaBlock('Dartda sonlar uchun ikki asosiy tur bor:'),
      BulletsBlock([
        '**`int`** (integer) — butun son: `-3`, `0`, `42`, `2024`',
        '**`double`** — kasr (o\'nlik) son: `3.14`, `-0.5`, `1.75`',
        '**`num`** — ikkalasining umumiy "otasi": `num x = 5;` yoki `num x = 5.5;`',
      ]),
      HeadingBlock('Arifmetik operatorlar'),
      BulletsBlock([
        '`+` qo\'shish, `-` ayirish, `*` ko\'paytirish',
        '`/` bo\'lish — natija **doim double**: `10 / 2` → `5.0`',
        '`~/` butun bo\'lish — natija int: `10 ~/ 3` → `3`',
        '`%` qoldiq: `10 % 3` → `1` (juft/toqni aniqlashda juda foydali)',
      ]),
      ParaBlock('Amallar tartibi matematikadagi kabi: avval `*`, `/`, `%`, keyin `+`, `-`. Qavs `( )` tartibni o\'zgartiradi.'),
      HeadingBlock('Foydali metodlar'),
      BulletsBlock([
        '`3.7.round()` → 4, `3.7.floor()` → 3, `3.2.ceil()` → 4',
        '`(10 / 3).toStringAsFixed(2)` → `\'3.33\'`',
        '`7.toDouble()` → 7.0, `9.99.toInt()` → 9',
        '`8.isEven` → true, `7.isOdd` → true, `(-5).abs()` → 5',
      ]),
    ],
    analogy: AnalogyBlock(
      'Olma va sharbat',
      '`int` — olmalar: 3 ta, 4 ta... yarimta olmani "dona" deb sanamaymiz. `double` — sharbat: 1.5 litr, 0.25 litr. 10 ta olmani 3 kishiga bo\'lsangiz: har biriga 3 tadan (`10 ~/ 3`), 1 ta ortadi (`10 % 3`).',
      icon: Icons.apple,
    ),
    why: 'Narxlar, ballar, vaqt, masofa, foizlar — dasturlarning katta qismi hisob-kitob. `/` va `~/` farqini bilmaslik — boshlovchilarning eng ko\'p uchraydigan xatosi.',
    where: [
      'Savatcha narxi: `double jami = narx * soni;`',
      'Sahifalash: `int sahifalar = (elementlar / 10).ceil();`',
      'Juft/toq: `if (son % 2 == 0)`',
      'Flutter: o\'lchamlar va koordinatalar double',
    ],
    terms: [
      TermBlock(term: 'Integer (int)', uz: 'Butun son', meaning: 'Kasr qismisiz son.', why: 'Sanash uchun.', example: '42'),
      TermBlock(term: 'Double', uz: 'Kasr son', meaning: 'O\'nlik kasrli son (64-bit).', why: 'O\'lchov va narx uchun.', example: '3.14'),
      TermBlock(term: 'Operator', uz: 'Operator (amal belgisi)', meaning: 'Qiymatlar ustida amal bajaruvchi belgi.', why: 'Hisoblash uchun.', example: '+, -, *, /'),
      TermBlock(term: 'Modulo (%)', uz: 'Qoldiq', meaning: 'Bo\'lishdan keyingi qoldiq.', why: 'Juft/toq, davriylik uchun.', example: '7 % 2 == 1'),
    ],
    animation: AnimationBlock('types', 'int — butun bloklar, double — kasr bo\'laklari. / va ~/ farqini ko\'ring.'),
    example: CodeBlock(
      r'''void main() {
  int olma = 10;
  int odam = 3;

  print(olma / odam);
  print(olma ~/ odam);
  print(olma % odam);

  double narx = 12500.50;
  int soni = 3;
  double jami = narx * soni;
  print(jami);
  print(jami.toStringAsFixed(1));
  print(jami.round());
}''',
      title: 'Bo\'lish turlari va formatlash',
      explain: {
        '/': 'Oddiy bo\'lish — natija doim double.',
        '~/': 'Butun bo\'lish — kasr qismi tashlab yuboriladi.',
        '%': 'Qoldiq — bo\'lishdan ortib qolgan qism.',
        'double': 'Kasr son turi.',
        'toStringAsFixed': 'Verguldan keyin nechta raqam qolishini belgilab, matn qaytaradi.',
        'round': 'Eng yaqin butun songa yaxlitlaydi.',
      },
      expectedOutput: '3.3333333333333335\n3\n1\n37501.5\n37501.5\n37502\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int jami = 100;
  int kishi = 4;
  int ulush = jami / kishi;
  print(ulush);
}''',
      task: 'Har bir kishining butun ulushini hisoblang. Kodni tuzating.',
      why: '`/` operatori doim `double` qaytaradi, `int` o\'zgaruvchiga esa double berib bo\'lmaydi. Butun bo\'lish uchun `~/` ishlatiladi.',
      fixed: r'''void main() {
  int jami = 100;
  int kishi = 4;
  int ulush = jami ~/ kishi;
  print(ulush);
}''',
      hint: 'Butun bo\'lish operatori qaysi?',
    ),
    task: CodeTask(
      title: 'Vaqt hisoblagich',
      instructions: '`int sekund = 3725;` berilgan. Uni soat, daqiqa va sekundga ajrating va chiqaring:\n`1 soat`\n`2 daqiqa`\n`5 sekund`\n(`~/` va `%` dan foydalaning — sonlarni qo\'lda yozmang!)',
      starter: r'''void main() {
  int sekund = 3725;
  // soat = sekund ~/ 3600
}''',
      checks: [
        OutputEquals('1 soat\n2 daqiqa\n5 sekund\n', label: 'To\'g\'ri natija'),
        UsesConstruct(r'~/', '`~/` ishlatilishi kerak'),
        UsesConstruct(r'%', '`%` ishlatilishi kerak'),
      ],
      hints: [
        'Soat: sekund ~/ 3600',
        'Daqiqa: (sekund % 3600) ~/ 60',
        r'''int soat = sekund ~/ 3600;
int daqiqa = (sekund % 3600) ~/ 60;
int qolgan = sekund % 60;
print('$soat soat');''',
      ],
      solution: r'''void main() {
  int sekund = 3725;
  int soat = sekund ~/ 3600;
  int daqiqa = (sekund % 3600) ~/ 60;
  int qolgan = sekund % 60;
  print('$soat soat');
  print('$daqiqa daqiqa');
  print('$qolgan sekund');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: '`print(9 / 3);` nima chiqaradi?',
        code: 'void main() {\n  print(9 / 3);\n}',
        options: ['3', '3.0', '3.33', 'Xato'],
        explanation: '`/` doim double qaytaradi: 3.0',
        topic: 'Bo\'lish',
      ),
      PredictOutput(
        prompt: 'Natijani yozing',
        code: 'void main() {\n  print(17 % 5);\n}',
        explanation: '17 = 5 × 3 + 2. Qoldiq — 2.',
        topic: 'Qoldiq',
      ),
      SingleChoice(
        prompt: '`2 + 3 * 4` ning qiymati nechaga teng?',
        options: ['20', '14', '24', '9'],
        correct: 1,
        explanation: 'Avval ko\'paytirish: 3 × 4 = 12, keyin 2 + 12 = 14.',
        topic: 'Amallar tartibi',
      ),
      TrueFalse(
        prompt: '`double d = 5;` — to\'g\'ri kod (int literal double ga berilyapti).',
        answer: true,
        explanation: 'Dart butun son literalini double kontekstida avtomatik 5.0 deb qabul qiladi.',
        topic: 'double',
      ),
    ],
    summary: [
      '`int` — butun, `double` — kasr, `num` — ikkalasi',
      '`/` → doim double, `~/` → butun qism, `%` → qoldiq',
      '`round()`, `floor()`, `ceil()`, `toStringAsFixed(n)`',
      'Amallar tartibi: * / ~/ % → + -; qavs ustun turadi',
    ],
    next: 'Keyingi darsda matnlar — `String` va qiymatlarni matnga joylash (interpolatsiya) ni o\'rganamiz.',
    revisionTip: 'Kalkulyator o\'rniga Dartda hisoblang: oylik maoshingizning 12% ini va 30 kunga bo\'lingan kunlik qismini.',
    links: [DocLink('Numbers in Dart', 'https://dart.dev/language/built-in-types#numbers')],
  ),

  // ───────────────────────── 1.7 ─────────────────────────
  Lesson(
    id: 'l1_strings',
    title: 'String va interpolatsiya',
    subtitle: 'Matnlar bilan ishlash',
    icon: Icons.text_fields_rounded,
    minutes: 13,
    skills: ['dart.strings'],
    prerequisites: ['Sonlar: int va double'],
    objectives: [
      'String yaratish va birlashtirishni bilasiz',
      'Interpolatsiya (`\$nom`, `\${ifoda}`) ni ishlatasiz',
      'Asosiy String metodlarini qo\'llaysiz',
    ],
    intro: [
      ParaBlock('**String** — matn, ya\'ni belgilar ketma-ketligi. Bitta `\'...\'` yoki qo\'sh `"..."` qo\'shtirnoqda yoziladi.'),
      HeadingBlock('Interpolatsiya — qiymatni matnga joylash'),
      ParaBlock('`\$` belgisi orqali o\'zgaruvchini to\'g\'ridan-to\'g\'ri matn ichiga qo\'yish mumkin:'),
      BulletsBlock([
        '`\'Salom, \$ism!\'` — oddiy o\'zgaruvchi',
        '`\'Kelasi yil: \${yosh + 1}\'` — ifoda uchun jingalak qavs',
        '`\'Uzunligi: \${ism.length}\'` — xususiyat uchun ham qavs kerak',
      ]),
      CalloutBlock(CalloutKind.tip, 'Professional uslub', 'Satrlarni `+` bilan birlashtirish o\'rniga interpolatsiyani ishlating — kod qisqa va tushunarli bo\'ladi. Dart linteri ham shuni tavsiya qiladi.'),
      HeadingBlock('Maxsus belgilar'),
      BulletsBlock([
        '`\\n` — yangi qator, `\\t` — tab',
        '`\\\'` — matn ichida apostrof: `\'Men O\\\'zbekistondanman\'`',
        '`\'\'\'...\'\'\'` — ko\'p qatorli matn',
      ]),
      HeadingBlock('Foydali metodlar'),
      BulletsBlock([
        '`.length` — uzunlik, `.toUpperCase()` / `.toLowerCase()`',
        '`.contains(\'x\')`, `.startsWith(\'a\')`, `.indexOf(\'b\')`',
        '`.substring(0, 3)` — bo\'lagini olish, `.trim()` — chetdagi bo\'shliqlarni olib tashlash',
        '`.split(\' \')` — bo\'laklarga ajratish, `.replaceAll(\'a\', \'b\')`',
      ]),
    ],
    analogy: AnalogyBlock(
      'Taklifnoma shabloni',
      'To\'y taklifnomasi: "Hurmatli ___, sizni ___ kuni kutamiz". Har bir mehmon uchun bo\'sh joylarga ism va sana yoziladi. Interpolatsiya — xuddi shu: `\'Hurmatli \$ism, sizni \$sana kuni kutamiz\'`.',
      icon: Icons.mark_email_unread_outlined,
    ),
    why: 'Ilovadagi deyarli har bir matn — "Salom, Ali!", "Savatchada 3 ta mahsulot", "Narx: 25 000 so\'m" — String va interpolatsiya bilan yasaladi.',
    where: [
      'Salomlashish: `\'Xush kelibsiz, \$ism\'`',
      'Narxni formatlash: `\'\${narx.toStringAsFixed(2)} so\'m\'`',
      'Email tekshirish: `email.contains(\'@\')`',
      'Qidiruv: `nom.toLowerCase().contains(so\'rov)`',
    ],
    terms: [
      TermBlock(term: 'String', uz: 'Satr', meaning: 'Belgilar ketma-ketligi (matn).', why: 'Har qanday matnli ma\'lumot.', example: "'Salom'"),
      TermBlock(term: 'Interpolation', uz: 'Interpolatsiya', meaning: 'Qiymatni matn ichiga joylash.', why: 'Dinamik matnlar uchun.', example: r"'Yosh: $yosh'"),
      TermBlock(term: 'Escape character', uz: 'Maxsus belgi', meaning: '\\ bilan boshlanadigan belgilar.', why: 'Yangi qator, apostrof va h.k. yozish uchun.', example: r"'\n'"),
      TermBlock(term: 'Concatenation', uz: 'Birlashtirish', meaning: 'Satrlarni + bilan qo\'shish.', why: 'Matnlarni ulash.', example: "'a' + 'b'"),
    ],
    animation: AnimationBlock('string_interp', "'Salom, \$ism!' — \$ism o'rniga qiymat \"uchib kiradi\"."),
    example: CodeBlock(
      r'''void main() {
  String ism = 'Dilnoza';
  int yosh = 21;

  print('Salom, $ism!');
  print('$ism $yosh yoshda.');
  print('Kelasi yil ${yosh + 1} yoshga to\'ladi.');
  print('Ismdagi harflar: ${ism.length}');
  print(ism.toUpperCase());
  print('Ism D bilan boshlanadimi? ${ism.startsWith('D')}');

  String toliq = 'Flutter Kitob';
  print(toliq.substring(0, 7));
  print(toliq.split(' '));
}''',
      title: 'Interpolatsiya va metodlar',
      explain: {
        r'$ism': 'O\'zgaruvchi qiymati matn ichiga qo\'yiladi.',
        r'${yosh + 1}': 'Murakkab ifoda uchun jingalak qavs: avval hisoblanadi.',
        'length': 'Matndagi belgilar soni.',
        'toUpperCase': 'Barcha harflarni katta qiladi (yangi matn qaytaradi).',
        'substring': '0-indeksdan 7-indeksgacha (7 kirmaydi) bo\'lakni oladi.',
        'split': 'Matnni berilgan belgi bo\'yicha ro\'yxatga ajratadi.',
      },
      expectedOutput: "Salom, Dilnoza!\nDilnoza 21 yoshda.\nKelasi yil 22 yoshga to'ladi.\nIsmdagi harflar: 7\nDILNOZA\nIsm D bilan boshlanadimi? true\nFlutter\n[Flutter, Kitob]\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int yosh = 18;
  print('Yoshim: ' + yosh);
}''',
      task: 'Kodni ishlaydigan qiling. Natija: `Yoshim: 18`',
      why: 'String ga `+` bilan faqat String qo\'shiladi, `int` emas. To\'g\'ri usul — interpolatsiya: `\'Yoshim: \$yosh\'` (yoki `yosh.toString()`).',
      fixed: r'''void main() {
  int yosh = 18;
  print('Yoshim: $yosh');
}''',
      hint: r"$ belgisidan foydalaning.",
    ),
    task: CodeTask(
      title: 'Chek chiqaring',
      instructions: '`mahsulot = \'Kitob\'`, `narx = 45000`, `soni = 3` berilgan. Interpolatsiya bilan aynan shuni chiqaring:\n`Kitob x 3 = 135000 so\'m`',
      starter: r'''void main() {
  String mahsulot = 'Kitob';
  int narx = 45000;
  int soni = 3;
  // natijani interpolatsiya bilan chiqaring
}''',
      checks: [
        OutputEquals("Kitob x 3 = 135000 so'm\n", label: 'Aniq natija'),
        UsesConstruct(r'\$\w+|\$\{', 'Interpolatsiya ishlatilishi kerak'),
      ],
      hints: [
        r"'$mahsulot x $soni = ...'",
        r"Ko'paytmani ${...} ichida hisoblang: ${narx * soni}",
        r'''print("$mahsulot x $soni = ${narx * soni} so'm");''',
      ],
      solution: r'''void main() {
  String mahsulot = 'Kitob';
  int narx = 45000;
  int soni = 3;
  print("$mahsulot x $soni = ${narx * soni} so'm");
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija qanday bo\'ladi?',
        code: r'''void main() {
  var a = 2;
  var b = 3;
  print('$a + $b = ${a + b}');
}''',
        options: ['2 + 3 = 5', r'$a + $b = 5', '5 = 5', '2 + 3 = 23'],
        explanation: r"$a → 2, $b → 3, ${a + b} → 5.",
        topic: 'Interpolatsiya',
      ),
      SingleChoice(
        prompt: r"`'Dart'.length` qiymati?",
        options: ['3', '4', '5', 'Xato'],
        correct: 1,
        explanation: 'D, a, r, t — 4 ta belgi.',
        topic: 'String metodlari',
      ),
      FillBlank(
        prompt: 'Natija `SALOM` bo\'lishi uchun metod nomini yozing',
        template: "void main() {\n  print('salom'.____());\n}",
        accepted: ['toUpperCase'],
        expectedOutput: 'SALOM\n',
        explanation: 'toUpperCase() barcha harflarni katta qiladi.',
        topic: 'String metodlari',
      ),
    ],
    summary: [
      "String — '...' yoki \"...\" ichidagi matn",
      r"Interpolatsiya: $nom va ${ifoda}",
      'Metodlar: length, toUpperCase, contains, substring, split, trim',
      'String + int — xato; interpolatsiya ishlating',
    ],
    next: 'Keyingi darsda "ha yoki yo\'q" qiymatlari — `bool` va taqqoslash operatorlari bilan tanishamiz.',
    revisionTip: r"Ismingiz va familiyangizdan foydalanib 5 xil String metodini sinab ko'ring.",
    links: [DocLink('Strings', 'https://dart.dev/language/built-in-types#strings')],
  ),

  // ───────────────────────── 1.8 ─────────────────────────
  Lesson(
    id: 'l1_bool',
    title: 'bool va taqqoslash',
    subtitle: 'true, false va mantiqiy operatorlar',
    icon: Icons.toggle_on_outlined,
    minutes: 12,
    skills: ['dart.bool', 'dart.operators'],
    prerequisites: ['String va interpolatsiya'],
    objectives: [
      '`bool` turi va `true`/`false` qiymatlarini bilasiz',
      'Taqqoslash operatorlari: `== != > < >= <=`',
      'Mantiqiy operatorlar: `&&` (va), `||` (yoki), `!` (emas)',
    ],
    intro: [
      ParaBlock('**`bool`** (boolean) — faqat ikkita qiymatga ega tur: **`true`** (rost) va **`false`** (yolg\'on). Bu dasturning qaror qabul qilish asosi.'),
      HeadingBlock('Taqqoslash operatorlari — natijasi doim bool'),
      BulletsBlock([
        '`==` teng, `!=` teng emas',
        '`>` katta, `<` kichik, `>=` katta yoki teng, `<=` kichik yoki teng',
      ]),
      HeadingBlock('Mantiqiy operatorlar'),
      BulletsBlock([
        '`&&` — **VA**: ikkalasi ham true bo\'lsa true. `yosh >= 18 && pasportBor`',
        '`||` — **YOKI**: kamida bittasi true bo\'lsa true. `dam_olish || bayram`',
        '`!` — **EMAS**: teskarisiga aylantiradi. `!kirgan`',
      ]),
      CalloutBlock(CalloutKind.warning, 'Eng ko\'p uchraydigan xato', '`=` — qiymat berish, `==` — taqqoslash. `if (a = 5)` — xato! To\'g\'risi: `if (a == 5)`.'),
    ],
    analogy: AnalogyBlock(
      'Chiroq kaliti',
      'bool — chiroq kaliti: yoqilgan (true) yoki o\'chirilgan (false), uchinchi holat yo\'q. && — ikkita kalit ketma-ket ulangan: chiroq ikkalasi yoqilganda yonadi. || — ikkita kalit parallel: bittasi yetarli.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    why: 'Login to\'g\'rimi? Yoshi yetarlimi? Savatcha bo\'shmi? Internet bormi? — har bir qaror bool qiymatga tayanadi. Keyingi darsdagi `if` operatori aynan bool bilan ishlaydi.',
    where: [
      'Tizimga kirganmi: `bool kirgan = true;`',
      'Tugma faolmi: `bool faol = email.isNotEmpty && parol.length >= 8;`',
      'Flutter: `Switch(value: qorongiRejim)`',
    ],
    terms: [
      TermBlock(term: 'Boolean', uz: 'Mantiqiy qiymat', meaning: 'true yoki false.', why: 'Qarorlar uchun.', example: 'bool tayyor = true;'),
      TermBlock(term: 'Comparison operator', uz: 'Taqqoslash operatori', meaning: 'Ikki qiymatni solishtiradi.', why: 'Shart yozish uchun.', example: 'a > b'),
      TermBlock(term: 'Logical operator', uz: 'Mantiqiy operator', meaning: 'Bool qiymatlarni birlashtiradi.', why: 'Murakkab shartlar uchun.', example: '&&, ||, !'),
    ],
    animation: AnimationBlock('condition', '&& va || — ikki kalit qanday ishlashini sinab ko\'ring.'),
    example: CodeBlock(
      r'''void main() {
  int yosh = 20;
  bool pasportBor = true;

  print(yosh >= 18);
  print(yosh == 25);
  print(yosh != 25);

  bool ovozBeraOladi = yosh >= 18 && pasportBor;
  print('Ovoz bera oladimi: $ovozBeraOladi');

  bool damOlish = false;
  bool bayram = true;
  print('Ishlamaydi: ${damOlish || bayram}');
  print('Ish kuni: ${!(damOlish || bayram)}');
}''',
      title: 'Taqqoslash va mantiq',
      explain: {
        'bool': 'Faqat true yoki false saqlaydi.',
        '>=': 'Katta yoki teng — natija bool.',
        '==': 'Tengmi? — natija bool.',
        '!=': 'Teng emasmi?',
        '&&': 'VA — ikkala shart ham true bo\'lishi kerak.',
        '||': 'YOKI — kamida bittasi true bo\'lsa yetarli.',
        '!': 'EMAS — qiymatni teskarisiga aylantiradi.',
      },
      expectedOutput: 'true\nfalse\ntrue\nOvoz bera oladimi: true\nIshlamaydi: true\nIsh kuni: false\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int ball = 85;
  bool otdi = ball >= 60
  print(otdi);
}''',
      task: 'Kodni tuzating.',
      why: '3-qator oxirida `;` yetishmayapti. Bool ifoda ham oddiy buyruq kabi `;` bilan tugaydi.',
      fixed: r'''void main() {
  int ball = 85;
  bool otdi = ball >= 60;
  print(otdi);
}''',
    ),
    task: CodeTask(
      title: 'Chegirma bormi?',
      instructions: 'Xaridor chegirma oladi, agar **summa 100000 dan katta yoki teng** VA (**a\'zo** YOKI **bugun bayram**) bo\'lsa.\nBerilgan qiymatlar bilan `chegirma` bool o\'zgaruvchisini hisoblang va `Chegirma: true` shaklida chiqaring.',
      starter: r'''void main() {
  int summa = 120000;
  bool azo = false;
  bool bayram = true;
  // bool chegirma = ...
}''',
      checks: [
        OutputEquals('Chegirma: true\n', label: 'Natija'),
        UsesConstruct(r'&&', '`&&` ishlatilishi kerak'),
        UsesConstruct(r'\|\|', '`||` ishlatilishi kerak'),
      ],
      hints: ['summa >= 100000 && (...)', '(azo || bayram)', r'''bool chegirma = summa >= 100000 && (azo || bayram);
print('Chegirma: $chegirma');'''],
      solution: r'''void main() {
  int summa = 120000;
  bool azo = false;
  bool bayram = true;
  bool chegirma = summa >= 100000 && (azo || bayram);
  print('Chegirma: $chegirma');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: 'void main() {\n  print(5 > 3 && 2 > 4);\n}',
        options: ['true', 'false', '5', 'Xato'],
        explanation: '5 > 3 — true, 2 > 4 — false. true && false = false.',
        topic: '&&',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: 'void main() {\n  bool a = false;\n  print(!a || false);\n}',
        options: ['true', 'false'],
        explanation: '!a = true. true || false = true.',
        topic: '!',
      ),
      SingleChoice(
        prompt: 'Taqqoslash uchun qaysi operator ishlatiladi?',
        options: ['=', '==', '=>', ':='],
        correct: 1,
        explanation: '`==` — tenglikni tekshiradi, `=` — qiymat beradi.',
        topic: 'Taqqoslash',
      ),
    ],
    summary: [
      'bool — true yoki false',
      'Taqqoslash: == != > < >= <= → natija bool',
      '&& — va, || — yoki, ! — emas',
      '= qiymat beradi, == taqqoslaydi',
    ],
    next: 'Keyingi darsda turlarni bir-biriga aylantirish va maxsus turlar — dynamic va Object ni o\'rganamiz.',
    revisionTip: 'Hayotingizdan 3 ta qoidani && va || bilan bool ifoda qilib yozing.',
  ),

  // ───────────────────────── 1.9 ─────────────────────────
  Lesson(
    id: 'l1_types_conversion',
    title: 'Tur o\'zgartirish, dynamic va Object',
    subtitle: 'Matnni songa, sonni matnga aylantirish',
    icon: Icons.swap_horiz_rounded,
    minutes: 12,
    skills: ['dart.types'],
    prerequisites: ['bool va taqqoslash'],
    objectives: [
      '`int.parse`, `double.parse`, `toString()` bilan turlarni aylantirasiz',
      'Xavfsiz aylantirish — `int.tryParse` ni bilasiz',
      '`dynamic` va `Object` farqini va xavfini tushunasiz',
    ],
    intro: [
      ParaBlock('Foydalanuvchi kiritgan har qanday narsa (masalan, yosh) dastlab **matn** bo\'lib keladi: `\'25\'`. U bilan hisob-kitob qilish uchun songa aylantirish kerak.'),
      BulletsBlock([
        '`int.parse(\'25\')` → `25` (int)',
        '`double.parse(\'3.5\')` → `3.5`',
        '`25.toString()` → `\'25\'` (String)',
        '`int.tryParse(\'abc\')` → `null` (xato bermaydi!)',
      ]),
      CalloutBlock(CalloutKind.warning, 'parse xavfi', '`int.parse(\'abc\')` dasturni `FormatException` bilan to\'xtatadi. Foydalanuvchi kiritgan ma\'lumot uchun `int.tryParse()` xavfsizroq.'),
      HeadingBlock('dynamic va Object'),
      BulletsBlock([
        '**`Object`** — Dartdagi barcha qiymatlarning umumiy turi. Har qanday qiymatni saqlaydi, lekin ishlatishdan oldin turini tekshirish (`is`) kerak.',
        '**`dynamic`** — tur tekshiruvini **o\'chiradi**. Xato faqat dastur ishlaganda chiqadi. Imkon qadar ishlatmang!',
      ]),
      ParaBlock('`is` operatori turni tekshiradi: `qiymat is int` → true yoki false. `.runtimeType` esa qiymat turini ko\'rsatadi.'),
    ],
    analogy: AnalogyBlock(
      'Valyuta ayirboshlash',
      'Dollar bilan bozorda non sotib ololmaysiz — avval so\'mga almashtirasiz. Matn ko\'rinishidagi son ham shunday: hisob-kitobdan oldin `int.parse` "ayirboshlash punkti"dan o\'tadi. tryParse — qalbaki pulni tekshiradigan kassir: yaroqsiz bo\'lsa, rad etadi (null), lekin janjal qilmaydi.',
      icon: Icons.currency_exchange_rounded,
    ),
    animation: AnimationBlock('type_convert', 'Matn ↔ son konvertori: `parse`, `toString` va xavfsiz `tryParse`.'),
    why: 'Formalar, API javoblari, fayllar — ma\'lumot ko\'pincha matn ko\'rinishida keladi. To\'g\'ri va xavfsiz aylantirish — ishonchli ilovaning asosi.',
    where: [
      'TextField dan kiritilgan yoshni olish: `int.tryParse(controller.text)`',
      'Narxni ekranda ko\'rsatish: `narx.toString()`',
      'JSON dan kelgan qiymatni tekshirish: `if (v is int)`',
    ],
    terms: [
      TermBlock(term: 'Parse', uz: 'Tahlil qilib aylantirish', meaning: 'Matndan qiymat (son) hosil qilish.', why: 'Kiritilgan ma\'lumotdan foydalanish.', example: "int.parse('42')"),
      TermBlock(term: 'dynamic', uz: 'Dinamik tur', meaning: 'Tur tekshiruvi o\'chirilgan qiymat.', why: 'Kamdan-kam, majburiy holatlarda.'),
      TermBlock(term: 'Object', uz: 'Obyekt (umumiy tur)', meaning: 'Barcha turlarning ota turi.', why: 'Har xil qiymatlarni xavfsiz saqlash.'),
      TermBlock(term: 'runtimeType', uz: 'Ish vaqtidagi tur', meaning: 'Qiymatning haqiqiy turi.', why: 'Debug uchun.'),
    ],
    example: CodeBlock(
      r'''void main() {
  String kiritilgan = '25';
  int yosh = int.parse(kiritilgan);
  print(yosh + 1);

  double boy = double.parse('1.82');
  print(boy * 100);

  String matn = 2024.toString();
  print(matn.length);

  print(int.tryParse('salom'));
  print(int.tryParse('42'));

  Object narsa = 'Dart';
  print(narsa is String);
  print(narsa.runtimeType);
}''',
      title: 'Aylantirish va tekshirish',
      explain: {
        'parse': 'Matnni songa aylantiradi. Noto\'g\'ri matn bo\'lsa xato beradi.',
        'tryParse': 'Xavfsiz aylantirish: muvaffaqiyatsiz bo\'lsa null qaytaradi.',
        'toString': 'Har qanday qiymatni matnga aylantiradi.',
        'Object': 'Har qanday qiymatni saqlay oladigan umumiy tur.',
        'is': 'Tur tekshiruvi — natija bool.',
        'runtimeType': 'Qiymatning haqiqiy turi.',
      },
      expectedOutput: '26\n182.0\n4\nnull\n42\ntrue\nString\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  String a = '10';
  String b = '20';
  int jami = a + b;
  print(jami);
}''',
      task: '`jami` 30 bo\'lishi kerak. Kodni tuzating.',
      why: '`a + b` ikki matnni ulaydi (`\'1020\'`) va natija String bo\'ladi. Avval har birini `int.parse` bilan songa aylantirish kerak.',
      fixed: r'''void main() {
  String a = '10';
  String b = '20';
  int jami = int.parse(a) + int.parse(b);
  print(jami);
}''',
      hint: 'Matnni songa aylantiruvchi funksiya qaysi?',
    ),
    task: CodeTask(
      title: 'Kiritilgan qiymatni hisoblash',
      instructions: 'Dastur foydalanuvchidan tug\'ilgan yilni **matn** sifatida oladi (`stdin` orqali). Uni songa aylantirib, 2026-yildagi yoshini chiqaring: `Yoshingiz: 26` (kiritilgan qiymat `2000` bo\'lsa).\n\nMaslahat: `stdin.readLineSync()` `String?` qaytaradi — `?? \'0\'` qo\'shing.',
      starter: r'''import 'dart:io';

void main() {
  String yilMatn = stdin.readLineSync() ?? '0';
  // int ga aylantiring va yoshni hisoblang
}''',
      checks: [
        OutputEquals('Yoshingiz: 26\n', stdin: ['2000'], label: '2000 → 26'),
        OutputEquals('Yoshingiz: 10\n', stdin: ['2016'], hidden: true, label: 'Yashirin test'),
        UsesConstruct(r'int\.(try)?[pP]arse', '`int.parse` yoki `int.tryParse` ishlatilishi kerak'),
      ],
      hints: ['int yil = int.parse(yilMatn);', 'int yosh = 2026 - yil;', r"print('Yoshingiz: $yosh');"],
      solution: r'''import 'dart:io';

void main() {
  String yilMatn = stdin.readLineSync() ?? '0';
  int yil = int.parse(yilMatn);
  int yosh = 2026 - yil;
  print('Yoshingiz: $yosh');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  print('5' + '5');
  print(int.parse('5') + 5);
}''',
        options: ['10\n10', '55\n10', '55\n55', 'Xato'],
        explanation: "Ikki matnni + qilish — ulash ('55'). parse dan keyin — qo'shish (10).",
        topic: 'parse',
      ),
      SingleChoice(
        prompt: "`int.tryParse('12a')` nima qaytaradi?",
        options: ['12', '0', 'null', 'Xato beradi'],
        correct: 2,
        explanation: 'tryParse muvaffaqiyatsiz bo\'lsa null qaytaradi va dasturni to\'xtatmaydi.',
        topic: 'tryParse',
      ),
      TrueFalse(
        prompt: '`dynamic` ishlatish tavsiya etiladi, chunki u qulay.',
        answer: false,
        explanation: 'dynamic tur tekshiruvini o\'chiradi — xatolar faqat ish vaqtida chiqadi. Imkon qadar aniq tur yoki Object ishlating.',
        topic: 'dynamic',
      ),
    ],
    summary: [
      "int.parse / double.parse — matndan son",
      'toString() — istalgan qiymatdan matn',
      'tryParse — xavfsiz, xatoda null',
      'Object — umumiy tur, dynamic — tekshiruvsiz (ehtiyot bo\'ling)',
      '`is` — tur tekshiruvi, runtimeType — haqiqiy tur',
    ],
    next: 'Keyingi darsda operatorlarning to\'liq to\'plami: qisqa qiymat berish (+=), increment (++) va boshqalar.',
    revisionTip: "Foydalanuvchidan ikkita son so'rab, yig'indisini chiqaradigan dastur yozing (stdin + int.parse).",
  ),

  // ───────────────────────── 1.10 ─────────────────────────
  Lesson(
    id: 'l1_operators',
    title: 'Operatorlar to\'plami',
    subtitle: 'Qisqa yozuvlar: +=, ++, ternar va boshqalar',
    icon: Icons.functions_rounded,
    minutes: 12,
    skills: ['dart.operators'],
    prerequisites: ['Tur o\'zgartirish, dynamic va Object'],
    objectives: [
      'Qisqa qiymat berish operatorlari: `+= -= *= /= ~/=`',
      'Increment va decrement: `++` va `--` (oldin va keyin)',
      'Shartli (ternar) operator: `shart ? a : b`',
    ],
    intro: [
      HeadingBlock('Qisqa qiymat berish'),
      BulletsBlock([
        '`ball += 10;` ↔ `ball = ball + 10;`',
        '`narx -= 500;`, `soni *= 2;`, `jami ~/= 3;`',
      ]),
      HeadingBlock('Increment / Decrement'),
      BulletsBlock([
        '`i++` — 1 ga oshirish, `i--` — 1 ga kamaytirish',
        '`i++` (postfiks) — avval eski qiymat ishlatiladi, keyin oshadi',
        '`++i` (prefiks) — avval oshadi, keyin yangi qiymat ishlatiladi',
      ]),
      HeadingBlock('Ternar operator'),
      ParaBlock('`shart ? agarRost : agarYolgon` — kichik `if-else` ning bir qatorli shakli: `var holat = ball >= 60 ? \'O\\\'tdi\' : \'Yiqildi\';`'),
      HeadingBlock('Amallar ustuvorligi (yuqoridan pastga)'),
      BulletsBlock([
        '`!`, `-` (unar), `++`, `--`',
        '`*` `/` `~/` `%`',
        '`+` `-`',
        '`<` `>` `<=` `>=`, keyin `==` `!=`',
        '`&&`, keyin `||`, keyin `? :`, oxirida `=` `+=` ...',
      ], ordered: true),
    ],
    analogy: AnalogyBlock(
      'Qadamlar hisoblagichi',
      'Fitnes bilaguzugi har qadamda `qadam++` qiladi. Yugurganingizda bir urinishda 2 qadam qo\'shiladi: `qadam += 2`. Ternar operator esa: "qadam 10000 dan oshdimi? → Barakalla! : Davom eting".',
      icon: Icons.directions_walk_rounded,
    ),
    animation: AnimationBlock('operators', 'Kalkulyator: har bir operator ikki sonni qanday natijaga aylantirishini ko\'ring.'),
    why: 'Bu operatorlar har bir siklda, hisoblagichda va UI shartlarida ishlatiladi. Flutterda ternar operator juda ko\'p uchraydi: `Text(kirgan ? \'Chiqish\' : \'Kirish\')`.',
    where: [
      'Sikllar: `for (var i = 0; i < 10; i++)`',
      'O\'yin balli: `ball += 5;`',
      'Flutter: `color: faol ? Colors.blue : Colors.grey`',
    ],
    terms: [
      TermBlock(term: 'Compound assignment', uz: 'Qisqa qiymat berish', meaning: 'Amal va qiymat berishni birlashtiradi.', why: 'Kodni qisqartiradi.', example: 'x += 1'),
      TermBlock(term: 'Increment', uz: 'Oshirish', meaning: '1 ga oshirish: ++', why: 'Hisoblagichlar uchun.'),
      TermBlock(term: 'Ternary operator', uz: 'Uch qismli operator', meaning: 'shart ? a : b', why: 'Qisqa shartli qiymat.'),
      TermBlock(term: 'Precedence', uz: 'Ustuvorlik', meaning: 'Qaysi amal birinchi bajarilishi.', why: 'Natijani to\'g\'ri hisoblash uchun.'),
    ],
    example: CodeBlock(
      r'''void main() {
  int ball = 50;
  ball += 20;
  ball -= 5;
  ball *= 2;
  print(ball);

  int i = 5;
  print(i++);
  print(i);
  print(++i);

  int harorat = 28;
  String kiyim = harorat > 25 ? 'futbolka' : 'kurtka';
  print('Bugun $kiyim kiying');
}''',
      title: 'Operatorlar amalda',
      explain: {
        '+=': 'ball = ball + 20 ning qisqa shakli.',
        '-=': 'ball = ball - 5.',
        '*=': 'ball = ball * 2.',
        'i++': 'Avval eski qiymat (5) chiqadi, keyin i 6 bo\'ladi.',
        '++i': 'Avval oshadi (7), keyin chiqadi.',
        '?': 'Ternar operator: shart true bo\'lsa — birinchi qiymat.',
        ':': 'aks holda — ikkinchi qiymat.',
      },
      expectedOutput: '130\n5\n6\n7\nBugun futbolka kiying\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  int son = 7;
  String tur = son % 2 == 0 ? 'juft' 'toq';
  print(tur);
}''',
      task: 'Ternar operator noto\'g\'ri yozilgan. Tuzating — natija `toq` bo\'lsin.',
      why: 'Ternar operatorda ikki qiymat orasida `:` bo\'lishi shart: `shart ? a : b`.',
      fixed: r'''void main() {
  int son = 7;
  String tur = son % 2 == 0 ? 'juft' : 'toq';
  print(tur);
}''',
    ),
    task: CodeTask(
      title: 'Hamyon',
      instructions: 'Hamyonda `100000` so\'m bor. Faqat `+=` va `-=` dan foydalanib:\n1) 50000 maosh qo\'shing\n2) 30000 xarid qiling\n3) Natijani chiqaring.\n4) Ternar operator bilan: agar balans 100000 dan ko\'p bo\'lsa `Boy`, aks holda `Tejang` chiqaring.\nNatija:\n`120000`\n`Boy`',
      starter: r'''void main() {
  int balans = 100000;
}''',
      checks: [
        OutputEquals('120000\nBoy\n', label: 'Natija'),
        UsesConstruct(r'\+=', '`+=` ishlatilishi kerak'),
        UsesConstruct(r'-=', '`-=` ishlatilishi kerak'),
        UsesConstruct(r'\?[\s\S]*:', 'Ternar operator ishlatilishi kerak'),
      ],
      hints: ['balans += 50000;', 'balans -= 30000;', r"print(balans > 100000 ? 'Boy' : 'Tejang');"],
      solution: r'''void main() {
  int balans = 100000;
  balans += 50000;
  balans -= 30000;
  print(balans);
  print(balans > 100000 ? 'Boy' : 'Tejang');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var x = 10;
  x += 5;
  x ~/= 4;
  print(x);
}''',
        explanation: '10 + 5 = 15, 15 ~/ 4 = 3.',
        topic: 'Qisqa qiymat berish',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var a = 3;
  var b = a++ + 10;
  print('$a $b');
}''',
        options: ['3 13', '4 13', '4 14', '3 14'],
        explanation: 'a++ avval 3 ni beradi (b = 13), keyin a 4 bo\'ladi.',
        topic: 'Increment',
      ),
      SingleChoice(
        prompt: "`5 > 3 ? 'A' : 'B'` qiymati?",
        options: ["'A'", "'B'", 'true', 'Xato'],
        correct: 0,
        explanation: 'Shart true — birinchi qiymat tanlanadi.',
        topic: 'Ternar',
      ),
    ],
    summary: [
      '`+= -= *= ~/=` — qisqa qiymat berish',
      '`i++` avval eski qiymat, `++i` avval yangi qiymat',
      'Ternar: `shart ? a : b`',
      'Ustuvorlik: * / → + - → taqqoslash → && → || → ?: → =',
    ],
    next: 'Tabriklaymiz — Dart asoslari tugadi! Keyingi darajada dasturga "fikrlash" beramiz: if, switch va sikllar.',
    revisionTip: 'Har bir operatorga o\'zingiz misol yozing va natijani avval taxmin qiling, keyin ishga tushirib tekshiring.',
  ),
];
