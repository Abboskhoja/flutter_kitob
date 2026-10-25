import 'package:kitob_dart/kitob_dart.dart';

import '../../content/model.dart';

class CheckResult {
  const CheckResult(this.check, this.passed, this.title, {this.detail, this.actual, this.expected});
  final Check check;
  final bool passed;
  final String title;
  final String? detail;
  final String? actual;
  final String? expected;
}

class GradeResult {
  const GradeResult({required this.results, required this.diagnostics, this.error, this.stdout = ''});
  final List<CheckResult> results;
  final List<Diagnostic> diagnostics;
  final RuntimeErrorInfo? error;
  final String stdout;

  bool get compiled => !diagnostics.any((d) => d.isError);
  bool get passed => compiled && results.isNotEmpty && results.every((r) => r.passed);
  int get passedCount => results.where((r) => r.passed).length;
}

/// Natijani solishtirish uchun normallashtiradi: qator oxiridagi bo'shliqlar va oxirgi bo'sh qatorlar.
String normalizeOutput(String s) {
  final lines = s.replaceAll('\r\n', '\n').split('\n').map((l) => l.trimRight()).toList();
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines.join('\n');
}

/// Izohlar va satrlarsiz kod — konstruksiya talablarini tekshirish uchun.
String _codeWithoutComments(String code) {
  final buf = StringBuffer();
  for (final t in highlightDart(code)) {
    if (t.kind == HighlightKind.comment) {
      buf.write(' ');
    } else {
      buf.write(code.substring(t.start, t.end));
    }
  }
  return buf.toString();
}

/// O'quvchi kodini vazifa testlari bilan baholaydi.
///
/// Javob matn bilan solishtirilmaydi: kod tahlil qilinadi, bajariladi va
/// natijasi (yoki funksiya qaytargan qiymat) testlar bilan tekshiriladi.
/// Shuning uchun turli usulda yozilgan to'g'ri yechimlar ham qabul qilinadi.
GradeResult gradeTask(CodeTask task, String code) {
  final diagnostics = KitobDart.analyze(code, requireMain: task.requireMain);
  if (diagnostics.any((d) => d.isError)) {
    return GradeResult(results: const [], diagnostics: diagnostics);
  }
  final results = <CheckResult>[];
  RuntimeErrorInfo? firstError;
  String? lastStdout;
  final cleanCode = _codeWithoutComments(code);
  final runCache = <String, ExecutionResult>{};

  ExecutionResult runWith(List<String> stdin) => runCache.putIfAbsent(
    stdin.join('\u0000'),
    () => KitobDart.run(code, options: ExecutionOptions(stdin: stdin, maxSteps: 2000000, timeout: const Duration(seconds: 3))),
  );

  KitobSession? session;
  var sessionTried = false;
  RuntimeErrorInfo? sessionError;

  // Flutter: har bir AfterTap o'z holatidan boshlashi uchun runtime har safar yangidan ochiladi.
  (FlutterRuntime?, RuntimeErrorInfo?) openFlutter() {
    final (rt, _, err) = FlutterRuntime.open(code);
    return (rt, err);
  }

  WidgetDesc? firstTree;

  var hiddenIndex = 0;
  for (final c in task.checks) {
    if (c.hidden) hiddenIndex++;
    final hiddenLabel = 'Yashirin test #$hiddenIndex';
    switch (c) {
      case OutputEquals():
        final r = runWith(c.stdin);
        lastStdout = r.stdout;
        firstError ??= r.error;
        final ok = r.error == null && normalizeOutput(r.stdout) == normalizeOutput(c.expected);
        results.add(CheckResult(
          c,
          ok,
          c.hidden ? hiddenLabel : (c.label ?? 'Natija to\'g\'ri'),
          detail: c.stdin.isEmpty ? null : 'Kiritma: ${c.stdin.join(', ')}',
          actual: c.hidden && !ok ? null : r.stdout,
          expected: c.hidden ? null : c.expected,
        ));
      case OutputContains():
        final r = runWith(const []);
        lastStdout = r.stdout;
        firstError ??= r.error;
        final ok = r.error == null && r.stdout.contains(c.text);
        results.add(CheckResult(c, ok, c.hidden ? hiddenLabel : (c.label ?? 'Natijada "${c.text}" bor'),
            actual: r.stdout, expected: c.hidden ? null : c.text));
      case EvaluatesTo():
        if (!sessionTried) {
          sessionTried = true;
          final (s, _, err) = KitobSession.open(code,
              requireMain: false, options: const ExecutionOptions(maxSteps: 2000000, timeout: Duration(seconds: 3)));
          session = s;
          sessionError = err;
        }
        if (session == null) {
          firstError ??= sessionError;
          results.add(CheckResult(c, false, c.hidden ? hiddenLabel : '`${c.expression}`',
              detail: sessionError?.explanation ?? 'Kodni yuklab bo\'lmadi'));
          continue;
        }
        final out = session.evaluate(c.expression);
        final ok = out.error == null && out.value == c.expected;
        if (out.error != null) firstError ??= out.error;
        results.add(CheckResult(
          c,
          ok,
          c.hidden ? hiddenLabel : '`${c.expression}` → `${c.expected}`',
          detail: out.error?.explanation,
          actual: c.hidden && !ok ? null : (out.value ?? out.error?.message),
          expected: c.hidden ? null : c.expected,
        ));
      case UsesConstruct():
        final ok = RegExp(c.pattern).hasMatch(c.inComments ? code : cleanCode);
        results.add(CheckResult(c, ok, c.requirement));
      case WidgetExists():
        final title = c.hidden ? hiddenLabel : (c.label ?? widgetExistsLabel(c));
        try {
          if (firstTree == null) {
            final (rt, err) = openFlutter();
            if (rt == null) {
              firstError ??= err;
              results.add(CheckResult(c, false, title, detail: err?.explanation ?? 'Ilova ishga tushmadi'));
              continue;
            }
            // `initState` dagi Future.delayed/Timer tugashi uchun (widget testdagi pumpAndSettle kabi).
            rt.settle();
            firstTree = rt.expand();
          }
          final n = firstTree.all.where((d) => matchesWidget(d, c)).length;
          results.add(CheckResult(c, n >= c.min, title,
              detail: n >= c.min ? null : (n == 0 ? 'Ekranda topilmadi' : 'Topildi: $n ta, kerak: kamida ${c.min} ta')));
        } on FlutterRunError catch (e) {
          firstError ??= e.info;
          results.add(CheckResult(c, false, title, detail: e.info.explanation));
        }
      case AfterTap():
        final title = c.hidden ? hiddenLabel : (c.label ?? afterTapLabel(c));
        try {
          final (rt, err) = openFlutter();
          if (rt == null) {
            firstError ??= err;
            results.add(CheckResult(c, false, title, detail: err?.explanation ?? 'Ilova ishga tushmadi'));
            continue;
          }
          rt.settle();
          var tree = rt.expand();
          String? problem;
          for (var i = 0; i < c.times; i++) {
            final target = findTappable(tree, c.tap);
            if (target == null) {
              problem = '"${c.tap}" tugmasi topilmadi (yoki unda onPressed/onTap yo\'q)';
              break;
            }
            final isToggle = target.type == 'Switch' || target.type == 'Checkbox' || target.type.endsWith('ListTile') && target.props.containsKey('value');
            final before = rt.setStateCount;
            rt.call(target.onTap, isToggle ? [target.props['value'] != 'true'] : const []);
            // `onPressed: () async { await ...; setState(...); }` — kutilayotgan ishlar tugaydi.
            rt.settle();
            // Haqiqiy Flutter'dagidek: setState chaqirilmasa ekran qayta chizilmaydi.
            if (rt.setStateCount != before) tree = rt.expand();
          }
          final texts = [for (final d in tree.all) if (d.text != null) d.text!];
          final ok = problem == null && texts.any((t) => t.contains(c.expectText));
          if (!ok && problem == null && rt.setStateCount == 0) {
            problem = 'Tugma bosildi, lekin setState() chaqirilmadi — ekran yangilanmadi';
          }
          results.add(CheckResult(c, ok, title,
              detail: problem,
              expected: c.hidden ? null : c.expectText,
              actual: ok || c.hidden ? null : (texts.isEmpty ? '(matn yo\'q)' : texts.take(8).join(' · '))));
        } on FlutterRunError catch (e) {
          firstError ??= e.info;
          results.add(CheckResult(c, false, title, detail: e.info.explanation));
        }
    }
  }
  return GradeResult(results: results, diagnostics: diagnostics, error: firstError, stdout: lastStdout ?? '');
}

String widgetExistsLabel(WidgetExists c) {
  final parts = [
    if (c.text != null) "'${c.text}'",
    for (final e in c.props.entries) '${e.key}: ${e.value}',
  ];
  final what = parts.isEmpty ? '`${c.type}`' : '`${c.type}(${parts.join(', ')})`';
  return c.min > 1 ? 'Ekranda kamida ${c.min} ta $what' : 'Ekranda $what bor';
}

String afterTapLabel(AfterTap c) =>
    '"${c.tap}" ${c.times > 1 ? '${c.times} marta ' : ''}bosilgach ekranda `${c.expectText}` chiqadi';

bool matchesWidget(WidgetDesc d, WidgetExists c) {
  if (d.type != c.type) return false;
  if (c.text != null) {
    final own = d.text;
    if (own != c.text && !d.all.any((x) => x.text == c.text)) return false;
  }
  for (final e in c.props.entries) {
    if (d.props[e.key] != e.value) return false;
  }
  return true;
}

/// Matni (yoki ikonkasi) [label] bo'lgan bosiladigan eng ichki widget.
WidgetDesc? findTappable(WidgetDesc root, String label) {
  bool hasLabel(WidgetDesc d) => d.all.any((x) => x.text == label || x.props['icon'] == label);
  WidgetDesc? best;
  void visit(WidgetDesc d) {
    if (d.onTap != null && hasLabel(d)) best = d;
    for (final c in d.children) {
      visit(c);
    }
  }
  visit(root);
  return best;
}
