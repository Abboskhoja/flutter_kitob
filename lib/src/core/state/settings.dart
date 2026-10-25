import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/store.dart';

/// O'quvchi tanlagan boshlang'ich daraja (onboarding).
enum StartLevel {
  beginner('Men mutlaqo yangiman', 'Dasturlash nimaligidan boshlaymiz', 0),
  littleCode('Ozgina dasturlashni bilaman', 'Dart asoslaridan boshlaymiz', 3),
  dartBasics('Dart asoslarini bilaman', 'OOP va asinxron Dart\'dan boshlaymiz', 4),
  flutterUsed('Flutter bilan ishlaganman', 'Flutter asoslariga o\'tamiz', 5),
  pro('Professional bilimimni kuchaytirmoqchiman', 'Barcha tayyor darslar ochiq — murakkab mavzular va loyihalar', 16);

  const StartLevel(this.title, this.subtitle, this.unlockedLevel);
  final String title;
  final String subtitle;

  /// Shu darajagacha bo'lgan barcha darslar ochiq bo'ladi.
  final int unlockedLevel;
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
    this.soundless = true,
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
  final bool soundless;

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
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        editorDark: editorDark ?? this.editorDark,
        codeFontSize: codeFontSize ?? this.codeFontSize,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        userName: userName ?? this.userName,
        startLevel: startLevel ?? this.startLevel,
        launchCount: launchCount ?? this.launchCount,
        dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
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
  };

  factory AppSettings.fromJson(Map<String, Object?> j) => AppSettings(
    themeMode: ThemeMode.values.asNameMap()[j['themeMode']] ?? ThemeMode.system,
    reduceMotion: j['reduceMotion'] as bool? ?? false,
    editorDark: j['editorDark'] as bool? ?? true,
    codeFontSize: (j['codeFontSize'] as num?)?.toDouble() ?? 14,
    onboardingDone: j['onboardingDone'] as bool? ?? false,
    userName: j['userName'] as String? ?? '',
    startLevel: StartLevel.values.asNameMap()[j['startLevel']] ?? StartLevel.beginner,
    launchCount: j['launchCount'] as int? ?? 0,
    dailyGoalXp: j['dailyGoalXp'] as int? ?? 50,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'settings';

  @override
  AppSettings build() {
    final j = ref.read(storeProvider).readJson(_key);
    return j == null ? const AppSettings() : AppSettings.fromJson(j);
  }

  void _save(AppSettings s) {
    state = s;
    ref.read(storeProvider).writeJson(_key, s.toJson());
  }

  void setThemeMode(ThemeMode m) => _save(state.copyWith(themeMode: m));
  void setReduceMotion(bool v) => _save(state.copyWith(reduceMotion: v));
  void setEditorDark(bool v) => _save(state.copyWith(editorDark: v));
  void setCodeFontSize(double v) => _save(state.copyWith(codeFontSize: v.clamp(10, 26)));
  void setDailyGoal(int v) => _save(state.copyWith(dailyGoalXp: v));
  void setName(String v) => _save(state.copyWith(userName: v.trim()));
  void registerLaunch() => _save(state.copyWith(launchCount: state.launchCount + 1));

  void completeOnboarding({required String name, required StartLevel level}) =>
      _save(state.copyWith(onboardingDone: true, userName: name.trim(), startLevel: level));

  void resetOnboarding() => _save(state.copyWith(onboardingDone: false));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Tizim "harakatni kamaytirish" sozlamasi yoki ilova sozlamasi.
bool reduceMotionOf(BuildContext context, AppSettings s) =>
    s.reduceMotion || MediaQuery.maybeDisableAnimationsOf(context) == true;
