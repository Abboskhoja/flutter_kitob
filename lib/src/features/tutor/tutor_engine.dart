import 'dart:math' as math;

import 'package:kitob_dart/kitob_dart.dart';

import '../../content/curriculum.dart';
import '../../content/glossary.dart';
import '../../content/model.dart';
import '../quiz/quiz_engine.dart';

enum TutorMode {
  explain('Sodda tushuntir', 'Boshlovchi uchun oddiy so\'zlar va hayotiy misol'),
  steps('Qadam-baqadam', 'Mavzuni bosqichlarga bo\'lib'),
  example('Misol ko\'rsat', 'Ishlaydigan kod namunasi'),
  debug('Xatoni birga topamiz', 'Kodingizdagi xato — ishoradan yechimgacha'),
  review('Kodimni tekshir', 'Kod sifati bo\'yicha maslahatlar'),
  quiz('Meni sinab ko\'r', 'Mavzu bo\'yicha savol'),
  interview('Intervyu mashqi', 'Junior Flutter dasturchi savollari');

  const TutorMode(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class TutorReply {
  const TutorReply(this.text, {this.lessonId, this.suggestions = const [], this.pending});
  final String text;
  final String? lessonId;
  final List<String> suggestions;

  /// Javobni kutayotgan savol (quiz/interview).
  final Object? pending;
}

class _InterviewQ {
  const _InterviewQ(this.q, this.keywords, this.model);
  final String q;
  final List<String> keywords;
  final String model;
}

const _interview = [
  _InterviewQ('`final` va `const` farqi nima?', ['kompilyatsiya', 'ish vaqt', 'bir marta', 'o\'zgarmas'],
      '`final` — qiymati bir marta beriladi va dastur **ishlayotganda** aniqlanishi mumkin. `const` — qiymat **kompilyatsiya vaqtida** ma\'lum bo\'lishi shart. Flutterda `const` widgetlar qayta qurilmaydi — samaradorlik oshadi.'),
  _InterviewQ('`StatelessWidget` va `StatefulWidget` farqi?', ['state', 'holat', 'setstate', 'o\'zgar'],
      'StatelessWidget ichki holatga ega emas — faqat berilgan parametrlardan chiziladi. StatefulWidget o\'zgaruvchan `State` obyektiga ega; `setState()` chaqirilganda `build()` qayta ishlaydi.'),
  _InterviewQ('Null safety nima va `?`, `!`, `??` nima qiladi?', ['null', '?', '!', '??'],
      'Null safety — oddiy tur hech qachon null bo\'lmasligi kafolati. `String?` — null bo\'lishi mumkin; `??` — null bo\'lsa standart qiymat; `?.` — null bo\'lsa chaqirmaydi; `!` — "null emas" deb majburlash (null bo\'lsa xato).'),
  _InterviewQ('`List`, `Set` va `Map` farqi?', ['tartib', 'takror', 'kalit', 'indeks'],
      'List — tartiblangan, takrorlanishi mumkin, indeks bilan. Set — takrorlanmas elementlar. Map — kalit → qiymat juftliklari, kalit bo\'yicha tez qidirish.'),
  _InterviewQ('Abstrakt class va interface (implements) farqi?', ['abstract', 'implements', 'meros', 'shartnoma'],
      'Abstrakt class — undan obyekt yaratilmaydi, qisman amalga oshirilgan kod va abstrakt metodlar bo\'lishi mumkin (`extends` bilan meros olinadi). `implements` — faqat shartnoma: barcha a\'zolar qayta yoziladi; bir nechta interfeysni amalga oshirish mumkin.'),
  _InterviewQ('Hot reload va hot restart farqi?', ['holat', 'state', 'saqla', 'qayta'],
      'Hot reload kod o\'zgarishini ilova holatini saqlagan holda qo\'llaydi. Hot restart ilovani boshidan ishga tushiradi va holat tozalanadi.'),
  _InterviewQ('`async`/`await` va `Future` nima?', ['kelajak', 'kut', 'asinxron', 'future'],
      '`Future` — keyinroq tayyor bo\'ladigan natija. `async` funksiya Future qaytaradi, `await` esa uni dasturni bloklamasdan kutadi (masalan, tarmoq so\'rovi).'),
];

/// Oflayn AI ustoz: javoblar darslar, lug'at va dvigatel natijalariga asoslanadi.
class TutorEngine {
  int _seed = 0;

  static final _stop = {
    'nima', 'nimaga', 'nega', 'qanday', 'qanaqa', 'haqida', 'menga', 'tushuntir', 'tushuntiring', 'aytib', 'ber', 'bering',
    'bu', 'u', 'va', 'yoki', 'uchun', 'kerak', 'nimadir', 'qilib', 'degani', 'ishlaydi', 'ishlatiladi', 'dartda', 'flutterda', 'misol',
  };

  List<String> _words(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9_'ʻ‘’\s-]"), ' ')
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(RegExp(r"['ʻ‘’]"), "'"))
      .map(_stem)
      .where((w) => w.length > 1 && !_stop.contains(w))
      .toList();

  String _stem(String w) {
    for (final suf in const ['larining', 'larni', 'larda', 'lardan', 'larga', 'ning', 'lari', 'lar', 'dan', 'ni', 'da', 'ga', 'ni', 'mi']) {
      if (w.length > suf.length + 2 && w.endsWith(suf)) return w.substring(0, w.length - suf.length);
    }
    return w;
  }

  /// Savolga eng mos dars va atama.
  (Lesson?, GlossaryTerm?) findTopic(String q, {String? lessonId}) {
    final words = _words(q);
    GlossaryTerm? bestTerm;
    var bestTermScore = 0;
    for (final t in glossary) {
      final tw = _words('${t.term} ${t.uz}');
      var score = 0;
      for (final w in words) {
        if (t.term.toLowerCase() == w) score += 6;
        if (tw.contains(w)) score += 3;
      }
      if (score > bestTermScore) {
        bestTermScore = score;
        bestTerm = t;
      }
    }
    Lesson? bestLesson;
    var bestScore = 0;
    for (final l in allLessons) {
      final title = _words('${l.title} ${l.subtitle}');
      final terms = _words(l.terms.map((t) => '${t.term} ${t.uz}').join(' '));
      final skills = l.skills.join(' ').toLowerCase();
      var score = 0;
      for (final w in words) {
        if (title.contains(w)) score += 4;
        if (terms.contains(w)) score += 2;
        if (skills.contains(w)) score += 2;
      }
      if (l.id == lessonId) score += 1;
      if (score > bestScore) {
        bestScore = score;
        bestLesson = l;
      }
    }
    if (bestScore == 0 && lessonId != null) bestLesson = lessonById[lessonId];
    if (bestTerm?.lessonId != null && bestScore < 4) bestLesson = lessonById[bestTerm!.lessonId] ?? bestLesson;
    return (bestScore > 0 || lessonId != null ? bestLesson : null, bestTermScore >= 3 ? bestTerm : null);
  }

  String? _extractCode(String text) {
    final fence = RegExp(r'```(?:dart)?\n?([\s\S]*?)```').firstMatch(text);
    if (fence != null) return fence.group(1);
    if (text.contains('void main') || (text.contains(';') && text.contains('(') && text.split('\n').length > 1)) return text;
    return null;
  }

  TutorReply respond(String message, TutorMode mode, {String? lessonId, Object? pending}) {
    final msg = message.trim();
    // Kutilayotgan javobni baholash
    if (pending is Question) return _gradeQuiz(pending, msg);
    if (pending is _InterviewQ) return _gradeInterview(pending, msg);

    final code = _extractCode(msg);
    if (code != null || mode == TutorMode.debug || mode == TutorMode.review) {
      if (code == null) {
        return const TutorReply('Kodingizni yuboring — uni analyzer bilan tekshirib, bajarib ko\'raman va nima bo\'layotganini tushuntiraman.\n\nKodni ```dart ... ``` ichiga qo\'ying yoki shunchaki joylashtiring.');
      }
      return _aboutCode(code, mode);
    }
    if (mode == TutorMode.quiz) return _askQuiz(msg, lessonId);
    if (mode == TutorMode.interview) return _askInterview();
    if (msg.isEmpty) return const TutorReply('Savolingizni yozing.');

    final (lesson, term) = findTopic(msg, lessonId: lessonId);
    if (lesson == null && term == null) {
      return const TutorReply(
        'Bu savol bo\'yicha bilim bazamda aniq ma\'lumot topilmadi — taxmin qilib noto\'g\'ri gapirmayman.\n\n'
        'Savolni boshqacha so\'rang (masalan: "List nima?", "for sikli qanday ishlaydi?") yoki kodingizni yuboring — uni tekshirib beraman.\n\n'
        'Rasmiy manbalar: dart.dev va docs.flutter.dev',
        suggestions: ['O\'zgaruvchi nima?', 'for sikli qanday ishlaydi?', 'null safety nima?', 'Class va obyekt farqi?'],
      );
    }
    return _explain(lesson, term, mode);
  }

  TutorReply _explain(Lesson? l, GlossaryTerm? t, TutorMode mode) {
    final b = StringBuffer();
    if (t != null) {
      b.writeln('**${t.term}** — ${t.uz}.');
      b.writeln();
      b.writeln(t.meaning);
      if (t.example != null) b.writeln('\nMisol: `${t.example}`');
      b.writeln();
    }
    if (l != null) {
      switch (mode) {
        case TutorMode.steps:
          b.writeln('**${l.title}** — qadam-baqadam:');
          var i = 1;
          for (final o in l.objectives) {
            b.writeln('${i++}. $o');
          }
          b.writeln('\nAsosiy xulosalar:');
          for (final s in l.summary) {
            b.writeln('• $s');
          }
        case TutorMode.example:
          final ex = l.example ?? (l.examples.isEmpty ? null : l.examples.first);
          if (ex != null) {
            final r = KitobDart.run(ex.code);
            b.writeln('Mana ishlaydigan misol ("${l.title}" darsidan):');
            b.writeln('```dart\n${ex.code}\n```');
            b.writeln('Men uni hozir bajarib ko\'rdim. Natija:');
            b.writeln('```\n${r.stdout.trimRight()}\n```');
          } else {
            b.writeln(_firstPara(l));
          }
        default:
          if (t == null) b.writeln(_firstPara(l));
          b.writeln('\n**Hayotiy misol — ${l.analogy.title}:** ${l.analogy.text}');
          b.writeln('\n**Nima uchun kerak:** ${l.why}');
      }
      b.writeln('\n📘 Batafsil: "${l.title}" darsi.');
    }
    return TutorReply(b.toString().trim(), lessonId: l?.id, suggestions: [
      if (mode != TutorMode.example) 'Misol ko\'rsat',
      if (mode != TutorMode.steps) 'Qadam-baqadam tushuntir',
      'Meni sinab ko\'r',
    ]);
  }

  String _firstPara(Lesson l) {
    for (final b in l.intro) {
      if (b is ParaBlock) return b.text;
    }
    return l.subtitle;
  }

  TutorReply _aboutCode(String code, TutorMode mode) {
    final diags = KitobDart.analyze(code);
    final errors = diags.where((d) => d.isError).toList();
    final b = StringBuffer();
    if (errors.isNotEmpty) {
      final d = errors.first;
      b.writeln('Kodni analyzer bilan tekshirdim: **${errors.length} ta xato** topildi.');
      b.writeln();
      b.writeln('**1-ishora:** ${d.line}-qatorga qarang.');
      b.writeln('\n**2-ishora:** ${d.message}');
      if (d.hint != null) b.writeln('\n**3-ishora (qisman yechim):** ${d.hint}');
      b.writeln('\nDart analyzer xabari: `${d.original}`');
      if (errors.length > 1) {
        b.writeln('\nQolgan xatolar:');
        for (final e in errors.skip(1).take(4)) {
          b.writeln('• ${e.line}-qator: ${e.message}');
        }
      }
      b.writeln('\nAvval o\'zingiz tuzatib ko\'ring — keyin kodni qayta yuboring, tekshirib beraman.');
      return TutorReply(b.toString().trim(), suggestions: const ['Yana tushuntir']);
    }
    final r = KitobDart.run(code, options: const ExecutionOptions(trace: true, maxTraceSteps: 60, timeout: Duration(seconds: 2)));
    if (mode == TutorMode.review) {
      b.writeln('Kod kompilyatsiyadan o\'tdi ✓');
      final warnings = diags.where((d) => !d.isError).toList();
      for (final w in warnings) {
        b.writeln('• ${w.line}-qator: ${w.message}');
      }
      b.writeln(_styleTips(code));
      if (r.error != null) b.writeln('\nLekin ishlaganda xato chiqdi: ${r.error!.explanation}');
      return TutorReply(b.toString().trim());
    }
    b.writeln('Kodingizni tahlil qildim va **haqiqatan bajarib ko\'rdim**.');
    b.writeln('\n**Qatorma-qator:**');
    final lines = code.split('\n');
    var shown = 0;
    for (var i = 0; i < lines.length && shown < 14; i++) {
      final ex = _explainLine(lines[i].trim());
      if (ex != null) {
        b.writeln('• ${i + 1}-qator `${lines[i].trim()}` — $ex');
        shown++;
      }
    }
    if (r.trace.isNotEmpty) {
      b.writeln('\n**Bajarilish tartibi:**');
      for (final t in r.trace.where((t) => t.kind != TraceKind.start).take(10)) {
        b.writeln('→ ${t.line}-qator: ${t.description}');
      }
      if (r.trace.length > 11) b.writeln('… (to\'liq ko\'rish uchun "Qadam-baqadam" vizualizatoridan foydalaning)');
    }
    b.writeln('\n**Natija:**\n```\n${r.stdout.trimRight().isEmpty ? '(hech narsa chiqmadi)' : r.stdout.trimRight()}\n```');
    if (r.error != null) b.writeln('\n⚠️ ${r.error!.explanation}${r.error!.hint == null ? '' : '\nMaslahat: ${r.error!.hint}'}');
    return TutorReply(b.toString().trim(), suggestions: const ['Kodimni tekshir', 'Xatoni birga topamiz']);
  }

  String _styleTips(String code) {
    final tips = <String>[];
    if (RegExp(r"'\s*\+\s*\w|\w\s*\+\s*'").hasMatch(code)) tips.add('Satrlarni `+` bilan ulash o\'rniga interpolatsiya ishlating: `\'Salom, \$ism\'`.');
    if (RegExp(r'\bvar\s+\w+\s*=').allMatches(code).length > 3 && !code.contains('final ')) {
      tips.add('Qiymati o\'zgarmaydigan o\'zgaruvchilar uchun `var` o\'rniga `final` ishlating.');
    }
    if (RegExp(r'\b[a-z]\b\s*=').hasMatch(code) && !RegExp(r'for\s*\(').hasMatch(code)) tips.add('Bir harfli nomlar o\'rniga ma\'noli nomlar tanlang (`x` → `narx`).');
    if (code.split('\n').any((l) => l.length > 100)) tips.add('Juda uzun qatorlarni bo\'ling — o\'qish osonlashadi.');
    if (!code.contains('//') && code.split('\n').length > 15) tips.add('Murakkab joylarga qisqa izoh (`//`) qo\'shing.');
    if (tips.isEmpty) return '\nKod toza va tushunarli ko\'rinadi. Barakalla! 👏';
    return '\n**Yaxshilash bo\'yicha maslahatlar:**\n${tips.map((t) => '• $t').join('\n')}';
  }

  String? _explainLine(String l) {
    if (l.isEmpty || l == '}' || l == '{' || l.startsWith('//')) return null;
    if (l.startsWith('import ')) return 'kutubxona ulanmoqda';
    if (l.startsWith('void main')) return 'dastur shu yerdan boshlanadi';
    if (RegExp(r'^class\s+(\w+)').hasMatch(l)) return '`${RegExp(r'^class\s+(\w+)').firstMatch(l)!.group(1)}` nomli class (chizma) e\'lon qilinmoqda';
    final decl = RegExp(r'^(final|const|var|late|int|double|String|bool|num|List<[^>]+>|Map<[^>]+>|Set<[^>]+>)\s+(\w+)\s*=\s*(.+);$').firstMatch(l);
    if (decl != null) {
      final kind = decl.group(1)!;
      final what = switch (kind) { 'final' => 'final (bir marta beriladigan)', 'const' => 'const (o\'zgarmas)', 'var' => 'turini Dart o\'zi aniqlaydigan', _ => '`$kind` turidagi' };
      return '$what `${decl.group(2)}` o\'zgaruvchisi yaratiladi, qiymati: `${decl.group(3)}`';
    }
    if (l.startsWith('print(')) return 'qavs ichidagi qiymat konsolga chiqariladi';
    if (l.startsWith('if ')) return 'shart tekshiriladi: true bo\'lsa blok bajariladi';
    if (l.startsWith('} else if') || l.startsWith('else if')) return 'oldingi shart false bo\'lsa — yangi shart';
    if (l.startsWith('} else') || l.startsWith('else')) return 'hech qaysi shart bajarilmasa';
    if (l.startsWith('for (') && l.contains(' in ')) return 'ro\'yxat elementlari bittalab aylaniladi (for-in)';
    if (l.startsWith('for (')) return 'sikl: boshlash; shart; qadam';
    if (l.startsWith('while (')) return 'shart true ekan takrorlanadi';
    if (l.startsWith('return')) return 'natija qaytariladi va funksiya tugaydi';
    if (l.startsWith('switch')) return 'qiymat bir nechta variant bilan solishtiriladi';
    if (l.startsWith('try')) return 'xato chiqishi mumkin bo\'lgan kod';
    if (l.startsWith('} catch') || l.startsWith('} on ')) return 'xato ushlanadi';
    final fn = RegExp(r'^(\w+(?:<[^>]+>)?\??)\s+(\w+)\s*\(([^)]*)\)\s*(\{|=>)').firstMatch(l);
    if (fn != null && fn.group(1) != 'return') return '`${fn.group(2)}` funksiyasi e\'lon qilinmoqda — qaytaradigan turi `${fn.group(1)}`';
    if (RegExp(r'^\w+\s*(\+\+|--);$').hasMatch(l)) return 'qiymat 1 ga o\'zgartiriladi';
    if (RegExp(r'^[\w.]+\s*[+\-*/]?=\s*').hasMatch(l)) return 'o\'zgaruvchiga yangi qiymat beriladi';
    if (RegExp(r'^\w+\.\w+\(').hasMatch(l)) return 'obyektning metodi chaqirilmoqda';
    return null;
  }

  TutorReply _askQuiz(String msg, String? lessonId) {
    final (l, _) = msg.isEmpty ? (lessonById[lessonId], null) : findTopic(msg, lessonId: lessonId);
    final lesson = l ?? allLessons[math.Random(_seed++).nextInt(allLessons.length)];
    final candidates = lesson.quiz.where((q) => q is SingleChoice || q is TrueFalse || (q is PredictOutput && q.options != null)).toList();
    if (candidates.isEmpty) return const TutorReply('Bu mavzu uchun savol topilmadi.');
    final q = candidates[(_seed++) % candidates.length];
    final b = StringBuffer('**"${lesson.title}"** bo\'yicha savol:\n\n${q.prompt}\n');
    if (q.code != null) b.writeln('```dart\n${q.code}\n```');
    switch (q) {
      case SingleChoice():
        for (var i = 0; i < q.options.length; i++) {
          b.writeln('${String.fromCharCode(65 + i)}) ${q.options[i]}');
        }
        b.writeln('\nJavob harfini yozing (A, B, C...).');
      case PredictOutput():
        for (var i = 0; i < q.options!.length; i++) {
          b.writeln('${String.fromCharCode(65 + i)}) ${q.options![i].replaceAll('\n', ' ⏎ ')}');
        }
        b.writeln('\nJavob harfini yozing.');
      case TrueFalse():
        b.writeln('\n"Ha" yoki "Yo\'q" deb javob bering.');
      default:
        break;
    }
    return TutorReply(b.toString().trim(), lessonId: lesson.id, pending: q);
  }

  TutorReply _gradeQuiz(Question q, String msg) {
    Answer? a;
    final m = msg.trim().toUpperCase();
    if (q is TrueFalse) {
      if (RegExp(r'^(HA|TO.?G.?RI|TRUE|ROST)').hasMatch(m)) a = const BoolAnswer(true);
      if (RegExp(r"^(YO.?Q|NOTO|FALSE|YOLG)").hasMatch(m)) a = const BoolAnswer(false);
    } else if (m.isNotEmpty) {
      final idx = m.codeUnitAt(0) - 65;
      if (idx >= 0 && idx < 10) a = IndexAnswer(idx);
    }
    if (a == null) return TutorReply('Javobni tushunmadim. ${q is TrueFalse ? '"Ha" yoki "Yo\'q"' : 'Variant harfini (A, B...)'} yozing.', pending: q);
    final v = gradeQuestion(q, a);
    return TutorReply(
      '${v.correct ? '✅ To\'g\'ri!' : '❌ Noto\'g\'ri.${v.correctAnswerText == null ? '' : ' To\'g\'ri javob: ${v.correctAnswerText!.replaceAll('\n', ' ⏎ ')}'}'}\n\n${q.explanation}',
      suggestions: const ['Yana savol', 'Sodda tushuntir'],
    );
  }

  TutorReply _askInterview() {
    final q = _interview[(_seed++) % _interview.length];
    return TutorReply('🎤 **Intervyu savoli:**\n\n${q.q}\n\nO\'z so\'zlaringiz bilan javob bering — keyin namunaviy javob bilan solishtiraman.', pending: q);
  }

  TutorReply _gradeInterview(_InterviewQ q, String msg) {
    final low = msg.toLowerCase();
    final hit = q.keywords.where((k) => low.contains(k.toLowerCase())).toList();
    final ratio = hit.length / q.keywords.length;
    final verdict = ratio >= 0.5
        ? '👍 Yaxshi javob — asosiy tushunchalarni aytdingiz.'
        : (ratio > 0 ? '🙂 Qisman to\'g\'ri. Yana aniqroq bo\'lishi mumkin.' : '🤔 Javobda muhim tushunchalar yetishmayapti.');
    return TutorReply('$verdict\n\n**Namunaviy javob:** ${q.model}', suggestions: const ['Keyingi intervyu savoli']);
  }
}
