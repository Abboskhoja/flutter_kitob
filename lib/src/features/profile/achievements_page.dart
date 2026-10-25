import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Yutuqlar'.uz)),
      body: ListView(padding: pagePadding(context), children: [
        ContentWidth(
          maxWidth: 900,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            UzText('Yutuqlar ekranda o\'tkazilgan vaqt uchun emas — bilim va amaliy natija uchun beriladi.', style: context.text.bodyMedium),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth > 700 ? 3 : 2;
              final w = (c.maxWidth - (cols - 1) * 10) / cols;
              return Wrap(spacing: 10, runSpacing: 10, children: [
                for (final a in achievementDefs)
                  SizedBox(
                    width: w,
                    child: Builder(builder: (context) {
                      final got = p.achievements.contains(a.id);
                      return Opacity(
                        opacity: got ? 1 : 0.55,
                        child: KCard(
                          borderColor: got ? a.color.withValues(alpha: 0.5) : null,
                          child: Column(children: [
                            got
                                ? KIconBox(a.icon, color: a.color, size: 56, filled: true)
                                : KIconBox(Icons.lock_outline_rounded, color: context.k.textMuted, size: 56),
                            const SizedBox(height: 10),
                            UzText(a.title, style: context.text.titleSmall, textAlign: TextAlign.center, maxLines: 2),
                            const SizedBox(height: 4),
                            UzText(a.description, style: context.text.bodySmall, textAlign: TextAlign.center, maxLines: 3),
                            if (a.xp > 0) ...[const SizedBox(height: 8), KBadge('+${a.xp} XP', color: got ? KColors.success : KColors.warning)],
                          ]),
                        ),
                      );
                    }),
                  ),
              ]);
            }),
          ]),
        ),
      ]),
    );
  }
}
