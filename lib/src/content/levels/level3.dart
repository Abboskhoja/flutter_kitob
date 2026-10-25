import 'package:flutter/material.dart';

import '../model.dart';

const level3Lessons = <Lesson>[
  // ───────────────────────── 3.1 ─────────────────────────
  Lesson(
    id: 'l3_functions',
    title: 'Funksiyalar',
    subtitle: 'Kodni qayta ishlatiladigan bo\'laklarga ajratish',
    icon: Icons.settings_input_component_outlined,
    minutes: 15,
    xp: 60,
    skills: ['dart.functions'],
    prerequisites: ['for sikli', 'if, else va else if'],
    objectives: [
      'Funksiya e\'lon qilish va chaqirishni bilasiz',
      'Parametr, argument va qaytariladigan qiymat (return) ni tushunasiz',
      'Arrow (`=>`) funksiyalarni yozasiz',
    ],
    intro: [
      ParaBlock('**Funksiya** — nomga ega, qayta-qayta chaqiriladigan kod bloki. Siz allaqachon `main()` va `print()` funksiyalarini ishlatdingiz.'),
      ParaBlock('`int kvadrat(int son) { return son * son; }`'),
      BulletsBlock([
        '**`int`** — qaytariladigan qiymat turi (natija)',
        '**`kvadrat`** — funksiya nomi (fe\'l bilan nomlash yaxshi: hisobla, ol, tekshir)',
        '**`(int son)`** — parametr: funksiyaga kiradigan ma\'lumot',
        '**`return`** — natijani qaytaradi va funksiyani tugatadi',
      ]),
      ParaBlock('Chaqirish: `kvadrat(5)` — bu yerda `5` **argument**. Natija `25` qaytadi.'),
      ParaBlock('Hech narsa qaytarmaydigan funksiya — **`void`**: `void salomlash(String ism) { print(\'Salom, \$ism\'); }`'),
      ParaBlock('Bitta ifodali funksiyani qisqa yozish — **arrow**: `int kvadrat(int son) => son * son;`'),
    ],
    analogy: AnalogyBlock(
      'Sharbat mashinasi',
      'Funksiya — sharbat mashinasi: ichiga olma solasiz (argument), u ishlov beradi (tana) va sharbat chiqaradi (return). Mashinani bir marta yasaysiz, istalgancha ishlatasiz. `void` funksiya esa chiroq tugmasiga o\'xshaydi: biror ish qiladi, lekin sizga hech narsa "qaytarmaydi".',
      icon: Icons.blender_outlined,
    ),
    why: 'Bir xil kodni 10 joyda yozish o\'rniga bitta funksiya yozasiz. Xato bo\'lsa — bir joyda tuzatasiz. Flutterda har bir widget, har bir tugma bosilishi — funksiya.',
    where: [
      'Hisob-kitob: `double soliqHisobla(double summa)`',
      'Tekshiruv: `bool emailTogrimi(String email)`',
      'Flutter: `onPressed: () { ... }`, `Widget build(BuildContext context)`',
    ],
    terms: [
      TermBlock(term: 'Function', uz: 'Funksiya', meaning: 'Nomlangan, qayta ishlatiladigan kod bloki.', why: 'Takrorlanishni yo\'qotish.'),
      TermBlock(term: 'Parameter', uz: 'Parametr', meaning: 'Funksiya e\'lonidagi kiruvchi o\'zgaruvchi.', why: 'Funksiyaga ma\'lumot berish.', example: 'int son'),
      TermBlock(term: 'Argument', uz: 'Argument', meaning: 'Chaqirishda beriladigan haqiqiy qiymat.', why: '', example: 'kvadrat(5) — 5'),
      TermBlock(term: 'Return value', uz: 'Qaytariladigan qiymat', meaning: 'Funksiya natijasi.', why: 'Natijani boshqa joyda ishlatish.'),
      TermBlock(term: 'Arrow function', uz: 'Strelkali funksiya', meaning: '=> ifoda; shaklidagi qisqa funksiya.', why: 'Qisqa va o\'qishli kod.'),
    ],
    animation: AnimationBlock('function_machine', 'Argument funksiyaga kiradi → ichida hisoblanadi → return natija chiqadi.'),
    syntax: SyntaxBlock(r'''QaytishTuri nom(Tur parametr) {
  // tana
  return natija;
}''', [
      SyntaxPart('QaytishTuri', 'int, String, bool... yoki void'),
      SyntaxPart('nom', 'lowerCamelCase, fe\'l bilan'),
      SyntaxPart('(Tur parametr)', 'kiruvchi ma\'lumotlar, vergul bilan'),
      SyntaxPart('return', 'natijani qaytaradi va funksiyani tugatadi'),
    ]),
    example: CodeBlock(
      r'''int kvadrat(int son) {
  return son * son;
}

double ortacha(int a, int b) => (a + b) / 2;

void salomlash(String ism) {
  print('Salom, $ism!');
}

bool juftmi(int n) => n % 2 == 0;

void main() {
  print(kvadrat(7));
  var natija = kvadrat(3) + kvadrat(4);
  print(natija);
  print(ortacha(8, 5));
  salomlash('Kamola');
  print(juftmi(10));
}''',
      title: 'Turli funksiyalar',
      explain: {
        'int kvadrat': 'int qaytaradigan funksiya.',
        'return': 'Natijani chaqirgan joyga qaytaradi.',
        '=>': 'Arrow: `{ return ...; }` ning qisqa shakli.',
        'void': 'Hech narsa qaytarmaydi — faqat ish bajaradi.',
        'kvadrat(7)': 'Chaqiruv: 7 — argument.',
      },
      expectedOutput: '49\n25\n6.5\nSalom, Kamola!\ntrue\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''int yigindi(int a, int b) {
  print(a + b);
}

void main() {
  var s = yigindi(2, 3);
  print(s * 10);
}''',
      task: 'Natija `50` bo\'lishi kerak. Xatoni toping va tuzating.',
      why: 'Funksiya `int` qaytarishi e\'lon qilingan, lekin `return` yo\'q — faqat `print` qilinyapti. `print` ekranga chiqaradi, `return` esa natijani **qaytaradi**. Ular boshqa-boshqa narsa!',
      fixed: r'''int yigindi(int a, int b) {
  return a + b;
}

void main() {
  var s = yigindi(2, 3);
  print(s * 10);
}''',
      hint: 'print va return farqi nima?',
    ),
    task: CodeTask(
      title: 'BMI kalkulyatori',
      instructions: '`double bmi(double vazn, double boy)` funksiyasini yozing: `vazn / (boy * boy)`.\nVa `String bmiHolat(double b)`:\n- `b < 18.5` → `Kam`\n- `b < 25` → `Normal`\n- aks holda → `Ortiqcha`',
      starter: r'''double bmi(double vazn, double boy) {
  return 0;
}

String bmiHolat(double b) {
  return '';
}

void main() {
  var b = bmi(70, 1.75);
  print(b.toStringAsFixed(1));
  print(bmiHolat(b));
}''',
      checks: [
        EvaluatesTo('bmi(70, 1.75).toStringAsFixed(1)', '22.9'),
        EvaluatesTo('bmiHolat(22.9)', 'Normal'),
        EvaluatesTo('bmiHolat(17.0)', 'Kam', hidden: true),
        EvaluatesTo('bmiHolat(30.0)', 'Ortiqcha', hidden: true),
        EvaluatesTo('bmi(50, 1.6).toStringAsFixed(2)', '19.53', hidden: true),
      ],
      hints: ['return vazn / (boy * boy);', 'bmiHolat da if-else if-else yoki switch ifodasi.', r'''if (b < 18.5) return 'Kam';
if (b < 25) return 'Normal';
return 'Ortiqcha';'''],
      solution: r'''double bmi(double vazn, double boy) {
  return vazn / (boy * boy);
}

String bmiHolat(double b) {
  if (b < 18.5) return 'Kam';
  if (b < 25) return 'Normal';
  return 'Ortiqcha';
}

void main() {
  var b = bmi(70, 1.75);
  print(b.toStringAsFixed(1));
  print(bmiHolat(b));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''int f(int x) => x * 2 + 1;

void main() {
  print(f(f(3)));
}''',
        explanation: 'f(3) = 7, f(7) = 15.',
        topic: 'Funksiya',
      ),
      SingleChoice(
        prompt: '`void` funksiya haqida qaysi to\'g\'ri?',
        options: ['Doim 0 qaytaradi', 'Hech qanday qiymat qaytarmaydi', 'Faqat print qila oladi', 'Parametr qabul qilmaydi'],
        correct: 1,
        explanation: 'void — "bo\'sh": funksiya ish bajaradi, lekin natija qaytarmaydi.',
        topic: 'void',
      ),
      MatchPairs(
        prompt: '`int ayir(int a, int b) => a - b;` va `ayir(9, 4)` uchun moslang',
        pairs: [('int', 'Qaytish turi'), ('ayir', 'Funksiya nomi'), ('a, b', 'Parametrlar'), ('9, 4', 'Argumentlar')],
        explanation: 'Parametr — e\'londa, argument — chaqiruvda.',
        topic: 'Atamalar',
      ),
    ],
    summary: [
      'Funksiya: QaytishTuri nom(parametrlar) { ... return ...; }',
      'void — hech narsa qaytarmaydi',
      'return — natijani qaytaradi; print — faqat ekranga chiqaradi',
      'Arrow: bitta ifoda uchun =>',
    ],
    next: 'Keyingi darsda nomli, ixtiyoriy va standart qiymatli parametrlarni o\'rganamiz — Flutterda eng ko\'p ishlatiladigan uslub.',
    revisionTip: 'Selsiyni Farengeytga aylantiruvchi funksiya yozing: F = C × 9/5 + 32.',
    links: [DocLink('Functions', 'https://dart.dev/language/functions')],
  ),

  // ───────────────────────── 3.2 ─────────────────────────
  Lesson(
    id: 'l3_parameters',
    title: 'Nomli va ixtiyoriy parametrlar',
    subtitle: 'Flutter uslubidagi funksiya chaqiruvlari',
    icon: Icons.tune_rounded,
    minutes: 13,
    skills: ['dart.parameters'],
    prerequisites: ['Funksiyalar'],
    objectives: [
      'Nomli parametrlar `{}` va `required` ni ishlatasiz',
      'Ixtiyoriy pozitsion parametrlar `[]` ni bilasiz',
      'Standart (default) qiymatlarni beriladi',
    ],
    intro: [
      ParaBlock('Parametrlar uch xil bo\'ladi:'),
      BulletsBlock([
        '**Pozitsion (majburiy)**: `f(int a, int b)` — tartib muhim: `f(1, 2)`',
        '**Ixtiyoriy pozitsion**: `f(int a, [int b = 0])` — `f(1)` yoki `f(1, 2)`',
        '**Nomli**: `f({required String ism, int yosh = 0})` — `f(ism: \'Ali\', yosh: 20)`',
      ]),
      ParaBlock('Nomli parametrlar chaqiruvni **o\'qishli** qiladi: `yarat(ism: \'Ali\', yosh: 20, admin: true)` — har bir qiymat nimaligini darhol ko\'rasiz. Tartib ahamiyatsiz.'),
      ParaBlock('Nomli parametr null bo\'la olmaydigan turda bo\'lsa, yo **`required`** bo\'lishi, yo **standart qiymat**ga ega bo\'lishi shart.'),
      CalloutBlock(CalloutKind.success, 'Bu — Flutter uslubi', '`Text(\'Salom\', style: TextStyle(fontSize: 20))`, `Container(width: 100, color: Colors.blue)` — Flutterdagi barcha widgetlar nomli parametrlar bilan ishlaydi.'),
    ],
    analogy: AnalogyBlock(
      'Kafe buyurtmasi',
      'Pozitsion: "kofe, katta, sutli" — tartibni adashtirsangiz chalkashlik. Nomli: "o\'lcham: katta, ichimlik: kofe, qo\'shimcha: sut" — har birini aytib berasiz, tartib muhim emas. Standart qiymat: shakar aytmasangiz — "1 qoshiq" deb hisoblanadi.',
      icon: Icons.local_cafe_outlined,
    ),
    why: 'Ko\'p parametrli funksiyalarni chaqirishda xato qilish oson. Nomli parametrlar xatolarni kamaytiradi va kodni o\'zini-o\'zi hujjatlashtiruvchi qiladi.',
    where: [
      'Flutter widgetlari: `ElevatedButton(onPressed: ..., child: ...)`',
      'Konfiguratsiya: `ulan(host: \'...\', port: 8080, timeout: 30)`',
    ],
    terms: [
      TermBlock(term: 'Named parameter', uz: 'Nomli parametr', meaning: '{} ichida, chaqiruvda nomi bilan beriladi.', why: 'O\'qishli chaqiruvlar.', example: 'f(ism: \'Ali\')'),
      TermBlock(term: 'required', uz: 'Majburiy', meaning: 'Nomli parametrni berish shart.', why: ''),
      TermBlock(term: 'Default value', uz: 'Standart qiymat', meaning: 'Berilmasa ishlatiladigan qiymat.', why: 'Ixtiyoriy sozlamalar.'),
      TermBlock(term: 'Optional positional', uz: 'Ixtiyoriy pozitsion', meaning: '[] ichidagi parametrlar.', why: ''),
    ],
    example: CodeBlock(
      r'''String tanishtir({required String ism, int yosh = 18, String shahar = 'Toshkent'}) {
  return '$ism, $yosh yosh, $shahar';
}

String toliqIsm(String ism, [String? familiya]) {
  if (familiya == null) return ism;
  return '$ism $familiya';
}

double narx(double asl, {double chegirma = 0}) => asl * (1 - chegirma);

void main() {
  print(tanishtir(ism: 'Ali'));
  print(tanishtir(shahar: 'Xiva', ism: 'Laylo', yosh: 22));
  print(toliqIsm('Bobur'));
  print(toliqIsm('Bobur', 'Mirzo'));
  print(narx(100000, chegirma: 0.2));
}''',
      title: 'Parametr turlari',
      explain: {
        'required': 'Bu nomli parametr majburiy.',
        '= 18': 'Standart qiymat — berilmasa 18.',
        '[String? familiya]': 'Ixtiyoriy pozitsion; berilmasa null.',
        'ism:': 'Nomli argument — nomi bilan beriladi.',
      },
      expectedOutput: 'Ali, 18 yosh, Toshkent\nLaylo, 22 yosh, Xiva\nBobur\nBobur Mirzo\n80000.0\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void xabar({required String matn, String turi = 'info'}) {
  print('[$turi] $matn');
}

void main() {
  xabar('Saqlandi', turi: 'ok');
}''',
      task: 'Chaqiruv xato. Tuzating — natija `[ok] Saqlandi` bo\'lsin.',
      why: '`matn` — nomli parametr, uni pozitsion (nomsiz) berib bo\'lmaydi. To\'g\'ri: `xabar(matn: \'Saqlandi\', turi: \'ok\')`.',
      fixed: r'''void xabar({required String matn, String turi = 'info'}) {
  print('[$turi] $matn');
}

void main() {
  xabar(matn: 'Saqlandi', turi: 'ok');
}''',
    ),
    task: CodeTask(
      title: 'Tugma konfiguratsiyasi',
      instructions: '`String tugma({required String matn, String rang = \'kok\', bool faol = true})` funksiyasini yozing. U qaytarsin:\n- faol bo\'lsa: `[<rang>] <matn>`\n- faol bo\'lmasa: `[o\'chiq] <matn>`\nMasalan `tugma(matn: \'Kirish\')` → `[kok] Kirish`',
      starter: r'''String tugma() {
  return '';
}

void main() {
  print(tugma(matn: 'Kirish'));
}''',
      checks: [
        EvaluatesTo("tugma(matn: 'Kirish')", '[kok] Kirish'),
        EvaluatesTo("tugma(matn: 'Saqlash', rang: 'yashil')", '[yashil] Saqlash'),
        EvaluatesTo("tugma(matn: 'Yuborish', faol: false)", "[o'chiq] Yuborish", hidden: true),
      ],
      hints: [r"Parametrlar: ({required String matn, String rang = 'kok', bool faol = true})", r'''if (!faol) return "[o'chiq] $matn";''', r"return '[$rang] $matn';"],
      solution: r'''String tugma({required String matn, String rang = 'kok', bool faol = true}) {
  if (!faol) return "[o'chiq] $matn";
  return '[$rang] $matn';
}

void main() {
  print(tugma(matn: 'Kirish'));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''int f(int a, [int b = 10]) => a + b;

void main() {
  print(f(1));
  print(f(1, 2));
}''',
        options: ['11\n3', '1\n3', 'Xato', '11\n12'],
        explanation: 'b berilmasa — 10.',
        topic: 'Ixtiyoriy parametr',
      ),
      TrueFalse(
        prompt: 'Nomli argumentlarni istalgan tartibda berish mumkin.',
        answer: true,
        explanation: 'Nomli argumentlar nomi bilan aniqlanadi, tartib muhim emas.',
        topic: 'Nomli parametr',
      ),
    ],
    summary: [
      'Pozitsion: f(a, b) — tartib muhim',
      'Ixtiyoriy: [Tur x = standart]',
      'Nomli: {required Tur x, Tur y = standart} — f(x: 1)',
      'Flutter widgetlari nomli parametrlar bilan ishlaydi',
    ],
    next: 'Keyingi darsda o\'zgaruvchilar qayerda "yashashi" — scope va funksiya "xotirasi" — closure ni o\'rganamiz.',
    revisionTip: 'Flutterdagi istalgan widget (Text, Container) hujjatini ochib, uning nomli parametrlarini sanab chiqing.',
  ),

  // ───────────────────────── 3.3 ─────────────────────────
  Lesson(
    id: 'l3_scope_closure',
    title: 'Scope, closure va funksiya — qiymat',
    subtitle: 'O\'zgaruvchilar qayerda yashaydi',
    icon: Icons.layers_outlined,
    minutes: 13,
    skills: ['dart.closures'],
    prerequisites: ['Nomli va ixtiyoriy parametrlar'],
    objectives: [
      'Scope (ko\'rinish sohasi) qoidalarini bilasiz',
      'Funksiyani o\'zgaruvchiga saqlash va argument qilib berishni o\'rganasiz',
      'Closure — tashqi o\'zgaruvchini "eslab qoluvchi" funksiyani tushunasiz',
    ],
    intro: [
      ParaBlock('**Scope** — o\'zgaruvchi ko\'rinadigan joy. `{ }` ichida e\'lon qilingan o\'zgaruvchi faqat shu blok ichida mavjud.'),
      BulletsBlock([
        'Ichki blok tashqi o\'zgaruvchini **ko\'radi**',
        'Tashqi blok ichki o\'zgaruvchini **ko\'rmaydi**',
        'Fayl darajasidagi (global) o\'zgaruvchi hamma joyda ko\'rinadi — lekin ko\'p ishlatmang',
      ]),
      HeadingBlock('Funksiya ham qiymat'),
      ParaBlock('Dartda funksiyani o\'zgaruvchiga saqlash, boshqa funksiyaga berish va qaytarish mumkin: `var ikki = (int x) => x * 2;` Bu **anonim funksiya** (lambda).'),
      ParaBlock('`list.map(ikki)`, `list.forEach(print)` — funksiyani argument sifatida berish.'),
      HeadingBlock('Closure'),
      ParaBlock('**Closure** — o\'zi yaratilgan joydagi o\'zgaruvchilarni "eslab qoladigan" funksiya. Tashqi funksiya tugasa ham, ichki funksiya o\'sha o\'zgaruvchiga murojaat qila oladi.'),
    ],
    analogy: AnalogyBlock(
      'Uy, xona va ryukzak',
      'Scope: oshxonadagi narsalar oshxonada, lekin uyning umumiy chirog\'i hamma xonada ko\'rinadi. Closure — ryukzak: siz uydan chiqib ketsangiz ham, ryukzakdagi narsalar (eslab qolingan o\'zgaruvchilar) siz bilan birga.',
      icon: Icons.backpack_outlined,
    ),
    why: 'Flutterda tugma bosilganda ishlaydigan funksiyalar (`onPressed`) aynan closure: ular ekrandagi holatni "eslab" qoladi. Scope ni tushunish nomlar to\'qnashuvi xatolarining oldini oladi.',
    where: [
      'Flutter: `onPressed: () => setState(() => son++)`',
      'Ro\'yxatlar: `.where((x) => x > chegara)`',
      'Hisoblagich, kesh, sozlangan funksiyalar',
    ],
    terms: [
      TermBlock(term: 'Scope', uz: 'Ko\'rinish sohasi', meaning: 'O\'zgaruvchi ishlatilishi mumkin bo\'lgan joy.', why: 'Nomlar to\'qnashuvining oldini oladi.'),
      TermBlock(term: 'Anonymous function', uz: 'Anonim funksiya', meaning: 'Nomsiz funksiya: (x) => x * 2', why: 'Qisqa callback lar uchun.'),
      TermBlock(term: 'Closure', uz: 'Yopilish (closure)', meaning: 'Tashqi o\'zgaruvchilarni eslab qoluvchi funksiya.', why: 'Holatni saqlash.'),
      TermBlock(term: 'Callback', uz: 'Qayta chaqiriladigan funksiya', meaning: 'Boshqa funksiyaga beriladigan va keyin chaqiriladigan funksiya.', why: 'Hodisalarga javob berish.'),
    ],
    animation: AnimationBlock('scope', 'Ichki blok tashqini ko\'radi, tashqi esa ichkini ko\'rmaydi.'),
    example: CodeBlock(
      r'''Function hisoblagichYarat() {
  var son = 0;
  return () {
    son++;
    return son;
  };
}

int qollash(int x, int Function(int) f) => f(x);

void main() {
  var tashqi = 'men tashqiman';
  if (true) {
    var ichki = 'men ichkiman';
    print(tashqi);
    print(ichki);
  }

  var ikki = (int x) => x * 2;
  print(qollash(5, ikki));
  print(qollash(5, (x) => x + 100));
  print([1, 2, 3].map(ikki).toList());

  var h = hisoblagichYarat();
  h();
  h();
  print(h());
}''',
      title: 'Scope va closure',
      explain: {
        'Function': 'Funksiya qaytaradigan funksiya.',
        'son': 'Closure ichida "eslab qolinadigan" o\'zgaruvchi.',
        'int Function(int)': 'int olib int qaytaradigan funksiya turi.',
        '(x) => x + 100': 'Anonim funksiya — argument sifatida.',
      },
      expectedOutput: 'men tashqiman\nmen ichkiman\n10\n105\n[2, 4, 6]\n3\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  for (var i = 0; i < 3; i++) {
    var kvadrat = i * i;
  }
  print(kvadrat);
}''',
      task: 'Oxirgi kvadratni (4) chiqarish kerak. Scope xatosini tuzating.',
      why: '`kvadrat` sikl bloki ichida e\'lon qilingan — tashqarida u mavjud emas. O\'zgaruvchini sikldan oldin e\'lon qiling.',
      fixed: r'''void main() {
  var kvadrat = 0;
  for (var i = 0; i < 3; i++) {
    kvadrat = i * i;
  }
  print(kvadrat);
}''',
    ),
    task: CodeTask(
      title: 'Ko\'paytiruvchi fabrika',
      instructions: '`int Function(int) kopaytiruvchi(int k)` — k ga ko\'paytiradigan **funksiya qaytarsin**.\n`var uch = kopaytiruvchi(3); uch(5)` → `15`',
      starter: r'''int Function(int) kopaytiruvchi(int k) {
  // funksiya qaytaring
  return (x) => x;
}

void main() {
  var uch = kopaytiruvchi(3);
  print(uch(5));
}''',
      checks: [
        EvaluatesTo('kopaytiruvchi(3)(5)', '15'),
        EvaluatesTo('kopaytiruvchi(10)(7)', '70', hidden: true),
        EvaluatesTo('kopaytiruvchi(0)(99)', '0', hidden: true),
      ],
      hints: ['Qaytarilayotgan funksiya k ni eslab qoladi (closure).', 'return (x) => x * k;', 'Faqat bitta qatorni o\'zgartirish kifoya.'],
      solution: r'''int Function(int) kopaytiruvchi(int k) {
  return (x) => x * k;
}

void main() {
  var uch = kopaytiruvchi(3);
  print(uch(5));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  var x = 1;
  var f = () => x * 10;
  x = 5;
  print(f());
}''',
        options: ['10', '50', '1', 'Xato'],
        explanation: 'Closure o\'zgaruvchining o\'zini eslab qoladi (nusxasini emas). Chaqirilganda x = 5 — natija 50.',
        topic: 'Closure',
      ),
      TrueFalse(
        prompt: 'if bloki ichida e\'lon qilingan o\'zgaruvchi blokdan keyin ham mavjud.',
        answer: false,
        explanation: 'Blok ichidagi o\'zgaruvchi faqat shu blokda yashaydi.',
        topic: 'Scope',
      ),
    ],
    summary: [
      'Scope: { } ichidagi o\'zgaruvchi faqat shu yerda',
      'Funksiya — qiymat: saqlash, berish, qaytarish mumkin',
      'Anonim funksiya: (x) => ...',
      'Closure tashqi o\'zgaruvchilarni eslab qoladi',
    ],
    next: 'Endi dasturlashning eng kuchli g\'oyalaridan biri — obyektga yo\'naltirilgan dasturlash (OOP) va class lar!',
    revisionTip: 'List<int> va shart funksiyasini oladigan `filtrla(l, shart)` funksiyasini o\'zingiz yozing.',
  ),

  // ───────────────────────── 3.4 ─────────────────────────
  Lesson(
    id: 'l3_classes',
    title: 'Class va obyekt',
    subtitle: 'Haqiqiy dunyoni kodda modellashtirish',
    icon: Icons.category_outlined,
    minutes: 16,
    xp: 70,
    skills: ['dart.classes'],
    prerequisites: ['Funksiyalar'],
    objectives: [
      'Class (chizma) va obyekt (nusxa) farqini tushunasiz',
      'Maydon (field) va metodlarni yozasiz',
      'Konstruktor bilan obyekt yaratasiz va `this` ni tushunasiz',
    ],
    intro: [
      ParaBlock('**Class** — obyektlar uchun **chizma** (shablon). U ikki narsani belgilaydi:'),
      BulletsBlock([
        '**Maydonlar** (fields) — obyekt nimalarni "biladi": ism, yosh, rang',
        '**Metodlar** (methods) — obyekt nimalar "qila oladi": gapir, yur, hisobla',
      ]),
      ParaBlock('**Obyekt** (object, instance) — class asosida yaratilgan aniq nusxa: `var ali = Talaba(\'Ali\', 20);`'),
      ParaBlock('**Konstruktor** — obyekt yaratilganda chaqiriladigan maxsus funksiya. Dartdagi qisqa uslub: `Talaba(this.ism, this.yosh);` — parametrlar to\'g\'ridan-to\'g\'ri maydonlarga yoziladi.'),
      ParaBlock('**`this`** — "shu obyektning o\'zi". `this.ism` — shu obyektning ism maydoni.'),
      ParaBlock('Class nomlari **UpperCamelCase**: `Talaba`, `BankHisobi`, `Mahsulot`.'),
    ],
    analogy: AnalogyBlock(
      'Avtomobil chizmasi va zavod',
      'Class — avtomobil chizmasi: "4 g\'ildirak, rang, model, haydash funksiyasi". Obyekt — zavoddan chiqqan aniq mashina: qizil Malibu, oq Nexia. Bitta chizmadan minglab mashina yasaladi, har birining rangi (maydon qiymati) o\'ziniki.',
      icon: Icons.directions_car_outlined,
    ),
    why: 'Real ilovalarda Foydalanuvchi, Mahsulot, Buyurtma, Xabar kabi tushunchalar bor. Class lar ularni tartibli modellashtiradi. Flutterdagi har bir widget ham — class!',
    where: [
      'Ma\'lumot modellari: `class Mahsulot { String nom; double narx; }`',
      'Flutter: `class MeningSahifam extends StatelessWidget`',
      'Servislar: `class AuthService { Future<void> login() }`',
    ],
    terms: [
      TermBlock(term: 'Class', uz: 'Sinf (klass)', meaning: 'Obyektlar uchun chizma.', why: 'Ma\'lumot va xatti-harakatni birlashtiradi.'),
      TermBlock(term: 'Object / Instance', uz: 'Obyekt / Nusxa', meaning: 'Class dan yaratilgan aniq narsa.', why: ''),
      TermBlock(term: 'Field', uz: 'Maydon', meaning: 'Obyektning ma\'lumoti.', why: '', example: 'String ism;'),
      TermBlock(term: 'Method', uz: 'Metod', meaning: 'Class ichidagi funksiya.', why: '', example: 'void gapir()'),
      TermBlock(term: 'Constructor', uz: 'Konstruktor', meaning: 'Obyekt yaratuvchi maxsus funksiya.', why: 'Boshlang\'ich qiymatlarni berish.'),
      TermBlock(term: 'this', uz: 'shu (obyekt)', meaning: 'Joriy obyektga havola.', why: 'Maydon va parametr nomlari bir xil bo\'lganda.'),
    ],
    animation: AnimationBlock('class_object', 'Bitta class chizmasidan turli qiymatli obyektlar yaratiladi.'),
    syntax: SyntaxBlock(r'''class Nom {
  Tur maydon;

  Nom(this.maydon);

  void metod() { }
}''', [
      SyntaxPart('class Nom', 'UpperCamelCase nom'),
      SyntaxPart('Tur maydon;', 'obyekt ma\'lumoti'),
      SyntaxPart('Nom(this.maydon);', 'konstruktor — maydonni to\'ldiradi'),
      SyntaxPart('void metod()', 'obyekt xatti-harakati'),
    ]),
    example: CodeBlock(
      r'''class Talaba {
  String ism;
  int yosh;
  List<int> baholar = [];

  Talaba(this.ism, this.yosh);

  void bahoQosh(int baho) {
    baholar.add(baho);
  }

  double ortacha() {
    if (baholar.isEmpty) return 0;
    return baholar.reduce((a, b) => a + b) / baholar.length;
  }

  void tanishtir() {
    print("Men $ism, $yosh yoshdaman. O'rtacha: ${ortacha()}");
  }
}

void main() {
  var ali = Talaba('Ali', 19);
  var laylo = Talaba('Laylo', 20);

  ali.bahoQosh(5);
  ali.bahoQosh(4);
  laylo.bahoQosh(5);

  ali.tanishtir();
  laylo.tanishtir();
  ali.yosh++;
  print(ali.yosh);
}''',
      title: 'Talaba class i',
      explain: {
        'class': 'Yangi class (chizma) e\'lon qilinadi.',
        'Talaba': 'Class nomi — UpperCamelCase.',
        'this.ism': 'Konstruktor parametri to\'g\'ridan-to\'g\'ri ism maydoniga yoziladi.',
        'bahoQosh': 'Metod — obyekt ma\'lumotini o\'zgartiradi.',
        "Talaba('Ali', 19)": 'Yangi obyekt yaratiladi (konstruktor chaqiriladi).',
        'ali.bahoQosh(5)': 'Obyekt metodini chaqirish: obyekt.metod()',
      },
      expectedOutput: "Men Ali, 19 yoshdaman. O'rtacha: 4.5\nMen Laylo, 20 yoshdaman. O'rtacha: 5.0\n20\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''class Kitob {
  String nom;
  String muallif;
}

void main() {
  var k = Kitob();
  print(k.nom);
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Konstruktor qo\'shib tuzating va `Kitob(\'O\\\'tkan kunlar\', \'Abdulla Qodiriy\')` yarating.',
      why: '`nom` va `muallif` null bo\'la olmaydigan String — ular obyekt yaratilganda albatta qiymat olishi kerak. Konstruktor `Kitob(this.nom, this.muallif);` buni ta\'minlaydi.',
      fixed: r'''class Kitob {
  String nom;
  String muallif;

  Kitob(this.nom, this.muallif);
}

void main() {
  var k = Kitob("O'tkan kunlar", 'Abdulla Qodiriy');
  print(k.nom);
}''',
      hint: 'Class ichiga Kitob(this.nom, this.muallif); qo\'shing.',
    ),
    task: CodeTask(
      title: 'Bank hisobi',
      instructions: '`BankHisobi` class ini yozing:\n- `String egasi`, `double balans` maydonlari\n- konstruktor: `BankHisobi(this.egasi, this.balans)`\n- `void qoyish(double s)` — balansga qo\'shadi\n- `bool yechish(double s)` — yetarli bo\'lsa ayiradi va `true`, aks holda `false` qaytaradi',
      starter: r'''class BankHisobi {
  // maydonlar, konstruktor va metodlar
}

void main() {
  var h = BankHisobi('Aziz', 1000);
  h.qoyish(500);
  print(h.yechish(2000));
  print(h.balans);
}''',
      checks: [
        OutputEquals('false\n1500.0\n', label: 'main natijasi'),
        EvaluatesTo("(BankHisobi('A', 100)..qoyish(50)).balans", '150.0', hidden: true),
        EvaluatesTo("BankHisobi('A', 100).yechish(30)", 'true', hidden: true),
        EvaluatesTo("(BankHisobi('A', 100)..yechish(30)).balans", '70.0', hidden: true),
      ],
      hints: [
        'String egasi; double balans; BankHisobi(this.egasi, this.balans);',
        'void qoyish(double s) { balans += s; }',
        r'''bool yechish(double s) {
  if (s > balans) return false;
  balans -= s;
  return true;
}'''
      ],
      solution: r'''class BankHisobi {
  String egasi;
  double balans;

  BankHisobi(this.egasi, this.balans);

  void qoyish(double s) {
    balans += s;
  }

  bool yechish(double s) {
    if (s > balans) return false;
    balans -= s;
    return true;
  }
}

void main() {
  var h = BankHisobi('Aziz', 1000);
  h.qoyish(500);
  print(h.yechish(2000));
  print(h.balans);
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Class va obyekt munosabati qaysi?',
        options: ['Class — nusxa, obyekt — chizma', 'Class — chizma, obyekt — undan yaratilgan nusxa', 'Ular bir xil', 'Obyekt faqat bitta bo\'ladi'],
        correct: 1,
        explanation: 'Bitta class (chizma) dan ko\'p obyekt (nusxa) yaratiladi.',
        topic: 'Class',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''class Hisob {
  int son = 0;
  void oshir() => son++;
}

void main() {
  var a = Hisob();
  var b = Hisob();
  a.oshir();
  a.oshir();
  b.oshir();
  print('${a.son} ${b.son}');
}''',
        options: ['3 3', '2 1', '1 2', '0 0'],
        explanation: 'Har bir obyektning maydonlari alohida: a — 2, b — 1.',
        topic: 'Obyekt',
      ),
      FillBlank(
        prompt: 'Konstruktorni to\'ldiring',
        template: 'class Nuqta {\n  int x, y;\n  Nuqta(this.x, ____.y);\n}\n\nvoid main() {\n  print(Nuqta(2, 3).y);\n}',
        accepted: ['this'],
        expectedOutput: '3\n',
        explanation: 'this.y — parametr y maydoniga yoziladi.',
        topic: 'Konstruktor',
      ),
    ],
    summary: [
      'Class — chizma, obyekt — nusxa',
      'Maydonlar — ma\'lumot, metodlar — xatti-harakat',
      'Konstruktor: ClassNomi(this.maydon)',
      'Murojaat: obyekt.maydon, obyekt.metod()',
    ],
    next: 'Keyingi darsda konstruktorlarning boshqa turlari — named, factory va initializer list ni o\'rganamiz.',
    revisionTip: 'O\'zingiz yoqtirgan narsani (telefon, kitob, o\'yin qahramoni) class qilib modellashtiring: 3 maydon, 2 metod.',
    links: [DocLink('Classes', 'https://dart.dev/language/classes')],
  ),

  // ───────────────────────── 3.5 ─────────────────────────
  Lesson(
    id: 'l3_constructors',
    title: 'Konstruktorlar, getter va setter',
    subtitle: 'Obyektlarni to\'g\'ri yaratish va himoyalash',
    icon: Icons.build_circle_outlined,
    minutes: 15,
    skills: ['dart.constructors', 'dart.encapsulation'],
    prerequisites: ['Class va obyekt'],
    objectives: [
      'Nomli konstruktor (`Nuqta.boshi()`) va initializer list ni yozasiz',
      'Private (`_`) maydonlar bilan inkapsulyatsiya qilasiz',
      'Getter va setter yozasiz, `toString` ni qayta aniqlaysiz',
    ],
    intro: [
      HeadingBlock('Konstruktor turlari'),
      BulletsBlock([
        '**Oddiy**: `Nuqta(this.x, this.y);`',
        '**Nomli**: `Nuqta.boshi() : x = 0, y = 0;` — bir nechta yaratish usuli',
        '**Nomli parametrli**: `Foydalanuvchi({required this.ism, this.yosh = 0});`',
        '**const**: `const Rang(this.kod);` — o\'zgarmas obyekt',
        '**factory**: kesh yoki boshqa turdagi obyekt qaytarishi mumkin',
      ]),
      ParaBlock('`: x = 0, y = 0` — **initializer list**: tanadan oldin maydonlarni to\'ldiradi.'),
      HeadingBlock('Inkapsulyatsiya'),
      ParaBlock('`_` bilan boshlangan nom **private** (faqat shu fayl ichida ko\'rinadi). Ichki ma\'lumotni yashirib, unga faqat nazoratli kirish beriladi:'),
      BulletsBlock([
        '**getter**: `double get balans => _balans;` — o\'qish',
        '**setter**: `set yosh(int v) { if (v >= 0) _yosh = v; }` — tekshirib yozish',
      ]),
      ParaBlock('**`toString()`** — obyekt `print` qilinganda nima chiqishini belgilaydi. Odatiy: `Instance of \'Nuqta\'`.'),
    ],
    analogy: AnalogyBlock(
      'Bankomat',
      'Bankomat ichidagi pullar (private _balans) to\'g\'ridan-to\'g\'ri qo\'lingizga berilmaydi. Siz faqat ekran (getter — balansni ko\'rish) va tugmalar (setter/metod — tekshiruv bilan pul yechish) orqali ishlaysiz. Bu inkapsulyatsiya.',
      icon: Icons.atm_outlined,
    ),
    why: 'Noto\'g\'ri qiymatlar (manfiy yosh, manfiy balans) dasturni buzadi. Inkapsulyatsiya obyektni noto\'g\'ri holatdan himoya qiladi. Nomli konstruktorlar esa JSON dan obyekt yaratishda keng qo\'llanadi: `User.fromJson(map)`.',
    where: [
      'JSON: `Mahsulot.fromJson(Map<String, dynamic> j)`',
      'Flutter: `const EdgeInsets.all(16)`, `EdgeInsets.symmetric(...)` — nomli konstruktorlar',
      'Validatsiya: setter ichida tekshiruv',
    ],
    terms: [
      TermBlock(term: 'Named constructor', uz: 'Nomli konstruktor', meaning: 'ClassNomi.nom() shaklidagi qo\'shimcha konstruktor.', why: 'Turli yaratish usullari.', example: 'User.fromJson()'),
      TermBlock(term: 'Initializer list', uz: 'Boshlang\'ich ro\'yxat', meaning: 'Konstruktor : dan keyingi maydon qiymatlari.', why: 'final maydonlarni to\'ldirish.'),
      TermBlock(term: 'Encapsulation', uz: 'Inkapsulyatsiya', meaning: 'Ichki ma\'lumotni yashirish va nazoratli kirish berish.', why: 'Obyekt yaxlitligini saqlash.'),
      TermBlock(term: 'Getter / Setter', uz: 'O\'quvchi / Yozuvchi', meaning: 'Maydonga nazoratli kirish metodlari.', why: ''),
      TermBlock(term: 'Private (_)', uz: 'Yopiq', meaning: '_ bilan boshlangan nom — faqat kutubxona ichida.', why: ''),
    ],
    example: CodeBlock(
      r'''class Nuqta {
  final int x;
  final int y;

  const Nuqta(this.x, this.y);
  const Nuqta.boshi() : x = 0, y = 0;
  Nuqta.diagonal(int k) : x = k, y = k;

  @override
  String toString() => 'Nuqta($x, $y)';
}

class Foydalanuvchi {
  final String ism;
  int _yosh = 0;

  Foydalanuvchi({required this.ism, int yosh = 0}) {
    this.yosh = yosh;
  }

  int get yosh => _yosh;

  set yosh(int v) {
    if (v >= 0 && v < 150) _yosh = v;
  }

  bool get kattaYoshli => _yosh >= 18;
}

void main() {
  print(Nuqta(3, 4));
  print(Nuqta.boshi());
  print(Nuqta.diagonal(7));

  var f = Foydalanuvchi(ism: 'Sardor', yosh: 17);
  print(f.kattaYoshli);
  f.yosh = -5;
  print(f.yosh);
  f.yosh = 18;
  print('${f.ism}: ${f.yosh}, katta: ${f.kattaYoshli}');
}''',
      title: 'Konstruktorlar va inkapsulyatsiya',
      explain: {
        'Nuqta.boshi()': 'Nomli konstruktor.',
        ': x = 0, y = 0': 'Initializer list — final maydonlarni to\'ldiradi.',
        '@override': 'Ota class (Object) metodini qayta aniqlash belgisi.',
        'toString': 'print qilinganda chiqadigan matn.',
        '_yosh': 'Private maydon — tashqaridan to\'g\'ridan-to\'g\'ri o\'zgartirilmaydi.',
        'get': 'Getter — qiymatni o\'qish.',
        'set': 'Setter — tekshiruv bilan yozish.',
      },
      expectedOutput: 'Nuqta(3, 4)\nNuqta(0, 0)\nNuqta(7, 7)\nfalse\n17\nSardor: 18, katta: true\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''class Doira {
  final double radius;
  Doira(this.radius);
}

void main() {
  var d = Doira(5);
  d.radius = 10;
  print(d.radius);
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Radiusi 10 bo\'lgan **yangi** doira yarating.',
      why: '`radius` — final: obyekt yaratilgandan keyin o\'zgarmaydi. O\'zgarmas obyektlar bilan ishlashda yangi qiymat uchun **yangi obyekt** yaratiladi.',
      fixed: r'''class Doira {
  final double radius;
  Doira(this.radius);
}

void main() {
  var d = Doira(5);
  d = Doira(10);
  print(d.radius);
}''',
    ),
    task: CodeTask(
      title: 'Harorat class i',
      instructions: '`Harorat` class:\n- private `double _selsiy`\n- konstruktor `Harorat(this._selsiy)`\n- nomli konstruktor `Harorat.farengeytdan(double f)` : `_selsiy = (f - 32) * 5 / 9`\n- getter `double get selsiy`\n- getter `double get farengeyt` = selsiy * 9 / 5 + 32',
      starter: r'''class Harorat {
}

void main() {
  var h = Harorat(100);
  print(h.farengeyt);
  print(Harorat.farengeytdan(212).selsiy);
}''',
      checks: [
        OutputEquals('212.0\n100.0\n', label: 'main natijasi'),
        EvaluatesTo('Harorat(0).farengeyt', '32.0', hidden: true),
        EvaluatesTo('Harorat.farengeytdan(32).selsiy', '0.0', hidden: true),
        UsesConstruct(r'_selsiy', 'Private `_selsiy` maydoni bo\'lishi kerak'),
      ],
      hints: ['double _selsiy; Harorat(this._selsiy);', 'Harorat.farengeytdan(double f) : _selsiy = (f - 32) * 5 / 9;', 'double get farengeyt => _selsiy * 9 / 5 + 32;'],
      solution: r'''class Harorat {
  double _selsiy;

  Harorat(this._selsiy);
  Harorat.farengeytdan(double f) : _selsiy = (f - 32) * 5 / 9;

  double get selsiy => _selsiy;
  double get farengeyt => _selsiy * 9 / 5 + 32;
}

void main() {
  var h = Harorat(100);
  print(h.farengeyt);
  print(Harorat.farengeytdan(212).selsiy);
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''class A {
  int _x = 0;
  int get x => _x;
  set x(int v) {
    if (v > 0) _x = v;
  }
}

void main() {
  var a = A();
  a.x = 5;
  a.x = -1;
  print(a.x);
}''',
        explanation: 'Setter manfiy qiymatni rad etadi — 5 qoladi.',
        topic: 'Setter',
      ),
      SingleChoice(
        prompt: '`toString()` ni qayta aniqlash nimaga ta\'sir qiladi?',
        options: ['Obyekt yaratilishiga', 'print va interpolatsiyada chiqadigan matnga', 'Maydon turlariga', 'Hech narsaga'],
        correct: 1,
        explanation: 'print(obyekt) va \'\$obyekt\' toString() natijasini ishlatadi.',
        topic: 'toString',
      ),
    ],
    summary: [
      'Nomli konstruktor: Class.nom() : initializer list',
      'const konstruktor — o\'zgarmas obyektlar',
      '_private + getter/setter = inkapsulyatsiya',
      'toString() — obyektning matnli ko\'rinishi',
    ],
    next: 'Keyingi darsda meros (inheritance) va polimorfizm — OOP ning eng kuchli tomonlari.',
    revisionTip: 'Mahsulot class iga Mahsulot.fromMap(Map m) nomli konstruktorini qo\'shing.',
  ),

  // ───────────────────────── 3.6 ─────────────────────────
  Lesson(
    id: 'l3_inheritance',
    title: 'Meros va polimorfizm',
    subtitle: 'extends, super, @override',
    icon: Icons.family_restroom_rounded,
    minutes: 15,
    xp: 60,
    skills: ['dart.inheritance', 'dart.polymorphism'],
    prerequisites: ['Konstruktorlar, getter va setter'],
    objectives: [
      '`extends` bilan meros olishni bilasiz',
      '`super` bilan ota konstruktor va metodlarni chaqirasiz',
      'Polimorfizm — bir xil chaqiruv, turli xatti-harakat',
    ],
    intro: [
      ParaBlock('**Meros** (inheritance) — yangi class mavjud class ning maydon va metodlarini **meros qilib oladi**: `class It extends Hayvon`.'),
      BulletsBlock([
        '**Ota class** (superclass): `Hayvon` — umumiy xususiyatlar',
        '**Bola class** (subclass): `It` — umumiy + o\'ziga xos',
        '**`super(...)`** — ota konstruktorini chaqirish',
        '**`@override`** — ota metodini qayta aniqlash',
      ]),
      ParaBlock('**Polimorfizm** ("ko\'p shakllilik") — `Hayvon h = It();` deb yozib, `h.ovoz()` ni chaqirsangiz, **It ning** versiyasi ishlaydi. Bitta ro\'yxatdagi turli obyektlar bir xil metodga turlicha javob beradi.'),
      ParaBlock('`is` operatori turni tekshiradi: `h is It` → true.'),
    ],
    analogy: AnalogyBlock(
      'Oila va meros',
      'Bola ota-onasidan ko\'z rangi, familiya kabi xususiyatlarni meros oladi, lekin o\'zining kasbi, qiziqishlari ham bor. Polimorfizm: "Hamma o\'z ismini aytsin!" deganda har kim o\'z ismini aytadi — buyruq bitta, javob har xil.',
      icon: Icons.groups_outlined,
    ),
    why: 'Takroriy kodni ota class ga chiqarib, umumiy mantiqni bir joyda saqlaysiz. Flutterning o\'zi meros ustiga qurilgan: har bir widget `StatelessWidget` yoki `StatefulWidget` dan meros oladi.',
    where: [
      'Flutter: `class Sahifa extends StatelessWidget`',
      'Shakllar: Doira, Kvadrat → Shakl',
      'To\'lov usullari: Karta, Naqd → Tolov',
    ],
    terms: [
      TermBlock(term: 'Inheritance', uz: 'Meros', meaning: 'Class boshqa class xususiyatlarini oladi.', why: 'Kodni qayta ishlatish.', example: 'class B extends A'),
      TermBlock(term: 'Superclass / Subclass', uz: 'Ota / Bola class', meaning: 'Meros beruvchi va oluvchi.', why: ''),
      TermBlock(term: 'super', uz: 'ota', meaning: 'Ota class ga murojaat.', why: 'Ota konstruktor/metodini chaqirish.'),
      TermBlock(term: '@override', uz: 'Qayta aniqlash', meaning: 'Ota metodini o\'z versiyangiz bilan almashtirish.', why: ''),
      TermBlock(term: 'Polymorphism', uz: 'Polimorfizm', meaning: 'Bir interfeys — turli amalga oshirishlar.', why: 'Moslashuvchan kod.'),
    ],
    animation: AnimationBlock('inheritance', 'Hayvon → It, Mushuk: umumiy qism meros, ovoz() har birida o\'ziga xos.'),
    example: CodeBlock(
      r'''class Hayvon {
  final String ism;
  Hayvon(this.ism);

  String ovoz() => '...';

  void tanishtir() {
    print('$ism: ${ovoz()}');
  }
}

class It extends Hayvon {
  It(super.ism);

  @override
  String ovoz() => 'Vov-vov!';

  void yugur() => print('$ism yuguryapti');
}

class Mushuk extends Hayvon {
  final bool uyda;
  Mushuk(String ism, {this.uyda = true}) : super(ism);

  @override
  String ovoz() => 'Miyov!';
}

void main() {
  var hayvonlar = <Hayvon>[It('Bobik'), Mushuk('Mosh'), Hayvon('Baliq')];
  for (final h in hayvonlar) {
    h.tanishtir();
  }

  var h = hayvonlar[0];
  if (h is It) {
    h.yugur();
  }
  print(hayvonlar[1] is Hayvon);
}''',
      title: 'Hayvonlar oilasi',
      explain: {
        'extends': 'Meros olish: It — Hayvon ning bolasi.',
        'super.ism': 'Super parametr: qiymat to\'g\'ridan-to\'g\'ri ota konstruktoriga.',
        ': super(ism)': 'Ota konstruktorini aniq chaqirish.',
        '@override': 'Ota metodini qayta aniqlash.',
        'is': 'Tur tekshiruvi; if ichida h endi It sifatida ishlatiladi.',
      },
      expectedOutput: 'Bobik: Vov-vov!\nMosh: Miyov!\nBaliq: ...\nBobik yuguryapti\ntrue\n',
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''class Transport {
  final int tezlik;
  Transport(this.tezlik);
}

class Velosiped extends Transport {
  Velosiped();
}

void main() {
  print(Velosiped().tezlik);
}''',
      task: 'Velosiped tezligi 20 bo\'lsin. Konstruktorni tuzating.',
      why: 'Ota class (Transport) konstruktori `tezlik` ni talab qiladi. Bola class konstruktori uni `super(20)` orqali berishi shart.',
      fixed: r'''class Transport {
  final int tezlik;
  Transport(this.tezlik);
}

class Velosiped extends Transport {
  Velosiped() : super(20);
}

void main() {
  print(Velosiped().tezlik);
}''',
    ),
    task: CodeTask(
      title: 'Xodimlar maoshi',
      instructions: '`Xodim` (`String ism`, `double asosiy`, `double maosh()` → asosiy) va undan meros oluvchi `Menejer` (`double bonus`; `maosh()` → asosiy + bonus) class larini yozing.\n`Menejer(\'Aziza\', 5000, 1500).maosh()` → `6500.0`',
      starter: r'''class Xodim {
}

class Menejer extends Xodim {
}

void main() {
  List<Xodim> jamoa = [Xodim('Ali', 4000), Menejer('Aziza', 5000, 1500)];
  for (final x in jamoa) {
    print('${x.ism}: ${x.maosh()}');
  }
}''',
      checks: [
        OutputEquals('Ali: 4000.0\nAziza: 6500.0\n', label: 'main natijasi'),
        EvaluatesTo("Menejer('B', 100, 50).maosh()", '150.0', hidden: true),
        EvaluatesTo("Menejer('B', 100, 50) is Xodim", 'true', hidden: true),
        UsesConstruct(r'@override', '`@override` ishlatilishi kerak'),
      ],
      hints: [
        'Xodim: final String ism; final double asosiy; Xodim(this.ism, this.asosiy); double maosh() => asosiy;',
        'Menejer(super.ism, super.asosiy, this.bonus);',
        '@override double maosh() => asosiy + bonus;',
      ],
      solution: r'''class Xodim {
  final String ism;
  final double asosiy;
  Xodim(this.ism, this.asosiy);

  double maosh() => asosiy;
}

class Menejer extends Xodim {
  final double bonus;
  Menejer(super.ism, super.asosiy, this.bonus);

  @override
  double maosh() => asosiy + bonus;
}

void main() {
  List<Xodim> jamoa = [Xodim('Ali', 4000), Menejer('Aziza', 5000, 1500)];
  for (final x in jamoa) {
    print('${x.ism}: ${x.maosh()}');
  }
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''class A {
  String salom() => 'A';
}

class B extends A {
  @override
  String salom() => 'B + ${super.salom()}';
}

void main() {
  A x = B();
  print(x.salom());
}''',
        options: ['A', 'B', 'B + A', 'Xato'],
        explanation: 'x ning haqiqiy turi B — B.salom() ishlaydi, u super orqali A ni ham chaqiradi.',
        topic: 'Polimorfizm',
      ),
      TrueFalse(
        prompt: 'Dartda class faqat bitta class dan `extends` qila oladi.',
        answer: true,
        explanation: 'Dartda yagona meros (single inheritance). Ko\'p manbadan xususiyat olish uchun mixin va interface ishlatiladi.',
        topic: 'Meros',
      ),
    ],
    summary: [
      'extends — meros; super — ota class',
      '@override — metodni qayta aniqlash',
      'Polimorfizm: ota turidagi o\'zgaruvchi, bola xatti-harakati',
      'is — tur tekshiruvi va avtomatik promotion',
    ],
    next: 'Keyingi darsda abstrakt class va interface — "shartnoma" yozishni o\'rganamiz.',
    revisionTip: 'Shakl → Doira, Tortburchak ierarxiyasini yozib, har birining perimetrini hisoblang.',
    links: [DocLink('Extending a class', 'https://dart.dev/language/extend')],
  ),

  // ───────────────────────── 3.7 ─────────────────────────
  Lesson(
    id: 'l3_abstract',
    title: 'Abstrakt class va interface',
    subtitle: 'Shartnoma yozish: "nima qilish kerak", "qanday" emas',
    icon: Icons.architecture_rounded,
    minutes: 14,
    skills: ['dart.abstraction'],
    prerequisites: ['Meros va polimorfizm'],
    objectives: [
      '`abstract class` va abstrakt metodlarni yozasiz',
      '`implements` bilan interfeysni amalga oshirasiz',
      'extends va implements farqini tushunasiz',
    ],
    intro: [
      ParaBlock('**Abstrakt class** — to\'liq bo\'lmagan, faqat **shablon** bo\'lib xizmat qiladigan class. Undan to\'g\'ridan-to\'g\'ri obyekt yaratib bo\'lmaydi.'),
      ParaBlock('**Abstrakt metod** — tanasi yo\'q metod: `double yuza();`. Har bir bola class uni **albatta** amalga oshirishi kerak — aks holda Dart xato beradi.'),
      HeadingBlock('Interface (implements)'),
      ParaBlock('Dartda har bir class avtomatik **interfeys** hamdir. `class Kvadrat implements Shakl` — "Kvadrat Shakl ning barcha a\'zolarini o\'zi yozib chiqadi" degani (hech narsa meros olinmaydi).'),
      BulletsBlock([
        '`extends` — kodni **meros oladi** (bitta class dan)',
        '`implements` — faqat **shartnomani** bajaradi, hammasini o\'zi yozadi (bir nechta class dan mumkin)',
      ]),
    ],
    analogy: AnalogyBlock(
      'Ish tavsifi (vakansiya)',
      'Abstrakt class — ish tavsifi: "Haydovchi: mashina haydash, yo\'l harakati qoidalarini bilish". Unda aniq odam yo\'q. Har bir yollangan haydovchi (konkret class) bu talablarni o\'z usulida bajaradi. Talabni bajarmasa — ishga olinmaydi (kompilyatsiya xatosi).',
      icon: Icons.assignment_outlined,
    ),
    why: 'Katta loyihalarda abstraksiya qismlarni bir-biridan ajratadi: `AuthRepository` interfeysi bir xil, lekin amalga oshirilishi Firebase, REST yoki test uchun soxta (mock) bo\'lishi mumkin. Bu Clean Architecture ning asosi.',
    where: [
      'Repository pattern: `abstract class UserRepository`',
      'Testlar uchun mock: `class FakeApi implements Api`',
      'Flutter: `abstract class StatelessWidget` — siz build() ni yozasiz',
    ],
    terms: [
      TermBlock(term: 'Abstract class', uz: 'Abstrakt class', meaning: 'To\'g\'ridan-to\'g\'ri obyekt yaratilmaydigan shablon class.', why: 'Umumiy shartnoma.'),
      TermBlock(term: 'Abstract method', uz: 'Abstrakt metod', meaning: 'Tanasiz metod — bolalar yozishi shart.', why: ''),
      TermBlock(term: 'Interface', uz: 'Interfeys', meaning: 'Class bajarishi kerak bo\'lgan a\'zolar to\'plami.', why: 'Qismlarni ajratish.'),
      TermBlock(term: 'implements', uz: 'Amalga oshiradi', meaning: 'Interfeys shartnomasini bajarish.', why: ''),
    ],
    example: CodeBlock(
      r'''abstract class Shakl {
  double yuza();
  String get nomi;

  void malumot() {
    print('$nomi yuzasi: ${yuza().toStringAsFixed(2)}');
  }
}

class Doira extends Shakl {
  final double r;
  Doira(this.r);

  @override
  double yuza() => 3.14159 * r * r;

  @override
  String get nomi => 'Doira';
}

class Tortburchak extends Shakl {
  final double a, b;
  Tortburchak(this.a, this.b);

  @override
  double yuza() => a * b;

  @override
  String get nomi => "To'rtburchak";
}

abstract class Saqlanuvchi {
  String saqla();
}

class Hujjat implements Saqlanuvchi {
  final String matn;
  Hujjat(this.matn);

  @override
  String saqla() => 'Saqlandi: $matn';
}

void main() {
  List<Shakl> shakllar = [Doira(2), Tortburchak(3, 4.5)];
  for (final s in shakllar) {
    s.malumot();
  }
  Saqlanuvchi x = Hujjat('hisobot.pdf');
  print(x.saqla());
}''',
      title: 'Shartnoma va amalga oshirish',
      explain: {
        'abstract': 'Abstrakt class — undan obyekt yaratilmaydi.',
        'double yuza();': 'Abstrakt metod — tanasi yo\'q.',
        'implements': 'Interfeysni amalga oshirish — barcha a\'zolar qayta yoziladi.',
      },
      expectedOutput: "Doira yuzasi: 12.57\nTo'rtburchak yuzasi: 13.50\nSaqlandi: hisobot.pdf\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''abstract class Tolov {
  bool tola(double summa);
}

class KartaTolov extends Tolov {
}

void main() {
  print(KartaTolov().tola(100));
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. `KartaTolov` summasi 0 dan katta bo\'lsa true qaytarsin.',
      why: '`KartaTolov` abstrakt `tola` metodini amalga oshirmagan. Konkret (abstrakt bo\'lmagan) class barcha abstrakt metodlarni yozishi shart.',
      fixed: r'''abstract class Tolov {
  bool tola(double summa);
}

class KartaTolov extends Tolov {
  @override
  bool tola(double summa) => summa > 0;
}

void main() {
  print(KartaTolov().tola(100));
}''',
    ),
    task: CodeTask(
      title: 'Bildirishnoma xizmati',
      instructions: '`abstract class Xabarchi { String yubor(String matn); }` berilgan. Uni amalga oshiring:\n- `SmsXabarchi` → `SMS: <matn>`\n- `EmailXabarchi` → `Email: <matn>`\n`main` dagi sikl ikkalasini ham ishlatadi.',
      starter: r'''abstract class Xabarchi {
  String yubor(String matn);
}

// SmsXabarchi va EmailXabarchi ni yozing

void main() {
  List<Xabarchi> kanallar = [SmsXabarchi(), EmailXabarchi()];
  for (final k in kanallar) {
    print(k.yubor('Salom'));
  }
}''',
      checks: [
        OutputEquals('SMS: Salom\nEmail: Salom\n', label: 'main natijasi'),
        EvaluatesTo("SmsXabarchi().yubor('Kod: 1234')", 'SMS: Kod: 1234', hidden: true),
      ],
      hints: ['class SmsXabarchi implements Xabarchi { ... }', '@override String yubor(String matn) => \'SMS: \$matn\';', 'Ikkinchisi ham xuddi shunday.'],
      solution: r'''abstract class Xabarchi {
  String yubor(String matn);
}

class SmsXabarchi implements Xabarchi {
  @override
  String yubor(String matn) => 'SMS: $matn';
}

class EmailXabarchi implements Xabarchi {
  @override
  String yubor(String matn) => 'Email: $matn';
}

void main() {
  List<Xabarchi> kanallar = [SmsXabarchi(), EmailXabarchi()];
  for (final k in kanallar) {
    print(k.yubor('Salom'));
  }
}''',
    ),
    quiz: [
      TrueFalse(
        prompt: 'Abstrakt class dan `Shakl()` deb obyekt yaratish mumkin.',
        answer: false,
        explanation: 'Abstrakt class — faqat shablon. Obyekt uning konkret bolalaridan yaratiladi.',
        topic: 'Abstrakt',
      ),
      SingleChoice(
        prompt: 'extends va implements farqi?',
        options: [
          'Farqi yo\'q',
          'extends kodni meros oladi, implements faqat shartnomani bajaradi',
          'implements kodni meros oladi',
          'extends bir nechta class dan mumkin',
        ],
        correct: 1,
        explanation: 'implements bilan barcha a\'zolarni o\'zingiz yozasiz; extends esa tayyor kodni oladi.',
        topic: 'Interface',
      ),
    ],
    summary: [
      'abstract class — shablon, undan obyekt yaratilmaydi',
      'Abstrakt metod — tanasiz, bolalar yozishi shart',
      'implements — interfeys shartnomasini to\'liq bajarish',
      'Abstraksiya — katta loyihalar arxitekturasining asosi',
    ],
    next: 'Keyingi darsda enum, mixin va extension — Dartning zamonaviy imkoniyatlari.',
    revisionTip: '`abstract class Ombor { void qosh(String x); List<String> hammasi(); }` va uning List asosidagi amalga oshirilishini yozing.',
  ),

  // ───────────────────────── 3.8 ─────────────────────────
  Lesson(
    id: 'l3_enum_mixin_ext',
    title: 'Enum, mixin va extension',
    subtitle: 'Cheklangan qiymatlar, qobiliyatlar va kengaytmalar',
    icon: Icons.auto_awesome_motion_outlined,
    minutes: 14,
    skills: ['dart.enums', 'dart.mixins', 'dart.extensions'],
    prerequisites: ['Abstrakt class va interface'],
    objectives: [
      '`enum` bilan cheklangan qiymatlar to\'plamini yaratasiz',
      '`mixin` bilan qobiliyatlarni bir nechta class ga qo\'shasiz',
      '`extension` bilan mavjud turlarga yangi metod qo\'shasiz',
    ],
    intro: [
      HeadingBlock('Enum'),
      ParaBlock('**Enum** — oldindan ma\'lum, cheklangan qiymatlar to\'plami: `enum Holat { kutilmoqda, yuborildi, yetkazildi }`. String o\'rniga enum ishlatsangiz, imlo xatolari bo\'lmaydi va `switch` barcha holatlarni qamrab olganini Dart tekshiradi.'),
      ParaBlock('Enhanced enum: maydon va metodlar ham bo\'lishi mumkin.'),
      HeadingBlock('Mixin'),
      ParaBlock('**Mixin** — bir nechta class ga "qo\'shimcha qobiliyat" ulash usuli: `class Ordak extends Qush with Suzuvchi, Uchuvchi`. Meros bitta bo\'ladi, mixin esa ko\'p.'),
      HeadingBlock('Extension'),
      ParaBlock('**Extension** — mavjud class ga (hatto `int`, `String` ga!) uning kodini o\'zgartirmasdan yangi metod qo\'shish: `extension on String { String get bosh => this[0].toUpperCase() + substring(1); }`'),
    ],
    analogy: AnalogyBlock(
      'Svetofor, ko\'nikmalar va aksessuarlar',
      'Enum — svetofor ranglari: faqat qizil, sariq, yashil — boshqasi bo\'lmaydi. Mixin — ko\'nikma sertifikatlari: odam bir vaqtda ham suzuvchi, ham haydovchi bo\'lishi mumkin. Extension — telefonga g\'ilof va ushlagich: telefonning o\'zini o\'zgartirmay, yangi imkoniyat qo\'shasiz.',
      icon: Icons.traffic_outlined,
    ),
    why: 'Enum — holatlar (theme mode, buyurtma holati), mixin — Flutterda `with SingleTickerProviderStateMixin` (animatsiyalar uchun), extension — `context.theme` kabi qulay yordamchilar uchun.',
    where: [
      'Flutter: `ThemeMode.dark`, `MainAxisAlignment.center` — enumlar',
      'Flutter: `with TickerProviderStateMixin` — mixin',
      'Yordamchilar: `extension on BuildContext`',
    ],
    terms: [
      TermBlock(term: 'enum', uz: 'Sanab o\'tiladigan tur', meaning: 'Cheklangan nomli qiymatlar.', why: 'Xavfsiz holatlar.', example: 'enum Rang { qizil, yashil }'),
      TermBlock(term: 'mixin', uz: 'Aralashma', meaning: 'Class ga with orqali qo\'shiladigan kod.', why: 'Ko\'p manbadan qobiliyat.'),
      TermBlock(term: 'extension', uz: 'Kengaytma', meaning: 'Mavjud turga yangi a\'zolar qo\'shish.', why: 'Qulay yordamchi metodlar.'),
    ],
    example: CodeBlock(
      r'''enum Holat { kutilmoqda, yuborildi, yetkazildi }

enum Tarif {
  oddiy(10000),
  premium(50000);

  final int narx;
  const Tarif(this.narx);
}

mixin Suzuvchi {
  void suz() => print('Suzyapti');
}

mixin Uchuvchi {
  void uch() => print('Uchyapti');
}

class Ordak with Suzuvchi, Uchuvchi {}

extension MatnYordam on String {
  String get boshHarf => this[0].toUpperCase() + substring(1);
}

extension SonYordam on int {
  bool get juftmi => this % 2 == 0;
}

String tavsif(Holat h) => switch (h) {
  Holat.kutilmoqda => 'Kutilmoqda...',
  Holat.yuborildi => "Yo'lda",
  Holat.yetkazildi => 'Yetkazildi!',
};

void main() {
  var h = Holat.yuborildi;
  print(h);
  print(h.name);
  print(tavsif(h));
  print(Holat.values.length);
  print(Tarif.premium.narx);

  var o = Ordak();
  o.suz();
  o.uch();

  print('toshkent'.boshHarf);
  print(8.juftmi);
}''',
      title: 'Uchalasi amalda',
      explain: {
        'enum': 'Cheklangan qiymatlar turi.',
        'Tarif(this.narx)': 'Enhanced enum — maydonli enum.',
        'mixin': 'Qo\'shiladigan qobiliyat.',
        'with': 'Mixin larni ulash.',
        'extension': 'Mavjud turga yangi a\'zo qo\'shish.',
        'this': 'Extension ichida — kengaytirilayotgan qiymat.',
      },
      expectedOutput: "Holat.yuborildi\nyuborildi\nYo'lda\n3\n50000\nSuzyapti\nUchyapti\nToshkent\ntrue\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''enum Fasl { qish, bahor, yoz, kuz }

String kiyim(Fasl f) {
  switch (f) {
    case Fasl.qish:
      return 'Palto';
    case Fasl.yoz:
      return 'Futbolka';
  }
}

void main() {
  print(kiyim(Fasl.bahor));
}''',
      task: 'Kod kompilyatsiya bo\'lmayapti. Bahor va kuz uchun `Kurtka` qaytaring.',
      why: 'switch enum ning barcha qiymatlarini qamramagan (bahor, kuz yetishmayapti). Dart buni tekshiradi — bu "exhaustiveness checking" va u ko\'p xatolarning oldini oladi.',
      fixed: r'''enum Fasl { qish, bahor, yoz, kuz }

String kiyim(Fasl f) {
  switch (f) {
    case Fasl.qish:
      return 'Palto';
    case Fasl.yoz:
      return 'Futbolka';
    case Fasl.bahor:
    case Fasl.kuz:
      return 'Kurtka';
  }
}

void main() {
  print(kiyim(Fasl.bahor));
}''',
    ),
    task: CodeTask(
      title: 'Narx formatlash extension',
      instructions: '`extension SomFormat on int` yozing: `String get som` getteri sonni minglik bo\'laklarga ajratib, oxiriga ` so\'m` qo\'shsin.\n`1500000.som` → `1 500 000 so\'m`, `999.som` → `999 so\'m`',
      starter: r'''extension SomFormat on int {
  String get som {
    var s = toString();
    // har 3 raqamdan keyin bo'shliq qo'ying (oxiridan boshlab)
    return "$s so'm";
  }
}

void main() {
  print(1500000.som);
}''',
      checks: [
        EvaluatesTo('1500000.som', "1 500 000 so'm"),
        EvaluatesTo('999.som', "999 so'm"),
        EvaluatesTo('1000.som', "1 000 so'm", hidden: true),
        EvaluatesTo('25000.som', "25 000 so'm", hidden: true),
      ],
      hints: [
        'Oxiridan boshiga qarab yuring va har 3 belgidan keyin bo\'shliq qo\'shing.',
        "var natija = ''; var sanoq = 0; for (var i = s.length - 1; i >= 0; i--) { ... }",
        r'''for (var i = s.length - 1; i >= 0; i--) {
  natija = s[i] + natija;
  sanoq++;
  if (sanoq % 3 == 0 && i > 0) natija = ' ' + natija;
}'''
      ],
      solution: r'''extension SomFormat on int {
  String get som {
    var s = toString();
    var natija = '';
    var sanoq = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      natija = s[i] + natija;
      sanoq++;
      if (sanoq % 3 == 0 && i > 0) natija = ' $natija';
    }
    return "$natija so'm";
  }
}

void main() {
  print(1500000.som);
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''enum Rang { qizil, yashil, kok }

void main() {
  print(Rang.kok.index);
  print(Rang.values.first.name);
}''',
        options: ['2\nqizil', '3\nqizil', 'kok\n0', '2\nRang.qizil'],
        explanation: 'index 0 dan boshlanadi (kok — 2), name — qiymat nomi.',
        topic: 'Enum',
      ),
      SingleChoice(
        prompt: '`class A with B, C` da B va C nima?',
        options: ['Ota class lar', 'Mixin lar', 'Enum lar', 'Extension lar'],
        correct: 1,
        explanation: 'with — mixin larni ulash kalit so\'zi.',
        topic: 'Mixin',
      ),
    ],
    summary: [
      'enum — cheklangan qiymatlar; .name, .index, .values',
      'switch enum barcha holatlarni qamrashi shart',
      'mixin + with — ko\'p qobiliyatlarni ulash',
      'extension — mavjud turga yangi metod/getter',
    ],
    next: 'Keyingi darsda dastur xatolarini boshqarish — try, catch, throw ni o\'rganamiz.',
    revisionTip: 'Buyurtma holatlari uchun enum yarating va har biriga emoji qaytaruvchi extension yozing.',
  ),

  // ───────────────────────── 3.9 ─────────────────────────
  Lesson(
    id: 'l3_errors',
    title: 'Xatolarni boshqarish: try, catch, throw',
    subtitle: 'Dastur qulamasligi uchun',
    icon: Icons.health_and_safety_outlined,
    minutes: 14,
    xp: 60,
    skills: ['dart.errors'],
    prerequisites: ['Abstrakt class va interface'],
    objectives: [
      'Exception (istisno) nima ekanini bilasiz',
      '`try / on / catch / finally` bilan xatolarni ushlaysiz',
      '`throw` bilan o\'z xatolaringizni yaratasiz',
    ],
    intro: [
      ParaBlock('Ba\'zi xatolar faqat dastur **ishlayotganda** yuz beradi: foydalanuvchi son o\'rniga harf kiritdi, internet uzildi, fayl topilmadi. Ular **exception** (istisno) deyiladi. Ushlanmasa — dastur to\'xtaydi.'),
      ParaBlock('**try-catch** — "sinab ko\'r, xato bo\'lsa — mana bunday qil":'),
      BulletsBlock([
        '`try { ... }` — xato chiqishi mumkin bo\'lgan kod',
        '`on FormatException catch (e) { ... }` — aniq turdagi xato',
        '`catch (e) { ... }` — har qanday xato',
        '`finally { ... }` — xato bo\'lsa ham, bo\'lmasa ham bajariladi',
      ]),
      ParaBlock('**`throw`** — o\'zingiz xato "tashlash": `throw Exception(\'Balans yetarli emas\');`'),
      ParaBlock('O\'z xato class ingiz: `class KamBalans implements Exception { ... }`'),
      CalloutBlock(CalloutKind.tip, 'Professional maslahat', 'Xatoni "yutib yubormang" (bo\'sh catch). Hech bo\'lmaganda foydalanuvchiga tushunarli xabar ko\'rsating yoki log qiling.'),
    ],
    analogy: AnalogyBlock(
      'Xavfsizlik to\'ri',
      'Sirk akrobati (try) murakkab harakat qiladi. Pastda xavfsizlik to\'ri (catch) bor — yiqilsa, to\'r ushlab qoladi va tomosha davom etadi. finally — tomosha qanday tugashidan qat\'i nazar, oxirida chiroqlar yoqiladi.',
      icon: Icons.sports_gymnastics_rounded,
    ),
    why: 'Haqiqiy ilovalarda internet, server, foydalanuvchi kiritmasi — hammasi ishonchsiz. Xatolarni to\'g\'ri boshqarish "ilova to\'xtab qoldi" o\'rniga "Internet yo\'q, qayta urinib ko\'ring" deyishga imkon beradi.',
    where: [
      'API so\'rovlari: tarmoq xatolari',
      'Forma: noto\'g\'ri kiritilgan son',
      'Fayl/ma\'lumotlar bazasi bilan ishlash',
    ],
    terms: [
      TermBlock(term: 'Exception', uz: 'Istisno (xato)', meaning: 'Ish vaqtida yuz beradigan, ushlash mumkin bo\'lgan xato.', why: 'Dastur qulamasligi uchun.'),
      TermBlock(term: 'try / catch', uz: 'Sinash / Ushlash', meaning: 'Xatoni ushlash konstruksiyasi.', why: ''),
      TermBlock(term: 'throw', uz: 'Tashlash', meaning: 'Xatoni qo\'lda yaratish.', why: 'Noto\'g\'ri holatni bildirish.'),
      TermBlock(term: 'finally', uz: 'Oxirida', meaning: 'Doim bajariladigan blok.', why: 'Resurslarni tozalash.'),
      TermBlock(term: 'Stack trace', uz: 'Chaqiruvlar izi', meaning: 'Xato qaysi funksiyalar orqali kelganini ko\'rsatadi.', why: 'Debug uchun.'),
    ],
    example: CodeBlock(
      r'''class KamBalans implements Exception {
  final double yetishmaydi;
  KamBalans(this.yetishmaydi);

  @override
  String toString() => "Balans yetarli emas: yana $yetishmaydi so'm kerak";
}

double yechish(double balans, double summa) {
  if (summa <= 0) throw ArgumentError('Summa musbat bo\'lishi kerak');
  if (summa > balans) throw KamBalans(summa - balans);
  return balans - summa;
}

void main() {
  var kiritma = '12a';
  try {
    var son = int.parse(kiritma);
    print(son);
  } on FormatException {
    print("Xato kiritma: '$kiritma' son emas");
  }

  try {
    print(yechish(50000, 80000));
  } on KamBalans catch (e) {
    print(e);
  } finally {
    print('Tranzaksiya yakunlandi');
  }

  try {
    yechish(100, -5);
  } catch (e) {
    print('Ushlandi: $e');
  }
  print('Dastur davom etmoqda');
}''',
      title: 'Xatolarni ushlash',
      explain: {
        'try': 'Xato chiqishi mumkin bo\'lgan kod.',
        'on FormatException': 'Faqat shu turdagi xatoni ushlaydi.',
        'catch (e)': 'Xato obyekti e ga yoziladi.',
        'finally': 'Har doim bajariladi.',
        'throw': 'Xatoni tashlash.',
        'implements Exception': 'O\'z xato turingiz.',
      },
      expectedOutput: "Xato kiritma: '12a' son emas\nBalans yetarli emas: yana 30000.0 so'm kerak\nTranzaksiya yakunlandi\nUshlandi: Invalid argument(s): Summa musbat bo'lishi kerak\nDastur davom etmoqda\n",
      visualize: true,
    ),
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var kiritma = 'yigirma';
  var yosh = int.parse(kiritma);
  print('Yosh: $yosh');
  print('Dastur tugadi');
}''',
      task: 'Ishga tushiring — dastur qulaydi. Xatoni ushlab, `Noto\'g\'ri yosh` chiqaring va dastur `Dastur tugadi` gacha yetsin.',
      why: '`int.parse(\'yigirma\')` FormatException tashlaydi. try-catch bilan ushlanmasa, dastur to\'xtaydi. (Muqobil: `int.tryParse` + null tekshiruvi.)',
      fixed: r'''void main() {
  var kiritma = 'yigirma';
  try {
    var yosh = int.parse(kiritma);
    print('Yosh: $yosh');
  } on FormatException {
    print("Noto'g'ri yosh");
  }
  print('Dastur tugadi');
}''',
    ),
    task: CodeTask(
      title: 'Xavfsiz bo\'lish',
      instructions: '`String bol(int a, int b)` — `a ~/ b` natijasini matn qilib qaytarsin. Agar `b == 0` bo\'lsa `throw ArgumentError(\'nol\')` qiling.\n`xavfsizBol(int a, int b)` esa `bol` ni chaqirsin va xato bo\'lsa `Xato: nolga bo\'lish` qaytarsin.',
      starter: r'''String bol(int a, int b) {
  return '${a ~/ b}';
}

String xavfsizBol(int a, int b) {
  return bol(a, b);
}

void main() {
  print(xavfsizBol(10, 2));
  print(xavfsizBol(1, 0));
}''',
      checks: [
        OutputEquals("5\nXato: nolga bo'lish\n", label: 'main natijasi'),
        EvaluatesTo('xavfsizBol(9, 3)', '3', hidden: true),
        UsesConstruct(r'throw', '`throw` ishlatilishi kerak'),
        UsesConstruct(r'catch', '`catch` ishlatilishi kerak'),
      ],
      hints: [
        "if (b == 0) throw ArgumentError('nol');",
        'xavfsizBol ichida try { return bol(a, b); } catch (e) { ... }',
        r'''try {
  return bol(a, b);
} catch (e) {
  return "Xato: nolga bo'lish";
}'''
      ],
      solution: r'''String bol(int a, int b) {
  if (b == 0) throw ArgumentError('nol');
  return '${a ~/ b}';
}

String xavfsizBol(int a, int b) {
  try {
    return bol(a, b);
  } catch (e) {
    return "Xato: nolga bo'lish";
  }
}

void main() {
  print(xavfsizBol(10, 2));
  print(xavfsizBol(1, 0));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  try {
    print('A');
    throw Exception('x');
  } catch (e) {
    print('B');
  } finally {
    print('C');
  }
  print('D');
}''',
        options: ['A\nB\nC\nD', 'A\nC\nD', 'A\nB\nD', 'A'],
        explanation: 'A chiqadi, xato tashlanadi → catch (B) → finally (C) → dastur davom etadi (D).',
        topic: 'try-catch',
      ),
      SingleChoice(
        prompt: '`finally` bloki qachon bajariladi?',
        options: ['Faqat xato bo\'lsa', 'Faqat xato bo\'lmasa', 'Har doim', 'Hech qachon'],
        correct: 2,
        explanation: 'finally — xato bo\'ladimi yo\'qmi, har doim bajariladi.',
        topic: 'finally',
      ),
    ],
    summary: [
      'Exception — ish vaqtidagi xato',
      'try { } on Tur catch (e) { } finally { }',
      'throw — xato tashlash; o\'z xato class i: implements Exception',
      'Xatoni yutmang — foydalanuvchiga tushunarli xabar bering',
    ],
    next: 'Tabriklaymiz — OOP moduli tugadi! Endi asinxron Dart\'ga o\'tamiz: Future, async/await va Stream — haqiqiy ilovalar shular ustida ishlaydi.',
    revisionTip: 'Foydalanuvchidan yosh so\'raydigan, noto\'g\'ri kiritmada qayta so\'raydigan dastur yozing (try-catch + while).',
    links: [DocLink('Error handling', 'https://dart.dev/language/error-handling')],
  ),
];
