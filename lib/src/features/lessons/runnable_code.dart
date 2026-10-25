import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/runner/grader.dart';
import '../../core/runner/runner.dart';
import '../../core/state/progress.dart';
import '../code/code_controller.dart';
import '../code/code_editor.dart';
import '../code/code_view.dart';
import '../code/console_view.dart';
import '../flutter_preview/preview_view.dart';
import '../visualizer/visualizer_view.dart';

/// Dars ichidagi ishlaydigan kod namunasi.
class RunnableCode extends ConsumerStatefulWidget {
  const RunnableCode({super.key, required this.block, this.lessonId});
  final CodeBlock block;
  final String? lessonId;

  @override
  ConsumerState<RunnableCode> createState() => _RunnableCodeState();
}

class _RunnableCodeState extends ConsumerState<RunnableCode> {
  final _runner = CodeRunner();
  ExecutionResult? _result;
  bool _running = false;
  bool _editing = false;
  String? _previewSource;
  late final _ctrl = CodeEditingController(text: widget.block.code);
  final _editorKey = GlobalKey<KitobCodeEditorState>();

  @override
  void dispose() {
    _runner.stop();
    _ctrl.dispose();
    super.dispose();
  }

  String get _code => _editing ? _ctrl.text : widget.block.code;

  Future<void> _run() async {
    if (widget.block.preview) {
      ref.read(progressProvider.notifier).recordCodeRun();
      // Bir xil kod qayta bosilsa ham ilova boshidan ishga tushsin.
      setState(() => _previewSource = _previewSource == _code ? '$_code\n' : _code);
      return;
    }
    setState(() => _running = true);
    final r = await _runner.run(_code, options: ExecutionOptions(stdin: widget.block.stdin));
    if (!mounted) return;
    ref.read(progressProvider.notifier).recordCodeRun();
    setState(() {
      _running = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    final notes = b.lineNotes.entries.toList()..sort((a, c) => a.key.compareTo(c.key));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CodeFrame(
        title: b.title ?? 'main.dart',
        code: _code,
        actions: [
          if (b.editable && b.runnable)
            TextButton.icon(
              onPressed: () => setState(() {
                _editing = !_editing;
                if (!_editing) _ctrl.text = b.code;
              }),
              icon: Icon(_editing ? Icons.undo_rounded : Icons.edit_rounded, size: 16),
              label: Text((_editing ? 'Asliga qaytarish' : 'Tahrirlash').uz),
            ),
        ],
        child: _editing
            ? KitobCodeEditor(key: _editorKey, controller: _ctrl, expands: false, minLines: 3, onRun: _run, showKeyBar: context.isCompact)
            : CodeView(code: b.code, explain: b.explain),
      ),
      if (b.explain.isNotEmpty && !_editing) ...[
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.touch_app_rounded, size: 15, color: KColors.cyan),
          const SizedBox(width: 6),
          Expanded(child: Text('Nuqtali tagchizilgan so\'zlarni bosing — ma\'nosi tushuntiriladi'.uz, style: context.text.bodySmall)),
        ]),
      ],
      if (b.runnable) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          KButton(
            label: b.preview ? (_previewSource == null ? 'Ekranda ko\'rish' : 'Qayta ishga tushirish') : (_running ? 'Bajarilmoqda' : 'Ishga tushirish'),
            icon: Icons.play_arrow_rounded,
            variant: KButtonVariant.success,
            compact: true,
            loading: _running,
            onPressed: _run,
          ),
          if (b.visualize && !b.preview)
            KButton(
              label: 'Qadam-baqadam',
              icon: Icons.slow_motion_video_rounded,
              variant: KButtonVariant.secondary,
              compact: true,
              onPressed: () => showVisualizer(context, _code, stdin: b.stdin),
            ),
          KButton(
            label: 'Playgroundda ochish',
            icon: Icons.open_in_new_rounded,
            variant: KButtonVariant.ghost,
            compact: true,
            onPressed: () => context.go('/practice/playground', extra: _code),
          ),
        ]),
        if (_previewSource != null) ...[
          const SizedBox(height: 12),
          Center(child: FlutterPreview(source: _previewSource!, height: 460, onJumpToLine: _editing ? (l) => _editorKey.currentState?.jumpToLine(l) : null)),
        ],
        if (_result != null || _running) ...[
          const SizedBox(height: 10),
          if (_result != null && !_result!.compiled) ...[
            ProblemsView(
              diagnostics: _result!.diagnostics.where((d) => d.isError).toList(),
              onTap: _editing ? (d) => _editorKey.currentState?.jumpToLine(d.line) : null,
            ),
          ] else
            ConsoleView(result: _result, running: _running),
        ],
      ],
      if (notes.isNotEmpty) ...[
        const SizedBox(height: 10),
        KCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Qatorma-qator izoh'.uz, style: context.text.titleSmall),
            const SizedBox(height: 8),
            for (final n in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  KBadge('${n.key}-qator', color: KColors.cyan),
                  const SizedBox(width: 8),
                  Expanded(child: RichUz(n.value, style: context.text.bodyMedium)),
                ]),
              ),
          ]),
        ),
      ],
    ]);
  }
}

/// "Xatoni top va tuzat" mashqi. Tuzatilgan kod tahlil qilinib, bajarilib,
/// to'g'ri yechim natijasi bilan solishtiriladi.
class BugFixer extends ConsumerStatefulWidget {
  const BugFixer({super.key, required this.block, this.lessonId});
  final BuggyCodeBlock block;
  final String? lessonId;

  @override
  ConsumerState<BugFixer> createState() => _BugFixerState();
}

class _BugFixerState extends ConsumerState<BugFixer> {
  late final _ctrl = CodeEditingController(text: widget.block.code);
  final _editorKey = GlobalKey<KitobCodeEditorState>();
  ExecutionResult? _result;
  bool? _fixed;
  bool _hint = false;
  bool _checking = false;
  int _attempts = 0;
  bool _showSolution = false;
  String? _previewSource;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (widget.block.preview) return _checkFlutter();
    setState(() => _checking = true);
    final code = _ctrl.text;
    final fixed = widget.block.fixed;
    final (mine, expected) = await computeHeavy(_runPair, (code, fixed));
    if (!mounted) return;
    final ok = mine.compiled && mine.error == null && normalizeOutput(mine.stdout) == normalizeOutput(expected.stdout);
    if (ok && widget.lessonId != null) ref.read(progressProvider.notifier).fixBug(widget.lessonId!);
    ref.read(progressProvider.notifier).recordCodeRun();
    setState(() {
      _checking = false;
      _result = mine;
      _fixed = ok;
      _attempts++;
    });
  }

  /// Flutter: tuzatilgan kodning widget daraxti to'g'ri variantnikiga teng bo'lishi kerak.
  Future<void> _checkFlutter() async {
    setState(() => _checking = true);
    final code = _ctrl.text;
    final (diags, mineTree, fixedTree) = await computeHeavy(_flutterTreePair, (code, widget.block.fixed));
    if (!mounted) return;
    final ok = mineTree != null && mineTree == fixedTree;
    if (ok && widget.lessonId != null) ref.read(progressProvider.notifier).fixBug(widget.lessonId!);
    ref.read(progressProvider.notifier).recordCodeRun();
    setState(() {
      _checking = false;
      _result = ExecutionResult(stdout: '', diagnostics: diags, elapsedMicros: 0);
      _previewSource = diags.any((d) => d.isError) ? null : code;
      _fixed = ok;
      _attempts++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.block;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const KIconBox(Icons.bug_report_rounded, color: KColors.error, size: 36),
        const SizedBox(width: 10),
        Expanded(child: RichUz(b.task, style: context.text.titleSmall)),
      ]),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(KRadius.lg),
        child: KitobCodeEditor(key: _editorKey, controller: _ctrl, expands: false, minLines: 3, onRun: _check, showKeyBar: context.isCompact),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        KButton(label: 'Tekshirish', icon: Icons.fact_check_rounded, compact: true, loading: _checking, onPressed: _check),
        if (b.hint != null && !_hint)
          KButton(label: 'Ishora', icon: Icons.lightbulb_outline_rounded, variant: KButtonVariant.ghost, compact: true, onPressed: () => setState(() => _hint = true)),
        KButton(
          label: 'Qaytadan',
          icon: Icons.restart_alt_rounded,
          variant: KButtonVariant.ghost,
          compact: true,
          onPressed: () => setState(() {
            _ctrl.text = b.code;
            _fixed = null;
            _result = null;
          }),
        ),
      ]),
      if (_hint && b.hint != null) ...[
        const SizedBox(height: 10),
        FeedbackBanner(kind: FeedbackKind.info, title: 'Ishora', message: b.hint),
      ],
      if (_result != null) ...[
        const SizedBox(height: 10),
        if (_previewSource != null) ...[
          Center(child: FlutterPreview(source: _previewSource!, height: 420, onJumpToLine: (l) => _editorKey.currentState?.jumpToLine(l))),
          const SizedBox(height: 10),
        ],
        if (_fixed == true)
          FeedbackBanner(kind: FeedbackKind.success, title: 'Xato tuzatildi! +10 XP', message: '**Sabab:** ${b.why}')
        else ...[
          if (b.preview && _result!.compiled)
            const FeedbackBanner(kind: FeedbackKind.warning, title: 'Ekran hali kutilganidek emas', message: 'Kod ishga tushdi, lekin widgetlar daraxti to\'g\'ri variantdan farq qiladi. Oynadagi natijani diqqat bilan ko\'ring.')
          else if (!_result!.compiled)
            ProblemsView(
              diagnostics: _result!.diagnostics.where((d) => d.isError).toList(),
              onTap: (d) => _editorKey.currentState?.jumpToLine(d.line),
            )
          else if (!b.preview) ...[
            ConsoleView(result: _result),
            const SizedBox(height: 8),
            const FeedbackBanner(kind: FeedbackKind.warning, title: 'Kod ishladi, lekin natija kutilganidek emas', message: 'Mantiqiy xato qolgan bo\'lishi mumkin. Natijani diqqat bilan o\'qing.'),
          ],
          if (_attempts >= 2 && !_showSolution) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(onPressed: () => setState(() => _showSolution = true), icon: const Icon(Icons.visibility_rounded), label: Text('Tuzatilgan variantni ko\'rish'.uz)),
            ),
          ],
          if (_showSolution) ...[
            const SizedBox(height: 8),
            FeedbackBanner(kind: FeedbackKind.info, title: 'Sabab', message: b.why),
            const SizedBox(height: 8),
            CodeFrame(title: 'To\'g\'ri variant', code: b.fixed, child: CodeView(code: b.fixed)),
          ],
        ],
      ],
    ]);
  }
}

/// Mustaqil kod yozish vazifasi — yashirin testlar bilan baholanadi.
class TaskWorkspace extends ConsumerStatefulWidget {
  const TaskWorkspace({super.key, required this.task, this.lessonId, this.practiceId, this.onSolved});
  final CodeTask task;
  final String? lessonId;
  final String? practiceId;
  final VoidCallback? onSolved;

  @override
  ConsumerState<TaskWorkspace> createState() => _TaskWorkspaceState();
}

class _TaskWorkspaceState extends ConsumerState<TaskWorkspace> {
  late final _ctrl = CodeEditingController(text: widget.task.starter);
  final _editorKey = GlobalKey<KitobCodeEditorState>();
  final _runner = CodeRunner();
  GradeResult? _grade;
  ExecutionResult? _run;
  bool _busy = false;
  int _hints = 0;
  int _attempts = 0;
  bool _solution = false;
  String? _previewSource;

  @override
  void dispose() {
    _runner.stop();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _runOnly() async {
    if (widget.task.preview) {
      ref.read(progressProvider.notifier).recordCodeRun();
      final code = _ctrl.text;
      setState(() {
        _previewSource = _previewSource == code ? '$code\n' : code;
        _grade = null;
      });
      return;
    }
    setState(() => _busy = true);
    final firstStdin = widget.task.checks.whereType<OutputEquals>().where((c) => c.stdin.isNotEmpty).map((c) => c.stdin).firstOrNull ?? const <String>[];
    final r = await _runner.run(_ctrl.text, options: ExecutionOptions(stdin: firstStdin));
    if (!mounted) return;
    ref.read(progressProvider.notifier).recordCodeRun();
    setState(() {
      _busy = false;
      _run = r;
      _grade = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final task = widget.task;
    final code = _ctrl.text;
    final g = await computeHeavy(_gradeInIsolate, (task, code));
    if (!mounted) return;
    final n = ref.read(progressProvider.notifier);
    n.recordCodeRun();
    if (g.passed) {
      if (widget.lessonId != null) n.solveTask(widget.lessonId!);
      if (widget.practiceId != null) n.solvePracticeTask(widget.practiceId!);
      widget.onSolved?.call();
    }
    setState(() {
      _busy = false;
      _grade = g;
      _run = null;
      if (task.preview && g.compiled) _previewSource = code;
      _attempts++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final g = _grade;
    final visibleChecks = t.checks.where((c) => !c.hidden).toList();
    final hidden = t.checks.where((c) => c.hidden).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const KIconBox(Icons.assignment_rounded, color: KColors.primary, size: 38),
            const SizedBox(width: 10),
            Expanded(child: UzText(t.title, style: context.text.titleMedium)),
          ]),
          const SizedBox(height: 10),
          RichUzBlocks(t.instructions, style: context.text.bodyLarge),
          const SizedBox(height: 10),
          Text('Talablar:'.uz, style: context.text.labelLarge),
          const SizedBox(height: 4),
          for (final c in visibleChecks)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.radio_button_unchecked_rounded, size: 16, color: KColors.primary),
                const SizedBox(width: 6),
                Expanded(child: RichUz(_checkLabel(c), style: context.text.bodyMedium)),
              ]),
            ),
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                const Icon(Icons.visibility_off_rounded, size: 16, color: KColors.violet),
                const SizedBox(width: 6),
                Expanded(child: Text('+ $hidden ta yashirin test (chegaraviy holatlar)'.uz, style: context.text.bodySmall)),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(KRadius.lg),
        child: KitobCodeEditor(
          key: _editorKey,
          controller: _ctrl,
          expands: false,
          minLines: 8,
          requireMain: t.requireMain,
          onRun: _submit,
          showKeyBar: context.isCompact,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        KButton(label: 'Tekshirish', icon: Icons.fact_check_rounded, loading: _busy, compact: true, onPressed: _submit),
        KButton(label: t.preview ? 'Ekranda ko\'rish' : 'Ishga tushirish', icon: t.preview ? Icons.phone_android_rounded : Icons.play_arrow_rounded, variant: KButtonVariant.success, compact: true, onPressed: _busy ? null : _runOnly),
        if (_hints < t.hints.length)
          KButton(
            label: _hints == 0 ? 'Ishora' : 'Kattaroq ishora',
            icon: Icons.lightbulb_outline_rounded,
            variant: KButtonVariant.ghost,
            compact: true,
            onPressed: () => setState(() => _hints++),
          ),
        if ((_attempts >= 2 || _hints >= t.hints.length) && !_solution)
          KButton(label: 'Yechimni ko\'rish', icon: Icons.visibility_rounded, variant: KButtonVariant.ghost, compact: true, onPressed: () => setState(() => _solution = true)),
      ]),
      for (var i = 0; i < _hints; i++) ...[
        const SizedBox(height: 8),
        FeedbackBanner(
          kind: FeedbackKind.info,
          title: ['1-ishora', '2-ishora (kattaroq)', '3-ishora (qisman yechim)', '4-ishora'][i.clamp(0, 3)],
          child: t.hints[i].contains('\n') || t.hints[i].contains(';')
              ? CodeFrame(title: 'ishora', child: CodeView(code: t.hints[i], showLineNumbers: false))
              : RichUz(t.hints[i], style: context.text.bodyMedium),
        ),
      ],
      if (_previewSource != null) ...[
        const SizedBox(height: 12),
        Center(child: FlutterPreview(source: _previewSource!, height: 480, onJumpToLine: (l) => _editorKey.currentState?.jumpToLine(l))),
      ],
      if (_run != null) ...[
        const SizedBox(height: 10),
        if (!_run!.compiled)
          ProblemsView(diagnostics: _run!.diagnostics.where((d) => d.isError).toList(), onTap: (d) => _editorKey.currentState?.jumpToLine(d.line))
        else
          ConsoleView(result: _run, onJumpToLine: (l) => _editorKey.currentState?.jumpToLine(l)),
      ],
      if (g != null) ...[
        const SizedBox(height: 12),
        if (!g.compiled)
          ProblemsView(diagnostics: g.diagnostics.where((d) => d.isError).toList(), onTap: (d) => _editorKey.currentState?.jumpToLine(d.line))
        else ...[
          FeedbackBanner(
            kind: g.passed ? FeedbackKind.success : FeedbackKind.error,
            title: g.passed ? 'Barcha testlardan o\'tdingiz! 🎉' : '${g.passedCount}/${g.results.length} test o\'tdi',
            message: g.passed
                ? 'Yechimingiz haqiqiy bajarish va yashirin testlar bilan tekshirildi.'
                : 'O\'tmagan testlarni ko\'ring. Kerak bo\'lsa ishoradan foydalaning — bu uyat emas, o\'rganish usuli.',
          ),
          const SizedBox(height: 8),
          for (final r in g.results) _CheckRow(r: r),
          if (g.error != null) ...[const SizedBox(height: 8), RuntimeErrorCard(error: g.error!, onJumpToLine: (l) => _editorKey.currentState?.jumpToLine(l))],
        ],
      ],
      if (_solution) ...[
        const SizedBox(height: 12),
        FeedbackBanner(
          kind: FeedbackKind.info,
          title: 'Namuna yechim',
          message: 'Bu yagona to\'g\'ri yechim emas — boshqa usul ham testlardan o\'tsa qabul qilinadi. Yechimni tushunib, keyin o\'zingiz qayta yozib ko\'ring.',
          child: CodeFrame(title: 'yechim.dart', code: t.solution, child: CodeView(code: t.solution)),
        ),
      ],
    ]);
  }

  String _checkLabel(Check c) => switch (c) {
    OutputEquals() => c.label ?? 'Natija: `${c.expected.trim().replaceAll('\n', ' ⏎ ')}`',
    OutputContains() => c.label ?? 'Natijada `${c.text}` bo\'lsin',
    EvaluatesTo() => '`${c.expression}` → `${c.expected}`',
    UsesConstruct() => c.requirement,
    WidgetExists() => c.label ?? widgetExistsLabel(c),
    AfterTap() => c.label ?? afterTapLabel(c),
  };
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.r});
  final CheckResult r;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: KCard(
      padding: const EdgeInsets.all(10),
      borderColor: r.passed ? KColors.success.withValues(alpha: 0.5) : KColors.error.withValues(alpha: 0.5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(r.passed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: r.passed ? KColors.success : KColors.error, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichUz(r.title, style: context.text.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
            if (r.detail != null) Text(r.detail!.uz, style: context.text.bodySmall),
            if (!r.passed && r.expected != null) ...[
              const SizedBox(height: 4),
              Text('Kutilgan: ${r.expected!.trimRight()}', style: codeStyle(size: 12.5, color: context.k.textSecondary)),
            ],
            if (!r.passed && r.actual != null)
              Text('Sizda: ${r.actual!.trimRight().isEmpty ? '(bo\'sh)' : r.actual!.trimRight()}', style: codeStyle(size: 12.5, color: context.k.textSecondary)),
          ]),
        ),
      ]),
    ),
  );
}

(ExecutionResult, ExecutionResult) _runPair((String, String) codes) => (KitobDart.run(codes.$1), KitobDart.run(codes.$2));

GradeResult _gradeInIsolate((CodeTask, String) a) => gradeTask(a.$1, a.$2);

/// Flutter "xatoni tuzat": ikkala kodning widget daraxti matn ko'rinishida.
(List<Diagnostic>, String?, String?) _flutterTreePair((String, String) codes) {
  String? tree(String code) {
    final (rt, _, err) = FlutterRuntime.open(code);
    if (rt == null || err != null) return null;
    try {
      return rt.expand().dump();
    } on FlutterRunError {
      return null;
    }
  }

  final diags = KitobDart.analyze(codes.$1);
  return (diags, diags.any((d) => d.isError) ? null : tree(codes.$1), tree(codes.$2));
}
