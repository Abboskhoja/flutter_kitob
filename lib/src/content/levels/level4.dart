import 'package:flutter/material.dart';

import '../model.dart';

/// 4-daraja, «Asinxron Dart» moduli. Barcha kodlar haqiqiy event loop semantikasi bilan bajariladi
/// (natijalar Dart VM bilan solishtirilgan — packages/kitob_dart/test/conformance/16–21).
const level4AsyncLessons = <Lesson>[
  // ───────────────────────── 4.1 Future ─────────────────────────
  Lesson(
    id: 'l4_future',
    title: 'Future — kelajakdagi qiymat',
    subtitle: 'Vaqt talab qiladigan ishlar',
    icon: Icons.hourglass_top_rounded,
    minutes: 15,
    xp: 60,
    skills: ['dart.future'],
    prerequisites: ['Xatolarni boshqarish: try, catch, throw'],
    objectives: [
      'Sinxron va asinxron kod farqini tushunasiz',
      '`Future<T>` — hali tayyor bo\'lmagan qiymat ekanini bilasiz',
      '`Future.delayed`, `Future.value` va `.then()` bilan ishlaysiz',
    ],
    intro: [
      ParaBlock('Hozirgacha yozgan kodlaringiz **sinxron** edi: har bir qator oldingisi tugagach bajariladi. Lekin ba\'zi ishlar vaqt oladi: serverdan ma\'lumot olish, faylni o\'qish, 2 soniya kutish.'),
      ParaBlock('Agar dastur shunday ishni kutib "qotib qolsa", ilova ekrani ham qotadi — tugmalar bosilmaydi, animatsiya to\'xtaydi. Shuning uchun Dart bunday ishlarni **asinxron** bajaradi: ishni boshlaydi, natijani esa **keyinroq** beradi.'),
      ParaBlock('**`Future<T>`** — "kelajakda `T` turidagi qiymat (yoki xato) bo\'ladi" degan va\'da. Masalan `Future<int>` — keyinroq butun son keladi.'),
      BulletsBlock([
        '`Future.delayed(Duration(seconds: 1), () => 42)` — 1 soniyadan keyin 42 bo\'ladigan Future',
        '`Future.value(5)` — qiymati allaqachon ma\'lum Future',
        '`.then((qiymat) { ... })` — "tayyor bo\'lganda shuni bajar"',
      ]),
      ParaBlock('Muhim: Future qaytaradigan funksiya **darhol** qaytadi. Natija esa kod davom etib bo\'lgandan keyin keladi. Shuning uchun quyidagi misolda `Buyurtma qabul qilindi` birinchi chiqadi.'),
      CalloutBlock(CalloutKind.info, 'Playgroundda vaqt', 'Kod ichidagi kutishlar (`Future.delayed`) haqiqiy Dart\'dagi tartibda bajariladi, lekin soniyalab kutib o\'tirmaysiz: natija darhol chiqadi, `DateTime.now()` esa xuddi vaqt o\'tgandek suriladi.'),
    ],
    analogy: AnalogyBlock(
      'Kafedagi buyurtma cheki',
      'Kafeda osh buyurtma qilsangiz, sizga darhol osh emas, **chek** beriladi. Chek — "oshingiz tayyorlanyapti, tayyor bo\'lsa olasiz" degan va\'da. Siz peshtaxta oldida qotib turmaysiz — joyingizga borib suhbatlashasiz. Osh tayyor bo\'lganda raqamingizni chaqirishadi. **Future** — xuddi shu chek, `.then` esa "chaqirishganda oshni olib kel" degan ko\'rsatma.',
      icon: Icons.receipt_long_rounded,
    ),
    why: 'Mobil va web ilovalar deyarli doim tarmoq, fayl va ma\'lumotlar bazasi bilan ishlaydi. Future bo\'lmasa, har bir so\'rov vaqtida ekran qotib qolardi. Flutter\'dagi `FutureBuilder`, `http.get` va `SharedPreferences.getInstance()` — barchasi Future qaytaradi.',
    where: [
      'Serverdan ma\'lumot yuklash (HTTP so\'rov)',
      'Fayl yoki ma\'lumotlar bazasini o\'qish',
      'Kechiktirilgan amallar: "3 soniyadan keyin xabarni yashir"',
      'Flutter: `FutureBuilder` bilan "Yuklanmoqda..." ekrani',
    ],
    terms: [
      TermBlock(term: 'Synchronous', uz: 'Sinxron', meaning: 'Har bir amal oldingisi tugagach bajariladi.', why: 'Oddiy hisob-kitoblar shunday ishlaydi.'),
      TermBlock(term: 'Asynchronous', uz: 'Asinxron', meaning: 'Ish boshlanadi, natija keyinroq keladi; dastur bu orada boshqa ishni bajaradi.', why: 'Ekran qotmasligi uchun.'),
      TermBlock(term: 'Future', uz: 'Kelajak (va\'da)', meaning: 'Keyinroq qiymat yoki xato bilan tugaydigan obyekt.', why: 'Asinxron natijani ifodalaydi.', example: 'Future<String>'),
      TermBlock(term: 'Callback', uz: 'Qayta chaqiriladigan funksiya', meaning: 'Biror narsa yuz berganda chaqiriladigan funksiya.', why: '`.then(...)` ga callback beriladi.'),
      TermBlock(term: 'Duration', uz: 'Davomiylik', meaning: 'Vaqt oralig\'i: soniya, millisekund...', why: 'Kutish vaqtini berish uchun.', example: 'Duration(milliseconds: 500)'),
    ],
    animation: AnimationBlock('async_await', 'Future qaytgan zahoti dastur davom etadi; natija keyinroq keladi'),
    syntax: SyntaxBlock(r'''Future<int> f = Future.delayed(
  Duration(seconds: 1),
  () => 42,
);
f.then((qiymat) => print(qiymat));''', [
      SyntaxPart('Future<int>', 'kelajakda int beradigan obyekt'),
      SyntaxPart('Future.delayed(...)', 'berilgan vaqtdan keyin funksiya natijasi bilan tugaydi'),
      SyntaxPart('() => 42', 'vaqt o\'tgach bajariladigan funksiya'),
      SyntaxPart('.then(...)', 'qiymat tayyor bo\'lganda chaqiriladigan callback'),
    ]),
    example: CodeBlock(
      r'''Future<String> oshTayyorla() {
  return Future.delayed(Duration(seconds: 3), () => 'Osh tayyor!');
}

void main() {
  print('Buyurtma berildi');
  final chek = oshTayyorla();
  print('Buyurtma qabul qilindi');
  chek.then((natija) {
    print(natija);
  });
  print('Kutib turibmiz...');
  Future.value(5).then((son) => print('Tayyor son: $son'));
}''',
      title: 'Future va then',
      explain: {
        'Future<String>': 'Funksiya kelajakda String beradi.',
        'Future.delayed': '3 soniyadan keyin natija beradigan Future.',
        'chek.then': 'Natija tayyor bo\'lganda callback chaqiriladi.',
        'Future.value(5)': 'Allaqachon tayyor qiymat — lekin then baribir keyinroq ishlaydi.',
      },
      lineNotes: {
        7: 'Bu yerda dastur kutmaydi: Future darhol qaytadi.',
        8: 'Shuning uchun bu qator osh tayyor bo\'lishidan oldin chiqadi.',
      },
      expectedOutput: 'Buyurtma berildi\nBuyurtma qabul qilindi\nKutib turibmiz...\nTayyor son: 5\nOsh tayyor!\n',
    ),
    extra: [
      CalloutBlock(CalloutKind.why, 'Nega "Tayyor son" oshdan oldin chiqdi?', '`Future.value(5)` tayyor, lekin uning `.then` callback\'i joriy kod (`main`) tugagach, navbat bilan ishlaydi. Osh esa 3 soniya kutadi. Bu tartib keyingi darslardagi **event loop** mavzusida batafsil tushuntiriladi.'),
      CodeBlock(
        r'''Future<int> narxHisobla(int dona) {
  return Future.delayed(Duration(milliseconds: 500), () => dona * 12000);
}

void main() {
  narxHisobla(3)
      .then((narx) => narx + 2000)
      .then((jami) => print("Jami: $jami so'm"));
  print('Hisoblanmoqda...');
}''',
        title: 'then zanjiri',
        explain: {'.then((narx) => narx + 2000)': 'then qaytargan qiymat keyingi then\'ga o\'tadi.'},
        expectedOutput: "Hisoblanmoqda...\nJami: 38000 so'm\n",
      ),
    ],
    buggy: BuggyCodeBlock(
      code: r'''Future<int> ballOl() {
  return Future.delayed(Duration(seconds: 1), () => 95);
}

void main() {
  final ball = ballOl();
  print('Ball: $ball');
}''',
      task: 'Ishga tushiring: `Ball: 95` o\'rniga `Instance of \'Future<int>\'` chiqadi. Natija tayyor bo\'lganda `Ball: 95` chiqadigan qiling.',
      why: '`ballOl()` qiymatni emas, **Future**ni (va\'dani) qaytaradi. Uni chop etsangiz, "bu Future obyekti" degan yozuv chiqadi. Qiymatni olish uchun `.then(...)` (yoki keyingi darsdagi `await`) kerak.',
      fixed: r'''Future<int> ballOl() {
  return Future.delayed(Duration(seconds: 1), () => 95);
}

void main() {
  ballOl().then((ball) {
    print('Ball: $ball');
  });
}''',
    ),
    task: CodeTask(
      title: 'Kechikkan ikki barobar',
      instructions: '`Future<int> ikkiBarobar(int n)` funksiyasini yozing: u **200 millisekunddan keyin** `n * 2` qiymatini bersin (`Future.delayed` bilan).\n`main` ichida `ikkiBarobar(21)` natijasini `.then` orqali `Natija: 42` ko\'rinishida chiqaring.',
      starter: r'''Future<int> ikkiBarobar(int n) {
  // Future.delayed bilan yozing
  return Future.value(0);
}

void main() {
  print('Natija: ${ikkiBarobar(21)}');
}''',
      checks: [
        OutputEquals('Natija: 42\n', label: 'main natijasi'),
        EvaluatesTo('await ikkiBarobar(5)', '10', label: '`ikkiBarobar(5)` → 10'),
        EvaluatesTo('await ikkiBarobar(-7)', '-14', hidden: true),
        UsesConstruct(r'Future\.delayed', '`Future.delayed` ishlatilishi kerak'),
        UsesConstruct(r'\.then\s*\(', '`.then` ishlatilishi kerak'),
      ],
      hints: [
        'return Future.delayed(Duration(milliseconds: 200), () => n * 2);',
        "main ichida: ikkiBarobar(21).then((v) => print('Natija: \$v'));",
        r'''Future<int> ikkiBarobar(int n) {
  return Future.delayed(Duration(milliseconds: 200), () => n * 2);
}

void main() {
  ikkiBarobar(21).then((v) => print('Natija: $v'));
}''',
      ],
      solution: r'''Future<int> ikkiBarobar(int n) {
  return Future.delayed(Duration(milliseconds: 200), () => n * 2);
}

void main() {
  ikkiBarobar(21).then((v) => print('Natija: $v'));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija qanday tartibda chiqadi?',
        code: r'''void main() {
  Future.delayed(Duration(seconds: 1), () => print('B'));
  print('A');
}''',
        options: ['A\nB', 'B\nA', 'A', 'B'],
        explanation: 'Future.delayed darhol qaytadi, shuning uchun avval A chiqadi; 1 soniyadan keyin B.',
        topic: 'Future',
      ),
      SingleChoice(
        prompt: '`Future<String>` nimani bildiradi?',
        options: ['Hozirning o\'zida tayyor matn', 'Kelajakda matn (yoki xato) beradigan obyekt', 'Matnlar ro\'yxati', 'Faqat xato'],
        correct: 1,
        explanation: 'Future — va\'da: keyinroq String qiymat yoki xato bilan tugaydi.',
        topic: 'Future',
      ),
      TrueFalse(
        prompt: 'Future qaytaradigan funksiya chaqirilganda dastur natija tayyor bo\'lguncha shu qatorda to\'xtab turadi.',
        answer: false,
        explanation: 'Yo\'q — Future darhol qaytadi va kod davom etadi. Kutish uchun then yoki await kerak.',
        topic: 'Future',
      ),
    ],
    summary: [
      'Asinxron ish: boshlanadi, natija keyinroq keladi — ekran qotmaydi',
      'Future<T> — kelajakdagi qiymat yoki xato',
      'Future.delayed, Future.value — Future yaratish usullari',
      '.then(callback) — natija tayyor bo\'lganda bajariladi; then zanjir qilinishi mumkin',
    ],
    next: 'Keyingi darsda `async` va `await` bilan asinxron kodni xuddi oddiy kod kabi tushunarli yozamiz.',
    revisionTip: 'Uchta turli kechikishli Future yarating va qaysi tartibda chiqishini avval qog\'ozda taxmin qiling, keyin ishga tushirib tekshiring.',
    links: [DocLink('Asynchronous programming', 'https://dart.dev/libraries/async/async-await')],
  ),

  // ───────────────────────── 4.2 async / await ─────────────────────────
  Lesson(
    id: 'l4_async_await',
    title: 'async va await',
    subtitle: 'Asinxron kodni oddiy koddek yozish',
    icon: Icons.schedule_rounded,
    minutes: 16,
    xp: 70,
    skills: ['dart.async_await'],
    prerequisites: ['Future — kelajakdagi qiymat'],
    objectives: [
      '`async` funksiya va `await` ifodasini yozasiz',
      '`await` funksiyani to\'xtatib turishini, lekin dasturni qotirmasligini tushunasiz',
      'Ketma-ket va parallel (`Future.wait`) kutishni farqlaysiz',
    ],
    intro: [
      ParaBlock('`.then` zanjirlari uzaygani sari o\'qish qiyinlashadi. Dart\'da buning chiroyli yechimi bor: **`async`** va **`await`**.'),
      BulletsBlock([
        'Funksiya tanasidan oldin `async` yoziladi: `Future<int> f() async { ... }`',
        'Bunday funksiya ichida `await future` — "shu Future tugaguncha **shu funksiyani** to\'xtat, natijani menga ber"',
        '`async` funksiya `return 5;` qilsa, chaqiruvchi `Future<int>` oladi',
      ]),
      ParaBlock('`await` **butun dasturni** to\'xtatmaydi — faqat o\'zi turgan funksiyani. Bu orada Dart boshqa ishlarni (masalan, ekranni chizish, tugma bosilishini) bajaradi.'),
      ParaBlock('Bir nechta mustaqil ish bo\'lsa, ularni birma-bir kutish shart emas: `await Future.wait([a(), b()])` — ikkalasi **bir vaqtda** kutiladi.'),
      CalloutBlock(CalloutKind.warning, 'Eng ko\'p uchraydigan xato', '`await` faqat `async` belgilangan funksiya ichida ishlaydi. `main` ichida await kerak bo\'lsa: `Future<void> main() async { ... }`.'),
    ],
    analogy: AnalogyBlock(
      'Kir yuvish mashinasi',
      'Siz mashinaga kir solib, tugmani bosasiz (Future boshlandi). `await` — "kir yuvilib bo\'lguncha **men** bu ishni davom ettirmayman". Lekin uy to\'xtab qolmaydi: bu orada boshqalar ovqat pishiradi, televizor ishlaydi. Mashina tugagach, siz kirni olib, keyingi qadamga (dazmollash) o\'tasiz.',
      icon: Icons.local_laundry_service_rounded,
    ),
    why: 'Professional Dart va Flutter kodining katta qismi `async/await` bilan yoziladi: API chaqiruvlari, ma\'lumotlar bazasi, fayllar. U asinxron mantiqni yuqoridan pastga o\'qiladigan oddiy kodga aylantiradi va xatolarni odatiy `try/catch` bilan ushlash imkonini beradi.',
    where: [
      'Login: `final user = await api.login(email, parol);`',
      'Ekran ochilganda ma\'lumot yuklash',
      'Bir nechta so\'rovni parallel yuborish: `Future.wait`',
      'Flutter `onPressed: () async { ... }`',
    ],
    terms: [
      TermBlock(term: 'async', uz: 'Asinxron funksiya belgisi', meaning: 'Funksiya ichida await ishlatish mumkinligini va u Future qaytarishini bildiradi.', why: 'await faqat shunday funksiyada ishlaydi.'),
      TermBlock(term: 'await', uz: 'Kutish', meaning: 'Future tugaguncha joriy funksiyani to\'xtatib, natijani qaytaradi.', why: 'then zanjirisiz tushunarli kod.'),
      TermBlock(term: 'Future.wait', uz: 'Hammasini kutish', meaning: 'Bir nechta Future\'ni bir vaqtda kutadi va natijalar ro\'yxatini beradi.', why: 'Mustaqil ishlarni tezroq bajarish.'),
      TermBlock(term: 'Suspend', uz: 'To\'xtatib turish', meaning: 'Funksiya await nuqtasida "uxlaydi" va keyin shu joydan davom etadi.', why: 'Dastur qotmaydi.'),
    ],
    animation: AnimationBlock('async_await', 'await faqat o\'z funksiyasini to\'xtatadi — main va boshqa ishlar davom etadi'),
    syntax: SyntaxBlock(r'''Future<String> yukla() async {
  final javob = await serverdan();
  return 'Natija: $javob';
}''', [
      SyntaxPart('Future<String>', 'async funksiya doim Future qaytaradi'),
      SyntaxPart('async', 'tana oldidan yoziladi'),
      SyntaxPart('await serverdan()', 'Future tugashini kutib, ichidagi qiymatni oladi'),
      SyntaxPart("return 'Natija...'", 'oddiy qiymat qaytariladi — Dart uni Future ichiga o\'raydi'),
    ]),
    example: CodeBlock(
      r'''Future<String> foydalanuvchiOl(int id) async {
  await Future.delayed(Duration(seconds: 1));
  return 'Aziza';
}

Future<int> ballOl(String ism) async {
  await Future.delayed(Duration(seconds: 2));
  return ism.length * 20;
}

Future<void> main() async {
  print('Yuklanmoqda...');
  final ism = await foydalanuvchiOl(7);
  print('Foydalanuvchi: $ism');
  final ball = await ballOl(ism);
  print('Ball: $ball');

  final boshi = DateTime.now();
  final natijalar = await Future.wait([ballOl('Ali'), ballOl('Vali')]);
  final ketdi = DateTime.now().difference(boshi).inSeconds;
  print('Parallel: $natijalar, $ketdi soniyada');
}''',
      title: 'async/await va Future.wait',
      explain: {
        'async': 'Funksiya ichida await ishlatish mumkin.',
        'await foydalanuvchiOl(7)': 'Natija kelguncha main shu yerda kutadi.',
        'Future<void> main() async': 'main ham asinxron bo\'lishi mumkin.',
        'Future.wait': 'Ikkala so\'rov bir vaqtda kutiladi: 2 + 2 emas, 2 soniya.',
      },
      lineNotes: {13: 'await natijani (String) qaytaradi, Future emas.', 20: 'Virtual vaqt bo\'yicha 2 soniya o\'tdi.'},
      expectedOutput: 'Yuklanmoqda...\nFoydalanuvchi: Aziza\nBall: 100\nParallel: [60, 80], 2 soniyada\n',
      visualize: true,
    ),
    extra: [
      CompareBlock(
        leftTitle: '.then bilan',
        left: r'''ismOl().then((ism) {
  return ballOl(ism);
}).then((ball) {
  print(ball);
});''',
        rightTitle: 'async/await bilan',
        right: r'''final ism = await ismOl();
final ball = await ballOl(ism);
print(ball);''',
        note: 'Ikkalasi bir xil ishlaydi. await varianti yuqoridan pastga oddiy kod kabi o\'qiladi.',
      ),
      CodeBlock(
        r'''Future<void> ish(String nom, int ms) async {
  print('$nom boshlandi');
  await Future.delayed(Duration(milliseconds: ms));
  print('$nom tugadi');
}

Future<void> main() async {
  await Future.wait([ish('Rasm', 300), ish('Matn', 100)]);
  print('Hammasi tayyor');
}''',
        title: 'Parallel ishlar qaysi tartibda tugaydi?',
        explain: {'Future.wait': 'Ikkalasi bir vaqtda boshlanadi; qisqasi oldin tugaydi.'},
        expectedOutput: 'Rasm boshlandi\nMatn boshlandi\nMatn tugadi\nRasm tugadi\nHammasi tayyor\n',
      ),
    ],
    buggy: BuggyCodeBlock(
      code: r'''Future<int> narx() async {
  await Future.delayed(Duration(milliseconds: 300));
  return 25000;
}

Future<void> main() async {
  final n = narx();
  print('Narx: $n');
}''',
      task: 'Natija `Narx: 25000` bo\'lishi kerak, lekin `Instance of \'Future<int>\'` chiqyapti. Bitta so\'z qo\'shib tuzating.',
      why: '`narx()` Future qaytaradi. Qiymatni olish uchun uni `await` bilan kutish kerak: `final n = await narx();`. main allaqachon `async`, shuning uchun await ishlatsa bo\'ladi.',
      fixed: r'''Future<int> narx() async {
  await Future.delayed(Duration(milliseconds: 300));
  return 25000;
}

Future<void> main() async {
  final n = await narx();
  print('Narx: $n');
}''',
    ),
    task: CodeTask(
      title: 'Profil kartasi',
      instructions: 'Quyida "serverdan" ism va yosh beradigan ikki funksiya berilgan. `Future<String> profil(int id) async` funksiyasini yozing: u ikkalasini **await** bilan olib, `"Ism, yosh yosh"` matnini qaytarsin.\nMasalan `await profil(1)` → `Ali, 20 yosh`.\n`main` esa `profil(2)` natijasini chiqarsin.',
      starter: r'''Future<String> ismOl(int id) async {
  await Future.delayed(Duration(milliseconds: 100));
  return id == 1 ? 'Ali' : 'Madina';
}

Future<int> yoshOl(int id) async {
  await Future.delayed(Duration(milliseconds: 50));
  return id == 1 ? 20 : 17;
}

Future<String> profil(int id) async {
  return '';
}

Future<void> main() async {
  print(await profil(2));
}''',
      checks: [
        OutputEquals('Madina, 17 yosh\n', label: 'main natijasi'),
        EvaluatesTo('await profil(1)', 'Ali, 20 yosh', label: '`profil(1)` → Ali, 20 yosh'),
        EvaluatesTo('await profil(3)', 'Madina, 17 yosh', hidden: true),
        UsesConstruct(r'await\s+ismOl', '`ismOl` natijasi `await` bilan olinishi kerak'),
        UsesConstruct(r'await\s+yoshOl', '`yoshOl` natijasi `await` bilan olinishi kerak'),
      ],
      hints: [
        'final ism = await ismOl(id);',
        'final yosh = await yoshOl(id);',
        r"return '$ism, $yosh yosh';",
      ],
      solution: r'''Future<String> ismOl(int id) async {
  await Future.delayed(Duration(milliseconds: 100));
  return id == 1 ? 'Ali' : 'Madina';
}

Future<int> yoshOl(int id) async {
  await Future.delayed(Duration(milliseconds: 50));
  return id == 1 ? 20 : 17;
}

Future<String> profil(int id) async {
  final ism = await ismOl(id);
  final yosh = await yoshOl(id);
  return '$ism, $yosh yosh';
}

Future<void> main() async {
  print(await profil(2));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''Future<void> salom() async {
  print('2');
  await Future.delayed(Duration(seconds: 1));
  print('4');
}

void main() {
  print('1');
  salom();
  print('3');
}''',
        options: ['1\n2\n3\n4', '1\n2\n4\n3', '1\n3\n2\n4', '2\n1\n3\n4'],
        explanation: 'salom() ichidagi kod birinchi await gacha darhol bajariladi (2). await joyida salom to\'xtaydi, main davom etadi (3). 1 soniyadan keyin salom davom etadi (4).',
        topic: 'await',
      ),
      SingleChoice(
        prompt: '`await` qaerda ishlatilishi mumkin?',
        options: ['Istalgan funksiyada', 'Faqat `async` belgilangan funksiyada', 'Faqat class ichida', 'Faqat main ichida'],
        correct: 1,
        explanation: 'await faqat async (yoki async*) funksiya ichida ishlaydi; aks holda analyzer xato beradi.',
        topic: 'async',
      ),
      SingleChoice(
        prompt: 'Uchta mustaqil so\'rov har biri 2 soniya oladi. Eng tez usul qaysi?',
        options: ['Uchtasini ketma-ket await qilish', '`await Future.wait([a(), b(), c()])`', 'Har birini alohida main\'da chaqirish', 'Farqi yo\'q'],
        correct: 1,
        explanation: 'Future.wait ularni bir vaqtda kutadi: taxminan 2 soniya. Ketma-ket — 6 soniya.',
        topic: 'Future.wait',
      ),
    ],
    summary: [
      'async funksiya doim Future qaytaradi',
      'await — Future tugaguncha faqat joriy funksiyani to\'xtatadi',
      'await faqat async funksiya ichida: Future<void> main() async',
      'Mustaqil ishlar uchun Future.wait — parallel kutish',
    ],
    next: 'Server har doim ham javob beravermaydi. Keyingi darsda asinxron xatolarni ushlash va timeout bilan ishlashni o\'rganamiz.',
    revisionTip: 'Oldingi darsdagi `.then` zanjirli misolni async/await bilan qayta yozing va natija bir xil ekanini tekshiring.',
    links: [DocLink('async and await', 'https://dart.dev/libraries/async/async-await')],
  ),

  // ───────────────────────── 4.3 Asinxron xatolar ─────────────────────────
  Lesson(
    id: 'l4_async_errors',
    title: 'Asinxron xatolar va timeout',
    subtitle: 'Server javob bermasa nima bo\'ladi?',
    icon: Icons.cloud_off_rounded,
    minutes: 15,
    xp: 70,
    skills: ['dart.async_errors'],
    prerequisites: ['async va await'],
    objectives: [
      'async funksiyadagi xatoni `try/catch` bilan ushlaysiz',
      '`catchError`, `whenComplete` va `finally` farqini bilasiz',
      '`timeout` bilan cheksiz kutishning oldini olasiz',
    ],
    intro: [
      ParaBlock('Asinxron ishlar ko\'pincha tashqi dunyo bilan bog\'liq: internet uziladi, server xato qaytaradi, javob juda kech keladi. Bunday holatda Future **xato bilan** tugaydi.'),
      ParaBlock('`await` qilingan Future xato bilan tugasa, xato xuddi oddiy `throw` kabi shu qatordan "otilib chiqadi". Demak uni tanish **`try / catch / finally`** bilan ushlaymiz.'),
      BulletsBlock([
        '`try { await yukla(); } catch (e) { ... }` — eng tushunarli usul',
        '`yukla().catchError((e) => ...)` — then uslubidagi ekvivalent',
        '`finally` / `whenComplete` — muvaffaqiyat yoki xatodan qat\'i nazar bajariladi (masalan, "Yuklanmoqda" belgisini o\'chirish)',
        '`future.timeout(Duration(seconds: 5))` — 5 soniyada javob bo\'lmasa `TimeoutException` (u `dart:async` kutubxonasida)',
      ]),
      CalloutBlock(CalloutKind.warning, 'Ushlanmagan asinxron xato', 'Agar Future xato bilan tugasa va uni hech kim kutmasa yoki ushlamasa, Dart dasturni "Unhandled exception" bilan to\'xtatadi. Playground ham xuddi shunday qiladi.'),
    ],
    analogy: AnalogyBlock(
      'Pochta kuryeri',
      'Siz kuryer orqali hujjat jo\'natdingiz (Future). Ba\'zan kuryer manzilni topolmay qaytadi (xato). `catch` — "qaytsa, menga xabar qil, boshqa yo\'l topaman". `timeout` — "agar 1 soatda yetkazmasa, buyurtmani bekor qil". `finally` — natija qanday bo\'lmasin, oxirida kvitansiyani arxivga qo\'yish.',
      icon: Icons.local_shipping_rounded,
    ),
    why: 'Foydalanuvchi uchun "ilova qotib qoldi" yoki "ilova yopilib ketdi" eng yomon tajriba. To\'g\'ri xato boshqaruvi bilan ilova "Internet yo\'q. Qayta urinish" tugmasini ko\'rsatadi. Bu professional ilovaning majburiy talabi.',
    where: [
      'API so\'rovi muvaffaqiyatsiz bo\'lganda xabar ko\'rsatish',
      'Juda sekin server uchun timeout',
      'Yuklanish indikatorini finally\'da o\'chirish',
      'Qayta urinish (retry) mantiqi',
    ],
    terms: [
      TermBlock(term: 'catchError', uz: 'Xatoni ushlash (then uslubi)', meaning: 'Future xato bilan tugasa chaqiriladigan callback.', why: 'then zanjirida xatoni ushlash.'),
      TermBlock(term: 'whenComplete', uz: 'Tugaganda', meaning: 'Natija qanday bo\'lishidan qat\'i nazar chaqiriladi.', why: 'finally\'ning then uslubidagi ekvivalenti.'),
      TermBlock(term: 'timeout', uz: 'Vaqt chegarasi', meaning: 'Future belgilangan vaqtda tugamasa xato (yoki onTimeout qiymati).', why: 'Cheksiz kutmaslik uchun.'),
      TermBlock(term: 'TimeoutException', uz: 'Vaqt tugashi xatosi', meaning: 'timeout oshib ketganda tashlanadigan xato (dart:async).', why: 'Uni alohida ushlash mumkin.'),
      TermBlock(term: 'Retry', uz: 'Qayta urinish', meaning: 'Xato bo\'lsa amalni yana bir necha marta takrorlash.', why: 'Vaqtinchalik tarmoq uzilishlari uchun.'),
    ],
    example: CodeBlock(
      r'''import 'dart:async';

Future<String> serverdan(int id) async {
  await Future.delayed(Duration(milliseconds: 300));
  if (id <= 0) throw FormatException("Noto'g'ri id: $id");
  return 'Mahsulot #$id';
}

Future<String> sekinServer() =>
    Future.delayed(Duration(seconds: 10), () => 'kech javob');

Future<void> main() async {
  try {
    print(await serverdan(5));
    print(await serverdan(-1));
    print('Bu qator bajarilmaydi');
  } on FormatException catch (e) {
    print('Xato: ${e.message}');
  } finally {
    print('Yuklanish belgisi yashirildi');
  }

  final javob = await serverdan(0).catchError((e) => 'Zaxira mahsulot');
  print(javob);

  try {
    await sekinServer().timeout(Duration(seconds: 2));
  } on TimeoutException {
    print('Server 2 soniyada javob bermadi');
  }
}''',
      title: 'try/catch, catchError va timeout',
      explain: {
        "import 'dart:async'": 'TimeoutException shu kutubxonada.',
        'throw FormatException': 'async funksiyadagi throw Future\'ni xato bilan tugatadi.',
        'on FormatException catch (e)': 'await qilingan Future xatosi shu yerda ushlanadi.',
        'catchError': 'then uslubida xatoni zaxira qiymat bilan almashtirish.',
        '.timeout': '2 soniyada tugamasa TimeoutException.',
      },
      lineNotes: {15: 'Shu yerda xato otiladi — keyingi qator o\'tkazib yuboriladi.'},
      expectedOutput: "Mahsulot #5\nXato: Noto'g'ri id: -1\nYuklanish belgisi yashirildi\nZaxira mahsulot\nServer 2 soniyada javob bermadi\n",
    ),
    extra: [
      CodeBlock(
        r'''Future<String> beqarorServer(int urinish) async {
  await Future.delayed(Duration(milliseconds: 100));
  if (urinish < 3) throw Exception('tarmoq uzildi');
  return 'Ma\'lumot keldi';
}

Future<String> qaytaUrin() async {
  for (var i = 1; i <= 5; i++) {
    try {
      final javob = await beqarorServer(i);
      print('$i-urinish: muvaffaqiyat');
      return javob;
    } catch (e) {
      print('$i-urinish: $e');
    }
  }
  return 'Barcha urinishlar muvaffaqiyatsiz';
}

Future<void> main() async {
  print(await qaytaUrin());
}''',
        title: 'Retry — qayta urinish',
        explain: {'for (var i = 1; i <= 5; i++)': 'Ko\'pi bilan 5 marta urinamiz.', 'return javob;': 'Muvaffaqiyatli bo\'lsa sikldan chiqamiz.'},
        expectedOutput: "1-urinish: Exception: tarmoq uzildi\n2-urinish: Exception: tarmoq uzildi\n3-urinish: muvaffaqiyat\nMa'lumot keldi\n",
      ),
    ],
    buggy: BuggyCodeBlock(
      code: r'''Future<int> balansOl() async {
  await Future.delayed(Duration(milliseconds: 200));
  throw Exception('server ishlamayapti');
}

Future<void> main() async {
  final b = await balansOl();
  print('Balans: $b');
  print('Ilova ishlashda davom etadi');
}''',
      task: 'Server xato qaytaradi va dastur qulaydi. Xatoni ushlab `Balansni olib bo\'lmadi` chiqaring, so\'ng `Ilova ishlashda davom etadi` ham chiqsin.',
      why: 'await qilingan Future xato bilan tugadi — xato `await` qatoridan otiladi. Uni ushlash uchun shu qatorni `try { ... } catch (e) { ... }` ichiga olish kerak.',
      fixed: r'''Future<int> balansOl() async {
  await Future.delayed(Duration(milliseconds: 200));
  throw Exception('server ishlamayapti');
}

Future<void> main() async {
  try {
    final b = await balansOl();
    print('Balans: $b');
  } catch (e) {
    print("Balansni olib bo'lmadi");
  }
  print('Ilova ishlashda davom etadi');
}''',
    ),
    task: CodeTask(
      title: 'Xavfsiz yuklash',
      instructions: '`serverdan(int id)` berilgan: `id` manfiy bo\'lsa xato tashlaydi. `Future<String> xavfsizYukla(int id) async` yozing:\n• muvaffaqiyatli bo\'lsa — server javobini qaytarsin;\n• xato bo\'lsa — `Xato: yuklab bo\'lmadi` qaytarsin.\nXatoni `try/catch` bilan ushlang.',
      starter: r'''Future<String> serverdan(int id) async {
  await Future.delayed(Duration(milliseconds: 100));
  if (id < 0) throw Exception('topilmadi');
  return 'Buyurtma #$id';
}

Future<String> xavfsizYukla(int id) async {
  return await serverdan(id);
}

Future<void> main() async {
  print(await xavfsizYukla(12));
  print(await xavfsizYukla(-3));
}''',
      checks: [
        OutputEquals("Buyurtma #12\nXato: yuklab bo'lmadi\n", label: 'main natijasi'),
        EvaluatesTo('await xavfsizYukla(7)', 'Buyurtma #7', hidden: true),
        EvaluatesTo('await xavfsizYukla(-1)', "Xato: yuklab bo'lmadi", hidden: true),
        UsesConstruct(r'catch', '`catch` ishlatilishi kerak'),
      ],
      hints: [
        'try { return await serverdan(id); } ...',
        "catch (e) { return \"Xato: yuklab bo'lmadi\"; }",
        r'''Future<String> xavfsizYukla(int id) async {
  try {
    return await serverdan(id);
  } catch (e) {
    return "Xato: yuklab bo'lmadi";
  }
}''',
      ],
      solution: r'''Future<String> serverdan(int id) async {
  await Future.delayed(Duration(milliseconds: 100));
  if (id < 0) throw Exception('topilmadi');
  return 'Buyurtma #$id';
}

Future<String> xavfsizYukla(int id) async {
  try {
    return await serverdan(id);
  } catch (e) {
    return "Xato: yuklab bo'lmadi";
  }
}

Future<void> main() async {
  print(await xavfsizYukla(12));
  print(await xavfsizYukla(-3));
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''Future<void> f() async {
  await Future.delayed(Duration(milliseconds: 10));
  throw Exception('X');
}

Future<void> main() async {
  try {
    await f();
    print('A');
  } catch (e) {
    print('B');
  } finally {
    print('C');
  }
}''',
        options: ['A\nC', 'B\nC', 'A\nB\nC', 'C'],
        explanation: 'f() xato bilan tugaydi → await qatoridan xato otiladi → A o\'tkazib yuboriladi → catch (B) → finally (C).',
        topic: 'async try-catch',
      ),
      SingleChoice(
        prompt: '`future.timeout(Duration(seconds: 3))` nima qiladi?',
        options: [
          'Future\'ni 3 soniya kechiktiradi',
          '3 soniyada tugamasa TimeoutException bilan tugaydi',
          'Future\'ni 3 marta takrorlaydi',
          'Hech narsa',
        ],
        correct: 1,
        explanation: 'timeout — vaqt chegarasi. onTimeout berilsa, xato o\'rniga shu qiymat qaytadi.',
        topic: 'timeout',
      ),
      MatchPairs(
        prompt: 'Moslang',
        pairs: [
          ('try/catch', 'await bilan xatoni ushlash'),
          ('catchError', 'then uslubida xatoni ushlash'),
          ('finally', 'har doim bajariladigan blok'),
          ('timeout', 'kutish vaqtini cheklash'),
        ],
        explanation: 'Ular birgalikda ishonchli asinxron kod yozishga yordam beradi.',
        topic: 'async errors',
      ),
    ],
    summary: [
      'Xato bilan tugagan Future await qatorida xato otadi',
      'try/catch/finally — async kodda ham ishlaydi',
      'catchError / whenComplete — then uslubidagi ekvivalentlar',
      'timeout + TimeoutException — cheksiz kutishdan himoya',
    ],
    next: 'Kodlar qaysi tartibda bajarilishini aniq bilish uchun keyingi darsda Dart\'ning yuragi — event loop bilan tanishamiz.',
    revisionTip: 'Retry misolini o\'zgartiring: har urinishdan oldin kutish vaqtini ikki barobar oshiring (100, 200, 400 ms) — bu "exponential backoff" deyiladi.',
    links: [DocLink('Futures and error handling', 'https://dart.dev/libraries/async/futures-error-handling')],
  ),

  // ───────────────────────── 4.4 Event loop ─────────────────────────
  Lesson(
    id: 'l4_event_loop',
    title: 'Event loop: microtask va event navbati',
    subtitle: 'Kod aynan qaysi tartibda bajariladi?',
    icon: Icons.loop_rounded,
    minutes: 18,
    xp: 80,
    skills: ['dart.event_loop'],
    prerequisites: ['Asinxron xatolar va timeout'],
    objectives: [
      'Dart bitta oqimda (thread) ishlashini va event loop vazifasini tushuntirasiz',
      'Microtask navbati va event (timer) navbati farqini bilasiz',
      'Asinxron kod chiqish tartibini oldindan to\'g\'ri aytasiz',
    ],
    intro: [
      ParaBlock('Dart kodingiz **bitta oqimda** bajariladi: bir vaqtda faqat bitta ish. Asinxronlik esa **event loop** (hodisalar sikli) orqali ishlaydi.'),
      ParaBlock('Event loop qoidasi oddiy:'),
      BulletsBlock([
        '1. Avval joriy sinxron kod oxirigacha bajariladi (`main` tanasi).',
        '2. So\'ng **microtask navbati** to\'liq bo\'shatiladi: `scheduleMicrotask`, `Future.microtask`, tayyor Future\'larning `then`/`await` davomi.',
        '3. Keyin **event navbatidan** bitta vazifa olinadi: `Future(() {...})`, `Future.delayed`, `Timer`, kiritish hodisalari.',
        '4. Har bir event\'dan keyin yana microtask\'lar bo\'shatiladi, va hokazo — navbatlar bo\'shaguncha.',
      ], ordered: false),
      ParaBlock('Shuning uchun `Future.delayed(Duration.zero, ...)` ham "hozir" emas — u joriy kod va barcha microtask\'lardan **keyin** ishlaydi.'),
      CalloutBlock(CalloutKind.tip, 'Professional maslahat', 'Ko\'p hollarda aniq tartibga bog\'liq kod yozmang — `await` bilan ketma-ketlikni aniq ko\'rsating. Event loop\'ni bilish esa "nega bu oldin chiqdi?" degan xatolarni tez topishga yordam beradi.'),
    ],
    analogy: AnalogyBlock(
      'Bitta oshpaz va ikki navbat',
      'Oshxonada **bitta** oshpaz bor (bitta oqim). U qo\'lidagi taomni tugatmaguncha boshqasiga o\'tmaydi. Ikkita qog\'oz bor: **shoshilinch** (microtask) va **oddiy** (event). Oshpaz har safar qo\'li bo\'shaganda avval shoshilinch ro\'yxatdagi hamma ishni bajaradi, keyin oddiy ro\'yxatdan bittasini oladi, so\'ng yana shoshilinchlarni tekshiradi.',
      icon: Icons.soup_kitchen_rounded,
    ),
    why: 'Flutter\'da `setState`, animatsiya kadrlari, tugma bosilishi — hammasi event loop orqali ishlaydi. Uzoq sinxron hisob-kitob event loop\'ni band qiladi va ekran "qotadi" (jank). Buni tushunish performance va to\'g\'ri asinxron dizaynning asosi.',
    where: [
      'Nega `print` tartibi kutilganidek emasligini aniqlash',
      'UI qotishining sababini topish (uzoq sinxron kod)',
      'Testlarda asinxron kodni to\'g\'ri kutish',
      'Og\'ir hisoblarni Isolate\'ga ko\'chirish qarorini qabul qilish',
    ],
    terms: [
      TermBlock(term: 'Event loop', uz: 'Hodisalar sikli', meaning: 'Navbatlardagi vazifalarni birma-bir bajaradigan mexanizm.', why: 'Asinxronlik shu orqali ishlaydi.'),
      TermBlock(term: 'Microtask queue', uz: 'Microtask navbati', meaning: 'Eng ustuvor navbat; event\'lardan oldin to\'liq bo\'shatiladi.', why: 'then/await davomlari shu yerda.'),
      TermBlock(term: 'Event queue', uz: 'Event navbati', meaning: 'Timer, Future(), kiritish hodisalari navbati.', why: 'Har bir event\'dan keyin microtask\'lar bajariladi.'),
      TermBlock(term: 'scheduleMicrotask', uz: 'Microtask qo\'shish', meaning: 'Funksiyani microtask navbatiga qo\'yadi (dart:async).', why: 'Tartibni o\'rganish uchun.'),
      TermBlock(term: 'Single thread', uz: 'Bitta oqim', meaning: 'Bir vaqtda faqat bitta kod bajariladi.', why: 'Shuning uchun uzoq sinxron kod hamma narsani to\'xtatadi.'),
    ],
    animation: AnimationBlock('event_loop', 'Avval sinxron kod, keyin barcha microtask\'lar, so\'ng event navbatidan bittadan'),
    example: CodeBlock(
      r'''import 'dart:async';

void main() {
  print('1. main boshlandi');
  Future.delayed(Duration(milliseconds: 100), () => print('7. 100 ms timer'));
  Future(() => print('5. Future() — event navbati'));
  scheduleMicrotask(() => print('3. microtask'));
  Future.value('qiymat').then((v) => print('4. tayyor Future then: $v'));
  Future.delayed(Duration.zero, () => print('6. Duration.zero ham event'));
  print('2. main tugadi');
}''',
      title: 'Chiqish tartibi',
      explain: {
        "import 'dart:async'": 'scheduleMicrotask shu kutubxonada.',
        'scheduleMicrotask': 'Microtask navbatiga — sinxron koddan keyin birinchi bo\'lib.',
        'Future.value': 'Tayyor qiymat; then davomi ham microtask sifatida.',
        'Future(() =>': 'Event navbatiga qo\'yiladi.',
        'Duration.zero': 'Nol kutish ham event navbati orqali.',
      },
      expectedOutput: '1. main boshlandi\n2. main tugadi\n3. microtask\n4. tayyor Future then: qiymat\n5. Future() — event navbati\n6. Duration.zero ham event\n7. 100 ms timer\n',
      visualize: true,
    ),
    extra: [
      CodeBlock(
        r'''import 'dart:async';

Future<void> ish() async {
  print('B: ish boshlandi');
  await null;
  print('D: await dan keyin (microtask)');
}

void main() {
  print('A');
  ish();
  scheduleMicrotask(() => print('E: microtask'));
  print('C');
}''',
        title: 'await davomi ham microtask',
        explain: {'await null': 'Hatto tayyor qiymatni kutish ham funksiyani keyingi microtask\'gacha to\'xtatadi.'},
        expectedOutput: 'A\nB: ish boshlandi\nC\nD: await dan keyin (microtask)\nE: microtask\n',
      ),
      CalloutBlock(CalloutKind.why, 'Nega D, E dan oldin?', '`ish()` ichidagi `await null` davomi microtask navbatiga **birinchi** bo\'lib qo\'yildi, `scheduleMicrotask` esa undan keyin. Navbat — kim oldin kelsa, shu oldin.'),
    ],
    buggy: BuggyCodeBlock(
      code: r'''void main() {
  var yuklandi = false;
  Future.delayed(Duration(seconds: 1), () {
    yuklandi = true;
  });
  if (yuklandi) {
    print('Ma\'lumot tayyor');
  } else {
    print('Hali tayyor emas');
  }
}''',
      task: 'Dasturchi `Ma\'lumot tayyor` chiqishini kutgan, lekin `Hali tayyor emas` chiqyapti. Yuklash tugashini kutib, keyin tekshiradigan qiling (`async/await`).',
      why: '`Future.delayed` darhol qaytadi; callback esa 1 soniyadan keyin event navbatidan ishlaydi. `if` sinxron, ya\'ni callback\'dan **oldin** bajariladi. Kutish uchun `await Future.delayed(...)` va `main` ni `async` qilish kerak.',
      fixed: r'''Future<void> main() async {
  var yuklandi = false;
  await Future.delayed(Duration(seconds: 1), () {
    yuklandi = true;
  });
  if (yuklandi) {
    print('Ma\'lumot tayyor');
  } else {
    print('Hali tayyor emas');
  }
}''',
    ),
    task: CodeTask(
      title: 'Navbatlarni boshqaring',
      instructions: 'Dastur aynan shunday chiqarsin:\n```\nboshlandi\nmicrotask\ntimer\n```\nShartlar: `microtask` matni `scheduleMicrotask` ichida, `timer` matni esa `Future.delayed` ichida chop etilsin. `main` oddiy (async emas) bo\'lishi mumkin.',
      starter: r'''import 'dart:async';

void main() {
  print('timer');
  print('microtask');
  print('boshlandi');
}''',
      checks: [
        OutputEquals('boshlandi\nmicrotask\ntimer\n', label: 'chiqish tartibi'),
        UsesConstruct(r'scheduleMicrotask\s*\(\s*\(\s*\)\s*(=>|\{)[^;]*microtask', '`microtask` scheduleMicrotask ichida chop etilsin'),
        UsesConstruct(r'Future\.delayed\([^;]*timer', '`timer` Future.delayed ichida chop etilsin'),
      ],
      hints: [
        "scheduleMicrotask(() => print('microtask'));",
        "Future.delayed(Duration.zero, () => print('timer'));",
        "Tartib: avval sinxron print('boshlandi'), keyin microtask, keyin event navbati. Kod qatorlari tartibi muhim emas!",
      ],
      solution: r'''import 'dart:async';

void main() {
  Future.delayed(Duration.zero, () => print('timer'));
  scheduleMicrotask(() => print('microtask'));
  print('boshlandi');
}''',
    ),
    quiz: [
      PredictOutput(
        prompt: 'Natija?',
        code: r'''import 'dart:async';

void main() {
  Future(() => print('X'));
  scheduleMicrotask(() => print('Y'));
  print('Z');
}''',
        options: ['X\nY\nZ', 'Z\nY\nX', 'Z\nX\nY', 'Y\nZ\nX'],
        explanation: 'Avval sinxron Z, keyin microtask Y, oxirida event navbatidagi X.',
        topic: 'event loop',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''void main() {
  Future.delayed(Duration(milliseconds: 20), () => print('20'));
  Future.delayed(Duration(milliseconds: 5), () => print('5'));
  Future.delayed(Duration.zero, () => print('0'));
}''',
        options: ['20\n5\n0', '0\n5\n20', '5\n0\n20', '0\n20\n5'],
        explanation: 'Timer\'lar vaqti kelishi tartibida ishlaydi: 0, 5, 20 ms.',
        topic: 'timer',
      ),
      TrueFalse(
        prompt: 'Microtask navbati bo\'shamaguncha event navbatidagi Timer callback\'lari ishlamaydi.',
        answer: true,
        explanation: 'To\'g\'ri. Har bir event\'dan oldin microtask navbati to\'liq bo\'shatiladi.',
        topic: 'microtask',
      ),
    ],
    summary: [
      'Dart bitta oqimda ishlaydi; asinxronlik — event loop orqali',
      'Tartib: sinxron kod → barcha microtask\'lar → bitta event → yana microtask\'lar...',
      'Microtask: scheduleMicrotask, then/await davomi; Event: Future(), Future.delayed, Timer',
      'Uzoq sinxron kod event loop\'ni band qiladi — UI qotadi',
    ],
    next: 'Bitta qiymat emas, vaqt davomida keladigan ko\'p qiymatlar uchun keyingi darsda Stream bilan tanishamiz.',
    revisionTip: 'Har bir misolda natijani avval qog\'ozga yozing, keyin vizualizatorda qadam-baqadam tekshiring.',
    links: [DocLink('Concurrency in Dart', 'https://dart.dev/language/concurrency')],
  ),

  // ───────────────────────── 4.5 Stream ─────────────────────────
  Lesson(
    id: 'l4_streams',
    title: 'Stream: vaqt bo\'yicha keladigan qiymatlar',
    subtitle: 'await for, async* va yield',
    icon: Icons.stream_rounded,
    minutes: 18,
    xp: 80,
    skills: ['dart.streams'],
    prerequisites: ['Event loop: microtask va event navbati'],
    objectives: [
      'Future va Stream farqini tushuntirasiz',
      '`await for` va `listen` bilan oqimni tinglaysiz',
      '`async*` va `yield` bilan o\'z oqimingizni yaratasiz; `where`, `map` bilan o\'zgartirasiz',
    ],
    intro: [
      ParaBlock('**Future** — bitta qiymat (bir marta). **Stream** — vaqt davomida keladigan **ko\'p** qiymatlar: chat xabarlari, joylashuv o\'zgarishlari, taymer tiklari, yuklanish foizi.'),
      BulletsBlock([
        '`await for (final x in oqim) { ... }` — har bir qiymat kelganda tana bajariladi, oqim tugagach sikl tugaydi',
        '`oqim.listen((x) { ... }, onDone: () { ... })` — callback uslubi',
        '`Stream<int> f() async* { yield 1; yield 2; }` — o\'z oqimingiz: `yield` qiymatni oqimga yuboradi',
        '`oqim.where(...)`, `oqim.map(...)`, `oqim.take(n)` — List\'dagi kabi o\'zgartirgichlar',
        '`await oqim.toList()` — oqim tugagach hamma qiymatlar ro\'yxati',
      ]),
      ParaBlock('Shunga o\'xshash **sinxron** generator ham bor: `Iterable<int> f() sync* { yield ...; }`. U qiymatlarni faqat so\'ralganda hisoblaydi (dangasa / lazy).'),
      CalloutBlock(CalloutKind.warning, 'Diqqat', 'Stream\'ni oddiy `for` bilan aylanib bo\'lmaydi — `await for` kerak (va u faqat `async` funksiyada ishlaydi).'),
    ],
    analogy: AnalogyBlock(
      'Suv quvuri',
      'Future — bitta paket yetkazib beruvchi kuryer. Stream esa **suv quvuri**: suv (hodisalar) vaqt davomida oqib keladi. `where` — filtr (faqat toza suv o\'tadi), `map` — isitgich (har bir tomchini o\'zgartiradi), `listen` — jo\'mrakni ochib kutish, `onDone` — suv tugadi.',
      icon: Icons.water_drop_rounded,
    ),
    why: 'Flutter\'da `StreamBuilder`, Firebase real-time ma\'lumotlari, WebSocket chat, BLoC state management — hammasi Stream ustiga qurilgan. Oqimlarni tushunish real-time ilovalarning asosi.',
    where: [
      'Chat: yangi xabarlar oqimi',
      'Sensor va GPS ma\'lumotlari',
      'Yuklanish foizi (0% → 100%)',
      'BLoC: holat (state) oqimi',
    ],
    terms: [
      TermBlock(term: 'Stream', uz: 'Oqim', meaning: 'Vaqt davomida ketma-ket keladigan hodisalar (qiymatlar yoki xatolar).', why: 'Ko\'p asinxron qiymatlar uchun.'),
      TermBlock(term: 'await for', uz: 'Oqimni aylanish', meaning: 'Har bir hodisa kelganda tanani bajaradi.', why: 'Oqimni ketma-ket qayta ishlash.'),
      TermBlock(term: 'async*', uz: 'Asinxron generator', meaning: 'Stream qaytaradigan funksiya; yield bilan qiymat beradi.', why: 'O\'z oqimingizni yaratish.'),
      TermBlock(term: 'yield', uz: 'Berish', meaning: 'Generatordan bitta qiymat chiqaradi.', why: 'Oqimga/ketma-ketlikka qiymat qo\'shish.'),
      TermBlock(term: 'sync*', uz: 'Sinxron generator', meaning: 'Dangasa Iterable qaytaradi; qiymatlar so\'ralganda hisoblanadi.', why: 'Cheksiz ketma-ketliklar uchun.'),
    ],
    animation: AnimationBlock('stream_flow', 'Qiymatlar oqim bo\'ylab filtr (where) va o\'zgartirgich (map) orqali tinglovchiga yetadi'),
    example: CodeBlock(
      r'''Stream<int> sanash(int dan) async* {
  for (var i = dan; i >= 1; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

Iterable<int> juftlar() sync* {
  var n = 0;
  while (true) {
    yield n;
    n += 2;
  }
}

Future<void> main() async {
  await for (final soniya in sanash(3)) {
    print('$soniya...');
  }
  print('Start!');

  final oqim = Stream.fromIterable([1, 2, 3, 4, 5, 6]);
  final natija = await oqim.where((x) => x.isOdd).map((x) => x * 10).toList();
  print(natija);

  print(juftlar().take(5).toList());
}''',
      title: 'async*, await for va sync*',
      explain: {
        'async*': 'Funksiya Stream qaytaradi.',
        'yield i': 'Oqimga navbatdagi qiymat yuboriladi.',
        'await for': 'Har bir qiymatni kutib, tanani bajaradi.',
        'sync*': 'Dangasa Iterable: cheksiz bo\'lsa ham faqat kerakli qismi hisoblanadi.',
        '.where((x) => x.isOdd)': 'Faqat toq sonlar o\'tadi.',
      },
      lineNotes: {10: 'Cheksiz sikl — lekin take(5) faqat 5 ta qiymat so\'raydi.'},
      expectedOutput: '3...\n2...\n1...\nStart!\n[10, 30, 50]\n[0, 2, 4, 6, 8]\n',
      visualize: true,
    ),
    extra: [
      CodeBlock(
        r'''Stream<String> xabarlar() async* {
  yield 'Salom!';
  await Future.delayed(Duration(milliseconds: 500));
  yield 'Qalaysiz?';
  await Future.delayed(Duration(milliseconds: 500));
  throw Exception('aloqa uzildi');
}

void main() {
  xabarlar().listen(
    (x) => print('Yangi xabar: $x'),
    onError: (e) => print('Oqim xatosi: $e'),
    onDone: () => print('Chat yopildi'),
  );
  print('Tinglash boshlandi');
}''',
        title: 'listen: onError va onDone',
        explain: {'onError': 'Oqimdagi xato shu yerga keladi.', 'onDone': 'Oqim tugaganda chaqiriladi.'},
        expectedOutput: 'Tinglash boshlandi\nYangi xabar: Salom!\nYangi xabar: Qalaysiz?\nOqim xatosi: Exception: aloqa uzildi\nChat yopildi\n',
      ),
    ],
    buggy: BuggyCodeBlock(
      code: r'''Stream<int> ballar() async* {
  yield 70;
  yield 85;
  yield 92;
}

Future<void> main() async {
  var jami = 0;
  ballar().listen((b) => jami += b);
  print('Jami: $jami');
}''',
      task: '`Jami: 247` chiqishi kerak, lekin `Jami: 0` chiqyapti. Oqim tugashini kutib, keyin chop eting (`await for` bilan).',
      why: '`listen` darhol qaytadi — qiymatlar keyinroq (microtask/event orqali) keladi, `print` esa ulardan oldin bajariladi. `await for` oqim tugaguncha kutadi.',
      fixed: r'''Stream<int> ballar() async* {
  yield 70;
  yield 85;
  yield 92;
}

Future<void> main() async {
  var jami = 0;
  await for (final b in ballar()) {
    jami += b;
  }
  print('Jami: $jami');
}''',
    ),
    task: CodeTask(
      title: 'Raketa uchishi',
      instructions: '`Stream<int> teskariSanash(int n) async*` yozing: u `n, n-1, ..., 1` qiymatlarini har biri orasida 1 soniya kutib bersin.\n`main` `await for` bilan har bir sonni chop etsin, oxirida `Uchdik!` desin.\n`teskariSanash(3)` uchun natija:\n```\n3\n2\n1\nUchdik!\n```',
      starter: r'''Stream<int> teskariSanash(int n) async* {
  // yield bilan yozing
}

Future<void> main() async {
  print('Uchdik!');
}''',
      checks: [
        OutputEquals('3\n2\n1\nUchdik!\n', label: 'main natijasi'),
        EvaluatesTo('await teskariSanash(4).toList()', '[4, 3, 2, 1]', label: '`teskariSanash(4)` → [4, 3, 2, 1]'),
        EvaluatesTo('await teskariSanash(1).toList()', '[1]', hidden: true),
        UsesConstruct(r'yield', '`yield` ishlatilishi kerak'),
        UsesConstruct(r'await\s+for', '`await for` ishlatilishi kerak'),
      ],
      hints: [
        'for (var i = n; i >= 1; i--) { ... yield i; }',
        'await Future.delayed(Duration(seconds: 1)); yield dan oldin',
        r'''await for (final s in teskariSanash(3)) {
  print(s);
}
print('Uchdik!');''',
      ],
      solution: r'''Stream<int> teskariSanash(int n) async* {
  for (var i = n; i >= 1; i--) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

Future<void> main() async {
  await for (final s in teskariSanash(3)) {
    print(s);
  }
  print('Uchdik!');
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Future va Stream farqi?',
        options: [
          'Farqi yo\'q',
          'Future — bitta asinxron qiymat, Stream — vaqt davomida ko\'p qiymatlar',
          'Stream — faqat sinxron',
          'Future — ko\'p qiymat, Stream — bitta',
        ],
        correct: 1,
        explanation: 'Future bir marta tugaydi; Stream ko\'p hodisa beradi va onDone bilan tugaydi.',
        topic: 'Stream',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''Iterable<int> f() sync* {
  print('a');
  yield 1;
  print('b');
  yield 2;
}

void main() {
  print(f().first);
}''',
        options: ['a\n1', 'a\nb\n1', '1', 'a\n1\nb'],
        explanation: 'sync* dangasa: first faqat birinchi qiymatni so\'raydi — b va 2 umuman hisoblanmaydi.',
        topic: 'sync*',
      ),
      FillBlank(
        prompt: 'Stream qaytaradigan generator funksiya belgisi:',
        template: 'Stream<int> sonlar() ____ { yield 1; }',
        accepted: ['async*'],
        explanation: 'async* — asinxron generator, Stream qaytaradi.',
        topic: 'async*',
      ),
    ],
    summary: [
      'Stream — vaqt davomida keladigan ko\'p qiymatlar (va xatolar)',
      'await for — oqimni ketma-ket aylanish; listen — callback uslubi',
      'async* + yield — o\'z oqimingiz; sync* + yield — dangasa Iterable',
      'where, map, take, toList — oqim o\'zgartirgichlari',
    ],
    next: 'Keyingi darsda oqimni qo\'lda boshqarish — StreamController va callback\'ni Future\'ga aylantiruvchi Completer bilan ishlaymiz.',
    revisionTip: 'Har 0.5 soniyada yuklanish foizini (0, 25, 50, 75, 100) beradigan Stream yozing va uni progress satri sifatida chop eting.',
    links: [DocLink('Asynchronous programming: Streams', 'https://dart.dev/libraries/async/using-streams')],
  ),

  // ───────────────────────── 4.6 StreamController, Completer, Timer ─────────────────────────
  Lesson(
    id: 'l4_stream_controller',
    title: 'StreamController, Completer va Timer',
    subtitle: 'Oqim va Future\'ni qo\'lda boshqarish',
    icon: Icons.settings_input_component_rounded,
    minutes: 18,
    xp: 80,
    skills: ['dart.stream_controller'],
    prerequisites: ['Stream: vaqt bo\'yicha keladigan qiymatlar'],
    objectives: [
      '`StreamController` bilan o\'z hodisalar oqimingizni yaratasiz (single va broadcast)',
      '`Completer` bilan callback\'li API\'ni Future\'ga aylantirasiz',
      '`Timer` va `Timer.periodic` bilan rejalashtirilgan ishlarni boshqarasiz',
    ],
    intro: [
      ParaBlock('`async*` oqimni funksiya ichidan yaratadi. Ba\'zan esa qiymatlarni **tashqaridan**, istalgan paytda qo\'shish kerak: masalan, tugma bosilganda yoki serverdan xabar kelganda. Buning uchun **`StreamController`** bor (`dart:async`).'),
      BulletsBlock([
        '`final c = StreamController<int>();` — boshqaruvchi',
        '`c.stream` — tinglovchilarga beriladigan oqim',
        '`c.add(5)`, `c.addError(e)`, `c.close()` — hodisa qo\'shish va yopish',
        '`StreamController.broadcast()` — **ko\'p** tinglovchili oqim (oddiysi faqat bitta tinglovchiga ruxsat beradi)',
      ]),
      ParaBlock('**`Completer<T>`** — Future\'ni qo\'lda tugatish uchun: `completer.future` ni qaytarasiz, natija tayyor bo\'lganda `completer.complete(qiymat)` chaqirasiz.'),
      ParaBlock('**`Timer(Duration, callback)`** — bir martalik; **`Timer.periodic(Duration, (t) {...})`** — takrorlanuvchi; `t.cancel()` bilan to\'xtatiladi.'),
      CalloutBlock(CalloutKind.warning, 'Resurslarni yoping', 'Ishlatib bo\'lingan `StreamController` ni `close()` qiling, `Timer.periodic` ni `cancel()` qiling. Aks holda xotira sizib chiqadi va dastur hech qachon tugamaydi.'),
    ],
    analogy: AnalogyBlock(
      'Radio studiya',
      'StreamController — radio studiya: diktor (`add`) istalgan paytda efirga xabar beradi. `stream` — radio to\'lqini. Oddiy controller — faqat bitta radiopriyomnik ulanadi; **broadcast** — butun shahar eshitadi. `close()` — efir tugadi. Completer esa "javobni keyin telefon qilib aytaman" degan va\'da: qo\'ng\'iroq bo\'lganda (`complete`) Future tugaydi.',
      icon: Icons.radio_rounded,
    ),
    why: 'BLoC, Riverpod ichki mexanizmlari, WebSocket wrapper\'lar, event bus\'lar StreamController ustiga quriladi. Completer eski callback\'li kutubxonalarni zamonaviy async/await bilan bog\'laydi. Timer — avtomatik saqlash, qayta urinish, sekundomer.',
    where: [
      'Chat: serverdan kelgan xabarlarni oqimga qo\'shish',
      'Event bus: ilova bo\'ylab hodisalarni tarqatish (broadcast)',
      'Callback API\'ni Future\'ga aylantirish (Completer)',
      'Sekundomer, avtomatik saqlash (Timer.periodic)',
    ],
    terms: [
      TermBlock(term: 'StreamController', uz: 'Oqim boshqaruvchisi', meaning: 'Qo\'lda hodisa qo\'shish mumkin bo\'lgan oqim yaratadi.', why: 'Tashqi hodisalarni oqimga aylantirish.'),
      TermBlock(term: 'Broadcast stream', uz: 'Ko\'p tinglovchili oqim', meaning: 'Bir nechta listen ruxsat etilgan oqim.', why: 'Bir hodisani ko\'p joyga yetkazish.'),
      TermBlock(term: 'StreamSubscription', uz: 'Obuna', meaning: 'listen natijasi; pause, resume, cancel qilish mumkin.', why: 'Tinglashni to\'xtatish uchun.'),
      TermBlock(term: 'Completer', uz: 'Tugatuvchi', meaning: 'Future\'ni qo\'lda complete/completeError qilish vositasi.', why: 'Callback → Future.'),
      TermBlock(term: 'Timer', uz: 'Taymer', meaning: 'Belgilangan vaqtdan keyin (yoki davriy) callback chaqiradi.', why: 'Rejalashtirilgan ishlar.'),
    ],
    animation: AnimationBlock('stream_flow', 'controller.add() bilan qo\'shilgan hodisa oqim orqali tinglovchiga yetadi'),
    example: CodeBlock(
      r'''import 'dart:async';

class Chat {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get xabarlar => _controller.stream;

  void yubor(String matn) => _controller.add(matn);
  Future<void> yop() => _controller.close();
}

Future<String> eskiApi() {
  final completer = Completer<String>();
  Timer(Duration(milliseconds: 300), () => completer.complete('javob keldi'));
  return completer.future;
}

Future<void> main() async {
  final chat = Chat();
  chat.xabarlar.listen((m) => print('Ali ko\'rdi: $m'));
  chat.xabarlar.listen((m) => print('Vali ko\'rdi: $m'));
  chat.yubor('Salom hammaga!');
  await chat.yop();

  print(await eskiApi());

  var tik = 0;
  Timer.periodic(Duration(seconds: 1), (t) {
    tik++;
    print('Sekundomer: $tik s');
    if (tik == 3) t.cancel();
  });
}''',
      title: 'Broadcast chat, Completer va Timer',
      explain: {
        'StreamController<String>.broadcast()': 'Ko\'p tinglovchili oqim.',
        '_controller.add(matn)': 'Oqimga yangi hodisa.',
        'Completer<String>()': 'Future\'ni qo\'lda tugatish vositasi.',
        'completer.complete': 'Future shu qiymat bilan tugaydi.',
        'Timer.periodic': 'Har 1 soniyada callback.',
        't.cancel()': 'Davriy taymerni to\'xtatish.',
      },
      expectedOutput: "Ali ko'rdi: Salom hammaga!\nVali ko'rdi: Salom hammaga!\njavob keldi\nSekundomer: 1 s\nSekundomer: 2 s\nSekundomer: 3 s\n",
    ),
    buggy: BuggyCodeBlock(
      code: r'''import 'dart:async';

void main() {
  final c = StreamController<int>();
  c.stream.listen((x) => print('Birinchi: $x'));
  c.stream.listen((x) => print('Ikkinchi: $x'));
  c.add(7);
  c.close();
}''',
      task: 'Ikki joy bir xil oqimni tinglamoqchi, lekin dastur `StateError` bilan to\'xtaydi. Ikkala tinglovchi ham `7` ni olsin.',
      why: 'Oddiy `StreamController` **bitta** tinglovchiga mo\'ljallangan: ikkinchi `listen` — "Stream has already been listened to". Ko\'p tinglovchi uchun `StreamController<int>.broadcast()` kerak.',
      fixed: r'''import 'dart:async';

void main() {
  final c = StreamController<int>.broadcast();
  c.stream.listen((x) => print('Birinchi: $x'));
  c.stream.listen((x) => print('Ikkinchi: $x'));
  c.add(7);
  c.close();
}''',
    ),
    task: CodeTask(
      title: 'Harorat datchigi',
      instructions: '`Datchik` class\'ini yozing (`dart:async` kerak):\n• ichida `StreamController<int>` bo\'lsin;\n• `Stream<int> get oqim` — oqimni bersin;\n• `void olchov(int t)` — haroratni oqimga qo\'shsin;\n• `void yop()` — controllerni yopsin.\n`main` dagi tinglovchi har bir o\'lchovni `Harorat: t°C` qilib chiqaradi, oqim yopilganda `O\'lchov tugadi`.',
      starter: r'''import 'dart:async';

class Datchik {
  Stream<int> get oqim => Stream.empty();
  void olchov(int t) {}
  void yop() {}
}

void main() {
  final d = Datchik();
  d.oqim.listen((t) => print('Harorat: $t°C'), onDone: () => print("O'lchov tugadi"));
  d.olchov(21);
  d.olchov(23);
  d.yop();
}''',
      checks: [
        OutputEquals("Harorat: 21°C\nHarorat: 23°C\nO'lchov tugadi\n", label: 'main natijasi'),
        EvaluatesTo('await (() async { final d = Datchik(); final f = d.oqim.toList(); d.olchov(5); d.yop(); return await f; })()', '[5]',
            hidden: true),
        UsesConstruct(r'StreamController', '`StreamController` ishlatilishi kerak'),
        UsesConstruct(r'\.add\(', 'Qiymat `.add(...)` bilan qo\'shilishi kerak'),
        UsesConstruct(r'\.close\(\)', 'Controller `close()` qilinishi kerak'),
      ],
      hints: [
        'final _c = StreamController<int>();',
        'Stream<int> get oqim => _c.stream;',
        'void olchov(int t) => _c.add(t);   void yop() => _c.close();',
      ],
      solution: r'''import 'dart:async';

class Datchik {
  final _c = StreamController<int>();
  Stream<int> get oqim => _c.stream;
  void olchov(int t) => _c.add(t);
  void yop() => _c.close();
}

void main() {
  final d = Datchik();
  d.oqim.listen((t) => print('Harorat: $t°C'), onDone: () => print("O'lchov tugadi"));
  d.olchov(21);
  d.olchov(23);
  d.yop();
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Bir oqimni bir nechta joy tinglashi kerak. Qaysi controller?',
        options: ['StreamController()', 'StreamController.broadcast()', 'Completer()', 'Timer()'],
        correct: 1,
        explanation: 'broadcast — ko\'p tinglovchili. Oddiy controller ikkinchi listen\'da StateError beradi.',
        topic: 'broadcast',
      ),
      PredictOutput(
        prompt: 'Natija?',
        code: r'''import 'dart:async';

Future<void> main() async {
  final c = Completer<int>();
  Timer(Duration(seconds: 2), () => c.complete(10));
  print('kutyapman');
  final v = await c.future;
  print(v * 2);
}''',
        options: ['kutyapman\n20', '20\nkutyapman', 'kutyapman\n10', '20'],
        explanation: 'Completer.future 2 soniyadan keyin 10 bilan tugaydi; await undan keyin 20 ni chiqaradi.',
        topic: 'Completer',
      ),
      MultiChoice(
        prompt: 'Qaysilarini ishlatib bo\'lgach yopish/to\'xtatish kerak?',
        options: ['StreamController (close)', 'Timer.periodic (cancel)', 'StreamSubscription (cancel)', 'Oddiy int o\'zgaruvchi'],
        correct: {0, 1, 2},
        explanation: 'Controller, davriy timer va obunalar resurs ushlab turadi — ularni yopish kerak.',
        topic: 'resurslar',
      ),
    ],
    summary: [
      'StreamController: add, addError, close; stream — tinglovchilar uchun',
      'Oddiy controller — bitta tinglovchi; broadcast — ko\'p',
      'Completer — Future\'ni qo\'lda complete qilish',
      'Timer va Timer.periodic; resurslarni close/cancel qiling',
    ],
    next: 'Tabriklaymiz — asinxron Dart moduli tugadi! Endi Flutter dunyosiga o\'tamiz: Widget nima va ekran qanday quriladi.',
    revisionTip: 'Sekundomer yozing: Timer.periodic har soniyada StreamController\'ga vaqtni qo\'shsin, tinglovchi esa uni chop etsin; 5 soniyada hammasini yoping.',
    links: [
      DocLink('StreamController', 'https://api.dart.dev/dart-async/StreamController-class.html'),
      DocLink('Completer', 'https://api.dart.dev/dart-async/Completer-class.html'),
    ],
  ),
];
