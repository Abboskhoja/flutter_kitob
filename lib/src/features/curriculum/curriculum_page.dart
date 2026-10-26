import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import 'learning_map.dart';

class CurriculumPage extends ConsumerStatefulWidget {
  const CurriculumPage({super.key, this.track});
  final String? track;

  @override
  ConsumerState<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends ConsumerState<CurriculumPage> {
  final _currentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Xarita ochilganda hozirgi dars ko'rinadigan joyga suriladi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentKey.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(ctx, alignment: 0.45, duration: KMotion.off(context) ? Duration.zero : KDurations.slow, curve: KMotion.emphasized);
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final t = Track.values.where((x) => x.name == track).firstOrNull;
    final levels = t == null ? curriculum : curriculum.where((l) => l.track == t).toList();
    final progress = ref.watch(progressProvider);
    final totalTopics = curriculum.fold<int>(0, (a, l) => a + l.topics.length);
    // "Siz shu yerdasiz": birinchi tayyor, lekin tugallanmagan daraja.
    final current = levels.where((l) => l.isReady && l.lessons.any((x) => !progress.isCompleted(x.id))).firstOrNull;
    return Scaffold(
      // Yuqori va pastki chet pagePadding ichida: kontent status bar va shaffof
      // navigatsiya ortidan o'tadi (edge-to-edge).
      body: SafeArea(
        top: false,
        bottom: false,
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
                  // O'quv xaritasi: har bir daraja banneri ostida darslar ilon izi.
                  for (var i = 0; i < levels.length; i++) ...[
                    Reveal(
                      key: ValueKey('lv-${t?.name}-${levels[i].number}'),
                      index: i,
                      child: LevelBanner(level: levels[i], progress: progress),
                    ),
                    if (levels[i].isReady) ...[
                      const SizedBox(height: 20),
                      LessonTrail(level: levels[i], currentKey: levels[i] == current ? _currentKey : null),
                    ],
                    const SizedBox(height: 22),
                  ],
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
