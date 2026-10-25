import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../code/code_controller.dart';
import '../code/code_editor.dart';
import '../code/code_view.dart';
import 'quiz_engine.dart';

class QuizSummary {
  const QuizSummary({required this.verdicts, required this.questions});
  final List<Verdict> verdicts;
  final List<Question> questions;

  int get correct => verdicts.where((v) => v.correct).length;
  int get total => questions.length;
  int get score => total == 0 ? 0 : (correct * 100 / total).round();
  List<String> get wrongTopics => [
    for (var i = 0; i < total; i++)
      if (!verdicts[i].correct && questions[i].topic.isNotEmpty) questions[i].topic,
  ];
}

/// Savollarni ketma-ket ko'rsatuvchi va baholovchi komponent.
class QuizRunner extends StatefulWidget {
  const QuizRunner({
    super.key,
    required this.questions,
    required this.onFinished,
    this.passScore = 60,
    this.resultsActions,
    this.seed = 1,
  });

  final List<Question> questions;
  final ValueChanged<QuizSummary> onFinished;
  final int passScore;
  final Widget Function(BuildContext context, QuizSummary summary, VoidCallback retry)? resultsActions;
  final int seed;

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int _i = 0;
  final _answers = <int, Answer>{};
  final _verdicts = <int, Verdict>{};
  QuizSummary? _summary;
  int _attempt = 0;

  void _check() {
    final q = widget.questions[_i];
    final v = gradeQuestion(q, _answers[_i]);
    HapticFeedback.lightImpact();
    setState(() => _verdicts[_i] = v);
  }

  void _next() {
    if (_i + 1 < widget.questions.length) {
      setState(() => _i++);
    } else {
      final s = QuizSummary(verdicts: [for (var k = 0; k < widget.questions.length; k++) _verdicts[k]!], questions: widget.questions);
      setState(() => _summary = s);
      widget.onFinished(s);
    }
  }

  void _retry() => setState(() {
    _i = 0;
    _answers.clear();
    _verdicts.clear();
    _summary = null;
    _attempt++;
  });

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const EmptyState(icon: Icons.quiz_outlined, title: 'Savollar yo\'q', message: 'Bu bo\'lim uchun savollar hali qo\'shilmagan.');
    }
    final s = _summary;
    if (s != null) return _Results(summary: s, passScore: widget.passScore, actions: widget.resultsActions?.call(context, s, _retry), onRetry: _retry);
    final q = widget.questions[_i];
    final v = _verdicts[_i];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('Savol ${_i + 1} / ${widget.questions.length}'.uz, style: context.text.labelLarge),
        const SizedBox(width: 10),
        KBadge(questionTypeLabel(q), color: KColors.violet),
        const Spacer(),
        for (var k = 0; k < widget.questions.length; k++)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _verdicts[k] == null
                  ? (k == _i ? KColors.primary : context.k.borderStrong)
                  : (_verdicts[k]!.correct ? KColors.success : KColors.error),
            ),
          ),
      ]),
      const SizedBox(height: 14),
      AnimatedSwitcher(
        duration: KDurations.medium,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a), child: c),
        ),
        child: KeyedSubtree(
          key: ValueKey('$_attempt-$_i'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RichUz(q.prompt, style: context.text.titleMedium),
            if (q.code != null && q is! FindBug) ...[
              const SizedBox(height: 12),
              CodeFrame(code: q.code, child: CodeView(code: q.code!, showLineNumbers: true)),
            ],
            const SizedBox(height: 14),
            AbsorbPointer(
              absorbing: v != null,
              child: _AnswerInput(
                question: q,
                seed: widget.seed * 31 + _i + _attempt * 7,
                answer: _answers[_i],
                verdict: v,
                onChanged: (a) => setState(() => _answers[_i] = a),
              ),
            ),
            const SizedBox(height: 14),
            if (v != null) ...[
              FeedbackBanner(
                kind: v.correct ? FeedbackKind.success : FeedbackKind.error,
                title: v.correct ? 'To\'g\'ri! 🎉' : 'Noto\'g\'ri',
                message: q.explanation,
                child: v.correct || v.correctAnswerText == null
                    ? (v.detail == null ? null : Text(v.detail!.uz, style: context.text.bodySmall))
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('To\'g\'ri javob:'.uz, style: context.text.labelMedium),
                        const SizedBox(height: 4),
                        SelectableText(v.correctAnswerText!, style: codeStyle(size: 13, color: context.k.text)),
                        if (v.detail != null) ...[const SizedBox(height: 6), Text(v.detail!.uz, style: context.text.bodySmall)],
                      ]),
              ),
              const SizedBox(height: 12),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: v == null
                  ? KButton(label: 'Tekshirish', icon: Icons.check_rounded, onPressed: _answers[_i] == null ? null : _check)
                  : KButton(
                      label: _i + 1 < widget.questions.length ? 'Keyingi savol' : 'Natijani ko\'rish',
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _AnswerInput extends StatefulWidget {
  const _AnswerInput({required this.question, required this.seed, required this.answer, required this.verdict, required this.onChanged});
  final Question question;
  final int seed;
  final Answer? answer;
  final Verdict? verdict;
  final ValueChanged<Answer> onChanged;

  @override
  State<_AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<_AnswerInput> {
  late List<int> _order;
  late List<String> _lines;
  late List<String> _rights;
  final _text = TextEditingController();
  CodeEditingController? _code;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    final rnd = math.Random(widget.seed);
    final n = switch (q) {
      SingleChoice() => q.options.length,
      MultiChoice() => q.options.length,
      PredictOutput() => q.options?.length ?? 0,
      _ => 0,
    };
    _order = List.generate(n, (i) => i)..shuffle(rnd);
    _lines = q is ArrangeLines ? (List.of(q.lines)..shuffle(rnd)) : const [];
    if (q is ArrangeLines && q.lines.length > 1) {
      var guard = 0;
      while (_lines.join() == q.lines.join() && guard++ < 10) {
        _lines.shuffle(rnd);
      }
    }
    _rights = q is MatchPairs ? ([for (final p in q.pairs) p.$2]..shuffle(rnd)) : const [];
    if (q is WriteCode) _code = CodeEditingController(text: q.task.starter);
    if (q is ArrangeLines) WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(OrderAnswer(List.of(_lines))));
  }

  @override
  void dispose() {
    _text.dispose();
    _code?.dispose();
    super.dispose();
  }

  Widget _option(int original, String text, {required bool selected, required bool multi, bool code = false}) {
    final k = context.k;
    final v = widget.verdict;
    Color? border;
    IconData? mark;
    if (v != null && selected) {
      border = v.correct ? KColors.success : KColors.error;
      mark = v.correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    } else if (selected) {
      border = KColors.primary;
    }
    final letter = String.fromCharCode(65 + _order.indexOf(original));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: KCard(
        padding: const EdgeInsets.all(12),
        borderColor: border,
        color: selected ? k.primarySoft : null,
        onTap: () {
          HapticFeedback.selectionClick();
          if (multi) {
            final cur = (widget.answer as SetAnswer?)?.indexes ?? <int>{};
            final next = {...cur};
            next.contains(original) ? next.remove(original) : next.add(original);
            widget.onChanged(SetAnswer(next));
          } else {
            widget.onChanged(IndexAnswer(original));
          }
        },
        semanticLabel: '$letter variant: $text',
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? KColors.primary : k.surfaceAlt,
              borderRadius: BorderRadius.circular(multi ? 8 : 15),
            ),
            child: Text(letter, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : k.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: code
                ? Text(text, style: codeStyle(size: 13.5, color: k.text))
                : RichUz(text, style: context.text.bodyLarge),
          ),
          if (mark != null) Icon(mark, color: border),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final a = widget.answer;
    switch (q) {
      case SingleChoice():
        return Column(children: [
          for (final i in _order) _option(i, q.options[i], selected: a is IndexAnswer && a.index == i, multi: false),
        ]);
      case MultiChoice():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bir nechta to\'g\'ri javob bo\'lishi mumkin'.uz, style: context.text.bodySmall),
          const SizedBox(height: 8),
          for (final i in _order) _option(i, q.options[i], selected: a is SetAnswer && a.indexes.contains(i), multi: true),
        ]);
      case TrueFalse():
        Widget btn(bool value, String label, IconData icon) => Expanded(
          child: KCard(
            onTap: () => widget.onChanged(BoolAnswer(value)),
            borderColor: a is BoolAnswer && a.value == value ? KColors.primary : null,
            color: a is BoolAnswer && a.value == value ? context.k.primarySoft : null,
            child: Column(children: [
              Icon(icon, size: 30, color: value ? KColors.success : KColors.error),
              const SizedBox(height: 6),
              Text(label.uz, style: context.text.titleSmall),
            ]),
          ),
        );
        return Row(children: [
          btn(true, 'To\'g\'ri', Icons.thumb_up_alt_rounded),
          const SizedBox(width: 12),
          btn(false, 'Noto\'g\'ri', Icons.thumb_down_alt_rounded),
        ]);
      case PredictOutput():
        if (q.options != null) {
          return Column(children: [
            for (final i in _order) _option(i, q.options![i], selected: a is IndexAnswer && a.index == i, multi: false, code: true),
          ]);
        }
        return TextField(
          controller: _text,
          maxLines: null,
          minLines: 2,
          style: codeStyle(size: 14, color: context.k.text),
          decoration: InputDecoration(
            hintText: 'Konsolda chiqadigan natijani aynan yozing (har bir qator alohida)'.uz,
            prefixIcon: const Icon(Icons.terminal_rounded),
          ),
          onChanged: (t) => widget.onChanged(TextAnswer(t)),
        );
      case FillBlank():
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CodeFrame(child: CodeView(code: q.template.replaceAll('____', '▁▁▁▁'), showLineNumbers: true)),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            style: codeStyle(size: 14.5, color: context.k.text),
            decoration: InputDecoration(hintText: '▁▁▁▁ o\'rniga nima yoziladi?'.uz, prefixIcon: const Icon(Icons.edit_rounded)),
            onChanged: (t) => widget.onChanged(TextAnswer(t)),
          ),
        ]);
      case ArrangeLines():
        return ClipRRect(
          borderRadius: BorderRadius.circular(KRadius.md),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (from, to) {
              setState(() {
                final item = _lines.removeAt(from);
                _lines.insert(to, item);
              });
              widget.onChanged(OrderAnswer(List.of(_lines)));
            },
            children: [
              for (var i = 0; i < _lines.length; i++)
                ReorderableDragStartListener(
                  key: ValueKey('${_lines[i]}#$i'),
                  index: i,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.k.surface,
                      borderRadius: BorderRadius.circular(KRadius.md),
                      border: Border.all(color: context.k.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.drag_indicator_rounded, color: context.k.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: q.byOutput
                            ? Text(_lines[i], style: codeStyle(size: 13.5, color: context.k.text))
                            : UzText(_lines[i], style: context.text.bodyLarge),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        );
      case FindBug():
        final lines = q.code!.split('\n');
        return CodeFrame(
          title: 'Xatoli qatorni bosing',
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < lines.length; i++)
              InkWell(
                onTap: () => widget.onChanged(IndexAnswer(i + 1)),
                child: Container(
                  color: a is IndexAnswer && a.index == i + 1
                      ? (widget.verdict == null ? KColors.primary.withValues(alpha: 0.25) : (widget.verdict!.correct ? KColors.success : KColors.error).withValues(alpha: 0.3))
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Row(children: [
                    SizedBox(width: 26, child: Text('${i + 1}', style: codeStyle(size: 12.5, color: CodePalette.dark.lineNumber))),
                    Expanded(child: Text(lines[i], style: codeStyle(size: 13.5, color: CodePalette.dark.text))),
                  ]),
                ),
              ),
            const SizedBox(height: 6),
          ]),
        );
      case MatchPairs():
        final map = a is PairsAnswer ? a.map : <String, String>{};
        return Column(children: [
          for (final p in q.pairs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: KCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(children: [
                  Expanded(child: Text(p.$1.uz, style: context.text.titleSmall)),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: map[p.$1],
                      hint: Text('Tanlang'.uz),
                      underline: const SizedBox.shrink(),
                      items: [for (final r in _rights) DropdownMenuItem(value: r, child: Text(r.uz, maxLines: 2))],
                      onChanged: (v) {
                        if (v == null) return;
                        widget.onChanged(PairsAnswer({...map, p.$1: v}));
                      },
                    ),
                  ),
                ]),
              ),
            ),
        ]);
      case WriteCode():
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          RichUz(q.task.instructions, style: context.text.bodyMedium),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(KRadius.md),
            child: KitobCodeEditor(
              controller: _code!,
              expands: false,
              minLines: 8,
              showKeyBar: false,
              requireMain: q.task.requireMain,
              onDiagnostics: (_) => widget.onChanged(CodeAnswer(_code!.text)),
            ),
          ),
          if (widget.verdict?.grade != null) ...[
            const SizedBox(height: 8),
            for (final r in widget.verdict!.grade!.results)
              Row(children: [
                Icon(r.passed ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: r.passed ? KColors.success : KColors.error),
                const SizedBox(width: 6),
                Expanded(child: RichUz(r.title, style: context.text.bodySmall)),
              ]),
          ],
        ]);
    }
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.summary, required this.passScore, required this.onRetry, this.actions});
  final QuizSummary summary;
  final int passScore;
  final VoidCallback onRetry;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final passed = summary.score >= passScore;
    final topics = summary.wrongTopics.toSet();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      KCard(
        child: Row(children: [
          KProgressRing(
            value: summary.score / 100,
            size: 96,
            stroke: 9,
            color: passed ? KColors.success : KColors.warning,
            center: Text('${summary.score}%', style: context.text.titleLarge!.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((passed ? 'Ajoyib natija!' : 'Yana bir oz mashq kerak').uz, style: context.text.headlineSmall),
              const SizedBox(height: 6),
              Text('✓ ${summary.correct} to\'g\'ri   ✗ ${summary.total - summary.correct} xato'.uz, style: context.text.bodyLarge),
              const SizedBox(height: 4),
              Text((passed ? 'O\'tish bali: $passScore% — muvaffaqiyatli' : 'O\'tish uchun kamida $passScore% kerak').uz,
                  style: context.text.bodySmall),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      if (topics.isNotEmpty)
        FeedbackBanner(
          kind: FeedbackKind.warning,
          title: 'Qayta o\'rganish tavsiya etiladi',
          message: 'Quyidagi mavzularda xato bo\'ldi: ${topics.map((t) => '**$t**').join(', ')}. Tushuntirishni qayta o\'qing yoki AI ustozdan boshqa misol so\'rang.',
        ),
      const SizedBox(height: 12),
      ?actions,
      const SizedBox(height: 12),
      SectionHeader('Javoblar tahlili'),
      for (var i = 0; i < summary.total; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: KCard(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(summary.verdicts[i].correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: summary.verdicts[i].correct ? KColors.success : KColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RichUz(summary.questions[i].prompt, style: context.text.titleSmall),
                  const SizedBox(height: 4),
                  RichUz(summary.questions[i].explanation, style: context.text.bodySmall),
                ]),
              ),
            ]),
          ),
        ),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerLeft, child: KButton(label: 'Qayta topshirish', icon: Icons.replay_rounded, variant: KButtonVariant.ghost, onPressed: onRetry)),
    ]);
  }
}
