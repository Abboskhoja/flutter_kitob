import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/bitik.dart';
import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../core/notifications/reminders.dart';
import '../quests/weekly_quests_card.dart';
import '../reminders/reminder_prompt.dart';

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
    // Yangi o'quvchi: hali birorta dars tugatilmagan — avval "qanday o'rganamiz" tushuntiriladi,
    // bo'sh statistikalar (0%, 0%, 0%) esa ko'rsatilmaydi.
    final isNew = progress.completedCount == 0;
    // Eslatma taklifi birinchi muvaffaqiyatdan keyin — qachon foydali ekani ayon bo'lganda.
    final askReminders =
        ReminderService.supported &&
        !settings.reminderAsked &&
        !settings.remindersOn &&
        (progress.completedCount > 0 || settings.launchCount >= 2);

    const gap = SizedBox(height: KSpace.lg);
    final hero = _ContinueCard(lesson: next, progress: progress);
    final goal = _DailyGoalCard(
      progress: progress,
      goal: settings.dailyGoalXp,
      timeGoal: settings.dailyStudyMinutes,
    );
    final path = next == null
        ? null
        : _PathPreview(current: next, statusOf: notifier.statusOf);
    final learning = <Widget>[
      if (path != null) ...[path, gap],
      if (askReminders) ...[const ReminderPromptCard(), gap],
      if (isNew) ...[const _HowItWorks(), gap],
      if (due.isNotEmpty) ...[
        SectionHeader(
          'Takrorlash vaqti keldi',
          subtitle: 'Eslab qolish uchun 2 daqiqalik qisqa test',
          icon: Icons.psychology_alt_rounded,
        ),
        for (final id in due.take(3)) _ReviewTile(lesson: lessonById[id]!),
        gap,
      ],
      SectionHeader(
        'Mashq qilish',
        subtitle: 'Darsdan tashqari o\'zingiz sinab ko\'ring',
        icon: Icons.sports_esports_rounded,
      ),
      _TodayRow(next: next),
    ];
    final stats = <Widget>[
      const WeeklyQuestsCard(),
      gap,
      _WeekCard(progress: progress),
      gap,
      _AchievementsPreview(progress: progress),
      if (!isNew) ...[gap, _SkillsCard(progress: progress)],
      if (progress.weakTopics.isNotEmpty) ...[
        gap,
        _WeakTopicsCard(progress: progress),
      ],
    ];

    return Scaffold(
      // Yuqori va pastki chet pagePadding ichida: kontent status bar va shaffof
      // navigatsiya ortidan o'tadi (edge-to-edge).
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: pagePadding(context).copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: ContentWidth(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${_greeting().uz}${settings.userName.isEmpty ? '' : ', ${settings.userName}'}',
                                    style: context.text.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const _WavingHand(),
                              ],
                            ),
                            Text(
                              (isNew
                                      ? 'Keling, boshlaymiz!'
                                      : 'Bugun nimani o\'rganamiz?')
                                  .uz,
                              style: context.text.titleLarge!.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StreakChip(
                        streak: progress.streak,
                        atRisk:
                            progress.streak > 0 &&
                            progress.xpOn(DateTime.now()) == 0,
                      ),
                      const SizedBox(width: 6),
                      _LvChip(progress: progress),
                      IconButton(
                        tooltip: 'Qidirish',
                        onPressed: () => context.go('/home/search'),
                        icon: const Icon(Icons.search_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: pagePadding(context).copyWith(top: KSpace.lg),
              sliver: SliverToBoxAdapter(
                child: ContentWidth(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _staggered([hero, gap, ...learning]),
                              ),
                            ),
                            const SizedBox(width: KSpace.xl),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _staggered([
                                  goal,
                                  gap,
                                  ...stats,
                                ], from: 1),
                              ),
                            ),
                          ],
                        )
                      // Telefonda: bugungi dars → kunlik maqsad → haftalik vazifalar → yo'l → mashqlar → statistika.
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _staggered([
                            hero,
                            gap,
                            goal,
                            gap,
                            ...stats.take(2),
                            ...learning,
                            gap,
                            ...stats.skip(2),
                          ]),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bo'limlarni ketma-ket (stagger) paydo qiladi. Bo'sh joy vidjetlari o'ralmaydi.
List<Widget> _staggered(List<Widget> items, {int from = 0}) {
  var i = from;
  return [
    for (final w in items) w is SizedBox ? w : Reveal(index: i++, child: w),
  ];
}

class _WavingHand extends StatelessWidget {
  const _WavingHand();

  @override
  Widget build(BuildContext context) => Ambient(
    period: const Duration(milliseconds: 2400),
    child: const Text('👋', style: TextStyle(fontSize: 15)),
    builder: (context, t, child) {
      // Davrning boshida ikki marta silkitadi, keyin dam oladi.
      final p = (t / 0.35).clamp(0.0, 1.0);
      final angle = p >= 1 ? 0.0 : math.sin(p * math.pi * 4) * 0.45 * (1 - p);
      return Transform.rotate(
        angle: angle,
        alignment: const Alignment(0.3, 0.8),
        child: child,
      );
    },
  );
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak, required this.atRisk});
  final int streak;

  /// Seriya bor, lekin bugun hali XP yo'q — uzilish xavfi.
  final bool atRisk;

  @override
  Widget build(BuildContext context) {
    final on = streak > 0;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: on && !atRisk
            ? LinearGradient(
                colors: [
                  KColors.orange.withValues(alpha: 0.22),
                  KColors.warning.withValues(alpha: 0.14),
                ],
              )
            : null,
        color: atRisk
            ? KColors.orange.withValues(alpha: 0.1)
            : (on ? null : context.k.surfaceAlt),
        borderRadius: BorderRadius.circular(KRadius.pill),
        border: atRisk
            ? Border.all(color: KColors.orange.withValues(alpha: 0.6))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (on)
            Ambient(
              period: const Duration(milliseconds: 900),
              reverse: true,
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: KColors.orange,
              ),
              // Olov "lipillaydi": biroz cho'ziladi va qiyshayadi.
              builder: (context, t, child) => Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(
                  1 - 0.06 * t,
                  1 + 0.14 * t,
                  1,
                )..rotateZ((t - 0.5) * 0.12),
                child: child,
              ),
            )
          else
            Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: context.k.textMuted,
            ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: numberStyle(
              TextStyle(
                fontWeight: FontWeight.w800,
                color: on ? KColors.orange : context.k.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
    return Tooltip(
      message:
          (atRisk
                  ? 'Bugun dars qilmasangiz $streak kunlik seriya uziladi!'
                  : '$streak kunlik seriya')
              .uz,
      child: PulseGlow(
        active: atRisk,
        color: KColors.orange,
        spread: 8,
        child: chip,
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson, required this.progress});
  final Lesson? lesson;
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final l = lesson;
    final level = l == null ? null : levelOfLesson[l.id];
    final started = l != null && progress.lessons.containsKey(l.id);
    final isNew = progress.completedCount == 0;
    // Progress butun kursdan (0/53) emas, joriy bosqichdan — yaqin va erishsa bo'ladigan maqsad.
    final total = level?.lessons.length ?? allLessons.length;
    final done = level == null
        ? progress.completedCount
        : level.lessons.where((x) => progress.isCompleted(x.id)).length;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B5FD6), KColors.primary, KColors.cyan],
        ),
        borderRadius: BorderRadius.circular(KRadius.xl),
        boxShadow: [
          BoxShadow(
            color: KColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Aurora(
              colors: [Color(0xFF7C5CFF), Color(0xFF22D3EE), Color(0xFF1E40FF)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KSpace.xl),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KBadge(
                        l == null
                            ? 'Barcha darslar tugadi'
                            : (started
                                  ? 'Davom ettirish'
                                  : (isNew ? 'Birinchi dars' : 'Bugungi dars')),
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (l?.title ?? 'Ajoyib natija!').uz,
                        style: context.text.headlineSmall!.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (l != null)
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            _HeroMeta(
                              Icons.schedule_rounded,
                              '${l.minutes} daqiqa',
                            ),
                            _HeroMeta(Icons.bolt_rounded, '+${l.xp} XP'),
                            _HeroMeta(
                              Icons.layers_rounded,
                              '${level!.number}-daraja',
                            ),
                          ],
                        )
                      else
                        Text(
                          'Imtihonlar va loyihalar bilan bilimingizni mustahkamlang.'
                              .uz,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13.5,
                          ),
                        ),
                      if (isNew && l != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Hech narsa bilish shart emas — noldan boshlaymiz.'
                              .uz,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Sheen(
                        child: KButton(
                          label: l == null
                              ? 'Testlarga o\'tish'
                              : (started ? 'Davom ettirish' : 'Boshlash'),
                          icon: Icons.play_arrow_rounded,
                          variant: KButtonVariant.dark,
                          compact: true,
                          onPressed: () => context.go(
                            l == null ? '/tests' : '/learn/lesson/${l.id}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  label:
                      '${level == null ? 'Kurs' : '${level.number}-daraja'}: $done / $total dars',
                  child: KProgressRing(
                    value: total == 0 ? 0 : done / total,
                    size: 84,
                    stroke: 8,
                    color: Colors.white,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountUp(
                          done,
                          suffix: '/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'dars',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.85)),
      const SizedBox(width: 4),
      Text(
        text.uz,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.next});
  final Lesson? next;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.terminal_rounded,
        'Kod maydoni',
        'Erkin kod yozing',
        KColors.success,
        '/practice/playground',
      ),
      (
        Icons.slow_motion_video_rounded,
        'Vizualizator',
        'Kod qanday ishlaydi?',
        KColors.violet,
        '/practice/visualizer',
      ),
      (
        Icons.keyboard_command_key_rounded,
        'Terminal',
        'Buyruqlarni sinang',
        KColors.navy,
        '/practice/terminal',
      ),
      (
        Icons.widgets_rounded,
        'Widget lab',
        'Flutter jonli',
        KColors.cyan,
        '/practice/widgets',
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 560 ? 4 : 2;
        final w = (c.maxWidth - (cols - 1) * 10) / cols;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (icon, title, sub, color, path) in items)
              SizedBox(
                width: w,
                child: Spotlight(
                  color: color == KColors.navy ? KColors.primary : color,
                  child: KCard(
                    onTap: () => context.go(path),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KIconBox(
                          icon,
                          color: color == KColors.navy && context.isDark
                              ? Colors.white
                              : color,
                          size: 38,
                        ),
                        const SizedBox(height: 10),
                        UzText(
                          title,
                          style: context.text.titleSmall,
                          maxLines: 1,
                        ),
                        UzText(sub, style: context.text.bodySmall, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
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
      child: Row(
        children: [
          KIconBox(lesson.icon, color: KColors.violet, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UzText(
                  lesson.title,
                  style: context.text.titleSmall,
                  maxLines: 1,
                ),
                UzText(
                  'Qisqa takrorlash testi · 2 daqiqa',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.progress,
    required this.goal,
    required this.timeGoal,
  });
  final ProgressState progress;
  final int goal;
  final int timeGoal;

  @override
  Widget build(BuildContext context) {
    final today = progress.xpOn(DateTime.now());
    final ratio = goal == 0 ? 0.0 : today / goal;
    final todaySeconds = progress.secondsOn(DateTime.now());
    final timeRatio = timeGoal == 0
        ? 0.0
        : (todaySeconds / (timeGoal * 60)).clamp(0.0, 1.0).toDouble();
    final left = goal - today;
    // Eng muhim bitta maslahat: seriya xavfi → qolgan XP → bajarildi.
    final (String hint, Color? hintColor) = switch (ratio) {
      >= 1 => (
        'Bugungi maqsad bajarildi — barakalla! 🎉',
        context.k.successText,
      ),
      _ when progress.streak > 0 && today == 0 => (
        '🔥 ${progress.streak} kunlik seriyani saqlash uchun bugun bitta dars qiling',
        KColors.orange,
      ),
      _ when today > 0 => (
        'Maqsadgacha $left XP qoldi — ${left <= 30 ? 'bitta mini test kifoya' : 'bitta dars yetarli'}',
        null,
      ),
      _ => ('Dars, test yoki mashq bajarib XP to\'plang', null),
    };
    return KCard(
      child: Row(
        children: [
          PulseGlow(
            active: ratio >= 1,
            color: KColors.success,
            spread: 6,
            child: KProgressRing(
              value: ratio,
              size: 70,
              color: ratio >= 1 ? KColors.success : KColors.warning,
              center: ratio >= 1
                  ? const Icon(Icons.check_rounded, color: KColors.success)
                  : const Floaty(
                      amplitude: 2.5,
                      child: Icon(Icons.bolt_rounded, color: KColors.warning),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UzText('Kunlik maqsad', style: context.text.titleMedium),
                const SizedBox(height: 2),
                CountUp(
                  today,
                  suffix: ' / $goal XP',
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: 2),
                UzText(
                  hint,
                  style: context.text.bodySmall!.copyWith(
                    color: hintColor,
                    fontWeight: hintColor == null ? null : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: context.k.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${todaySeconds ~/ 60} / $timeGoal ${'daqiqa'.uz}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                KProgressBar(
                  value: timeRatio,
                  color: timeRatio >= 1 ? KColors.success : KColors.cyan,
                ),
              ],
            ),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UzText('Bilim darajasi', style: context.text.titleMedium),
          const SizedBox(height: 4),
          UzText(
            'Tugatilgan darslar, test natijalari va amaliyotdan hisoblanadi',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 14),
          for (final (name, v, color) in rows) ...[
            Row(
              children: [
                Expanded(child: Text(name, style: context.text.labelLarge)),
                Text(
                  v == null ? 'Hali baholanmagan'.uz : '${(v * 100).round()}%',
                  style: context.text.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            KProgressBar(value: v ?? 0, color: color),
            const SizedBox(height: 12),
          ],
        ],
      ),
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
    final days = [
      for (var i = 6; i >= 0; i--)
        DateTime(now.year, now.month, now.day).subtract(Duration(days: i)),
    ];
    final values = [for (final d in days) progress.xpOn(d)];
    final maxV = values.fold<int>(1, (a, b) => b > a ? b : a);
    final total = values.fold<int>(0, (a, b) => a + b);
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: UzText(
                  'Haftalik faollik',
                  style: context.text.titleMedium,
                ),
              ),
              Text(
                '$total XP',
                style: context.text.labelLarge!.copyWith(
                  color: KColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Semantics(
                      label: '${_days[days[i].weekday - 1]}: ${values[i]} XP',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (values[i] > 0)
                            Text(
                              '${values[i]}',
                              style: context.text.labelSmall,
                            ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: values[i] / maxV),
                            // Ustunlar chapdan o'ngga navbat bilan o'sadi.
                            duration:
                                KDurations.lazy +
                                Duration(milliseconds: 90 * i),
                            curve: Interval(
                              i / 14,
                              1,
                              curve: Curves.easeOutCubic,
                            ),
                            builder: (c, v, _) => Container(
                              height: 4 + 62 * v,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                gradient: values[i] > 0
                                    ? const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [KColors.primary, KColors.cyan],
                                      )
                                    : null,
                                color: values[i] > 0
                                    ? null
                                    : context.k.surfaceHigh,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  if (i == 6 && values[i] > 0)
                                    BoxShadow(
                                      color: KColors.cyan.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 12,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _days[days[i].weekday - 1],
                            style: context.text.labelSmall!.copyWith(
                              color: i == 6 ? KColors.primary : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  const _AchievementsPreview({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final got = achievementDefs
        .where((a) => progress.achievements.contains(a.id))
        .toList();
    return KCard(
      onTap: () => context.go('/profile/achievements'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: UzText('Yutuqlar', style: context.text.titleMedium),
              ),
              Text(
                '${got.length}/${achievementDefs.length}',
                style: context.text.labelLarge,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 12),
          if (got.isEmpty)
            UzText(
              'Birinchi kodingizni ishga tushirib, birinchi yutuqni oling!',
              style: context.text.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, a) in got.reversed.take(6).indexed)
                  Reveal(
                    index: i,
                    delay: const Duration(milliseconds: 300),
                    offset: Offset.zero,
                    scale: 0.3,
                    child: Tooltip(
                      message: a.title.uz,
                      child: KIconBox(
                        a.icon,
                        color: a.color,
                        size: 40,
                        filled: true,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) => KCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: KColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: UzText(
                'Kuchaytirish kerak bo\'lgan mavzular',
                style: context.text.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        UzText(
          'Testlarda ko\'proq xato qilingan mavzular',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in progress.weakTopics.take(6))
              ActionChip(
                avatar: CircleAvatar(
                  backgroundColor: KColors.warning,
                  child: Text(
                    '${e.value}',
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
                label: Text(e.key.uz),
                onPressed: () => context.go(
                  '/home/search?q=${Uri.encodeQueryComponent(e.key)}',
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

/// XP darajasi ("Lv"). Kursdagi "1-daraja, 2-daraja" bosqichlari bilan
/// adashtirilmasligi uchun boshqa nom va belgi.
class _LvChip extends StatelessWidget {
  const _LvChip({required this.progress});
  final ProgressState progress;

  @override
  Widget build(BuildContext context) => Tooltip(
    message:
        'XP darajasi. Lv ${progress.userLevel + 1} gacha ${progress.xpToNext} XP'
            .uz,
    child: Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: KColors.violet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KProgressRing(
            value: progress.levelProgress,
            size: 26,
            stroke: 3.5,
            color: KColors.violet,
            center: const Icon(
              Icons.star_rounded,
              size: 14,
              color: KColors.violet,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Lv ${progress.userLevel}',
            style: numberStyle(
              const TextStyle(
                fontWeight: FontWeight.w800,
                color: KColors.violet,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Joriy bosqich darslari lentasi: ✓ tugagan, ▶ hozirgi, 🔒 yopiq.
/// O'quvchi "keyin nima qilaman?" degan savolga doim javob ko'radi.
class _PathPreview extends StatefulWidget {
  const _PathPreview({required this.current, required this.statusOf});
  final Lesson current;
  final LessonStatus Function(String id) statusOf;

  @override
  State<_PathPreview> createState() => _PathPreviewState();
}

class _PathPreviewState extends State<_PathPreview> {
  static const _w = 108.0;
  late final ScrollController _scroll;

  Level get _level => levelOfLesson[widget.current.id]!;

  @override
  void initState() {
    super.initState();
    final i = _level.lessons.indexWhere((l) => l.id == widget.current.id);
    // Hozirgi dars ekranda ko'rinsin: undan oldingi bitta dars chapda qoladi.
    _scroll = ScrollController(initialScrollOffset: math.max(0, (i - 1) * _w));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;
    final lessons = level.lessons;
    final done = lessons
        .where((l) => widget.statusOf(l.id) == LessonStatus.completed)
        .length;
    return KCard(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                KIconBox(level.icon, color: level.color, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UzText(
                        'Yo\'lingiz · ${level.number}-daraja',
                        style: context.text.titleSmall,
                      ),
                      UzText(
                        '${level.title} · $done/${lessons.length} dars',
                        style: context.text.bodySmall,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/learn/level/${level.number}'),
                  child: Text('Barchasi'.uz),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 112,
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: lessons.length,
              itemExtent: _w,
              itemBuilder: (context, i) => _PathNode(
                lesson: lessons[i],
                status: widget.statusOf(lessons[i].id),
                current: lessons[i].id == widget.current.id,
                color: level.color,
                first: i == 0,
                last: i == lessons.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.lesson,
    required this.status,
    required this.current,
    required this.color,
    required this.first,
    required this.last,
  });
  final Lesson lesson;
  final LessonStatus status;
  final bool current;
  final Color color;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final locked = status == LessonStatus.locked;
    final done = status == LessonStatus.completed;
    final bg = done ? KColors.success : (locked ? k.surfaceHigh : color);
    final icon = done
        ? Icons.check_rounded
        : (locked
              ? Icons.lock_rounded
              : (current ? Icons.play_arrow_rounded : lesson.icon));
    final size = current ? 52.0 : 44.0;
    return Semantics(
      button: true,
      label:
          '${lesson.title}${done ? ', tugallangan' : (locked ? ', yopiq' : '')}'
              .uz,
      child: InkWell(
        borderRadius: BorderRadius.circular(KRadius.md),
        onTap: () => locked
            ? showToast(
                context,
                'Avval oldingi darsni tugating — bilimlar ketma-ket quriladi',
                icon: Icons.lock_rounded,
              )
            : context.go('/learn/lesson/${lesson.id}'),
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Darslarni bog'lovchi chiziq.
                  Row(
                    children: [
                      Expanded(
                        child: first
                            ? const SizedBox()
                            : Container(
                                height: 3,
                                color: done || current
                                    ? color.withValues(alpha: 0.5)
                                    : k.border,
                              ),
                      ),
                      SizedBox(width: size),
                      Expanded(
                        child: last
                            ? const SizedBox()
                            : Container(
                                height: 3,
                                color: done
                                    ? color.withValues(alpha: 0.5)
                                    : k.border,
                              ),
                      ),
                    ],
                  ),
                  PulseGlow(
                    active: current,
                    color: color,
                    spread: 10,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bg,
                        border: current
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: locked ? k.textMuted : Colors.white,
                        size: current ? 28 : 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: UzText(
                lesson.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: context.text.labelMedium!.copyWith(
                  color: locked ? k.textMuted : k.text,
                  fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Birinchi darsgacha: o'qish qanday kechishini uch qadamda ko'rsatadi
/// va xatodan qo'rqmaslikka undaydi.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        Icons.menu_book_rounded,
        KColors.primary,
        'O\'qing',
        'Qisqa, sodda tushuntirish va hayotiy misol',
      ),
      (
        Icons.play_circle_rounded,
        KColors.success,
        'Sinab ko\'ring',
        'Kodni o\'zingiz ishga tushirib, o\'zgartiring',
      ),
      (
        Icons.emoji_events_rounded,
        KColors.warning,
        'Tekshiring',
        'Mini test — XP, seriya va yutuqlar',
      ),
    ];
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BitikSays(
            mood: BitikMood.happy,
            color: context.k.primarySoft,
            text: 'Salom! Men **Bitik** — sizning Flutter kitobingiz. Har bir darsda yoningizdaman.',
          ),
          const SizedBox(height: 14),
          UzText('Qanday o\'rganamiz?', style: context.text.titleMedium),
          const SizedBox(height: 12),
          for (final (i, (icon, color, title, sub)) in steps.indexed) ...[
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    KIconBox(icon, color: color, size: 42),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: color,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UzText(title, style: context.text.titleSmall),
                      UzText(sub, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.k.successSoft,
              borderRadius: BorderRadius.circular(KRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: context.k.successText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UzText(
                    'Xato qilish — o\'rganishning bir qismi. Hech narsa buzilmaydi, istagancha qayta urinish mumkin.',
                    style: context.text.bodySmall!.copyWith(
                      color: context.k.successText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
