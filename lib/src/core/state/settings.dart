import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/store.dart';

enum AppLanguage {
  uz('uz', 'O‘zbekcha'),
  en('en', 'English'),
  ru('ru', 'Русский');

  const AppLanguage(this.code, this.nativeName);
  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage forLocale(Locale locale) => switch (locale.languageCode) {
    'en' => AppLanguage.en,
    'ru' => AppLanguage.ru,
    _ => AppLanguage.uz,
  };
}

/// O'quvchi tanlagan boshlang'ich daraja (onboarding).
enum StartLevel {
  beginner('Men mutlaqo yangiman', 'Dasturlash nimaligidan boshlaymiz', 0),
  littleCode('Ozgina dasturlashni bilaman', 'Dart asoslaridan boshlaymiz', 3),
  dartBasics(
    'Dart asoslarini bilaman',
    'OOP va asinxron Dart\'dan boshlaymiz',
    4,
  ),
  flutterUsed('Flutter bilan ishlaganman', 'Flutter asoslariga o\'tamiz', 5),
  pro(
    'Professional bilimimni kuchaytirmoqchiman',
    'Barcha tayyor darslar ochiq — murakkab mavzular va loyihalar',
    16,
  );

  const StartLevel(this.title, this.subtitle, this.unlockedLevel);
  final String title;
  final String subtitle;

  /// Shu darajagacha bo'lgan barcha darslar ochiq bo'ladi.
  final int unlockedLevel;
}

/// Interfeys uslubi. `auto` — platformaga qarab: iOS/macOS → Liquid Glass,
/// Android → Material, Web → web uslubi.
enum LookPref {
  auto('Avtomatik', 'Avto'),
  glass('Liquid Glass', 'Glass'),
  material('Material', 'Material');

  const LookPref(this.title, this.short);
  final String title;

  /// Tor joylar (segment tugmalar) uchun qisqa nom.
  final String short;
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.editorDark = true,
    this.codeFontSize = 14,
    this.onboardingDone = false,
    this.userName = '',
    this.startLevel = StartLevel.beginner,
    this.launchCount = 0,
    this.dailyGoalXp = 50,
    this.dailyStudyMinutes = 10,
    this.soundless = true,
    this.remindersOn = false,
    this.reminderMinutes = 19 * 60,
    this.reminderAsked = false,
    this.look = LookPref.auto,
    this.soundOn = true,
    this.language = AppLanguage.uz,
  });

  final ThemeMode themeMode;
  final bool reduceMotion;
  final bool editorDark;
  final double codeFontSize;
  final bool onboardingDone;
  final String userName;
  final StartLevel startLevel;
  final int launchCount;
  final int dailyGoalXp;
  final int dailyStudyMinutes;
  final bool soundless;

  /// O'qish eslatmalari yoqilganmi (tizim ruxsati berilgandan keyin).
  final bool remindersOn;

  /// Eslatma vaqti — yarim tundan boshlab daqiqalar (19:00 = 1140).
  final int reminderMinutes;

  /// Eslatmalarni yoqish taklifi ko'rsatilib, javob olinganmi.
  final bool reminderAsked;

  final LookPref look;

  /// To'g'ri/xato javob va bayram ovozlari (telefon jim rejimini hurmat qiladi).
  final bool soundOn;
  final AppLanguage language;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderMinutes ~/ 60, minute: reminderMinutes % 60);

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? reduceMotion,
    bool? editorDark,
    double? codeFontSize,
    bool? onboardingDone,
    String? userName,
    StartLevel? startLevel,
    int? launchCount,
    int? dailyGoalXp,
    int? dailyStudyMinutes,
    bool? remindersOn,
    int? reminderMinutes,
    bool? reminderAsked,
    LookPref? look,
    bool? soundOn,
    AppLanguage? language,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    editorDark: editorDark ?? this.editorDark,
    codeFontSize: codeFontSize ?? this.codeFontSize,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    userName: userName ?? this.userName,
    startLevel: startLevel ?? this.startLevel,
    launchCount: launchCount ?? this.launchCount,
    dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
    dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
    remindersOn: remindersOn ?? this.remindersOn,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    reminderAsked: reminderAsked ?? this.reminderAsked,
    look: look ?? this.look,
    soundOn: soundOn ?? this.soundOn,
    language: language ?? this.language,
  );

  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'reduceMotion': reduceMotion,
    'editorDark': editorDark,
    'codeFontSize': codeFontSize,
    'onboardingDone': onboardingDone,
    'userName': userName,
    'startLevel': startLevel.name,
    'launchCount': launchCount,
    'dailyGoalXp': dailyGoalXp,
    'dailyStudyMinutes': dailyStudyMinutes,
    'remindersOn': remindersOn,
    'reminderMinutes': reminderMinutes,
    'reminderAsked': reminderAsked,
    'look': look.name,
    'soundOn': soundOn,
    'language': language.name,
  };

  factory AppSettings.fromJson(
    Map<String, Object?> j, {
    AppLanguage fallbackLanguage = AppLanguage.uz,
  }) => AppSettings(
    themeMode: ThemeMode.values.asNameMap()[j['themeMode']] ?? ThemeMode.system,
    reduceMotion: j['reduceMotion'] as bool? ?? false,
    editorDark: j['editorDark'] as bool? ?? true,
    codeFontSize: (j['codeFontSize'] as num?)?.toDouble() ?? 14,
    onboardingDone: j['onboardingDone'] as bool? ?? false,
    userName: j['userName'] as String? ?? '',
    startLevel:
        StartLevel.values.asNameMap()[j['startLevel']] ?? StartLevel.beginner,
    launchCount: j['launchCount'] as int? ?? 0,
    dailyGoalXp: j['dailyGoalXp'] as int? ?? 50,
    dailyStudyMinutes: j['dailyStudyMinutes'] as int? ?? 10,
    remindersOn: j['remindersOn'] as bool? ?? false,
    reminderMinutes: j['reminderMinutes'] as int? ?? 19 * 60,
    reminderAsked: j['reminderAsked'] as bool? ?? false,
    look: LookPref.values.asNameMap()[j['look']] ?? LookPref.auto,
    soundOn: j['soundOn'] as bool? ?? true,
    language: AppLanguage.values.asNameMap()[j['language']] ?? fallbackLanguage,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'settings';

  @override
  AppSettings build() {
    final j = ref.read(storeProvider).readJson(_key);
    // Darslar hozircha faqat o'zbekcha: qurilma tili inglizcha bo'lsa ham interfeys
    // o'zbekcha boshlanadi — aks holda sarlavhalar inglizcha, matnlar o'zbekcha
    // aralashib qoladi. Boshqa tilni o'quvchi o'zi tanlaydi (onboarding/sozlamalar).
    const fallbackLanguage = AppLanguage.uz;
    return j == null
        ? AppSettings(language: fallbackLanguage)
        : AppSettings.fromJson(j, fallbackLanguage: fallbackLanguage);
  }

  void _save(AppSettings s) {
    state = s;
    ref.read(storeProvider).writeJson(_key, s.toJson());
  }

  void setThemeMode(ThemeMode m) => _save(state.copyWith(themeMode: m));
  void setReduceMotion(bool v) => _save(state.copyWith(reduceMotion: v));
  void setEditorDark(bool v) => _save(state.copyWith(editorDark: v));
  void setCodeFontSize(double v) =>
      _save(state.copyWith(codeFontSize: v.clamp(10, 26)));
  void setDailyGoal(int v) => _save(state.copyWith(dailyGoalXp: v));
  void setDailyStudyMinutes(int v) =>
      _save(state.copyWith(dailyStudyMinutes: v));
  void setName(String v) => _save(state.copyWith(userName: v.trim()));
  void setReminders(bool on) =>
      _save(state.copyWith(remindersOn: on, reminderAsked: true));
  void setReminderTime(TimeOfDay t) =>
      _save(state.copyWith(reminderMinutes: t.hour * 60 + t.minute));
  void setSound(bool v) => _save(state.copyWith(soundOn: v));
  void setLanguage(AppLanguage v) => _save(state.copyWith(language: v));
  void setLook(LookPref v) => _save(state.copyWith(look: v));
  void dismissReminderPrompt() => _save(state.copyWith(reminderAsked: true));
  void registerLaunch() =>
      _save(state.copyWith(launchCount: state.launchCount + 1));

  void completeOnboarding({
    required String name,
    required StartLevel level,
    required int dailyMinutes,
  }) => _save(
    state.copyWith(
      onboardingDone: true,
      userName: name.trim(),
      startLevel: level,
      dailyStudyMinutes: dailyMinutes,
    ),
  );

  void resetOnboarding() => _save(state.copyWith(onboardingDone: false));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Tizim "harakatni kamaytirish" sozlamasi yoki ilova sozlamasi.
bool reduceMotionOf(BuildContext context, AppSettings s) =>
    s.reduceMotion || MediaQuery.maybeDisableAnimationsOf(context) == true;
