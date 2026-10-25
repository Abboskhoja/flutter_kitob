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
import '../../core/state/settings.dart';
import '../../shared/logo.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Xayrli tun';
    if (h < 12) return 'Xayrli tong';
    if (h < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final next = notifier.continueLesson();
    final due = progress.dueReviews(DateTime.now());
    final wide = context.screenWidth >= 900;

    final left = <Widget>[
      _ContinueCard(lesson: next, progress: progress),
      const SizedBox(height: KSpace.lg),
      _TodayRow(next: next),
      const SizedBox(height: KSpace.xl),
      if (due.isNotEmpty) ...[
        SectionHeader('Takrorlash vaqti keldi', subtitle: 'Intervalli takrorlash bilimni uzoq muddat saqlaydi', icon: Icons.psychology_alt_rounded),
        for (final id in due.take(3)) _ReviewTile(lesson: lessonById[id]!),
        const SizedBox(height: KSpace.xl),
      ],
      SectionHeader('O\'quv yo\'lingiz', action: 'Hammasi', onAction: () => context.go('/learn')),
      for (final lv in curriculum.where((l) => l.isReady).take(wide ? 6 : 4)) _LevelProgressTile(level: lv),
    ];

    final right = <Widget>[
      _DailyGoalCard(progress: progress, goal: settings.dailyGoalXp),
      const SizedBox(height: KSpace.lg),
      _SkillsCard(progress: progress),
      const SizedBox(height: KSpace.lg),
      _WeekCard(progress: progress),
      const SizedBox(height: KSpace.lg),
      _AchievementsPreview(progress: progress),
      if (progress.weakTopics.isNotEmpty) ...[
        const SizedBox(height: KSpace.lg),
        _WeakTopicsCard(progress: progress),
      ],
    ];

    return Scaffold(
      floatingActionButton: const TutorFab(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: pagePadding(context).copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: ContentWidth(
                  child: Row(children: [
                    if (context.isCompact) ...[const KitobLogo(size: 40), const SizedBox(width: 12)],
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${_greeting()}${settings.userName.isEmpty ? '' : ', ${settings.userName}'} 👋'.uz,
                            style: context.text.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Bugun nimani o\'rganamiz?'.uz, style: context.text.headlineSmall),
                      ]),
                    ),
                    _StreakChip(streak: progress.streak),
                    IconButton(tooltip: 'Qidirish', onPressed: () => context.go('/home/search'), icon: const Icon(Icons.search_rounded)),
                  ]),
                ),
              ),
            ),
            SliverPadding(
              padding: pagePadding(context),
              sliver: SliverToBoxAdapter(
                child: ContentWidth(
                  child: wide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
                          const SizedBox(width: KSpace.xl),
                          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
                        ])
                      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          ...left.take(3),
                          _DailyGoalCard(progress: progress, goal: settings.dailyGoalXp),
                          const SizedBox(height: KSpace.xl),
                          ...left.skip(3),
                          const SizedBox(height: KSpace.lg),
                          ...right.skip(2),
                        ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$streak kunlik seriya'.uz,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: streak > 0 ? KColors.orange.withValues(alpha: 0.14) : context.k.surfaceAlt,
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_fire_department_rounded, size: 18, color: streak > 0 ? KColors.orange : context.k.textMuted),
        const SizedBox(width: 4),
        Text('$streak', style: TextStyle(fontWeight: FontWeight.w800, color: streak > 0 ? KColors.orange : context.k.textMuted)),
      ]),
    ),
  );
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson, required this.progress});
  final Lesson? lesson;
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final total = allLessons.length;
    final done = progress.completedCount;
    final l = lesson;
    final level = l == null ? null : levelOfLesson[l.id];
    final started = l != null && progress.lessons.containsKey(l.id);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0B5FD6), KColors.primary, KColors.cyan]),
        borderRadius: BorderRadius.circular(KRadius.xl),
        boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 14))],
      ),
      padding: const EdgeInsets.all(KSpace.xl),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            KBadge(l == null ? 'Barcha darslar tugadi' : (started ? 'Davom ettirish' : 'Keyingi dars'),
                color: Colors.white, solid: false),
            const SizedBox(height: 10),
            Text((l?.title ?? 'Ajoyib natija!').uz,
                style: context.text.headlineSmall!.copyWith(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              (l == null ? 'Imtihonlar va loyihalar bilan bilimingizni mustahkamlang.' : '${level!.number}-daraja · ${level.title} · ${l.minutes} daqiqa').uz,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            KButton(
              label: l == null ? 'Testlarga o\'tish' : (started ? 'Davom ettirish' : 'Boshlash'),
              icon: Icons.play_arrow_rounded,
              variant: KButtonVariant.dark,
              compact: true,
              onPressed: () => context.go(l == null ? '/tests' : '/learn/lesson/${l.id}'),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        KProgressRing(
          value: total == 0 ? 0 : done / total,
          size: 92,
          stroke: 9,
          color: Colors.white,
          center: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${total == 0 ? 0 : (done * 100 ~/ total)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
            Text('$done/$total', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
          ]),
        ),
      ]),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.next});
  final Lesson? next;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.terminal_rounded, 'Kod maydoni', 'Erkin kod yozing', KColors.success, '/practice/playground'),
      (Icons.slow_motion_video_rounded, 'Vizualizator', 'Kod qanday ishlaydi?', KColors.violet, '/practice/visualizer'),
      (Icons.keyboard_command_key_rounded, 'Terminal', 'Buyruqlarni sinang', KColors.navy, '/practice/terminal'),
      (Icons.widgets_rounded, 'Widget lab', 'Flutter jonli', KColors.cyan, '/practice/widgets'),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 560 ? 4 : 2;
      final w = (c.maxWidth - (cols - 1) * 10) / cols;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        for (final (icon, title, sub, color, path) in items)
          SizedBox(
            width: w,
            child: KCard(
              onTap: () => context.go(path),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                KIconBox(icon, color: color == KColors.navy && context.isDark ? Colors.white : color, size: 38),
                const SizedBox(height: 10),
                UzText(title, style: context.text.titleSmall, maxLines: 1),
                UzText(sub, style: context.text.bodySmall, maxLines: 1),
              ]),
            ),
          ),
      ]);
    });
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: KCard(
      onTap: () => context.go('/tests/review/${lesson.id}'),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        KIconBox(lesson.icon, color: KColors.violet, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(lesson.title, style: context.text.titleSmall, maxLines: 1),
            UzText('Qisqa takrorlash testi · 2 daqiqa', style: context.text.bodySmall),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded),
      ]),
    ),
  );
}

class _LevelProgressTile extends ConsumerWidget {
  const _LevelProgressTile({required this.level});
  final Level level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final done = level.lessons.where((l) => p.isCompleted(l.id)).length;
    final ratio = level.lessons.isEmpty ? 0.0 : done / level.lessons.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: KCard(
        onTap: () => context.go('/learn/level/${level.number}'),
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          KIconBox(level.icon, color: level.color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: UzText('${level.number}. ${level.title}', style: context.text.titleSmall, maxLines: 1)),
                Text('$done/${level.lessons.length}', style: context.text.labelMedium),
              ]),
              const SizedBox(height: 8),
              KProgressBar(value: ratio, color: level.color, height: 6),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.progress, required this.goal});
  final ProgressState progress;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final today = progress.xpOn(DateTime.now());
    final ratio = goal == 0 ? 0.0 : today / goal;
    return KCard(
      child: Row(children: [
        KProgressRing(
          value: ratio,
          size: 70,
          color: ratio >= 1 ? KColors.success : KColors.warning,
          center: Icon(ratio >= 1 ? Icons.check_rounded : Icons.bolt_rounded, color: ratio >= 1 ? KColors.success : KColors.warning),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText('Kunlik maqsad', style: context.text.titleMedium),
            const SizedBox(height: 2),
            Text('$today / $goal XP', style: context.text.headlineSmall),
            UzText(ratio >= 1 ? 'Bugungi maqsad bajarildi — barakalla!' : 'Dars yoki mashq bajarib XP to\'plang',
                style: context.text.bodySmall),
          ]),
        ),
        Column(children: [
          Text('${progress.userLevel}', style: context.text.headlineSmall!.copyWith(color: KColors.primary)),
          Text('daraja', style: context.text.labelSmall),
        ]),
      ]),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Asoslar', progress.trackMastery(Track.foundations), KColors.teal),
      ('Dart', progress.trackMastery(Track.dart), KColors.primary),
      ('Flutter', progress.trackMastery(Track.flutter), KColors.cyan),
    ];
    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        UzText('Bilim darajasi', style: context.text.titleMedium),
        const SizedBox(height: 4),
        UzText('Tugatilgan darslar, test natijalari va amaliyotdan hisoblanadi', style: context.text.bodySmall),
        const SizedBox(height: 14),
        for (final (name, v, color) in rows) ...[
          Row(children: [
            Expanded(child: Text(name, style: context.text.labelLarge)),
            Text('${(v * 100).round()}%', style: context.text.labelMedium),
          ]),
          const SizedBox(height: 6),
          KProgressBar(value: v, color: color),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.progress});
  final ProgressState progress;

  static const _days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = [for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day).subtract(Duration(days: i))];
    final values = [for (final d in days) progress.xpOn(d)];
    final maxV = values.fold<int>(1, (a, b) => b > a ? b : a);
    final total = values.fold<int>(0, (a, b) => a + b);
    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: UzText('Haftalik faollik', style: context.text.titleMedium)),
          Text('$total XP', style: context.text.labelLarge!.copyWith(color: KColors.primary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Semantics(
                  label: '${_days[days[i].weekday - 1]}: ${values[i]} XP',
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    if (values[i] > 0) Text('${values[i]}', style: context.text.labelSmall),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: values[i] / maxV),
                      duration: KDurations.lazy,
                      curve: Curves.easeOutCubic,
                      builder: (c, v, _) => Container(
                        height: 4 + 70 * v,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: values[i] > 0
                              ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [KColors.primary, KColors.cyan])
                              : null,
                          color: values[i] > 0 ? null : context.k.surfaceHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_days[days[i].weekday - 1],
                        style: context.text.labelSmall!.copyWith(color: i == 6 ? KColors.primary : null)),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  const _AchievementsPreview({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final got = achievementDefs.where((a) => progress.achievements.contains(a.id)).toList();
    return KCard(
      onTap: () => context.go('/profile/achievements'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: UzText('Yutuqlar', style: context.text.titleMedium)),
          Text('${got.length}/${achievementDefs.length}', style: context.text.labelLarge),
          const Icon(Icons.chevron_right_rounded),
        ]),
        const SizedBox(height: 12),
        if (got.isEmpty)
          UzText('Birinchi kodingizni ishga tushirib, birinchi yutuqni oling!', style: context.text.bodySmall)
        else
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in got.reversed.take(6)) Tooltip(message: a.title.uz, child: KIconBox(a.icon, color: a.color, size: 40, filled: true)),
          ]),
      ]),
    );
  }
}

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) => KCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.trending_up_rounded, color: KColors.warning),
        const SizedBox(width: 8),
        Expanded(child: UzText('Kuchaytirish kerak bo\'lgan mavzular', style: context.text.titleMedium)),
      ]),
      const SizedBox(height: 4),
      UzText('Testlarda ko\'proq xato qilingan mavzular', style: context.text.bodySmall),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final e in progress.weakTopics.take(6))
          ActionChip(
            avatar: CircleAvatar(backgroundColor: KColors.warning, child: Text('${e.value}', style: const TextStyle(fontSize: 11, color: Colors.white))),
            label: Text(e.key.uz),
            onPressed: () => context.go('/home/search?q=${Uri.encodeQueryComponent(e.key)}'),
          ),
      ]),
    ]),
  );
}
