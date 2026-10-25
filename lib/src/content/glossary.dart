import 'curriculum.dart';
import 'model.dart';

/// Darslardagi barcha atamalar + qo'shimcha umumiy atamalar.
final List<GlossaryTerm> glossary = () {
  final seen = <String>{};
  final out = <GlossaryTerm>[];
  for (final lv in curriculum) {
    for (final l in lv.lessons) {
      for (final t in l.terms) {
        final key = t.term.toLowerCase();
        if (!seen.add(key)) continue;
        out.add(GlossaryTerm(
          term: t.term,
          uz: t.uz,
          meaning: t.why.isEmpty ? t.meaning : '${t.meaning} ${t.why}',
          example: t.example,
          lessonId: l.id,
          category: lv.track.title,
        ));
      }
    }
  }
  for (final t in _extraTerms) {
    if (seen.add(t.term.toLowerCase())) out.add(t);
  }
  out.sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
  return out;
}();

const _extraTerms = [
  GlossaryTerm(term: 'Widget', uz: 'Vidjet', meaning: 'Flutterda ekrandagi har bir element (matn, tugma, joylashuv) — widget. Ilova widgetlar daraxtidan quriladi.', example: "Text('Salom')", category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'StatelessWidget', uz: 'Holatsiz widget', meaning: 'O\'zgarmaydigan, faqat berilgan ma\'lumotdan chiziladigan widget.', category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'StatefulWidget', uz: 'Holatli widget', meaning: 'Ichki holati (state) o\'zgarganda qayta chiziladigan widget. setState() bilan yangilanadi.', category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'setState', uz: 'Holatni yangilash', meaning: 'State o\'zgarganini Flutterga aytadi va build() qayta chaqiriladi.', category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'BuildContext', uz: 'Qurilish konteksti', meaning: 'Widgetning daraxtdagi joyi. Theme, MediaQuery, Navigator ga shu orqali murojaat qilinadi.', category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'Hot restart', uz: 'Issiq qayta ishga tushirish', meaning: 'Ilovani holatini tozalab qayta ishga tushirish (hot reload dan kuchliroq).', category: 'Flutter akademiyasi'),
  GlossaryTerm(term: 'Package', uz: 'Paket', meaning: 'Boshqalar yozgan va pub.dev da tarqatilgan qayta ishlatiladigan kod kutubxonasi.', example: 'flutter pub add http', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'pubspec.yaml', uz: 'Loyiha sozlamalari fayli', meaning: 'Loyiha nomi, versiyasi, paketlari (dependencies) va resurslari yoziladigan fayl.', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'Future', uz: 'Kelajakdagi qiymat', meaning: 'Hozir emas, keyinroq tayyor bo\'ladigan natija (masalan, internetdan javob).', example: 'Future<String>', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'async / await', uz: 'Asinxron / kutish', meaning: 'Uzoq davom etadigan amallarni dasturni to\'xtatmasdan kutish usuli.', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'Stream', uz: 'Oqim', meaning: 'Vaqt o\'tishi bilan ketma-ket keladigan qiymatlar oqimi.', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'JSON', uz: 'Ma\'lumot almashinuv formati', meaning: 'Matn ko\'rinishidagi ma\'lumot formati; API lar odatda JSON qaytaradi.', example: '{"ism": "Ali"}', category: 'Dart akademiyasi'),
  GlossaryTerm(term: 'Debugging', uz: 'Xatolarni tuzatish', meaning: 'Dasturdagi xatoning sababini topish va bartaraf etish jarayoni.', category: 'Asoslar'),
  GlossaryTerm(term: 'Runtime', uz: 'Ish vaqti', meaning: 'Dastur bajarilayotgan payt. Ish vaqtidagi xatolar faqat dastur ishlaganda chiqadi.', category: 'Asoslar'),
  GlossaryTerm(term: 'Compile-time', uz: 'Kompilyatsiya vaqti', meaning: 'Kod ishga tushishidan oldingi tekshiruv bosqichi. Dart ko\'p xatolarni shu yerda topadi.', category: 'Asoslar'),
  GlossaryTerm(term: 'Refactoring', uz: 'Qayta tuzish', meaning: 'Kod xatti-harakatini o\'zgartirmasdan uni toza va tushunarli qilish.', category: 'Professional'),
  GlossaryTerm(term: 'Unit test', uz: 'Birlik testi', meaning: 'Funksiya yoki class to\'g\'ri ishlashini avtomatik tekshiruvchi kichik test.', category: 'Professional'),
];

List<GlossaryTerm> searchGlossary(String q) {
  final s = q.trim().toLowerCase();
  if (s.isEmpty) return glossary;
  return glossary
      .where((t) => t.term.toLowerCase().contains(s) || t.uz.toLowerCase().contains(s) || t.meaning.toLowerCase().contains(s))
      .toList();
}
