import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';

class TestsPage extends ConsumerWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final due = p.dueReviews(DateTime.now());
    final scheduled = p.reviews.entries.where((e) => !due.contains(e.key)).toList()..sort((a, b) => a.value.due.compareTo(b.value.due));
    return Scaffold(
      // Yuqori va pastki chet pagePadding ichida: kontent status bar va shaffof
      // navigatsiya ortidan o'tadi (edge-to-edge).
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(padding: pagePadding(context), children: [
          ContentWidth(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              UzText('Test va imtihonlar', style: context.text.headlineMedium),
              const SizedBox(height: 4),
              UzText('Bilimingizni isbotlang: savollar kod bajarilishi bilan tekshiriladi, kod vazifalari yashirin testlar bilan.',
                  style: context.text.bodyMedium),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: StatTile(icon: Icons.task_alt_rounded, value: '${p.counter(Counters.quizzesPassed)}', label: 'Topshirilgan test', color: KColors.success)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(icon: Icons.workspace_premium_rounded, value: '${p.counter(Counters.examsPassed)}', label: 'Imtihon', color: KColors.warning)),
                if (!context.isCompact) ...[
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(icon: Icons.emoji_events_rounded, value: '${p.counter(Counters.perfectQuizzes)}', label: '100% natija', color: KColors.violet)),
                ],
              ]),
              const SizedBox(height: KSpace.xl),
              SectionHeader('Takrorlash', subtitle: due.isEmpty ? 'Bugun takrorlanadigan mavzu yo\'q' : '${due.length} ta mavzu takrorlashni kutmoqda', icon: Icons.psychology_rounded),
              if (due.isEmpty && scheduled.isEmpty)
                KCard(child: UzText('Darsni tugatganingizdan keyin u bu yerda paydo bo\'ladi va 1, 3, 7, 16... kundan so\'ng takrorlanadi.', style: context.text.bodyMedium)),
              for (final id in due)
                _Tile(
                  icon: Icons.replay_rounded,
                  color: KColors.violet,
                  title: lessonById[id]!.title,
                  subtitle: 'Hozir takrorlash vaqti',
                  trailing: const KBadge('Bugun', color: KColors.violet, solid: true),
                  onTap: () => context.go('/tests/review/$id'),
                ),
              for (final e in scheduled.take(4))
                if (lessonById[e.key] != null)
                  _Tile(
                    icon: Icons.event_rounded,
                    color: KColors.primary,
                    title: lessonById[e.key]!.title,
                    subtitle: 'Keyingi takrorlash: ${e.value.due} (interval: ${e.value.interval} kun)',
                    onTap: () => context.go('/tests/review/${e.key}'),
                  ),
              const SizedBox(height: KSpace.xl),
              const SectionHeader('Daraja imtihonlari', subtitle: '80% va undan yuqori — keyingi daraja ochiladi', icon: Icons.workspace_premium_rounded),
              for (final lv in curriculum.where((l) => l.isReady))
                Builder(builder: (context) {
                  final best = p.history.where((h) => h.id == 'exam:${lv.number}').fold<int>(-1, (a, h) => h.score > a ? h.score : a);
                  return _Tile(
                    icon: lv.icon,
                    color: lv.color,
                    title: '${lv.number}. ${lv.title}',
                    subtitle: best < 0 ? 'Hali topshirilmagan' : 'Eng yaxshi natija: $best%',
                    trailing: best >= 80 ? const KBadge('O\'tdi', color: KColors.success, icon: Icons.check_rounded) : null,
                    onTap: () => context.go('/tests/exam/${lv.number}'),
                  );
                }),
              const SizedBox(height: KSpace.xl),
              const SectionHeader('Natijalar tarixi', icon: Icons.history_rounded),
              if (p.history.isEmpty)
                KCard(child: UzText('Hali test topshirilmagan.', style: context.text.bodyMedium))
              else
                for (final h in p.history.take(15))
                  _Tile(
                    icon: h.score >= 60 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: h.score >= 60 ? KColors.success : KColors.error,
                    title: h.title,
                    subtitle: '${h.date}${h.wrongTopics.isEmpty ? '' : ' · Xatolar: ${h.wrongTopics.toSet().join(', ')}'}',
                    trailing: Text('${h.score}%', style: context.text.titleMedium),
                  ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.color, required this.title, required this.subtitle, this.trailing, this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: KCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        KIconBox(icon, color: color, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(title, style: context.text.titleSmall, maxLines: 1),
            UzText(subtitle, style: context.text.bodySmall, maxLines: 2),
          ]),
        ),
        ?trailing,
        if (onTap != null) const Icon(Icons.chevron_right_rounded),
      ]),
    ),
  );
}
