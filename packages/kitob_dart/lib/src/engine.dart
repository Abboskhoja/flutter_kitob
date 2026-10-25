import 'ast.dart';
import 'checker.dart';
import 'diagnostics.dart';
import 'interpreter.dart';
import 'parser.dart';
import 'result.dart';
import 'runtime.dart';

/// O'quvchi kodini tahlil qilish va bajarish uchun asosiy kirish nuqtasi.
class KitobDart {
  KitobDart._();

  static Program? _preludeProgram;
  static Program get _prelude => _preludeProgram ??= Parser(preludeSource).parseProgram();

  /// Kodni ishga tushirmasdan tekshiradi (Dart analyzer o'rnini bosuvchi).
  static List<Diagnostic> analyze(String source, {bool requireMain = true}) {
    final parsed = _parse(source);
    if (parsed.$2 != null) return [parsed.$2!];
    return Checker(parsed.$1!, preludeClasses: _preludeFor(parsed.$1!), requireMain: requireMain).check(source);
  }

  static List<ClassDecl> _preludeFor(Program p) => [..._prelude.classes, if (usesFlutter(p)) ...flutterPrelude.classes];

  static (Program?, Diagnostic?) _parse(String source) {
    try {
      return (Parser(source).parseProgram(), null);
    } on CompileError catch (e) {
      return (null, e.diagnostic);
    }
  }

  /// Kodni tekshiradi va xato bo'lmasa `main()` ni bajaradi.
  static ExecutionResult run(String source, {ExecutionOptions options = const ExecutionOptions()}) {
    final clock = Stopwatch()..start();
    final parsed = _parse(source);
    if (parsed.$2 != null) {
      return ExecutionResult(stdout: '', diagnostics: [parsed.$2!], elapsedMicros: clock.elapsedMicroseconds);
    }
    final diagnostics = Checker(parsed.$1!, preludeClasses: _preludeFor(parsed.$1!)).check(source);
    if (diagnostics.any((d) => d.isError)) {
      return ExecutionResult(stdout: '', diagnostics: diagnostics, elapsedMicros: clock.elapsedMicroseconds);
    }
    final interp = Interpreter(source, parsed.$1!, options);
    RuntimeErrorInfo? error;
    try {
      interp.load();
      interp.runMain();
    } catch (e, st) {
      error = describeError(e, interp, st);
    }
    return ExecutionResult(
      stdout: interp.stdout,
      diagnostics: diagnostics,
      error: error,
      trace: interp.trace,
      traceTruncated: interp.traceTruncated,
      steps: interp.steps,
      elapsedMicros: clock.elapsedMicroseconds,
    );
  }

  /// Xatoni o'quvchiga tushunarli ko'rinishga keltiradi. `null` — dastur `exit()` bilan to'xtagan.
  static RuntimeErrorInfo? describeError(Object e, Interpreter interp, [StackTrace? st]) {
    // Asinxron kodda ushlanmagan xato (Future yoki Stream) — Dart VM kabi dastur to'xtaydi.
    if (e is UncaughtAsyncError) e = e.error;
    if (e is ExecutionAbort) {
      return RuntimeErrorInfo(
        type: e.kind,
        message: e.original,
        explanation: e.message,
        hint: e.hint,
        line: interp.lineOf(e.offset),
        column: interp.columnOf(e.offset),
      );
    }
    if (e is DartThrow) {
      final value = e.value;
      final className = value is KInstance ? value.klass.name : interp.typeName(value);
      String text;
      try {
        text = interp.stringify(value);
      } catch (_) {
        text = className;
      }
      final (explanation, hint) = _explain(className, text, value);
      return RuntimeErrorInfo(
        type: className,
        message: 'Unhandled exception:\n$text',
        explanation: explanation,
        hint: hint,
        line: interp.lineOf(e.offset),
        column: interp.columnOf(e.offset),
        stack: e.stack,
      );
    }
    if (e.runtimeType.toString() == '_ExitSignal') return null;
    final s = e.toString();
    if (e is StackOverflowError || s.contains('call stack') || s.contains('Stack Overflow')) {
      return RuntimeErrorInfo(
        type: 'stack_overflow',
        message: 'Stack Overflow',
        explanation: "Funksiyalar bir-birini juda chuqur chaqirdi (Stack Overflow). Rekursiyada to'xtash sharti yo'q bo'lishi mumkin.",
        hint: "Rekursiv funksiya boshida to'xtash shartini yozing: if (n <= 1) return 1;",
        line: interp.lineOf(0),
        column: 1,
      );
    }
    return RuntimeErrorInfo(
      type: 'internal',
      message: s,
      explanation: "Interpretator bu kodni bajara olmadi. Bu playgroundning cheklovi bo'lishi mumkin — kodni soddaroq yozib ko'ring.",
      line: 1,
      column: 1,
    );
  }

  static (String, String?) _explain(String className, String text, Object? value) {
    switch (className) {
      case 'FormatException':
        return (
          "Matnni songa (yoki boshqa formatga) aylantirib bo'lmadi. Masalan, int.parse('abc') ishlamaydi, chunki 'abc' son emas.",
          "Xavfsiz usul: int.tryParse(matn) — muvaffaqiyatsiz bo'lsa null qaytaradi. Yoki try-catch ishlating."
        );
      case 'RangeError':
        return (
          "Ro'yxatda (yoki matnda) bunday tartib raqami — indeks yo'q. Indekslar 0 dan boshlanadi, oxirgisi esa length - 1.",
          "Indeksni ishlatishdan oldin tekshiring: if (i < royxat.length) { ... }"
        );
      case 'TypeError':
        if (text.contains('Null check')) {
          return (
            "`!` operatori ishlatilgan qiymat aslida null ekan. `!` — \"bu qiymat null emas, ishon\" degani, lekin u null chiqdi.",
            "`!` o'rniga `?? standartQiymat` ishlating yoki avval if (x != null) bilan tekshiring."
          );
        }
        return ("Qiymatning turi kutilgan turga mos kelmadi.", "O'zgaruvchi va qiymat turlarini tekshiring.");
      case 'NoSuchMethodError':
        return (
          "Bunday metod yoki xususiyat mavjud emas. Ko'pincha bu qiymat null bo'lganda yuz beradi.",
          "Qiymat null emasligini tekshiring yoki `?.` operatoridan foydalaning."
        );
      case 'StateError':
        return (
          "Obyekt bu amal uchun noto'g'ri holatda. Masalan, bo'sh ro'yxatdan .first yoki .last so'ralgan.",
          "Avval ro'yxat bo'sh emasligini tekshiring: if (royxat.isNotEmpty)"
        );
      case 'IntegerDivisionByZeroException':
      case 'UnsupportedError':
        if (text.contains('division') || className == 'IntegerDivisionByZeroException') {
          return ("Butun sonni nolga bo'lib bo'lmaydi (`~/ 0` yoki `% 0`).", "Bo'luvchi 0 emasligini oldindan tekshiring.");
        }
        return ("Bu amalni bajarib bo'lmaydi (masalan, o'zgarmas ro'yxatga element qo'shish).", null);
      case 'AssertionError':
        return ("`assert` sharti bajarilmadi (false bo'ldi).", "assert ichidagi shartni tekshiring.");
      case 'LateInitializationError':
        return ("`late` o'zgaruvchiga qiymat berilmasdan turib u ishlatildi.", "late o'zgaruvchini ishlatishdan oldin unga qiymat bering.");
      case 'ArgumentError':
        return ("Funksiyaga noto'g'ri argument berildi.", null);
      case 'ConcurrentModificationError':
        return (
          "Ro'yxatni aylanib (for-in) chiqayotganda uni o'zgartirib bo'lmaydi.",
          "Nusxasini aylaning: for (final x in royxat.toList()) yoki removeWhere ishlating."
        );
      case 'Exception':
        return (
          "Dasturingiz `throw` orqali xato tashladi va u hech qayerda `catch` qilinmadi, shuning uchun dastur to'xtadi.",
          "Xatoni ushlash uchun: try { ... } catch (e) { print(e); }"
        );
      case 'StackOverflowError':
        return ("Rekursiya cheksiz davom etdi.", null);
    }
    if (value is KInstance) {
      return (
        "`$className` turidagi xato tashlandi (throw) va ushlanmadi (catch qilinmadi).",
        "Xatoni ushlash uchun try-catch ishlating: try { ... } on $className catch (e) { ... }"
      );
    }
    return ("Dastur `throw` bilan to'xtatildi va xato ushlanmadi.", "try-catch bilan ushlang.");
  }
}

/// Testlar va baholash uchun: dasturni yuklab, uning ichida ifodalarni hisoblash.
class KitobSession {
  KitobSession._(this.source, this.interpreter);

  final String source;
  final Interpreter interpreter;

  /// Dasturni yuklaydi. [requireMain] false bo'lsa, faqat funksiyalar/class'lar bo'lishi mumkin.
  static (KitobSession?, List<Diagnostic>, RuntimeErrorInfo?) open(String source,
      {bool requireMain = false, ExecutionOptions options = const ExecutionOptions()}) {
    final diagnostics = KitobDart.analyze(source, requireMain: requireMain);
    if (diagnostics.any((d) => d.isError)) return (null, diagnostics, null);
    final program = Parser(source).parseProgram();
    final interp = Interpreter(source, program, options);
    try {
      interp.load();
    } catch (e, st) {
      return (null, diagnostics, KitobDart.describeError(e, interp, st));
    }
    return (KitobSession._(source, interp), diagnostics, null);
  }

  /// `main()` ni bajaradi va shu paytgacha chiqqan matnni qaytaradi.
  (String stdout, RuntimeErrorInfo? error) runMain() {
    final before = interpreter.stdout.length;
    try {
      interpreter.runMain();
      return (interpreter.stdout.substring(before), null);
    } catch (e, st) {
      return (interpreter.stdout.substring(before), KitobDart.describeError(e, interpreter, st));
    }
  }

  /// Masalan `kvadrat(4)` ifodasini hisoblab, natijani matn ko'rinishida qaytaradi.
  EvalOutcome evaluate(String expression) {
    final before = interpreter.stdout.length;
    try {
      final v = interpreter.evaluate(expression);
      return EvalOutcome(
        value: interpreter.stringify(v),
        typeName: interpreter.typeName(v),
        stdout: interpreter.stdout.substring(before),
      );
    } on CompileError catch (e) {
      return EvalOutcome(error: RuntimeErrorInfo(
        type: 'test_error',
        message: e.diagnostic.original,
        explanation: 'Test ifodasi noto\'g\'ri: ${e.diagnostic.message}',
        line: 1,
        column: 1,
      ));
    } catch (e, st) {
      return EvalOutcome(stdout: interpreter.stdout.substring(before), error: KitobDart.describeError(e, interpreter, st));
    }
  }
}

class EvalOutcome {
  const EvalOutcome({this.value, this.typeName, this.stdout = '', this.error});
  final String? value;
  final String? typeName;
  final String stdout;
  final RuntimeErrorInfo? error;
}
