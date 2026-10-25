import 'package:flutter/material.dart';

import '../model.dart';

/// Flutter asoslari darslari. Kod namunalari kitob_dart Flutter runtime'ida bajariladi
/// va telefon oynasida haqiqiy Flutter widgetlari sifatida chiziladi.
const level5Lessons = <Lesson>[
  // ───────────────────────── 5.1 ─────────────────────────
  Lesson(
    id: 'l5_flutter_intro',
    title: 'Flutter nima? Birinchi ilova',
    subtitle: 'runApp, MaterialApp va birinchi ekran',
    icon: Icons.flutter_dash,
    minutes: 15,
    xp: 60,
    skills: ['flutter.basics'],
    prerequisites: ['Class va obyekt'],
    objectives: [
      'Flutter nima ekanini va u Dart bilan qanday bog\'liqligini tushunasiz',
      '`main()` → `runApp()` → ekran zanjirini bilasiz',
      '`MaterialApp`, `Scaffold`, `Center`, `Text` bilan birinchi ekranni yasaysiz',
    ],
    intro: [
      ParaBlock('**Flutter** — Google yaratgan UI (foydalanuvchi interfeysi) **framework**i. Bitta Dart kodidan Android, iOS, Web va desktop ilovalar chiqadi.'),
      ParaBlock('Flutterda ekrandagi **hamma narsa — widget**: matn, tugma, bo\'sh joy, hatto butun ekran ham. Widget — bu oddiy Dart **class**ining obyekti. Siz o\'tgan darajada o\'rgangan class, constructor va nomli parametrlar shu yerda ishlaydi.'),
      BulletsBlock([
        '**`main()`** — dastur shu yerdan boshlanadi (Dartdagi kabi)',
        '**`runApp(widget)`** — berilgan widgetni ekranga chiqaradi',
        '**`MaterialApp`** — ilova "qobig\'i": mavzu (theme), navigatsiya, Material dizayn',
        '**`Scaffold`** — bitta ekranning skeleti: tepada `appBar`, o\'rtada `body`',
        '**`Center`** — farzandini o\'rtaga qo\'yadi, **`Text`** — matn chiqaradi',
      ]),
      CalloutBlock(CalloutKind.info, 'Bu yerdagi preview qanday ishlaydi?',
          'Siz yozgan kod FLUTTER_KITOB ichidagi Dart interpretatorida haqiqatan bajariladi, `build()` qaytargan widgetlar esa **haqiqiy Flutter widgetlari** bo\'lib telefon oynasida chiziladi. Tugmalar sizning funksiyalaringizni chaqiradi. Bu — asosiy widgetlar to\'plami; to\'liq Flutter SDK kompyuteringizda `flutter run` bilan ishlaydi.'),
    ],
    analogy: AnalogyBlock(
      'Lego konstruktori',
      'Flutter ilova — Lego qurilmasi. Har bir widget — bitta Lego bo\'lagi. Kichik bo\'laklar (Text, Icon) kattaroqlariga (Center, Column) ulanadi, ular esa eng kattasiga (Scaffold, MaterialApp). `runApp` — tayyor qurilmani stol ustiga qo\'yish.',
      icon: Icons.extension_outlined,
    ),
    why: 'Flutter bitta kod bazasi bilan barcha platformalarga yuqori sifatli ilova yozish imkonini beradi. Dunyodagi minglab kompaniyalar (Google Pay, BMW, Alibaba) Flutter ishlatadi — bu talab yuqori bo\'lgan kasb.',
    where: [
      'Mobil ilovalar: do\'kon, bank, ta\'lim, yetkazib berish',
      'Web ilovalar va admin panellar',
      'Desktop (Windows, macOS, Linux) ilovalar',
    ],
    terms: [
      TermBlock(term: 'Framework', uz: 'Freymvork (karkas)', meaning: 'Tayyor qoidalar va vositalar to\'plami — siz faqat o\'z qismingizni yozasiz.', why: 'Noldan hamma narsani yozmaslik uchun.'),
      TermBlock(term: 'Widget', uz: 'Vidjet', meaning: 'Ekran bo\'lagining tavsifi (Dart obyekti).', why: 'Flutterda UI faqat widgetlardan quriladi.', example: "Text('Salom')"),
      TermBlock(term: 'runApp', uz: 'Ilovani ishga tushirish', meaning: 'Ildiz widgetni ekranga joylaydi.', why: 'Usiz ekran bo\'sh qoladi.', example: 'runApp(const MyApp());'),
      TermBlock(term: 'Scaffold', uz: 'Ekran karkasi', meaning: 'AppBar, body, tugmalar uchun tayyor joylar.', why: 'Har bir Material ekranning asosi.'),
    ],
    animation: AnimationBlock('widget_tree', 'Widgetlar bir-birining ichiga joylashib, daraxt hosil qiladi.'),
    syntax: SyntaxBlock(r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Salom')),
    ),
  ));
}''', [
      SyntaxPart("import 'package:flutter/material.dart'", 'Material widgetlarini ulash'),
      SyntaxPart('runApp(...)', 'ildiz widgetni ekranga chiqarish'),
      SyntaxPart('home:', 'ilovaning birinchi ekrani'),
      SyntaxPart('child:', 'bitta farzand widget'),
    ]),
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Birinchi ilovam')),
        body: const Center(
          child: Text(
            'Salom, Flutter!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}''',
      title: 'main.dart',
      preview: true,
      explain: {
        'runApp': 'Ildiz widgetni ekranga joylaydi.',
        'MaterialApp': 'Ilova qobig\'i: mavzu, navigatsiya.',
        'Scaffold': 'Ekran skeleti: appBar + body.',
        'AppBar': 'Tepadagi sarlavha paneli.',
        'Center': 'Farzandini o\'rtaga qo\'yadi.',
        'TextStyle': 'Matn ko\'rinishi: o\'lcham, qalinlik, rang.',
        'debugShowCheckedModeBanner': 'O\'ng burchakdagi "DEBUG" yorlig\'ini yashiradi.',
      },
      lineNotes: {
        1: 'Flutter Material kutubxonasini ulaymiz — Text, Scaffold va boshqalar shu yerda.',
        4: '`runApp` ga butun ilova — bitta widget beriladi.',
        7: '`home` — ilova ochilganda ko\'rinadigan ekran.',
        9: '`const` — bu widget hech qachon o\'zgarmaydi, Flutter uni qayta yaratmaydi (tezroq).',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() {
  MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Salom!')),
    ),
  );
}''',
      task: 'Ilova ochilganda ekranda hech narsa chiqmayapti. Nima yetishmayapti?',
      why: '`MaterialApp(...)` obyekti yaratildi, lekin u **ekranga berilmadi**. Widgetni ekranga faqat `runApp(...)` chiqaradi. Obyekt yaratish va uni ko\'rsatish — boshqa-boshqa narsa.',
      fixed: r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Salom!')),
    ),
  ));
}''',
      hint: 'Widgetni ekranga qaysi funksiya chiqaradi?',
    ),
    task: CodeTask(
      title: 'Mening ilovam',
      preview: true,
      instructions: 'Ilova yasang:\n- `AppBar` sarlavhasi: `Mening ilovam`\n- ekran o\'rtasida (`Center`) matn: `Salom, Flutter!`',
      starter: r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Text('...'),
    ),
  ));
}''',
      checks: [
        WidgetExists('AppBar', text: 'Mening ilovam'),
        WidgetExists('Center', text: 'Salom, Flutter!', label: '`Center` ichida `Salom, Flutter!` matni'),
        WidgetExists('Scaffold', hidden: true),
      ],
      hints: [
        'Scaffold ga `appBar: AppBar(title: Text(\'Mening ilovam\'))` qo\'shing.',
        '`body` ni `Center(child: Text(...))` ga o\'rang.',
        r'''home: Scaffold(
  appBar: AppBar(title: const Text('Mening ilovam')),
  body: const Center(child: Text('Salom, Flutter!')),
),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Mening ilovam')),
      body: const Center(child: Text('Salom, Flutter!')),
    ),
  ));
}''',
    ),
    extra: [
      WidgetLabBlock('text', 'Text widgetining parametrlarini o\'zgartirib, natijani darhol ko\'ring.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'Flutterda widgetni ekranga qaysi funksiya chiqaradi?',
        options: ['print()', 'runApp()', 'build()', 'show()'],
        correct: 1,
        explanation: '`runApp()` ildiz widgetni ekranga joylaydi. `print` faqat konsolga yozadi.',
      ),
      TrueFalse(
        prompt: 'Flutterda tugma, matn va bo\'sh joy — hammasi widget.',
        answer: true,
        explanation: 'Ha, Flutterda UI to\'liq widgetlardan quriladi.',
      ),
      MatchPairs(
        prompt: 'Widgetni vazifasi bilan moslang',
        pairs: [
          ('MaterialApp', 'ilova qobig\'i'),
          ('Scaffold', 'ekran skeleti'),
          ('Center', 'o\'rtaga qo\'yadi'),
          ('Text', 'matn chiqaradi'),
        ],
        explanation: 'MaterialApp → Scaffold → Center → Text: tashqaridan ichkariga.',
      ),
      SingleChoice(
        prompt: 'Flutter qaysi dasturlash tilida yoziladi?',
        options: ['Kotlin', 'Swift', 'Dart', 'JavaScript'],
        correct: 2,
        explanation: 'Flutter ilovalari Dart tilida yoziladi — shuning uchun avval Dartni o\'rgandik.',
      ),
    ],
    summary: [
      'Flutter — bitta Dart kodidan ko\'p platformaga UI yozish frameworki',
      'Ekrandagi hamma narsa — widget (Dart obyekti)',
      '`main()` → `runApp(widget)` → ekran',
      '`MaterialApp` → `Scaffold(appBar, body)` → `Center` → `Text`',
    ],
    revisionTip: 'Bo\'sh ekran chiqsa, birinchi navbatda `runApp` chaqirilganini tekshiring.',
    next: 'Keyingi darsda o\'z widgetingizni yasaysiz — StatelessWidget.',
    links: [DocLink('Flutter: Get started', 'https://docs.flutter.dev/get-started'), DocLink('Widget catalog', 'https://docs.flutter.dev/ui/widgets')],
  ),

  // ───────────────────────── 5.2 ─────────────────────────
  Lesson(
    id: 'l5_stateless',
    title: 'StatelessWidget va widget tree',
    subtitle: 'O\'z widgetingizni yasash: build va BuildContext',
    icon: Icons.account_tree_outlined,
    minutes: 18,
    xp: 70,
    skills: ['flutter.widgets'],
    prerequisites: ['Flutter nima? Birinchi ilova'],
    objectives: [
      '`StatelessWidget` dan meros olib, o\'z widgetingizni yozasiz',
      '`build(BuildContext context)` metodi nima qaytarishini tushunasiz',
      'Widgetga constructor orqali ma\'lumot berasiz va uni qayta ishlatasiz',
    ],
    intro: [
      ParaBlock('Katta ekranni bitta `main` ichida yozish noqulay. Flutterda ekran **kichik, qayta ishlatiladigan widgetlar**ga bo\'linadi. O\'z widgetingizni yasash uchun class yozasiz.'),
      ParaBlock('**`StatelessWidget`** — o\'zgarmas (holatsiz) widget. U faqat o\'ziga berilgan ma\'lumot asosida ko\'rinish quradi.'),
      BulletsBlock([
        '`class Salom extends StatelessWidget` — Flutterning tayyor class\'idan meros',
        '`final String ism;` — widget ma\'lumoti (har doim `final`)',
        '`const Salom({super.key, required this.ism});` — nomli parametrli constructor',
        '`Widget build(BuildContext context)` — **ekranda nima ko\'rinishini qaytaradi**',
      ]),
      ParaBlock('**`BuildContext`** — widgetning daraxtdagi "manzili". U orqali mavzu (`Theme.of(context)`), ekran o\'lchami (`MediaQuery`) va navigatsiyaga murojaat qilinadi.'),
      CalloutBlock(CalloutKind.tip, 'Widget tree', 'Har bir widget `build` ichida boshqa widgetlarni qaytaradi. Natijada **daraxt** hosil bo\'ladi: `MyApp → MaterialApp → Scaffold → Column → ProfilKarta → Text`. Flutter shu daraxtni ekranga aylantiradi.'),
    ],
    analogy: AnalogyBlock(
      'Tashrif qog\'ozi shabloni',
      'StatelessWidget — tashrif qog\'ozi shabloni. Shablon bir marta chiziladi, unga ism va kasb berasiz (constructor parametrlari) — tayyor qog\'oz chiqadi. Bir shablondan istalgancha turli qog\'oz chop etish mumkin.',
      icon: Icons.badge_outlined,
    ),
    why: 'Qayta ishlatiladigan widgetlar kodni qisqa, tushunarli va xatosiz qiladi. Bitta `MahsulotKarta` widgetini 100 ta mahsulot uchun ishlatasiz — o\'zgartirish kerak bo\'lsa, bir joyni tuzatasiz.',
    where: [
      'Mahsulot kartasi, foydalanuvchi avatari, sarlavha bloki',
      'Bir xil uslubdagi tugmalar va yorliqlar',
      'Har qanday ilova — ko\'plab kichik StatelessWidget\'lardan iborat',
    ],
    terms: [
      TermBlock(term: 'StatelessWidget', uz: 'Holatsiz widget', meaning: 'Faqat kiruvchi ma\'lumotdan ko\'rinish quradigan widget.', why: 'O\'zgarmaydigan UI bo\'laklari uchun.'),
      TermBlock(term: 'build()', uz: 'Qurish metodi', meaning: 'Widget ko\'rinishini (boshqa widgetlarni) qaytaradi.', why: 'Flutter ekranni shu metod orqali chizadi.'),
      TermBlock(term: 'BuildContext', uz: 'Qurish konteksti', meaning: 'Widgetning daraxtdagi o\'rni.', why: 'Theme, MediaQuery, Navigator uchun kerak.'),
      TermBlock(term: 'Widget tree', uz: 'Widget daraxti', meaning: 'Widgetlarning ichma-ich joylashuvi.', why: 'Ekran tuzilishini tushunish uchun.'),
      TermBlock(term: 'key', uz: 'Kalit', meaning: 'Widgetni boshqalardan ajratib turuvchi identifikator.', why: 'Ro\'yxatlarda holatni to\'g\'ri saqlash uchun.', example: 'super.key'),
    ],
    syntax: SyntaxBlock(r'''class Nom extends StatelessWidget {
  const Nom({super.key, required this.matn});
  final String matn;

  @override
  Widget build(BuildContext context) {
    return Text(matn);
  }
}''', [
      SyntaxPart('extends StatelessWidget', 'Flutterning holatsiz widget class\'idan meros'),
      SyntaxPart('final String matn', 'widget ma\'lumoti — o\'zgarmas'),
      SyntaxPart('@override', 'ota class metodini qayta yozyapmiz'),
      SyntaxPart('Widget build(...)', 'ko\'rinishni qaytaradi'),
    ]),
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Jamoa')),
        body: const Column(
          children: [
            ProfilKarta(ism: 'Aziza', kasb: 'Flutter dasturchi'),
            ProfilKarta(ism: 'Bobur', kasb: 'Dizayner'),
            ProfilKarta(ism: 'Dilnoza', kasb: 'Backend dasturchi'),
          ],
        ),
      ),
    );
  }
}

class ProfilKarta extends StatelessWidget {
  const ProfilKarta({super.key, required this.ism, required this.kasb});
  final String ism;
  final String kasb;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(child: Text(ism[0])),
        title: Text(ism),
        subtitle: Text(kasb),
      ),
    );
  }
}''',
      title: 'main.dart',
      preview: true,
      explain: {
        'extends StatelessWidget': 'Holatsiz widget: faqat berilgan ma\'lumotni ko\'rsatadi.',
        'required this.ism': 'Majburiy nomli parametr — ism berilmasa xato.',
        '@override': 'Ota class (StatelessWidget) dagi build metodini o\'zimiz yozyapmiz.',
        'BuildContext context': 'Widgetning daraxtdagi o\'rni.',
        'ism[0]': 'Matnning birinchi harfi — avatar uchun.',
      },
      lineNotes: {
        3: 'Arrow funksiya: `main` bitta ifoda — `runApp(...)`.',
        5: '`MyApp` — butun ilova ham oddiy StatelessWidget.',
        17: 'Bitta `ProfilKarta` shabloni uch marta turli ma\'lumot bilan ishlatildi.',
        28: '`build` har doim widget qaytaradi — bu yerda `Card`.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Yorliq(matn: 'Yangi')));

class Yorliq extends StatelessWidget {
  const Yorliq({super.key, required this.matn});
  final String matn;

  @override
  Widget build(BuildContext context) {
    Center(child: Text(matn));
  }
}''',
      task: 'Kod ishga tushmayapti. Analizator nimadan norozi?',
      why: '`build` metodi `Widget` **qaytarishi shart**, lekin bu yerda `return` yo\'q — widget yaratildi-yu, tashlab yuborildi. Dartda qaytish turi `void` bo\'lmagan funksiya har doim `return` qilishi kerak.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Yorliq(matn: 'Yangi')));

class Yorliq extends StatelessWidget {
  const Yorliq({super.key, required this.matn});
  final String matn;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(matn));
  }
}''',
      hint: 'build metodi nimani qaytarishi kerak?',
    ),
    task: CodeTask(
      title: 'Salomlash widgeti',
      preview: true,
      instructions: '`Salomlash` nomli `StatelessWidget` yozing: u `ism` (String) qabul qilib, `Salom, <ism>!` matnini ko\'rsatsin.\n`Column` ichida uni ikki marta ishlating: `Ali` va `Vali` uchun.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Bosh())));

class Bosh extends StatelessWidget {
  const Bosh({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Text('Salom!'),
    ]);
  }
}

// Salomlash widgetini shu yerga yozing
''',
      checks: [
        UsesConstruct(r'class\s+Salomlash\s+extends\s+StatelessWidget', '`Salomlash` class\'i `StatelessWidget` dan meros oladi'),
        WidgetExists('Salomlash', min: 2, label: '`Salomlash` widgeti kamida 2 marta ishlatilgan'),
        WidgetExists('Text', text: 'Salom, Ali!'),
        WidgetExists('Text', text: 'Salom, Vali!'),
      ],
      hints: [
        'Avvalgi misoldagi `ProfilKarta` ga qarang: `final String ism;` va `required this.ism`.',
        "build ichida: return Text('Salom, \$ism!');",
        r'''class Salomlash extends StatelessWidget {
  const Salomlash({super.key, required this.ism});
  final String ism;

  @override
  Widget build(BuildContext context) => Text('Salom, $ism!');
}''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Bosh())));

class Bosh extends StatelessWidget {
  const Bosh({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Salomlash(ism: 'Ali'),
      Salomlash(ism: 'Vali'),
    ]);
  }
}

class Salomlash extends StatelessWidget {
  const Salomlash({super.key, required this.ism});
  final String ism;

  @override
  Widget build(BuildContext context) => Text('Salom, $ism!');
}''',
    ),
    extra: [
      WidgetLabBlock('card', 'Card widgetining parametrlarini o\'zgartirib ko\'ring.'),
    ],
    quiz: [
      SingleChoice(
        prompt: '`build()` metodi nima qaytaradi?',
        options: ['String', 'void', 'Widget', 'BuildContext'],
        correct: 2,
        explanation: '`build` ekranda nima ko\'rinishini — widgetni qaytaradi.',
      ),
      SingleChoice(
        prompt: 'StatelessWidget maydonlari odatda qanday e\'lon qilinadi?',
        options: ['var', 'late', 'final', 'static'],
        correct: 2,
        explanation: 'Widget o\'zgarmas — maydonlari `final`. O\'zgaradigan ma\'lumot uchun StatefulWidget (keyingi darslar).',
      ),
      FindBug(
        prompt: 'Qaysi qatorda xato bor?',
        code: r'''class Nom extends StatelessWidget {
  const Nom({super.key});

  @override
  Widget build(BuildContext context) {
    Text('Salom');
  }
}''',
        bugLine: 6,
        explanation: '`return` yo\'q — `build` widget qaytarishi shart: `return Text(\'Salom\');`',
      ),
      TrueFalse(
        prompt: '`BuildContext` — widgetning daraxtdagi o\'rni haqidagi ma\'lumot.',
        answer: true,
        explanation: 'Ha. U orqali Theme.of(context), MediaQuery.of(context), Navigator.of(context) ishlaydi.',
      ),
    ],
    summary: [
      'O\'z widgetingiz: `class X extends StatelessWidget`',
      'Ma\'lumot constructor orqali keladi va `final` maydonlarda saqlanadi',
      '`build(BuildContext context)` har doim widget qaytaradi',
      'Widgetlar ichma-ich joylashib widget tree hosil qiladi',
    ],
    revisionTip: 'Ilovangizdagi takrorlanadigan bo\'lakni toping va uni alohida StatelessWidget\'ga ajrating.',
    next: 'Keyingi darsda layout: Container, Padding, Row va Column.',
    links: [DocLink('StatelessWidget', 'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html')],
  ),

  // ───────────────────────── 5.3 ─────────────────────────
  Lesson(
    id: 'l5_layout',
    title: 'Layout: Container, Row va Column',
    subtitle: 'Elementlarni joylashtirish va bo\'shliqlar',
    icon: Icons.view_quilt_outlined,
    minutes: 20,
    xp: 70,
    skills: ['flutter.layout'],
    prerequisites: ['StatelessWidget va widget tree'],
    objectives: [
      '`Container`, `Padding`, `SizedBox` bilan o\'lcham va bo\'shliq berasiz',
      '`Row` (gorizontal) va `Column` (vertikal) bilan elementlarni joylashtirasiz',
      '`mainAxisAlignment` va `crossAxisAlignment` farqini tushunasiz',
    ],
    intro: [
      ParaBlock('Ekran **layout** (joylashuv) widgetlari bilan quriladi. Ular ko\'rinmaydi, lekin farzandlarini qayerga va qanday o\'lchamda qo\'yishni hal qiladi.'),
      BulletsBlock([
        '**`Container`** — quti: `width`, `height`, `color`, `padding`, `margin`, `decoration`',
        '**`Padding`** — farzand atrofida ichki bo\'shliq: `EdgeInsets.all(16)`',
        '**`SizedBox`** — aniq o\'lcham yoki shunchaki bo\'sh joy: `SizedBox(height: 12)`',
        '**`Row`** — farzandlarni **yonma-yon** (gorizontal) qo\'yadi',
        '**`Column`** — farzandlarni **ustma-ust** (vertikal) qo\'yadi',
      ]),
      ParaBlock('`Row` va `Column` da ikki o\'q bor: **asosiy o\'q** (main axis — yo\'nalish bo\'yicha) va **ko\'ndalang o\'q** (cross axis). Column uchun asosiy o\'q — vertikal, Row uchun — gorizontal.'),
      CalloutBlock(CalloutKind.tip, 'Eslab qoling', '`mainAxisAlignment: MainAxisAlignment.center` — asosiy o\'q bo\'yicha o\'rtaga. `spaceBetween` — oraliqlarni teng taqsimlaydi. `crossAxisAlignment: CrossAxisAlignment.start` — ko\'ndalang o\'q bo\'yicha boshiga.'),
    ],
    analogy: AnalogyBlock(
      'Javon va tokchalar',
      'Column — ko\'p qavatli javon: narsalar ustma-ust turadi. Row — bitta tokcha: narsalar yonma-yon. Container — quti: uning o\'lchami, rangi va devor qalinligi (padding) bor. SizedBox — narsalar orasiga qo\'yilgan bo\'sh joy.',
      icon: Icons.shelves,
    ),
    why: 'Har qanday dizaynni — kartalar, profillar, menyular — Row, Column va Container kombinatsiyasi bilan qurish mumkin. Bu Flutter layoutning 80 foizi.',
    where: [
      'Profil sahifasi: avatar + ism (Row), uning ostida ma\'lumotlar (Column)',
      'Mahsulot kartasi: rasm, nom, narx, tugma',
      'Tugmalar qatori, statistika bloklari',
    ],
    terms: [
      TermBlock(term: 'Layout', uz: 'Joylashuv', meaning: 'Elementlarning ekrandagi o\'rni va o\'lchami.', why: 'Tartibli va chiroyli UI uchun.'),
      TermBlock(term: 'EdgeInsets', uz: 'Chekka bo\'shliqlar', meaning: 'Padding/margin qiymati.', why: 'Elementlar yopishib qolmasligi uchun.', example: 'EdgeInsets.symmetric(horizontal: 16)'),
      TermBlock(term: 'Main axis', uz: 'Asosiy o\'q', meaning: 'Row uchun gorizontal, Column uchun vertikal.', why: 'mainAxisAlignment shu o\'q bo\'yicha ishlaydi.'),
      TermBlock(term: 'Cross axis', uz: 'Ko\'ndalang o\'q', meaning: 'Asosiy o\'qqa perpendikulyar o\'q.', why: 'crossAxisAlignment shu o\'q bo\'yicha.'),
    ],
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Profil())));

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.center,
                child: const Text('AK', style: TextStyle(color: Colors.white, fontSize: 22)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aziza Karimova', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Toshkent'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Statistika(son: '24', nom: 'Dars'),
              Statistika(son: '1250', nom: 'XP'),
              Statistika(son: '7', nom: 'Kun'),
            ],
          ),
        ],
      ),
    );
  }
}

class Statistika extends StatelessWidget {
  const Statistika({super.key, required this.son, required this.nom});
  final String son;
  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(son, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        Text(nom),
      ]),
    );
  }
}''',
      title: 'profil.dart',
      preview: true,
      explain: {
        'EdgeInsets.all(20)': 'Har tomondan 20 piksel ichki bo\'shliq.',
        'crossAxisAlignment': 'Ko\'ndalang o\'q bo\'yicha joylash (Column uchun — gorizontal).',
        'BoxDecoration': 'Container bezagi: rang, burchak radiusi, soya, chegara.',
        'BorderRadius.circular(32)': 'Burchaklarni yumaloqlash — 64 lik quti uchun doira.',
        'MainAxisAlignment.spaceBetween': 'Elementlar orasidagi bo\'shliqni teng taqsimlaydi.',
        'Colors.blue.shade50': 'Ko\'k rangning eng och tusi.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Tugmalar())));

class Tugmalar extends StatelessWidget {
  const Tugmalar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 80, height: 40, color: Colors.red),
        Container(width: 80, height: 40, color: Colors.green),
        Container(width: 80, height: 40, color: Colors.blue),
      ],
    );
  }
}''',
      task: 'Uchta rangli quti ekran o\'rtasida **yonma-yon** (bitta qatorda) turishi kerak edi, lekin ular ustma-ust chiqyapti. Tuzating.',
      why: '`Column` farzandlarni **vertikal** (ustma-ust) joylaydi. Yonma-yon qo\'yish uchun `Row` kerak. Ikkalasining parametrlari bir xil — faqat yo\'nalish boshqa.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Tugmalar())));

class Tugmalar extends StatelessWidget {
  const Tugmalar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 80, height: 40, color: Colors.red),
        Container(width: 80, height: 40, color: Colors.green),
        Container(width: 80, height: 40, color: Colors.blue),
      ],
    );
  }
}''',
      hint: 'Qaysi widget farzandlarni gorizontal joylaydi?',
    ),
    task: CodeTask(
      title: 'Svetofor',
      preview: true,
      instructions: 'Ekran o\'rtasida svetofor yasang: `Column` ichida uchta `Container` — **qizil, sariq, yashil** (`Colors.red`, `Colors.amber`, `Colors.green`), har biri `width: 80, height: 80`.\nUlar orasida `SizedBox(height: 12)` bo\'lsin.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Svetofor())));

class Svetofor extends StatelessWidget {
  const Svetofor({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(width: 80, height: 80, color: Colors.grey),
    );
  }
}''',
      checks: [
        WidgetExists('Column'),
        WidgetExists('Container', props: {'color': '0xFFF44336'}, label: 'Qizil `Container` (Colors.red)'),
        WidgetExists('Container', props: {'color': '0xFFFFC107'}, label: 'Sariq `Container` (Colors.amber)'),
        WidgetExists('Container', props: {'color': '0xFF4CAF50'}, label: 'Yashil `Container` (Colors.green)'),
        WidgetExists('SizedBox', min: 2, label: 'Qutilar orasida kamida 2 ta `SizedBox`'),
        WidgetExists('Container', props: {'width': '80', 'height': '80'}, min: 3, hidden: true),
      ],
      hints: [
        '`Center(child: Column(mainAxisSize: MainAxisSize.min, children: [...]))`',
        'children ichida: Container, SizedBox(height: 12), Container, SizedBox(height: 12), Container',
        r'''Container(width: 80, height: 80, color: Colors.red),
const SizedBox(height: 12),
Container(width: 80, height: 80, color: Colors.amber),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Svetofor())));

class Svetofor extends StatelessWidget {
  const Svetofor({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 80, height: 80, color: Colors.red),
          const SizedBox(height: 12),
          Container(width: 80, height: 80, color: Colors.amber),
          const SizedBox(height: 12),
          Container(width: 80, height: 80, color: Colors.green),
        ],
      ),
    );
  }
}''',
    ),
    extra: [
      WidgetLabBlock('row_column', 'Row va Column hizalash parametrlarini o\'zgartirib, farqini ko\'ring.'),
      WidgetLabBlock('container', 'Container: o\'lcham, rang, radius va padding.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'Elementlarni yonma-yon (gorizontal) joylash uchun qaysi widget?',
        options: ['Column', 'Row', 'Stack', 'Center'],
        correct: 1,
        explanation: '`Row` — gorizontal, `Column` — vertikal.',
      ),
      SingleChoice(
        prompt: '`Column` da `mainAxisAlignment` qaysi yo\'nalishda ishlaydi?',
        options: ['Gorizontal', 'Vertikal', 'Ikkalasida', 'Hech qaysida'],
        correct: 1,
        explanation: 'Column ning asosiy o\'qi — vertikal. Gorizontal hizalash uchun `crossAxisAlignment`.',
      ),
      MatchPairs(
        prompt: 'Moslang',
        pairs: [
          ('EdgeInsets.all(16)', 'har tomondan 16'),
          ('SizedBox(height: 8)', 'vertikal bo\'sh joy'),
          ('BorderRadius.circular(12)', 'yumaloq burchak'),
          ('MainAxisAlignment.spaceBetween', 'oraliqlarni teng taqsimlash'),
        ],
        explanation: 'Bular layoutning eng ko\'p ishlatiladigan qiymatlari.',
      ),
      TrueFalse(
        prompt: '`Container` ga bir vaqtda `color` va `decoration` berish mumkin.',
        answer: false,
        explanation: 'Mumkin emas — Flutter xato beradi. Rangni `BoxDecoration(color: ...)` ichiga yozing.',
      ),
    ],
    summary: [
      '`Container` — o\'lcham, rang, padding, margin, decoration',
      '`Padding` va `SizedBox` — bo\'shliqlar',
      '`Row` — gorizontal, `Column` — vertikal',
      '`mainAxisAlignment` — asosiy o\'q, `crossAxisAlignment` — ko\'ndalang o\'q',
    ],
    revisionTip: 'Telefoningizdagi biror ilova ekranini qog\'ozga Row/Column qutilari bilan chizib ko\'ring.',
    next: 'Keyingi darsda Scaffold, ikonkalar va tugmalar.',
    links: [DocLink('Layouts in Flutter', 'https://docs.flutter.dev/ui/layout')],
  ),

  // ───────────────────────── 5.4 ─────────────────────────
  Lesson(
    id: 'l5_scaffold',
    title: 'Scaffold, ikonkalar va tugmalar',
    subtitle: 'AppBar, Icon, ElevatedButton, FloatingActionButton',
    icon: Icons.smart_button_outlined,
    minutes: 18,
    xp: 70,
    skills: ['flutter.widgets'],
    prerequisites: ['Layout: Container, Row va Column'],
    objectives: [
      '`Scaffold` ning asosiy joylarini (appBar, body, floatingActionButton) ishlatasiz',
      '`Icon` va `Icons.*` bilan ikonka qo\'yasiz',
      'Tugmalar va `onPressed` callback\'ini tushunasiz',
    ],
    intro: [
      ParaBlock('**`Scaffold`** — Material ekranining tayyor karkasi. Unda joylar bor: `appBar` (tepa panel), `body` (asosiy qism), `floatingActionButton` (suzuvchi tugma), `bottomNavigationBar` (pastki menyu).'),
      ParaBlock('**`Icon(Icons.home)`** — ikonka. Flutterda minglab tayyor Material ikonkalari bor: `Icons.favorite`, `Icons.settings`, `Icons.add`...'),
      BulletsBlock([
        '**`ElevatedButton`** — ko\'tarilgan asosiy tugma',
        '**`FilledButton`** — to\'ldirilgan (eng muhim harakat)',
        '**`OutlinedButton`**, **`TextButton`** — ikkinchi darajali harakatlar',
        '**`IconButton`** — faqat ikonkadan iborat tugma',
        '**`FloatingActionButton`** — ekranning asosiy harakati (masalan "qo\'shish")',
      ]),
      ParaBlock('Har bir tugmada **`onPressed`** bor — bosilganda chaqiriladigan **funksiya** (callback). `onPressed: null` bo\'lsa, tugma o\'chirilgan (kulrang) holatda bo\'ladi.'),
    ],
    analogy: AnalogyBlock(
      'Eshik qo\'ng\'irog\'i',
      'Tugma — eshik qo\'ng\'irog\'i, `onPressed` — qo\'ng\'iroq simiga ulangan qurilma. Tugmani bosish o\'zi hech narsa qilmaydi — unga ulangan funksiya ishlaydi. Sim ulanmagan bo\'lsa (`null`), qo\'ng\'iroq jim.',
      icon: Icons.doorbell_outlined,
    ),
    why: 'Deyarli har bir ekranda AppBar, ikonkalar va tugmalar bor. Ularni to\'g\'ri tanlash — ilova qulayligining asosi (UX).',
    where: [
      'AppBar: sarlavha + qidiruv/sozlamalar ikonkalari',
      'Forma ostidagi "Saqlash" tugmasi',
      'FloatingActionButton: yangi xabar, yangi vazifa qo\'shish',
    ],
    terms: [
      TermBlock(term: 'Callback', uz: 'Qayta chaqiriluvchi funksiya', meaning: 'Biror hodisa yuz berganda chaqiriladigan funksiya.', why: 'Tugma bosilishiga javob berish.', example: "onPressed: () { print('bosildi'); }"),
      TermBlock(term: 'AppBar', uz: 'Ilova paneli', meaning: 'Ekran tepasidagi sarlavha va harakatlar paneli.', why: 'Foydalanuvchi qayerdaligini ko\'rsatadi.'),
      TermBlock(term: 'FAB', uz: 'Suzuvchi harakat tugmasi', meaning: 'FloatingActionButton — ekranning asosiy harakati.', why: 'Eng muhim amalni ko\'zga tashlantirish.'),
    ],
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Musiqa'),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () => print('Qidiruv')),
            IconButton(icon: const Icon(Icons.settings), onPressed: () => print('Sozlamalar')),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note, size: 96, color: Colors.deepPurple),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => print('Ijro etilmoqda'), child: const Text('Ijro etish')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => print('Pauza'), child: const Text('Pauza')),
              const SizedBox(height: 8),
              const TextButton(onPressed: null, child: Text('O\'chirilgan tugma')),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => print('Sevimlilarga qo\'shildi'),
          child: const Icon(Icons.favorite),
        ),
      ),
    );
  }
}''',
      title: 'main.dart',
      preview: true,
      explain: {
        'actions': 'AppBar o\'ng tomonidagi tugmalar ro\'yxati.',
        'IconButton': 'Faqat ikonkali tugma.',
        'Icons.music_note': 'Tayyor Material ikonka.',
        'onPressed': 'Bosilganda ishlaydigan funksiya (callback).',
        'onPressed: null': 'Callback yo\'q — tugma o\'chirilgan.',
        'floatingActionButton': 'Pastki o\'ng burchakdagi suzuvchi tugma.',
      },
      lineNotes: {
        16: '`() => print(...)` — anonim arrow funksiya. Tugmani bosing — konsolda natija chiqadi.',
        29: '`onPressed: null` — tugma kulrang va bosilmaydi.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: Text('Bosh sahifa'),
    body: const Center(child: Icon(Icons.home, size: 80)),
  ),
));''',
      task: 'Tepada odatiy sarlavha paneli (rangli, balandligi to\'g\'ri) chiqishi kerak edi, lekin oddiy matn chiqdi. Tuzating.',
      why: '`appBar` joyiga oddiy `Text` berilgan. Sarlavha paneli uchun **`AppBar`** widgeti kerak, matn esa uning `title` parametriga yoziladi.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: Text('Bosh sahifa')),
    body: const Center(child: Icon(Icons.home, size: 80)),
  ),
));''',
      hint: 'appBar ga qaysi widget beriladi?',
    ),
    task: CodeTask(
      title: 'Do\'kon ekrani',
      preview: true,
      instructions: 'Ekran yasang:\n- `AppBar` sarlavhasi: `Market`\n- `body` o\'rtasida `Icons.shopping_cart` ikonkasi\n- `FloatingActionButton` ichida `Icons.add` ikonkasi',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Market()));

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Market')),
    );
  }
}''',
      checks: [
        WidgetExists('AppBar', text: 'Market'),
        WidgetExists('Icon', props: {'icon': 'shopping_cart'}, label: '`Icon(Icons.shopping_cart)` bor'),
        WidgetExists('FloatingActionButton'),
        WidgetExists('Icon', props: {'icon': 'add'}, label: 'FAB ichida `Icons.add`'),
      ],
      hints: [
        'Scaffold da `appBar:`, `body:` va `floatingActionButton:` parametrlari bor.',
        'Ikonka: `Icon(Icons.shopping_cart, size: 80)`',
        r'''floatingActionButton: FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Market()));

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: const Center(child: Icon(Icons.shopping_cart, size: 80)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}''',
    ),
    extra: [
      WidgetLabBlock('buttons', 'Tugma turlarini solishtiring.'),
      WidgetLabBlock('icon', 'Ikonka o\'lchami va rangini o\'zgartiring.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'Tugmani o\'chirilgan (bosilmaydigan) holatga qanday keltiriladi?',
        options: ['enabled: false', 'onPressed: null', 'disabled: true', 'onPressed: false'],
        correct: 1,
        explanation: 'Flutterda tugma callback\'i `null` bo\'lsa, u avtomatik o\'chirilgan ko\'rinishda bo\'ladi.',
      ),
      MultiChoice(
        prompt: 'Qaysilari Scaffold parametrlari?',
        options: ['appBar', 'body', 'floatingActionButton', 'onPressed'],
        correct: {0, 1, 2},
        explanation: '`onPressed` — tugma parametri, Scaffold\'niki emas.',
      ),
      SingleChoice(
        prompt: '`onPressed: () => print(\'Salom\')` — bu nima?',
        options: ['String', 'Widget', 'Anonim funksiya (callback)', 'Ikonka'],
        correct: 2,
        explanation: 'Bu nomsiz arrow funksiya; tugma bosilganda chaqiriladi.',
      ),
    ],
    summary: [
      'Scaffold: `appBar`, `body`, `floatingActionButton`, `bottomNavigationBar`',
      '`Icon(Icons.nom, size:, color:)` — tayyor ikonkalar',
      'Tugmalar: Elevated, Filled, Outlined, Text, Icon, FAB',
      '`onPressed` — callback; `null` bo\'lsa tugma o\'chirilgan',
    ],
    revisionTip: 'Har bir ekranda bitta asosiy harakat bo\'lsin — uni FilledButton yoki FAB qiling.',
    next: 'Keyingi darsda eng muhim mavzu: StatefulWidget va setState — ekranni jonlantiramiz!',
    links: [DocLink('Scaffold', 'https://api.flutter.dev/flutter/material/Scaffold-class.html'), DocLink('Buttons', 'https://docs.flutter.dev/ui/widgets/material#buttons')],
  ),

  // ───────────────────────── 5.5 ─────────────────────────
  Lesson(
    id: 'l5_stateful',
    title: 'StatefulWidget va setState',
    subtitle: 'O\'zgaradigan holat va ekranni yangilash',
    icon: Icons.sync_alt_rounded,
    minutes: 22,
    xp: 80,
    skills: ['flutter.state'],
    prerequisites: ['Scaffold, ikonkalar va tugmalar'],
    objectives: [
      'Holat (state) nima ekanini va qachon StatefulWidget kerakligini tushunasiz',
      '`StatefulWidget` + `State` juftligini yozasiz',
      '`setState()` ekranni qanday yangilashini bilasiz',
    ],
    intro: [
      ParaBlock('StatelessWidget o\'zgarmaydi. Lekin ilovalarda ko\'p narsa o\'zgaradi: hisoblagich, yoqilgan/o\'chirilgan tugma, savatdagi mahsulotlar soni. Vaqt o\'tishi bilan o\'zgaradigan ma\'lumot — **holat (state)**.'),
      ParaBlock('**`StatefulWidget`** ikki class\'dan iborat:'),
      BulletsBlock([
        '`class Hisoblagich extends StatefulWidget` — widgetning o\'zi (o\'zgarmas sozlamalar)',
        '`class _HisoblagichState extends State<Hisoblagich>` — **holat** va `build()` shu yerda',
        '`createState()` — Flutter holat obyektini yaratadi',
        'Holatdan widget maydonlariga murojaat: **`widget.nom`**',
      ]),
      ParaBlock('Holatni o\'zgartirish: **`setState(() { _son++; });`**. `setState` — Flutter\'ga "holat o\'zgardi, `build` ni qayta chaqir" degan signal. **setState siz** o\'zgaruvchi o\'zgaradi, lekin ekran **yangilanmaydi**!'),
      CalloutBlock(CalloutKind.warning, 'Eng ko\'p uchraydigan xato', '`_son++` ni `setState` dan tashqarida yozish. Qiymat xotirada o\'zgaradi, ekranda esa eski son qoladi. Bu preview va tekshiruvchi ham haqiqiy Flutter kabi ishlaydi: setState bo\'lmasa — ekran o\'zgarmaydi.'),
    ],
    analogy: AnalogyBlock(
      'Tablo va hakam',
      'Stadiondagi tablo — ekran, hisob — holat. Gol urilganda hakam hisobni daftarga yozadi (`_son++`), lekin tablo operatoriga aytmasa (`setState`), tablo eski hisobni ko\'rsatib turaveradi. `setState` — "tabloni yangilang!" degan buyruq.',
      icon: Icons.scoreboard_outlined,
    ),
    why: 'Har qanday interaktiv ilova holatga asoslangan: like tugmasi, savat, forma, sozlamalar. setState — Flutterda holat boshqaruvining birinchi va asosiy usuli; Provider, Riverpod, Bloc kabi kutubxonalar ham shu g\'oyaga quriladi.',
    where: [
      'Like/sevimli tugmasi, hisoblagich',
      'Switch, Checkbox, tanlangan tab',
      'Yuklanmoqda / tayyor holatlari',
    ],
    terms: [
      TermBlock(term: 'State', uz: 'Holat', meaning: 'Vaqt o\'tishi bilan o\'zgaradigan ma\'lumot.', why: 'Ekran shu ma\'lumotga qarab chiziladi.'),
      TermBlock(term: 'StatefulWidget', uz: 'Holatli widget', meaning: 'O\'zgaradigan holatga ega widget.', why: 'Interaktiv UI uchun.'),
      TermBlock(term: 'setState', uz: 'Holatni o\'rnatish', meaning: 'Holatni o\'zgartirib, build ni qayta chaqirtiradi.', why: 'Ekranni yangilashning yagona to\'g\'ri yo\'li (bu darajada).', example: 'setState(() => _son++);'),
      TermBlock(term: 'initState', uz: 'Boshlang\'ich holat', meaning: 'State yaratilganda bir marta chaqiriladi.', why: 'Boshlang\'ich qiymatlar, obunalar uchun.'),
    ],
    animation: AnimationBlock('set_state', 'Bosish → setState → build() → yangi ekran.'),
    syntax: SyntaxBlock(r'''class Nom extends StatefulWidget {
  const Nom({super.key});
  @override
  State<Nom> createState() => _NomState();
}

class _NomState extends State<Nom> {
  int _qiymat = 0;

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}''', [
      SyntaxPart('extends StatefulWidget', 'holatli widget'),
      SyntaxPart('createState()', 'holat obyektini yaratadi'),
      SyntaxPart('_NomState', '_ — faqat shu faylda ko\'rinadigan (private) class'),
      SyntaxPart('int _qiymat', 'holat maydoni — o\'zgaradi (final emas)'),
    ]),
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Hisoblagich(sarlavha: 'Hisoblagich')));

class Hisoblagich extends StatefulWidget {
  const Hisoblagich({super.key, required this.sarlavha});
  final String sarlavha;

  @override
  State<Hisoblagich> createState() => _HisoblagichState();
}

class _HisoblagichState extends State<Hisoblagich> {
  int _son = 0;
  bool _yoqdi = false;

  void _oshir() {
    setState(() {
      _son++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sarlavha)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tugma shuncha marta bosildi:'),
            Text('$_son', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            IconButton(
              iconSize: 40,
              icon: Icon(_yoqdi ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              onPressed: () => setState(() => _yoqdi = !_yoqdi),
            ),
            Text(_yoqdi ? 'Yoqdi!' : 'Yurakchani bosing'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _oshir,
        child: const Icon(Icons.add),
      ),
    );
  }
}''',
      title: 'hisoblagich.dart',
      preview: true,
      explain: {
        'StatefulWidget': 'Holatli widget: o\'zgaradigan ma\'lumot State class\'ida.',
        'createState': 'Flutter holat obyektini shu metod orqali oladi.',
        'State<Hisoblagich>': 'Hisoblagich widgetining holati.',
        'setState': 'Holat o\'zgardi → build qayta chaqiriladi → ekran yangilanadi.',
        'widget.sarlavha': 'State ichidan widget maydoniga murojaat.',
        '_yoqdi = !_yoqdi': 'bool qiymatni teskarisiga almashtirish.',
      },
      lineNotes: {
        14: 'Holat maydonlari `final` emas — ular o\'zgaradi.',
        17: 'O\'zgarish `setState` ichida — Flutter ekranni qayta chizadi.',
        41: '`onPressed: _oshir` — funksiya **nomi** beriladi, `_oshir()` emas (aks holda darhol chaqirilib ketadi).',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Salom(ism: 'Jasur')));

class Salom extends StatefulWidget {
  const Salom({super.key, required this.ism});
  final String ism;

  @override
  State<Salom> createState() => _SalomState();
}

class _SalomState extends State<Salom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Salom, $ism!')));
  }
}''',
      task: 'Analizator `ism` ni topa olmayapti. Nima uchun va qanday tuzatiladi?',
      why: '`ism` — **widget** class\'ining maydoni, `build` esa **State** class\'ida. State ichidan widget maydonlariga `widget.` orqali murojaat qilinadi: `widget.ism`.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Salom(ism: 'Jasur')));

class Salom extends StatefulWidget {
  const Salom({super.key, required this.ism});
  final String ism;

  @override
  State<Salom> createState() => _SalomState();
}

class _SalomState extends State<Salom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Salom, ${widget.ism}!')));
  }
}''',
      hint: 'State ichidan widget maydoniga qanday murojaat qilinadi?',
    ),
    task: CodeTask(
      title: 'Plus-minus hisoblagich',
      preview: true,
      instructions: 'Hisoblagich yasang: ekranda `Son: 0` matni, ostida ikkita tugma — `+` va `-` yozuvli.\n`+` sonni 1 ga oshirsin, `-` 1 ga kamaytirsin. Ekran har bosishda yangilanishi kerak (setState!).',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: PlusMinus()))));

class PlusMinus extends StatefulWidget {
  const PlusMinus({super.key});

  @override
  State<PlusMinus> createState() => _PlusMinusState();
}

class _PlusMinusState extends State<PlusMinus> {
  int _son = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Son: $_son'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('-')),
            ElevatedButton(onPressed: () { _son++; }, child: const Text('+')),
          ],
        ),
      ],
    );
  }
}''',
      checks: [
        WidgetExists('Text', text: 'Son: 0', label: 'Boshida `Son: 0`'),
        AfterTap('+', 'Son: 1'),
        AfterTap('+', 'Son: 3', times: 3),
        AfterTap('-', 'Son: -1'),
        AfterTap('-', 'Son: -2', times: 2, hidden: true),
        UsesConstruct(r'setState\s*\(', '`setState` ishlatilgan'),
      ],
      hints: [
        'Boshlang\'ich kodda `_son++` bor, lekin ekran yangilanmaydi. Nima yetishmayapti?',
        '`onPressed: () => setState(() => _son++)`',
        r'''ElevatedButton(onPressed: () => setState(() => _son--), child: const Text('-')),
ElevatedButton(onPressed: () => setState(() => _son++), child: const Text('+')),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: PlusMinus()))));

class PlusMinus extends StatefulWidget {
  const PlusMinus({super.key});

  @override
  State<PlusMinus> createState() => _PlusMinusState();
}

class _PlusMinusState extends State<PlusMinus> {
  int _son = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Son: $_son'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => setState(() => _son--), child: const Text('-')),
            ElevatedButton(onPressed: () => setState(() => _son++), child: const Text('+')),
          ],
        ),
      ],
    );
  }
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'O\'zgaruvchi `setState` siz o\'zgartirilsa nima bo\'ladi?',
        options: ['Xato beradi', 'Qiymat o\'zgaradi, lekin ekran yangilanmaydi', 'Ilova yopiladi', 'Hech narsa o\'zgarmaydi'],
        correct: 1,
        explanation: 'Qiymat xotirada o\'zgaradi, ammo Flutter `build` ni qayta chaqirmaydi — ekranda eski qiymat qoladi.',
      ),
      SingleChoice(
        prompt: 'State ichidan widgetning `title` maydoniga qanday murojaat qilinadi?',
        options: ['this.title', 'title', 'widget.title', 'state.title'],
        correct: 2,
        explanation: 'State class\'ida `widget` xususiyati — unga tegishli widget obyekti.',
      ),
      TrueFalse(
        prompt: '`onPressed: _oshir()` va `onPressed: _oshir` bir xil.',
        answer: false,
        explanation: '`_oshir()` funksiyani darhol chaqirib, natijasini (void) beradi. Callback uchun funksiyaning o\'zi — `_oshir` beriladi.',
      ),
      ArrangeLines(
        prompt: 'Tugma bosilgandan keyingi jarayonni tartiblang',
        lines: ['onPressed chaqiriladi', 'setState ichida holat o\'zgaradi', 'Flutter build() ni qayta chaqiradi', 'Ekranda yangi qiymat ko\'rinadi'],
        byOutput: false,
        explanation: 'Bosish → setState → build → yangi ekran.',
      ),
    ],
    summary: [
      'Holat (state) — vaqt bilan o\'zgaradigan ma\'lumot',
      'StatefulWidget = widget class + State class (`createState`)',
      'Holatni faqat `setState(() { ... })` ichida o\'zgartiring',
      'State ichidan widget maydonlari: `widget.nom`',
    ],
    revisionTip: 'Ekran yangilanmasa — birinchi savol: "setState chaqirildimi?"',
    next: 'Keyingi darsda ro\'yxatlar: ListView va ListView.builder.',
    links: [DocLink('Adding interactivity', 'https://docs.flutter.dev/ui/interactivity')],
  ),

  // ───────────────────────── 5.6 ─────────────────────────
  Lesson(
    id: 'l5_lists',
    title: 'Ro\'yxatlar: ListView',
    subtitle: 'ListView, ListView.builder, ListTile va Card',
    icon: Icons.view_list_outlined,
    minutes: 20,
    xp: 80,
    skills: ['flutter.lists'],
    prerequisites: ['StatefulWidget va setState'],
    objectives: [
      '`ListView` bilan aylantiriladigan (scroll) ro\'yxat yasaysiz',
      '`ListView.builder` bilan ma\'lumotlar ro\'yxatidan dinamik UI quriysiz',
      '`ListTile` va `Card` bilan chiroyli qatorlar yasaysiz',
    ],
    intro: [
      ParaBlock('Column ekranga sig\'maydigan ko\'p elementni ko\'rsata olmaydi. **`ListView`** — aylantiriladigan (scroll) ro\'yxat.'),
      BulletsBlock([
        '**`ListView(children: [...])`** — oz va oldindan ma\'lum elementlar uchun',
        '**`ListView.builder(itemCount:, itemBuilder:)`** — ko\'p yoki dinamik ma\'lumot uchun: elementlar faqat ekranda ko\'rinayotganda yaratiladi (tez va tejamkor)',
        '**`ListTile`** — tayyor qator: `leading` (chap), `title`, `subtitle`, `trailing` (o\'ng), `onTap`',
        '**`Card`** — soyali, yumaloq burchakli karta',
      ]),
      ParaBlock('`itemBuilder: (context, index) { ... }` — Flutter har bir qator uchun shu funksiyani `index` = 0, 1, 2... bilan chaqiradi. Siz `royxat[index]` dan widget qaytarasiz.'),
    ],
    analogy: AnalogyBlock(
      'Kutubxona kartotekasi',
      'ListView.builder — kutubxonachi: 10 000 kitobning hammasini stolga to\'kmaydi, siz qaysi tokchaga qarasangiz, faqat o\'shalarni olib beradi. `itemCount` — jami kitoblar soni, `itemBuilder` — "N-kitobni olib ber" degan ko\'rsatma.',
      icon: Icons.local_library_outlined,
    ),
    why: 'Deyarli har bir ilovada ro\'yxat bor: chatlar, mahsulotlar, xabarlar, sozlamalar. ListView.builder katta ma\'lumotlarda ham ilovani tez ishlashini ta\'minlaydi.',
    where: [
      'Chatlar va kontaktlar ro\'yxati',
      'Mahsulot katalogi, yangiliklar lentasi',
      'Sozlamalar sahifasi (ListTile)',
    ],
    terms: [
      TermBlock(term: 'Scroll', uz: 'Aylantirish', meaning: 'Ekranga sig\'magan kontentni surib ko\'rish.', why: 'Ko\'p ma\'lumot ko\'rsatish uchun.'),
      TermBlock(term: 'itemBuilder', uz: 'Element quruvchi', meaning: 'index bo\'yicha bitta qator widgetini qaytaruvchi funksiya.', why: 'Dinamik ro\'yxat uchun.'),
      TermBlock(term: 'Lazy loading', uz: 'Dangasa yuklash', meaning: 'Element faqat kerak bo\'lganda yaratiladi.', why: 'Tezlik va xotira tejash.'),
    ],
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Kontaktlar()));

class Kontakt {
  const Kontakt(this.ism, this.telefon, this.sevimli);
  final String ism;
  final String telefon;
  final bool sevimli;
}

class Kontaktlar extends StatelessWidget {
  const Kontaktlar({super.key});

  static const royxat = [
    Kontakt('Aziza', '+998 90 111 22 33', true),
    Kontakt('Bobur', '+998 91 222 33 44', false),
    Kontakt('Dilnoza', '+998 93 333 44 55', true),
    Kontakt('Eldor', '+998 94 444 55 66', false),
    Kontakt('Feruza', '+998 95 555 66 77', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kontaktlar (${royxat.length})')),
      body: ListView.builder(
        itemCount: royxat.length,
        itemBuilder: (context, index) {
          final k = royxat[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text(k.ism[0])),
              title: Text(k.ism),
              subtitle: Text(k.telefon),
              trailing: k.sevimli ? const Icon(Icons.star, color: Colors.amber) : null,
              onTap: () => print('Qo\'ng\'iroq: ${k.ism}'),
            ),
          );
        },
      ),
    );
  }
}''',
      title: 'kontaktlar.dart',
      preview: true,
      explain: {
        'ListView.builder': 'Dinamik ro\'yxat: qatorlar index bo\'yicha quriladi.',
        'itemCount': 'Jami qatorlar soni.',
        'itemBuilder': '(context, index) → bitta qator widgeti.',
        'royxat[index]': 'index-chi kontakt.',
        'ListTile': 'Tayyor qator: leading, title, subtitle, trailing.',
        'trailing': 'Qatorning o\'ng tomoni; null bo\'lsa — bo\'sh.',
      },
      lineNotes: {
        5: 'Oddiy Dart class — ma\'lumot modeli. UI va ma\'lumotni ajratish yaxshi odat.',
        28: '`itemCount` ro\'yxat uzunligiga teng — index 0..4.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Mevalar()));

class Mevalar extends StatelessWidget {
  const Mevalar({super.key});

  @override
  Widget build(BuildContext context) {
    const mevalar = ['Olma', 'Nok', 'Uzum'];
    return Scaffold(
      body: ListView.builder(
        itemCount: mevalar.length + 1,
        itemBuilder: (context, i) => ListTile(title: Text(mevalar[i])),
      ),
    );
  }
}''',
      task: 'Ro\'yxat ochilganda xato chiqyapti. Sababini toping.',
      why: '`itemCount: mevalar.length + 1` — 4 ta qator so\'ralyapti, lekin ro\'yxatda 3 ta element (indekslar 0, 1, 2). `mevalar[3]` — **RangeError**. itemCount aynan ro\'yxat uzunligiga teng bo\'lishi kerak.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Mevalar()));

class Mevalar extends StatelessWidget {
  const Mevalar({super.key});

  @override
  Widget build(BuildContext context) {
    const mevalar = ['Olma', 'Nok', 'Uzum'];
    return Scaffold(
      body: ListView.builder(
        itemCount: mevalar.length,
        itemBuilder: (context, i) => ListTile(title: Text(mevalar[i])),
      ),
    );
  }
}''',
      hint: 'Ro\'yxatda nechta element bor va nechta qator so\'ralyapti?',
    ),
    task: CodeTask(
      title: 'Vazifalar ro\'yxati',
      preview: true,
      instructions: '`vazifalar` ro\'yxatidan `ListView.builder` bilan ekran yasang. Har bir qator — `ListTile`: `leading` da `Icon(Icons.check_circle)`, `title` da vazifa matni.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Vazifalar()));

class Vazifalar extends StatelessWidget {
  const Vazifalar({super.key});

  static const vazifalar = ['Kitob o\'qish', 'Sport', 'Dart mashqi', 'Flutter darsi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugun')),
      body: const Center(child: Text('Ro\'yxat shu yerda bo\'ladi')),
    );
  }
}''',
      checks: [
        UsesConstruct(r'ListView\.builder', '`ListView.builder` ishlatilgan'),
        WidgetExists('ListTile', min: 4, label: 'Kamida 4 ta `ListTile`'),
        WidgetExists('Text', text: 'Kitob o\'qish'),
        WidgetExists('Text', text: 'Flutter darsi'),
        WidgetExists('Icon', props: {'icon': 'check_circle'}, min: 4, label: 'Har qatorda `Icons.check_circle`'),
      ],
      hints: [
        '`body: ListView.builder(itemCount: vazifalar.length, itemBuilder: ...)`',
        'itemBuilder: (context, i) => ListTile(...)',
        r'''itemBuilder: (context, i) => ListTile(
  leading: const Icon(Icons.check_circle),
  title: Text(vazifalar[i]),
),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Vazifalar()));

class Vazifalar extends StatelessWidget {
  const Vazifalar({super.key});

  static const vazifalar = ['Kitob o\'qish', 'Sport', 'Dart mashqi', 'Flutter darsi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugun')),
      body: ListView.builder(
        itemCount: vazifalar.length,
        itemBuilder: (context, i) => ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(vazifalar[i]),
        ),
      ),
    );
  }
}''',
    ),
    extra: [
      WidgetLabBlock('listview', 'ListView elementlari va ajratgichlar bilan tajriba.'),
    ],
    quiz: [
      SingleChoice(
        prompt: '1000 ta mahsulotni ko\'rsatish uchun eng to\'g\'ri tanlov?',
        options: ['Column', 'ListView(children: ...)', 'ListView.builder', 'Row'],
        correct: 2,
        explanation: 'ListView.builder qatorlarni faqat ekranda ko\'ringanda quradi — katta ro\'yxatlar uchun tez.',
      ),
      SingleChoice(
        prompt: '`itemBuilder: (context, index)` da `index` nima?',
        options: ['Ro\'yxat uzunligi', 'Quriladigan qator tartib raqami (0 dan)', 'Widget nomi', 'Tasodifiy son'],
        correct: 1,
        explanation: 'Flutter har qator uchun index = 0, 1, 2... bilan chaqiradi.',
      ),
      MatchPairs(
        prompt: 'ListTile qismlarini moslang',
        pairs: [
          ('leading', 'chap tomondagi element'),
          ('title', 'asosiy matn'),
          ('subtitle', 'ikkinchi qator matni'),
          ('trailing', 'o\'ng tomondagi element'),
        ],
        explanation: 'ListTile — sozlamalar, kontaktlar, xabarlar uchun tayyor qator.',
      ),
    ],
    summary: [
      '`ListView` — aylantiriladigan ro\'yxat',
      '`ListView.builder(itemCount, itemBuilder)` — dinamik va tejamkor',
      '`itemCount` aynan ro\'yxat uzunligi bo\'lsin (aks holda RangeError)',
      '`ListTile` + `Card` — chiroyli qatorlar',
    ],
    revisionTip: 'Har doim ma\'lumotni (List) va uning ko\'rinishini (itemBuilder) alohida o\'ylang.',
    next: 'Keyingi darsda Stack va Expanded — murakkabroq joylashuvlar.',
    links: [DocLink('Work with long lists', 'https://docs.flutter.dev/cookbook/lists/long-lists')],
  ),

  // ───────────────────────── 5.7 ─────────────────────────
  Lesson(
    id: 'l5_stack_expanded',
    title: 'Stack, Expanded va Flexible',
    subtitle: 'Ustma-ust qatlamlar va bo\'sh joyni taqsimlash',
    icon: Icons.layers_outlined,
    minutes: 18,
    xp: 80,
    skills: ['flutter.layout'],
    prerequisites: ['Layout: Container, Row va Column'],
    objectives: [
      '`Stack` va `Positioned` bilan elementlarni ustma-ust qo\'yasiz',
      '`Expanded` bilan Row/Column dagi bo\'sh joyni taqsimlaysiz',
      '`flex` qiymati nisbatni qanday belgilashini tushunasiz',
    ],
    intro: [
      ParaBlock('**`Stack`** — farzandlarni **qatlam-qatlam** ustma-ust qo\'yadi: birinchisi pastda, oxirgisi eng tepada. Rasm ustidagi yozuv, avatar ustidagi "online" nuqtasi, karta burchagidagi "YANGI" yorlig\'i — hammasi Stack.'),
      ParaBlock('**`Positioned(top:, left:, right:, bottom:)`** — Stack ichida elementni aniq joyga qo\'yadi.'),
      ParaBlock('**`Expanded`** — Row yoki Column ichida qolgan **bo\'sh joyni egallaydi**. Bir nechta Expanded bo\'lsa, joy `flex` nisbatida bo\'linadi: `flex: 2` va `flex: 1` → 2:1.'),
      CalloutBlock(CalloutKind.warning, 'Muhim qoida', '`Expanded` va `Flexible` faqat `Row`, `Column` (yoki `Flex`) ichida ishlaydi. `Positioned` esa faqat `Stack` ichida. Boshqa joyda Flutter xato beradi.'),
    ],
    analogy: AnalogyBlock(
      'Pitsa va tort',
      'Stack — qatlamli tort: pastda biskvit, o\'rtada krem, tepada gilos (Positioned bilan aniq joyda). Expanded — pitsani bo\'lish: `flex: 2` olgan odam ikki bo\'lak, `flex: 1` olgan — bitta bo\'lak oladi.',
      icon: Icons.cake_outlined,
    ),
    why: 'Zamonaviy dizaynlar ko\'pincha qatlamli (Stack) va moslashuvchan (Expanded). Expanded yordamida ekran kengligi qanday bo\'lishidan qat\'i nazar layout to\'g\'ri taqsimlanadi.',
    where: [
      'Banner: rasm + ustidagi matn (Stack)',
      'Bildirishnoma nishoni (badge) ikonka burchagida',
      'Qidiruv qatori: Expanded TextField + tugma',
    ],
    terms: [
      TermBlock(term: 'Stack', uz: 'Qatlam', meaning: 'Farzandlarni ustma-ust joylaydi.', why: 'Overlay dizaynlar uchun.'),
      TermBlock(term: 'Positioned', uz: 'Joylashtirilgan', meaning: 'Stack ichida aniq koordinata.', why: 'Badge, yorliq qo\'yish uchun.'),
      TermBlock(term: 'Expanded', uz: 'Kengaytirilgan', meaning: 'Qolgan bo\'sh joyni egallaydi.', why: 'Moslashuvchan layout.'),
      TermBlock(term: 'flex', uz: 'Nisbat', meaning: 'Expanded lar orasida joy bo\'linish ulushi.', why: 'Proporsional ustunlar.', example: 'Expanded(flex: 2, child: ...)'),
    ],
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: Namuna())));

class Namuna extends StatelessWidget {
  const Namuna({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.indigo, Colors.cyan]),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('Flutter kursi', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                  child: const Text('YANGI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 2, child: Container(height: 60, color: Colors.teal, alignment: Alignment.center, child: const Text('flex: 2'))),
              const SizedBox(width: 8),
              Expanded(child: Container(height: 60, color: Colors.amber, alignment: Alignment.center, child: const Text('flex: 1'))),
            ],
          ),
        ],
      ),
    );
  }
}''',
      title: 'stack_expanded.dart',
      preview: true,
      explain: {
        'Stack': 'Farzandlar ustma-ust: oxirgisi eng tepada.',
        'Positioned': 'Stack ichida aniq joy: tepadan 10, o\'ngdan 10.',
        'LinearGradient': 'Ranglarning silliq o\'tishi.',
        'Expanded(flex: 2': 'Bo\'sh joyning 2/3 qismi.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Ustunlar())));

class Ustunlar extends StatelessWidget {
  const Ustunlar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 100, color: Colors.blue)),
      Expanded(child: Container(height: 100, color: Colors.red)),
    ]);
  }
}''',
      task: 'Ko\'k ustun qizildan **uch barobar keng** bo\'lishi kerak, lekin ular teng chiqyapti. Tuzating.',
      why: 'Ikkala `Expanded` ning `flex` qiymati standart — 1, shuning uchun joy 1:1 bo\'linadi. 3:1 nisbat uchun ko\'k ustunga `flex: 3` bering.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Ustunlar())));

class Ustunlar extends StatelessWidget {
  const Ustunlar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 3, child: Container(height: 100, color: Colors.blue)),
      Expanded(child: Container(height: 100, color: Colors.red)),
    ]);
  }
}''',
      hint: 'Expanded da nisbatni qaysi parametr belgilaydi?',
    ),
    task: CodeTask(
      title: 'Avatar va nishon',
      preview: true,
      instructions: '`Stack` yordamida avatar yasang: pastda `CircleAvatar(radius: 40)`, uning o\'ng-past burchagida (`Positioned(right: 0, bottom: 0)`) yashil doira — `Container(width: 20, height: 20)` + `BoxDecoration(color: Colors.green, shape: BoxShape.circle)`.\nAvatar ostida `Row` ichida ikkita `Expanded`: `Obunachilar` (flex: 2) va `Postlar` (flex: 1) matnlari bilan.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Profil())));

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircleAvatar(radius: 40, child: Text('A')),
    );
  }
}''',
      checks: [
        WidgetExists('Stack'),
        WidgetExists('Positioned', props: {'right': '0', 'bottom': '0'}, label: '`Positioned(right: 0, bottom: 0)`'),
        WidgetExists('CircleAvatar'),
        WidgetExists('Expanded', props: {'flex': '2'}, text: 'Obunachilar', label: '`Expanded(flex: 2)` ichida `Obunachilar`'),
        WidgetExists('Expanded', text: 'Postlar'),
        WidgetExists('Expanded', min: 2, hidden: true),
      ],
      hints: [
        'Column(children: [Stack(...), Row(...)])',
        r'''Stack(children: [
  const CircleAvatar(radius: 40, child: Text('A')),
  Positioned(right: 0, bottom: 0, child: Container(...)),
])''',
        r'''Row(children: [
  Expanded(flex: 2, child: Text('Obunachilar')),
  Expanded(child: Text('Postlar')),
])''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Profil())));

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              const CircleAvatar(radius: 40, child: Text('A')),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(flex: 2, child: Text('Obunachilar')),
              Expanded(child: Text('Postlar')),
            ],
          ),
        ],
      ),
    );
  }
}''',
    ),
    extra: [
      WidgetLabBlock('stack', 'Stack va Positioned bilan tajriba.'),
      WidgetLabBlock('expanded', 'Expanded flex nisbatlarini o\'zgartiring.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'Stack ichida qaysi farzand eng tepada (ko\'rinadigan) bo\'ladi?',
        options: ['Birinchisi', 'Oxirgisi', 'Eng kattasi', 'Tasodifiy'],
        correct: 1,
        explanation: 'Stack farzandlarni ro\'yxat tartibida chizadi — oxirgisi eng ustida.',
      ),
      SingleChoice(
        prompt: '`Expanded(flex: 1)` va `Expanded(flex: 3)` joyni qanday bo\'ladi?',
        options: ['1:1', '1:3', '3:1', '1:4'],
        correct: 1,
        explanation: 'Joy flex nisbatida: birinchisiga 1/4, ikkinchisiga 3/4.',
      ),
      TrueFalse(
        prompt: '`Positioned` ni `Column` ichida ishlatish mumkin.',
        answer: false,
        explanation: 'Positioned faqat Stack ichida ishlaydi.',
      ),
    ],
    summary: [
      '`Stack` — qatlamlar; oxirgi farzand eng tepada',
      '`Positioned` — Stack ichida aniq joy',
      '`Expanded` — Row/Column dagi bo\'sh joyni egallaydi',
      '`flex` — Expanded lar orasidagi nisbat',
    ],
    revisionTip: 'Overlay kerakmi — Stack; joyni taqsimlash kerakmi — Expanded.',
    next: 'Keyingi darsda foydalanuvchi kiritishi: TextField va Switch.',
    links: [DocLink('Stack', 'https://api.flutter.dev/flutter/widgets/Stack-class.html'), DocLink('Expanded', 'https://api.flutter.dev/flutter/widgets/Expanded-class.html')],
  ),

  // ───────────────────────── 5.8 ─────────────────────────
  Lesson(
    id: 'l5_input',
    title: 'Kiritish: TextField va Switch',
    subtitle: 'Foydalanuvchidan ma\'lumot olish',
    icon: Icons.keyboard_outlined,
    minutes: 20,
    xp: 90,
    skills: ['flutter.input', 'flutter.state'],
    prerequisites: ['StatefulWidget va setState'],
    objectives: [
      '`TextField` va `TextEditingController` bilan matn olasiz',
      '`onChanged` callback\'ini ishlatasiz',
      '`Switch`/`SwitchListTile` bilan yoqish-o\'chirish holatini boshqarasiz',
    ],
    intro: [
      ParaBlock('**`TextField`** — matn kiritish maydoni. Uning qiymatini olishning ikki yo\'li bor:'),
      BulletsBlock([
        '**`TextEditingController`** — maydon bilan bog\'langan obyekt: `controller.text` — joriy matn, `controller.clear()` — tozalash',
        '**`onChanged: (qiymat) { ... }`** — har bir harf kiritilganda chaqiriladi',
        '**`decoration: InputDecoration(labelText:, hintText:, prefixIcon:)`** — yorliq, maslahat, ikonka',
      ]),
      ParaBlock('**`Switch(value:, onChanged:)`** — yoqish/o\'chirish. Muhim: Switch o\'zi holat saqlamaydi! `value` ni siz berasiz, `onChanged` da esa `setState` bilan yangilaysiz. `SwitchListTile` — sarlavhali tayyor variant.'),
      CalloutBlock(CalloutKind.tip, 'Controlled widget', 'Switch, Checkbox, TextField — "boshqariladigan" widgetlar: ular ko\'rsatadigan qiymat sizning holatingizdan keladi. Bu Flutterning asosiy g\'oyasi: **UI = f(state)** — ekran holatning funksiyasi.'),
    ],
    analogy: AnalogyBlock(
      'Pochta qutisi',
      'TextField — pochta qutisi, TextEditingController — qutining kaliti: kalit bilan istalgan payt ichidagi xatni (`controller.text`) o\'qiysiz yoki qutini bo\'shatasiz (`clear()`). `onChanged` esa har safar xat tushganda chalinadigan qo\'ng\'iroq.',
      icon: Icons.markunread_mailbox_outlined,
    ),
    why: 'Ro\'yxatdan o\'tish, qidiruv, chat, sozlamalar — foydalanuvchi bilan muloqot kiritish widgetlarisiz bo\'lmaydi.',
    where: [
      'Login va ro\'yxatdan o\'tish formalari',
      'Qidiruv qatori, chat xabari',
      'Sozlamalar: qorong\'i rejim, bildirishnomalar',
    ],
    terms: [
      TermBlock(term: 'TextEditingController', uz: 'Matn boshqaruvchisi', meaning: 'TextField matnini o\'qish/o\'zgartirish obyekti.', why: 'Tugma bosilganda matnni olish uchun.'),
      TermBlock(term: 'onChanged', uz: 'O\'zgarganda', meaning: 'Qiymat o\'zgarganda chaqiriladigan callback.', why: 'Jonli qidiruv, tekshiruv.'),
      TermBlock(term: 'InputDecoration', uz: 'Kiritish bezagi', meaning: 'Yorliq, maslahat, ikonka, xato matni.', why: 'Tushunarli forma.'),
      TermBlock(term: 'UI = f(state)', uz: 'Ekran — holat funksiyasi', meaning: 'Ekran har doim joriy holatdan chiziladi.', why: 'Flutterning asosiy falsafasi.'),
    ],
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Tanishuv()));

class Tanishuv extends StatefulWidget {
  const Tanishuv({super.key});

  @override
  State<Tanishuv> createState() => _TanishuvState();
}

class _TanishuvState extends State<Tanishuv> {
  final _ismCtrl = TextEditingController();
  String _salom = '';
  int _harflar = 0;
  bool _qorongi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _qorongi ? Colors.blueGrey.shade900 : Colors.white,
      appBar: AppBar(title: const Text('Tanishuv')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ismCtrl,
              decoration: const InputDecoration(
                labelText: 'Ismingiz',
                hintText: 'Masalan: Aziza',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _harflar = v.length),
            ),
            const SizedBox(height: 6),
            Text('$_harflar ta harf', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => _salom = 'Salom, ${_ismCtrl.text}!'),
              child: const Text('Salomlash'),
            ),
            const SizedBox(height: 12),
            Text(_salom, style: TextStyle(fontSize: 22, color: _qorongi ? Colors.white : Colors.black)),
            const Spacer(),
            Card(
              child: SwitchListTile(
                title: const Text('Qorong\'i fon'),
                value: _qorongi,
                onChanged: (v) => setState(() => _qorongi = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}''',
      title: 'tanishuv.dart',
      preview: true,
      explain: {
        'TextEditingController': 'TextField matnini boshqaruvchi obyekt.',
        '_ismCtrl.text': 'Maydondagi joriy matn.',
        'InputDecoration': 'Yorliq, maslahat va ikonka.',
        'onChanged': 'Har harf kiritilganda chaqiriladi.',
        'SwitchListTile': 'Sarlavhali yoqish-o\'chirish qatori.',
        'Spacer': 'Column dagi qolgan bo\'sh joyni egallaydi.',
      },
      lineNotes: {
        13: 'Controller — State ichida bir marta yaratiladi.',
        52: 'Switch qiymati `_qorongi` holatidan keladi; o\'zgarishni setState bilan saqlaymiz.',
      },
    ),
    buggy: BuggyCodeBlock(
      preview: true,
      code: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Shahar())));

class Shahar extends StatefulWidget {
  const Shahar({super.key});

  @override
  State<Shahar> createState() => _ShaharState();
}

class _ShaharState extends State<Shahar> {
  final _ctrl = TextEditingController(text: 'Samarqand');

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(controller: _ctrl),
      Text('Shahar: $_ctrl'),
    ]);
  }
}''',
      task: 'Matn ostida `Shahar: Samarqand` chiqishi kerak edi, lekin g\'alati yozuv chiqyapti. Tuzating.',
      why: '`\$_ctrl` — controller **obyektining o\'zi** ("Instance of ..."). Ichidagi matn `text` xususiyatida: `\${_ctrl.text}`.',
      fixed: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Shahar())));

class Shahar extends StatefulWidget {
  const Shahar({super.key});

  @override
  State<Shahar> createState() => _ShaharState();
}

class _ShaharState extends State<Shahar> {
  final _ctrl = TextEditingController(text: 'Samarqand');

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(controller: _ctrl),
      Text('Shahar: ${_ctrl.text}'),
    ]);
  }
}''',
      hint: 'Controller ichidagi matn qaysi xususiyatda saqlanadi?',
    ),
    task: CodeTask(
      title: 'Bildirishnomalar sozlamasi',
      preview: true,
      instructions: '`SwitchListTile` yasang: sarlavhasi `Bildirishnomalar`, boshida o\'chirilgan.\nUning ostida holat matni: yoqilganda `Holat: yoqilgan`, o\'chirilganda `Holat: o\'chirilgan`.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Sozlama())));

class Sozlama extends StatefulWidget {
  const Sozlama({super.key});

  @override
  State<Sozlama> createState() => _SozlamaState();
}

class _SozlamaState extends State<Sozlama> {
  bool _yoqilgan = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 40),
      Text(_yoqilgan ? 'Holat: yoqilgan' : "Holat: o'chirilgan"),
    ]);
  }
}''',
      checks: [
        WidgetExists('SwitchListTile', text: 'Bildirishnomalar'),
        WidgetExists('Text', text: "Holat: o'chirilgan", label: 'Boshida `Holat: o\'chirilgan`'),
        AfterTap('Bildirishnomalar', 'Holat: yoqilgan', label: 'Bosilgach `Holat: yoqilgan`'),
        AfterTap('Bildirishnomalar', "Holat: o'chirilgan", times: 2, hidden: true),
      ],
      hints: [
        'Column ga `SwitchListTile(title: ..., value: _yoqilgan, onChanged: ...)` qo\'shing.',
        'onChanged: (v) => setState(() => _yoqilgan = v)',
        r'''SwitchListTile(
  title: const Text('Bildirishnomalar'),
  value: _yoqilgan,
  onChanged: (v) => setState(() => _yoqilgan = v),
),''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Sozlama())));

class Sozlama extends StatefulWidget {
  const Sozlama({super.key});

  @override
  State<Sozlama> createState() => _SozlamaState();
}

class _SozlamaState extends State<Sozlama> {
  bool _yoqilgan = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 40),
      SwitchListTile(
        title: const Text('Bildirishnomalar'),
        value: _yoqilgan,
        onChanged: (v) => setState(() => _yoqilgan = v),
      ),
      Text(_yoqilgan ? 'Holat: yoqilgan' : "Holat: o'chirilgan"),
    ]);
  }
}''',
    ),
    extra: [
      WidgetLabBlock('textfield', 'TextField bezaklarini sinab ko\'ring.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'TextField dagi joriy matnni qanday olasiz?',
        options: ['textField.value', 'controller.text', 'TextField.text', 'context.text'],
        correct: 1,
        explanation: 'TextEditingController ning `text` xususiyati — joriy matn.',
      ),
      TrueFalse(
        prompt: 'Switch o\'z holatini o\'zi saqlaydi — `value` berish shart emas.',
        answer: false,
        explanation: 'Switch "boshqariladigan": `value` ni siz berasiz va `onChanged` da setState bilan yangilaysiz.',
      ),
      SingleChoice(
        prompt: '"UI = f(state)" nimani anglatadi?',
        options: ['UI tezroq ishlaydi', 'Ekran har doim joriy holatdan chiziladi', 'State UI dan katta', 'Funksiyalar UI ni o\'chiradi'],
        correct: 1,
        explanation: 'Flutterda ekran holatning natijasi: holat o\'zgaradi → build → yangi ekran.',
      ),
    ],
    summary: [
      '`TextField` + `TextEditingController` → `controller.text`',
      '`onChanged` — har o\'zgarishda callback',
      '`Switch`/`SwitchListTile`: `value` + `onChanged` + setState',
      'UI = f(state): ekran holatdan chiziladi',
    ],
    revisionTip: 'Ilovangizga sozlamalar ekranini qo\'shing: 3 ta SwitchListTile va ularning holatlari.',
    next: 'Tabriklaymiz — Flutter asoslari tugadi! Keyingi darajada professional UI: constraints, responsive dizayn, navigatsiya va formalar.',
    links: [DocLink('Text input', 'https://docs.flutter.dev/cookbook/forms/text-input'), DocLink('Switch', 'https://api.flutter.dev/flutter/material/Switch-class.html')],
  ),
];
