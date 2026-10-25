import 'package:kitob_dart/kitob_dart.dart';

import '../../content/model.dart';
import '../../core/runner/grader.dart';

/// Savolga berilgan javob (har bir tur uchun o'z shakli).
sealed class Answer {
  const Answer();
}

class IndexAnswer extends Answer {
  const IndexAnswer(this.index);
  final int index;
}

class SetAnswer extends Answer {
  const SetAnswer(this.indexes);
  final Set<int> indexes;
}

class BoolAnswer extends Answer {
  const BoolAnswer(this.value);
  final bool value;
}

class TextAnswer extends Answer {
  const TextAnswer(this.text);
  final String text;
}

class OrderAnswer extends Answer {
  const OrderAnswer(this.lines);
  final List<String> lines;
}

class PairsAnswer extends Answer {
  /// chap → tanlangan o'ng
  const PairsAnswer(this.map);
  final Map<String, String> map;
}

class CodeAnswer extends Answer {
  const CodeAnswer(this.code);
  final String code;
}

class Verdict {
  const Verdict(this.correct, {this.correctAnswerText, this.detail, this.grade});
  final bool correct;

  /// To'g'ri javob — foydalanuvchiga ko'rsatish uchun.
  final String? correctAnswerText;
  final String? detail;
  final GradeResult? grade;
}

final _outputCache = <String, ExecutionResult>{};

/// Kodni bajarib, haqiqiy natijani qaytaradi (keshlanadi).
ExecutionResult runCached(String code) => _outputCache.putIfAbsent(code, () => KitobDart.run(code));

String _norm(String s) => normalizeOutput(s);

String _withMain(String body) => 'void main() {\n${body.split('\n').map((l) => '  $l').join('\n')}\n}';

/// PredictOutput uchun to'g'ri javob (haqiqiy bajarish natijasi).
String actualOutputOf(PredictOutput q) => _norm(runCached(q.code!).stdout);

Verdict gradeQuestion(Question q, Answer? a) {
  if (a == null) return const Verdict(false, detail: 'Javob berilmadi');
  switch (q) {
    case SingleChoice():
      return Verdict(a is IndexAnswer && a.index == q.correct, correctAnswerText: q.options[q.correct]);
    case MultiChoice():
      final ok = a is SetAnswer && a.indexes.length == q.correct.length && a.indexes.containsAll(q.correct);
      return Verdict(ok, correctAnswerText: [for (final i in q.correct.toList()..sort()) q.options[i]].join(' · '));
    case TrueFalse():
      return Verdict(a is BoolAnswer && a.value == q.answer, correctAnswerText: q.answer ? 'To\'g\'ri' : 'Noto\'g\'ri');
    case PredictOutput():
      final actual = actualOutputOf(q);
      String given;
      if (a is IndexAnswer && q.options != null) {
        given = q.options![a.index];
      } else if (a is TextAnswer) {
        given = a.text;
      } else {
        return Verdict(false, correctAnswerText: actual);
      }
      final ok = _norm(given.replaceAll(r'\n', '\n')) == actual ||
          _norm(given).replaceAll(RegExp(r'\s+'), ' ') == actual.replaceAll(RegExp(r'\s+'), ' ');
      return Verdict(ok, correctAnswerText: actual, detail: 'Kod haqiqatan bajarildi va natija solishtirildi.');
    case FillBlank():
      if (a is! TextAnswer) return const Verdict(false);
      final filled = q.template.replaceAll('____', a.text.trim());
      if (q.expectedOutput != null) {
        final r = runCached(filled);
        if (!r.compiled) {
          return Verdict(false,
              correctAnswerText: q.accepted.isEmpty ? null : q.accepted.first,
              detail: 'Kod kompilyatsiya bo\'lmadi: ${r.diagnostics.firstWhere((d) => d.isError).message}');
        }
        final ok = r.error == null && _norm(r.stdout) == _norm(q.expectedOutput!);
        return Verdict(ok,
            correctAnswerText: q.accepted.isEmpty ? null : q.accepted.first,
            detail: ok ? null : 'Sizning javobingiz bilan natija: ${_norm(r.stdout).isEmpty ? '(bo\'sh)' : _norm(r.stdout)}');
      }
      return Verdict(q.accepted.contains(a.text.trim()), correctAnswerText: q.accepted.first);
    case ArrangeLines():
      if (a is! OrderAnswer) return const Verdict(false);
      final correctText = q.lines.join('\n');
      if (!q.byOutput) return Verdict(_listEq(a.lines, q.lines), correctAnswerText: correctText);
      String program(List<String> lines) => q.wrapInMain ? _withMain(lines.join('\n')) : lines.join('\n');
      final expected = runCached(program(q.lines));
      final got = runCached(program(a.lines));
      final ok = got.compiled && got.error == null && _norm(got.stdout) == _norm(expected.stdout);
      return Verdict(ok,
          correctAnswerText: correctText,
          detail: ok ? 'Kodingiz bajarildi va kutilgan natijani berdi.' : (got.compiled ? 'Natija boshqacha chiqdi.' : 'Bu tartibda kod kompilyatsiya bo\'lmaydi.'));
    case FindBug():
      return Verdict(a is IndexAnswer && a.index == q.bugLine, correctAnswerText: '${q.bugLine}-qator');
    case MatchPairs():
      if (a is! PairsAnswer) return const Verdict(false);
      final ok = q.pairs.every((p) => a.map[p.$1] == p.$2);
      return Verdict(ok, correctAnswerText: q.pairs.map((p) => '${p.$1} → ${p.$2}').join('\n'));
    case WriteCode():
      if (a is! CodeAnswer) return const Verdict(false);
      final g = gradeTask(q.task, a.code);
      return Verdict(g.passed, grade: g, correctAnswerText: q.task.solution);
  }
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].trim() != b[i].trim()) return false;
  }
  return true;
}

String questionTypeLabel(Question q) => switch (q) {
  SingleChoice() => 'Bitta javob',
  MultiChoice() => 'Bir nechta javob',
  TrueFalse() => 'To\'g\'ri / Noto\'g\'ri',
  PredictOutput() => 'Natijani taxmin qiling',
  FillBlank() => 'Bo\'sh joyni to\'ldiring',
  ArrangeLines() => 'Tartibga qo\'ying',
  FindBug() => 'Xatoni toping',
  MatchPairs() => 'Moslang',
  WriteCode() => 'Kod yozing',
};
