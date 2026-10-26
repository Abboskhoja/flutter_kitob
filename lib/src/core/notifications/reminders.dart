import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../content/model.dart';
import '../design_system/tokens.dart';
import '../state/progress.dart';
import '../state/settings.dart';

/// Rejalashtirilgan bitta eslatma.
@immutable
class PlannedReminder {
  const PlannedReminder({required this.id, required this.at, required this.title, required this.body, required this.route});
  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Bosilganda ochiladigan sahifa.
  final String route;

  @override
  String toString() => 'PlannedReminder($id, $at, $title)';
}

/// O'quvchi qaytmasa, eslatmalar shu kunlarda keladi, keyin to'xtaydi —
/// ilovani ochmagan odamni cheksiz bezovta qilmaymiz.
const reminderDayOffsets = [0, 1, 2, 3, 5, 7, 14];

/// Eslatmalar rejasini tuzadi. Sof funksiya: platformaga bog'liq emas, testlanadi.
///
/// Reja har safar ilova ochilganda yoki XP olinganda qayta tuziladi. Shuning
/// uchun faol o'quvchi faqat bugungi/ertangi eslatmani oladi, ilovani tashlab
/// qo'ygan o'quvchi esa asta-sekin siyraklashadigan eslatmalarni.
List<PlannedReminder> planReminders({
  required DateTime now,
  required ProgressState progress,
  required AppSettings settings,
  Lesson? next,
}) {
  if (!settings.remindersOn) return const [];
  final today = DateTime(now.year, now.month, now.day);
  final todayXp = progress.xpOn(now);
  final goal = settings.dailyGoalXp;
  final streak = progress.streakAt(now);
  final route = next == null ? '/home' : '/learn/lesson/${next.id}';
  final lessonLine = next == null ? 'Kod maydonida kichik dastur yozib ko\'ring.' : '«${next.title}» — ${next.minutes} daqiqalik dars.';

  final out = <PlannedReminder>[];
  for (final d in reminderDayOffsets) {
    final day = today.add(Duration(days: d));
    final at = DateTime(day.year, day.month, day.day, settings.reminderMinutes ~/ 60, settings.reminderMinutes % 60);
    if (!at.isAfter(now)) continue;

    final (String title, String body, String to) = switch (d) {
      0 when goal > 0 && todayXp >= goal => ('', '', ''),
      0 when streak > 0 && todayXp == 0 => ('🔥 $streak kunlik seriyangiz xavf ostida', 'Bugun 5 daqiqa ajrating — seriya saqlanib qoladi.', route),
      0 when todayXp > 0 => ('Kunlik maqsadgacha ${goal - todayXp} XP qoldi', 'Bitta qisqa mashq yetarli. Davom etamizmi?', route),
      0 => ('Bugungi dars sizni kutmoqda', lessonLine, route),
      // Bugun XP bo'lsa, ertaga seriya hali tirik.
      1 when todayXp > 0 => ('🔥 Seriyani ${streak + 1} kunga yetkazing', lessonLine, route),
      1 => ('Kichik qadam — katta natija', lessonLine, route),
      2 => ('Bir daqiqaga qaytasizmi?', 'Har kuni ozgina o\'rganish bir kunda ko\'p o\'rganishdan samaraliroq.', route),
      3 => ('Sizni sog\'indik 👋', next == null ? 'To\'xtagan joyingizdan davom eting.' : '«${next.title}» to\'xtagan joyingizdan davom etadi.', route),
      5 => ('Bilim takrorlashni yaxshi ko\'radi', 'Qisqa takrorlash testi o\'rganganlaringizni mustahkamlaydi.', '/tests'),
      7 => ('Bir haftadan beri ko\'rinmadingiz', 'Davom etish uchun hech qachon kech emas — bitta dars bilan boshlang.', route),
      _ => ('Flutter dasturchi bo\'lish yo\'lingiz davom etadi', 'Siz uchun keyingi dars tayyor turibdi.', route),
    };
    if (title.isEmpty) continue;
    out.add(PlannedReminder(id: 100 + d, at: at, title: title, body: body, route: to));
  }
  return out;
}

/// Mahalliy bildirishnomalar (Android va iOS). Server talab qilinmaydi,
/// internetsiz ham ishlaydi. Boshqa platformalarda hech narsa qilmaydi.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Testlar xostda (macOS) ishlaydi — u yerda plagin yo'q, xizmat o'chiq.
  static bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static const _channelId = 'study_reminders';

  /// [onOpen] — eslatma bosilganda ochiladigan yo'l bilan chaqiriladi.
  /// Ilova eslatma orqali ochilgan bo'lsa, o'sha yo'lni qaytaradi.
  Future<String?> init({required ValueChanged<String> onOpen}) async {
    if (!supported || _ready) return null;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Noma'lum zona: UTC bilan ishlaymiz, eslatma vaqti biroz siljishi mumkin.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_kitob'),
        // Ruxsat ilova ochilishi bilan emas, o'quvchi o'zi rozi bo'lganda so'raladi.
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.startsWith('/')) onOpen(p);
      },
    );
    _ready = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final p = launch?.notificationResponse?.payload;
    return (launch?.didNotificationLaunchApp ?? false) && p != null && p.startsWith('/') ? p : null;
  }

  /// Tizim ruxsatini so'raydi. Qaytaradi: ruxsat berildimi.
  Future<bool> requestPermission() async {
    if (!supported) return false;
    if (Platform.isAndroid) {
      final a = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await a?.requestNotificationsPermission() ?? false;
    }
    final i = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await i?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  /// Avvalgi rejani bekor qilib, yangisini o'rnatadi.
  Future<void> apply(List<PlannedReminder> plan) async {
    if (!_ready) return;
    for (final d in reminderDayOffsets) {
      await _plugin.cancel(id: 100 + d);
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'O\'qish eslatmalari',
        channelDescription: 'Kunlik dars, seriya va takrorlash haqida eslatmalar',
        icon: 'ic_stat_kitob',
        color: KColors.primary,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (final r in plan) {
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: details,
        // Aniq vaqtli signal ruxsati (exact alarm) so'ralmaydi — Play siyosatiga mos.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body,
        payload: r.route,
      );
    }
  }
}
