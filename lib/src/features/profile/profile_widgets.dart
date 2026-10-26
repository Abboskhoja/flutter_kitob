import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../shared/bitik.dart';

/// Oxirgi haftalardagi faollik: har bir katak — bir kun, rangi o'sha kungi XP.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({super.key, required this.progress, this.weeks = 15});
  final ProgressState progress;
  final int weeks;

  static const _days = ['Du', '', 'Ch', '', 'Ju', '', 'Ya'];

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1 + (weeks - 1) * 7));
    final values = [for (var i = 0; i < weeks * 7; i++) progress.xpOn(start.add(Duration(days: i)))];
    final active = values.where((v) => v > 0).length;
    final maxV = values.fold<int>(1, (a, b) => b > a ? b : a);
    Color cell(int v, bool future) {
      if (future) return Colors.transparent;
      if (v == 0) return k.surfaceHigh;
      final t = 0.3 + 0.7 * (v / maxV);
      return Color.lerp(KColors.success.withValues(alpha: 0.25), KColors.success, t)!;
    }

    return KCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: UzText('Faollik', style: context.text.titleMedium)),
          Text('$active kun · eng uzun seriya ${progress.bestStreak}'.uz, style: context.text.labelMedium),
        ]),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, c) {
          final size = ((c.maxWidth - 24) / weeks - 4).clamp(8.0, 18.0);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              for (final d in _days)
                SizedBox(height: size + 4, width: 22, child: Text(d, style: context.text.labelSmall!.copyWith(fontSize: 9.5))),
            ]),
            // Animatsiya har hafta ustuniga (15 ta), har katakka emas (105 ta).
            for (var w = 0; w < weeks; w++)
              Reveal(
                index: w,
                step: const Duration(milliseconds: 30),
                offset: const Offset(0, 8),
                scale: 0.6,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(children: [
                    for (var d = 0; d < 7; d++)
                      Builder(builder: (context) {
                        final i = w * 7 + d;
                        final day = start.add(Duration(days: i));
                        final future = day.isAfter(today);
                        return Tooltip(
                          message: future ? '' : '${dayKey(day)}: ${values[i]} XP',
                          child: Container(
                            width: size,
                            height: size,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: cell(values[i], future),
                              borderRadius: BorderRadius.circular(3),
                              border: day == today ? Border.all(color: KColors.primary, width: 1.5) : null,
                            ),
                          ),
                        );
                      }),
                  ]),
                ),
              ),
          ]);
        }),
      ]),
    );
  }
}

/// Darajani to'liq tugatganlik sertifikatlari (ichki, FLUTTER_KITOB tomonidan).
class CertificatesSection extends StatelessWidget {
  const CertificatesSection({super.key, required this.progress, required this.name});
  final ProgressState progress;
  final String name;

  @override
  Widget build(BuildContext context) {
    final earned = [
      for (final lv in curriculum)
        if (lv.isReady && lv.lessons.every((l) => progress.isCompleted(l.id))) lv,
    ];
    final next = curriculum.where((lv) => lv.isReady && !earned.contains(lv)).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader('Sertifikatlar', subtitle: 'Darajadagi barcha darslar tugaganda beriladi', icon: Icons.workspace_premium_rounded),
      if (earned.isEmpty)
        KCard(
          child: BitikSays(
            mood: BitikMood.think,
            text: next == null
                ? 'Sertifikatlar darslar tayyor bo\'lgach ochiladi.'
                : 'Birinchi sertifikat: **${next.number}-daraja · ${next.title}**. ${next.lessons.where((l) => !progress.isCompleted(l.id)).length} ta dars qoldi!',
          ),
        )
      else
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final lv in earned)
            SizedBox(
              width: 220,
              child: KCard(
                onTap: () => showCertificate(context, level: lv, progress: progress, name: name),
                gradient: LinearGradient(colors: [lv.color.withValues(alpha: 0.16), lv.color.withValues(alpha: 0.04)]),
                borderColor: lv.color.withValues(alpha: 0.4),
                child: Row(children: [
                  KIconBox(Icons.workspace_premium_rounded, color: lv.color, filled: true),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${lv.number}-daraja'.uz, style: context.text.labelSmall),
                      UzText(lv.title, style: context.text.titleSmall, maxLines: 2),
                    ]),
                  ),
                ]),
              ),
            ),
        ]),
    ]);
  }
}

/// Sertifikat oynasi. Ma'lumotlar haqiqiy: tugatilgan sana va o'rtacha test natijasi.
Future<void> showCertificate(BuildContext context, {required Level level, required ProgressState progress, required String name}) {
  final ps = [for (final l in level.lessons) progress.of(l.id)];
  final dates = ps.map((p) => p.completedAt).whereType<String>().toList()..sort();
  final date = dates.isEmpty ? dayKey(DateTime.now()) : dates.last.substring(0, 10);
  final scored = ps.where((p) => p.bestQuiz >= 0).toList();
  final avg = scored.isEmpty ? null : scored.fold<int>(0, (a, p) => a + p.bestQuiz) ~/ scored.length;
  final text = '$name — FLUTTER_KITOB: ${level.number}-daraja «${level.title}» tugatildi ($date, ${level.lessons.length} dars'
      '${avg == null ? '' : ', o\'rtacha test $avg%'}).';
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KRadius.xxl),
            gradient: LinearGradient(colors: [level.color, KColors.cyan, KColors.warning]),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            decoration: BoxDecoration(color: ctx.k.surface, borderRadius: BorderRadius.circular(KRadius.xxl - 4)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Bitik(mood: BitikMood.cheer, size: 84),
              const SizedBox(height: 6),
              Text('SERTIFIKAT', style: ctx.text.labelSmall!.copyWith(letterSpacing: 4, fontWeight: FontWeight.w900, color: level.color)),
              const SizedBox(height: 8),
              UzText(name, style: ctx.text.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              RichUz('**${level.number}-daraja · ${level.title}** bo\'yicha barcha darslarni muvaffaqiyatli tugatdi.',
                  style: ctx.text.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Fact(label: 'Sana', value: date),
                _Fact(label: 'Darslar', value: '${level.lessons.length}'),
                if (avg != null) _Fact(label: 'O\'rtacha test', value: '$avg%'),
              ]),
              const SizedBox(height: 12),
              Text('FLUTTER_KITOB ichki sertifikati — o\'quv natijangizni tasdiqlaydi.'.uz,
                  style: ctx.text.labelSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: KButton(
                    label: 'Matnni nusxalash',
                    icon: Icons.copy_rounded,
                    variant: KButtonVariant.secondary,
                    compact: true,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      showToast(ctx, 'Nusxalandi — rezyume yoki ijtimoiy tarmoqqa qo\'shishingiz mumkin', icon: Icons.check_rounded);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                KButton(label: 'Yopish', compact: true, onPressed: () => Navigator.pop(ctx)),
              ]),
            ]),
          ),
        ),
      ),
    ),
  );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(children: [
      Text(value, style: numberStyle(context.text.titleMedium!.copyWith(fontWeight: FontWeight.w800))),
      Text(label.uz, style: context.text.labelSmall),
    ]),
  );
}
