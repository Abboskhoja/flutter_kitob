import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/reminders.dart';
import '../core/state/progress.dart';
import '../core/state/settings.dart';
import 'router.dart';

/// Eslatmalar rejasini doim dolzarb saqlaydi: ilova ochilganda, fonga
/// o'tib qaytganda, XP olinganda va sozlamalar o'zgarganda qayta tuziladi.
class RemindersHost extends ConsumerStatefulWidget {
  const RemindersHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<RemindersHost> createState() => _RemindersHostState();
}

class _RemindersHostState extends ConsumerState<RemindersHost> with WidgetsBindingObserver {
  Timer? _debounce;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (!ReminderService.supported) return;
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() async {
    final launchRoute = await ReminderService.instance.init(onOpen: _open);
    if (!mounted) return;
    _ready = true;
    if (launchRoute != null) _open(launchRoute);
    await _reschedule();
  }

  void _open(String route) {
    if (!ref.read(settingsProvider).onboardingDone) return;
    ref.read(routerProvider).go(route);
  }

  Future<void> _reschedule() async {
    if (!_ready || !mounted) return;
    final plan = planReminders(
      now: DateTime.now(),
      progress: ref.read(progressProvider),
      settings: ref.read(settingsProvider),
      next: ref.read(progressProvider.notifier).continueLesson(),
    );
    await ReminderService.instance.apply(plan);
  }

  void _schedule() {
    if (!_ready) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _reschedule);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Fonga o'tishda ham yangilaymiz: shu sessiyadagi XP hisobga olinsin.
    if (state == AppLifecycleState.resumed || state == AppLifecycleState.paused) _reschedule();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ReminderService.supported) {
      ref.listen(progressProvider.select((p) => p.xp), (_, _) => _schedule());
      ref.listen(settingsProvider.select((s) => (s.remindersOn, s.reminderMinutes, s.dailyGoalXp)), (_, _) => _schedule());
    }
    return widget.child;
  }
}
