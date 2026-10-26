import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/curriculum.dart';
import '../../content/model.dart';
import '../storage/store.dart';
import 'settings.dart';

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime parseDay(String s) => DateTime.parse(s);

@immutable
class LessonProgress {
  const LessonProgress({
    this.step = 0,
    this.completed = false,
    this.bestQuiz = -1,
    this.taskSolved = false,
    this.bugFixed = false,
    this.quizAttempts = 0,
    this.completedAt,
  });

  final int step;
  final bool completed;

  /// -1 — test hali topshirilmagan, aks holda 0..100.
  final int bestQuiz;
  final bool taskSolved;
  final bool bugFixed;
  final int quizAttempts;
  final String? completedAt;

  LessonProgress copyWith({
    int? step,
    bool? completed,
    int? bestQuiz,
    bool? taskSolved,
    bool? bugFixed,
    int? quizAttempts,
    String? completedAt,
  }) => LessonProgress(
    step: step ?? this.step,
    completed: completed ?? this.completed,
    bestQuiz: bestQuiz ?? this.bestQuiz,
    taskSolved: taskSolved ?? this.taskSolved,
    bugFixed: bugFixed ?? this.bugFixed,
    quizAttempts: quizAttempts ?? this.quizAttempts,
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, Object?> toJson() => {
    's': step,
    'c': completed,
    'q': bestQuiz,
    't': taskSolved,
    'b': bugFixed,
    'a': quizAttempts,
    'at': completedAt,
  };

  factory LessonProgress.fromJson(Map<String, Object?> j) => LessonProgress(
    step: j['s'] as int? ?? 0,
    completed: j['c'] as bool? ?? false,
    bestQuiz: j['q'] as int? ?? -1,
    taskSolved: j['t'] as bool? ?? false,
    bugFixed: j['b'] as bool? ?? false,
    quizAttempts: j['a'] as int? ?? 0,
    completedAt: j['at'] as String?,
  );
}

/// Intervalli takrorlash yozuvi (Leitner/SM-2 soddalashtirilgan).
@immutable
class ReviewItem {
  const ReviewItem({required this.due, this.interval = 1, this.reps = 0});
  final String due;
  final int interval;
  final int reps;

  bool isDue(DateTime today) =>
      !parseDay(due).isAfter(DateTime(today.year, today.month, today.day));

  Map<String, Object?> toJson() => {'d': due, 'i': interval, 'r': reps};
  factory ReviewItem.fromJson(Map<String, Object?> j) => ReviewItem(
    due: j['d'] as String,
    interval: j['i'] as int? ?? 1,
    reps: j['r'] as int? ?? 0,
  );
}

@immutable
class QuizRecord {
  const QuizRecord({
    required this.id,
    required this.title,
    required this.score,
    required this.date,
    required this.wrongTopics,
  });
  final String id;
  final String title;
  final int score;
  final String date;
  final List<String> wrongTopics;

  Map<String, Object?> toJson() => {
    'id': id,
    't': title,
    's': score,
    'd': date,
    'w': wrongTopics,
  };
  factory QuizRecord.fromJson(Map<String, Object?> j) => QuizRecord(
    id: j['id'] as String,
    title: j['t'] as String,
    score: j['s'] as int,
    date: j['d'] as String,
    wrongTopics: (j['w'] as List?)?.cast<String>() ?? const [],
  );
}

abstract final class Counters {
  static const codeRuns = 'codeRuns';
  static const tasksSolved = 'tasksSolved';
  static const bugsFixed = 'bugsFixed';
  static const terminalCommands = 'terminal';
  static const terminalMissions = 'terminalMissions';
  static const quizzesPassed = 'quizzesPassed';
  static const perfectQuizzes = 'perfectQuizzes';
  static const labsUsed = 'labs';
  static const visualizations = 'visual';
  static const examsPassed = 'exams';
  static const secondsLearned = 'seconds';
  static const projectsDone = 'projects';
  static const reviewsDone = 'reviews';
}

@immutable
class ProgressState {
  const ProgressState({
    this.lessons = const {},
    this.xp = 0,
    this.dailyXp = const {},
    this.dailySeconds = const {},
    this.achievements = const {},
    this.skills = const {},
    this.mistakes = const {},
    this.reviews = const {},
    this.counters = const {},
    this.unlockedLevels = const {},
    this.passedExams = const {},
    this.history = const [],
    this.celebrations = const [],
  });

  final Map<String, LessonProgress> lessons;
  final int xp;
  final Map<String, int> dailyXp;
  final Map<String, int> dailySeconds;
  final Set<String> achievements;
  final Map<String, double> skills;
  final Map<String, int> mistakes;
  final Map<String, ReviewItem> reviews;
  final Map<String, int> counters;
  final Set<int> unlockedLevels;

  /// Imtihon bo'yicha ilk muvaffaqiyat mukofotini olgan darajalar.
  final Set<String> passedExams;
  final List<QuizRecord> history;

  /// Hali ko'rsatilmagan yangi yutuqlar (UI ko'rsatgach tozalaydi).
  final List<String> celebrations;

  int counter(String k) => counters[k] ?? 0;
  LessonProgress of(String id) => lessons[id] ?? const LessonProgress();
  bool isCompleted(String id) => lessons[id]?.completed ?? false;
  int get completedCount => lessons.values.where((l) => l.completed).length;

  int xpOn(DateTime d) => dailyXp[dayKey(d)] ?? 0;
  int secondsOn(DateTime d) => dailySeconds[dayKey(d)] ?? 0;

  /// Ketma-ket faol kunlar soni (bugun yoki kechadan boshlab).
  int get streak => streakAt(DateTime.now());

  /// [now] kuniga nisbatan seriya (eslatmalarni rejalashtirish uchun).
  int streakAt(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (xpOn(day) == 0) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (xpOn(day) > 0) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  int get bestStreak {
    if (dailyXp.isEmpty) return 0;
    final days =
        dailyXp.entries
            .where((e) => e.value > 0)
            .map((e) => parseDay(e.key))
            .toList()
          ..sort();
    var best = 0, cur = 0;
    DateTime? prev;
    for (final d in days) {
      cur = prev != null && d.difference(prev).inDays == 1 ? cur + 1 : 1;
      best = math.max(best, cur);
      prev = d;
    }
    return best;
  }

  /// O'quvchi darajasi: har bir keyingi daraja oldingisidan 100 XP ko'p talab qiladi.
  int get userLevel => _levelFor(xp).$1;
  double get levelProgress {
    final (lv, start, next) = _levelFor(xp);
    if (lv < 1) return 0;
    return ((xp - start) / (next - start)).clamp(0.0, 1.0);
  }

  int get xpToNext {
    final (_, _, next) = _levelFor(xp);
    return next - xp;
  }

  static (int, int, int) _levelFor(int xp) {
    var level = 1, start = 0, need = 100;
    while (xp >= start + need) {
      start += need;
      level++;
      need += 100;
    }
    return (level, start, start + need);
  }

  List<String> dueReviews(DateTime today) => [
    for (final e in reviews.entries)
      if (e.value.isDue(today) && lessonById.containsKey(e.key)) e.key,
  ];

  /// Track bo'yicha o'zlashtirish (0..1); hali dalil to'planmagan bo'lsa null.
  /// Faqat baholangan natijalarni hisoblaydi, o'rganilmagan mavzuni 0 deb olmaydi.
  double? trackMastery(Track t) {
    final lessonsOfTrack = [
      for (final lv in curriculum)
        if (lv.track == t) ...lv.lessons,
    ];
    if (lessonsOfTrack.isEmpty) return null;
    var sum = 0.0;
    var evidenceCount = 0;
    for (final l in lessonsOfTrack) {
      final p = lessons[l.id];
      if (p == null || !p.completed) continue;
      if (p.bestQuiz >= 0) {
        sum += p.bestQuiz / 100;
        evidenceCount++;
      }
      if (p.taskSolved) {
        sum += 1;
        evidenceCount++;
      }
    }
    if (evidenceCount == 0) return null;
    return sum / evidenceCount;
  }

  List<MapEntry<String, int>> get weakTopics {
    final l = mistakes.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return l;
  }

  ProgressState copyWith({
    Map<String, LessonProgress>? lessons,
    int? xp,
    Map<String, int>? dailyXp,
    Map<String, int>? dailySeconds,
    Set<String>? achievements,
    Map<String, double>? skills,
    Map<String, int>? mistakes,
    Map<String, ReviewItem>? reviews,
    Map<String, int>? counters,
    Set<int>? unlockedLevels,
    Set<String>? passedExams,
    List<QuizRecord>? history,
    List<String>? celebrations,
  }) => ProgressState(
    lessons: lessons ?? this.lessons,
    xp: xp ?? this.xp,
    dailyXp: dailyXp ?? this.dailyXp,
    dailySeconds: dailySeconds ?? this.dailySeconds,
    achievements: achievements ?? this.achievements,
    skills: skills ?? this.skills,
    mistakes: mistakes ?? this.mistakes,
    reviews: reviews ?? this.reviews,
    counters: counters ?? this.counters,
    unlockedLevels: unlockedLevels ?? this.unlockedLevels,
    passedExams: passedExams ?? this.passedExams,
    history: history ?? this.history,
    celebrations: celebrations ?? this.celebrations,
  );

  Map<String, Object?> toJson() => {
    'lessons': {for (final e in lessons.entries) e.key: e.value.toJson()},
    'xp': xp,
    'daily': dailyXp,
    'dailySeconds': dailySeconds,
    'ach': achievements.toList(),
    'skills': skills,
    'mistakes': mistakes,
    'reviews': {for (final e in reviews.entries) e.key: e.value.toJson()},
    'counters': counters,
    'levels': unlockedLevels.toList(),
    'passedExams': passedExams.toList(),
    'history': [for (final h in history) h.toJson()],
  };

  factory ProgressState.fromJson(Map<String, Object?> j) {
    final history = [
      for (final h in (j['history'] as List?) ?? const [])
        QuizRecord.fromJson((h as Map).cast<String, Object?>()),
    ];
    final passedExams =
        (j['passedExams'] as List?)?.cast<String>().toSet() ??
        {
          for (final h in history)
            if (h.id.startsWith('exam:') && h.score >= 80) h.id,
        };
    return ProgressState(
      lessons: {
        for (final e in ((j['lessons'] as Map?) ?? const {}).entries)
          e.key as String: LessonProgress.fromJson(
            (e.value as Map).cast<String, Object?>(),
          ),
      },
      xp: j['xp'] as int? ?? 0,
      dailyXp: ((j['daily'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
      dailySeconds: ((j['dailySeconds'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
      achievements: ((j['ach'] as List?) ?? const []).cast<String>().toSet(),
      skills: ((j['skills'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, (v as num).toDouble()),
      ),
      mistakes: ((j['mistakes'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
      reviews: {
        for (final e in ((j['reviews'] as Map?) ?? const {}).entries)
          e.key as String: ReviewItem.fromJson(
            (e.value as Map).cast<String, Object?>(),
          ),
      },
      counters: ((j['counters'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, v as int),
      ),
      unlockedLevels: ((j['levels'] as List?) ?? const []).cast<int>().toSet(),
      passedExams: passedExams,
      history: history,
    );
  }
}

enum LessonStatus { locked, available, inProgress, completed }

class ProgressNotifier extends Notifier<ProgressState> {
  static const _key = 'progress';

  @override
  ProgressState build() {
    final j = ref.read(storeProvider).readJson(_key);
    return j == null ? const ProgressState() : ProgressState.fromJson(j);
  }

  void _commit(ProgressState next) {
    final withAch = _checkAchievements(next);
    state = withAch;
    ref.read(storeProvider).writeJson(_key, withAch.toJson());
  }

  ProgressState _addXp(ProgressState s, int amount) {
    if (amount <= 0) return s;
    final k = dayKey(DateTime.now());
    return s.copyWith(
      xp: s.xp + amount,
      dailyXp: {...s.dailyXp, k: (s.dailyXp[k] ?? 0) + amount},
    );
  }

  ProgressState _inc(ProgressState s, String counter, [int by = 1]) =>
      s.copyWith(counters: {...s.counters, counter: s.counter(counter) + by});

  LessonProgress _lp(String id) => state.of(id);

  ProgressState _putLesson(ProgressState s, String id, LessonProgress p) =>
      s.copyWith(lessons: {...s.lessons, id: p});

  // ───────────────────────── Ochiqlik ─────────────────────────

  bool isUnlocked(String lessonId) {
    final level = levelOfLesson[lessonId];
    if (level == null) return false;
    final start = ref.read(settingsProvider).startLevel;
    if (level.number <= start.unlockedLevel) return true;
    if (state.unlockedLevels.contains(level.number)) return true;
    if (state.lessons.containsKey(lessonId)) return true;
    final prev = previousLessonOf(lessonId);
    return prev == null || state.isCompleted(prev.id);
  }

  LessonStatus statusOf(String lessonId) {
    final p = state.lessons[lessonId];
    if (p?.completed ?? false) return LessonStatus.completed;
    if (p != null) return LessonStatus.inProgress;
    return isUnlocked(lessonId) ? LessonStatus.available : LessonStatus.locked;
  }

  /// Davom ettirish uchun keyingi dars.
  Lesson? continueLesson() {
    for (final l in allLessons) {
      final p = state.lessons[l.id];
      if (p != null && !p.completed) return l;
    }
    for (final l in allLessons) {
      if (!state.isCompleted(l.id) && isUnlocked(l.id)) return l;
    }
    return null;
  }

  // ───────────────────────── Amallar ─────────────────────────

  void openLesson(String id) {
    if (state.lessons.containsKey(id)) return;
    _commit(_putLesson(state, id, const LessonProgress()));
  }

  void setStep(String id, int step) {
    final p = _lp(id);
    if (p.step == step) return;
    _commit(_putLesson(state, id, p.copyWith(step: step)));
  }

  /// Haftalik vazifa kabi haqiqiy natija uchun beriladigan mukofot.
  void grantXp(int amount) => _commit(_addXp(state, amount));

  void recordCodeRun() => _commit(_inc(state, Counters.codeRuns));
  void recordVisualization() => _commit(_inc(state, Counters.visualizations));
  void recordLabUse() => _commit(_inc(state, Counters.labsUsed));
  void recordTime(int seconds) {
    if (seconds <= 0) return;
    final key = dayKey(DateTime.now());
    final withTotal = _inc(state, Counters.secondsLearned, seconds);
    _commit(
      withTotal.copyWith(
        dailySeconds: {
          ...withTotal.dailySeconds,
          key: (withTotal.dailySeconds[key] ?? 0) + seconds,
        },
      ),
    );
  }

  void recordTerminalCommand({bool missionCompleted = false}) {
    var s = _inc(state, Counters.terminalCommands);
    if (missionCompleted) {
      s = _inc(s, Counters.terminalMissions);
      s = _addXp(s, 10);
    }
    _commit(s);
  }

  /// Amaliy vazifa yechildi. XP faqat birinchi marta beriladi.
  void solveTask(String lessonId) {
    final p = _lp(lessonId);
    var s = state;
    if (!p.taskSolved) {
      s = _addXp(s, 20);
      s = _inc(s, Counters.tasksSolved);
    }
    _commit(_putLesson(s, lessonId, p.copyWith(taskSolved: true)));
  }

  void solvePracticeTask(String taskId) {
    final key = 'practice:$taskId';
    if (state.achievements.contains(key)) return;
    var s = _addXp(state, 15);
    s = _inc(s, Counters.tasksSolved);
    _commit(s.copyWith(achievements: {...s.achievements, key}));
  }

  void fixBug(String lessonId) {
    final p = _lp(lessonId);
    var s = state;
    if (!p.bugFixed) {
      s = _addXp(s, 10);
      s = _inc(s, Counters.bugsFixed);
    }
    _commit(_putLesson(s, lessonId, p.copyWith(bugFixed: true)));
  }

  /// Dars testi natijasi. Qaytaradi: dars tugallandimi.
  bool submitLessonQuiz(Lesson lesson, int score, List<String> wrongTopics) {
    final p = _lp(lesson.id);
    var s = state;
    s = _recordMistakes(s, wrongTopics);
    final passed = score >= 60;
    final firstCompletion = passed && !p.completed;
    var np = p.copyWith(
      bestQuiz: math.max(p.bestQuiz, score),
      quizAttempts: p.quizAttempts + 1,
    );
    if (passed) {
      s = _inc(s, Counters.quizzesPassed);
      if (score == 100) s = _inc(s, Counters.perfectQuizzes);
    }
    if (firstCompletion) {
      np = np.copyWith(
        completed: true,
        completedAt: DateTime.now().toIso8601String(),
      );
      s = _addXp(s, lesson.xp + (score * 30 ~/ 100));
      s = s.copyWith(
        reviews: {
          ...s.reviews,
          lesson.id: ReviewItem(
            due: dayKey(DateTime.now().add(const Duration(days: 1))),
          ),
        },
      );
      s = s.copyWith(
        skills: {
          ...s.skills,
          for (final sk in lesson.skills)
            sk: math.max(s.skills[sk] ?? 0, score / 100),
        },
      );
    } else if (passed && score > p.bestQuiz) {
      s = _addXp(s, 5);
    }
    s = _addHistory(
      s,
      QuizRecord(
        id: lesson.id,
        title: lesson.title,
        score: score,
        date: dayKey(DateTime.now()),
        wrongTopics: wrongTopics,
      ),
    );
    _commit(_putLesson(s, lesson.id, np));
    return passed;
  }

  /// Takrorlash testi (spaced repetition).
  void submitReview(String lessonId, int score, List<String> wrongTopics) {
    final item = state.reviews[lessonId];
    final now = DateTime.now();
    final isScheduledReview = item != null && item.isDue(now);
    final current = item ?? ReviewItem(due: dayKey(now));
    final good = score >= 80;
    final interval = good ? math.max(1, (current.interval * 2.5).round()) : 1;
    var s = _recordMistakes(state, wrongTopics);
    if (isScheduledReview) {
      s = _inc(s, Counters.reviewsDone);
      s = _addXp(s, good ? 15 : 5);
    }
    final lesson = lessonById[lessonId];
    if (isScheduledReview && lesson != null) {
      s = s.copyWith(
        skills: {
          ...s.skills,
          for (final sk in lesson.skills)
            sk: ((s.skills[sk] ?? 0) * 0.5 + score / 200).clamp(0.0, 1.0),
        },
      );
    }
    if (isScheduledReview) {
      s = s.copyWith(
        reviews: {
          ...s.reviews,
          lessonId: ReviewItem(
            due: dayKey(now.add(Duration(days: interval))),
            interval: interval,
            reps: current.reps + 1,
          ),
        },
      );
    }
    s = _addHistory(
      s,
      QuizRecord(
        id: 'review:$lessonId',
        title: 'Takrorlash: ${lesson?.title ?? lessonId}',
        score: score,
        date: dayKey(DateTime.now()),
        wrongTopics: wrongTopics,
      ),
    );
    _commit(s);
  }

  /// Daraja imtihoni. 80% dan yuqori bo'lsa keyingi daraja ochiladi.
  void submitExam(
    int levelNumber,
    String title,
    int score,
    List<String> wrongTopics,
  ) {
    var s = _recordMistakes(state, wrongTopics);
    if (score >= 80) {
      final examId = 'exam:$levelNumber';
      if (!s.passedExams.contains(examId)) {
        s = _inc(s, Counters.examsPassed);
        s = _addXp(s, 100);
        s = s.copyWith(passedExams: {...s.passedExams, examId});
      }
      s = s.copyWith(
        unlockedLevels: {...s.unlockedLevels, levelNumber, levelNumber + 1},
      );
    }
    s = _addHistory(
      s,
      QuizRecord(
        id: 'exam:$levelNumber',
        title: title,
        score: score,
        date: dayKey(DateTime.now()),
        wrongTopics: wrongTopics,
      ),
    );
    _commit(s);
  }

  void completeProject(String projectId) {
    final key = 'project:$projectId';
    if (state.achievements.contains(key)) return;
    var s = _addXp(state, 80);
    s = _inc(s, Counters.projectsDone);
    _commit(s.copyWith(achievements: {...s.achievements, key}));
  }

  ProgressState _recordMistakes(ProgressState s, List<String> topics) {
    if (topics.isEmpty) return s;
    final m = {...s.mistakes};
    for (final t in topics) {
      if (t.isEmpty) continue;
      m[t] = (m[t] ?? 0) + 1;
    }
    return s.copyWith(mistakes: m);
  }

  ProgressState _addHistory(ProgressState s, QuizRecord r) {
    final h = [r, ...s.history];
    return s.copyWith(history: h.length > 60 ? h.sublist(0, 60) : h);
  }

  void consumeCelebrations() {
    if (state.celebrations.isEmpty) return;
    state = state.copyWith(celebrations: const []);
  }

  Future<void> resetAll() async {
    await ref.read(storeProvider).remove(_key);
    state = const ProgressState();
  }

  ProgressState _checkAchievements(ProgressState s) {
    final unlocked = <String>[];
    for (final a in achievementDefs) {
      if (!s.achievements.contains(a.id) && a.test(s)) unlocked.add(a.id);
    }
    if (unlocked.isEmpty) return s;
    var xpBonus = 0;
    for (final id in unlocked) {
      xpBonus += achievementDefs.firstWhere((a) => a.id == id).xp;
    }
    final next = _addXp(s, xpBonus);
    return next.copyWith(
      achievements: {...s.achievements, ...unlocked},
      celebrations: [...s.celebrations, ...unlocked],
    );
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);

// ───────────────────────── Yutuqlar ─────────────────────────

class AchievementDef {
  const AchievementDef(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.color,
    this.test, {
    this.xp = 20,
  });
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(ProgressState) test;
  final int xp;
}

bool _levelDone(ProgressState s, int n) {
  final lv = curriculum.where((l) => l.number == n);
  if (lv.isEmpty || lv.first.lessons.isEmpty) return false;
  return lv.first.lessons.every((l) => s.isCompleted(l.id));
}

bool _moduleDone(ProgressState s, String id) {
  for (final lv in curriculum) {
    for (final m in lv.modules) {
      if (m.id == id) {
        return m.lessons.isNotEmpty &&
            m.lessons.every((l) => s.isCompleted(l.id));
      }
    }
  }
  return false;
}

int _doneInLevel(ProgressState s, int n) {
  final lv = curriculum.where((l) => l.number == n);
  if (lv.isEmpty) return 0;
  return lv.first.lessons.where((l) => s.isCompleted(l.id)).length;
}

final achievementDefs = <AchievementDef>[
  AchievementDef(
    'first_code',
    'Birinchi kodim',
    'Birinchi marta kodni ishga tushirdingiz',
    Icons.play_arrow_rounded,
    const Color(0xFF087CF7),
    (s) => s.counter(Counters.codeRuns) >= 1,
    xp: 10,
  ),
  AchievementDef(
    'first_lesson',
    'Birinchi qadam',
    'Birinchi darsni tugatdingiz',
    Icons.flag_rounded,
    const Color(0xFF16A34A),
    (s) => s.completedCount >= 1,
  ),
  AchievementDef(
    'foundations',
    'Poydevor',
    'Noldan dasturlash darajasini tugatdingiz',
    Icons.foundation_rounded,
    const Color(0xFF14B8A6),
    (s) => _levelDone(s, 1),
    xp: 50,
  ),
  AchievementDef(
    'dart_beginner',
    'Dart boshlovchisi',
    'Dart asoslari darajasidan 3 ta dars',
    Icons.code_rounded,
    const Color(0xFF03B8E8),
    (s) => _doneInLevel(s, 3) >= 3,
    xp: 30,
  ),
  AchievementDef(
    'dart_basics',
    'Dart asoslari',
    'Dart asoslari darajasini to\'liq tugatdingiz',
    Icons.school_rounded,
    const Color(0xFF087CF7),
    (s) => _levelDone(s, 3),
    xp: 80,
  ),
  AchievementDef(
    'loop_master',
    'Sikl ustasi',
    'Boshqaruv oqimi va kolleksiyalar modulini tugatdingiz',
    Icons.loop_rounded,
    const Color(0xFF7C5CFF),
    (s) => _moduleDone(s, 'dart.control'),
    xp: 80,
  ),
  AchievementDef(
    'oop_architect',
    'OOP arxitektori',
    'Obyektga yo\'naltirilgan dasturlash modulini tugatdingiz',
    Icons.category_rounded,
    const Color(0xFFF97316),
    (s) => _moduleDone(s, 'dart.oop'),
    xp: 100,
  ),
  AchievementDef(
    'async_master',
    'Asinxron fikrlash',
    'Asinxron Dart modulini tugatdingiz: Future, event loop, Stream',
    Icons.hourglass_top_rounded,
    const Color(0xFF0891B2),
    (s) => _moduleDone(s, 'dart.async'),
    xp: 100,
  ),
  AchievementDef(
    'ten_practice',
    '10 ta amaliyot',
    '10 ta amaliy vazifani yechdingiz',
    Icons.fitness_center_rounded,
    const Color(0xFFEC4899),
    (s) => s.counter(Counters.tasksSolved) >= 10,
    xp: 40,
  ),
  AchievementDef(
    'bug_hunter',
    'Bug Hunter',
    '5 ta xatoli kodni tuzatdingiz',
    Icons.bug_report_rounded,
    const Color(0xFFEF4444),
    (s) => s.counter(Counters.bugsFixed) >= 5,
    xp: 40,
  ),
  AchievementDef(
    'testing_champion',
    'Testing Champion',
    '5 ta testni 100% bilan topshirdingiz',
    Icons.emoji_events_rounded,
    const Color(0xFFF59E0B),
    (s) => s.counter(Counters.perfectQuizzes) >= 5,
    xp: 50,
  ),
  AchievementDef(
    'widget_builder',
    'Widget Builder',
    'Widget laboratoriyasida 5 marta tajriba qildingiz',
    Icons.widgets_rounded,
    const Color(0xFF03B8E8),
    (s) => s.counter(Counters.labsUsed) >= 5,
    xp: 30,
  ),
  AchievementDef(
    'flutter_path',
    'Flutter Developer Path',
    'Birinchi Flutter darsini tugatdingiz',
    Icons.flutter_dash_rounded,
    const Color(0xFF0EA5E9),
    (s) => _doneInLevel(s, 5) >= 1,
    xp: 50,
  ),
  AchievementDef(
    'terminal_master',
    'Terminal ustasi',
    'Terminal laboratoriyasida 5 ta missiyani bajardingiz',
    Icons.terminal_rounded,
    const Color(0xFF0B1220),
    (s) => s.counter(Counters.terminalMissions) >= 5,
    xp: 40,
  ),
  AchievementDef(
    'visual_learner',
    'Ko\'z bilan ko\'rdim',
    'Kodni 5 marta qadam-baqadam vizualizatsiya qildingiz',
    Icons.visibility_rounded,
    const Color(0xFF6366F1),
    (s) => s.counter(Counters.visualizations) >= 5,
    xp: 20,
  ),
  AchievementDef(
    'project_creator',
    'Project Creator',
    'Birinchi amaliy loyihani yakunladingiz',
    Icons.rocket_launch_rounded,
    const Color(0xFF16A34A),
    (s) => s.counter(Counters.projectsDone) >= 1,
    xp: 60,
  ),
  AchievementDef(
    'streak_3',
    '3 kunlik seriya',
    '3 kun ketma-ket o\'rgandingiz',
    Icons.local_fire_department_rounded,
    const Color(0xFFF97316),
    (s) => s.streak >= 3,
    xp: 30,
  ),
  AchievementDef(
    'streak_7',
    'Haftalik seriya',
    '7 kun ketma-ket o\'rgandingiz',
    Icons.whatshot_rounded,
    const Color(0xFFEF4444),
    (s) => s.streak >= 7,
    xp: 80,
  ),
  AchievementDef(
    'reviewer',
    'Xotira kuchi',
    '5 marta takrorlash testini topshirdingiz',
    Icons.psychology_rounded,
    const Color(0xFF7C5CFF),
    (s) => s.counter(Counters.reviewsDone) >= 5,
    xp: 30,
  ),
  AchievementDef(
    'xp_1000',
    '1000 XP',
    '1000 tajriba balliga yetdingiz',
    Icons.star_rounded,
    const Color(0xFFF59E0B),
    (s) => s.xp >= 1000,
    xp: 0,
  ),
];

AchievementDef? achievementById(String id) {
  for (final a in achievementDefs) {
    if (a.id == id) return a;
  }
  return null;
}
