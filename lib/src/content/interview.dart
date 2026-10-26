/// Dasturchilar uchun intervyu tayyorgarligi: Dart va Flutter bo'yicha eng ko'p
/// so'raladigan savollar. Har birida — intervyuda aytiladigan qisqa javob,
/// chuqurroq izoh va (kerak bo'lsa) kod.
///
/// Kontent qo'lda yozilgan va tekshirilgan — internet yoki AI talab qilmaydi.
library;

enum InterviewTrack {
  dart('Dart'),
  flutter('Flutter');

  const InterviewTrack(this.title);
  final String title;
}

enum InterviewLevel {
  junior('Junior'),
  middle('Middle');

  const InterviewLevel(this.title);
  final String title;
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.track,
    required this.level,
    required this.question,
    required this.answer,
    required this.details,
    this.code,
    this.lessonId,
  });

  final String id;
  final InterviewTrack track;
  final InterviewLevel level;
  final String question;

  /// 1–2 gapli javob — intervyuda birinchi aytiladigan fikr.
  final String answer;

  /// Chuqurroq izoh (RichUz formatida: **qalin**, `kod`).
  final String details;
  final String? code;

  /// Mavzu o'rgatilgan dars (bo'lsa).
  final String? lessonId;
}

const interviewQuestions = <InterviewQuestion>[
  // ───────────────────────────── Dart · Junior ─────────────────────────────
  InterviewQuestion(
    id: 'd_var_final_const',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: "var, final va const o'rtasidagi farq nima?",
    answer: "var — qiymati o'zgaradigan o'zgaruvchi; final — bir marta beriladi, ish vaqtida (runtime) aniqlanishi mumkin; const — kompilyatsiya vaqtida ma'lum bo'lgan, butunlay o'zgarmas qiymat.",
    details: "`final` obyektning **havolasini** qotiradi, lekin obyektning ichi o'zgarishi mumkin: `final list = [1]; list.add(2);` ishlaydi. `const` esa chuqur o'zgarmas: `const [1, 2]` ga element qo'shib bo'lmaydi. Bir xil `const` qiymatlar xotirada **bitta** nusxa bo'ladi (canonicalization) — Flutter'da `const` widgetlar shu sababli qayta qurilmaydi.",
    code: r'''final now = DateTime.now(); // OK: runtime qiymat
// const now2 = DateTime.now(); // XATO: kompilyatsiyada noma'lum
const pi = 3.14159;           // OK

final items = [1, 2];
items.add(3);                 // OK: ichi o'zgaradi
// items = [];                // XATO: havola qotgan''',
    lessonId: 'l1_var_final_const',
  ),
  InterviewQuestion(
    id: 'd_null_safety',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: 'Sound null safety nima va ?, !, ?? operatorlari nima qiladi?',
    answer: "Dart'da tur sukut bo'yicha null bo'la olmaydi; null bo'lishi mumkin bo'lsa tur oxiriga ? qo'yiladi. Kompilyator null xatolarini ishga tushirishdan oldin ushlaydi.",
    details: "`String?` — null bo'lishi mumkin. `?.` — obyekt null bo'lsa chaqiruvni o'tkazib, null qaytaradi. `??` — chap tomon null bo'lsa o'ng tomonni oladi. `!` — \"bu null emas, ishoning\" degani: agar baribir null bo'lsa, **runtime xato** beradi, shuning uchun kam va ongli ishlatiladi. \"Sound\" — tur tizimi null emas degan bo'lsa, qiymat haqiqatan null bo'la olmaydi.",
    code: r'''String? name;
print(name?.length);      // null
print(name ?? 'Mehmon');  // Mehmon
name ??= 'Ali';           // null bo'lsa beradi
print(name!.length);      // 3 — endi xavfsiz''',
    lessonId: 'l2_null_safety',
  ),
  InterviewQuestion(
    id: 'd_late',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: 'late kalit so\'zi nima uchun kerak?',
    answer: "Null bo'lmaydigan o'zgaruvchini e'lon qilib, qiymatini keyinroq berish uchun. Qiymat berilmasdan o'qilsa — runtime xato.",
    details: "Ikki holatda qo'llanadi: 1) qiymat konstruktordan keyin aniqlanadi (masalan, `initState` da); 2) **dangasa (lazy) hisoblash**: `late final x = og'irHisob();` — `x` birinchi marta o'qilganda hisoblanadi. Ortiqcha ishlatish null safety foydasini yo'qotadi.",
    code: r'''class Profil {
  late final String token; // keyin beriladi
  late final int hisob = _ogirHisob(); // birinchi o'qishda
  int _ogirHisob() => 42;
}''',
  ),
  InterviewQuestion(
    id: 'd_equality',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: '== va identical() farqi nima?',
    answer: "identical() ikki havola aynan bitta obyektmi — shuni tekshiradi. == esa qiymat tengligini tekshiradi va klassda qayta aniqlanishi (override) mumkin.",
    details: "Sukut bo'yicha `==` ham havola tengligi. Qiymat obyektlarida (`Point(1,2) == Point(1,2)`) `operator ==` va **`hashCode`** ni birga override qilish kerak — aks holda `Set`/`Map` noto'g'ri ishlaydi. Dart 3 dagi **record** turlari (`(1, 2)`) qiymat bo'yicha avtomatik tenglashadi.",
    code: r'''class Point {
  const Point(this.x, this.y);
  final int x, y;
  @override
  bool operator ==(Object o) => o is Point && o.x == x && o.y == y;
  @override
  int get hashCode => Object.hash(x, y);
}''',
  ),
  InterviewQuestion(
    id: 'd_collections',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: 'List, Set va Map qachon ishlatiladi?',
    answer: "List — tartibli, takrorlanishi mumkin bo'lgan elementlar; Set — takrorlanmas elementlar, tez \"bormi?\" tekshiruvi; Map — kalit → qiymat juftliklari.",
    details: "`List` da `contains` — **O(n)**, `Set` va `Map` kalitida esa o'rtacha **O(1)**. Shuning uchun \"bu foydalanuvchi ko'rganmi?\" kabi tekshiruvlar uchun `Set` to'g'ri tanlov. Dart'da `{}` sukut bo'yicha **Map**: bo'sh set uchun `<int>{}` deb yoziladi.",
    code: r'''final ranglar = ['qizil', "ko'k", 'qizil']; // 3 ta
final noyob = ranglar.toSet();               // {qizil, ko'k}
final yosh = {'Ali': 20, 'Vali': 25};
print(yosh['Ali']); // 20''',
    lessonId: 'l2_set_collections',
  ),
  InterviewQuestion(
    id: 'd_named_params',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: 'Nomlangan va pozitsion parametrlar, required va sukut qiymatlar qanday ishlaydi?',
    answer: "Pozitsion parametrlar tartib bo'yicha beriladi, [] ichidagilari ixtiyoriy. Nomlangan parametrlar {} ichida, nom bilan beriladi; majburiy bo'lsa required, aks holda sukut qiymat yoki nullable tur kerak.",
    details: "Flutter API lari deyarli doim nomlangan parametrlardan foydalanadi (`Text('a', style: ...)`) — chaqiruv o'qilishi oson bo'ladi va parametr tartibi muhim emas.",
    code: r'''void salom(String ism, {required int yosh, String shahar = 'Toshkent'}) {
  print('$ism, $yosh, $shahar');
}
salom('Ali', yosh: 20);''',
    lessonId: 'l3_parameters',
  ),
  InterviewQuestion(
    id: 'd_closure',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: 'Closure (yopilma) nima?',
    answer: "Funksiya o'zi yaratilgan muhitdagi o'zgaruvchilarni \"eslab qoladi\" va ulardan keyin ham foydalanadi.",
    details: "Har bir chaqiruv o'z muhitini yaratadi, shuning uchun quyidagi misolda ikkita hisoblagich bir-biriga ta'sir qilmaydi. Flutter'da `onPressed: () => setState(...)` ham closure: u `State` obyektini eslab qoladi.",
    code: r'''Function hisoblagich() {
  var n = 0;
  return () => ++n;
}
final a = hisoblagich();
print(a()); // 1
print(a()); // 2''',
    lessonId: 'l3_scope_closure',
  ),
  InterviewQuestion(
    id: 'd_string_immutable',
    track: InterviewTrack.dart,
    level: InterviewLevel.junior,
    question: "Dart'da String o'zgaruvchanmi? Ko'p satrni qanday samarali birlashtirish mumkin?",
    answer: "String o'zgarmas (immutable): har bir + yangi satr yaratadi. Sikl ichida ko'p birlashtirish uchun StringBuffer ishlatiladi.",
    details: "`s += 'x'` 1000 marta bajarilsa, 1000 ta oraliq satr yaratiladi. `StringBuffer` esa bitta buferga yozib, oxirida bir marta `toString()` qiladi. Kichik holatlarda interpolatsiya (`'\$a \$b'`) eng o'qiladigan usul.",
    code: r'''final sb = StringBuffer();
for (var i = 0; i < 3; i++) {
  sb.write('$i,');
}
print(sb.toString()); // 0,1,2,''',
    lessonId: 'l1_strings',
  ),

  // ───────────────────────────── Dart · Middle ─────────────────────────────
  InterviewQuestion(
    id: 'd_future_stream',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'Future va Stream farqi nima?',
    answer: "Future — kelajakda keladigan bitta natija (yoki xato). Stream — vaqt o'tishi bilan keladigan qiymatlar ketma-ketligi.",
    details: "Future misollari: HTTP so'rov, fayl o'qish. Stream misollari: foydalanuvchi bosishlari, WebSocket xabarlari, joylashuv o'zgarishi. Stream **single-subscription** (bitta tinglovchi, sukut) yoki **broadcast** (ko'p tinglovchi) bo'ladi. `await for` bilan stream tugaguncha o'qiladi; `StreamSubscription` ni `cancel()` qilmaslik — xotira oqishining keng tarqalgan sababi.",
    code: r'''Future<int> bitta() async => 42;

Stream<int> sanash() async* {
  for (var i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(milliseconds: 100));
    yield i;
  }
}

Future<void> main() async {
  print(await bitta());
  await for (final n in sanash()) print(n);
}''',
    lessonId: 'l4_streams',
  ),
  InterviewQuestion(
    id: 'd_event_loop',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'Event loop qanday ishlaydi? Microtask va event navbatlari farqi?',
    answer: "Dart bitta oqimda ishlaydi: sinxron kod tugagach, avval microtask navbati to'liq bo'shatiladi, keyin event navbatidan (Timer, I/O) bitta hodisa olinadi va jarayon takrorlanadi.",
    details: "`scheduleMicrotask` va tugallangan `Future` ning `then` lari — **microtask**. `Timer`, `Future.delayed`, I/O — **event**. Shuning uchun quyidagi kod `1 4 3 2` chiqaradi. Microtasklarni cheksiz qo'shish event navbatini \"och\" qoldiradi — UI qotadi.",
    code: r'''import 'dart:async';

void main() {
  print(1);
  Future(() => print(2));          // event
  scheduleMicrotask(() => print(3)); // microtask
  print(4);
}
// 1 4 3 2''',
    lessonId: 'l4_event_loop',
  ),
  InterviewQuestion(
    id: 'd_isolate',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'async/await kodni parallel qiladimi? Isolate nima?',
    answer: "Yo'q: async/await faqat kutishni (I/O) bloklamaslik uchun — hisoblash baribir bitta oqimda. Og'ir CPU ishlar uchun alohida xotirali Isolate ishlatiladi.",
    details: "Katta JSON ni parse qilish yoki rasmni qayta ishlash UI oqimida bajarilsa, kadrlar tushib ketadi (jank). `Isolate.run(() => ...)` (Flutter'da `compute`) ishni boshqa isolatega beradi. Isolatelar xotirani **bo'lishmaydi** — ma'lumot nusxalanib xabar orqali uzatiladi, shuning uchun lock/race condition muammolari kam.",
    code: r'''import 'dart:isolate';

Future<int> yigindi(int n) => Isolate.run(() {
  var s = 0;
  for (var i = 0; i < n; i++) s += i;
  return s;
});''',
  ),
  InterviewQuestion(
    id: 'd_async_errors',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'Asinxron koddagi xatolarni qanday ushlaysiz?',
    answer: "await qilingan Future xatosi oddiy try/catch bilan ushlanadi; await qilinmagan Future xatosi esa catchError yoki zona orqali ushlanmasa, \"unhandled\" bo'lib qoladi.",
    details: "Keng tarqalgan xato: `Future` ni `await` siz chaqirib (\"fire and forget\"), ichidagi xatoni yo'qotish. Bir nechta mustaqil so'rovni parallel kutish uchun `Future.wait([...])` — birortasi xato bersa, umumiy Future ham xato bilan tugaydi. `finally` resurslarni yopish uchun.",
    code: r'''Future<void> yukla() async {
  try {
    final r = await Future.wait([so1(), so2()]);
    print(r);
  } on FormatException catch (e) {
    print('Format xato: $e');
  } catch (e, st) {
    print('Kutilmagan: $e\n$st');
  } finally {
    print('tugadi');
  }
}
Future<int> so1() async => 1;
Future<int> so2() async => 2;''',
    lessonId: 'l4_async_errors',
  ),
  InterviewQuestion(
    id: 'd_mixin_abstract',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'abstract class, interface va mixin farqi nima?',
    answer: "abstract class — qisman tayyor bazaviy klass (extends). Har qanday klass implements orqali interfeys bo'la oladi — barcha a'zolarni qayta yozish shart. mixin — xatti-harakat bo'lagi bo'lib, with orqali bir nechtasini qo'shish mumkin.",
    details: "Dart'da faqat **bitta** `extends`, lekin ko'p `implements` va `with` mumkin. Mixin \"is-a\" emas, \"can-do\" munosabati uchun: `class Ordek extends Qush with Suzuvchi, Uchuvchi`. Dart 3 da `interface class`, `base class`, `final class`, `sealed class` modifikatorlari klass qayerda kengaytirilishi mumkinligini aniq belgilaydi.",
    code: r'''abstract class Shakl {
  double get yuza;
  String tavsif() => 'Yuza: $yuza';
}
mixin Rangli { String rang = "ko'k"; }

class Doira extends Shakl with Rangli {
  Doira(this.r);
  final double r;
  @override
  double get yuza => 3.14 * r * r;
}''',
    lessonId: 'l3_abstract',
  ),
  InterviewQuestion(
    id: 'd_factory',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'factory konstruktor nima va qachon kerak?',
    answer: "Har safar yangi obyekt yaratishi shart bo'lmagan konstruktor: keshdan qaytarishi, kichik turni (subclass) tanlashi yoki JSON dan obyekt yasashi mumkin.",
    details: "Oddiy konstruktor `this` ga kira oladi va doim yangi nusxa yaratadi; `factory` esa `this` ga kira olmaydi, lekin istalgan mos obyektni `return` qiladi. Eng ko'p uchraydigan holat: `factory User.fromJson(Map<String, dynamic> j)`.",
    code: r'''class User {
  const User(this.name);
  final String name;

  factory User.fromJson(Map<String, dynamic> j) =>
      User(j['name'] as String? ?? 'Noma\'lum');
}''',
    lessonId: 'l3_constructors',
  ),
  InterviewQuestion(
    id: 'd_extension',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'Extension method nima?',
    answer: "Mavjud turga (hatto String, int kabi o'zgartirib bo'lmaydigan turlarga) uning kodiga tegmasdan yangi metod qo'shish usuli.",
    details: "Extension statik hal qilinadi: o'zgaruvchining **e'lon qilingan** turiga qarab tanlanadi, shuning uchun `dynamic` o'zgaruvchida ishlamaydi. Flutter'da `context.theme`, `context.mq` kabi yordamchilar ko'pincha extension orqali yoziladi.",
    code: r'''extension on String {
  String get bosHarf => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
print('dart'.bosHarf); // Dart''',
    lessonId: 'l3_enum_mixin_ext',
  ),
  InterviewQuestion(
    id: 'd_sealed_patterns',
    track: InterviewTrack.dart,
    level: InterviewLevel.middle,
    question: 'Dart 3 dagi sealed class va pattern matching nima beradi?',
    answer: "sealed class kichik turlar ro'yxatini yopadi, shuning uchun switch barcha holatlar ko'rib chiqilganini kompilyatsiya vaqtida tekshiradi (exhaustiveness).",
    details: "Holatlarni (`Yuklanmoqda`, `Tayyor`, `Xato`) modellashtirishda yangi holat qo'shilsa, uni ishlatmagan har bir `switch` **kompilyatsiya xatosi** beradi — unutilgan holat bo'lmaydi. Pattern'lar qiymatni bir vaqtda tekshirib, ajratib ham oladi.",
    code: r'''sealed class Holat {}
class Yuklanmoqda extends Holat {}
class Tayyor extends Holat { Tayyor(this.data); final String data; }
class Xato extends Holat { Xato(this.msg); final String msg; }

String matn(Holat h) => switch (h) {
  Yuklanmoqda() => 'Kuting...',
  Tayyor(:final data) => data,
  Xato(:final msg) => 'Xato: $msg',
};''',
    lessonId: 'l2_switch',
  ),

  // ─────────────────────────── Flutter · Junior ───────────────────────────
  InterviewQuestion(
    id: 'f_stateless_stateful',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'StatelessWidget va StatefulWidget farqi nima?',
    answer: "StatelessWidget faqat tashqaridan kelgan ma'lumot asosida chiziladi. StatefulWidget o'zgaruvchan holatni alohida State obyektida saqlaydi va setState orqali qayta chiziladi.",
    details: "Widgetning o'zi doim **o'zgarmas** (immutable) — qayta qurilganda yangi widget obyekti yaratiladi. Holat esa `State` da yashaydi va widget qayta yaratilsa ham saqlanib qoladi. Qoida: holatni iloji boricha **pastda**, kerakli joyda saqlang — shunda kamroq qism qayta quriladi.",
    code: r'''class Hisoblagich extends StatefulWidget {
  const Hisoblagich({super.key});
  @override
  State<Hisoblagich> createState() => _HisoblagichState();
}

class _HisoblagichState extends State<Hisoblagich> {
  int n = 0;
  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => setState(() => n++), child: Text('$n'));
}''',
    lessonId: 'l5_stateful',
  ),
  InterviewQuestion(
    id: 'f_setstate',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'setState aslida nima qiladi?',
    answer: "Berilgan funksiyani darhol bajaradi va elementni \"iflos\" (dirty) deb belgilaydi; keyingi kadrda shu widgetning build metodi qayta chaqiriladi.",
    details: "`setState` sinxron: ekran shu zahoti emas, **keyingi kadrda** yangilanadi. Uni `build` ichida chaqirish mumkin emas, `dispose` dan keyin chaqirish esa xato beradi — asinxron ishdan keyin `if (!mounted) return;` tekshiruvi shuning uchun kerak.",
    code: r'''Future<void> _yukla() async {
  final data = await api.get();
  if (!mounted) return; // sahifa yopilgan bo'lishi mumkin
  setState(() => _data = data);
}''',
    lessonId: 'l5_stateful',
  ),
  InterviewQuestion(
    id: 'f_lifecycle',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'StatefulWidget hayot sikli qanday?',
    answer: "createState → initState (bir marta) → didChangeDependencies → build (ko'p marta) → didUpdateWidget (ota yangi konfiguratsiya bersa) → dispose (bir marta, oxirida).",
    details: "`initState` — controllerlar, obunalar yaratiladigan joy (bu yerda `context` dan InheritedWidget o'qib bo'lmaydi — buning uchun `didChangeDependencies`). `dispose` — `AnimationController`, `TextEditingController`, `StreamSubscription` larni yopish shart, aks holda xotira oqadi.",
    lessonId: 'l5_stateful',
  ),
  InterviewQuestion(
    id: 'f_hot_reload',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'Hot reload va hot restart farqi nima?',
    answer: "Hot reload yangi kodni ishlayotgan ilovaga kiritadi va holatni saqlab, widgetlarni qayta quradi. Hot restart ilovani boshidan ishga tushiradi va holat yo'qoladi.",
    details: "Hot reload `main()` va `initState` ni qayta chaqirmaydi, shuning uchun global o'zgaruvchilar boshlang'ich qiymati yoki `initState` dagi o'zgarishlar ko'rinmasligi mumkin — bunda hot restart kerak. Native kod (Android/iOS) o'zgarsa, to'liq qayta build qilinadi.",
    lessonId: 'e2_flutter_tools',
  ),
  InterviewQuestion(
    id: 'f_constraints',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: '"Constraints go down, sizes go up" qoidasini tushuntiring.',
    answer: "Ota widget bolaga o'lcham chegaralarini (min/max) beradi, bola shu chegaralar ichida o'z o'lchamini tanlab otaga qaytaradi, joylashuvni esa ota belgilaydi.",
    details: "Shuning uchun widget o'zi xohlagan o'lchamda bo'la olmaydi: `Container(width: 100)` ekran to'liq `tight` chegara bersa, baribir ekran kengligida bo'ladi. Mashhur xato — `ListView` ni `Column` ichiga qo'yish: `Column` cheksiz balandlik beradi, `ListView` esa cheksizga cho'zilmoqchi bo'ladi → **unbounded height** xatosi. Yechim: `Expanded` bilan o'rash.",
    code: r'''Column(children: [
  const Text('Sarlavha'),
  Expanded(            // qolgan joyni beradi
    child: ListView(children: const [Text('a'), Text('b')]),
  ),
])''',
    lessonId: 'l5_layout',
  ),
  InterviewQuestion(
    id: 'f_expanded_flexible',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'Expanded va Flexible farqi nima?',
    answer: "Ikkalasi ham Row/Column dagi bo'sh joyni flex bo'yicha bo'ladi. Expanded bolani ajratilgan joyni to'liq egallashga majburlaydi, Flexible esa bolaga undan kichikroq bo'lishga ruxsat beradi.",
    details: "`Expanded` aslida `Flexible(fit: FlexFit.tight)`. Uzun matnni qatorda ellips bilan kesish uchun ko'pincha `Flexible` + `overflow: TextOverflow.ellipsis` ishlatiladi.",
    lessonId: 'l5_stack_expanded',
  ),
  InterviewQuestion(
    id: 'f_listview_builder',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: "Uzun ro'yxat uchun nega ListView.builder ishlatiladi?",
    answer: "ListView.builder elementlarni dangasa (lazy) quradi: faqat ekranda ko'rinadigan va yaqin turganlari yaratiladi. Oddiy ListView(children: ...) esa hammasini birdaniga yaratadi.",
    details: "10 000 qatorli ro'yxatda oddiy `ListView` sekin ochiladi va ko'p xotira oladi. Bir xil balandlikdagi qatorlar uchun `itemExtent` yoki `prototypeItem` berish aylantirish (scroll) hisobini yana tezlashtiradi.",
    code: r'''ListView.builder(
  itemCount: mahsulotlar.length,
  itemBuilder: (context, i) => ListTile(title: Text(mahsulotlar[i])),
)''',
    lessonId: 'l5_lists',
  ),
  InterviewQuestion(
    id: 'f_const_widgets',
    track: InterviewTrack.flutter,
    level: InterviewLevel.junior,
    question: 'Widgetlarda const nima uchun muhim?',
    answer: "const widget kompilyatsiyada bir marta yaratiladi va ota qayta qurilganda ham o'sha nusxa qayta ishlatiladi. Flutter uni o'zgarmagan deb bilib, qayta qurishni o'tkazib yuboradi.",
    details: "Bu bepul optimizatsiya: `const Text('Salom')`, `const SizedBox(height: 8)`. `flutter_lints` dagi `prefer_const_constructors` qoidasi shuni eslatib turadi. Dinamik qiymat (o'zgaruvchi) bor joyda const qo'yib bo'lmaydi.",
    lessonId: 'l5_stateless',
  ),

  // ─────────────────────────── Flutter · Middle ───────────────────────────
  InterviewQuestion(
    id: 'f_three_trees',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: 'Widget, Element va RenderObject daraxtlari nima?',
    answer: "Widget — yengil, o'zgarmas konfiguratsiya. Element — widgetning daraxtdagi joyi va State ni saqlaydigan uzoq yashovchi obyekt. RenderObject — o'lchash, joylashtirish va chizishni bajaradi.",
    details: "`build` har safar yangi **widget**lar qaytaradi, lekin Flutter turi va kaliti bir xil bo'lsa, mavjud **element** va **render object** ni qayta ishlatib, faqat farqni yangilaydi. Shuning uchun widget yaratish arzon, layout/paint esa qimmat. `BuildContext` — aslida shu widgetning **Element**i.",
  ),
  InterviewQuestion(
    id: 'f_keys',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: 'Key nima uchun kerak? ValueKey va GlobalKey farqi?',
    answer: "Key Flutter'ga qaysi widget qaysi elementga (va State ga) mos kelishini aytadi. Ro'yxat elementlari o'rni almashganda yoki o'chirilganda holat noto'g'ri elementga o'tib ketmasligi uchun kerak.",
    details: "Key bo'lmasa, Flutter widgetlarni **tartib va tur** bo'yicha moslaydi: StatefulWidget lar ro'yxatidan birinchisini o'chirsangiz, uning holati keyingisiga \"ko'chib\" qoladi. `ValueKey(item.id)` — ro'yxat elementlari uchun. `GlobalKey` — butun ilova bo'yicha yagona, State ga tashqaridan kirish (masalan, `Form` validatsiyasi) uchun; qimmat, kam ishlating.",
    code: r'''ListView(children: [
  for (final t in vazifalar)
    VazifaTile(key: ValueKey(t.id), vazifa: t),
])''',
  ),
  InterviewQuestion(
    id: 'f_buildcontext',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: "BuildContext nima? Nega ba'zan Theme.of(context) yoki Navigator \"topilmaydi\"?",
    answer: "BuildContext — widgetning daraxtdagi joyi (Element). of(context) chaqiruvlari shu joydan yuqoriga qarab qidiradi; kerakli widget yuqorida bo'lmasa, topilmaydi.",
    details: "Klassik xato: `Scaffold` ni yaratgan `build` ning context i bilan `ScaffoldMessenger`/`Scaffold.of` ni chaqirish — o'sha context Scaffold'dan **yuqorida**. Yechim: `Builder` bilan yangi, pastroqdagi context olish yoki widgetni alohida klassga ajratish. Asinxron kutishdan keyin context ishlatishdan oldin `context.mounted` tekshiriladi.",
    code: r'''Scaffold(
  body: Builder(
    builder: (ctx) => TextButton(
      onPressed: () => Scaffold.of(ctx).openDrawer(), // ctx — Scaffold ichida
      child: const Text('Menyu'),
    ),
  ),
)''',
  ),
  InterviewQuestion(
    id: 'f_inherited',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: 'InheritedWidget qanday ishlaydi va state management bilan aloqasi nima?',
    answer: "InheritedWidget ma'lumotni daraxt bo'ylab pastga samarali uzatadi: dependOnInheritedWidgetOfExactType bilan o'qigan widgetlar u o'zgarganda avtomatik qayta quriladi.",
    details: "`Theme.of`, `MediaQuery.of` — aynan shu mexanizm. Provider, Riverpod kabi kutubxonalar shu g'oyani qulayroq qiladi: ma'lumotni yuqorida saqlash, pastda o'qish va **faqat o'qiganlarni** qayta qurish. Intervyuda bitta yechimni \"eng yaxshi\" deb emas, loyiha hajmiga qarab (setState → InheritedWidget/Provider → Riverpod/Bloc) tanlashni tushuntirish muhim.",
  ),
  InterviewQuestion(
    id: 'f_futurebuilder',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: 'FutureBuilder bilan bog\'liq eng keng tarqalgan xato qaysi?',
    answer: "Future ni to'g'ridan-to'g'ri build ichida yaratish: har safar qayta qurilganda so'rov qaytadan yuboriladi. Future initState da (yoki state manager'da) bir marta yaratilishi kerak.",
    details: "`build` sekundiga 60 martagacha chaqirilishi mumkin (masalan, animatsiya yoki klaviatura ochilganda). `FutureBuilder(future: api.get())` — har safar yangi HTTP so'rov. To'g'risi: `late final _f = api.get();` va `future: _f`. Shuningdek, `snapshot.hasError` holatini ko'rsatishni unutmang.",
    code: r'''class _S extends State<P> {
  late final Future<List<String>> _f = api.yukla(); // bir marta

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _f,
    builder: (context, s) {
      if (s.hasError) return Text('Xato: ${s.error}');
      if (!s.hasData) return const CircularProgressIndicator();
      return Text('${s.data!.length} ta');
    },
  );
}''',
  ),
  InterviewQuestion(
    id: 'f_performance',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: "Flutter ilovasi sekinlashsa (jank), nimalarni tekshirasiz?",
    answer: "Profile rejimda DevTools orqali qaysi kadr 16 ms dan oshayotganini topaman: UI oqimidagi og'ir build/hisob yoki raster oqimidagi qimmat chizish (saveLayer, katta rasm, ortiqcha shaffoflik).",
    details: "Tez-tez uchraydigan sabablar: 1) katta daraxtni `setState` bilan qayta qurish — holatni pastga tushiring, `const` ishlating; 2) `build` ichida og'ir hisob yoki JSON parse — keshlang yoki isolatega o'tkazing; 3) `Opacity`/`ClipRRect` ni animatsiyada ko'p ishlatish; 4) katta rasmlarni `cacheWidth` siz yuklash; 5) uzun ro'yxatda `ListView.builder` o'rniga oddiy `ListView`. `RepaintBoundary` tez-tez qayta chiziladigan qismni ajratadi. O'lchovni **debug** emas, **profile** rejimda qiling.",
  ),
  InterviewQuestion(
    id: 'f_testing',
    track: InterviewTrack.flutter,
    level: InterviewLevel.middle,
    question: 'Flutter\'da qanday test turlari bor?',
    answer: "Unit test — alohida funksiya/klass mantig'i; widget test — bitta widget yoki ekranni soxta muhitda qurib, bosish va matnni tekshirish; integration test — haqiqiy qurilmada butun ilova oqimi.",
    details: "Piramida tamoyili: unit testlar eng ko'p (tez, arzon), integration testlar eng kam (sekin, mo'rt). Widget testda `pump` bitta kadr, `pumpAndSettle` animatsiyalar tugaguncha kutadi — cheksiz animatsiya bo'lsa u hech qachon tugamaydi. Ko'rinish uchun **golden** testlar ham bor.",
    code: r'''testWidgets('hisoblagich oshadi', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: Hisoblagich()));
  await tester.tap(find.text('0'));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});''',
  ),
];
