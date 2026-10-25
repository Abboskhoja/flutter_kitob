import 'package:flutter/material.dart';

import '../../content/model.dart';

class ProjectStep {
  const ProjectStep(this.title, this.explanation, this.task);
  final String title;
  final String explanation;
  final CodeTask task;
}

class ProjectDef {
  const ProjectDef({
    required this.id,
    required this.title,
    required this.icon,
    required this.level,
    required this.brief,
    required this.functional,
    required this.architecture,
    required this.folders,
    required this.steps,
    required this.testing,
    required this.review,
    this.ui = const [],
    this.flutterNote,
  });

  final String id;
  final String title;
  final IconData icon;
  final String level;
  final String brief;
  final List<String> functional;
  final List<String> ui;
  final String architecture;
  final String folders;
  final List<ProjectStep> steps;
  final List<String> testing;
  final List<String> review;
  final String? flutterNote;
}

const allProjects = <ProjectDef>[
  ProjectDef(
    id: 'hello',
    title: 'Hello World — tashrif qog\'ozi',
    icon: Icons.badge_rounded,
    level: '3-daraja',
    brief: 'Foydalanuvchi haqidagi ma\'lumotni chiroyli formatda chiqaradigan birinchi konsol dasturi.',
    functional: ['Ism, kasb va shaharni o\'zgaruvchilarda saqlash', 'Ramka ichida chiroyli chiqarish', 'Yoshni tug\'ilgan yildan hisoblash'],
    architecture: 'Bitta `main()` funksiyasi va yordamchi funksiyalar. Ma\'lumot — o\'zgaruvchilar.',
    folders: 'hello/\n  bin/hello.dart',
    steps: [
      ProjectStep(
        '1. Ma\'lumotlar',
        'Avval ma\'lumotni o\'zgaruvchilarda saqlaymiz.',
        CodeTask(
          title: 'Ma\'lumotlarni chiqaring',
          instructions: '`ism = \'Aziz\'`, `kasb = \'Dasturchi\'`, `tugilganYil = 2004` o\'zgaruvchilarini yarating va chiqaring:\n`Ism: Aziz`\n`Kasb: Dasturchi`\n`Yosh: 22` (yoshni 2026 - tugilganYil deb hisoblang)',
          starter: "void main() {\n  // o'zgaruvchilar\n}\n",
          checks: [
            OutputEquals('Ism: Aziz\nKasb: Dasturchi\nYosh: 22\n'),
            UsesConstruct(r'2026\s*-\s*tugilganYil', 'Yosh hisoblanishi kerak (22 ni qo\'lda yozmang)'),
          ],
          hints: ["String ism = 'Aziz';", 'int yosh = 2026 - tugilganYil;', r"print('Ism: $ism');"],
          solution: "void main() {\n  String ism = 'Aziz';\n  String kasb = 'Dasturchi';\n  int tugilganYil = 2004;\n  int yosh = 2026 - tugilganYil;\n  print('Ism: \$ism');\n  print('Kasb: \$kasb');\n  print('Yosh: \$yosh');\n}\n",
        ),
      ),
      ProjectStep(
        '2. Ramka funksiyasi',
        'Takrorlanadigan ishni funksiyaga chiqaramiz: matnni `*` ramkaga oladi.',
        CodeTask(
          title: 'ramka() funksiyasi',
          instructions: '`String ramka(String matn)` — matnni `* ` va ` *` orasiga oladi: `ramka(\'Salom\')` → `* Salom *`',
          starter: "String ramka(String matn) {\n  return matn;\n}\n\nvoid main() {\n  print(ramka('Salom'));\n}\n",
          checks: [EvaluatesTo("ramka('Salom')", '* Salom *'), EvaluatesTo("ramka('')", '*  *', hidden: true)],
          hints: [r"return '* $matn *';"],
          solution: "String ramka(String matn) {\n  return '* \$matn *';\n}\n\nvoid main() {\n  print(ramka('Salom'));\n}\n",
          requireMain: false,
        ),
      ),
    ],
    testing: ['Har xil ism va yil bilan sinab ko\'ring', 'Bo\'sh matn bilan ramka() ni tekshiring'],
    review: ['O\'zgaruvchi nomlari ma\'noli (camelCase)', 'Takroriy kod funksiyaga chiqarilgan', 'Interpolatsiya ishlatilgan'],
  ),
  ProjectDef(
    id: 'calculator',
    title: 'Kalkulyator',
    icon: Icons.calculate_rounded,
    level: '3-daraja',
    brief: 'Ikki son va amal belgisini qabul qilib, natijani hisoblaydigan, xatolarni (nolga bo\'lish, noto\'g\'ri amal) to\'g\'ri boshqaradigan kalkulyator.',
    functional: ['+, -, *, / amallari', 'Nolga bo\'lishda tushunarli xabar', 'Noma\'lum amalda xabar', 'Natijani formatlash'],
    ui: ['Flutter versiyasida: raqam tugmalari GridView da, natija ekrani Text da'],
    architecture: 'Mantiq (`hisobla` funksiyasi) UI dan ajratilgan — keyin Flutter ilovasiga ko\'chirish oson.',
    folders: 'calculator/\n  lib/calculator.dart   // mantiq\n  bin/main.dart         // konsol interfeys\n  test/calculator_test.dart',
    steps: [
      ProjectStep(
        '1. Hisoblash mantiqi',
        'Asosiy funksiya: `switch` bilan amalni tanlaymiz.',
        CodeTask(
          title: 'hisobla()',
          instructions: '`double hisobla(double a, String amal, double b)` — +, -, *, / ni bajarsin.',
          starter: "double hisobla(double a, String amal, double b) {\n  return 0;\n}\n",
          checks: [
            EvaluatesTo("hisobla(6, '+', 2)", '8.0'),
            EvaluatesTo("hisobla(6, '-', 2)", '4.0'),
            EvaluatesTo("hisobla(6, '*', 2)", '12.0', hidden: true),
            EvaluatesTo("hisobla(6, '/', 4)", '1.5', hidden: true),
          ],
          hints: ['switch (amal) { ... }', "case '+': return a + b;", r'''return switch (amal) {
  '+' => a + b,
  '-' => a - b,
  '*' => a * b,
  _ => a / b,
};'''],
          solution: "double hisobla(double a, String amal, double b) {\n  return switch (amal) {\n    '+' => a + b,\n    '-' => a - b,\n    '*' => a * b,\n    '/' => a / b,\n    _ => throw ArgumentError('Noma\\'lum amal: \$amal'),\n  };\n}\n",
          requireMain: false,
        ),
      ),
      ProjectStep(
        '2. Xatolarni boshqarish',
        'Real ilova xato kiritmada qulamasligi kerak.',
        CodeTask(
          title: 'xavfsizHisobla()',
          instructions: '`String xavfsizHisobla(double a, String amal, double b)`:\n- natija bo\'lsa: `Natija: 8.0`\n- b == 0 va amal `/`: `Xato: nolga bo\'lib bo\'lmaydi`\n- noma\'lum amal: `Xato: noma\'lum amal %`',
          starter: "String xavfsizHisobla(double a, String amal, double b) {\n  return '';\n}\n",
          checks: [
            EvaluatesTo("xavfsizHisobla(6, '+', 2)", 'Natija: 8.0'),
            EvaluatesTo("xavfsizHisobla(1, '/', 0)", "Xato: nolga bo'lib bo'lmaydi"),
            EvaluatesTo("xavfsizHisobla(1, '%', 2)", "Xato: noma'lum amal %", hidden: true),
            EvaluatesTo("xavfsizHisobla(9, '/', 3)", 'Natija: 3.0', hidden: true),
          ],
          hints: ["if (amal == '/' && b == 0) return \"Xato: nolga bo'lib bo'lmaydi\";", 'Amallar ro\'yxatini tekshiring: [\'+\', \'-\', \'*\', \'/\'].contains(amal)', r'''final natija = switch (amal) { '+' => a + b, '-' => a - b, '*' => a * b, _ => a / b };
return 'Natija: $natija';'''],
          solution: "String xavfsizHisobla(double a, String amal, double b) {\n  if (!['+', '-', '*', '/'].contains(amal)) return \"Xato: noma'lum amal \$amal\";\n  if (amal == '/' && b == 0) return \"Xato: nolga bo'lib bo'lmaydi\";\n  final natija = switch (amal) {\n    '+' => a + b,\n    '-' => a - b,\n    '*' => a * b,\n    _ => a / b,\n  };\n  return 'Natija: \$natija';\n}\n",
          requireMain: false,
        ),
      ),
    ],
    testing: ['Har bir amal uchun test', 'Chegaraviy holat: 0 ga bo\'lish', 'Manfiy sonlar va kasrlar'],
    review: ['Mantiq va kiritma/chiqarish ajratilgan', 'Xato holatlari foydalanuvchiga tushunarli', 'switch ifodasi bilan toza kod'],
    flutterNote: 'Flutter versiyasi uchun `hisobla` funksiyasini o\'zgarishsiz ishlatasiz — faqat UI (GridView tugmalari) qo\'shiladi.',
  ),
  ProjectDef(
    id: 'todo',
    title: 'To-Do ro\'yxat',
    icon: Icons.checklist_rounded,
    level: '4-daraja',
    brief: 'Vazifalarni qo\'shish, bajarildi deb belgilash, o\'chirish va statistikani ko\'rsatish — class va List bilan.',
    functional: ['Vazifa qo\'shish', 'Bajarildi/bajarilmadi belgilash', 'O\'chirish', 'Faqat bajarilmaganlarni ko\'rsatish', 'Statistika: 2/5 bajarildi'],
    ui: ['Flutter: ListView + CheckboxListTile + FloatingActionButton'],
    architecture: '`Vazifa` model class, `VazifaRoyxati` — biznes mantiq (repository uslubi).',
    folders: 'todo/\n  lib/models/vazifa.dart\n  lib/vazifa_royxati.dart\n  bin/main.dart',
    steps: [
      ProjectStep(
        '1. Model',
        'Har bir vazifa — obyekt: matn va bajarilganlik holati.',
        CodeTask(
          title: 'Vazifa class i',
          instructions: '`Vazifa` class: `final String matn`, `bool bajarildi = false`, konstruktor `Vazifa(this.matn)`, `void belgilash()` — holatni teskarisiga o\'zgartiradi, `toString()` → `[x] matn` yoki `[ ] matn`.',
          starter: 'class Vazifa {\n}\n',
          checks: [
            EvaluatesTo("Vazifa('Kitob o\\'qish').toString()", "[ ] Kitob o'qish"),
            EvaluatesTo("(Vazifa('A')..belgilash()).toString()", '[x] A'),
            EvaluatesTo("(Vazifa('A')..belgilash()..belgilash()).bajarildi", 'false', hidden: true),
          ],
          hints: ['final String matn; bool bajarildi = false; Vazifa(this.matn);', 'void belgilash() => bajarildi = !bajarildi;', r"@override String toString() => '[${bajarildi ? 'x' : ' '}] $matn';"],
          solution: "class Vazifa {\n  final String matn;\n  bool bajarildi = false;\n  Vazifa(this.matn);\n\n  void belgilash() => bajarildi = !bajarildi;\n\n  @override\n  String toString() => '[\${bajarildi ? 'x' : ' '}] \$matn';\n}\n",
          requireMain: false,
        ),
      ),
      ProjectStep(
        '2. Ro\'yxat mantiqi',
        'Vazifalar to\'plamini boshqaruvchi class.',
        CodeTask(
          title: 'VazifaRoyxati',
          instructions: 'Oldingi `Vazifa` class ini qoldiring va `VazifaRoyxati` yozing:\n- `List<Vazifa> vazifalar = []`\n- `void qosh(String matn)`\n- `void belgila(int i)`\n- `List<Vazifa> get qolganlar` — bajarilmaganlar\n- `String get statistika` → `1/3 bajarildi`',
          starter: "class Vazifa {\n  final String matn;\n  bool bajarildi = false;\n  Vazifa(this.matn);\n  void belgilash() => bajarildi = !bajarildi;\n  @override\n  String toString() => '[\${bajarildi ? 'x' : ' '}] \$matn';\n}\n\nclass VazifaRoyxati {\n}\n",
          checks: [
            EvaluatesTo("(VazifaRoyxati()..qosh('a')..qosh('b')..qosh('c')..belgila(1)).statistika", '1/3 bajarildi'),
            EvaluatesTo("(VazifaRoyxati()..qosh('a')..qosh('b')..belgila(0)).qolganlar", '[[ ] b]'),
            EvaluatesTo('VazifaRoyxati().statistika', '0/0 bajarildi', hidden: true),
          ],
          hints: ['void qosh(String matn) => vazifalar.add(Vazifa(matn));', 'List<Vazifa> get qolganlar => vazifalar.where((v) => !v.bajarildi).toList();', r"String get statistika => '${vazifalar.where((v) => v.bajarildi).length}/${vazifalar.length} bajarildi';"],
          solution: "class Vazifa {\n  final String matn;\n  bool bajarildi = false;\n  Vazifa(this.matn);\n  void belgilash() => bajarildi = !bajarildi;\n  @override\n  String toString() => '[\${bajarildi ? 'x' : ' '}] \$matn';\n}\n\nclass VazifaRoyxati {\n  List<Vazifa> vazifalar = [];\n\n  void qosh(String matn) => vazifalar.add(Vazifa(matn));\n  void belgila(int i) => vazifalar[i].belgilash();\n  List<Vazifa> get qolganlar => vazifalar.where((v) => !v.bajarildi).toList();\n  String get statistika => '\${vazifalar.where((v) => v.bajarildi).length}/\${vazifalar.length} bajarildi';\n}\n",
          requireMain: false,
        ),
      ),
    ],
    testing: ['Bo\'sh ro\'yxat statistikasi', 'Ikki marta belgilash — holat qaytadi', 'Noto\'g\'ri indeks bilan belgila() — RangeError'],
    review: ['Model va mantiq ajratilgan', 'Getterlar hisoblangan qiymatlar uchun', 'toString() o\'qishli'],
    flutterNote: 'Flutterda `VazifaRoyxati` holat (state) bo\'ladi: har bir o\'zgarishdan keyin `setState()` chaqiriladi.',
  ),
  ProjectDef(
    id: 'expense',
    title: 'Xarajatlar hisobchisi',
    icon: Icons.account_balance_wallet_rounded,
    level: '4-daraja',
    brief: 'Xarajatlarni toifalar bo\'yicha yig\'ib, eng katta toifani va umumiy summani hisoblovchi dastur.',
    functional: ['Xarajat qo\'shish (toifa, summa)', 'Toifalar bo\'yicha jami', 'Eng ko\'p sarflangan toifa', 'Umumiy summa'],
    architecture: '`Xarajat` record/class va Map<String, double> agregatsiya.',
    folders: 'expense/\n  lib/xarajat.dart\n  lib/hisobchi.dart',
    steps: [
      ProjectStep(
        '1. Toifalar bo\'yicha yig\'indi',
        'Map — toifa → jami summa.',
        CodeTask(
          title: 'toifalarJami()',
          instructions: '`Map<String, double> toifalarJami(List<(String, double)> x)` — record lar ro\'yxatidan toifa bo\'yicha jami.\n`toifalarJami([(\'ovqat\', 20), (\'yol\', 5), (\'ovqat\', 10)])` → `{ovqat: 30.0, yol: 5.0}`',
          starter: 'Map<String, double> toifalarJami(List<(String, double)> x) {\n  var m = <String, double>{};\n  return m;\n}\n',
          checks: [
            EvaluatesTo("toifalarJami([('ovqat', 20.0), ('yol', 5.0), ('ovqat', 10.0)])", '{ovqat: 30.0, yol: 5.0}'),
            EvaluatesTo('toifalarJami([])', '{}', hidden: true),
          ],
          hints: [r'for (final (toifa, summa) in x) { ... }', 'm[toifa] = (m[toifa] ?? 0) + summa;', 'Record maydonlari: e.\$1 va e.\$2 ham ishlaydi.'],
          solution: 'Map<String, double> toifalarJami(List<(String, double)> x) {\n  var m = <String, double>{};\n  for (final e in x) {\n    m[e.\$1] = (m[e.\$1] ?? 0) + e.\$2;\n  }\n  return m;\n}\n',
          requireMain: false,
        ),
      ),
      ProjectStep(
        '2. Eng katta toifa',
        'Map entries bo\'ylab maksimumni topamiz.',
        CodeTask(
          title: 'engKatta()',
          instructions: '`String engKatta(Map<String, double> m)` — eng katta summali toifa nomi; bo\'sh bo\'lsa `yo\'q`.',
          starter: 'String engKatta(Map<String, double> m) {\n  return \'\';\n}\n',
          checks: [
            EvaluatesTo("engKatta({'ovqat': 30, 'yol': 5})", 'ovqat'),
            EvaluatesTo("engKatta({'a': 1, 'b': 9, 'c': 3})", 'b', hidden: true),
            EvaluatesTo('engKatta({})', "yo'q", hidden: true),
          ],
          hints: ["if (m.isEmpty) return \"yo'q\";", 'var eng = m.entries.first;', 'for (final e in m.entries) { if (e.value > eng.value) eng = e; } return eng.key;'],
          solution: "String engKatta(Map<String, double> m) {\n  if (m.isEmpty) return \"yo'q\";\n  var eng = m.entries.first;\n  for (final e in m.entries) {\n    if (e.value > eng.value) eng = e;\n  }\n  return eng.key;\n}\n",
          requireMain: false,
        ),
      ),
    ],
    testing: ['Bo\'sh ro\'yxat', 'Bitta toifa', 'Teng summalar'],
    review: ['Record lar bilan toza modellashtirish', 'Bo\'sh holatlar boshqarilgan'],
  ),
  ProjectDef(
    id: 'quiz',
    title: 'Quiz ilovasi mantiqi',
    icon: Icons.quiz_rounded,
    level: '4-daraja',
    brief: 'Savollar, variantlar, ball hisoblash va natija bahosi — o\'zingizning test dvigatelingiz.',
    functional: ['Savol modeli (matn, variantlar, to\'g\'ri indeks)', 'Javobni tekshirish', 'Ball va foiz', 'Natijaga qarab baho'],
    architecture: '`Savol` class + `Test` class (holat: joriy savol, ball).',
    folders: 'quiz/\n  lib/models/savol.dart\n  lib/test_dvigatel.dart',
    steps: [
      ProjectStep(
        '1. Savol modeli',
        'Har bir savol to\'g\'ri javobini biladi.',
        CodeTask(
          title: 'Savol',
          instructions: '`Savol(this.matn, this.variantlar, this.togri)` va `bool tekshir(int javob)`.',
          starter: 'class Savol {\n}\n',
          checks: [
            EvaluatesTo("Savol('2+2?', ['3', '4'], 1).tekshir(1)", 'true'),
            EvaluatesTo("Savol('2+2?', ['3', '4'], 1).tekshir(0)", 'false'),
          ],
          hints: ['final String matn; final List<String> variantlar; final int togri;', 'bool tekshir(int javob) => javob == togri;'],
          solution: 'class Savol {\n  final String matn;\n  final List<String> variantlar;\n  final int togri;\n  Savol(this.matn, this.variantlar, this.togri);\n\n  bool tekshir(int javob) => javob == togri;\n}\n',
          requireMain: false,
        ),
      ),
      ProjectStep(
        '2. Natija bahosi',
        'Foizga qarab baho beramiz.',
        CodeTask(
          title: 'baho()',
          instructions: '`String baho(int togri, int jami)` — foiz = togri * 100 ~/ jami.\n>= 90 → `A\'lo`, >= 70 → `Yaxshi`, >= 50 → `Qoniqarli`, aks holda `Qayta urinib ko\'ring`. jami == 0 bo\'lsa `Savol yo\'q`.',
          starter: 'String baho(int togri, int jami) {\n  return \'\';\n}\n',
          checks: [
            EvaluatesTo('baho(9, 10)', "A'lo"),
            EvaluatesTo('baho(7, 10)', 'Yaxshi'),
            EvaluatesTo('baho(1, 2)', 'Qoniqarli', hidden: true),
            EvaluatesTo('baho(1, 10)', "Qayta urinib ko'ring", hidden: true),
            EvaluatesTo('baho(0, 0)', "Savol yo'q", hidden: true),
          ],
          hints: ["if (jami == 0) return \"Savol yo'q\";", 'final foiz = togri * 100 ~/ jami;', 'switch ifodasi: >= 90 => ...'],
          solution: "String baho(int togri, int jami) {\n  if (jami == 0) return \"Savol yo'q\";\n  final foiz = togri * 100 ~/ jami;\n  return switch (foiz) {\n    >= 90 => \"A'lo\",\n    >= 70 => 'Yaxshi',\n    >= 50 => 'Qoniqarli',\n    _ => \"Qayta urinib ko'ring\",\n  };\n}\n",
          requireMain: false,
        ),
      ),
    ],
    testing: ['Barcha chegaraviy foizlar (49, 50, 69, 70, 89, 90)', 'jami = 0'],
    review: ['Model o\'zgarmas (final)', 'Baholash alohida sof funksiya — test qilish oson'],
    flutterNote: 'Flutterda savollar `PageView` bilan, natija `AnimatedSwitcher` bilan ko\'rsatiladi.',
  ),
];

ProjectDef? projectById(String id) => allProjects.where((p) => p.id == id).firstOrNull;
