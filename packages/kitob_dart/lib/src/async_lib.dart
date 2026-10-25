part of 'interpreter.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Asinxron Dart: Future, async/await, Timer, Stream, async* va sync*.
//
// Semantika Dart VM'dagi kabi (sdk/lib/async va vm/lib/async_patch.dart):
//  * microtask navbati timer'lardan oldin to'liq bo'shatiladi;
//  * har bir timer'dan keyin microtask'lar yana bo'shatiladi;
//  * tugallanmagan Future'ga ulangan tinglovchilar u tugaganda sinxron chaqiriladi,
//    allaqachon tugagan Future'ga ulangan tinglovchi esa microtask orqali;
//  * vaqt virtual: `Future.delayed(Duration(seconds: 2))` haqiqatda kutmaydi,
//    lekin tartib va `DateTime.now()` xuddi 2 soniya o'tgandek ishlaydi.
// ═══════════════════════════════════════════════════════════════════════════

/// Dart `Future` qiymati.
class KFuture {
  KFuture(this.typeArg);
  final String typeArg;

  /// 0 — kutilmoqda, 1 — qiymat bilan tugadi, 2 — xato bilan tugadi.
  int _state = 0;
  Object? value;
  DartThrow? error;
  List<void Function(KFuture)>? _listeners = [];

  bool get isDone => _state != 0;
  bool get hasError => _state == 2;
}

class KCompleter {
  KCompleter(this.future);
  final KFuture future;
  bool isCompleted = false;
}

class KTimer {
  KTimer(this.due, this.period, this.callback, this.seq);
  int due;
  final int? period;
  final Object? callback;
  int seq;
  bool isActive = true;
  int tick = 0;
}

class _StreamEvent {
  const _StreamEvent.data(this.value) : kind = 0, error = null;
  const _StreamEvent.error(this.error) : kind = 1, value = null;
  const _StreamEvent.done() : kind = 2, value = null, error = null;
  final int kind;
  final Object? value;
  final DartThrow? error;
}

/// `StreamSubscription`: hodisalarni tinglovchiga yetkazadi.
class KSubscription {
  KSubscription(this.typeArg);
  final String typeArg;
  void Function(Object?) onData = (_) {};
  void Function(DartThrow)? onError;
  void Function() onDone = () {};

  /// Manba uchun: done hodisasi yetkazilgandan keyin (masalan `controller.done` Future'ini tugatish).
  final List<void Function()> afterDone = [];
  bool cancelOnError = false;

  final ListQueue<_StreamEvent> _pending = ListQueue();
  bool _scheduled = false;
  bool _inCallback = false;
  bool canceled = false;
  bool done = false;
  int pauseCount = 0;

  // Manba (producer) tomonidan o'rnatiladi.
  void Function()? onPauseHook;
  void Function()? onResumeHook;
  KFuture? Function()? onCancelHook;

  bool get isPaused => pauseCount > 0;
}

/// Dart `Stream` qiymati. [_onListen] har bir obunada manbani ishga tushiradi.
class KStream {
  KStream(this.typeArg, this._onListen, {this.isBroadcast = false});
  final String typeArg;
  final bool isBroadcast;
  final void Function(KSubscription) _onListen;
  bool listened = false;
}

/// `StreamController`.
class KStreamController {
  KStreamController(this.typeArg, {this.isSync = false, this.isBroadcast = false});
  final String typeArg;
  final bool isSync;
  final bool isBroadcast;
  late final KStream stream;
  KSubscription? sub;
  final List<KSubscription> subs = [];
  final List<_StreamEvent> buffer = [];
  bool isClosed = false;
  KFuture? doneFuture;

  // O'quvchi callback'lari (onListen: () {...}).
  Object? onListen;
  Object? onCancel;
  Object? onPause;
  Object? onResume;

  // Ichki callback'lar (async* uchun).
  void Function()? nOnListen;
  void Function()? nOnResume;
  KFuture? Function()? nOnCancel;

  bool get hasListener => isBroadcast ? subs.isNotEmpty : (sub != null && !sub!.canceled && !sub!.done);
  bool get isPaused => isBroadcast ? false : (sub?.isPaused ?? !hasListener);
}

/// `controller.sink`.
class KStreamSink {
  KStreamSink(this.controller);
  final KStreamController controller;
}

/// `sync*` funksiya qaytaradigan dangasa (lazy) Iterable.
class KSyncStarIterable extends Iterable<Object?> {
  KSyncStarIterable(this._interp, this._fn, this._env, this.typeArg);
  final Interpreter _interp;
  final KFunction _fn;
  final Env _env;
  final String typeArg;

  @override
  Iterator<Object?> get iterator => _SyncStarIterator(_interp, _fn, _interp._copyEnv(_env));
}

class _SyncStarIterator implements Iterator<Object?> {
  _SyncStarIterator(this._interp, this._fn, Env env) : _body = _interp._bodyG(_fn, env, _Box()).iterator;
  final Interpreter _interp;
  final KFunction _fn;
  final Iterator<_Pause> _body;
  Iterator<Object?>? _inner;
  Object? _current;
  bool _finished = false;

  @override
  Object? get current => _current;

  @override
  bool moveNext() {
    if (_finished) return false;
    final i = _interp;
    i._callStack.add(_fn.name.isEmpty ? '<closure>' : _fn.name);
    i._depth++;
    try {
      while (true) {
        final inner = _inner;
        if (inner != null) {
          if (inner.moveNext()) {
            _current = inner.current;
            return true;
          }
          _inner = null;
        }
        if (!_body.moveNext()) {
          _finished = true;
          _current = null;
          return false;
        }
        final p = _body.current;
        if (p is _YieldPoint) {
          if (p.isStar) {
            _inner = i._iterableOf(p.value, p.offset, 'yield*').iterator;
            continue;
          }
          _current = p.value;
          return true;
        }
        throw ExecutionAbort('await_in_sync_star', "`sync*` generator ichida `await` ishlatib bo'lmaydi.",
            "The 'await' expression can only be used in an async function.", (p as _AwaitPoint).offset);
      }
    } catch (_) {
      _finished = true;
      rethrow;
    } finally {
      i._depth--;
      i._callStack.removeLast();
    }
  }
}

// ───────────── Generator ichki mexanizmi ─────────────

/// Generator (async funksiya tanasi) to'xtagan nuqta.
sealed class _Pause {}

class _AwaitPoint extends _Pause {
  _AwaitPoint(this.future, this.offset);
  final KFuture future;
  final int offset;
  KFuture? result;
}

class _YieldPoint extends _Pause {
  _YieldPoint(this.value, this.isStar, this.offset);
  final Object? value;
  final bool isStar;
  final int offset;
  bool cancelled = false;
}

class _Box {
  Object? value;
}

/// async* oqimi bekor qilinganda generator tanasini (finally'lar bilan) tugatadi.
class _GeneratorCancel implements Exception {}

/// Ushlanmagan asinxron xato — dasturni to'xtatadi (o'quvchi `catch`i ushlamaydi).
class UncaughtAsyncError implements Exception {
  UncaughtAsyncError(this.error);
  final DartThrow error;
}

class _AsyncFrame {
  _AsyncFrame(this.name, this.result, this.out, this.fn);
  final String name;
  final KFuture result;
  final _Box out;
  final KFunction fn;
  late Iterator<_Pause> it;
  bool suspended = false;
}

class _AsyncStarFrame {
  _AsyncStarFrame(this.name, this.controller);
  final String name;
  final KStreamController controller;
  late Iterator<_Pause> it;
  bool scheduled = false;
  bool suspendedAtYield = false;
  bool adding = false;
  bool cancelRequested = false;
  KFuture? cancelFuture;
}

/// `await for` uchun: Dart'ning `_StreamIterator`i bilan bir xil.
class _KStreamIterator {
  _KStreamIterator(this.stream);
  KStream? stream;
  KSubscription? subscription;
  KFuture? _future;
  Object? current;
  bool hasValue = false;
}

const dartAsyncNames = {
  'Completer', 'Timer', 'StreamController', 'StreamSubscription', 'StreamSink', 'scheduleMicrotask', 'unawaited',
  'TimeoutException', 'StreamIterator',
};

extension _AsyncRuntime on Interpreter {
  // ───────────── Event loop ─────────────

  void _microtask(void Function() fn) => _microtasks.add(fn);

  KTimer _addTimer(int micros, int? period, Object? callback) {
    final t = KTimer(_now + (micros < 0 ? 0 : micros), period, callback, _timerSeq++);
    _timers.add(t);
    return t;
  }

  void _drainMicrotasks() {
    while (_microtasks.isNotEmpty) {
      _tick(_lastUserOffset);
      _microtasks.removeFirst()();
    }
  }

  /// Vaqtni [micros] gacha suradi: vaqti kelgan timer'larni bajaradi.
  /// Keyingi timer'gacha qolgan vaqtni (mikrosekund) qaytaradi, timer qolmagan bo'lsa null.
  int? advanceTo(int micros) {
    _drainMicrotasks();
    while (true) {
      KTimer? next;
      for (final t in _timers) {
        if (!t.isActive) continue;
        if (next == null || t.due < next.due || t.due == next.due && t.seq < next.seq) next = t;
      }
      _timers.removeWhere((t) => !t.isActive);
      if (next == null) {
        if (micros > _now) _now = micros;
        return null;
      }
      if (next.due > micros) {
        if (micros > _now) _now = micros;
        return next.due - _now;
      }
      _now = next.due;
      _fireTimer(next);
      _drainMicrotasks();
    }
  }

  void _fireTimer(KTimer next) {
    _tick(_lastUserOffset);
    if (next.period != null) {
      next.tick++;
      next.due = _now + (next.period! < 1 ? 1 : next.period!);
      next.seq = _timerSeq++;
      _callValue(next.callback, [next], const {}, _lastUserOffset);
    } else {
      next.isActive = false;
      _callValue(next.callback, const [], const {}, _lastUserOffset);
    }
  }

  /// Barcha microtask va timer'lar tugaguncha aylanadi (Dart VM kabi).
  void runEventLoop() {
    _drainMicrotasks();
    var fired = 0;
    while (true) {
      KTimer? next;
      for (final t in _timers) {
        if (!t.isActive) continue;
        if (next == null || t.due < next.due || t.due == next.due && t.seq < next.seq) next = t;
      }
      _timers.removeWhere((t) => !t.isActive);
      if (next == null) break;
      if (++fired > 200000) {
        throw ExecutionAbort('timer_limit', "Timer'lar juda ko'p marta ishga tushdi. Ehtimol `Timer.periodic` hech qachon to'xtatilmagan.",
            'Too many timer events.', _lastUserOffset,
            hint: "Davriy timer'ni kerakli paytda `timer.cancel();` bilan to'xtating.");
      }
      _now = next.due;
      _fireTimer(next);
      _drainMicrotasks();
    }
  }

  // ───────────── Future yadrosi ─────────────

  void _listen(KFuture f, void Function(KFuture) l) {
    if (f.isDone) {
      _microtask(() => l(f));
    } else {
      f._listeners!.add(l);
    }
  }

  void _propagate(KFuture f) {
    final ls = f._listeners!;
    f._listeners = null;
    if (ls.isEmpty && f.hasError) throw UncaughtAsyncError(f.error!);
    for (final l in ls) {
      l(f);
    }
  }

  void _completeValue(KFuture f, Object? v) {
    if (f.isDone) return;
    if (v is KFuture) {
      _chain(f, v);
      return;
    }
    f
      .._state = 1
      ..value = v;
    _propagate(f);
  }

  void _completeError(KFuture f, DartThrow e) {
    if (f.isDone) return;
    f
      .._state = 2
      ..error = e;
    _propagate(f);
  }

  void _copyResult(KFuture target, KFuture source) =>
      source.hasError ? _completeError(target, source.error!) : _completeValue(target, source.value);

  /// [target] [source] bilan bir xil natijada tugaydi.
  void _chain(KFuture target, KFuture source) {
    if (source.isDone) {
      _copyResult(target, source);
    } else {
      source._listeners!.add((s) => _copyResult(target, s));
    }
  }

  void _asyncComplete(KFuture f, Object? v) {
    if (v is KFuture) {
      _listen(v, (s) => _copyResult(f, s));
      return;
    }
    _microtask(() => _completeValue(f, v));
  }

  void _asyncCompleteError(KFuture f, DartThrow e) => _microtask(() => _completeError(f, e));

  KFuture _valueFuture(Object? v, [String? type]) {
    final f = KFuture(type ?? typeName(v));
    _asyncComplete(f, v);
    return f;
  }

  DartThrow _asThrow(Object? error, int offset) =>
      error is DartThrow ? error : DartThrow(error, offset, List.of(_callStack.reversed));

  /// Callback natijasi bilan [result] ni tugatadi (Future qaytsa — zanjir).
  void _runInto(KFuture result, Object? Function() body) {
    try {
      final v = body();
      if (v is KFuture) {
        _chain(result, v);
      } else {
        _completeValue(result, v);
      }
    } on DartThrow catch (e) {
      _completeError(result, e);
    }
  }

  Object? _callErrorHandler(Object? handler, DartThrow e, int offset) {
    final arity = handler is KFunction ? handler.params.where((p) => !p.isNamed).length : 1;
    final stack = e.stack.map((f) => '#  $f').join('\n');
    return _callValue(handler, arity >= 2 ? [e.value, stack] : [e.value], const {}, offset);
  }

  String _futureTypeArg(TypeAnnotation? t) {
    if (t == null) return 'dynamic';
    if ((t.name == 'Future' || t.name == 'Stream' || t.name == 'Iterable') && t.args.isNotEmpty) return t.args.first.toString();
    return 'dynamic';
  }

  // ───────────── async / async* / sync* funksiyalarni boshlash ─────────────

  Object? _startAsyncBody(KFunction f, Env env) {
    final name = f.name.isEmpty ? '<closure>' : f.name;
    if (f.isGenerator && !f.isAsync) return KSyncStarIterable(this, f, env, _futureTypeArg(f.returnType));
    if (f.isGenerator) return _startAsyncStar(f, env, name);
    final frame = _AsyncFrame(name, KFuture(_futureTypeArg(f.returnType)), _Box(), f);
    frame.it = _bodyG(f, env, frame.out).iterator;
    _stepAsync(frame, push: false);
    return frame.result;
  }

  void _stepAsync(_AsyncFrame fr, {bool push = true}) {
    if (push) {
      _callStack.add(fr.name);
      _depth++;
    }
    try {
      if (fr.it.moveNext()) {
        final p = fr.it.current;
        if (p is! _AwaitPoint) {
          throw ExecutionAbort('yield_in_async', "`yield` faqat generator (`sync*` yoki `async*`) funksiyada ishlatiladi.",
              "Yield statements must be in a generator function.", (p as _YieldPoint).offset);
        }
        fr.suspended = true;
        _listen(p.future, (src) {
          p.result = src;
          _stepAsync(fr);
        });
        return;
      }
      var v = fr.out.value;
      final rt = fr.fn.returnType;
      if (rt != null && rt.name == 'Future' && rt.args.isNotEmpty && v is! KFuture && rt.args.first.name != 'void') {
        v = _coerce(v, rt.args.first, _lastUserOffset, '${fr.name} return');
      }
      if (v is KFuture) {
        _asyncComplete(fr.result, v);
      } else {
        _completeValue(fr.result, v);
      }
    } on DartThrow catch (e) {
      fr.suspended ? _completeError(fr.result, e) : _asyncCompleteError(fr.result, e);
    } finally {
      if (push) {
        _depth--;
        _callStack.removeLast();
      }
    }
  }

  KStream _startAsyncStar(KFunction f, Env env, String name) {
    final ctrl = _newController(_futureTypeArg(f.returnType), isSync: true);
    final fr = _AsyncStarFrame(name, ctrl);
    fr.it = _bodyG(f, env, _Box()).iterator;
    ctrl.nOnListen = () => _scheduleGenerator(fr);
    ctrl.nOnResume = () {
      if (fr.suspendedAtYield) _scheduleGenerator(fr);
    };
    ctrl.nOnCancel = () {
      if (ctrl.isClosed) return null;
      if (fr.cancelFuture == null) {
        fr.cancelFuture = KFuture('void');
        fr.cancelRequested = true;
        if (fr.suspendedAtYield) _scheduleGenerator(fr);
      }
      return fr.cancelFuture;
    };
    return ctrl.stream;
  }

  void _scheduleGenerator(_AsyncStarFrame fr) {
    if (fr.scheduled || fr.controller.isPaused || fr.adding) return;
    fr.scheduled = true;
    _microtask(() {
      fr.scheduled = false;
      fr.suspendedAtYield = false;
      _stepAsyncStar(fr);
    });
  }

  void _stepAsyncStar(_AsyncStarFrame fr) {
    final ctrl = fr.controller;
    _callStack.add(fr.name);
    _depth++;
    try {
      while (true) {
        if (!fr.it.moveNext()) {
          _closeGenerator(fr);
          return;
        }
        final p = fr.it.current;
        if (p is _AwaitPoint) {
          _listen(p.future, (src) {
            p.result = src;
            _stepAsyncStar(fr);
          });
          return;
        }
        p as _YieldPoint;
        if (p.isStar) {
          final inner = p.value;
          if (inner is! KStream) {
            _typeError("type '${typeName(inner)}' is not a subtype of type 'Stream<dynamic>' (yield*)", p.offset);
          }
          if (!ctrl.hasListener) {
            p.cancelled = true;
            continue;
          }
          fr.adding = true;
          _subscribe(inner, (v) => _controllerAdd(ctrl, v, p.offset), onError: (e) => _controllerAddError(ctrl, e),
              onDone: () {
            fr.adding = false;
            _scheduleGenerator(fr);
            if (!fr.scheduled) fr.suspendedAtYield = true;
          });
          return;
        }
        _controllerAdd(ctrl, p.value, p.offset);
        if (!ctrl.hasListener) {
          p.cancelled = true;
          continue;
        }
        _scheduleGenerator(fr);
        fr.suspendedAtYield = true;
        p.cancelled = fr.cancelRequested;
        return;
      }
    } on _GeneratorCancel {
      _closeGenerator(fr);
    } on DartThrow catch (e) {
      final cf = fr.cancelFuture;
      if (cf != null && !cf.isDone) {
        _completeError(cf, e);
      } else if (ctrl.hasListener) {
        _controllerAddError(ctrl, e);
      }
      _closeGenerator(fr);
    } finally {
      _depth--;
      _callStack.removeLast();
    }
  }

  void _closeGenerator(_AsyncStarFrame fr) {
    final cf = fr.cancelFuture;
    if (cf != null && !cf.isDone) _completeValue(cf, null);
    if (!fr.controller.isClosed) _controllerClose(fr.controller);
  }

  // ───────────── Stream yadrosi ─────────────

  void _emit(KSubscription sub, _StreamEvent ev, {required bool sync}) {
    if (sub.canceled || sub.done) return;
    if (sync && sub._pending.isEmpty && !sub.isPaused && !sub._inCallback) {
      _deliver(sub, ev);
    } else {
      sub._pending.add(ev);
      _scheduleSub(sub);
    }
  }

  void _scheduleSub(KSubscription sub) {
    if (sub._scheduled || sub._pending.isEmpty || sub.isPaused || sub.canceled) return;
    sub._scheduled = true;
    _microtask(() {
      sub._scheduled = false;
      if (sub.canceled || sub.isPaused || sub._pending.isEmpty) return;
      _deliver(sub, sub._pending.removeFirst());
    });
  }

  void _deliver(KSubscription sub, _StreamEvent ev) {
    sub._inCallback = true;
    try {
      switch (ev.kind) {
        case 0:
          sub.onData(ev.value);
        case 1:
          if (sub.cancelOnError) {
            sub.canceled = true;
            sub._pending.clear();
            sub.onCancelHook?.call();
          }
          final h = sub.onError;
          if (h == null) throw UncaughtAsyncError(ev.error!);
          h(ev.error!);
        default:
          sub.done = true;
          sub._pending.clear();
          sub.onDone();
          for (final f in sub.afterDone) {
            f();
          }
      }
    } finally {
      sub._inCallback = false;
    }
    _scheduleSub(sub);
  }

  /// Ichki (native) obuna.
  KSubscription _subscribe(KStream s, void Function(Object?) onData,
      {void Function(DartThrow)? onError, void Function()? onDone, bool cancelOnError = false}) {
    if (!s.isBroadcast && s.listened) {
      _throwDart('StateError', ['Stream has already been listened to.'], _lastUserOffset);
    }
    s.listened = true;
    final sub = KSubscription(s.typeArg)
      ..onData = onData
      ..onError = onError
      ..cancelOnError = cancelOnError;
    if (onDone != null) sub.onDone = onDone;
    s._onListen(sub);
    return sub;
  }

  /// O'quvchining `stream.listen(...)` chaqiruvi.
  KSubscription _userListen(KStream s, Object? onData, Map<String, Object?> named, int offset) {
    final onError = named['onError'];
    final onDone = named['onDone'];
    return _subscribe(
      s,
      (v) {
        if (onData != null) _callValue(onData, [v], const {}, offset);
      },
      onError: onError == null ? null : (e) => _callErrorHandler(onError, e, offset),
      onDone: onDone == null ? null : () => _callValue(onDone, const [], const {}, offset),
      cancelOnError: named['cancelOnError'] == true,
    );
  }

  KFuture _cancelSub(KSubscription sub) {
    if (sub.canceled || sub.done) return _nullFuture();
    sub.canceled = true;
    sub._pending.clear();
    return sub.onCancelHook?.call() ?? _nullFuture();
  }

  void _pauseSub(KSubscription sub) {
    if (sub.canceled) return;
    sub.pauseCount++;
    if (sub.pauseCount == 1) sub.onPauseHook?.call();
  }

  void _resumeSub(KSubscription sub) {
    if (sub.canceled || sub.pauseCount == 0) return;
    sub.pauseCount--;
    if (sub.pauseCount > 0) return;
    if (sub._pending.isNotEmpty) {
      _scheduleSub(sub);
    } else {
      sub.onResumeHook?.call();
    }
  }

  KFuture _nullFuture() => KFuture('void')
    .._state = 1
    .._listeners = null;

  KStreamController _newController(String typeArg, {bool isSync = false, bool isBroadcast = false}) {
    final c = KStreamController(typeArg, isSync: isSync, isBroadcast: isBroadcast);
    c.stream = KStream(typeArg, (sub) => _controllerListen(c, sub), isBroadcast: isBroadcast);
    return c;
  }

  void _controllerListen(KStreamController c, KSubscription sub) {
    if (c.isBroadcast) {
      if (c.isClosed) {
        _emit(sub, const _StreamEvent.done(), sync: false);
        return;
      }
      c.subs.add(sub);
      sub.onCancelHook = () {
        c.subs.remove(sub);
        if (c.subs.isEmpty && c.onCancel != null) _callValue(c.onCancel, const [], const {}, _lastUserOffset);
        return null;
      };
      if (c.subs.length == 1 && c.onListen != null) _callValue(c.onListen, const [], const {}, _lastUserOffset);
      return;
    }
    c.sub = sub;
    sub.onCancelHook = () {
      final r = c.nOnCancel?.call();
      if (c.onCancel != null) {
        final v = _callValue(c.onCancel, const [], const {}, _lastUserOffset);
        if (v is KFuture) return v;
      }
      return r;
    };
    sub.onPauseHook = () {
      if (c.onPause != null) _callValue(c.onPause, const [], const {}, _lastUserOffset);
    };
    sub.onResumeHook = () {
      c.nOnResume?.call();
      if (c.onResume != null) _callValue(c.onResume, const [], const {}, _lastUserOffset);
    };
    sub.afterDone.add(() {
      final df = c.doneFuture;
      if (df != null) _completeValue(df, null);
    });
    for (final ev in c.buffer) {
      sub._pending.add(ev);
    }
    c.buffer.clear();
    _scheduleSub(sub);
    c.nOnListen?.call();
    if (c.onListen != null) _callValue(c.onListen, const [], const {}, _lastUserOffset);
  }

  void _controllerEvent(KStreamController c, _StreamEvent ev) {
    if (c.isBroadcast) {
      for (final s in List.of(c.subs)) {
        _emit(s, ev, sync: c.isSync);
      }
      return;
    }
    final s = c.sub;
    if (s == null) {
      c.buffer.add(ev);
    } else {
      _emit(s, ev, sync: c.isSync);
    }
  }

  void _controllerAdd(KStreamController c, Object? v, int offset) {
    if (c.isClosed) _throwDart('StateError', ['Cannot add new events after calling close'], offset);
    _controllerEvent(c, _StreamEvent.data(v));
  }

  void _controllerAddError(KStreamController c, DartThrow e) {
    if (c.isClosed) _throwDart('StateError', ['Cannot add new events after calling close'], _lastUserOffset);
    _controllerEvent(c, _StreamEvent.error(e));
  }

  KFuture _controllerClose(KStreamController c) {
    final df = c.doneFuture ??= KFuture('void');
    if (c.isClosed) return df;
    c.isClosed = true;
    if (c.isBroadcast) {
      if (c.subs.isEmpty) {
        _asyncComplete(df, null);
      } else {
        final n = c.subs.length;
        var left = n;
        for (final s in List.of(c.subs)) {
          s.afterDone.add(() {
            if (--left == 0) _completeValue(df, null);
          });
        }
        _controllerEvent(c, const _StreamEvent.done());
      }
      return df;
    }
    _controllerEvent(c, const _StreamEvent.done());
    return df;
  }

  /// Oddiy manba: [events] ni har birini alohida microtask'da yuboradi.
  KStream _eventsStream(String type, List<_StreamEvent> events) => KStream(type, (sub) {
        for (final e in events) {
          _emit(sub, e, sync: false);
        }
      });

  KStream _fromIterable(Iterable<Object?> items, String type) => KStream(type, (sub) {
        final it = items.iterator;
        var scheduled = true;
        void next() {
          if (sub.canceled || sub.done || sub.isPaused) {
            scheduled = false;
            return;
          }
          bool has;
          try {
            has = it.moveNext();
          } on DartThrow catch (e) {
            _emit(sub, _StreamEvent.error(e), sync: true);
            _emit(sub, const _StreamEvent.done(), sync: true);
            return;
          }
          if (has) {
            _emit(sub, _StreamEvent.data(it.current), sync: true);
            if (!sub.canceled && !sub.isPaused) {
              _microtask(next);
            } else {
              scheduled = false;
            }
          } else {
            _emit(sub, const _StreamEvent.done(), sync: true);
          }
        }

        sub.onResumeHook = () {
          if (!scheduled) {
            scheduled = true;
            _microtask(next);
          }
        };
        _microtask(next);
      });

  KStream _periodic(int micros, Object? computation, String type, int offset) {
    late KStream s;
    s = KStream(type, (sub) {
      var count = 0;
      late KTimer timer;
      void fire(Object? _) {
        final v = computation == null ? null : _callValue(computation, [count], const {}, offset);
        count++;
        _emit(sub, _StreamEvent.data(v), sync: true);
      }

      timer = _addTimer(micros, micros, NativeFunction('periodic', (p, n) => fire(p.first)));
      sub.onCancelHook = () {
        timer.isActive = false;
        return null;
      };
      sub.onPauseHook = () => timer.isActive = false;
      sub.onResumeHook = () {
        timer = _addTimer(micros, micros, NativeFunction('periodic', (p, n) => fire(p.first)));
      };
    });
    return s;
  }

  /// `map`, `where`, `take` kabi oqim o'zgartirgichlari: manbaga obuna bo'lib, hodisani sinxron uzatadi.
  KStream _forward(KStream src, String type,
      void Function(KSubscription out, Object? v, KSubscription upstream) onData) => KStream(type, (out) {
        late KSubscription up;
        up = _subscribe(src, (v) {
          try {
            onData(out, v, up);
          } on DartThrow catch (e) {
            _emit(out, _StreamEvent.error(e), sync: true);
          }
        }, onError: (e) => _emit(out, _StreamEvent.error(e), sync: true), onDone: () => _emit(out, const _StreamEvent.done(), sync: true));
        out.onCancelHook = () => _cancelSub(up);
        out.onPauseHook = () => _pauseSub(up);
        out.onResumeHook = () => _resumeSub(up);
      }, isBroadcast: src.isBroadcast);

  /// `toList`, `first`, `forEach` kabi Future qaytaruvchi amallar.
  KFuture _streamFuture(KStream s, String type, void Function(KFuture result, Object? v, KSubscription sub) onData,
      Object? Function() onDone) {
    final result = KFuture(type);
    late KSubscription sub;
    sub = _subscribe(s, (v) {
      try {
        onData(result, v, sub);
      } on DartThrow catch (e) {
        _cancelSub(sub);
        _completeError(result, e);
      }
    }, onError: (e) => _completeError(result, e), onDone: () {
      try {
        _completeValue(result, onDone());
      } on DartThrow catch (e) {
        _completeError(result, e);
      }
    }, cancelOnError: true);
    return result;
  }

  // ───────────── Kutubxona: dart:core (Future, Stream) va dart:async ─────────────

  Object? _asyncStatic(String type, String name, List<Object?> p, Map<String, Object?> n, int offset, String? elem) {
    switch ('$type.$name') {
      case 'Future.value':
        return _valueFuture(p.isEmpty ? null : p[0], elem ?? (p.isEmpty ? 'dynamic' : typeName(p[0])));
      case 'Future.error':
        final f = KFuture(elem ?? 'dynamic');
        _asyncCompleteError(f, _asThrow(p[0], offset));
        return f;
      case 'Future.delayed':
        final f = KFuture(elem ?? 'dynamic');
        final d = _durationMicros(p[0], offset);
        final comp = p.length > 1 ? p[1] : null;
        _addTimer(d, null, NativeFunction('delayed', (_, _) {
          if (comp == null) {
            _completeValue(f, null);
          } else {
            _runInto(f, () => _callValue(comp, const [], const {}, offset));
          }
          return null;
        }));
        return f;
      case 'Future.microtask':
        final f = KFuture(elem ?? 'dynamic');
        _microtask(() => _runInto(f, () => _callValue(p[0], const [], const {}, offset)));
        return f;
      case 'Future.sync':
        try {
          final v = _callValue(p[0], const [], const {}, offset);
          return v is KFuture ? v : _valueFuture(v, elem);
        } on DartThrow catch (e) {
          final f = KFuture(elem ?? 'dynamic');
          _asyncCompleteError(f, e);
          return f;
        }
      case 'Future.wait':
        final futures = _iterableOf(p[0], offset, 'Future.wait').toList();
        final result = KFuture('List<${elem ?? 'dynamic'}>');
        final values = List<Object?>.filled(futures.length, null);
        if (futures.isEmpty) {
          _asyncComplete(result, _newList(const [], elem));
          return result;
        }
        var left = futures.length;
        DartThrow? firstError;
        for (var i = 0; i < futures.length; i++) {
          final fut = futures[i];
          if (fut is! KFuture) _typeError("type '${typeName(fut)}' is not a subtype of type 'Future<dynamic>' (Future.wait)", offset);
          final idx = i;
          _listen(fut, (s) {
            if (s.hasError) {
              firstError ??= s.error;
            } else {
              values[idx] = s.value;
            }
            if (--left == 0) {
              if (firstError != null) {
                _completeError(result, firstError!);
              } else {
                _completeValue(result, _newList(values, elem));
              }
            }
          });
        }
        return result;
      case 'Future.any':
        final futures = _iterableOf(p[0], offset, 'Future.any').toList();
        final result = KFuture(elem ?? 'dynamic');
        for (final fut in futures) {
          if (fut is! KFuture) _typeError("type '${typeName(fut)}' is not a subtype of type 'Future<dynamic>' (Future.any)", offset);
          _listen(fut, (s) {
            if (!result.isDone) _copyResult(result, s);
          });
        }
        return result;
      case 'Stream.fromIterable':
        return _fromIterable(_iterableOf(p[0], offset, 'Stream.fromIterable').toList(), elem ?? _inferElementType(_iterableOf(p[0], offset, '')));
      case 'Stream.value':
        return _eventsStream(elem ?? typeName(p[0]), [_StreamEvent.data(p[0]), const _StreamEvent.done()]);
      case 'Stream.error':
        return _eventsStream(elem ?? 'dynamic', [_StreamEvent.error(_asThrow(p[0], offset)), const _StreamEvent.done()]);
      case 'Stream.empty':
        return _eventsStream(elem ?? 'dynamic', const [_StreamEvent.done()]);
      case 'Stream.periodic':
        return _periodic(_durationMicros(p[0], offset), p.length > 1 ? p[1] : null, elem ?? 'dynamic', offset);
      case 'Stream.fromFuture':
        final fut = p[0];
        if (fut is! KFuture) _typeError("type '${typeName(fut)}' is not a subtype of type 'Future<dynamic>'", offset);
        final c = _newController(elem ?? fut.typeArg, isSync: true);
        _listen(fut, (s) {
          if (s.hasError) {
            _controllerAddError(c, s.error!);
          } else {
            _controllerAdd(c, s.value, offset);
          }
          _controllerClose(c);
        });
        return c.stream;
      case 'StreamController.broadcast':
        final c = _newController(elem ?? 'dynamic', isSync: n['sync'] == true, isBroadcast: true)
          ..onListen = n['onListen']
          ..onCancel = n['onCancel'];
        return c;
      case 'Timer.periodic':
        return _addTimer(_durationMicros(p[0], offset), _durationMicros(p[0], offset), p[1]);
      case 'Timer.run':
        return _addTimer(0, null, p[0]);
    }
    return _notFound;
  }

  Object? _asyncConstruct(String type, List<Object?> p, Map<String, Object?> n, int offset, String? elem) {
    switch (type) {
      case 'Future':
        final f = KFuture(elem ?? 'dynamic');
        _addTimer(0, null, NativeFunction('Future', (_, _) {
          _runInto(f, () => _callValue(p[0], const [], const {}, offset));
          return null;
        }));
        return f;
      case 'Completer':
        return KCompleter(KFuture(elem ?? 'dynamic'));
      case 'Timer':
        return _addTimer(_durationMicros(p[0], offset), null, p[1]);
      case 'StreamController':
        return _newController(elem ?? 'dynamic', isSync: n['sync'] == true)
          ..onListen = n['onListen']
          ..onCancel = n['onCancel']
          ..onPause = n['onPause']
          ..onResume = n['onResume'];
    }
    return _notFound;
  }

  int _durationMicros(Object? d, int offset) {
    if (d is KInstance && d.klass.name == 'Duration') return d.fields['inMicroseconds'] as int;
    _typeError("type '${typeName(d)}' is not a subtype of type 'Duration'", offset);
  }

  Map<String, Object?> _asyncLibrary() => {
    'scheduleMicrotask': NativeFunction('scheduleMicrotask', (p, n) {
      final fn = p[0];
      _microtask(() => _callValue(fn, const [], const {}, _lastUserOffset));
      return null;
    }, signature: '(void Function()) => void'),
    'unawaited': NativeFunction('unawaited', (p, n) {
      final f = p[0];
      if (f is KFuture) _listen(f, (_) {});
      return null;
    }, signature: '(Future<void>?) => void'),
    for (final t in const ['Completer', 'Timer', 'StreamController', 'StreamSubscription', 'StreamSink'])
      t: BuiltinType(t),
  };

  Object? _asyncProperty(Object? t, String name, int offset) {
    if (t is KCompleter) {
      if (name == 'future') return t.future;
      if (name == 'isCompleted') return t.isCompleted;
    }
    if (t is KTimer) {
      if (name == 'isActive') return t.isActive;
      if (name == 'tick') return t.tick;
    }
    if (t is KStream && name == 'isBroadcast') return t.isBroadcast;
    if (t is KStream) {
      switch (name) {
        case 'first':
          return _streamFuture(t, t.typeArg, (r, v, sub) {
            _cancelSub(sub);
            _completeValue(r, v);
          }, () => _throwDart('StateError', ['No element'], offset));
        case 'last':
          Object? last;
          var has = false;
          return _streamFuture(t, t.typeArg, (r, v, sub) {
            last = v;
            has = true;
          }, () => has ? last : _throwDart('StateError', ['No element'], offset));
        case 'length':
          var count = 0;
          return _streamFuture(t, 'int', (r, v, sub) => count++, () => count);
        case 'isEmpty':
          return _streamFuture(t, 'bool', (r, v, sub) {
            _cancelSub(sub);
            _completeValue(r, false);
          }, () => true);
      }
    }
    if (t is KStreamController) {
      switch (name) {
        case 'stream':
          return t.stream;
        case 'sink':
          return KStreamSink(t);
        case 'hasListener':
          return t.hasListener;
        case 'isClosed':
          return t.isClosed;
        case 'isPaused':
          return t.isPaused;
        case 'done':
          return t.doneFuture ??= KFuture('void');
      }
    }
    if (t is KSubscription && name == 'isPaused') return t.isPaused;
    return _notFound;
  }

  bool _setAsyncProperty(Object? t, String name, Object? value) {
    if (t is KStreamController) {
      switch (name) {
        case 'onListen':
          t.onListen = value;
          return true;
        case 'onCancel':
          t.onCancel = value;
          return true;
        case 'onPause':
          t.onPause = value;
          return true;
        case 'onResume':
          t.onResume = value;
          return true;
      }
    }
    return false;
  }

  Object? _asyncMethod(Object? t, String name, List<Object?> p, Map<String, Object?> n, int offset) {
    if (t is KFuture) {
      switch (name) {
        case 'then':
          final onValue = p[0];
          final onError = n['onError'];
          final r = KFuture('dynamic');
          _listen(t, (s) {
            if (!s.hasError) {
              _runInto(r, () => _callValue(onValue, [s.value], const {}, offset));
            } else if (onError != null) {
              _runInto(r, () => _callErrorHandler(onError, s.error!, offset));
            } else {
              _completeError(r, s.error!);
            }
          });
          return r;
        case 'catchError':
          final handler = p[0];
          final test = n['test'];
          final r = KFuture(t.typeArg);
          _listen(t, (s) {
            if (!s.hasError) {
              _completeValue(r, s.value);
              return;
            }
            if (test != null) {
              bool matches;
              try {
                matches = _callValue(test, [s.error!.value], const {}, offset) == true;
              } on DartThrow catch (e) {
                _completeError(r, e);
                return;
              }
              if (!matches) {
                _completeError(r, s.error!);
                return;
              }
            }
            _runInto(r, () => _callErrorHandler(handler, s.error!, offset));
          });
          return r;
        case 'whenComplete':
          final action = p[0];
          final r = KFuture(t.typeArg);
          _listen(t, (s) {
            Object? v;
            try {
              v = _callValue(action, const [], const {}, offset);
            } on DartThrow catch (e) {
              _completeError(r, e);
              return;
            }
            if (v is KFuture) {
              _listen(v, (a) => a.hasError ? _completeError(r, a.error!) : _copyResult(r, s));
            } else {
              _copyResult(r, s);
            }
          });
          return r;
        case 'timeout':
          final r = KFuture(t.typeArg);
          final onTimeout = n['onTimeout'];
          final d = _durationMicros(p[0], offset);
          final timer = _addTimer(d, null, NativeFunction('timeout', (_, _) {
            if (r.isDone) return null;
            if (onTimeout != null) {
              _runInto(r, () => _callValue(onTimeout, const [], const {}, offset));
            } else {
              final ex = _instantiate(classes['TimeoutException']!, '', ['Future not completed', p[0]], const {}, offset);
              _completeError(r, DartThrow(ex, offset, List.of(_callStack.reversed)));
            }
            return null;
          }));
          _listen(t, (s) {
            if (r.isDone) return;
            timer.isActive = false;
            _copyResult(r, s);
          });
          return r;
        case 'ignore':
          _listen(t, (_) {});
          return null;
        case 'asStream':
          return _asyncStatic('Stream', 'fromFuture', [t], const {}, offset, t.typeArg);
      }
    }
    if (t is KCompleter) {
      switch (name) {
        case 'complete':
          if (t.isCompleted) _throwDart('StateError', ['Future already completed'], offset);
          t.isCompleted = true;
          _asyncComplete(t.future, p.isEmpty ? null : p[0]);
          return null;
        case 'completeError':
          if (t.isCompleted) _throwDart('StateError', ['Future already completed'], offset);
          t.isCompleted = true;
          _asyncCompleteError(t.future, _asThrow(p[0], offset));
          return null;
      }
    }
    if (t is KTimer && name == 'cancel') {
      t.isActive = false;
      return null;
    }
    if (t is KStreamController || t is KStreamSink) {
      final c = t is KStreamSink ? t.controller : t as KStreamController;
      switch (name) {
        case 'add':
          _controllerAdd(c, p[0], offset);
          return null;
        case 'addError':
          _controllerAddError(c, _asThrow(p[0], offset));
          return null;
        case 'close':
          return _controllerClose(c);
      }
    }
    if (t is KSubscription) {
      switch (name) {
        case 'onData':
          final f = p[0];
          t.onData = (v) {
            if (f != null) _callValue(f, [v], const {}, offset);
          };
          return null;
        case 'onError':
          final f = p[0];
          t.onError = f == null ? null : (e) => _callErrorHandler(f, e, offset);
          return null;
        case 'onDone':
          final f = p[0];
          t.onDone = () {
            if (f != null) _callValue(f, const [], const {}, offset);
          };
          return null;
        case 'cancel':
          return _cancelSub(t);
        case 'pause':
          _pauseSub(t);
          return null;
        case 'resume':
          _resumeSub(t);
          return null;
      }
    }
    if (t is KStream) {
      switch (name) {
        case 'listen':
          return _userListen(t, p.isEmpty ? null : p[0], n, offset);
        case 'map':
          final f = p[0];
          return _forward(t, 'dynamic', (out, v, up) => _emit(out, _StreamEvent.data(_callValue(f, [v], const {}, offset)), sync: true));
        case 'where':
          final f = p[0];
          return _forward(t, t.typeArg, (out, v, up) {
            if (_asBool(_callValue(f, [v], const {}, offset), offset)) _emit(out, _StreamEvent.data(v), sync: true);
          });
        case 'take':
          final count = _intArg(p[0], offset, 'count');
          var seen = 0;
          if (count <= 0) return _eventsStream(t.typeArg, const [_StreamEvent.done()]);
          return _forward(t, t.typeArg, (out, v, up) {
            seen++;
            _emit(out, _StreamEvent.data(v), sync: true);
            if (seen >= count) {
              _cancelSub(up);
              _emit(out, const _StreamEvent.done(), sync: true);
            }
          });
        case 'skip':
          final count = _intArg(p[0], offset, 'count');
          var seen = 0;
          return _forward(t, t.typeArg, (out, v, up) {
            if (seen++ >= count) _emit(out, _StreamEvent.data(v), sync: true);
          });
        case 'expand':
          final f = p[0];
          return _forward(t, 'dynamic', (out, v, up) {
            for (final x in _iterableOf(_callValue(f, [v], const {}, offset), offset, 'expand')) {
              _emit(out, _StreamEvent.data(x), sync: true);
            }
          });
        case 'toList':
          final list = _newList(const [], t.typeArg == 'dynamic' ? null : t.typeArg);
          return _streamFuture(t, 'List<${t.typeArg}>', (r, v, sub) => list.add(v), () => list);
        case 'toSet':
          final set = <Object?>{};
          return _streamFuture(t, 'Set<${t.typeArg}>', (r, v, sub) => set.add(v), () => set);
        case 'forEach':
          final f = p[0];
          return _streamFuture(t, 'void', (r, v, sub) => _callValue(f, [v], const {}, offset), () => null);
        case 'join':
          final sep = p.isEmpty ? '' : _strArg(p[0], offset);
          final parts = <String>[];
          return _streamFuture(t, 'String', (r, v, sub) => parts.add(stringify(v, offset)), () => parts.join(sep));
        case 'fold':
          var acc = p[0];
          final f = p[1];
          return _streamFuture(t, 'dynamic', (r, v, sub) => acc = _callValue(f, [acc, v], const {}, offset), () => acc);
        case 'reduce':
          Object? acc;
          var has = false;
          final f = p[0];
          return _streamFuture(t, t.typeArg, (r, v, sub) {
            acc = has ? _callValue(f, [acc, v], const {}, offset) : v;
            has = true;
          }, () => has ? acc : _throwDart('StateError', ['No element'], offset));
        case 'contains':
          final needle = p[0];
          return _streamFuture(t, 'bool', (r, v, sub) {
            if (_equals(v, needle, offset)) {
              _cancelSub(sub);
              _completeValue(r, true);
            }
          }, () => false);
        case 'firstWhere':
          final f = p[0];
          final orElse = n['orElse'];
          return _streamFuture(t, t.typeArg, (r, v, sub) {
            if (_asBool(_callValue(f, [v], const {}, offset), offset)) {
              _cancelSub(sub);
              _completeValue(r, v);
            }
          }, () => orElse != null ? _callValue(orElse, const [], const {}, offset) : _throwDart('StateError', ['No element'], offset));
        case 'handleError':
          final f = p[0];
          return KStream(t.typeArg, (out) {
            late KSubscription up;
            up = _subscribe(t, (v) => _emit(out, _StreamEvent.data(v), sync: true), onError: (e) {
              try {
                _callErrorHandler(f, e, offset);
              } on DartThrow catch (e2) {
                _emit(out, _StreamEvent.error(e2), sync: true);
              }
            }, onDone: () => _emit(out, const _StreamEvent.done(), sync: true));
            out.onCancelHook = () => _cancelSub(up);
            out.onPauseHook = () => _pauseSub(up);
            out.onResumeHook = () => _resumeSub(up);
          }, isBroadcast: t.isBroadcast);
        case 'asBroadcastStream':
          final c = _newController(t.typeArg, isSync: true, isBroadcast: true);
          var started = false;
          c.onListen = NativeFunction('asBroadcast', (_, _) {
            if (started) return null;
            started = true;
            _subscribe(t, (v) => _controllerAdd(c, v, offset), onError: (e) => _controllerAddError(c, e), onDone: () => _controllerClose(c));
            return null;
          });
          return c.stream;
      }
    }
    return _notFound;
  }

  // ───────────── await for ─────────────

  KFuture _iteratorMoveNext(_KStreamIterator it) {
    final sub = it.subscription;
    if (sub != null) {
      if (it.hasValue) {
        final f = KFuture('bool');
        it._future = f;
        it.hasValue = false;
        _resumeSub(sub);
        return f;
      }
      _throwDart('StateError', ['Already waiting for next.'], _lastUserOffset);
    }
    final s = it.stream;
    if (s == null) return _valueFuture(false, 'bool');
    final f = KFuture('bool');
    it._future = f;
    final created = _subscribe(s, (v) {
      if (it.subscription == null) return;
      final mf = it._future!;
      it.current = v;
      it.hasValue = true;
      _completeValue(mf, true);
      if (it.hasValue) {
        final s2 = it.subscription;
        if (s2 != null) _pauseSub(s2);
      }
    }, onError: (e) {
      final had = it.subscription != null;
      final mf = it._future!;
      it.subscription = null;
      it.stream = null;
      had ? _completeError(mf, e) : _asyncCompleteError(mf, e);
    }, onDone: () {
      final had = it.subscription != null;
      final mf = it._future!;
      it.subscription = null;
      it.stream = null;
      had ? _completeValue(mf, false) : _asyncComplete(mf, false);
    }, cancelOnError: true);
    if (it.stream != null) it.subscription = created;
    return f;
  }

  KFuture _iteratorCancel(_KStreamIterator it) {
    final sub = it.subscription;
    it.stream = null;
    if (sub != null) {
      it.subscription = null;
      if (!it.hasValue) {
        _asyncComplete(it._future!, false);
      } else {
        it.hasValue = false;
      }
      return _cancelSub(sub);
    }
    return _nullFuture();
  }

  // ───────────── Tur va matn ─────────────

  String? _asyncTypeName(Object? v) => switch (v) {
    KFuture() => 'Future<${v.typeArg}>',
    KStream() => v.isBroadcast ? '_BroadcastStream<${v.typeArg}>' : 'Stream<${v.typeArg}>',
    KCompleter() => 'Completer<${v.future.typeArg}>',
    KTimer() => 'Timer',
    KStreamController() => 'StreamController<${v.typeArg}>',
    KStreamSink() => 'StreamSink<${v.controller.typeArg}>',
    KSubscription() => 'StreamSubscription<${v.typeArg}>',
    KSyncStarIterable() => '_SyncStarIterable<${v.typeArg}>',
    _ => null,
  };

  bool? _isAsyncType(Object? v, TypeAnnotation t) {
    bool arg(String actual) {
      if (t.args.isEmpty) return true;
      final a = t.args.first;
      if (a.isDynamic || a.name == 'Object' || a.name == 'void' || actual == 'dynamic') return true;
      return a.name == actual.replaceAll('?', '') || a.toString() == actual;
    }

    return switch (t.name) {
      'Future' => v is KFuture && arg(v.typeArg),
      'Stream' => v is KStream && arg(v.typeArg),
      'Completer' => v is KCompleter,
      'Timer' => v is KTimer,
      'StreamController' => v is KStreamController,
      'StreamSink' => v is KStreamSink || v is KStreamController,
      'StreamSubscription' => v is KSubscription,
      'FutureOr' => true,
      _ => null,
    };
  }

  // ───────────── await/yield bormi? (AST bo'yicha) ─────────────

  bool _hasPause(Object? n) {
    if (n == null) return false;
    if (n is Node) {
      final cached = _pauseCache[n];
      if (cached != null) return cached;
      final r = _computeHasPause(n);
      _pauseCache[n] = r;
      return r;
    }
    return _computeHasPause(n);
  }

  bool _anyPause(Iterable<Object?> xs) {
    for (final x in xs) {
      if (_hasPause(x)) return true;
    }
    return false;
  }

  bool _computeHasPause(Object n) => switch (n) {
    AwaitExpr() || YieldStmt() => true,
    FunctionExpr() || LocalFunctionStmt() => false,
    Literal() || Identifier() || ThisExpr() || SuperExpr() || CascadeTarget() => false,
    StringInterp() => _anyPause(n.parts.whereType<Expr>()),
    ListLiteral() => _anyPause(n.elements),
    SetOrMapLiteral() => _anyPause(n.elements),
    RecordLiteral() => _anyPause([...n.positional, ...n.named.values]),
    UnaryExpr() => _hasPause(n.operand),
    IncDecExpr() => _hasPause(n.target),
    BinaryExpr() => _hasPause(n.left) || _hasPause(n.right),
    ConditionalExpr() => _anyPause([n.condition, n.then, n.otherwise]),
    AssignExpr() => _hasPause(n.target) || _hasPause(n.value),
    PropertyGet() => _hasPause(n.target),
    IndexExpr() => _hasPause(n.target) || _hasPause(n.index),
    CallExpr() => _hasPause(n.callee) || _anyPause([...n.args.positional, ...n.args.named.values]),
    MethodCall() => _hasPause(n.target) || _anyPause([...n.args.positional, ...n.args.named.values]),
    CascadeExpr() => _hasPause(n.target) || _anyPause(n.sections),
    IsExpr() => _hasPause(n.expr),
    AsExpr() => _hasPause(n.expr),
    NullAssertExpr() => _hasPause(n.expr),
    ThrowExpr() => _hasPause(n.expr),
    SwitchExpr() => _hasPause(n.subject) || n.cases.any((c) => _hasPause(c.guard) || _hasPause(c.body)),
    ExprElement() => _hasPause(n.expr),
    MapEntryElement() => _hasPause(n.key) || _hasPause(n.value),
    SpreadElement() => _hasPause(n.expr),
    IfElement() => _anyPause([n.condition, n.then, n.otherwise]),
    ForElement() => _hasPause(n.loop) || _hasPause(n.body),
    Block() => _anyPause(n.statements),
    VarDecl() => _anyPause(n.vars.map((v) => v.init)),
    ExprStmt() => _hasPause(n.expr),
    IfStmt() => _anyPause([n.condition, n.then, n.otherwise]),
    ForStmt() => _anyPause([n.init, n.condition, ...n.updates, n.body]),
    ForInStmt() => n.isAwait || _hasPause(n.iterable) || _hasPause(n.body),
    WhileStmt() => _hasPause(n.condition) || _hasPause(n.body),
    DoWhileStmt() => _hasPause(n.condition) || _hasPause(n.body),
    ReturnStmt() => _hasPause(n.value),
    SwitchStmt() => _hasPause(n.subject) || n.cases.any((c) => _anyPause(c.body) || _anyPause(c.guards)),
    TryStmt() => _hasPause(n.body) || n.catches.any((c) => _hasPause(c.body)) || _hasPause(n.finallyBlock),
    AssertStmt() => _hasPause(n.condition) || _hasPause(n.message),
    LabeledStmt() => _hasPause(n.body),
    _ => false,
  };

  Env _copyEnv(Env env) {
    final e = Env(env.parent, self: env.self, selfClass: env.selfClass, staticClass: env.staticClass, isFunction: true,
        functionName: env.functionName);
    for (final v in env.vars.entries) {
      final b = v.value;
      e.vars[v.key] = Binding(b.value, isFinal: b.isFinal, type: b.type, initialized: b.initialized, isLate: b.isLate);
    }
    return e;
  }

  // ───────────── Generator rejimidagi bajarish (await/yield to'xtay oladi) ─────────────

  Iterable<_Pause> _bodyG(KFunction f, Env env, _Box out) sync* {
    final body = f.body!;
    if (body.expr != null) {
      yield* _evalG(body.expr!, env, out);
      return;
    }
    final c = _Box();
    yield* _execBlockG(body.block!.statements, env, c);
    final r = c.value;
    if (r is _Return) out.value = r.value;
    if (r is _Break || r is _Continue) {
      throw ExecutionAbort('break_outside_loop', "`break`/`continue` faqat sikl yoki switch ichida ishlatiladi.",
          'A break statement can\'t be used outside of a loop or switch statement.', f.body?.block?.offset ?? 0);
    }
  }

  Iterable<_Pause> _execBlockG(List<Stmt> stmts, Env env, _Box out) sync* {
    for (final s in stmts) {
      final b = _Box();
      yield* _execG(s, env, b);
      if (b.value != null) {
        out.value = b.value;
        return;
      }
    }
  }

  Iterable<_Pause> _execG(Stmt s, Env env, _Box out, {String? label}) sync* {
    if (!_hasPause(s)) {
      out.value = _exec(s, env, label: label);
      return;
    }
    _tick(s.offset);
    switch (s) {
      case Block():
        yield* _execBlockG(s.statements, Env(env), out);
      case VarDecl():
        for (final v in s.vars) {
          if (v.init == null) {
            _declareVar(s, v, null, env, uninitialized: true);
            continue;
          }
          final b = _Box();
          yield* _evalG(v.init!, env, b);
          _declareVar(s, v, b.value, env);
        }
      case ExprStmt():
        yield* _evalG(s.expr, env, _Box());
      case IfStmt():
        final b = _Box();
        yield* _evalG(s.condition, env, b);
        final cond = _asCondition(b.value, s.condition, 'if');
        if (cond) {
          yield* _execG(s.then, Env(env), out);
        } else if (s.otherwise != null) {
          yield* _execG(s.otherwise!, Env(env), out);
        }
      case WhileStmt():
        while (true) {
          final b = _Box();
          yield* _evalG(s.condition, env, b);
          if (!_asCondition(b.value, s.condition, 'while')) break;
          final cb = _Box();
          yield* _execG(s.body, Env(env), cb);
          final c = cb.value;
          if (c is _Break && (c.label == null || c.label == label)) break;
          if (c is _Continue && (c.label == null || c.label == label)) continue;
          if (c != null) {
            out.value = c;
            return;
          }
        }
      case DoWhileStmt():
        while (true) {
          final cb = _Box();
          yield* _execG(s.body, Env(env), cb);
          final c = cb.value;
          if (c is _Break && (c.label == null || c.label == label)) break;
          if (c != null && c is! _Continue) {
            out.value = c;
            return;
          }
          if (c is _Continue && c.label != null && c.label != label) {
            out.value = c;
            return;
          }
          final b = _Box();
          yield* _evalG(s.condition, env, b);
          if (!_asCondition(b.value, s.condition, 'do-while')) break;
        }
      case ForStmt():
        yield* _execForG(s, env, label, out);
      case ForInStmt():
        if (s.isAwait) {
          yield* _execAwaitForG(s, env, label, out);
        } else {
          yield* _execForInG(s, env, label, out);
        }
      case ReturnStmt():
        final b = _Box();
        if (s.value != null) yield* _evalG(s.value!, env, b);
        out.value = _Return(b.value);
      case YieldStmt():
        final b = _Box();
        yield* _evalG(s.value, env, b);
        _record(TraceKind.output, s.offset, s.end - s.offset, "`yield` — oqimga qiymat berildi: ${_preview(b.value)}", env: env);
        final p = _YieldPoint(b.value, s.isStar, s.offset);
        yield p;
        if (p.cancelled) throw _GeneratorCancel();
      case TryStmt():
        yield* _execTryG(s, env, out);
      case SwitchStmt():
        yield* _execSwitchG(s, env, label, out);
      case LabeledStmt():
        final b = _Box();
        yield* _execG(s.body, env, b, label: s.label);
        final c = b.value;
        out.value = c is _Break && c.label == s.label ? null : c;
      default:
        out.value = _exec(s, env, label: label);
    }
  }

  bool _asCondition(Object? v, Expr e, String what) {
    if (v is! bool) _typeError("type '${typeName(v)}' is not a subtype of type 'bool' ($what sharti)", e.offset);
    return v;
  }

  Iterable<_Pause> _execForG(ForStmt s, Env env, String? label, _Box out) sync* {
    final loopEnv = Env(env);
    if (s.init != null) yield* _execG(s.init!, loopEnv, _Box());
    while (true) {
      if (s.condition != null) {
        final b = _Box();
        yield* _evalG(s.condition!, loopEnv, b);
        if (!_asCondition(b.value, s.condition!, 'for')) break;
      }
      final iterEnv = Env(env);
      for (final e in loopEnv.vars.entries) {
        final b = e.value;
        iterEnv.vars[e.key] = Binding(b.value, isFinal: b.isFinal, type: b.type, initialized: b.initialized);
      }
      final cb = _Box();
      yield* _execG(s.body, iterEnv, cb);
      for (final e in iterEnv.vars.entries) {
        loopEnv.vars[e.key]?.value = e.value.value;
      }
      final c = cb.value;
      if (c is _Break && (c.label == null || c.label == label)) break;
      if (c != null && c is! _Continue) {
        out.value = c;
        return;
      }
      if (c is _Continue && c.label != null && c.label != label) {
        out.value = c;
        return;
      }
      for (final u in s.updates) {
        _tick(u.offset);
        yield* _evalG(u, loopEnv, _Box());
      }
    }
  }

  Iterable<_Pause> _execForInG(ForInStmt s, Env env, String? label, _Box out) sync* {
    final b = _Box();
    yield* _evalG(s.iterable, env, b);
    final items = _iterableOf(b.value, s.iterable.offset, 'for-in');
    for (final item in items) {
      _tick(s.offset);
      final iterEnv = _forInEnv(s, item, env);
      final cb = _Box();
      yield* _execG(s.body, iterEnv, cb);
      final c = cb.value;
      if (c is _Break && (c.label == null || c.label == label)) break;
      if (c is _Continue && (c.label == null || c.label == label)) continue;
      if (c != null) {
        out.value = c;
        return;
      }
    }
  }

  Env _forInEnv(ForInStmt s, Object? item, Env env) {
    final iterEnv = Env(env);
    if (s.declares) {
      iterEnv.define(s.name, Binding(_coerce(item, s.type, s.offset, s.name), isFinal: s.isFinal, type: s.type));
    } else {
      _assignVar(s.name, item, env, s.offset);
    }
    return iterEnv;
  }

  Iterable<_Pause> _execAwaitForG(ForInStmt s, Env env, String? label, _Box out) sync* {
    final b = _Box();
    yield* _evalG(s.iterable, env, b);
    final stream = b.value;
    if (stream is! KStream) {
      _typeError("type '${typeName(stream)}' is not a subtype of type 'Stream<dynamic>' (await for)", s.iterable.offset);
    }
    final it = _KStreamIterator(stream);
    var i = 0;
    try {
      while (true) {
        final p = _AwaitPoint(_iteratorMoveNext(it), s.offset);
        yield p;
        final r = p.result!;
        if (r.hasError) throw r.error!;
        if (r.value != true) break;
        _tick(s.offset);
        final iterEnv = _forInEnv(s, it.current, env);
        _record(TraceKind.loop, s.offset, 5, "await for: ${++i}-hodisa keldi, `${s.name}` = ${_preview(it.current)}",
            env: iterEnv, changed: [s.name]);
        final cb = _Box();
        yield* _execG(s.body, iterEnv, cb);
        final c = cb.value;
        if (c is _Break && (c.label == null || c.label == label)) break;
        if (c is _Continue && (c.label == null || c.label == label)) continue;
        if (c != null) {
          out.value = c;
          return;
        }
      }
    } finally {
      if (it.subscription != null) {
        final p = _AwaitPoint(_iteratorCancel(it), s.offset);
        yield p;
      }
    }
  }

  Iterable<_Pause> _execTryG(TryStmt s, Env env, _Box out) sync* {
    Object? result;
    try {
      try {
        final b = _Box();
        yield* _execBlockG(s.body.statements, Env(env), b);
        result = b.value;
      } on DartThrow catch (ex) {
        final handler = _handlerFor(s, ex);
        if (handler == null) rethrow;
        final ce = _catchEnv(handler, ex, env);
        final b = _Box();
        yield* _execBlockG(handler.body.statements, ce, b);
        result = b.value;
      }
    } finally {
      if (s.finallyBlock != null) {
        final b = _Box();
        yield* _execBlockG(s.finallyBlock!.statements, Env(env), b);
        if (b.value != null) result = b.value;
      }
    }
    out.value = result;
  }

  Iterable<_Pause> _execSwitchG(SwitchStmt s, Env env, String? label, _Box out) sync* {
    final b = _Box();
    yield* _evalG(s.subject, env, b);
    final (chosen, caseEnv) = _chooseCase(s, b.value, env);
    if (chosen == null) return;
    final cb = _Box();
    yield* _execBlockG(chosen.body, caseEnv!, cb);
    final c = cb.value;
    out.value = c is _Break && (c.label == null || c.label == label) ? null : c;
  }

  Iterable<_Pause> _evalArgsG(Arguments a, Env env, _Box out) sync* {
    final pos = <Object?>[];
    for (final p in a.positional) {
      final b = _Box();
      yield* _evalG(p, env, b);
      pos.add(b.value);
    }
    final named = <String, Object?>{};
    for (final n in a.named.entries) {
      final b = _Box();
      yield* _evalG(n.value, env, b);
      named[n.key] = b.value;
    }
    out.value = (pos, named);
  }

  Iterable<_Pause> _evalG(Expr e, Env env, _Box out) sync* {
    if (!_hasPause(e)) {
      out.value = _eval(e, env);
      return;
    }
    switch (e) {
      case AwaitExpr():
        final b = _Box();
        yield* _evalG(e.expr, env, b);
        final v = b.value;
        final fut = v is KFuture ? v : _valueFuture(v, typeName(v));
        _record(TraceKind.wait, e.offset, e.end - e.offset,
            fut.isDone
                ? "`await` — Future tayyor, natija keyingi microtask'da olinadi."
                : "`await` — Future tugashi kutilmoqda. Shu paytda boshqa vazifalar (event loop) ishlaydi.",
            env: env);
        final p = _AwaitPoint(fut, e.offset);
        yield p;
        final r = p.result!;
        if (r.hasError) throw r.error!;
        _record(TraceKind.wait, e.offset, e.end - e.offset, "`await` tugadi: natija ${_preview(r.value)}", env: env);
        out.value = r.value;
      case StringInterp():
        final buf = StringBuffer();
        for (final p in e.parts) {
          if (p is String) {
            buf.write(p);
          } else {
            final b = _Box();
            yield* _evalG(p as Expr, env, b);
            buf.write(stringify(b.value, p.offset));
          }
        }
        out.value = buf.toString();
      case BinaryExpr():
        final lb = _Box();
        yield* _evalG(e.left, env, lb);
        final l = lb.value;
        switch (e.op) {
          case '&&':
          case '||':
            if (l is! bool) _typeError("type '${typeName(l)}' is not a subtype of type 'bool'", e.left.offset);
            if (e.op == '&&' ? !l : l) {
              out.value = l;
              return;
            }
            final rb = _Box();
            yield* _evalG(e.right, env, rb);
            if (rb.value is! bool) _typeError("type '${typeName(rb.value)}' is not a subtype of type 'bool'", e.right.offset);
            out.value = rb.value;
            return;
          case '??':
            if (l != null) {
              out.value = l;
              return;
            }
            yield* _evalG(e.right, env, out);
            return;
        }
        final rb = _Box();
        yield* _evalG(e.right, env, rb);
        out.value = _binary(e.op, l, rb.value, e.opOffset);
      case UnaryExpr():
        final b = _Box();
        yield* _evalG(e.operand, env, b);
        out.value = _unary(e, b.value);
      case ConditionalExpr():
        final b = _Box();
        yield* _evalG(e.condition, env, b);
        yield* _evalG(_asCondition(b.value, e.condition, '?:') ? e.then : e.otherwise, env, out);
      case AssignExpr():
        if (_hasPause(e.target)) break;
        Object? current;
        if (e.op != '=') {
          current = _eval(e.target, env);
          if (e.op == '??=' && current != null) {
            out.value = current;
            return;
          }
        }
        final b = _Box();
        yield* _evalG(e.value, env, b);
        final value = e.op == '=' || e.op == '??=' ? b.value : _binary(e.op.substring(0, e.op.length - 1), current, b.value, e.offset);
        _assignTo(e.target, value, env, e.offset);
        if (e.target is Identifier) {
          final n = (e.target as Identifier).name;
          _record(TraceKind.assign, e.offset, e.end - e.offset, "`$n` ga yangi qiymat berildi: ${_preview(value)}",
              env: env, changed: [n]);
        }
        out.value = value;
      case CallExpr():
        final cb = _Box();
        yield* _evalG(e.callee, env, cb);
        final ab = _Box();
        yield* _evalArgsG(e.args, env, ab);
        final (pos, named) = ab.value as (List<Object?>, Map<String, Object?>);
        out.value = _callValue(cb.value, pos, named, e.offset,
            name: e.callee is Identifier ? (e.callee as Identifier).name : null, typeArgs: e.typeArgs);
      case MethodCall():
        if (e.target is SuperExpr) break;
        final tb = _Box();
        yield* _evalG(e.target, env, tb);
        if (tb.value == null && e.nullAware) {
          out.value = null;
          return;
        }
        final ab = _Box();
        yield* _evalArgsG(e.args, env, ab);
        final (pos, named) = ab.value as (List<Object?>, Map<String, Object?>);
        out.value = _callMethod(tb.value, e.name, pos, named, e.nameOffset, typeArgs: e.typeArgs);
      case PropertyGet():
        if (e.target is SuperExpr) break;
        final tb = _Box();
        yield* _evalG(e.target, env, tb);
        out.value = tb.value == null && e.nullAware ? null : _getProperty(tb.value, e.name, e.nameOffset);
      case IndexExpr():
        final tb = _Box();
        yield* _evalG(e.target, env, tb);
        if (tb.value == null && e.nullAware) {
          out.value = null;
          return;
        }
        final ib = _Box();
        yield* _evalG(e.index, env, ib);
        out.value = _index(tb.value, ib.value, e.offset);
      case ListLiteral():
        if (!e.elements.every((x) => x is ExprElement || !_hasPause(x))) break;
        final list = <Object?>[];
        for (final el in e.elements) {
          if (el is ExprElement) {
            final b = _Box();
            yield* _evalG(el.expr, env, b);
            list.add(b.value);
          } else {
            _evalElement(el, env, list.add, null);
          }
        }
        out.value = _finishList(e, list);
      case SetOrMapLiteral():
        if (!e.isMap || !e.elements.every((x) => x is MapEntryElement || !_hasPause(x))) break;
        final map = <Object?, Object?>{};
        for (final el in e.elements) {
          if (el is MapEntryElement) {
            final kb = _Box();
            yield* _evalG(el.key, env, kb);
            final vb = _Box();
            yield* _evalG(el.value, env, vb);
            map[kb.value] = vb.value;
          } else {
            _evalElement(el, env, null, (k, v) => map[k] = v);
          }
        }
        if (e.typeArgs.length == 2) _typeArgs[map] = '${e.typeArgs[0]}, ${e.typeArgs[1]}';
        out.value = map;
      case RecordLiteral():
        final pos = <Object?>[];
        for (final p in e.positional) {
          final b = _Box();
          yield* _evalG(p, env, b);
          pos.add(b.value);
        }
        final named = <String, Object?>{};
        for (final n in e.named.entries) {
          final b = _Box();
          yield* _evalG(n.value, env, b);
          named[n.key] = b.value;
        }
        out.value = KRecord(pos, named);
      case IsExpr():
        final b = _Box();
        yield* _evalG(e.expr, env, b);
        final r = isType(b.value, e.type);
        out.value = e.negated ? !r : r;
      case AsExpr():
        final b = _Box();
        yield* _evalG(e.expr, env, b);
        out.value = _asCast(e, b.value);
      case NullAssertExpr():
        final b = _Box();
        yield* _evalG(e.expr, env, b);
        if (b.value == null) _typeError('Null check operator used on a null value', e.offset);
        out.value = b.value;
      case ThrowExpr():
        final b = _Box();
        yield* _evalG(e.expr, env, b);
        if (b.value == null) _typeError('Throw of null.', e.offset);
        throw DartThrow(b.value, e.offset, List.of(_callStack.reversed));
      case SwitchExpr():
        final b = _Box();
        yield* _evalG(e.subject, env, b);
        for (final c in e.cases) {
          final ce = Env(env);
          if (_match(c.pattern, b.value, ce) && (c.guard == null || _eval(c.guard!, ce) == true)) {
            yield* _evalG(c.body, ce, out);
            return;
          }
        }
        _throwDart('StateError', ["switch ifodasida ${_preview(b.value)} uchun mos holat topilmadi"], e.offset);
      case CascadeExpr():
        final tb = _Box();
        yield* _evalG(e.target, env, tb);
        _cascadeStack.add(tb.value);
        try {
          for (final s in e.sections) {
            yield* _evalG(s, env, _Box());
          }
        } finally {
          _cascadeStack.removeLast();
        }
        out.value = tb.value;
      default:
        break;
    }
    if (out.value == null && !_handledInG(e)) {
      throw ExecutionAbort('unsupported_await_position',
          "`await` bu ifoda ichida hozircha qo'llab-quvvatlanmaydi. Natijani avval alohida o'zgaruvchiga oling: `final x = await ...;`",
          'await is not supported in this position by this runner.', e.offset);
    }
  }

  /// [_evalG] ichida to'liq ishlov berilgan (null natija ham to'g'ri bo'lishi mumkin) ifodalar.
  bool _handledInG(Expr e) => switch (e) {
    AssignExpr() => !_hasPause(e.target),
    MethodCall() || PropertyGet() => (e is MethodCall ? e.target : (e as PropertyGet).target) is! SuperExpr,
    ListLiteral() => e.elements.every((x) => x is ExprElement || !_hasPause(x)),
    SetOrMapLiteral() => e.isMap && e.elements.every((x) => x is MapEntryElement || !_hasPause(x)),
    IncDecExpr() || ForElement() => false,
    _ => true,
  };
}
