import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import 'quiz_runner.dart';

/// Daraja savollar bankidan imtihon versiyasini yig'adi.
List<Question> buildExam(Level level, int version) {
  final rnd = math.Random(level.number * 1000 + version);
  final pool = <Question>[];
  for (final l in level.lessons) {
    final qs = List.of(l.quiz)..shuffle(rnd);
    pool.addAll(qs.take(2));
  }
  pool.shuffle(rnd);
  final picked = pool.take(math.min(10, pool.length)).toList();
  final tasks = [for (final l in level.lessons) if (l.task != null) l]..shuffle(rnd);
  for (final l in tasks.take(2)) {
    picked.add(WriteCode(
      prompt: 'Kod yozing: ${l.task!.title}',
      task: l.task!,
      explanation: 'Bu vazifa "${l.title}" darsidan. Yechim haqiqiy bajarish va yashirin testlar bilan tekshirildi.',
      topic: l.title,
    ));
  }
  return picked;
}

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key, required this.levelNumber});
  final int levelNumber;

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  bool _started = false;
  bool _finished = false;
  late int _version;
  List<Question>? _questions;
  final _clock = Stopwatch();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    final attempts = ref.read(progressProvider).history.where((h) => h.id == 'exam:${widget.levelNumber}').length;
    _version = attempts + 1;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _started = true);
    _clock.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_finished) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = curriculum.where((l) => l.number == widget.levelNumber).firstOrNull;
    if (level == null || !level.isReady) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const KTopBar(),
        body: Builder(builder: (context) => const EmptyState(icon: Icons.hourglass_empty_rounded, title: 'Imtihon hali yo\'q', message: 'Bu daraja darslari tayyorlanmoqda, shuning uchun imtihon ham hali mavjud emas.')),
      );
    }
    final questions = _questions ??= buildExam(level, _version);
    final limit = Duration(minutes: 2 * questions.length);
    final left = limit - _clock.elapsed;
    final mm = left.inMinutes.clamp(0, 999).toString().padLeft(2, '0');
    final ss = (left.inSeconds % 60).clamp(0, 59).toString().padLeft(2, '0');
    return Scaffold(
extendBodyBehindAppBar: true,
      appBar: KTopBar(
        close: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/tests'),
        title: '${level.number}-daraja imtihoni',
        actions: [
          if (_started && !_finished)
            KBadge(left.isNegative ? 'Vaqt tugadi' : '$mm:$ss', icon: Icons.timer_outlined, color: left.inMinutes < 2 ? KColors.error : KColors.primary),
        ],
      ),
      body: Builder(builder: (context) => ListView(padding: pagePadding(context), children: [
        ContentWidth(
          maxWidth: 860,
          child: !_started
              ? KCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    KIconBox(level.icon, color: level.color, size: 56, filled: true),
                    const SizedBox(height: 14),
                    UzText(level.title, style: context.text.headlineSmall),
                    const SizedBox(height: 10),
                    RichUz(
                      '**${questions.length} ta topshiriq**: savollar banki asosidagi testlar va **kod yozish** vazifalari. '
                      'Tavsiya etilgan vaqt: **${limit.inMinutes} daqiqa**. O\'tish bali — **80%**.\n\n'
                      'Bu $_version-versiya: har bir urinishda savollar tarkibi o\'zgaradi.',
                      style: context.text.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    KButton(label: 'Imtihonni boshlash', icon: Icons.play_arrow_rounded, onPressed: _start),
                  ]),
                )
              : QuizRunner(
                  questions: questions,
                  seed: _version,
                  passScore: 80,
                  onFinished: (s) {
                    _clock.stop();
                    setState(() => _finished = true);
                    ref.read(progressProvider.notifier).submitExam(level.number, '${level.number}-daraja imtihoni', s.score, s.wrongTopics);
                  },
                  resultsActions: (context, s, retry) => FeedbackBanner(
                    kind: s.score >= 80 ? FeedbackKind.success : FeedbackKind.warning,
                    title: s.score >= 80 ? 'Imtihondan o\'tdingiz! Keyingi daraja ochildi 🎓' : 'Hali o\'tish bali to\'planmadi',
                    message: s.score >= 80
                        ? 'Vaqt: ${_clock.elapsed.inMinutes} daqiqa ${_clock.elapsed.inSeconds % 60} soniya.'
                        : 'Xato qilingan mavzularni qayta o\'qing va keyinroq yangi versiyani topshiring.',
                  ),
                ),
        ),
      ])),
    );
  }
}
