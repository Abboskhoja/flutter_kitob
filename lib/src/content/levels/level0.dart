import 'package:flutter/material.dart';

import '../model.dart';

const level0Lessons = <Lesson>[
  // ───────────────────────── 0.1 ─────────────────────────
  Lesson(
    id: 'l0_computer',
    title: 'Kompyuter va dastur nima?',
    subtitle: 'Telefoningiz ichida aslida nima sodir bo\'ladi',
    icon: Icons.computer_rounded,
    minutes: 8,
    xp: 40,
    skills: ['found.computer'],
    objectives: [
      'Kompyuter qanday qismlardan iborat ekanini bilasiz',
      'Dastur nima ekanini o\'z so\'zingiz bilan tushuntira olasiz',
      'Kirish → qayta ishlash → chiqish modelini tushunasiz',
    ],
    intro: [
      ParaBlock('**Kompyuter** — ma\'lumotni qabul qiladigan, uni buyruqlar asosida qayta ishlaydigan va natija beradigan qurilma. Telefoningiz, noutbukingiz, hatto aqlli soatingiz ham — kompyuter.'),
      ParaBlock('Har qanday kompyuterda 4 ta asosiy qism bor:'),
      BulletsBlock([
        '**Protsessor (CPU)** — "miya". Buyruqlarni juda tez bajaradi: sekundiga milliardlab amal.',
        '**Xotira (RAM)** — "ish stoli". Hozir ishlayotgan dasturlar va ma\'lumotlar shu yerda turadi. Telefon o\'chsa — tozalanadi.',
        '**Doimiy xotira (SSD / flesh)** — "javon". Rasmlar, ilovalar, fayllar shu yerda saqlanadi va o\'chganda ham yo\'qolmaydi.',
        '**Kirish/chiqish qurilmalari** — ekran, klaviatura, kamera, mikrofon, karnay.',
      ]),
      ParaBlock('**Dastur** — kompyuterga nima qilish kerakligini aytadigan **buyruqlar to\'plami**. Kompyuter o\'zicha hech narsa "bilmaydi" — u faqat dasturda yozilgan buyruqlarni aniq va tartib bilan bajaradi.'),
      ParaBlock('Telegram, kamera, kalkulyator, o\'yinlar — bularning hammasi dasturlar. Telefonda ular **ilova** (app) deb ham ataladi.'),
    ],
    analogy: AnalogyBlock(
      'Oshpaz va retsept',
      'Kompyuterni juda tez, lekin o\'zicha o\'ylay olmaydigan oshpaz deb tasavvur qiling. Dastur — uning qo\'lidagi retsept. Retseptda "2 ta tuxum chaq, 3 daqiqa qovur" deb yozilgan bo\'lsa, oshpaz aynan shuni qiladi. Retsept xato bo\'lsa — taom ham xato chiqadi. Dasturchi — retsept yozuvchi.',
      icon: Icons.restaurant_menu_rounded,
    ),
    why: 'Dasturlashni o\'rganishdan oldin kompyuter buyruqlarni qanday bajarishini tushunish kerak. Shunda kod yozganda "kompyuter buni nima uchun bunday qildi?" degan savolga o\'zingiz javob topasiz.',
    where: [
      'Har bir mobil ilova — telefon protsessorida bajariladigan dastur',
      'Bank kartangizdan to\'lov — serverdagi dastur buyrug\'i',
      'Svetoforlar, liftlar, kir yuvish mashinalari ham kichik dasturlar bilan ishlaydi',
    ],
    terms: [
      TermBlock(term: 'Program', uz: 'Dastur', meaning: 'Kompyuter bajaradigan buyruqlar ketma-ketligi.', why: 'Biz yozadigan har bir narsa — dastur.', example: 'Kalkulyator ilovasi'),
      TermBlock(term: 'CPU (Central Processing Unit)', uz: 'Markaziy protsessor', meaning: 'Buyruqlarni bajaruvchi asosiy mikrosxema.', why: 'Kodingiz oxir-oqibat CPU da bajariladi.'),
      TermBlock(term: 'RAM', uz: 'Tezkor xotira', meaning: 'Ishlayotgan dasturlar vaqtincha saqlanadigan xotira.', why: 'O\'zgaruvchilaringiz aynan RAM da yashaydi.'),
      TermBlock(term: 'Input / Output', uz: 'Kirish / Chiqish', meaning: 'Dasturga keladigan ma\'lumot va dastur beradigan natija.', why: 'Har qanday dastur ma\'lumot oladi va natija beradi.', example: 'Kalkulyatorda 2+2 — kirish, 4 — chiqish'),
    ],
    animation: AnimationBlock('program_flow', 'Kirish → Dastur (buyruqlar) → Chiqish. Tugmani bosib jarayonni kuzating.'),
    extra: [
      CalloutBlock(CalloutKind.info, 'Muhim g\'oya', 'Kompyuter **aqlli emas** — u faqat **tez** va **aniq**. Buyruqlarni bir-biridan keyin, tartib bilan bajaradi. Dasturchining vazifasi — to\'g\'ri va aniq buyruqlar yozish.'),
    ],
    quiz: [
      SingleChoice(
        prompt: 'Dastur nima?',
        options: ['Kompyuterning ekrani', 'Kompyuterga nima qilishni aytadigan buyruqlar to\'plami', 'Internet tarmog\'i', 'Kompyuterning xotirasi'],
        correct: 1,
        explanation: 'Dastur — buyruqlar to\'plami. Ekran va xotira esa qurilma qismlari.',
        topic: 'Dastur',
      ),
      SingleChoice(
        prompt: 'Telefon o\'chganda qaysi xotiradagi ma\'lumot tozalanadi?',
        options: ['SSD / flesh xotira', 'RAM (tezkor xotira)', 'Ikkalasi ham', 'Hech qaysi'],
        correct: 1,
        explanation: 'RAM — vaqtinchalik "ish stoli". Doimiy xotira (SSD) esa ma\'lumotni saqlab qoladi.',
        topic: 'Xotira',
      ),
      TrueFalse(
        prompt: 'Kompyuter buyruq yozilmagan ishni o\'zi o\'ylab bajara oladi.',
        answer: false,
        explanation: 'Kompyuter faqat dasturda yozilgan buyruqlarni bajaradi. "Aqlli" ko\'ringan ilovalar ham aslida juda ko\'p buyruqlardan iborat.',
        topic: 'Dastur',
      ),
      MatchPairs(
        prompt: 'Qismni vazifasi bilan moslang',
        pairs: [('CPU', 'Buyruqlarni bajaradi'), ('RAM', 'Vaqtinchalik ish xotirasi'), ('SSD', 'Fayllarni doimiy saqlaydi'), ('Ekran', 'Natijani ko\'rsatadi')],
        explanation: 'Har bir qism o\'z vazifasiga ega va ular birgalikda ishlaydi.',
        topic: 'Kompyuter qismlari',
      ),
    ],
    summary: [
      'Kompyuter = protsessor + xotira + doimiy xotira + kirish/chiqish qurilmalari',
      'Dastur — kompyuter bajaradigan buyruqlar to\'plami',
      'Har qanday dastur: kirish → qayta ishlash → chiqish',
      'Kompyuter tez va aniq, lekin o\'zicha o\'ylamaydi',
    ],
    next: 'Keyingi darsda kompyuter "tushunadigan" til — dasturlash tili bilan tanishamiz va birinchi kodingizni ishga tushirasiz.',
    revisionTip: 'Telefoningizdagi 3 ta ilovani oling va har biri uchun "kirish" va "chiqish" nima ekanini yozib chiqing.',
  ),

  // ───────────────────────── 0.2 ─────────────────────────
  Lesson(
    id: 'l0_language',
    title: 'Dasturlash tili va kod',
    subtitle: 'Kompyuter bilan qanday "gaplashamiz"',
    icon: Icons.translate_rounded,
    minutes: 10,
    xp: 40,
    skills: ['found.language'],
    prerequisites: ['Kompyuter va dastur nima?'],
    objectives: [
      'Dasturlash tili nima uchun kerakligini tushunasiz',
      'Kod, sintaksis va kompilyator tushunchalarini bilasiz',
      'Birinchi Dart kodingizni ishga tushirasiz',
    ],
    intro: [
      ParaBlock('Protsessor faqat **mashina tili**ni tushunadi — bu 0 va 1 lardan iborat juda uzun ketma-ketlik. Odam uchun uni yozish deyarli imkonsiz.'),
      ParaBlock('Shuning uchun odamlar **dasturlash tillari**ni o\'ylab topishdi: Dart, Python, JavaScript, Java, Swift... Ular inglizcha so\'zlar va matematik belgilarga o\'xshaydi, shuning uchun o\'qish va yozish oson.'),
      ParaBlock('Dasturlash tilida yozilgan matn **kod** (yoki manba kodi — source code) deyiladi. Kodni mashina tiliga maxsus dastur — **kompilyator** (compiler) tarjima qiladi.'),
      ParaBlock('Har bir tilning o\'z **sintaksisi** bor — ya\'ni yozish qoidalari. O\'zbek tilida gap oxiriga nuqta qo\'yganimiz kabi, Dartda har bir buyruq oxiriga `;` qo\'yiladi.'),
    ],
    analogy: AnalogyBlock(
      'Tarjimon',
      'Siz o\'zbekcha gapirasiz, mehmon esa faqat yaponcha tushunadi. O\'rtada tarjimon turadi. Dasturlashda siz Dart tilida yozasiz, protsessor esa faqat mashina tilini tushunadi — kompilyator ana shu tarjimon.',
      icon: Icons.record_voice_over_outlined,
    ),
    why: 'Dasturlash tili — sizning kompyuterga buyruq berish vositangiz. Uning qoidalarini (sintaksisini) bilmasangiz, kompyuter sizni "tushunmaydi" va xato beradi.',
    where: [
      'Dart — Flutter ilovalari (Android, iOS, Web, Desktop)',
      'Swift — faqat Apple qurilmalari uchun',
      'Kotlin — Android ilovalari uchun',
      'JavaScript — veb-saytlar uchun',
    ],
    terms: [
      TermBlock(term: 'Programming language', uz: 'Dasturlash tili', meaning: 'Kompyuterga buyruq yozish uchun maxsus til.', why: 'Mashina tilida yozish juda qiyin.', example: 'Dart, Python, Java'),
      TermBlock(term: 'Source code', uz: 'Manba kodi', meaning: 'Dasturchi yozgan matn ko\'rinishidagi dastur.', why: 'Biz o\'qiy va o\'zgartira oladigan shakl.'),
      TermBlock(term: 'Syntax', uz: 'Sintaksis', meaning: 'Tilning yozish qoidalari.', why: 'Qoida buzilsa, kod ishlamaydi.', example: 'Buyruq oxirida ;'),
      TermBlock(term: 'Compiler', uz: 'Kompilyator', meaning: 'Kodni mashina tushunadigan shaklga o\'giruvchi dastur.', why: 'Usiz protsessor kodingizni tushunmaydi.'),
      TermBlock(term: 'Interpreter', uz: 'Interpretator', meaning: 'Kodni qatorma-qator o\'qib, darhol bajaruvchi dastur.', why: 'Kodni tez sinab ko\'rish uchun qulay. Bu platformadagi kod ishga tushirgich ham interpretator.'),
      TermBlock(term: 'Bug', uz: 'Xato (bag)', meaning: 'Dasturdagi xato yoki kutilmagan xatti-harakat.', why: 'Dasturchi vaqtining katta qismi xatolarni topish va tuzatishga ketadi.'),
    ],
    animation: AnimationBlock('compiler', 'Dart kodi kompilyator orqali mashina kodiga aylanadi va protsessor uni bajaradi.'),
    example: CodeBlock(
      r'''void main() {
  print('Salom, dunyo!');
}''',
      title: 'Sizning birinchi kodingiz',
      explain: {
        'void': 'Funksiya hech qanday qiymat qaytarmasligini bildiradi. Hozircha "shunday yoziladi" deb eslab qoling.',
        'main': 'Dastur shu yerdan boshlanadi. Har bir Dart dasturida main() bo\'lishi shart.',
        'print': 'Qavs ichidagi matnni ekranga (konsolga) chiqaradi.',
        "'Salom, dunyo!'": 'Matn (String). Qo\'shtirnoq ichida yoziladi.',
        ';': 'Buyruq tugadi degan belgi.',
        '{': 'main funksiyasi tanasining boshlanishi.',
        '}': 'main funksiyasi tanasining oxiri.',
      },
      lineNotes: {1: 'Dastur shu yerdan boshlanadi', 2: 'Ekranga matn chiqaramiz', 3: 'main tugadi'},
      expectedOutput: 'Salom, dunyo!\n',
    ),
    task: CodeTask(
      title: 'O\'z ismingizni chiqaring',
      instructions: 'Kodni o\'zgartiring: `Salom, dunyo!` o\'rniga `Salom, ` va o\'z ismingizni yozing. Masalan: `Salom, Aziz!`',
      starter: r'''void main() {
  print('Salom, dunyo!');
}''',
      checks: [
        OutputContains('Salom, ', label: 'Natijada "Salom, " bo\'lishi kerak'),
        UsesConstruct(r"print\s*\(", 'print() ishlatilgan bo\'lishi kerak'),
        UsesConstruct(r"^(?![\s\S]*dunyo)[\s\S]*$", '"dunyo" o\'rniga o\'z ismingizni yozing'),
      ],
      hints: [
        'Faqat qo\'shtirnoq ichidagi matnni o\'zgartiring.',
        'Qo\'shtirnoqlarni o\'chirib yubormang: \'Salom, Ali!\'',
        "print('Salom, Ali!');",
      ],
      solution: r'''void main() {
  print('Salom, Ali!');
}''',
    ),
    quiz: [
      SingleChoice(
        prompt: 'Kompilyator nima qiladi?',
        options: ['Kodni chiroyli qiladi', 'Kodni mashina tushunadigan shaklga tarjima qiladi', 'Internetga ulaydi', 'Xatolarni o\'zi tuzatadi'],
        correct: 1,
        explanation: 'Kompilyator — tarjimon: manba kodini mashina kodiga aylantiradi.',
        topic: 'Kompilyator',
      ),
      SingleChoice(
        prompt: 'Sintaksis nima?',
        options: ['Dastur nomi', 'Tilning yozish qoidalari', 'Xato turi', 'Kompyuter qismi'],
        correct: 1,
        explanation: 'Sintaksis — tilning grammatikasi, ya\'ni kod qanday yozilishi qoidalari.',
        topic: 'Sintaksis',
      ),
      PredictOutput(
        prompt: 'Bu kod ekranga nima chiqaradi?',
        code: r'''void main() {
  print('Dart');
  print('Flutter');
}''',
        options: ['Dart Flutter', 'Dart\nFlutter', 'Flutter\nDart', 'Xato beradi'],
        explanation: 'Har bir print() alohida qatorga chiqaradi va buyruqlar yuqoridan pastga bajariladi.',
        topic: 'print',
      ),
    ],
    summary: [
      'Protsessor faqat mashina tilini (0 va 1) tushunadi',
      'Dasturlash tili — odam uchun qulay buyruq yozish tili',
      'Kompilyator kodni mashina kodiga tarjima qiladi',
      'Sintaksis — yozish qoidalari; buzilsa kod ishlamaydi',
    ],
    next: 'Endi dasturlashning eng muhim ko\'nikmasi — muammoni qadamlarga bo\'lishni, ya\'ni algoritm tuzishni o\'rganamiz.',
    revisionTip: 'Birinchi kodni xotiradan qayta yozib ko\'ring: void main, qavslar, print va nuqtali vergul.',
  ),

  // ───────────────────────── 0.3 ─────────────────────────
  Lesson(
    id: 'l0_algorithm',
    title: 'Algoritm — qadam-baqadam fikrlash',
    subtitle: 'Har qanday muammoni kichik qadamlarga bo\'lish',
    icon: Icons.account_tree_outlined,
    minutes: 10,
    xp: 40,
    skills: ['found.algorithm'],
    prerequisites: ['Dasturlash tili va kod'],
    objectives: [
      'Algoritm nima ekanini bilasiz',
      'Kundalik vazifani aniq qadamlarga bo\'la olasiz',
      'Shart (agar...) va takrorlash (...gacha) tushunchalarini sezasiz',
    ],
    intro: [
      ParaBlock('**Algoritm** — muammoni yechish uchun aniq, tartiblangan qadamlar ketma-ketligi. Har qanday dastur ichida bir yoki bir nechta algoritm bor.'),
      ParaBlock('Yaxshi algoritmning xususiyatlari:'),
      BulletsBlock([
        '**Aniq** — har bir qadam bir xil tushuniladi ("biroz tuz sol" emas, "1 choy qoshiq tuz sol")',
        '**Tartibli** — qadamlar to\'g\'ri ketma-ketlikda',
        '**Chekli** — qachondir tugaydi',
        '**Natijali** — oxirida kutilgan natija chiqadi',
      ]),
      ParaBlock('Algoritmlarda 3 ta asosiy "qurilish bloki" uchraydi:'),
      BulletsBlock([
        '**Ketma-ketlik** — qadamlar birin-ketin bajariladi',
        '**Shart** — "AGAR yomg\'ir yog\'sa, soyabon ol, AKS HOLDA ko\'zoynak ol"',
        '**Takrorlash** — "Choynak qaynaguncha kut", "10 marta o\'tirib tur"',
      ], ordered: true),
      ParaBlock('Keyinchalik Dartda bular `if`, `for`, `while` deb yoziladi. Hozir esa fikrlash usulini o\'rganamiz.'),
    ],
    analogy: AnalogyBlock(
      'Navigator',
      'Xaritadagi navigator sizga "200 metr to\'g\'ri yuring, chorrahada chapga buriling, agar yo\'l yopiq bo\'lsa — o\'ngdan aylanib o\'ting" deydi. Bu — algoritm: aniq, tartibli va shartli qadamlar.',
      icon: Icons.navigation_outlined,
    ),
    why: 'Kod yozishdan oldin "nima qilish kerak?" degan savolga qadamlar bilan javob bera olsangiz, kodni yozish juda osonlashadi. Professional dasturchilar ham avval algoritmni o\'ylaydi, keyin kod yozadi.',
    where: [
      'Navigatsiya ilovalari — eng qisqa yo\'lni topish algoritmi',
      'Qidiruv tizimlari — natijalarni saralash algoritmi',
      'O\'yinlar — raqib harakatini tanlash algoritmi',
      'Har bir funksiya — kichik algoritm',
    ],
    terms: [
      TermBlock(term: 'Algorithm', uz: 'Algoritm', meaning: 'Muammoni yechishning aniq qadamlari.', why: 'Har bir dastur algoritmlardan quriladi.', example: 'Choy damlash qadamlari'),
      TermBlock(term: 'Condition', uz: 'Shart', meaning: 'Qaror qabul qilish: agar ... bo\'lsa.', why: 'Dastur turli vaziyatlarda turlicha ishlashi uchun.', example: 'Agar parol to\'g\'ri bo\'lsa — kirish'),
      TermBlock(term: 'Loop', uz: 'Sikl (takrorlash)', meaning: 'Qadamni bir necha marta qaytarish.', why: 'Bir xil ishni qayta-qayta yozmaslik uchun.', example: '10 marta salom de'),
    ],
    animation: AnimationBlock('algorithm', 'Choy damlash algoritmi: ketma-ketlik, shart va takrorlash.'),
    example: CodeBlock(
      r'''void main() {
  print('1. Choynakka suv quy');
  print('2. Choynakni yoq');
  print('3. Suv qaynaguncha kut');
  print('4. Piyolaga choy sol');
  print('5. Qaynoq suv quy');
}''',
      title: 'Algoritm koddagi ko\'rinishi',
      lineNotes: {2: '1-qadam', 3: '2-qadam', 4: 'Takrorlash g\'oyasi: qaynaguncha', 6: 'Oxirgi qadam'},
      expectedOutput: '1. Choynakka suv quy\n2. Choynakni yoq\n3. Suv qaynaguncha kut\n4. Piyolaga choy sol\n5. Qaynoq suv quy\n',
    ),
    task: CodeTask(
      title: 'Ertalabki algoritm',
      instructions: 'Ertalab uyg\'ongandan keyingi 3 ta qadamingizni `print()` bilan **tartib bilan** chiqaring. Har bir qadam alohida qatorda bo\'lsin.',
      starter: r'''void main() {
  print('1. Uyg\'ondim');
  // 2- va 3-qadamlarni shu yerga yozing
}''',
      checks: [
        UsesConstruct(r"print[\s\S]*print[\s\S]*print", 'Kamida 3 ta print() bo\'lishi kerak'),
        OutputContains('1.', label: '1-qadam chiqishi kerak'),
      ],
      hints: [
        'Har bir qadam uchun alohida print() yozing.',
        "print('2. Yuvindim'); kabi qator qo'shing.",
        r'''print('2. Yuvindim');
print('3. Nonushta qildim');''',
      ],
      solution: r'''void main() {
  print('1. Uyg\'ondim');
  print('2. Yuvindim');
  print('3. Nonushta qildim');
}''',
    ),
    quiz: [
      ArrangeLines(
        prompt: 'Telefon orqali do\'stga xabar yuborish algoritmini to\'g\'ri tartibga qo\'ying',
        lines: ['Telegramni och', 'Do\'stingni chatini top', 'Xabarni yoz', 'Yuborish tugmasini bos'],
        byOutput: false,
        explanation: 'Algoritmda tartib muhim: xabarni yozmasdan yuborib bo\'lmaydi.',
        topic: 'Algoritm',
      ),
      SingleChoice(
        prompt: '"Agar havo sovuq bo\'lsa, kurtka kiy" — bu algoritmning qaysi qurilish bloki?',
        options: ['Ketma-ketlik', 'Shart', 'Takrorlash', 'Natija'],
        correct: 1,
        explanation: '"Agar..." — shart. Dartda u `if` bilan yoziladi.',
        topic: 'Shart',
      ),
      SingleChoice(
        prompt: '"Barcha uy vazifalari tugaguncha bittadan bajar" — bu qaysi blok?',
        options: ['Shart', 'Takrorlash', 'Ketma-ketlik', 'Hech qaysi'],
        correct: 1,
        explanation: '"...guncha" — takrorlash (sikl). Dartda `while` yoki `for` bilan yoziladi.',
        topic: 'Takrorlash',
      ),
      TrueFalse(
        prompt: '"Biroz kut, keyin biroz tuz sol" — bu yaxshi algoritm qadami.',
        answer: false,
        explanation: 'Yaxshi algoritm aniq bo\'lishi kerak: "3 daqiqa kut", "1 qoshiq tuz sol".',
        topic: 'Algoritm',
      ),
    ],
    summary: [
      'Algoritm — aniq, tartibli, chekli qadamlar',
      'Uch asosiy blok: ketma-ketlik, shart, takrorlash',
      'Avval algoritmni o\'yla — keyin kod yoz',
    ],
    next: 'Keyingi darsda dasturlar ishlaydigan "dunyo" — ma\'lumot, fayl, papka va operatsion tizim bilan tanishamiz.',
    revisionTip: 'Bugun qilgan istalgan ishingizni (masalan, do\'konga borish) shart va takrorlash bilan qadamlarga bo\'lib yozing.',
  ),

  // ───────────────────────── 0.4 ─────────────────────────
  Lesson(
    id: 'l0_data_os',
    title: 'Ma\'lumot, fayl va operatsion tizim',
    subtitle: 'Kompyuter ma\'lumotni qanday saqlaydi va boshqaradi',
    icon: Icons.folder_open_rounded,
    minutes: 9,
    xp: 40,
    skills: ['found.os'],
    prerequisites: ['Algoritm — qadam-baqadam fikrlash'],
    objectives: [
      'Ma\'lumot turlarini (son, matn, ha/yo\'q) ajrata olasiz',
      'Fayl, papka va yo\'l (path) tushunchalarini bilasiz',
      'Operatsion tizim nima qilishini tushunasiz',
    ],
    intro: [
      ParaBlock('**Ma\'lumot** (data) — kompyuter saqlaydigan va qayta ishlaydigan har qanday axborot: ismingiz, yoshingiz, rasm, qo\'shiq, xabar.'),
      ParaBlock('Dasturlashda ma\'lumotlar **turlarga** bo\'linadi. Eng asosiylari:'),
      BulletsBlock([
        '**Son** — 18, 3.14, -5 (yosh, narx, harorat)',
        '**Matn** — "Ali", "Toshkent" (ism, manzil, xabar)',
        '**Mantiqiy** — ha/yo\'q, ya\'ni true/false (tizimga kirganmi? to\'langanmi?)',
      ]),
      ParaBlock('Ma\'lumot uzoq saqlanishi uchun **fayl**larga yoziladi. Fayllar **papka**larga (folder, directory) joylanadi. Papkalar ichida yana papkalar bo\'lishi mumkin — bu daraxtga o\'xshaydi.'),
      ParaBlock('Faylning to\'liq manzili **yo\'l** (path) deyiladi: `/home/ali/loyihalar/main.dart`. Har bir `/` — bir papka ichiga kirish.'),
      ParaBlock('**Operatsion tizim** (OS) — kompyuterning "boshqaruvchisi": fayllarni, xotirani, ilovalarni va qurilmalarni boshqaradi. Android, iOS, Windows, macOS, Linux — operatsion tizimlar. Flutter ilovasi aynan OS ustida ishlaydi.'),
    ],
    analogy: AnalogyBlock(
      'Kutubxona',
      'Operatsion tizim — kutubxonachi. Papkalar — javonlar, fayllar — kitoblar, yo\'l (path) esa "3-qavat, 5-javon, 2-qator" kabi manzil. Siz kitobni nomi bo\'yicha so\'raysiz, kutubxonachi uni topib beradi.',
      icon: Icons.local_library_outlined,
    ),
    why: 'Dasturchi doim fayllar bilan ishlaydi: kod fayllari, rasm, sozlamalar. Flutter loyihasi ham papkalar daraxti. Terminalda ishlash uchun yo\'l (path) tushunchasini bilish shart.',
    where: [
      'Flutter loyihasida kod `lib/main.dart` faylida yoziladi',
      'Rasmlar `assets/` papkasida saqlanadi',
      'Telefon OS ilovalarga ruxsat beradi (kamera, joylashuv)',
    ],
    terms: [
      TermBlock(term: 'Data', uz: 'Ma\'lumot', meaning: 'Saqlanadigan va qayta ishlanadigan axborot.', why: 'Dasturlar ma\'lumot bilan ishlaydi.'),
      TermBlock(term: 'File', uz: 'Fayl', meaning: 'Nomga ega, saqlangan ma\'lumot bo\'lagi.', why: 'Kod ham fayllarda yoziladi.', example: 'main.dart'),
      TermBlock(term: 'Directory / Folder', uz: 'Papka (katalog)', meaning: 'Fayllar va boshqa papkalar joylashadigan joy.', why: 'Loyihani tartibli saqlash uchun.', example: 'lib/'),
      TermBlock(term: 'Path', uz: 'Yo\'l (manzil)', meaning: 'Fayl yoki papkaning to\'liq manzili.', why: 'Terminal va dastur faylni shu orqali topadi.', example: '/home/ali/main.dart'),
      TermBlock(term: 'Operating System (OS)', uz: 'Operatsion tizim', meaning: 'Qurilma resurslarini boshqaruvchi asosiy dastur.', why: 'Ilovalar OS ustida ishlaydi.', example: 'Android, iOS'),
    ],
    animation: AnimationBlock('file_tree', 'Papkalar daraxti: loyiha → lib → main.dart. Har bir tugunni bosing.'),
    example: CodeBlock(
      r'''void main() {
  print('Son: 18');
  print('Matn: Toshkent');
  print('Mantiqiy: true');
  print('Yo\'l: /home/ali/loyiha/lib/main.dart');
}''',
      title: 'Ma\'lumot turlari misolida',
      expectedOutput: "Son: 18\nMatn: Toshkent\nMantiqiy: true\nYo'l: /home/ali/loyiha/lib/main.dart\n",
    ),
    quiz: [
      MatchPairs(
        prompt: 'Ma\'lumotni turi bilan moslang',
        pairs: [('25', 'Son'), ('"Samarqand"', 'Matn'), ('true', 'Mantiqiy (ha/yo\'q)'), ('3.5', 'Kasr son')],
        explanation: 'Har bir ma\'lumotning turi bor. Keyingi darslarda ular Dartda int, String, bool va double deb ataladi.',
        topic: 'Ma\'lumot turlari',
      ),
      SingleChoice(
        prompt: '`/home/ali/loyiha/main.dart` yo\'lida `main.dart` qaysi papka ichida?',
        options: ['home', 'ali', 'loyiha', 'Hech qaysi'],
        correct: 2,
        explanation: 'Fayl o\'zidan oldingi oxirgi papka — `loyiha` ichida joylashgan.',
        topic: 'Path',
      ),
      SingleChoice(
        prompt: 'Qaysi biri operatsion tizim EMAS?',
        options: ['Android', 'iOS', 'Flutter', 'Windows'],
        correct: 2,
        explanation: 'Flutter — ilova yaratish uchun framework. U operatsion tizimlar ustida ishlaydi.',
        topic: 'OS',
      ),
    ],
    summary: [
      'Ma\'lumot turlari: son, matn, mantiqiy (true/false)',
      'Fayllar papkalarda, papkalar daraxt bo\'lib joylashadi',
      'Path — faylning to\'liq manzili',
      'OS — qurilmani boshqaruvchi tizim; ilovalar uning ustida ishlaydi',
    ],
    next: 'Keyingi darsda dasturlar qanday turlarga bo\'linishini — frontend, backend, mobil va web dasturlarni bilib olamiz.',
    revisionTip: 'Telefoningiz fayl menejerini oching va biror rasmning to\'liq yo\'lini (path) toping.',
  ),

  // ───────────────────────── 0.5 ─────────────────────────
  Lesson(
    id: 'l0_app_types',
    title: 'Frontend, Backend, Mobil va Web',
    subtitle: 'Ilovalar qanday tuzilgan va qanday "gaplashadi"',
    icon: Icons.devices_rounded,
    minutes: 10,
    xp: 40,
    skills: ['found.architecture'],
    prerequisites: ['Ma\'lumot, fayl va operatsion tizim'],
    objectives: [
      'Frontend va backend farqini tushuntira olasiz',
      'Mobil, web va desktop ilovalarni ajrata olasiz',
      'API orqali ma\'lumot almashinuvini tushunasiz',
    ],
    intro: [
      ParaBlock('Zamonaviy ilovalar odatda ikki qismdan iborat:'),
      BulletsBlock([
        '**Frontend** — foydalanuvchi ko\'radigan va bosadigan qism: tugmalar, matnlar, rasmlar, animatsiyalar. Flutter — frontend yaratish vositasi.',
        '**Backend** — "sahna orti": serverda ishlaydigan, ma\'lumotlarni saqlaydigan va qayta ishlaydigan qism. Masalan, Telegram xabarlaringiz serverda saqlanadi.',
      ]),
      ParaBlock('Frontend va backend bir-biri bilan **API** orqali "gaplashadi". API (Application Programming Interface) — "qanday so\'rash va qanday javob olish" qoidalari.'),
      ParaBlock('Ilova turlari:'),
      BulletsBlock([
        '**Mobil ilova** — telefonga o\'rnatiladi (Android, iOS)',
        '**Web ilova** — brauzerda ochiladi (Chrome, Safari)',
        '**Desktop ilova** — kompyuterga o\'rnatiladi (Windows, macOS)',
      ]),
      CalloutBlock(CalloutKind.success, 'Flutterning kuchi', 'Flutter bilan **bitta kod** yozib, undan Android, iOS, Web va Desktop ilovalarini chiqarish mumkin. Siz hozir foydalanayotgan FLUTTER_KITOB ham aynan shunday yaratilgan!'),
    ],
    analogy: AnalogyBlock(
      'Restoran',
      'Frontend — restoran zali: menyu, stol, ofitsiant. Backend — oshxona: taom tayyorlanadi, mahsulotlar saqlanadi. API — ofitsiant: buyurtmangizni (so\'rov) oshxonaga olib boradi va taomni (javob) olib keladi. Siz oshxonani ko\'rmaysiz, lekin u ishlayapti.',
      icon: Icons.storefront_outlined,
    ),
    why: 'Flutter dasturchi asosan frontend yozadi, lekin backend bilan API orqali ishlashni bilishi shart: login, ma\'lumotlarni yuklash, to\'lov — hammasi API orqali.',
    where: [
      'Ob-havo ilovasi API dan haroratni so\'raydi',
      'Login — login/parol backendga yuboriladi va tekshiriladi',
      'Instagram lentasi — postlar backenddan yuklanadi',
    ],
    terms: [
      TermBlock(term: 'Frontend', uz: 'Foydalanuvchi interfeysi qismi', meaning: 'Ilovaning ko\'rinadigan qismi.', why: 'Flutter aynan frontend uchun.'),
      TermBlock(term: 'Backend', uz: 'Server qismi', meaning: 'Ma\'lumotlarni saqlovchi va qayta ishlovchi qism.', why: 'Ko\'p ilovalar ma\'lumotni serverdan oladi.'),
      TermBlock(term: 'Server', uz: 'Server', meaning: 'Boshqa qurilmalarga xizmat ko\'rsatuvchi doimiy ishlaydigan kompyuter.', why: 'Backend serverda ishlaydi.'),
      TermBlock(term: 'API', uz: 'Dasturlararo interfeys', meaning: 'Dasturlar bir-biri bilan ma\'lumot almashish qoidalari.', why: 'Frontend backenddan shu orqali ma\'lumot oladi.', example: 'GET /weather?city=Toshkent'),
      TermBlock(term: 'Request / Response', uz: 'So\'rov / Javob', meaning: 'Klient yuboradigan so\'rov va server qaytaradigan javob.', why: 'Har bir API chaqiruvi shu juftlikdan iborat.'),
    ],
    animation: AnimationBlock('client_server', 'Telefon (klient) → so\'rov → server → javob → ekran.'),
    quiz: [
      SingleChoice(
        prompt: 'Tugmalar, ranglar va animatsiyalar qaysi qismga tegishli?',
        options: ['Backend', 'Frontend', 'Ma\'lumotlar bazasi', 'Operatsion tizim'],
        correct: 1,
        explanation: 'Foydalanuvchi ko\'radigan hamma narsa — frontend.',
        topic: 'Frontend',
      ),
      SingleChoice(
        prompt: 'Restoran misolida API kim?',
        options: ['Oshpaz', 'Ofitsiant', 'Mijoz', 'Stol'],
        correct: 1,
        explanation: 'Ofitsiant so\'rovni oshxonaga (backend) olib boradi va javobni qaytaradi — xuddi API kabi.',
        topic: 'API',
      ),
      TrueFalse(
        prompt: 'Flutter bilan bitta kod bazasidan ham Android, ham iOS, ham Web ilova chiqarish mumkin.',
        answer: true,
        explanation: 'Bu Flutterning asosiy afzalligi — cross-platform (ko\'p platformali) ishlab chiqish.',
        topic: 'Flutter',
      ),
      ArrangeLines(
        prompt: 'Ob-havo ilovasida harorat qanday chiqadi? Tartibga qo\'ying',
        lines: ['Foydalanuvchi shaharni tanlaydi', 'Ilova API ga so\'rov yuboradi', 'Server haroratni javob qilib qaytaradi', 'Ilova haroratni ekranda ko\'rsatadi'],
        byOutput: false,
        explanation: 'So\'rov → server → javob → ekran: bu klient-server modeli.',
        topic: 'API',
      ),
    ],
    summary: [
      'Frontend — ko\'rinadigan qism, backend — server qismi',
      'API — ular orasidagi "ofitsiant"',
      'Ilova turlari: mobil, web, desktop',
      'Flutter — bitta kod bilan ko\'p platforma',
    ],
    next: 'Oxirgi tayyorgarlik darsida dasturchining asboblari — IDE, terminal, SDK va Git bilan tanishamiz.',
    revisionTip: 'Sevimli ilovangizni oling: undagi 3 ta frontend elementi va backenddan keladigan 3 ta ma\'lumotni yozing.',
  ),

  // ───────────────────────── 0.6 ─────────────────────────
  Lesson(
    id: 'l0_tools',
    title: 'Dasturchi asboblari: IDE, Terminal, SDK, Git',
    subtitle: 'Professional dasturchining ish stoli',
    icon: Icons.handyman_outlined,
    minutes: 12,
    xp: 50,
    skills: ['found.tools', 'terminal.basics'],
    prerequisites: ['Frontend, Backend, Mobil va Web'],
    objectives: [
      'IDE va VS Code nima uchun kerakligini bilasiz',
      'Terminal va buyruq tushunchasini anglaysiz',
      'SDK va Git nima ekanini tushuntira olasiz',
    ],
    intro: [
      ParaBlock('Dasturchi bir nechta asosiy asbob bilan ishlaydi:'),
      HeadingBlock('IDE va VS Code'),
      ParaBlock('**IDE** (Integrated Development Environment) — kod yozish uchun maxsus muhit: rangli kod, xatolarni ko\'rsatish, avtomatik to\'ldirish, ishga tushirish tugmasi. **VS Code** va **Android Studio** — Flutter dasturchilarining eng mashhur IDE lari. Ushbu ilovadagi "Kod maydoni" ham kichik IDE.'),
      HeadingBlock('Terminal'),
      ParaBlock('**Terminal** — kompyuterga matnli buyruqlar beradigan oyna. Sichqoncha bilan papka ochish o\'rniga `cd papka` deb yozasiz. Flutter dasturchi terminalda `flutter create`, `flutter run` kabi buyruqlarni har kuni ishlatadi.'),
      HeadingBlock('SDK'),
      ParaBlock('**SDK** (Software Development Kit) — biror platforma uchun dastur yaratish asboblari to\'plami: kompilyator, kutubxonalar, buyruqlar. **Flutter SDK** ichida Dart SDK ham bor.'),
      HeadingBlock('Git va GitHub'),
      ParaBlock('**Git** — kodning har bir o\'zgarishini saqlab boradigan tizim ("vaqt mashinasi"). Xato qilsangiz, oldingi holatga qaytasiz. **GitHub** — Git loyihalarini internetda saqlash va jamoa bilan ishlash xizmati.'),
    ],
    analogy: AnalogyBlock(
      'Usta ustaxonasi',
      'IDE — ustaxonadagi ish stoli, SDK — asboblar qutisi (bolg\'a, arra, o\'lchagich), terminal — ustaga tez buyruq berish usuli, Git esa har bir bosqichni suratga olib boruvchi kamera: biror narsa buzilsa, suratga qarab qayta tiklaysiz.',
      icon: Icons.construction_outlined,
    ),
    why: 'Flutter loyihasini yaratish, ishga tushirish, tekshirish va do\'kon (Play Store, App Store) ga chiqarish — hammasi shu asboblar orqali bajariladi.',
    where: [
      '`flutter create` — terminalda yangi loyiha yaratish',
      'VS Code — kod yozish va debug qilish',
      'GitHub — jamoaviy ishlash va portfolio',
    ],
    terms: [
      TermBlock(term: 'IDE', uz: 'Integratsiyalashgan ishlab chiqish muhiti', meaning: 'Kod yozish, tekshirish va ishga tushirish uchun dastur.', why: 'Ishni tez va xatosiz qiladi.', example: 'VS Code, Android Studio'),
      TermBlock(term: 'Terminal / Shell', uz: 'Terminal / Buyruq qobig\'i', meaning: 'Matnli buyruqlar orqali kompyuterni boshqarish oynasi.', why: 'Flutter buyruqlari terminalda ishlatiladi.', example: 'flutter run'),
      TermBlock(term: 'Command', uz: 'Buyruq', meaning: 'Terminalga yoziladigan ko\'rsatma.', why: 'Har bir amal buyruq bilan bajariladi.', example: 'pwd, ls, cd'),
      TermBlock(term: 'SDK', uz: 'Dasturiy ishlab chiqish to\'plami', meaning: 'Platforma uchun dastur yaratish asboblari.', why: 'Flutter SDK siz Flutter ilova yaratib bo\'lmaydi.'),
      TermBlock(term: 'Git', uz: 'Versiyalarni boshqarish tizimi', meaning: 'Kod o\'zgarishlari tarixini saqlovchi tizim.', why: 'Xatodan qaytish va jamoada ishlash uchun.', example: 'git commit'),
      TermBlock(term: 'Repository', uz: 'Repozitoriy', meaning: 'Git kuzatadigan loyiha papkasi.', why: 'Loyiha tarixi shu yerda saqlanadi.'),
    ],
    animation: AnimationBlock('terminal', 'Terminal: buyruq yoziladi → kompyuter bajaradi → natija chiqadi.'),
    extra: [
      TerminalDemoBlock([
        ('pwd', '/home/student'),
        ('mkdir my_app', ''),
        ('cd my_app', ''),
        ('pwd', '/home/student/my_app'),
        ('flutter --version', 'Flutter 3.47.7 • channel stable\nTools • Dart 3.13.5'),
      ], caption: 'Terminalda birinchi buyruqlar. "Terminal laboratoriyasi"da ularni o\'zingiz sinab ko\'rasiz.'),
      CalloutBlock(CalloutKind.tip, 'Amaliyot', '"Amaliyot → Terminal laboratoriyasi" bo\'limida xavfsiz virtual terminal bor. U yerda `pwd`, `ls`, `mkdir`, `cd` buyruqlarini o\'zingiz yozib ko\'ring.'),
    ],
    quiz: [
      MatchPairs(
        prompt: 'Asbobni vazifasi bilan moslang',
        pairs: [('IDE', 'Kod yozish muhiti'), ('Terminal', 'Matnli buyruqlar oynasi'), ('SDK', 'Platforma asboblari to\'plami'), ('Git', 'Kod tarixini saqlash')],
        explanation: 'Har bir asbob dasturchining ish jarayonida o\'z o\'rniga ega.',
        topic: 'Asboblar',
      ),
      SingleChoice(
        prompt: 'Qaysi buyruq hozirgi papka yo\'lini ko\'rsatadi?',
        options: ['ls', 'cd', 'pwd', 'mkdir'],
        correct: 2,
        explanation: '`pwd` — print working directory (joriy papkani chiqar).',
        topic: 'Terminal',
      ),
      TrueFalse(
        prompt: 'Flutter SDK ichida Dart SDK ham mavjud.',
        answer: true,
        explanation: 'Flutter Dart tilida ishlaydi, shuning uchun Flutter SDK Dart SDK ni o\'z ichiga oladi.',
        topic: 'SDK',
      ),
    ],
    summary: [
      'IDE — kod yozish muhiti (VS Code, Android Studio)',
      'Terminal — matnli buyruqlar bilan ishlash',
      'SDK — dastur yaratish asboblari (Flutter SDK)',
      'Git — kod tarixi; GitHub — onlayn saqlash va jamoa',
    ],
    next: 'Tayyorgarlik tugadi! Endi Dart tiliga sho\'ng\'iymiz: Dart nima va nega yaratilgan?',
    revisionTip: 'Terminal laboratoriyasida 5 ta buyruqni sinab ko\'ring: pwd, ls, mkdir, cd, clear.',
  ),
];
