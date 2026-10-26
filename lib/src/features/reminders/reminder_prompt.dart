import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/notifications/reminders.dart';
import '../../core/state/settings.dart';

/// Tizim ruxsatini so'rab, eslatmalarni yoqadi. Rad etilsa — tushuntiradi.
Future<bool> enableReminders(BuildContext context, WidgetRef ref) async {
  final granted = await ReminderService.instance.requestPermission();
  ref.read(settingsProvider.notifier).setReminders(granted);
  if (context.mounted) {
    showToast(
      context,
      granted
          ? 'Eslatmalar yoqildi — har kuni ${_fmt(ref.read(settingsProvider).reminderTime)} da eslatamiz'
          : 'Ruxsat berilmadi. Telefon sozlamalaridan bildirishnomalarni yoqishingiz mumkin.',
      icon: granted ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
    );
  }
  return granted;
}

String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Eslatma vaqtini tanlash.
Future<void> pickReminderTime(BuildContext context, WidgetRef ref) async {
  final t = await showTimePicker(
    context: context,
    initialTime: ref.read(settingsProvider).reminderTime,
    helpText: 'Eslatma vaqti'.uz,
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  if (t != null) ref.read(settingsProvider.notifier).setReminderTime(t);
}

/// Sozlamalar sahifasidagi eslatmalar bo'limi.
class ReminderSettingsTiles extends ConsumerWidget {
  const ReminderSettingsTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    if (!ReminderService.supported) {
      return ListTile(
        leading: const Icon(Icons.notifications_none_rounded),
        title: Text('O\'qish eslatmalari'.uz),
        subtitle: Text('Eslatmalar Android va iOS ilovasida ishlaydi.'.uz),
      );
    }
    return Column(children: [
      SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: Text('O\'qish eslatmalari'.uz),
        subtitle: Text('Dars qilinmagan kunlari va seriya xavf ostida bo\'lganda eslatadi'.uz),
        value: s.remindersOn,
        onChanged: (v) => v ? enableReminders(context, ref) : ref.read(settingsProvider.notifier).setReminders(false),
      ),
      ListTile(
        enabled: s.remindersOn,
        leading: const Icon(Icons.schedule_rounded),
        title: Text('Eslatma vaqti'.uz),
        trailing: Text(_fmt(s.reminderTime), style: context.text.titleMedium),
        onTap: () => pickReminderTime(context, ref),
      ),
    ]);
  }
}

/// Bosh sahifada bir marta ko'rsatiladigan taklif — birinchi muvaffaqiyatdan keyin.
/// Tizim oynasi to'g'ridan-to'g'ri emas, avval nima uchun kerakligi tushuntiriladi.
class ReminderPromptCard extends ConsumerWidget {
  const ReminderPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(settingsProvider.select((s) => s.reminderTime));
    return KCard(
      color: KColors.violet.withValues(alpha: context.isDark ? 0.14 : 0.07),
      borderColor: KColors.violet.withValues(alpha: 0.35),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Floaty(amplitude: 3, child: KIconBox(Icons.notifications_active_rounded, color: KColors.violet, size: 46, filled: true)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText('Seriyani yo\'qotmang', style: context.text.titleSmall),
            const SizedBox(height: 2),
            UzText('Har kuni ${_fmt(t)} da qisqa eslatma yuboramiz — faqat kunlik maqsad hali bajarilmagan bo\'lsa. Spam yo\'q.',
                style: context.text.bodySmall),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              KButton(label: 'Yoqish', icon: Icons.notifications_rounded, compact: true, onPressed: () => enableReminders(context, ref)),
              KButton(label: 'Vaqtni tanlash', compact: true, variant: KButtonVariant.secondary, onPressed: () => pickReminderTime(context, ref)),
              KButton(
                label: 'Keyinroq',
                compact: true,
                variant: KButtonVariant.ghost,
                onPressed: () => ref.read(settingsProvider.notifier).dismissReminderPrompt(),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
