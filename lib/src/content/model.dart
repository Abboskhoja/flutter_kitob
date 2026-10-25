import 'package:flutter/material.dart';

// ───────────────────────── O'quv dasturi tuzilmasi ─────────────────────────

enum Track {
  foundations('Asoslar', Icons.lightbulb_outline_rounded),
  dart('Dart', Icons.code_rounded),
  flutter('Flutter', Icons.widgets_outlined),
  pro('Muhandislik', Icons.engineering_outlined),
  leadership('Texnik yetakchilik', Icons.hub_outlined),
  research('Ichki tuzilma va tadqiqot', Icons.biotech_outlined);

  const Track(this.title, this.icon);
  final String title;
  final IconData icon;
}

/// Daraja ichidagi mavzuli bo'lim: tayyor darslar va hali yozilayotgan mavzular rejasi.
class Module {
  const Module({required this.id, required this.title, this.summary = '', this.lessons = const [], this.topics = const []});
  final String id;
  final String title;
  final String summary;

  /// To'liq yozilgan va tekshirilgan darslar.
  final List<Lesson> lessons;

  /// Modulning to'liq mavzular rejasi (darslar qamrab olgan va hali yozilmagan mavzular).
  final List<String> topics;

  bool get isReady => lessons.isNotEmpty;
}

/// Darajaning yakuniy loyihasi.
class Capstone {
  const Capstone(this.title, this.description, {this.requirements = const [], this.projectId});
  final String title;
  final String description;

  /// Qabul mezonlari (acceptance criteria).
  final List<String> requirements;

  /// Project Academy'dagi tayyor loyiha (bo'lsa).
  final String? projectId;
}

class Level {
  const Level({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.track,
    required this.icon,
    required this.color,
    required this.modules,
    this.outcome = '',
    this.competencies = const [],
    this.capstone,
    this.rank,
  });

  final int number;
  final String title;
  final String subtitle;
  final Track track;
  final IconData icon;
  final Color color;
  final List<Module> modules;

  /// Daraja tugaganda o'quvchi nimani qila oladi.
  final String outcome;

  /// Kompetensiyalar xaritasi: darajani tugatgan o'quvchi bajara oladigan aniq ko'nikmalar.
  final List<String> competencies;
  final Capstone? capstone;

  /// Bilim yo'nalishi nomi (ZERO, JUNIOR, SENIOR...). Haqiqiy lavozimni tasdiqlamaydi.
  final String? rank;

  String get id => 'level$number';

  /// Tayyor darslar (modullar tartibida).
  List<Lesson> get lessons => [for (final m in modules) ...m.lessons];

  /// Darajaning to'liq mavzular rejasi.
  List<String> get topics => [for (final m in modules) ...m.topics];

  bool get isReady => modules.any((m) => m.isReady);
  int get plannedRemaining => (topics.length - lessons.length).clamp(0, 999);
}

class DocLink {
  const DocLink(this.title, this.url);
  final String title;
  final String url;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.minutes,
    required this.objectives,
    required this.intro,
    required this.why,
    required this.where,
    required this.analogy,
    required this.quiz,
    required this.summary,
    required this.revisionTip,
    this.prerequisites = const [],
    this.skills = const [],
    this.terms = const [],
    this.animation,
    this.syntax,
    this.example,
    this.examples = const [],
    this.buggy,
    this.task,
    this.terminalTask,
    this.extra = const [],
    this.next,
    this.links = const [],
    this.xp = 50,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int minutes;
  final List<String> objectives;
  final List<String> prerequisites;
  final List<String> skills;

  /// Oddiy tushuntirish.
  final List<Block> intro;
  final String why;
  final List<String> where;
  final AnalogyBlock analogy;
  final List<TermBlock> terms;
  final AnimationBlock? animation;
  final SyntaxBlock? syntax;
  final CodeBlock? example;
  final List<CodeBlock> examples;
  final BuggyCodeBlock? buggy;
  final CodeTask? task;

  /// Kod o'rniga virtual terminalda bajariladigan amaliy vazifa (masalan, 2-daraja).
  final TerminalTask? terminalTask;

  /// Asosiy tushuntirishdan keyingi qo'shimcha bloklar.
  final List<Block> extra;
  final List<Question> quiz;
  final List<String> summary;
  final String? next;
  final String revisionTip;
  final List<DocLink> links;
  final int xp;

  bool get hasCode => example != null;
}

// ───────────────────────── Dars bloklari ─────────────────────────

sealed class Block {
  const Block();
}

/// `**qalin**`, `` `kod` `` belgilarini qo'llab-quvvatlaydigan matn.
class ParaBlock extends Block {
  const ParaBlock(this.text);
  final String text;
}

class HeadingBlock extends Block {
  const HeadingBlock(this.text);
  final String text;
}

class BulletsBlock extends Block {
  const BulletsBlock(this.items, {this.ordered = false});
  final List<String> items;
  final bool ordered;
}

enum CalloutKind { info, tip, warning, success, why, where }

class CalloutBlock extends Block {
  const CalloutBlock(this.kind, this.title, this.text);
  final CalloutKind kind;
  final String title;
  final String text;
}

class AnalogyBlock extends Block {
  const AnalogyBlock(this.title, this.text, {this.icon = Icons.emoji_objects_outlined});
  final String title;
  final String text;
  final IconData icon;
}

/// Inglizcha atama: asl nomi, o'zbekcha izohi, nima uchun kerak, misol.
class TermBlock extends Block {
  const TermBlock({required this.term, required this.uz, required this.meaning, required this.why, this.example});
  final String term;
  final String uz;
  final String meaning;
  final String why;
  final String? example;
}

class AnimationBlock extends Block {
  const AnimationBlock(this.id, this.caption);
  final String id;
  final String caption;
}

class SyntaxPart {
  const SyntaxPart(this.part, this.meaning);
  final String part;
  final String meaning;
}

class SyntaxBlock extends Block {
  const SyntaxBlock(this.code, this.parts, {this.title = 'Sintaksis'});
  final String code;
  final List<SyntaxPart> parts;
  final String title;
}

/// Ishlaydigan kod namunasi. Natija haqiqiy ishga tushirishdan olinadi.
class CodeBlock extends Block {
  const CodeBlock(
    this.code, {
    this.title,
    this.explain = const {},
    this.lineNotes = const {},
    this.runnable = true,
    this.visualize = false,
    this.stdin = const [],
    this.expectedOutput,
    this.editable = true,
    this.preview = false,
  });

  final String code;
  final String? title;

  /// Token → tushuntirish (masalan `'int': 'butun son turi'`).
  final Map<String, String> explain;

  /// Qator raqami (1 dan) → izoh.
  final Map<int, String> lineNotes;
  final bool runnable;
  final bool visualize;
  final List<String> stdin;

  /// Agar berilsa, CI testi haqiqiy natija shunga tengligini tekshiradi.
  final String? expectedOutput;
  final bool editable;

  /// Flutter kodi: natija konsol emas, telefon oynasida haqiqiy widgetlar sifatida chiziladi.
  final bool preview;
}

class BuggyCodeBlock extends Block {
  const BuggyCodeBlock({
    required this.code,
    required this.task,
    required this.why,
    required this.fixed,
    this.hint,
    this.preview = false,
  });

  /// Flutter kodi: tuzatish widget daraxti to'g'ri variantnikiga tengligi bilan tekshiriladi.
  final bool preview;

  final String code;
  final String task;

  /// Xato sababi (tuzatilgandan keyin ko'rsatiladi).
  final String why;
  final String fixed;
  final String? hint;
}

class CompareBlock extends Block {
  const CompareBlock({required this.leftTitle, required this.left, required this.rightTitle, required this.right, this.note});
  final String leftTitle;
  final String left;
  final String rightTitle;
  final String right;
  final String? note;
}

class TerminalDemoBlock extends Block {
  const TerminalDemoBlock(this.lines, {this.caption});

  /// (buyruq, natija)
  final List<(String, String)> lines;
  final String? caption;
}

class WidgetLabBlock extends Block {
  const WidgetLabBlock(this.labId, this.caption);
  final String labId;
  final String caption;
}

class CodeBlockGroup extends Block {
  const CodeBlockGroup(this.blocks);
  final List<CodeBlock> blocks;
}

// ───────────────────────── Amaliy vazifa va tekshiruvlar ─────────────────────────

sealed class Check {
  const Check({this.hidden = false, this.label});

  /// Yashirin test: kutilgan qiymat oldindan ko'rsatilmaydi.
  final bool hidden;
  final String? label;
}

/// `main()` natijasi aynan shu matnga teng bo'lishi kerak.
class OutputEquals extends Check {
  const OutputEquals(this.expected, {this.stdin = const [], super.hidden, super.label});
  final String expected;
  final List<String> stdin;
}

class OutputContains extends Check {
  const OutputContains(this.text, {super.hidden, super.label});
  final String text;
}

/// Ifodani o'quvchi kodi kontekstida hisoblab, natijani solishtiradi.
class EvaluatesTo extends Check {
  const EvaluatesTo(this.expression, this.expected, {super.hidden, super.label});
  final String expression;
  final String expected;
}

/// Kodda ma'lum konstruksiya ishlatilishi talabi (masalan, `for` sikli).
class UsesConstruct extends Check {
  const UsesConstruct(this.pattern, this.requirement, {super.label, this.inComments = false});
  final String pattern;
  final String requirement;

  /// true — izohlar ham hisobga olinadi (masalan, "kodni izohga aylantiring" vazifasi).
  final bool inComments;
}

/// Flutter: `runApp()` daraxtida shu widget bo'lishi kerak.
class WidgetExists extends Check {
  const WidgetExists(this.type, {this.text, this.props = const {}, this.min = 1, super.hidden, super.label});
  final String type;

  /// `Text` uchun aniq matn (yoki boshqa widget ichidagi matn).
  final String? text;

  /// Masalan `{'icon': 'favorite'}` yoki `{'color': '0xFFF44336'}`.
  final Map<String, String> props;
  final int min;
}

/// Flutter: [tap] yozuvli (yoki `Icons.[tap]` ikonkali) tugmani [times] marta bosgach,
/// ekranda [expectText] matni bo'lishi kerak. setState haqiqatan ishlashini tekshiradi.
class AfterTap extends Check {
  const AfterTap(this.tap, this.expectText, {this.times = 1, super.hidden, super.label});
  final String tap;
  final String expectText;
  final int times;
}

class CodeTask {
  const CodeTask({
    required this.title,
    required this.instructions,
    required this.starter,
    required this.checks,
    required this.hints,
    required this.solution,
    this.requireMain = true,
    this.preview = false,
  });

  /// Flutter vazifasi — "Ishga tushirish" telefon oynasida ko'rsatadi.
  final bool preview;

  final String title;
  final String instructions;
  final String starter;
  final List<Check> checks;

  /// Bosqichma-bosqich: kichik ishora → kattaroq → qisman yechim.
  final List<String> hints;
  final String solution;
  final bool requireMain;
}

// ───────────────────────── Terminal vazifasi ─────────────────────────

/// Virtual fayl tizimining holati bo'yicha tekshiruv (buyruqlar matni emas, natija tekshiriladi).
sealed class ShellCheck {
  const ShellCheck(this.label);
  final String label;
}

/// `~/loyiha` kabi yo'lda papka bor.
class DirExists extends ShellCheck {
  const DirExists(this.path, super.label);
  final String path;
}

class FileExists extends ShellCheck {
  const FileExists(this.path, super.label);
  final String path;
}

/// Faylda [text] bor (katta-kichik harf farqlanmaydi).
class FileContains extends ShellCheck {
  const FileContains(this.path, this.text, super.label);
  final String path;
  final String text;
}

class CwdIs extends ShellCheck {
  const CwdIs(this.path, super.label);
  final String path;
}

/// Terminalda shu amal bajarilgan (virtual shell hodisasi: `ls`, `dart_run`, `git_commit` ...).
class ShellEvent extends ShellCheck {
  const ShellEvent(this.event, super.label);
  final String event;
}

/// Git omborida kamida [min] ta commit bor.
class GitCommits extends ShellCheck {
  const GitCommits(this.min, super.label);
  final int min;
}

class TerminalTask {
  const TerminalTask({
    required this.title,
    required this.instructions,
    required this.checks,
    required this.hints,
    required this.solution,
  });
  final String title;
  final String instructions;
  final List<ShellCheck> checks;
  final List<String> hints;

  /// Vazifani yechadigan buyruqlar ketma-ketligi (kontent testida tekshiriladi).
  final List<String> solution;
}

// ───────────────────────── Test savollari ─────────────────────────

sealed class Question {
  const Question({required this.prompt, required this.explanation, this.topic = '', this.code});
  final String prompt;
  final String explanation;
  final String topic;
  final String? code;
}

class SingleChoice extends Question {
  const SingleChoice({required super.prompt, required this.options, required this.correct, required super.explanation, super.topic, super.code});
  final List<String> options;
  final int correct;
}

class MultiChoice extends Question {
  const MultiChoice({required super.prompt, required this.options, required this.correct, required super.explanation, super.topic, super.code});
  final List<String> options;
  final Set<int> correct;
}

class TrueFalse extends Question {
  const TrueFalse({required super.prompt, required this.answer, required super.explanation, super.topic, super.code});
  final bool answer;
}

/// Kod natijasini taxmin qilish. To'g'ri javob kodni haqiqiy bajarishdan olinadi.
class PredictOutput extends Question {
  const PredictOutput({required super.prompt, required String code, required super.explanation, this.options, super.topic}) : super(code: code);

  /// Agar null bo'lsa — erkin javob kiritiladi.
  final List<String>? options;
}

/// `____` o'rniga yozish. [expectedOutput] berilsa, to'ldirilgan kod bajarilib tekshiriladi.
class FillBlank extends Question {
  const FillBlank({
    required super.prompt,
    required this.template,
    required super.explanation,
    this.accepted = const [],
    this.expectedOutput,
    super.topic,
  });
  final String template;
  final List<String> accepted;
  final String? expectedOutput;
}

/// Qatorlarni to'g'ri tartibga qo'yish. Tartib bajarilib natijasi solishtiriladi.
class ArrangeLines extends Question {
  const ArrangeLines({
    required super.prompt,
    required this.lines,
    required super.explanation,
    super.topic,
    this.wrapInMain = false,
    this.byOutput = true,
  });

  /// To'g'ri tartib.
  final List<String> lines;
  final bool wrapInMain;

  /// true — kod bajarilib natijasi solishtiriladi (teng natijali boshqa tartib ham qabul).
  /// false — oddiy matn qadamlari, tartib aynan solishtiriladi.
  final bool byOutput;
}

class FindBug extends Question {
  const FindBug({required super.prompt, required String code, required this.bugLine, required super.explanation, super.topic})
      : super(code: code);

  /// 1 dan boshlanadigan qator raqami.
  final int bugLine;
}

class MatchPairs extends Question {
  const MatchPairs({required super.prompt, required this.pairs, required super.explanation, super.topic});
  final List<(String, String)> pairs;
}

/// Imtihonlar uchun: to'liq kod yozish, testlar bilan baholanadi.
class WriteCode extends Question {
  const WriteCode({required super.prompt, required this.task, required super.explanation, super.topic});
  final CodeTask task;
}

// ───────────────────────── Lug'at ─────────────────────────

class GlossaryTerm {
  const GlossaryTerm({
    required this.term,
    required this.uz,
    required this.meaning,
    this.example,
    this.lessonId,
    this.category = 'Umumiy',
  });
  final String term;
  final String uz;
  final String meaning;
  final String? example;
  final String? lessonId;
  final String category;
}
