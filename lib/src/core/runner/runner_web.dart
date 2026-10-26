import 'dart:async';

import 'package:kitob_dart/kitob_dart.dart';

import 'runner.dart' show stoppedResult;

/// Web runner sinxron ishlaydi, shuning uchun kod asosiy oqimda qat'iy limit bilan bajariladi.
const _webMaxSteps = 500000;
const _webTimeout = Duration(seconds: 1);

ExecutionOptions adjustOptions(ExecutionOptions o) => ExecutionOptions(
  maxSteps: o.maxSteps > _webMaxSteps ? _webMaxSteps : o.maxSteps,
  timeout: o.timeout > _webTimeout ? _webTimeout : o.timeout,
  trace: o.trace,
  maxTraceSteps: o.maxTraceSteps,
  stdin: o.stdin,
  maxOutputChars: o.maxOutputChars,
  maxCallDepth: o.maxCallDepth > 200 ? 200 : o.maxCallDepth,
  randomSeed: o.randomSeed,
);

class PlatformRun {
  PlatformRun(String code, ExecutionOptions options) {
    // UI "bajarilmoqda" holatini chizib olishi uchun bir kadr kutamiz.
    Timer(const Duration(milliseconds: 16), () {
      if (_completer.isCompleted) return;
      _completer.complete(KitobDart.run(code, options: options));
    });
  }

  final _completer = Completer<ExecutionResult>();
  Future<ExecutionResult> get result => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete(stoppedResult());
  }
}

// Yield one frame before CPU work; this is not a background isolate on Web.
Future<R> computeHeavy<A, R>(R Function(A) fn, A arg) => Future.delayed(const Duration(milliseconds: 16), () => fn(arg));
