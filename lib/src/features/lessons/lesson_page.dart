import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' hide Block;

import '../../shared/bitik.dart';
import '../../content/curriculum.dart';
import '../../content/interview.dart';
import '../../content/model.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../quiz/quiz_runner.dart';
import '../terminal/terminal_task.dart';
import 'blocks.dart';
import 'runnable_code.dart';

enum _StepKind { goal, concept, example, bug, task, quiz, summary }

class _Step {
  const _Step(this.kind, this.title, this.icon);
  final _StepKind kind;
  final String title;
  final IconData icon;
}

List<_Step> _stepsFor(Lesson l) => [
  const _Step(_StepKind.goal, 'Maqsad', Icons.flag_rounded),
  const _Step(_StepKind.concept, 'Tushuncha', Icons.lightbulb_rounded),
  if (l.animation != null || l.syntax != null || l.example != null)
    const _Step(_StepKind.example, 'Ko\'rib o\'rgan', Icons.visibility_rounded),
  if (l.buggy != null) const _Step(_StepKind.bug, 'Xatoni tuzat', Icons.bug_report_rounded),
  if (l.task != null) const _Step(_StepKind.task, 'O\'zing yoz', Icons.edit_note_rounded),
  if (l.task == null && l.terminalTask != null) const _Step(_StepKind.task, 'Terminalda bajar', Icons.terminal_rounded),
  const _Step(_StepKind.quiz, 'Mini test', Icons.quiz_rounded),
  const _Step(_StepKind.summary, 'Xulosa', Icons.emoji_events_rounded),
];

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  late int _step;
  final _scroll = ScrollController();
  final _clock = Stopwatch()..start();
  QuizSummary? _quiz;
  bool _justCompleted = false;
  late final ProgressNotifier _notifier;

  Lesson? get _lesson => lessonById[widget.lessonId];

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(progressProvider.notifier);
    final p = ref.read(progressProvider).of(widget.lessonId);
    final steps = _lesson == null ? 0 : _stepsFor(_lesson!).length;
    _step = p.completed ? 0 : p.step.clamp(0, steps == 0 ? 0 : steps - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lesson != null) ref.read(progressProvider.notifier).openLesson(widget.lessonId);
    });
  }

  @override
  void dispose() {
    final secs = _clock.elapsed.inSeconds;
    if (secs > 5) {
      // Vaqt statistikasi — XP bermaydi (XP faqat bilim uchun).
      final notifier = _notifier;
      scheduleMicrotask(() => notifier.recordTime(secs.clamp(0, 3600)));
    }
    _scroll.dispose();
    super.dispose();
  }

  void _goto(int i, List<_Step> steps) {
    setState(() => _step = i.clamp(0, steps.length - 1));
    ref.read(progressProvider.notifier).setStep(widget.lessonId, _step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    if (lesson == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const KTopBar(),
        body: Builder(builder: (context) => EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Dars topilmadi',
          message: 'Bunday dars mavjud emas yoki hali tayyorlanmoqda.',
          action: 'Darslarga qaytish',
          onAction: () => context.go('/learn'),
        )),
      );
    }
    final steps = _stepsFor(lesson);
    final step = steps[_step];
    final level = levelOfLesson[lesson.id]!;
    final progress = ref.watch(progressProvider).of(lesson.id);

    return Scaffold(
      // Panel yo'q — suzuvchi ✕, sarlavha va bosqichlar. Kontent ular ostiga
      // kirmaydi: kod maydonlari fokuslanganda yoki aylantirilganda yashirinmasin.
      appBar: KTopBar(
        close: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/learn/level/${level.number}'),
        title: lesson.title,
        subtitle: '${level.number}-daraja · ${step.title}',
        actions: [
          if (progress.completed) const KBadge('Tugallangan', color: KColors.success, icon: Icons.check_rounded),
        ],
        bottom: _StepBar(steps: steps, current: _step, onTap: (i) => _goto(i, steps)),
        bottomHeight: 46,
      ),
      // Pastki panel kontent ustiga chiqmaydi: avtomatik aylantirilgan tugmalar
      // (masalan, "Tekshirish") hech qachon uning ostida qolib ketmasin.
      body: Column(children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: pagePadding(context).copyWith(bottom: 24),
            children: [
              ContentWidth(
                maxWidth: KBreakpoints.maxReading + 80,
                child: AnimatedSwitcher(
                  duration: KDurations.medium,
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(position: Tween(begin: const Offset(0.03, 0), end: Offset.zero).animate(a), child: c),
                  ),
                  child: KeyedSubtree(key: ValueKey(_step), child: _buildStep(context, lesson, step, steps)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: _BottomNav(
            canBack: _step > 0,
            nextLabel: switch (step.kind) {
              _StepKind.summary => (nextLessonAfter(lesson.id) == null ? 'Darslar ro\'yxati' : 'Keyingi dars'),
              _StepKind.quiz => _quiz == null ? 'Testsiz davom etish' : 'Xulosa',
              _ => 'Davom etish',
            },
            onBack: () => _goto(_step - 1, steps),
            onNext: () {
              if (step.kind == _StepKind.summary) {
                final next = nextLessonAfter(lesson.id);
                if (next != null && ref.read(progressProvider.notifier).isUnlocked(next.id)) {
                  context.go('/learn/lesson/${next.id}');
                } else {
                  context.go('/learn/level/${level.number}');
                }
                return;
              }
              _goto(_step + 1, steps);
            },
          ),
        ),
      ]),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: KSpace.xxl),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Kitobdagidek bir xil uslub: rangli "konfetti" emas, bitta urg'u rangi.
      Row(children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: context.k.primarySoft, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: context.isDark ? const Color(0xFF8CC8FF) : KColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Semantics(header: true, child: UzText(title, style: context.text.titleLarge))),
      ]),
      const SizedBox(height: 12),
      ...children,
    ]),
  );

  List<Widget> _spaced(List<Block> blocks, String lessonId) => [
    for (final b in blocks) Padding(padding: const EdgeInsets.only(bottom: 14), child: BlockView(b, lessonId: lessonId)),
  ];

  Widget _buildStep(BuildContext context, Lesson l, _Step step, List<_Step> steps) {
    switch (step.kind) {
      case _StepKind.goal:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            KIconBox(l.icon, size: 64, filled: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UzText(l.title, style: context.text.headlineMedium),
                const SizedBox(height: 4),
                UzText(l.subtitle, style: context.text.bodyLarge),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            KBadge('${l.minutes} daqiqa', icon: Icons.schedule_rounded),
            KBadge('+${l.xp} XP', icon: Icons.bolt_rounded, color: KColors.warning),
            KBadge('${l.quiz.length} ta savol', icon: Icons.quiz_rounded, color: KColors.violet),
            if (l.task != null) const KBadge('Amaliy vazifa', icon: Icons.code_rounded, color: KColors.success),
            if (l.terminalTask != null) const KBadge('Terminal mashqi', icon: Icons.terminal_rounded, color: KColors.success),
          ]),
          const SizedBox(height: KSpace.xl),
          _section('Bu darsda o\'rganasiz', Icons.flag_rounded, [
            for (final o in l.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle_outline_rounded, color: KColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: RichUz(o, style: context.text.bodyLarge)),
                ]),
              ),
          ]),
          if (l.prerequisites.isNotEmpty)
            _section('Oldindan kerakli bilimlar', Icons.link_rounded, [
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in l.prerequisites)
                  ActionChip(
                    avatar: const Icon(Icons.menu_book_rounded, size: 16),
                    label: Text(p.uz),
                    onPressed: () {
                      final target = allLessons.where((x) => x.title == p).firstOrNull;
                      if (target != null) context.go('/learn/lesson/${target.id}');
                    },
                  ),
              ]),
            ]),
          if (l.terms.isNotEmpty)
            _section('Yangi atamalar', Icons.translate_rounded, [
              Wrap(spacing: 8, runSpacing: 8, children: [for (final t in l.terms) Chip(label: Text('${t.term} — ${t.uz}'.uz))]),
            ]),
        ]);
      case _StepKind.concept:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _section('Oddiy tushuntirish', Icons.lightbulb_rounded, _spaced(l.intro, l.id)),
          _section('Hayotiy misol', Icons.emoji_objects_rounded, [AnalogyCard(l.analogy)]),
          _section('Nima uchun kerak?', Icons.help_outline_rounded, [RichUz(l.why, style: context.text.bodyLarge)]),
          _section('Qayerda ishlatiladi?', Icons.place_rounded, [
            for (final w in l.where)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.arrow_right_rounded, color: KColors.cyan),
                  Expanded(child: RichUz(w, style: context.text.bodyLarge)),
                ]),
              ),
          ]),
          if (l.terms.isNotEmpty)
            _section('Atamalar lug\'ati', Icons.translate_rounded, [
              for (final t in l.terms) Padding(padding: const EdgeInsets.only(bottom: 8), child: TermCard(t)),
            ]),
          if (l.extra.isNotEmpty && l.example == null) ..._spaced(l.extra, l.id),
          if (l.example == null && l.animation != null) ...[],
        ]);
      case _StepKind.example:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (l.animation != null) _section('Animatsion tushuntirish', Icons.animation_rounded, [BlockView(l.animation!)]),
          if (l.syntax != null) _section('Sintaksis', Icons.data_object_rounded, [SyntaxView(l.syntax!)]),
          if (l.example != null)
            _section('Ishlaydigan kod', Icons.code_rounded, [
              RunnableCode(block: l.example!, lessonId: l.id),
              if (l.example!.expectedOutput != null) ...[
                const SizedBox(height: 10),
                FeedbackBanner(
                  kind: FeedbackKind.info,
                  title: 'Kutilgan natija',
                  child: Text(l.example!.expectedOutput!.trimRight(), style: codeStyle(size: 13.5, color: context.k.text)),
                ),
              ],
            ]),
          for (final e in l.examples)
            _section(e.title ?? 'Yana bir misol', Icons.code_rounded, [RunnableCode(block: e, lessonId: l.id)]),
          if (l.example != null && l.extra.isNotEmpty) ..._spaced(l.extra, l.id),
        ]);
      case _StepKind.bug:
        return _section('Xatoli kodni tuzating', Icons.bug_report_rounded, [
          RichUz('Professional dasturchilar vaqtining katta qismini xato topishga sarflaydi. Xato xabarini **o\'qishni** o\'rganing — u sizga nima noto\'g\'ri ekanini aytadi.',
              style: context.text.bodyMedium),
          const SizedBox(height: 12),
          BugFixer(block: l.buggy!, lessonId: l.id),
        ]);
      case _StepKind.task:
        if (l.task == null) {
          return _section('Terminal vazifasi', Icons.terminal_rounded, [TerminalTaskWorkspace(task: l.terminalTask!, lessonId: l.id)]);
        }
        return _section('Mustaqil vazifa', Icons.edit_note_rounded, [TaskWorkspace(task: l.task!, lessonId: l.id)]);
      case _StepKind.quiz:
        return _section('Mini test', Icons.quiz_rounded, [
          RichUz('Kamida **60%** to\'g\'ri javob — dars tugallanadi va keyingi mavzu ochiladi.', style: context.text.bodyMedium),
          const SizedBox(height: 14),
          QuizRunner(
            key: ValueKey('quiz-${l.id}'),
            questions: l.quiz,
            seed: l.id.hashCode,
            onFinished: (s) {
              final wasDone = ref.read(progressProvider).isCompleted(l.id);
              final passed = ref.read(progressProvider.notifier).submitLessonQuiz(l, s.score, s.wrongTopics);
              setState(() {
                _quiz = s;
                _justCompleted = passed && !wasDone;
              });
            },
            resultsActions: (context, s, retry) => s.score >= 60
                ? FeedbackBanner(
                    kind: FeedbackKind.success,
                    title: _justCompleted ? 'Dars tugallandi! +${l.xp} XP' : 'Test muvaffaqiyatli topshirildi',
                    message: 'Xulosa bosqichiga o\'ting va keyingi mavzuga tayyorlaning.',
                    child: KButton(label: 'Xulosa', compact: true, trailingIcon: Icons.arrow_forward_rounded, onPressed: () => _goto(steps.length - 1, steps)),
                  )
                : FeedbackBanner(
                    kind: FeedbackKind.warning,
                    title: 'Shoshilmang — keling, boshqacha usulda ko\'ramiz',
                    message: 'Mavzuni qayta o\'qing, misollarni o\'zingiz o\'zgartirib ko\'ring, keyin testni qayta topshiring.',
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      KButton(label: 'Qayta tushuntirish', icon: Icons.lightbulb_rounded, compact: true, variant: KButtonVariant.secondary, onPressed: () => _goto(1, steps)),
                      if (l.example != null)
                        KButton(label: 'Misollarni ko\'rish', icon: Icons.code_rounded, compact: true, variant: KButtonVariant.secondary, onPressed: () => _goto(2, steps)),
                    ]),
                  ),
          ),
        ]);
      case _StepKind.summary:
        final p = ref.watch(progressProvider).of(l.id);
        final next = nextLessonAfter(l.id);
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (p.completed)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (c, v, ch) => Transform.scale(scale: v, child: ch),
              child: KCard(
                gradient: const LinearGradient(colors: [KColors.success, Color(0xFF22C55E)]),
                child: Row(children: [
                  const Bitik(mood: BitikMood.cheer, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Dars tugallandi!'.uz, style: context.text.titleLarge!.copyWith(color: Colors.white)),
                      Text('Test: ${p.bestQuiz}%${p.taskSolved ? ' · Vazifa ✓' : ''}${p.bugFixed ? ' · Xato tuzatildi ✓' : ''}'.uz,
                          style: const TextStyle(color: Colors.white)),
                    ]),
                  ),
                ]),
              ),
            )
          else
            FeedbackBanner(
              kind: FeedbackKind.warning,
              title: 'Dars hali tugallanmagan',
              message: 'Darsni tugatish uchun mini testdan kamida 60% oling.',
              child: KButton(label: 'Testga o\'tish', compact: true, onPressed: () => _goto(steps.indexWhere((s) => s.kind == _StepKind.quiz), steps)),
            ),
          const SizedBox(height: KSpace.xl),
          _section('Xulosa', Icons.summarize_rounded, [
            for (final s in l.summary)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_rounded, color: KColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: RichUz(s, style: context.text.bodyLarge)),
                ]),
              ),
          ]),
          // Dasturchi nigohi: shu mavzu ish suhbatlarida qanday so'raladi.
          if (interviewQuestions.any((q) => q.lessonId == l.id))
            _section('Bu mavzu intervyuda so\'raladi', Icons.work_outline_rounded, [
              for (final q in interviewQuestions.where((q) => q.lessonId == l.id))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: KCard(
                    onTap: () => context.go('/practice/interview'),
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      KBadge('${q.track.title} · ${q.level.title}', color: KColors.pink),
                      const SizedBox(width: 10),
                      Expanded(child: UzText(q.question, style: context.text.titleSmall)),
                      const Icon(Icons.chevron_right_rounded),
                    ]),
                  ),
                ),
              Text('Javobni avval o\'zingiz tuzing, keyin intervyu bo\'limida solishtiring.'.uz, style: context.text.bodySmall),
            ]),
          _section('Takrorlash tavsiyasi', Icons.psychology_rounded, [
            RichUz(l.revisionTip, style: context.text.bodyLarge),
            const SizedBox(height: 6),
            Text('Bu mavzu ertaga takrorlash ro\'yxatiga qo\'shiladi (intervalli takrorlash).'.uz, style: context.text.bodySmall),
          ]),
          if (l.next != null)
            _section('Keyingi qadam', Icons.arrow_forward_rounded, [
              RichUz(l.next!, style: context.text.bodyLarge),
              if (next != null) ...[
                const SizedBox(height: 10),
                KCard(
                  onTap: () => context.go('/learn/lesson/${next.id}'),
                  child: Row(children: [
                    KIconBox(next.icon),
                    const SizedBox(width: 12),
                    Expanded(child: UzText(next.title, style: context.text.titleSmall)),
                    const Icon(Icons.chevron_right_rounded),
                  ]),
                ),
              ],
            ]),
          if (l.links.isNotEmpty) _section('Rasmiy manbalar', Icons.public_rounded, [DocLinksView(l.links)]),
          Text('Kontent tekshirilgan: $contentSdk · $contentReviewed'.uz, style: context.text.bodySmall),
        ]);
    }
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current, required this.onTap});
  final List<_Step> steps;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 42, child: _chips(context)),
    // Butun dars bo'yicha umumiy progress — har bosqichda silliq to'ladi.
    TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (current + 1) / steps.length),
      duration: KDurations.slow,
      curve: KMotion.emphasized,
      builder: (context, v, _) => Container(
        height: 4,
        alignment: Alignment.centerLeft,
        color: context.k.surfaceHigh,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [KColors.primary, KColors.cyan]),
              boxShadow: [BoxShadow(color: KColors.cyan.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
        ),
      ),
    ),
  ]);

  Widget _chips(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    itemCount: steps.length,
    separatorBuilder: (_, _) => const SizedBox(width: 6),
    itemBuilder: (context, i) {
      final s = steps[i];
      final active = i == current;
      final done = i < current;
      return Semantics(
        button: true,
        selected: active,
        label: '${i + 1}-bosqich: ${s.title}'.uz,
        child: InkWell(
          borderRadius: BorderRadius.circular(KRadius.pill),
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: KDurations.medium,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: active ? null : (done ? context.k.successSoft : context.k.surfaceAlt),
              gradient: active ? const LinearGradient(colors: [KColors.primary, Color(0xFF1C9BF5)]) : null,
              borderRadius: BorderRadius.circular(KRadius.pill),
              boxShadow: [if (active) BoxShadow(color: KColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(children: [
              Icon(done ? Icons.check_rounded : s.icon, size: 16, color: active ? Colors.white : (done ? KColors.success : context.k.textMuted)),
              const SizedBox(width: 6),
              Text(s.title.uz,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : (done ? context.k.successText : context.k.textSecondary))),
            ]),
          ),
        ),
      );
    },
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.canBack, required this.nextLabel, required this.onBack, required this.onNext});
  final bool canBack;
  final String nextLabel;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Glass(
    radius: BorderRadius.zero,
    padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
    child: ContentWidth(
      maxWidth: KBreakpoints.maxReading + 80,
      // Tor ekran yoki katta shriftda ham sig'adi: tugmalar qisqaradi, "Orqaga" faqat ikonkaga aylanadi.
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 360;
        return Row(children: [
          if (canBack)
            KButton(label: narrow ? '' : 'Orqaga', icon: Icons.arrow_back_rounded, variant: KButtonVariant.ghost, onPressed: onBack, tooltip: narrow ? 'Orqaga' : null),
          const SizedBox(width: 10),
          const Spacer(),
          Flexible(flex: 6, child: KButton(label: nextLabel, trailingIcon: Icons.arrow_forward_rounded, onPressed: onNext)),
        ]);
      }),
    ),
  );
}
