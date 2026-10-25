import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';

class CurriculumPage extends ConsumerWidget {
  const CurriculumPage({super.key, this.track});
  final String? track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Track.values.where((x) => x.name == track).firstOrNull;
    final levels = t == null ? curriculum : curriculum.where((l) => l.track == t).toList();
    final progress = ref.watch(progressProvider);
    final totalTopics = curriculum.fold<int>(0, (a, l) => a + l.topics.length);
    return Scaffold(
      floatingActionButton: const TutorFab(),
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: pagePadding(context),
            sliver: SliverToBoxAdapter(
              child: ContentWidth(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        UzText(t?.title ?? 'Mening ta\'lim yo\'lim', style: context.text.headlineMedium),
                        const SizedBox(height: 4),
                        UzText('${curriculum.length} daraja · $totalTopics mavzu · ${allLessons.length} ta tayyor interaktiv dars',
                            style: context.text.bodyMedium),
                        const SizedBox(height: 2),
                        UzText('Noldan → Dart → Flutter → Junior → Senior → Staff → Principal → Internals → Research',
                            style: context.text.labelSmall),
                      ]),
                    ),
                    IconButton(tooltip: 'Atamalar lug\'ati'.uz, onPressed: () => context.go('/learn/glossary'), icon: const Icon(Icons.translate_rounded)),
                  ]),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _TrackChip(label: 'Hammasi', selected: t == null, onTap: () => context.go('/learn')),
                      for (final tr in Track.values)
                        _TrackChip(label: tr.title, icon: tr.icon, selected: t == tr, onTap: () => context.go('/learn?track=${tr.name}')),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < levels.length; i++)
                    _LevelNode(level: levels[i], progress: progress, isLast: i == levels.length - 1),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      avatar: icon == null ? null : Icon(icon, size: 16),
      label: Text(label.uz),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({required this.level, required this.progress, required this.isLast});
  final Level level;
  final ProgressState progress;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = level.lessons.where((l) => progress.isCompleted(l.id)).length;
    final ratio = level.lessons.isEmpty ? 0.0 : done / level.lessons.length;
    final complete = level.isReady && done == level.lessons.length;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 44,
          child: Column(children: [
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: complete ? KColors.success : (level.isReady ? level.color : context.k.surfaceHigh),
                boxShadow: [if (level.isReady) BoxShadow(color: level.color.withValues(alpha: 0.35), blurRadius: 12)],
              ),
              alignment: Alignment.center,
              child: complete
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                  : Text('${level.number}',
                      style: TextStyle(fontWeight: FontWeight.w800, color: level.isReady ? Colors.white : context.k.textMuted)),
            ),
            if (!isLast)
              Expanded(
                child: Container(width: 3, margin: const EdgeInsets.symmetric(vertical: 4), color: complete ? KColors.success : context.k.border),
              ),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KCard(
              onTap: () => context.go('/learn/level/${level.number}'),
              semanticLabel: '${level.number}-daraja: ${level.title}',
              child: Row(children: [
                KIconBox(level.icon, color: level.color, size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: UzText(level.title, style: context.text.titleMedium, maxLines: 2)),
                      if (!level.isReady) const KBadge('Tayyorlanmoqda', color: KColors.warning),
                    ]),
                    if (level.rank != null) ...[
                      const SizedBox(height: 2),
                      Text(level.rank!, style: context.text.labelSmall?.copyWith(color: level.color, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
                    ],
                    const SizedBox(height: 2),
                    UzText(level.subtitle, style: context.text.bodySmall, maxLines: 2),
                    const SizedBox(height: 10),
                    if (level.isReady) ...[
                      KProgressBar(value: ratio, color: level.color, height: 6),
                      const SizedBox(height: 6),
                      Text('$done / ${level.lessons.length} dars · ${level.modules.length} modul · ${level.topics.length} mavzu'.uz,
                          style: context.text.labelSmall),
                    ] else
                      Text('${level.modules.length} modul · ${level.topics.length} mavzu rejalashtirilgan'.uz, style: context.text.labelSmall),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
