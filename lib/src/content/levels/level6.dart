import 'package:flutter/material.dart';

import '../model.dart';

/// Flutter ilovasini turli o'lchamdagi ekranlarga moslashni amalda o'rgatadi.
const level6Lessons = <Lesson>[
  Lesson(
    id: 'l6_responsive_wrap',
    title: 'Responsive layout: telefon va katta ekran',
    subtitle: 'Widgetlarni mavjud joyga moslab joylashtirish',
    icon: Icons.devices_rounded,
    minutes: 18,
    xp: 65,
    skills: ['flutter.responsive'],
    prerequisites: ['Row, Column va Container', 'ListView va GridView'],
    objectives: [
      'Responsive dizayn nima sabab kerakligini tushuntirasiz',
      '`Wrap` va `ConstrainedBox` bilan turli enlarda buzilmaydigan kartalar yasaysiz',
      'Kenglikni `width` ga qattiq bog\'lab qo\'yish xatosidan qochasiz',
    ],
    intro: [
      ParaBlock(
        'Telefon, planshet va brauzer oynasining eni har xil. Faqat bitta eni bor deb yozilgan UI kichik ekranda siqiladi, katta ekranda esa keragidan ortiq cho\'ziladi.',
      ),
      HeadingBlock('Flutter joyni ota widgetdan oladi'),
      ParaBlock(
        'Flutter layoutida ota widget bolaga qancha joy borligini **constraints** orqali bildiradi. Bola shu chegaralar ichida o\'z o\'lchamini tanlaydi. Shu sabab ekranga moslashda ekranning aniq enini taxmin qilib qotirib qo\'yishdan ko\'ra, mavjud joyga mos keladigan widgetlarni tanlash muhim.',
      ),
      BulletsBlock([
        '`Wrap` — qatorga sig\'magan bolalarni keyingi qatorga o\'tkazadi.',
        '`ConstrainedBox` — bolaga yuqori yoki quyi o\'lcham chegarasini beradi.',
        '`Expanded` — `Row` yoki `Column` ichida qolgan joyni egallaydi.',
        '`LayoutBuilder` — ota bergan aniq constraints bilan turli layout tanlash imkonini beradi.',
      ]),
      CalloutBlock(
        CalloutKind.warning,
        'Ko\'p uchraydigan xato',
        'Har bir kartaga `width: 500` berish telefonda overflow keltirib chiqarishi mumkin. Boshqa tomondan, barcha elementni bitta ulkan `Row` ga tiqish ham muammoni hal qilmaydi. Avval qatorga nechta element sig\'ishi kerakligini o\'ylang.',
      ),
      CalloutBlock(
        CalloutKind.info,
        'Bu darsdagi preview',
        'Quyidagi kod `Wrap` yordamida haqiqiy Flutter widget daraxtini quradi. Preview o\'quv runtime qo\'llaydigan widgetlar bilan ishlaydi; `LayoutBuilder` kabi framework API larini keyingi loyiha muhitida to\'liq Flutter SDK bilan tekshirish kerak.',
      ),
    ],
    analogy: AnalogyBlock(
      'Tokchaga joylash',
      'Kitoblarni tokchaga terayotganda joy tugasa, keyingi qatorga o\'tasiz. `Wrap` ham bolalarni xuddi shunday joylaydi. `ConstrainedBox` esa har bir kitob uchun eng katta ruxsat etilgan enni belgilaydi.',
      icon: Icons.shelves,
    ),
    why: 'Bir xil Flutter ilovasi portret telefonda, planshetda va web oynasida ishlashi mumkin. Responsive layout foydalanuvchining ekraniga qarab elementlarni qayta joylaydi; alohida-alohida uchta ilova yozish shart bo\'lmaydi.',
    where: [
      'Katalog va mahsulot kartalari',
      'Dashboard statistikasi',
      'Planshet va web uchun ko\'p ustunli sahifalar',
    ],
    terms: [
      TermBlock(
        term: 'Responsive layout',
        uz: 'Moslashuvchan joylashuv',
        meaning: 'UI elementlari mavjud ekran joyiga qarab qayta joylashadi.',
        why: 'Bitta ekran tuzilmasi turli o\'lchamlarda o\'qilishi uchun.',
      ),
      TermBlock(
        term: 'Constraint',
        uz: 'O\'lcham chegarasi',
        meaning:
            'Ota widget farzandiga beradigan min/max kenglik va balandlik.',
        why: 'Flutter bolaga qaysi o\'lchamlarda chizilishi mumkinligini bildiradi.',
        example: 'BoxConstraints(maxWidth: 320)',
      ),
      TermBlock(
        term: 'Wrap',
        uz: 'Qatorga o\'rab joylash',
        meaning: 'Bolalarni joy qolmaganda keyingi qatorga tushiradi.',
        why: 'Kichik ekranda overflow bo\'lmasligi uchun.',
        example: 'Wrap(children: cards)',
      ),
    ],
    animation: AnimationBlock(
      'layout_constraints',
      'Ota widget mavjud enni beradi → Wrap bolalarni joylaydi → sig\'magan bola yangi qatorga o\'tadi.',
    ),
    syntax: SyntaxBlock(
      r'''Wrap(
  spacing: 12,
  runSpacing: 12,
  children: kartalar,
)''',
      [
        SyntaxPart(
          'spacing',
          'Bir qatordagi bolalar orasidagi gorizontal masofa',
        ),
        SyntaxPart('runSpacing', 'Keyingi qatorlar orasidagi vertikal masofa'),
        SyntaxPart('children', 'Joylashtiriladigan widgetlar ro\'yxati'),
      ],
    ),
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 220, child: Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Dart'),
            ))),
            SizedBox(width: 220, child: Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Flutter'),
            ))),
          ],
        ),
      ),
    ),
  ));
}''',
      title: 'Qatorga moslashadigan kartalar',
      preview: true,
      explain: {
        'Wrap': 'Joy yetmaganda bolalarni keyingi qatorga o\'tkazadi.',
        'spacing': 'Bir qatordagi kartalar orasidagi masofa.',
        'runSpacing': 'Qatorlar orasidagi masofa.',
        'SizedBox(width: 220)':
            'Kartaga eng ko\'pi bilan 220 logical pixel en beradi.',
      },
    ),
    buggy: BuggyCodeBlock(
      code: r'''Row(
  children: [
    SizedBox(width: 220, child: Card(child: Text('Dart'))),
    SizedBox(width: 220, child: Card(child: Text('Flutter'))),
  ],
)''',
      task: 'Bu `Row` tor telefonda ikkita 220 pixel kartani yonma-yon joylab overflow qilishi mumkin. Elementlar sig\'masa keyingi qatorga o\'tadigan qiling.',
      why: '`Row` bolalarni doim bitta gorizontal qatorga qo\'yadi va o\'zi avtomatik ravishda yangi qator ochmaydi. `Wrap` shu vaziyat uchun mo\'ljallangan.',
      fixed: r'''Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    SizedBox(width: 220, child: Card(child: Text('Dart'))),
    SizedBox(width: 220, child: Card(child: Text('Flutter'))),
  ],
)''',
      hint: 'Bolalarni `Row` o\'rniga qatorga o\'ray oladigan widget qaysi?',
    ),
    task: CodeTask(
      title: 'Moslashuvchan kurs kartalari',
      instructions: 'Ekranga `Dart asoslari` va `Flutter UI` nomli ikkita `Card` chiqaring. Kartalarni `Wrap` ichiga joylang; ular tor ekranda keyingi qatorga o\'ta olsin. Har bir kartaga `SizedBox(width: 220)` va `Padding` ishlating.',
      starter: r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Shu yerga ikkita SizedBox va Card qo'shing.
          ],
        ),
      ),
    ),
  ));
}''',
      checks: [
        WidgetExists('Wrap', label: 'Kartalar moslashuvchan Wrap ichida'),
        WidgetExists('Card', min: 2, label: 'Ikkala mavzu uchun Card'),
        WidgetExists(
          'SizedBox',
          min: 2,
          label: 'Kartalarning eni chegaralangan',
        ),
        WidgetExists('Text', text: 'Dart asoslari', label: 'Dart kartasi'),
        WidgetExists('Text', text: 'Flutter UI', label: 'Flutter kartasi'),
      ],
      hints: [
        'Har bir karta uchun `SizedBox(width: 220, child: Card(...))` yozing.',
        'Card ichida `Padding(padding: EdgeInsets.all(16), child: Text(...))` ishlating.',
        r'''SizedBox(width: 220, child: Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Dart asoslari'),
  ),
))''',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 220, child: Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Dart asoslari'),
            ))),
            SizedBox(width: 220, child: Card(child: Padding(
              padding: EdgeInsets.all(16), child: Text('Flutter UI'),
            ))),
          ],
        ),
      ),
    ),
  ));
}''',
      preview: true,
    ),
    quiz: [
      SingleChoice(
        prompt: '`Row` ga ikki bola sig\'masa, u odatda nima qiladi?',
        options: [
          'Avtomatik yangi qator ochadi',
          'Overflow bo\'lishi mumkin',
          'Ikkinchi bolani yashiradi',
          'Ekranni aylantiradi',
        ],
        correct: 1,
        explanation: '`Row` bolalarni bitta qatorda joylaydi; u avtomatik wrap qilmaydi.',
        topic: 'Row va Wrap',
      ),
      SingleChoice(
        prompt: '`Wrap` qachon bolani keyingi qatorga o\'tkazadi?',
        options: [
          'Har doim',
          'Oldingi bola bosilganda',
          'Joriy qatorga joy yetmaganda',
          'Faqat webda',
        ],
        correct: 2,
        explanation:
            '`Wrap` mavjud joyga qarab qatorlarni avtomatik hosil qiladi.',
        topic: 'Wrap',
      ),
      SingleChoice(
        prompt: 'Flutter layoutda constraints nimani bildiradi?',
        options: [
          'Widget rangini',
          'Bolaga berilgan mumkin bo\'lgan o\'lcham chegaralarini',
          'Animatsiya tezligini',
          'Dart turini',
        ],
        correct: 1,
        explanation:
            'Ota widget farzandiga min/max o\'lcham chegaralarini beradi.',
        topic: 'Constraints',
      ),
    ],
    summary: [
      '`Row` bitta qatorni saqlaydi; `Wrap` joy tugaganda yangi qator ochadi.',
      '`ConstrainedBox` va `SizedBox` o\'lchamlarni chegaralashga yordam beradi.',
      'Responsive UI ni tor va keng oynada ko\'rib tekshiring.',
    ],
    next: 'Keyingi darsda formadagi foydalanuvchi kiritgan qiymatni tekshirib, xatoni maydon yonida ko\'rsatishni o\'rganasiz.',
    revisionTip: 'Ikki kartani avval tor, keyin keng oynada ko\'ring. Qatorlar soni qanday o\'zgarganini ayting.',
    links: [
      DocLink('Flutter: layout', 'https://docs.flutter.dev/ui/layout'),
      DocLink(
        'Flutter: adaptive and responsive design',
        'https://docs.flutter.dev/ui/adaptive-responsive',
      ),
    ],
  ),
  Lesson(
    id: 'l6_form_validation',
    title: 'TextField va forma tekshiruvi',
    subtitle: 'Foydalanuvchi kiritgan qiymatga javob berish',
    icon: Icons.fact_check_outlined,
    minutes: 20,
    xp: 70,
    skills: ['flutter.forms', 'flutter.state'],
    prerequisites: ['StatefulWidget va setState', 'Funksiyalar va shartlar'],
    objectives: [
      '`TextField` orqali matn kiritishni qabul qilasiz',
      '`TextEditingController` bilan maydon qiymatini o\'qiysiz',
      'Bo\'sh qiymatni tekshirib, UI holatini `setState` bilan yangilaysiz',
    ],
    intro: [
      ParaBlock(
        'Ko\'p ilovalarda foydalanuvchi ism, email yoki qidiruv so\'zini kiritadi. `TextField` matn kiritish maydonini ko\'rsatadi. Kiritilgan qiymatni tekshirish esa noto\'g\'ri yoki bo\'sh ma\'lumotni qabul qilmaslikka yordam beradi.',
      ),
      ParaBlock(
        'Bu darsda kichik salomlashuv formasini quramiz. `TextEditingController` maydondagi matnni saqlaydi. Tugma bosilganda `controller.text.trim()` qiymatni olib, chetidagi bo\'sh joylarni olib tashlaydi.',
      ),
      BulletsBlock([
        '`TextField(controller: ...)` — controller ni matn maydoniga ulaydi.',
        '`controller.text` — hozirgi kiritilgan satr.',
        '`.trim().isEmpty` — satr bo\'sh yoki faqat probellardan iboratligini tekshiradi.',
        '`setState` — xabar o\'zgarganini Flutterga bildiradi va ekranni yangilaydi.',
      ]),
      CalloutBlock(
        CalloutKind.warning,
        'Muhim',
        '`TextField` ma\'lumotni o\'zi tekshirmaydi. Tekshirish qoidasini siz yozasiz. Haqiqiy ko\'p maydonli ekranda Flutter `Form` va `TextFormField` ham ishlatiladi; bu preview runtime hozir oddiy `TextField` va holatni o\'rgatadi.',
      ),
    ],
    analogy: AnalogyBlock(
      'Kirishdagi nazorat',
      'Forma — tadbirga kirish ro\'yxatiga o\'xshaydi. Ism yozilgan bo\'lsa, odamni tanib salomlashasiz; maydon bo\'sh bo\'lsa, avval ism so\'raysiz. `if/else` shu qarorni, `setState` esa yangi javobni ekranda ko\'rsatishni bajaradi.',
      icon: Icons.how_to_reg_outlined,
    ),
    why: 'Formalar ro\'yxatdan o\'tish, qidirish, buyurtma va sozlamalarda uchraydi. Kiritilgan qiymatni tekshirish noto\'g\'ri so\'rovlarni kamaytiradi va foydalanuvchiga xatoni qayerda tuzatishni ko\'rsatadi.',
    where: [
      'Ro\'yxatdan o\'tish va kirish',
      'Qidiruv maydonlari',
      'Buyurtma va profil ma\'lumotlari',
    ],
    terms: [
      TermBlock(
        term: 'TextField',
        uz: 'Matn maydoni',
        meaning: 'Foydalanuvchidan matn kiritishni qabul qiladigan widget.',
        why: 'Forma va qidiruv interfeyslari uchun.',
      ),
      TermBlock(
        term: 'Controller',
        uz: 'Boshqaruvchi obyekt',
        meaning: 'Matn maydonining qiymatini o\'qish yoki boshqarish vositasi.',
        why: 'Tugma bosilganda yozilgan qiymatga murojaat qilish uchun.',
        example: 'controller.text',
      ),
      TermBlock(
        term: 'Validation',
        uz: 'Tekshirish',
        meaning: 'Kiritilgan qiymat belgilangan qoidaga mosligini aniqlash.',
        why: 'Bo\'sh yoki noto\'g\'ri ma\'lumotni qabul qilmaslik uchun.',
      ),
    ],
    animation: AnimationBlock(
      'form_validation',
      'Matn kiritiladi → controller qiymatni saqlaydi → tugma tekshiradi → setState natijani ko\'rsatadi.',
    ),
    syntax: SyntaxBlock(
      r'''final controller = TextEditingController();

if (controller.text.trim().isEmpty) {
  setState(() => xabar = 'Ism kiriting');
}''',
      [
        SyntaxPart(
          'TextEditingController()',
          'Matn maydoni qiymatini kuzatadi',
        ),
        SyntaxPart(
          'text.trim()',
          'Kiritilgan matn va chetdagi bo\'sh joylarni oladi',
        ),
        SyntaxPart('isEmpty', 'Satrda belgi yo\'qligini tekshiradi'),
        SyntaxPart('setState', 'O\'zgargan xabarni qayta chizdiradi'),
      ],
    ),
    example: CodeBlock(
      r'''import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SalomForma()));

class SalomForma extends StatefulWidget {
  @override
  State<SalomForma> createState() => _SalomFormaState();
}

class _SalomFormaState extends State<SalomForma> {
  final controller = TextEditingController();
  String xabar = 'Ismingizni kiriting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Ism'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final ism = controller.text.trim();
                if (ism.isEmpty) {
                  xabar = 'Ism bo\'sh bo\'lmasin';
                } else {
                  xabar = 'Salom, $ism!';
                }
              });
            },
            child: Text('Salomlash'),
          ),
          Text(xabar),
        ]),
      ),
    );
  }
}''',
      title: 'Ism so\'raydigan haqiqiy forma',
      preview: true,
      explain: {
        'TextEditingController': 'Matn maydonidagi qiymatni olib beradi.',
        'controller.text.trim()':
            'Kiritilgan ismni chetidagi bo\'sh joylarsiz oladi.',
        'setState':
            'Xabar o\'zgargach Flutterga UI ni qayta qurishni bildiradi.',
      },
    ),
    task: CodeTask(
      title: 'Salomlashuv formasini yig\'ing',
      instructions: '`TextField` va `TextEditingController` ishlating. `Salomlash` tugmasi bosilganda maydon bo\'sh bo\'lsa `Ism bo\'sh bo\'lmasin`, aks holda `Salom, <ism>!` chiqaring. `setState` ichida qiymatni tekshiring.',
      starter: r'''import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SalomForma()));

class SalomForma extends StatefulWidget {
  @override
  State<SalomForma> createState() => _SalomFormaState();
}

class _SalomFormaState extends State<SalomForma> {
  final controller = TextEditingController();
  String xabar = 'Ismingizni kiriting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      // TextField, tugma va natija matnini qo'shing.
    ]));
  }
}''',
      checks: [
        WidgetExists('TextField', label: 'Matn kiritish maydoni'),
        WidgetExists('ElevatedButton', label: 'Salomlash tugmasi'),
        WidgetExists('Text', text: 'Salomlash', label: 'Tugma matni'),
        AfterTap(
          'Salomlash',
          'Ism bo\'sh bo\'lmasin',
          label: 'Bo\'sh ismni tushuntiradi',
        ),
      ],
      hints: [
        '`TextField(controller: controller)` bilan controller ni ulang.',
        'Tugma callback ichida `setState(() { ... })` ishlating.',
        'Bo\'sh bo\'lsa xato xabarini, aks holda ismni salom matniga qo\'shing.',
      ],
      solution: r'''import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SalomForma()));

class SalomForma extends StatefulWidget {
  @override
  State<SalomForma> createState() => _SalomFormaState();
}

class _SalomFormaState extends State<SalomForma> {
  final controller = TextEditingController();
  String xabar = 'Ismingizni kiriting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: EdgeInsets.all(24),
      child: Column(children: [
        TextField(controller: controller,
          decoration: InputDecoration(labelText: 'Ism')),
        ElevatedButton(onPressed: () {
          setState(() {
            final ism = controller.text.trim();
            if (ism.isEmpty) {
              xabar = 'Ism bo\'sh bo\'lmasin';
            } else {
              xabar = 'Salom, $ism!';
            }
          });
        }, child: Text('Salomlash')),
        Text(xabar),
      ]),
    ));
  }
}''',
      preview: true,
    ),
    quiz: [
      SingleChoice(
        prompt: '`TextEditingController` nimaga kerak?',
        options: [
          'Ekran rangini o\'zgartiradi',
          'TextField qiymatini o\'qish va boshqarishga',
          'Sahifani yo\'naltiradi',
          'Dart kodini formatlaydi',
        ],
        correct: 1,
        explanation: 'Controller matn maydonidagi joriy qiymatni beradi.',
        topic: 'TextField',
      ),
      SingleChoice(
        prompt: '`setState` chaqirilmasa, xabar o\'zgarganidan keyin odatda nima bo\'ladi?',
        options: [
          'Flutter avtomatik sezadi',
          'Dart xatolik beradi',
          'Ekranda eski qiymat qolishi mumkin',
          'Ilova yopiladi',
        ],
        correct: 2,
        explanation: 'StatefulWidget ichida holatni yangilab, UI qayta qurilishi uchun setState kerak.',
        topic: 'setState',
      ),
      SingleChoice(
        prompt: '`trim().isEmpty` qaysi qiymatni bo\'sh deb topadi?',
        options: ['`  ` (faqat probel)', '`Dart`', '`Flutter`', 'Hech qachon'],
        correct: 0,
        explanation: '`trim()` chetdagi bo\'sh joylarni olib tashlaydi; bo\'sh qolsa isEmpty true bo\'ladi.',
        topic: 'Validation',
      ),
    ],
    summary: [
      '`TextField` foydalanuvchidan matn oladi, controller uning qiymatini beradi.',
      'Kiritilgan qiymatni tekshiring va xatoni tushunarli xabar bilan ko\'rsating.',
      '`setState` UI ga yangi holatni qayta chizishni bildiradi.',
    ],
    next: 'Keyingi darslarda formani bir nechta maydon, Form va TextFormField bilan kengaytiring.',
    revisionTip: 'Maydonga ism yozib, tugmani bosing. Keyin maydonni bo\'sh qoldirib qayta tekshiring.',
    links: [
      DocLink(
        'Flutter: text input',
        'https://docs.flutter.dev/cookbook/forms/text-input',
      ),
    ],
  ),
];
