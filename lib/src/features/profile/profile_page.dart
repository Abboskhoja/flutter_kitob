import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import 'profile_widgets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final p = ref.watch(progressProvider);
    final minutes = p.counter(Counters.secondsLearned) ~/ 60;
    final name = s.userName.isEmpty ? 'O\'quvchi' : s.userName;
    return Scaffold(
      // Yuqori va pastki chet pagePadding ichida: kontent status bar va shaffof
      // navigatsiya ortidan o'tadi (edge-to-edge).
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(padding: pagePadding(context), children: [
          ContentWidth(
            maxWidth: 900,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: UzText('Profil', style: context.text.headlineMedium)),
                IconButton(tooltip: 'Sozlamalar', onPressed: () => context.go('/profile/settings'), icon: const Icon(Icons.settings_rounded)),
              ]),
              const SizedBox(height: 12),
              KCard(
                gradient: const LinearGradient(colors: [KColors.primary, KColors.cyan]),
                child: Row(children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(name.characters.first.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: KColors.primary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name.uz, style: context.text.headlineSmall!.copyWith(color: Colors.white)),
                      Text('Lv ${p.userLevel} · ${p.xp} XP · ${s.startLevel.title}'.uz, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      KProgressBar(value: p.levelProgress, color: Colors.white, height: 6),
                      const SizedBox(height: 4),
                      Text('Lv ${p.userLevel + 1} gacha ${p.xpToNext} XP'.uz, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth > 600 ? 3 : 2;
                final w = (c.maxWidth - (cols - 1) * 10) / cols;
                final stats = [
                  (Icons.menu_book_rounded, '${p.completedCount}/${allLessons.length}', 'Tugallangan dars', KColors.primary),
                  (Icons.local_fire_department_rounded, '${p.streak} / ${p.bestStreak}', 'Seriya / eng uzun', KColors.orange),
                  (Icons.play_arrow_rounded, '${p.counter(Counters.codeRuns)}', 'Kod ishga tushirildi', KColors.success),
                  (Icons.code_rounded, '${p.counter(Counters.tasksSolved)}', 'Yechilgan vazifa', KColors.violet),
                  (Icons.bug_report_rounded, '${p.counter(Counters.bugsFixed)}', 'Tuzatilgan xato', KColors.error),
                  (Icons.schedule_rounded, '$minutes daq', 'O\'qish vaqti', KColors.teal),
                ];
                return Wrap(spacing: 10, runSpacing: 10, children: [
                  for (final (i, v, l, c) in stats) SizedBox(width: w, child: StatTile(icon: i, value: v, label: l, color: c)),
                ]);
              }),
              const SizedBox(height: KSpace.lg),
              ActivityHeatmap(progress: p),
              const SizedBox(height: KSpace.xl),
              CertificatesSection(progress: p, name: name),
              const SizedBox(height: KSpace.xl),
              SectionHeader('Ko\'nikmalar', subtitle: 'Darslar bo\'yicha o\'zlashtirish', icon: Icons.insights_rounded),
              KCard(
                child: Column(children: [
                  for (final lv in curriculum.where((l) => l.isReady))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        KIconBox(lv.icon, color: lv.color, size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            UzText(lv.title, style: context.text.titleSmall, maxLines: 1),
                            const SizedBox(height: 4),
                            KProgressBar(value: _levelMastery(p, lv), color: lv.color, height: 6),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Text('${(_levelMastery(p, lv) * 100).round()}%', style: context.text.labelLarge),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: KSpace.lg),
              KCard(
                onTap: () => context.go('/profile/achievements'),
                child: Row(children: [
                  const KIconBox(Icons.emoji_events_rounded, color: KColors.warning),
                  const SizedBox(width: 12),
                  Expanded(child: UzText('Yutuqlar: ${p.achievements.where((a) => !a.startsWith('practice:') && !a.startsWith('project:')).length} / ${achievementDefs.length}', style: context.text.titleSmall)),
                  const Icon(Icons.chevron_right_rounded),
                ]),
              ),
              const SizedBox(height: KSpace.lg),
              KCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded, color: KColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichUz(
                      '**Senior darajasi haqida:** kursni tugatish avtomatik "Senior" qilmaydi. Senior — real tajriba, murakkab masalalarni hal qilish, arxitektura va jamoaviy ish. Platforma shu ko\'nikmalarni bosqichma-bosqich rivojlantiradi va baholaydi.',
                      style: context.text.bodySmall,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  double _levelMastery(ProgressState p, Level lv) {
    if (lv.lessons.isEmpty) return 0;
    var sum = 0.0;
    for (final l in lv.lessons) {
      final lp = p.of(l.id);
      if (!lp.completed) continue;
      sum += (0.7 * (lp.bestQuiz < 0 ? 0.6 : lp.bestQuiz / 100) + (lp.taskSolved ? 0.2 : 0) + (lp.bugFixed ? 0.1 : 0)).clamp(0.0, 1.0);
    }
    return sum / lv.lessons.length;
  }
}
