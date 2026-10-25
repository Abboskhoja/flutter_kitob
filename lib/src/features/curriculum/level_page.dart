import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';

class LevelPage extends ConsumerWidget {
  const LevelPage({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = curriculum.where((l) => l.number == number).firstOrNull;
    if (level == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.search_off_rounded, title: 'Daraja topilmadi', message: 'Bunday daraja o\'quv dasturida yo\'q.'),
      );
    }
    final progress = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final done = level.lessons.where((l) => progress.isCompleted(l.id)).length;
    // Tayyor darslar qamrab olmagan mavzular (rejadagi qolgan qism).
    return Scaffold(
      appBar: AppBar(title: Text('${level.number}-daraja'.uz)),
      body: ListView(
        padding: pagePadding(context),
        children: [
          ContentWidth(
            maxWidth: 860,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              KCard(
                gradient: LinearGradient(colors: [level.color.withValues(alpha: 0.16), level.color.withValues(alpha: 0.04)]),
                child: Row(children: [
                  KIconBox(level.icon, color: level.color, size: 58, filled: true),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      UzText(level.title, style: context.text.headlineSmall),
                      const SizedBox(height: 4),
                      UzText(level.subtitle, style: context.text.bodyMedium),
                      if (level.outcome.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(Icons.flag_rounded, size: 18, color: level.color),
                          const SizedBox(width: 6),
                          Expanded(child: RichUz(level.outcome, style: context.text.bodyMedium)),
                        ]),
                      ],
                    ]),
                  ),
                  if (level.isReady)
                    KProgressRing(
                      value: done / level.lessons.length,
                      color: level.color,
                      center: Text('$done/${level.lessons.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                ]),
              ),
              const SizedBox(height: KSpace.lg),
              if (level.number > 1)
                _InfoRow(
                  icon: Icons.route_rounded,
                  color: context.k.textMuted,
                  text: 'Oldindan kerak: ${level.number - 1}-daraja «${levelByNumber(level.number - 1).title}» bilimlari.',
                ),
              if (level.competencies.isNotEmpty) ...[
                const SizedBox(height: KSpace.lg),
                SectionHeader('Kompetensiyalar xaritasi', subtitle: 'Darajani tugatgan o\'quvchi quyidagilarni amalda bajara oladi'),
                KCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    for (final c in level.competencies)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18, color: level.color),
                          const SizedBox(width: 8),
                          Expanded(child: RichUz(c, style: context.text.bodyMedium)),
                        ]),
                      ),
                  ]),
                ),
              ],
              const SizedBox(height: KSpace.xl),
              for (var mi = 0; mi < level.modules.length; mi++) ...[
                _ModuleSection(
                  module: level.modules[mi],
                  index: mi + 1,
                  color: level.color,
                  firstLessonIndex: [for (final m in level.modules.take(mi)) m.lessons.length].fold(0, (a, b) => a + b),
                  progress: progress,
                  statusOf: notifier.statusOf,
                ),
                const SizedBox(height: KSpace.lg),
              ],
              if (level.isReady)
                KCard(
                  onTap: () => context.go('/tests/exam/${level.number}'),
                  child: Row(children: [
                    const KIconBox(Icons.workspace_premium_rounded, color: KColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UzText('Daraja imtihoni', style: context.text.titleSmall),
                        UzText('Tayyor darslar savollaridan · 80% va undan yuqori natija keyingi darajani ochadi', style: context.text.bodySmall),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ]),
                ),
              if (level.capstone case final cap?) ...[
                const SizedBox(height: KSpace.xl),
                SectionHeader('Yakuniy loyiha', subtitle: 'Daraja bilimlarini bitta haqiqiy ishda birlashtiring'),
                KCard(
                  gradient: LinearGradient(colors: [level.color.withValues(alpha: 0.10), Colors.transparent]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      KIconBox(Icons.rocket_launch_rounded, color: level.color),
                      const SizedBox(width: 12),
                      Expanded(child: UzText(cap.title, style: context.text.titleMedium)),
                    ]),
                    const SizedBox(height: 10),
                    RichUz(cap.description, style: context.text.bodyMedium),
                    if (cap.requirements.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      UzText('Qabul mezonlari', style: context.text.labelLarge),
                      const SizedBox(height: 4),
                      for (final r in cap.requirements)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.task_alt_rounded, size: 16, color: context.k.textMuted),
                            const SizedBox(width: 8),
                            Expanded(child: RichUz(r, style: context.text.bodySmall)),
                          ]),
                        ),
                    ],
                    const SizedBox(height: 12),
                    if (cap.projectId != null)
                      FilledButton.icon(
                        onPressed: () => context.go('/practice/projects/${cap.projectId}'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Loyihani boshlash'.uz),
                      )
                    else
                      KBadge('Avtomatik tekshiriladigan versiyasi tayyorlanmoqda', color: context.k.textMuted),
                  ]),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.index, required this.status, required this.progress});
  final Lesson lesson;
  final int index;
  final LessonStatus status;
  final LessonProgress progress;

  @override
  Widget build(BuildContext context) {
    final locked = status == LessonStatus.locked;
    final (icon, color, label) = switch (status) {
      LessonStatus.completed => (Icons.check_circle_rounded, KColors.success, 'Tugallangan'),
      LessonStatus.inProgress => (Icons.timelapse_rounded, KColors.primary, 'Jarayonda'),
      LessonStatus.available => (Icons.play_circle_fill_rounded, KColors.primary, 'Ochiq'),
      LessonStatus.locked => (Icons.lock_rounded, context.k.textMuted, 'Qulflangan'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: locked ? 0.6 : 1,
        child: KCard(
          onTap: () {
            if (locked) {
              final prev = previousLessonOf(lesson.id);
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  icon: const Icon(Icons.lock_rounded),
                  title: Text('Dars hali qulflangan'.uz),
                  content: Text('Avval "${prev?.title ?? ''}" darsini tugating. Bu mavzuni bilsangiz, daraja imtihonini topshirib darsni ochishingiz mumkin.'.uz),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Yopish'.uz)),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final lv = levelOfLesson[lesson.id]!;
                        context.go('/tests/exam/${lv.number}');
                      },
                      child: Text('Imtihon'.uz),
                    ),
                  ],
                ),
              );
              return;
            }
            context.go('/learn/lesson/${lesson.id}');
          },
          semanticLabel: '$index-dars: ${lesson.title}, $label',
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              KIconBox(lesson.icon, color: locked ? context.k.textMuted : KColors.primary, size: 46),
              Positioned(right: -4, bottom: -4, child: Icon(icon, size: 20, color: color)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                UzText('$index. ${lesson.title}', style: context.text.titleSmall, maxLines: 2),
                const SizedBox(height: 2),
                UzText(lesson.subtitle, style: context.text.bodySmall, maxLines: 2),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  KBadge('${lesson.minutes} daq', icon: Icons.schedule_rounded, color: KColors.primary),
                  KBadge('+${lesson.xp} XP', icon: Icons.bolt_rounded, color: KColors.warning),
                  if (progress.bestQuiz >= 0) KBadge('Test: ${progress.bestQuiz}%', color: progress.bestQuiz >= 60 ? KColors.success : KColors.error),
                  if (progress.taskSolved) const KBadge('Vazifa ✓', color: KColors.success),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 18, color: color),
    const SizedBox(width: 8),
    Expanded(child: RichUz(text, style: context.text.bodySmall)),
  ]);
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.module,
    required this.index,
    required this.color,
    required this.firstLessonIndex,
    required this.progress,
    required this.statusOf,
  });
  final Module module;
  final int index;
  final Color color;
  final int firstLessonIndex;
  final ProgressState progress;
  final LessonStatus Function(String id) statusOf;

  @override
  Widget build(BuildContext context) {
    final done = module.lessons.where((l) => progress.isCompleted(l.id)).length;
    // Darslar qamrab olmagan rejadagi mavzular.
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(KRadius.pill)),
          child: Text('Modul $index'.uz, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(child: UzText(module.title, style: context.text.titleMedium)),
        if (module.isReady)
          Text('$done/${module.lessons.length}', style: context.text.labelMedium)
        else
          const KBadge('Tayyorlanmoqda', color: KColors.warning),
      ]),
      if (module.summary.isNotEmpty) ...[
        const SizedBox(height: 4),
        UzText(module.summary, style: context.text.bodySmall),
      ],
      const SizedBox(height: 10),
      for (var i = 0; i < module.lessons.length; i++)
        _LessonRow(
          lesson: module.lessons[i],
          index: firstLessonIndex + i + 1,
          status: statusOf(module.lessons[i].id),
          progress: progress.of(module.lessons[i].id),
        ),
      if (module.topics.isNotEmpty)
        KCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(
              module.isReady ? 'Modulning to\'liq mavzular rejasi' : 'Bu modul darslari yozilmoqda. Tayyor bo\'lmagan dars ochilmaydi — reja shaffof ko\'rsatiladi.',
              style: context.text.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final t in module.topics) Chip(label: Text(t.uz), visualDensity: VisualDensity.compact),
            ]),
          ]),
        ),
    ]);
  }
}
