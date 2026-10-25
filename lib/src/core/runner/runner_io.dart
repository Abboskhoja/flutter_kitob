import 'dart:async';
import 'dart:isolate';

import 'package:kitob_dart/kitob_dart.dart';

import 'runner.dart' show stoppedResult;

ExecutionOptions adjustOptions(ExecutionOptions o) => o;

class PlatformRun {
  PlatformRun(String code, ExecutionOptions options) {
    _start(code, options);
  }

  final _completer = Completer<ExecutionResult>();
  Isolate? _isolate;
  ReceivePort? _port;
  bool _cancelled = false;

  Future<ExecutionResult> get result => _completer.future;

  Future<void> _start(String code, ExecutionOptions options) async {
    final port = ReceivePort();
    _port = port;
    try {
      _isolate = await Isolate.spawn(_entry, [port.sendPort, code, options.toJson()], errorsAreFatal: true);
      if (_cancelled) {
        _isolate?.kill(priority: Isolate.immediate);
        return;
      }
      final msg = await port.first;
      if (!_completer.isCompleted) {
        _completer.complete(ExecutionResult.fromJson((msg as Map).cast<String, Object?>()));
      }
    } catch (e) {
      if (!_completer.isCompleted) {
        // Isolate yaratib bo'lmasa — asosiy oqimda bajaramiz.
        _completer.complete(KitobDart.run(code, options: options));
      }
    } finally {
      port.close();
      _isolate = null;
    }
  }

  static void _entry(List<Object?> args) {
    final send = args[0] as SendPort;
    final result = KitobDart.run(args[1] as String, options: ExecutionOptions.fromJson((args[2] as Map).cast<String, Object?>()));
    send.send(result.toJson());
  }

  void cancel() {
    _cancelled = true;
    _isolate?.kill(priority: Isolate.immediate);
    _port?.close();
    if (!_completer.isCompleted) _completer.complete(stoppedResult());
  }
}

Future<R> computeHeavy<A, R>(R Function(A) fn, A arg) => Isolate.run(() => fn(arg));
