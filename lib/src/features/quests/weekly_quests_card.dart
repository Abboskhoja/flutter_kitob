import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/state/quests.dart';

/// Haftalik vazifalar: haqiqiy harakatlardan hisoblanadi, har dushanba yangilanadi.
class WeeklyQuestsCard extends ConsumerWidget {
  const WeeklyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    ref.watch(questsProvider);
    final quests = ref.read(questsProvider.notifier).current(p);
    final daysLeft = 8 - DateTime.now().weekday;
    final done = quests.where((q) => q.claimed).length;
    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const KIconBox(Icons.flag_circle_rounded, color: KColors.orange, size: 40, filled: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UzText('Haftalik vazifalar', style: context.text.titleMedium),
              Text((daysLeft <= 1 ? 'Bugun oxirgi kun!' : 'Yangilanishgacha $daysLeft kun').uz,
                  style: context.text.bodySmall!.copyWith(color: daysLeft <= 1 ? KColors.orange : null, fontWeight: daysLeft <= 1 ? FontWeight.w700 : null)),
            ]),
          ),
          Text('$done/${quests.length}', style: numberStyle(context.text.titleMedium!.copyWith(color: KColors.orange))),
        ]),
        const SizedBox(height: 14),
        for (final q in quests) _QuestRow(q: q, onClaim: () => ref.read(questsProvider.notifier).claim(q.def.id)),
      ]),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.q, required this.onClaim});
  final QuestProgress q;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final d = q.def;
    final ready = q.done && !q.claimed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        KIconBox(q.claimed ? Icons.check_rounded : d.icon, color: q.claimed ? KColors.success : d.color, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(d.title, style: context.text.titleSmall!.copyWith(
              decoration: q.claimed ? TextDecoration.lineThrough : null,
              color: q.claimed ? context.k.textMuted : null,
            )),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: KProgressBar(value: q.ratio, color: q.done ? KColors.success : d.color, height: 7)),
              const SizedBox(width: 8),
              Text('${q.value.clamp(0, d.target)}/${d.target}', style: numberStyle(context.text.labelMedium!)),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: KDurations.medium,
          transitionBuilder: (c, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: c),
          child: ready
              ? PulseGlow(
                  key: const ValueKey('ready'),
                  color: KColors.warning,
                  radius: KRadius.md,
                  spread: 6,
                  child: Sheen(
                    child: KButton(
                      label: '+${d.xp} XP',
                      icon: Icons.redeem_rounded,
                      compact: true,
                      variant: KButtonVariant.success,
                      onPressed: () {
                        kHaptic(context);
                        onClaim();
                      },
                    ),
                  ),
                )
              : q.claimed
                  ? KBadge('Olindi', key: const ValueKey('claimed'), color: KColors.success, icon: Icons.check_rounded)
                  : KBadge('+${d.xp} XP', key: const ValueKey('todo'), color: KColors.warning),
        ),
      ]),
    );
  }
}
