import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/interview.dart';
import '../../content/model.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../lessons/runnable_code.dart';

class PracticePage extends ConsumerWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final tools = [
      (Icons.terminal_rounded, 'Code Playground', 'Haqiqiy Dart kodini yozing va ishga tushiring. Bir nechta fayl, avtosaqlash, analyzer.', KColors.success, '/practice/playground'),
      (Icons.slow_motion_video_rounded, 'Kod vizualizatori', 'Kod qanday bajarilishini qadam-baqadam ko\'ring: o\'zgaruvchilar, sikllar, funksiyalar.', KColors.violet, '/practice/visualizer'),
      (Icons.widgets_rounded, 'Widget laboratoriyasi', 'Flutter widgetlarini jonli o\'zgartiring va mos kodni ko\'ring.', KColors.cyan, '/practice/widgets'),
      (Icons.keyboard_command_key_rounded, 'Terminal laboratoriyasi', 'Xavfsiz virtual terminalda pwd, ls, cd, mkdir, dart run buyruqlari.', KColors.navy, '/practice/terminal'),
      (Icons.rocket_launch_rounded, 'Amaliy loyihalar', 'Kalkulyator, To-Do, Quiz kabi real dasturlarni bosqichma-bosqich yarating.', KColors.orange, '/practice/projects'),
      (Icons.work_outline_rounded, 'Intervyuga tayyorgarlik', '${interviewQuestions.length} ta eng ko\'p so\'raladigan Dart va Flutter savoli — namunaviy javob va kod bilan.', KColors.pink, '/practice/interview'),
    ];
    final tasks = [
      for (final l in allLessons)
        if (l.task != null && notifier.statusOf(l.id) != LessonStatus.locked) l,
    ];
    return Scaffold(
      // Yuqori va pastki chet pagePadding ichida: kontent status bar va shaffof
      // navigatsiya ortidan o'tadi (edge-to-edge).
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: pagePadding(context),
          children: [
            ContentWidth(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                UzText('Amaliyot', style: context.text.headlineMedium),
                const SizedBox(height: 4),
                UzText('O\'qish — bilim, amaliyot — ko\'nikma. Har kuni ozgina kod yozing.', style: context.text.bodyMedium),
                const SizedBox(height: 18),
                LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
                  final w = (c.maxWidth - (cols - 1) * 12) / cols;
                  return Wrap(spacing: 12, runSpacing: 12, children: [
                    for (final (icon, title, sub, color, path) in tools)
                      SizedBox(
                        width: w,
                        child: KCard(
                          onTap: () => context.go(path),
                          child: Row(children: [
                            KIconBox(icon, color: color == KColors.navy && context.isDark ? Colors.white : color, size: 50, filled: color != KColors.navy),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                UzText(title, style: context.text.titleMedium),
                                const SizedBox(height: 2),
                                UzText(sub, style: context.text.bodySmall, maxLines: 3),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                  ]);
                }),
                const SizedBox(height: KSpace.xxl),
                SectionHeader('Kod yozish mashqlari',
                    subtitle: '${progress.counter(Counters.tasksSolved)} ta vazifa yechilgan · har biri yashirin testlar bilan tekshiriladi',
                    icon: Icons.fitness_center_rounded),
                if (tasks.isEmpty)
                  const EmptyState(icon: Icons.lock_rounded, title: 'Mashqlar hali qulflangan', message: 'Birinchi darslarni boshlang — mashqlar ochiladi.')
                else
                  for (final l in tasks) _TaskTile(lesson: l, solved: progress.of(l.id).taskSolved),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.lesson, required this.solved});
  final Lesson lesson;
  final bool solved;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: KCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: KTopBar(title: lesson.task!.title),
          body: Builder(builder: (ctx) => ListView(padding: pagePadding(ctx), children: [
            ContentWidth(maxWidth: 900, child: TaskWorkspace(task: lesson.task!, lessonId: lesson.id)),
          ])),
        ),
      )),
      child: Row(children: [
        Icon(solved ? Icons.check_circle_rounded : Icons.code_rounded, color: solved ? KColors.success : KColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(lesson.task!.title, style: context.text.titleSmall),
            UzText('${levelOfLesson[lesson.id]!.number}-daraja · ${lesson.title}', style: context.text.bodySmall, maxLines: 1),
          ]),
        ),
        if (solved) const KBadge('Yechilgan', color: KColors.success) else const KBadge('+20 XP', color: KColors.warning),
      ]),
    ),
  );
}
