import 'package:kitob_dart/kitob_dart.dart';

import 'runner_web.dart' if (dart.library.io) 'runner_io.dart' as platform;

/// Bajarilish holatini boshqarish: ishga tushirish va to'xtatish.
class CodeRunner {
  platform.PlatformRun? _active;

  bool get isRunning => _active != null;

  /// Kodni fon rejimida bajaradi (mobil/desktop — alohida isolate; web — asosiy oqim).
  Future<ExecutionResult> run(String code, {ExecutionOptions options = const ExecutionOptions()}) async {
    _active?.cancel();
    final job = platform.PlatformRun(code, platform.adjustOptions(options));
    _active = job;
    try {
      return await job.result;
    } finally {
      if (identical(_active, job)) _active = null;
    }
  }

  /// Bajarilayotgan dasturni to'xtatadi.
  void stop() {
    _active?.cancel();
    _active = null;
  }
}

/// Og'ir hisob-kitobni (baholash) fon rejimida bajaradi.
///
/// [fn] — top-level yoki static funksiya bo'lishi kerak: closure widget
/// holatini ushlab qolsa, uni isolate'ga yuborib bo'lmaydi.
Future<R> computeHeavy<A, R>(R Function(A) fn, A arg) => platform.computeHeavy(fn, arg);

/// Foydalanuvchi to'xtatganda qaytariladigan natija.
ExecutionResult stoppedResult() => const ExecutionResult(
  stdout: '',
  diagnostics: [],
  error: RuntimeErrorInfo(
    type: 'stopped',
    message: 'Stopped by user',
    explanation: 'Dastur siz tomoningizdan to\'xtatildi.',
    line: 1,
    column: 1,
  ),
);
