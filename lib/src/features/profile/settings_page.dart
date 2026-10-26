import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../core/storage/store.dart';
import '../code/code_view.dart';
import '../reminders/reminder_prompt.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    Widget group(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title.uz.toUpperCase(), style: context.text.labelSmall),
          ),
          KCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ],
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const KTopBar(title: 'Sozlamalar'),
      body: Builder(
        builder: (context) => ListView(
          padding: pagePadding(context),
          children: [
            ContentWidth(
              maxWidth: 760,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  group('Ko\'rinish', [
                    ListTile(
                      leading: const Icon(Icons.translate_rounded),
                      title: Text('Ilova tili'.uz),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton<AppLanguage>(
                            value: s.language,
                            isExpanded: true,
                            items: [
                              for (final language in AppLanguage.values)
                                DropdownMenuItem(
                                  value: language,
                                  child: Text(language.nativeName),
                                ),
                            ],
                            onChanged: (language) {
                              if (language != null) n.setLanguage(language);
                            },
                          ),
                          if (s.language != AppLanguage.uz)
                            Text(
                              'Tarjima bosqichma-bosqich qo\'shilmoqda; kurs darslari hozircha o\'zbekcha.'
                                  .uz,
                              style: context.text.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text('Mavzu'.uz),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SegmentedButton<ThemeMode>(
                          // Telefonda ikonka + belgi yozuvni ikki qatorga bo'lib yubormasin.
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('Tizim'.uz),
                              icon: context.isCompact
                                  ? null
                                  : const Icon(Icons.brightness_auto_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Yorug\''.uz),
                              icon: context.isCompact
                                  ? null
                                  : const Icon(Icons.light_mode_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Qorong\'i'.uz),
                              icon: context.isCompact
                                  ? null
                                  : const Icon(Icons.dark_mode_rounded),
                            ),
                          ],
                          selected: {s.themeMode},
                          onSelectionChanged: (v) => n.setThemeMode(v.first),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.water_drop_outlined),
                      title: Text('Interfeys uslubi'.uz),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SegmentedButton<LookPref>(
                              showSelectedIcon: false,
                              segments: [
                                for (final l in LookPref.values)
                                  ButtonSegment(
                                    value: l,
                                    label: Text(
                                      l.short.uz,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                              ],
                              selected: {s.look},
                              onSelectionChanged: (v) => n.setLook(v.first),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Avtomatik: iPhone\'da Liquid Glass (suvli shisha), Android\'da Material, brauzerda web uslubi.'
                                  .uz,
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up_outlined),
                      title: Text('Ovozli effektlar'.uz),
                      subtitle: Text(
                        'To\'g\'ri/xato javob va yutuqlar. Telefon jim rejimda bo\'lsa, ovoz chiqmaydi.'
                            .uz,
                      ),
                      value: s.soundOn,
                      onChanged: n.setSound,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.motion_photos_off_outlined),
                      title: Text('Harakatni kamaytirish'.uz),
                      subtitle: Text(
                        'Animatsiyalar avtomatik ijro etilmaydi (Reduce Motion)'
                            .uz,
                      ),
                      value: s.reduceMotion,
                      onChanged: n.setReduceMotion,
                    ),
                  ]),
                  group('Kod muharriri', [
                    SwitchListTile(
                      secondary: const Icon(Icons.code_rounded),
                      title: Text('Qorong\'i editor mavzusi'.uz),
                      value: s.editorDark,
                      onChanged: n.setEditorDark,
                    ),
                    ListTile(
                      leading: const Icon(Icons.format_size_rounded),
                      title: Text('Kod shrifti: ${s.codeFontSize.round()}'.uz),
                      subtitle: Slider(
                        value: s.codeFontSize,
                        min: 10,
                        max: 26,
                        divisions: 16,
                        label: '${s.codeFontSize.round()}',
                        onChanged: n.setCodeFontSize,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: CodeView(
                          code:
                              "void main() {\n  print('Salom!'); // namuna\n}",
                          showLineNumbers: true,
                        ),
                      ),
                    ),
                  ]),
                  group('Eslatmalar', const [ReminderSettingsTiles()]),
                  group('O\'qish', [
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: Text('Kunlik maqsad'.uz),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 30, label: Text('30 XP')),
                            ButtonSegment(value: 50, label: Text('50 XP')),
                            ButtonSegment(value: 100, label: Text('100 XP')),
                            ButtonSegment(value: 200, label: Text('200 XP')),
                          ],
                          selected: {s.dailyGoalXp},
                          onSelectionChanged: (v) => n.setDailyGoal(v.first),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule_rounded),
                      title: Text('Kunlik o\'qish vaqti'.uz),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final minutes in const [5, 10, 15, 20])
                              ChoiceChip(
                                label: Text('$minutes ${'daqiqa'.uz}'),
                                selected: s.dailyStudyMinutes == minutes,
                                onSelected: (_) =>
                                    n.setDailyStudyMinutes(minutes),
                              ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded),
                      title: Text('Ism'.uz),
                      subtitle: Text(
                        s.userName.isEmpty ? 'Kiritilmagan'.uz : s.userName,
                      ),
                      trailing: const Icon(Icons.edit_rounded),
                      onTap: () async {
                        final c = TextEditingController(text: s.userName);
                        final v = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Ismingiz'.uz),
                            content: TextField(controller: c, autofocus: true),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Bekor'.uz),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, c.text),
                                child: Text('Saqlash'.uz),
                              ),
                            ],
                          ),
                        );
                        if (v != null) n.setName(v);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text('Boshlang\'ich daraja'.uz),
                      subtitle: Text(s.startLevel.title.uz),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        n.resetOnboarding();
                        context.go('/onboarding');
                      },
                    ),
                  ]),
                  group('Ma\'lumotlar va maxfiylik', [
                    ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text('Ma\'lumotlarimni eksport qilish'.uz),
                      subtitle: Text(
                        'Progress va sozlamalar JSON ko\'rinishida nusxalanadi'
                            .uz,
                      ),
                      onTap: () {
                        final store = ref.read(storeProvider);
                        final data = {
                          for (final k in store.keysWithPrefix(''))
                            k: store.readJson(k) ?? store.readString(k),
                        };
                        Clipboard.setData(
                          ClipboardData(
                            text: const JsonEncoder.withIndent('  ')
                                .convert(data),
                          ),
                        );
                        showToast(
                          context,
                          'Ma\'lumotlar clipboard\'ga nusxalandi',
                          icon: Icons.check_rounded,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_rounded,
                        color: context.k.errorText,
                      ),
                      title: Text(
                        'Barcha ma\'lumotlarni o\'chirish'.uz,
                        style: TextStyle(color: context.k.errorText),
                      ),
                      subtitle: Text(
                        'Progress, kodlar va sozlamalar butunlay o\'chiriladi'
                            .uz,
                      ),
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Hammasini o\'chirasizmi?'.uz),
                            content: Text(
                              'Bu amalni ortga qaytarib bo\'lmaydi.'.uz,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('Bekor'.uz),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: KColors.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('O\'chirish'.uz),
                              ),
                            ],
                          ),
                        );
                        if (ok != true) return;
                        await ref.read(storeProvider).clearAll();
                        ref.invalidate(settingsProvider);
                        ref.invalidate(progressProvider);
                        if (context.mounted) context.go('/onboarding');
                      },
                    ),
                  ]),
                  KCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLUTTER_KITOB',
                          style: context.text.titleMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Versiya 0.1.0 · Kontent: $contentSdk ($contentReviewed)'
                              .uz,
                          style: context.text.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        RichUz(
                          'Ma\'lumotlaringiz faqat shu qurilmada saqlanadi. Kodlaringiz serverga yuborilmaydi — Dart kodi qurilmaning o\'zida, xavfsiz izolyatsiyalangan interpretatorda bajariladi.',
                          style: context.text.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Shriftlar: Inter, JetBrains Mono (SIL Open Font License)'
                              .uz,
                          style: codeStyle(
                            size: 11.5,
                            color: context.k.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
