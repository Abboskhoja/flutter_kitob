import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/tokens.dart';
import '../storage/store.dart';
import 'progress.dart';

/// Haftalik vazifa turi va uning o'lchovi.
enum QuestMetric { lessons, codeRuns, quizzes, perfect, bugs, reviews, tasks, activeDays }

class QuestDef {
  const QuestDef(this.id, this.metric, this.target, this.xp, this.title, this.icon, this.color);
  final String id;
  final QuestMetric metric;
  final int target;
  final int xp;
  final String title;
  final IconData icon;
  final Color color;
}

/// Har hafta: bitta asosiy (darslar) + ikkita aylanib turuvchi vazifa.
/// Mukofot faqat haqiqiy harakat uchun — tugma bosish bilan XP yig'ilmaydi.
const questMain = QuestDef('lessons3', QuestMetric.lessons, 3, 60, '3 ta darsni tugating', Icons.menu_book_rounded, KColors.primary);
const questPool = <QuestDef>[
  QuestDef('runs10', QuestMetric.codeRuns, 10, 30, 'Kodni 10 marta ishga tushiring', Icons.play_circle_rounded, KColors.success),
  QuestDef('quiz2', QuestMetric.quizzes, 2, 40, '2 ta testdan o\'ting', Icons.quiz_rounded, KColors.violet),
  QuestDef('perfect1', QuestMetric.perfect, 1, 50, 'Bitta testni 100% bilan topshiring', Icons.workspace_premium_rounded, KColors.warning),
  QuestDef('bug1', QuestMetric.bugs, 1, 30, 'Bitta xatoli kodni tuzating', Icons.bug_report_rounded, KColors.error),
  QuestDef('review1', QuestMetric.reviews, 1, 40, 'Takrorlash testini topshiring', Icons.psychology_rounded, KColors.teal),
  QuestDef('task1', QuestMetric.tasks, 1, 40, 'Bitta mustaqil vazifani yeching', Icons.edit_note_rounded, KColors.cyan),
  QuestDef('days4', QuestMetric.activeDays, 4, 70, 'Hafta davomida 4 kun o\'qing', Icons.local_fire_department_rounded, KColors.orange),
];

/// Hafta boshi (dushanba) kaliti.
String weekKeyOf(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return dayKey(day.subtract(Duration(days: day.weekday - 1)));
}

List<QuestDef> questsForWeek(String weekKey) {
  final n = DateTime.parse(weekKey).difference(DateTime(2024, 1, 1)).inDays ~/ 7;
  final a = n % questPool.length;
  final b = (a + 1 + n % (questPool.length - 1)) % questPool.length;
  return [questMain, questPool[a], questPool[b == a ? (a + 1) % questPool.length : b]];
}

int metricValue(ProgressState p, QuestMetric m, {DateTime? now}) => switch (m) {
  QuestMetric.lessons => p.completedCount,
  QuestMetric.codeRuns => p.counter(Counters.codeRuns),
  QuestMetric.quizzes => p.counter(Counters.quizzesPassed),
  QuestMetric.perfect => p.counter(Counters.perfectQuizzes),
  QuestMetric.bugs => p.counter(Counters.bugsFixed),
  QuestMetric.reviews => p.counter(Counters.reviewsDone),
  QuestMetric.tasks => p.counter(Counters.tasksSolved),
  // Faol kunlar baza talab qilmaydi — haftaning o'zidan sanaladi.
  QuestMetric.activeDays => () {
    final start = DateTime.parse(weekKeyOf(now ?? DateTime.now()));
    return [for (var i = 0; i < 7; i++) p.xpOn(start.add(Duration(days: i)))].where((x) => x > 0).length;
  }(),
};

@immutable
class QuestsState {
  const QuestsState({required this.week, this.base = const {}, this.claimed = const {}});
  final String week;

  /// Hafta boshidagi o'lchovlar — progress shundan beri sanaladi.
  final Map<String, int> base;
  final Set<String> claimed;

  Map<String, Object?> toJson() => {'week': week, 'base': base, 'claimed': claimed.toList()};

  factory QuestsState.fromJson(Map<String, Object?> j) => QuestsState(
    week: j['week'] as String? ?? '',
    base: ((j['base'] as Map?) ?? const {}).map((k, v) => MapEntry(k as String, v as int)),
    claimed: ((j['claimed'] as List?) ?? const []).cast<String>().toSet(),
  );
}

class QuestProgress {
  const QuestProgress(this.def, this.value, this.claimed);
  final QuestDef def;
  final int value;
  final bool claimed;
  bool get done => value >= def.target;
  double get ratio => (value / def.target).clamp(0.0, 1.0);
}

class QuestsNotifier extends Notifier<QuestsState> {
  static const _key = 'quests';

  @override
  QuestsState build() {
    final j = ref.read(storeProvider).readJson(_key);
    final s = j == null ? null : QuestsState.fromJson(j);
    return _ensureWeek(s, persist: true);
  }

  QuestsState _ensureWeek(QuestsState? s, {bool persist = false}) {
    final week = weekKeyOf(DateTime.now());
    if (s != null && s.week == week) return s;
    // Yangi hafta: hozirgi qiymatlar boshlang'ich nuqta bo'ladi.
    final p = ref.read(progressProvider);
    final next = QuestsState(week: week, base: {for (final m in QuestMetric.values) m.name: metricValue(p, m)});
    if (persist) ref.read(storeProvider).writeJson(_key, next.toJson());
    return next;
  }

  /// UI build paytida chaqiriladi — holatni o'zgartirmaydi (hafta almashsa,
  /// yangi hafta faqat hisoblanadi; saqlash `claim` yoki keyingi ishga tushishda).
  List<QuestProgress> current(ProgressState p) {
    final s = _ensureWeek(state);
    return [
      for (final q in questsForWeek(s.week))
        QuestProgress(
          q,
          q.metric == QuestMetric.activeDays ? metricValue(p, q.metric) : (metricValue(p, q.metric) - (s.base[q.metric.name] ?? 0)).clamp(0, 1 << 30),
          s.claimed.contains(q.id),
        ),
    ];
  }

  /// Bajarilgan vazifa mukofotini oladi. Qaytaradi: berilgan XP (0 — bajarilmagan yoki olingan).
  int claim(String id) {
    final s = _ensureWeek(state, persist: true);
    if (!identical(s, state)) state = s;
    final q = current(ref.read(progressProvider)).where((e) => e.def.id == id).firstOrNull;
    if (q == null || !q.done || q.claimed) return 0;
    state = QuestsState(week: s.week, base: s.base, claimed: {...s.claimed, id});
    ref.read(storeProvider).writeJson(_key, state.toJson());
    ref.read(progressProvider.notifier).grantXp(q.def.xp);
    return q.def.xp;
  }
}

final questsProvider = NotifierProvider<QuestsNotifier, QuestsState>(QuestsNotifier.new);
