import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:math' as math;

import 'ast.dart';
import 'diagnostics.dart';
import 'engine.dart';
import 'flutter_colors.g.dart';
import 'parser.dart';
import 'result.dart';
import 'runtime.dart';
import 'values.dart';

part 'async_lib.dart';
part 'builtins.dart';
part 'flutter_lib.dart';
part 'trace_text.dart';

sealed class _Completion {}

class _Break extends _Completion {
  _Break(this.label);
  final String? label;
}

class _Continue extends _Completion {
  _Continue(this.label);
  final String? label;
}

class _Return extends _Completion {
  _Return(this.value);
  final Object? value;
}

final _plainBreak = _Break(null);
final _plainContinue = _Continue(null);

class _ExitSignal implements Exception {
  _ExitSignal(this.code);
  final int code;
}

class _NotFound {
  const _NotFound();
}

const _notFound = _NotFound();

/// Namespace prefiksi: `import 'dart:math' as math;`
class KNamespace {
  KNamespace(this.name, this.members);
  final String name;
  final Map<String, Object?> members;
}

/// Bajariladigan muhit uchun maxsus obyektlar (stdin, stdout).
class KNative {
  const KNative(this.kind);
  final String kind;
}

Program? _preludeCache;
Program get _prelude => _preludeCache ??= Parser(preludeSource).parseProgram();

/// Tree-walking interpretator. AST ni to'g'ridan-to'g'ri bajaradi.
class Interpreter {
  Interpreter(this.source, this.program, this.options) : lineMap = LineMap(source) {
    _random = math.Random(options.randomSeed);
  }

  final String source;
  final Program program;
  final ExecutionOptions options;
  final LineMap lineMap;

  final StringBuffer _out = StringBuffer();
  final List<TraceStep> trace = [];
  bool traceTruncated = false;
  int steps = 0;
  final Stopwatch _clock = Stopwatch();
  final Env globals = Env(null, isFunction: true, functionName: 'global');
  final Map<String, KClass> classes = {};
  final Map<String, List<(ExtensionDecl, FunctionDecl)>> _extensions = {};
  final Set<String> _declNames = {};
  final Set<KClass> _preludeClasses = {};
  final List<String> _callStack = [];
  final Expando<String> _typeArgs = Expando('typeArgs');
  int _depth = 0;
  int _stdinIndex = 0;
  int _traceSuspended = 0;
  int _lastUserOffset = 0;
  late math.Random _random;
  final List<Object?> _cascadeStack = [];
  late final Map<String, Object?> _builtins = _createBuiltins();
  final Map<String, Map<String, Object?>> _libCache = {};

  // Event loop (asinxron kod uchun). Vaqt virtual — mikrosekundlarda.
  final ListQueue<void Function()> _microtasks = ListQueue();
  final List<KTimer> _timers = [];
  int _now = 0;
  int _timerSeq = 0;
  final Expando<bool> _pauseCache = Expando('pause');
  final DateTime _startTime = DateTime.now();

  /// false — Flutter ilovasi: event loop `main()` dan keyin to'liq aylantirilmaydi (ilova "yashab" turadi).
  bool drainEventLoopOnMain = true;

  int get nowMicros => _now;

  /// Virtual vaqt bo'yicha hozirgi payt (`DateTime.now()`).
  DateTime get virtualNow => _startTime.add(Duration(microseconds: _now));

  /// Flutter: `runApp()` ga berilgan ildiz widget.
  Object? flutterRoot;
  FlutterHost? flutterHost;

  /// Nechta `setState` chaqirilgani (baholash: ekran faqat setState'dan keyin yangilanadi).
  int flutterSetStates = 0;

  /// Har bir callback (masalan tugma bosilishi) uchun qadam limitini yangilaydi.
  void resetBudget() {
    steps = 0;
    _clock
      ..reset()
      ..start();
  }

  String get stdout => _out.toString();

  // ───────────────────────── Yuklash ─────────────────────────

  void load() {
    _clock.start();
    final preludeDecls = [..._prelude.classes, if (usesFlutter(program)) ...flutterPrelude.classes];
    for (final c in preludeDecls) {
      _preludeClasses.add(_declareClass(c));
    }
    for (final c in program.classes) {
      _declNames.add(c.name);
      _declareClass(c);
    }
    for (final c in [...preludeDecls, ...program.classes]) {
      _linkClass(c);
    }
    for (final e in program.extensions) {
      for (final m in e.methods) {
        (_extensions[m.name] ??= []).add((e, m));
      }
    }
    for (final f in program.functions) {
      _declNames.add(f.name);
      globals.define(f.name, Binding(_makeFunction(f, globals), isFinal: true));
    }
    for (final imp in program.imports) {
      if (imp.prefix != null) {
        globals.define(imp.prefix!, Binding(KNamespace(imp.prefix!, _libraryMembers(imp.uri)), isFinal: true));
        _declNames.add(imp.prefix!);
      }
    }
    for (final c in [...preludeDecls, ...program.classes]) {
      _initStatics(classes[c.name]!);
    }
    for (final v in program.variables) {
      _execVarDecl(v, globals);
    }
  }

  Set<String> get _importedLibraries => {for (final i in program.imports) if (i.prefix == null) i.uri};

  Map<String, Object?> _libraryMembers(String uri) => _libCache.putIfAbsent(uri, () => switch (uri) {
    'dart:math' => _mathLibrary(),
    'dart:io' => _ioLibrary(),
    'dart:convert' => _convertLibrary(),
    'dart:async' => _asyncLibrary(),
    _ when flutterLibraryUris.contains(uri) => _flutterLibrary(),
    _ => <String, Object?>{},
  });

  KClass _declareClass(ClassDecl d) {
    final k = KClass(d.name, d);
    classes[d.name] = k;
    globals.define(d.name, Binding(k, isFinal: true));
    k.staticEnv = Env(globals, staticClass: k);
    _fillMembers(k, d);
    return k;
  }

  void _fillMembers(KClass k, ClassDecl d) {
    for (final m in d.methods) {
      if (m.isStatic) {
        if (m.isGetter) {
          k.staticGetters[m.name] = m;
        } else {
          k.staticMethods[m.name] = m;
        }
      } else if (m.isGetter) {
        k.getters[m.name] = m;
      } else if (m.isSetter) {
        k.setters[m.name] = m;
      } else {
        k.methods[m.name] = m;
      }
    }
    for (final c in d.constructors) {
      k.constructors[c.name ?? ''] = c;
    }
    for (final f in d.fields) {
      if (f.isStatic) continue;
      k.instanceFields.add(f);
      if (f.decl.isFinal || f.decl.isConst) {
        for (final v in f.decl.vars) {
          k.finalFields.add(v.name);
        }
      }
    }
  }

  void _linkClass(ClassDecl d) {
    final k = classes[d.name]!;
    KClass? sup;
    if (d.superclass != null) {
      sup = classes[d.superclass!.name];
      if (sup == null && !_isBuiltinTypeName(d.superclass!.name)) {
        throw ExecutionAbort('unknown_class', "`${d.superclass!.name}` nomli class topilmadi.",
            "Classes can only extend other classes.", d.offset);
      }
    }
    // Mixinlar: har biri alohida "oraliq" class sifatida zanjirga qo'shiladi.
    for (final m in d.mixins) {
      final mk = classes[m.name];
      if (mk == null) continue;
      final app = KClass('${sup?.name ?? 'Object'} with ${m.name}', mk.decl, superclass: sup, isMixinApplication: true);
      app.staticEnv = mk.staticEnv;
      _fillMembers(app, mk.decl);
      app.interfaceNames.add(m.name);
      app.interfaceNames.addAll(mk.interfaceNames);
      sup = app;
    }
    k.superclass = sup;
    for (final i in d.interfaces) {
      k.interfaceNames.add(i.name);
      final ik = classes[i.name];
      if (ik != null) {
        KClass? c = ik;
        while (c != null) {
          k.interfaceNames.add(c.name);
          k.interfaceNames.addAll(c.interfaceNames);
          c = c.superclass;
        }
      }
    }
    if (d.kind == ClassKind.enumDecl) k.interfaceNames.add('Enum');
  }

  void _initStatics(KClass k) {
    for (final f in k.decl.fields) {
      if (!f.isStatic) continue;
      for (final v in f.decl.vars) {
        final value = v.init == null ? null : _eval(v.init!, k.staticEnv);
        k.statics[v.name] = Binding(_coerce(value, f.decl.type, v.offset, v.name),
            isFinal: f.decl.isFinal || f.decl.isConst, type: f.decl.type);
      }
    }
    if (k.isEnum) {
      var i = 0;
      for (final ev in k.decl.enumValues) {
        final args = ev.args;
        final inst = KInstance(k)
          ..enumName = ev.name
          ..enumIndex = i++;
        final (pos, named) = args == null ? (<Object?>[], <String, Object?>{}) : _evalArgs(args, k.staticEnv);
        _initInstance(inst, k, k.constructors[''], pos, named, ev.offset);
        k.enumValues.add(inst);
        k.statics[ev.name] = Binding(inst, isFinal: true);
      }
      k.statics['values'] = Binding(List<Object?>.of(k.enumValues, growable: false), isFinal: true);
    }
  }

  KFunction _makeFunction(FunctionDecl f, Env closure, {KClass? owner}) => KFunction(
    name: f.name,
    params: f.params,
    body: f.body,
    closure: closure,
    returnType: f.returnType,
    ownerClass: owner,
    isGetter: f.isGetter,
    isStatic: f.isStatic,
    isAsync: f.isAsync,
    isGenerator: f.isGenerator,
  );

  // ───────────────────────── Ishga tushirish ─────────────────────────

  /// `main()` ni topib bajaradi.
  void runMain() {
    final main = globals.vars['main']?.value;
    if (main is! KFunction) {
      throw ExecutionAbort('no_main', "Dasturda `main()` funksiyasi topilmadi. Dart dasturi har doim main() dan boshlanadi.",
          "Error: No 'main' method found.", 0,
          hint: "Kodni shunday yozing:\nvoid main() {\n  print('Salom');\n}");
    }
    _record(TraceKind.start, main.body?.block?.offset ?? 0, 1, "Dastur ishga tushdi: `main()` funksiyasi chaqirildi.");
    _callStack.add('main');
    final args = main.params.isEmpty ? <Object?>[] : <Object?>[<Object?>[]];
    _invoke(main, args, const {}, 0, traceCall: false);
    _callStack.removeLast();
    if (drainEventLoopOnMain) runEventLoop();
    _record(TraceKind.end, source.length, 0, "Dastur muvaffaqiyatli yakunlandi.");
  }

  /// Dastur kontekstida ifodani hisoblaydi (testlar uchun).
  Object? evaluate(String exprSource) {
    final sub = Parser(exprSource);
    final expr = sub.parseExpression();
    if (!_hasPause(expr)) {
      final v = _eval(expr, globals);
      runEventLoop();
      return v;
    }
    // `await kvadrat(3)` — ifoda async kontekstda hisoblanadi, event loop natija tayyor bo'lguncha aylanadi.
    final out = _Box();
    final it = _evalG(expr, globals, out).iterator;
    Object? result;
    DartThrow? error;
    var finished = false;
    void step() {
      try {
        if (it.moveNext()) {
          final p = it.current as _AwaitPoint;
          _listen(p.future, (src) {
            p.result = src;
            step();
          });
          return;
        }
        result = out.value;
      } on DartThrow catch (e) {
        error = e;
      }
      finished = true;
    }

    step();
    runEventLoop();
    if (error != null) throw error!;
    if (!finished) {
      throw ExecutionAbort('future_never_completed', "Kutilgan Future hech qachon tugamadi (masalan Completer.complete() chaqirilmagan).",
          'The awaited future never completed.', 0);
    }
    return result;
  }

  // ───────────────────────── Yordamchilar ─────────────────────────

  void _tick(int offset) {
    steps++;
    if (_traceSuspended == 0) _lastUserOffset = offset;
    if (steps > options.maxSteps || (steps & 1023) == 0 && _clock.elapsed > options.timeout) {
      throw ExecutionAbort(
        'timeout',
        "Dastur juda uzoq ishladi va to'xtatildi. Ehtimol cheksiz sikl (infinite loop) bor.",
        'Execution timed out.',
        _lastUserOffset,
        hint: "Sikl sharti qachondir `false` bo'lishini tekshiring. Masalan, while (i < 5) ichida i ni oshirishni unutmang: i++;",
      );
    }
  }

  int lineOf(int offset) => lineMap.lineOf(offset.clamp(0, source.isEmpty ? 0 : source.length - 1));
  int columnOf(int offset) => lineMap.columnOf(offset.clamp(0, source.isEmpty ? 0 : source.length - 1));

  String _src(Node n) => _srcRange(n.offset, n.end);
  String _srcRange(int start, int end) {
    if (_traceSuspended > 0 || start < 0 || end > source.length || start >= end) return '';
    final s = source.substring(start, end).replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.length > 60 ? '${s.substring(0, 57)}...' : s;
  }

  void _write(String s) {
    if (_out.length + s.length > options.maxOutputChars) {
      _out.write(s.substring(0, (options.maxOutputChars - _out.length).clamp(0, s.length)));
      throw ExecutionAbort('output_limit', "Dastur juda ko'p matn chiqardi va to'xtatildi.",
          'Output limit exceeded.', _lastUserOffset,
          hint: "Sikl ichida print() cheksiz chaqirilmayotganini tekshiring.");
    }
    _out.write(s);
  }

  Never _throwDart(String className, List<Object?> args, int offset) {
    final k = classes[className]!;
    final inst = _instantiate(k, '', args, const {}, offset);
    throw DartThrow(inst, offset, List.of(_callStack.reversed));
  }

  Never _typeError(String text, int offset) => _throwDart('TypeError', [text], offset);

  Never _noSuchMethod(Object? target, String name, int offset, {bool getter = false}) {
    if (target == null) {
      _throwDart('NoSuchMethodError', [
        getter
            ? "NoSuchMethodError: The getter '$name' was called on null."
            : "NoSuchMethodError: The method '$name' was called on null.",
      ], offset);
    }
    _throwDart('NoSuchMethodError', [
      "NoSuchMethodError: Class '${typeName(target)}' has no instance ${getter ? 'getter' : 'method'} '$name'.",
    ], offset);
  }

  /// Native Dart xatolarini foydalanuvchi ushlay oladigan Dart xatolariga aylantiradi.
  T _guard<T>(T Function() body, int offset) {
    try {
      return body();
    } on DartThrow {
      rethrow;
    } on ExecutionAbort {
      rethrow;
    } on _ExitSignal {
      rethrow;
    } on FormatException catch (e) {
      _throwDart('FormatException', [e.message, e.source, e.offset], offset);
    } on RangeError catch (e) {
      _throwDart('RangeError', [e.toString()], offset);
    } on ArgumentError catch (e) {
      _throwDart('ArgumentError', [e.message], offset);
    } on StateError catch (e) {
      _throwDart('StateError', [e.message], offset);
    } on UnsupportedError catch (e) {
      _throwDart('UnsupportedError', [e.message], offset);
    } on ConcurrentModificationError {
      _throwDart('ConcurrentModificationError', [], offset);
    } on StackOverflowError {
      throw ExecutionAbort('stack_overflow', "Funksiya o'zini juda ko'p marta chaqirdi (Stack Overflow).",
          'Stack Overflow', offset);
    } on TypeError catch (e) {
      _typeError(_cleanNativeTypeError(e.toString()), offset);
    }
  }

  String _cleanNativeTypeError(String s) => s
      .replaceAll('KDouble', 'double')
      .replaceAll('KInstance', 'Object')
      .replaceAll('KFunction', 'Function')
      .replaceAll('_Map<Object?, Object?>', 'Map')
      .replaceAll('List<Object?>', 'List');

  // ───────────────────────── Turlar ─────────────────────────

  bool _isBuiltinTypeName(String n) => const {
    'Object', 'dynamic', 'int', 'double', 'num', 'String', 'bool', 'List', 'Map', 'Set', 'Iterable',
    'Function', 'Null', 'void', 'Never', 'Record', 'Comparable', 'Enum', 'StringBuffer', 'DateTime',
    'Random', 'Future', 'Stream', 'Type', 'Symbol', 'Pattern', 'RegExp', 'Iterator',
  }.contains(n);

  /// Qiymatning Dartdagi tur nomi (`runtimeType`).
  String typeName(Object? v) {
    if (v == null) return 'Null';
    final a = _asyncTypeName(v);
    if (a != null) return a;
    if (v is bool) return 'bool';
    if (v is int) return 'int';
    if (v is KDouble) return 'double';
    if (v is String) return 'String';
    if (v is List) return 'List<${_typeArgs[v] ?? _inferElementType(v)}>';
    if (v is Set) return '_Set<${_typeArgs[v] ?? _inferElementType(v)}>';
    if (v is Map) return '_Map<${_typeArgs[v] ?? '${_inferElementType(v.keys)}, ${_inferElementType(v.values)}'}>';
    if (v is Iterable) return 'Iterable<${_inferElementType(v.take(20))}>';
    if (v is KInstance) return v.klass.displayName;
    if (v is KClass) return 'Type';
    if (v is BuiltinType) return 'Type';
    if (v is KFunction) return v.signature();
    if (v is NativeFunction) return v.signature;
    if (v is KRecord) {
      final parts = [
        ...v.positional.map(typeName),
        if (v.named.isNotEmpty) '{${v.named.entries.map((e) => '${typeName(e.value)} ${e.key}').join(', ')}}',
      ];
      return '(${parts.join(', ')})';
    }
    if (v is StringBuffer) return 'StringBuffer';
    if (v is DateTime) return 'DateTime';
    if (v is KRandom) return 'Random';
    if (v is FNode) return v.type.split('.').first;
    if (v is FColor) return 'Color';
    if (v is FEnum) return v.type;
    if (v is FIcon) return 'IconData';
    if (v is FlutterType) return 'Type';
    return 'Object';
  }

  String _inferElementType(Iterable<Object?> items) {
    String? t;
    var nullable = false;
    for (final e in items) {
      if (e == null) {
        nullable = true;
        continue;
      }
      final n = e is List ? 'List<${_typeArgs[e] ?? _inferElementType(e)}>' : (e is Map ? 'Map' : typeName(e));
      if (t == null) {
        t = n;
      } else if (t != n) {
        t = (const {'int', 'double', 'num'}.contains(t) && const {'int', 'double'}.contains(n)) ? 'num' : 'Object';
      }
    }
    if (t == null) return nullable ? 'Null' : 'dynamic';
    return nullable ? '$t?' : t;
  }

  bool isType(Object? v, TypeAnnotation t) {
    final n = t.name;
    if (n == 'dynamic' || n == 'void') return true;
    if (v == null) return t.nullable || n == 'Null' || n == 'dynamic';
    final asyncCheck = _isAsyncType(v, t);
    if (asyncCheck != null) return asyncCheck;
    if (v is KFuture || v is KStream || v is KCompleter || v is KTimer || v is KStreamController || v is KSubscription) {
      return n == 'Object' || !classes.containsKey(n) && !_isBuiltinTypeName(n);
    }
    switch (n) {
      case 'Object':
        return true;
      case 'int':
        return v is int;
      case 'double':
        return v is KDouble;
      case 'num':
        return v is int || v is KDouble;
      case 'String':
        return v is String;
      case 'bool':
        return v is bool;
      case 'List':
        return v is List && _elementTypesOk(v, t);
      case 'Set':
        return v is Set && _elementTypesOk(v, t);
      case 'Map':
        return v is Map;
      case 'Iterable':
        return v is Iterable && v is! Map;
      case 'Function':
        return v is KFunction || v is NativeFunction || v is KClass;
      case 'Null':
        return false;
      case 'Never':
        return false;
      case 'Record':
        return v is KRecord;
      case 'Comparable':
        return v is int || v is KDouble || v is String;
      case 'StringBuffer':
        return v is StringBuffer;
      case 'DateTime':
        return v is DateTime;
      case 'Type':
        return v is KClass || v is BuiltinType;
      case 'Enum':
        return v is KInstance && v.klass.isEnum;
    }
    if (v is FNode || v is FColor || v is FEnum || v is FIcon || v is FlutterType) {
      if (v is FColor) return n == 'Color' || !classes.containsKey(n);
      return n == 'Widget' || !classes.containsKey(n);
    }
    // Noma'lum nom (masalan generic `T`) — tekshirib bo'lmaydi, qabul qilamiz.
    if (v is KInstance) return classes.containsKey(n) ? v.klass.isSubtypeOf(n) : true;
    // Noma'lum nom — generic tur parametri (T, E ...) deb hisoblaymiz.
    return !classes.containsKey(n);
  }

  bool _elementTypesOk(Iterable v, TypeAnnotation t) {
    if (t.args.isEmpty) return true;
    final declared = _typeArgs[v];
    final want = t.args.first;
    if (declared != null) {
      return declared == want.toString() || want.isDynamic || want.name == 'Object' ||
          (want.name == 'num' && (declared == 'int' || declared == 'double'));
    }
    return true;
  }

  /// Qiymatni e'lon qilingan turga moslaydi yoki TypeError chiqaradi.
  Object? _coerce(Object? value, TypeAnnotation? type, int offset, String what) {
    if (type == null) return value;
    final n = type.name;
    if (n == 'dynamic' || n == 'void' || n == 'Object' && type.nullable) return value;
    if (n == 'double' && value is int) return KDouble(value.toDouble());
    if (!isType(value, type)) {
      _typeError("type '${typeName(value)}' is not a subtype of type '$type' of '$what'", offset);
    }
    if (value is List && type.args.isNotEmpty && _typeArgs[value] == null) {
      _typeArgs[value] = type.args.first.toString();
    }
    if (value is Set && type.args.isNotEmpty && _typeArgs[value] == null) {
      _typeArgs[value] = type.args.first.toString();
    }
    if (value is Map && type.args.length == 2 && _typeArgs[value] == null) {
      _typeArgs[value] = '${type.args[0]}, ${type.args[1]}';
    }
    return value;
  }

  // ───────────────────────── O'zgaruvchilar ─────────────────────────

  Object? _lookup(String name, Env env, int offset) {
    Env? e = env;
    while (e != null) {
      final b = e.vars[name];
      if (b != null) {
        if (!b.initialized) {
          if (b.isLate) {
            _throwDart('LateInitializationError', ["Local variable '$name' has not been initialized."], offset);
          }
          throw ExecutionAbort('unassigned', "`$name` o'zgaruvchisiga qiymat berilmasdan turib ishlatildi.",
              "The non-nullable local variable '$name' must be assigned before it can be used.", offset,
              hint: "O'zgaruvchini e'lon qilganda unga boshlang'ich qiymat bering: int $name = 0;");
        }
        return b.value;
      }
      if (e.hasSelf) {
        final r = _lookupSelfMember(e, name, offset);
        if (!identical(r, _notFound)) return r;
      }
      if (e.staticClass != null) {
        final r = _lookupStatic(e.staticClass!, name, offset);
        if (!identical(r, _notFound)) return r;
      }
      e = e.parent;
    }
    final lib = _libraryLookup(name);
    if (!identical(lib, _notFound)) return lib;
    throw ExecutionAbort('undefined_name', "`$name` nomi aniqlanmagan.", "Undefined name '$name'.", offset);
  }

  Object? _libraryLookup(String name) {
    if (_builtins.containsKey(name)) return _builtins[name];
    for (final lib in _importedLibraries) {
      final m = _libraryMembers(lib);
      if (m.containsKey(name)) return m[name];
    }
    return _notFound;
  }

  Object? _lookupSelfMember(Env e, String name, int offset) {
    final self = e.self;
    if (self is KInstance) {
      if (self.fields.containsKey(name)) return self.fields[name];
      final g = self.klass.findGetter(name);
      if (g != null) return _callGetter(g.$1, g.$2, self, offset);
      final m = self.klass.findMethod(name);
      if (m != null) return _makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(self, self.klass);
      if (self.klass.isEnum && name == 'name') return self.enumName;
      if (self.klass.isEnum && name == 'index') return self.enumIndex;
      final ext = _findExtension(self, name);
      if (ext != null) return _findExtensionValue(self, name, offset);
      return _notFound;
    }
    if (e.selfClass == null && self != null) {
      // extension ichida: this — oddiy qiymat.
      final ext = _findExtension(self, name);
      if (ext != null) {
        if (ext.isGetter) return _invoke(_makeFunction(ext, globals).bind(self, null), const [], const {}, offset);
        return _makeFunction(ext, globals).bind(self, null);
      }
      final g = _guard(() => _builtinGetter(self, name, offset), offset);
      if (!identical(g, _notFound)) return g;
      if (_hasBuiltinMethod(self, name)) {
        return NativeFunction(name, (p, n) => _callMethod(self, name, p, n, offset));
      }
      return _notFound;
    }
    return _notFound;
  }

  Object? _lookupStatic(KClass k, String name, int offset) {
    final b = k.statics[name];
    if (b != null) return b.value;
    final g = k.staticGetters[name];
    if (g != null) return _invoke(_makeFunction(g, k.staticEnv, owner: k), const [], const {}, offset);
    final m = k.staticMethods[name];
    if (m != null) return _makeFunction(m, k.staticEnv, owner: k);
    return _notFound;
  }

  void _assignVar(String name, Object? value, Env env, int offset) {
    Env? e = env;
    while (e != null) {
      final b = e.vars[name];
      if (b != null) {
        if (b.isFinal && (b.initialized || !b.isLate)) {
          throw ExecutionAbort('assign_final', "`$name` final (o'zgarmas) — unga qayta qiymat berib bo'lmaydi.",
              "The final variable '$name' can only be set once.", offset,
              hint: "Agar qiymat o'zgarishi kerak bo'lsa, `final` o'rniga `var` ishlating.");
        }
        b.value = _coerce(value, b.type, offset, name);
        b.initialized = true;
        return;
      }
      if (e.hasSelf && e.self is KInstance) {
        final self = e.self as KInstance;
        final setter = self.klass.findSetter(name);
        if (setter != null) {
          _invoke(_makeFunction(setter.$1, setter.$2.staticEnv, owner: setter.$2).bind(self, self.klass), [value], const {}, offset);
          return;
        }
        if (self.fields.containsKey(name)) {
          _setField(self, name, value, offset);
          return;
        }
      }
      if (e.staticClass != null) {
        final sb = e.staticClass!.statics[name];
        if (sb != null) {
          if (sb.isFinal) {
            throw ExecutionAbort('assign_final', "`$name` final — o'zgartirib bo'lmaydi.",
                "The final variable '$name' can only be set once.", offset);
          }
          sb.value = _coerce(value, sb.type, offset, name);
          return;
        }
      }
      e = e.parent;
    }
    throw ExecutionAbort('undefined_name', "`$name` nomi aniqlanmagan.", "Undefined name '$name'.", offset);
  }

  void _setField(KInstance obj, String name, Object? value, int offset) {
    if (obj.klass.hasFinalField(name)) {
      throw ExecutionAbort('assign_final_field', "`$name` maydoni final — obyekt yaratilgandan keyin uni o'zgartirib bo'lmaydi.",
          "'$name' can't be used as a setter because it's final.", offset);
    }
    final type = _fieldType(obj.klass, name);
    obj.fields[name] = _coerce(value, type, offset, name);
  }

  TypeAnnotation? _fieldType(KClass k, String name) {
    KClass? c = k;
    while (c != null) {
      for (final f in c.instanceFields) {
        for (final v in f.decl.vars) {
          if (v.name == name) return f.decl.type;
        }
      }
      c = c.superclass;
    }
    return null;
  }

  // ───────────────────────── Bayonotlar ─────────────────────────

  _Completion? _execBlock(List<Stmt> stmts, Env env) {
    for (final s in stmts) {
      final c = _exec(s, env);
      if (c != null) return c;
    }
    return null;
  }

  _Completion? _exec(Stmt s, Env env, {String? label}) {
    _tick(s.offset);
    switch (s) {
      case Block():
        return _execBlock(s.statements, Env(env));
      case VarDecl():
        _execVarDecl(s, env);
        return null;
      case ExprStmt():
        _eval(s.expr, env);
        return null;
      case IfStmt():
        final cond = _condition(s.condition, env, 'if');
        _record(TraceKind.condition, s.condition.offset, s.condition.end - s.condition.offset,
            cond
                ? "Shart `${_src(s.condition)}` → true. Shuning uchun if bloki bajariladi."
                : (s.otherwise != null
                    ? "Shart `${_src(s.condition)}` → false. Shuning uchun else bloki bajariladi."
                    : "Shart `${_src(s.condition)}` → false. if bloki o'tkazib yuboriladi."),
            env: env);
        if (cond) return _exec(s.then, Env(env));
        if (s.otherwise != null) return _exec(s.otherwise!, Env(env));
        return null;
      case WhileStmt():
        var iteration = 0;
        while (true) {
          final cond = _condition(s.condition, env, 'while');
          _record(TraceKind.loop, s.condition.offset, s.condition.end - s.condition.offset,
              cond
                  ? "Sikl sharti `${_src(s.condition)}` → true. Sikl tanasi ${++iteration}-marta bajariladi."
                  : "Sikl sharti `${_src(s.condition)}` → false. Sikl tugadi.",
              env: env);
          if (!cond) break;
          final c = _exec(s.body, Env(env));
          if (c is _Break && (c.label == null || c.label == label)) break;
          if (c is _Continue && (c.label == null || c.label == label)) continue;
          if (c != null) return c;
        }
        return null;
      case DoWhileStmt():
        while (true) {
          final c = _exec(s.body, Env(env));
          if (c is _Break && (c.label == null || c.label == label)) break;
          if (c != null && c is! _Continue) return c;
          if (c is _Continue && c.label != null && c.label != label) return c;
          final cond = _condition(s.condition, env, 'do-while');
          _record(TraceKind.loop, s.condition.offset, s.condition.end - s.condition.offset,
              "do-while sharti `${_src(s.condition)}` → $cond.", env: env);
          if (!cond) break;
        }
        return null;
      case ForStmt():
        return _execFor(s, env, label);
      case ForInStmt():
        if (s.isAwait) {
          throw ExecutionAbort('await_for_outside_async', "`await for` faqat `async` funksiya ichida ishlatiladi.",
              "Asynchronous for-in can only be used in functions marked with 'async' or 'async*'.", s.offset);
        }
        return _execForIn(s, env, label);
      case YieldStmt():
        throw ExecutionAbort('yield_outside_generator', "`yield` faqat generator (`sync*` yoki `async*`) funksiyada ishlatiladi.",
            "Yield statements must be in a generator function.", s.offset);
      case BreakStmt():
        _record(TraceKind.branch, s.offset, s.end - s.offset, "`break` — sikldan chiqiladi.", env: env);
        return s.label == null ? _plainBreak : _Break(s.label);
      case ContinueStmt():
        _record(TraceKind.branch, s.offset, s.end - s.offset, "`continue` — keyingi aylanishga o'tiladi.", env: env);
        return s.label == null ? _plainContinue : _Continue(s.label);
      case ReturnStmt():
        final v = s.value == null ? null : _eval(s.value!, env);
        return _Return(v);
      case SwitchStmt():
        return _execSwitch(s, env, label);
      case TryStmt():
        return _execTry(s, env);
      case RethrowStmt():
        final b = _findRethrow(env);
        if (b == null) {
          throw ExecutionAbort('rethrow_outside_catch', "`rethrow` faqat catch bloki ichida ishlatiladi.",
              "A rethrow must be inside of a catch clause.", s.offset);
        }
        throw b;
      case AssertStmt():
        final ok = _eval(s.condition, env);
        if (ok != true) {
          final msg = s.message == null ? null : _eval(s.message!, env);
          _throwDart('AssertionError', [msg ?? "'${_srcRange(s.condition.offset, s.condition.end)}': is not true."], s.offset);
        }
        return null;
      case LocalFunctionStmt():
        env.define(s.function.name, Binding(_makeFunction(s.function, env), isFinal: true));
        return null;
      case LabeledStmt():
        final c = _exec(s.body, env, label: s.label);
        if (c is _Break && c.label == s.label) return null;
        return c;
      case EmptyStmt():
        return null;
    }
  }

  DartThrow? _findRethrow(Env env) {
    Env? e = env;
    while (e != null) {
      final b = e.vars[r'$caught'];
      if (b != null) return b.value as DartThrow;
      e = e.parent;
    }
    return null;
  }

  bool _condition(Expr e, Env env, String what) {
    final v = _eval(e, env);
    if (v is! bool) {
      _typeError("type '${typeName(v)}' is not a subtype of type 'bool' ($what sharti)", e.offset);
    }
    return v;
  }

  void _execVarDecl(VarDecl s, Env env) {
    for (final v in s.vars) {
      _declareVar(s, v, v.init == null ? null : _eval(v.init!, env), env, uninitialized: v.init == null);
    }
  }

  void _declareVar(VarDecl s, VarDeclarator v, Object? initValue, Env env, {bool uninitialized = false}) {
    if (uninitialized) {
      env.define(v.name, Binding(null,
          isFinal: s.isFinal || s.isConst,
          type: s.type,
          initialized: s.type == null || s.type!.nullable || s.type!.isDynamic,
          isLate: s.isLate));
      if (env == globals || s.type == null || s.type!.nullable) {
        env.vars[v.name]!.initialized = true;
      }
      _record(TraceKind.declare, v.offset, v.name.length,
          "`${v.name}` o'zgaruvchisi e'lon qilindi${s.type != null ? ' (turi: ${s.type})' : ''}, hali qiymati yo'q.",
          env: env, changed: [v.name]);
      return;
    }
    var value = initValue;
    value = _coerce(value, s.type, v.offset, v.name);
    if ((s.type == null || s.type!.args.isEmpty) && (value is List || value is Set) && _typeArgs[value as Object] == null) {
      // `var a = [1, 2]` — tur elementlardan chiqariladi (List<int>).
      final inferred = _inferElementType(value as Iterable<Object?>);
      if (inferred != 'dynamic') _typeArgs[value] = inferred;
    }
    env.define(v.name, Binding(value, isFinal: s.isFinal || s.isConst, type: s.type ?? _inferDeclType(value, s)));
    _record(TraceKind.declare, v.offset, v.name.length, _declDescription(s, v, value), env: env, changed: [v.name]);
  }

  /// `var x = 5;` — Dart x ning turini `int` deb aniqlaydi va keyin String berib bo'lmaydi.
  TypeAnnotation? _inferDeclType(Object? value, VarDecl s) {
    if (!s.isVar || value == null) return null;
    if (value is int) return TypeAnnotation('int');
    if (value is KDouble) return TypeAnnotation('double');
    if (value is String) return TypeAnnotation('String');
    if (value is bool) return TypeAnnotation('bool');
    return null;
  }

  _Completion? _execFor(ForStmt s, Env env, String? label) {
    final loopEnv = Env(env);
    if (s.init != null) _exec(s.init!, loopEnv);
    var iteration = 0;
    while (true) {
      if (s.condition != null) {
        final cond = _condition(s.condition!, loopEnv, 'for');
        _record(TraceKind.loop, s.condition!.offset, s.condition!.end - s.condition!.offset,
            cond
                ? "Sikl sharti `${_src(s.condition!)}` → true. ${++iteration}-aylanish boshlanadi."
                : "Sikl sharti `${_src(s.condition!)}` → false. Sikl tugadi.",
            env: loopEnv);
        if (!cond) break;
      }
      // Har bir aylanish uchun o'zgaruvchining alohida nusxasi (closure'lar uchun Dart qoidasi).
      final iterEnv = Env(env);
      for (final e in loopEnv.vars.entries) {
        final b = e.value;
        iterEnv.vars[e.key] = Binding(b.value, isFinal: b.isFinal, type: b.type, initialized: b.initialized);
      }
      final c = _exec(s.body, iterEnv);
      for (final e in iterEnv.vars.entries) {
        loopEnv.vars[e.key]?.value = e.value.value;
      }
      if (c is _Break && (c.label == null || c.label == label)) break;
      if (c != null && c is! _Continue) return c;
      if (c is _Continue && c.label != null && c.label != label) return c;
      for (final u in s.updates) {
        _tick(u.offset);
        _eval(u, loopEnv);
      }
    }
    return null;
  }

  _Completion? _execForIn(ForInStmt s, Env env, String? label) {
    final iterable = _eval(s.iterable, env);
    final items = _iterableOf(iterable, s.iterable.offset, 'for-in');
    var i = 0;
    for (final item in items) {
      _tick(s.offset);
      final iterEnv = Env(env);
      if (s.declares) {
        iterEnv.define(s.name, Binding(_coerce(item, s.type, s.offset, s.name), isFinal: s.isFinal, type: s.type));
      } else {
        _assignVar(s.name, item, env, s.offset);
      }
      _record(TraceKind.loop, s.offset, 3,
          "${++i}-aylanish: `${s.name}` = ${_preview(item)}", env: iterEnv, changed: [s.name]);
      final c = _guard(() => _exec(s.body, iterEnv), s.offset);
      if (c is _Break && (c.label == null || c.label == label)) break;
      if (c is _Continue && (c.label == null || c.label == label)) continue;
      if (c != null) return c;
    }
    return null;
  }

  Iterable<Object?> _iterableOf(Object? v, int offset, String what) {
    if (v is Iterable && v is! Map) return v.cast<Object?>();
    if (v is Map) {
      _typeError("type '${typeName(v)}' is not a subtype of type 'Iterable<dynamic>'. Map'ni to'g'ridan-to'g'ri aylanib bo'lmaydi — .keys, .values yoki .entries dan foydalaning.", offset);
    }
    if (v is String) {
      _typeError("type 'String' is not a subtype of type 'Iterable<dynamic>'. Harflarni aylanish uchun .split('') ishlating.", offset);
    }
    _typeError("type '${typeName(v)}' is not a subtype of type 'Iterable<dynamic>' ($what)", offset);
  }

  _Completion? _execSwitch(SwitchStmt s, Env env, String? label) {
    final (chosen, caseEnv) = _chooseCase(s, _eval(s.subject, env), env);
    if (chosen == null) return null;
    final c = _execBlock(chosen.body, caseEnv!);
    if (c is _Break && (c.label == null || c.label == label)) return null;
    return c;
  }

  (SwitchCase?, Env?) _chooseCase(SwitchStmt s, Object? subject, Env env) {
    SwitchCase? chosen;
    Env? caseEnv;
    for (final c in s.cases) {
      if (c.isDefault && c.patterns.isEmpty) continue;
      for (var i = 0; i < c.patterns.length; i++) {
        final pe = Env(env);
        if (_match(c.patterns[i], subject, pe) && (c.guards[i] == null || _eval(c.guards[i]!, pe) == true)) {
          chosen = c;
          caseEnv = pe;
          break;
        }
      }
      if (chosen != null) break;
    }
    if (chosen == null) {
      for (final c in s.cases) {
        if (c.isDefault) {
          chosen = c;
          caseEnv = Env(env);
        }
      }
    }
    _record(TraceKind.branch, s.subject.offset, s.subject.end - s.subject.offset,
        chosen == null
            ? "switch: `${_src(s.subject)}` = ${_preview(subject)} — mos case topilmadi."
            : "switch: `${_src(s.subject)}` = ${_preview(subject)} → ${chosen.isDefault && chosen.patterns.isEmpty ? 'default' : 'mos case'} bajariladi.",
        env: env);
    return (chosen, caseEnv);
  }

  bool _match(Pattern p, Object? value, Env env) {
    switch (p) {
      case WildcardPattern():
        return true;
      case ConstPattern():
        return _equals(value, _eval(p.expr, env), p.offset);
      case RelationalPattern():
        final other = _eval(p.expr, env);
        if (p.op == '==') return _equals(value, other, p.offset);
        if (p.op == '!=') return !_equals(value, other, p.offset);
        if (value is! int && value is! KDouble) return false;
        return _binary(p.op, value, other, p.offset) == true;
      case OrPattern():
        return _match(p.left, value, env) || _match(p.right, value, env);
      case AndPattern():
        return _match(p.left, value, env) && _match(p.right, value, env);
      case BindingPattern():
        if (p.type != null && !isType(value, p.type!)) return false;
        if (p.name != null) env.define(p.name!, Binding(value, type: p.type));
        return true;
    }
  }

  _Completion? _execTry(TryStmt s, Env env) {
    _Completion? result;
    try {
      try {
        result = _execBlock(s.body.statements, Env(env));
      } on DartThrow catch (ex) {
        final handler = _handlerFor(s, ex);
        if (handler == null) rethrow;
        result = _execBlock(handler.body.statements, _catchEnv(handler, ex, env));
      }
    } finally {
      if (s.finallyBlock != null) {
        final f = _execBlock(s.finallyBlock!.statements, Env(env));
        if (f != null) result = f;
      }
    }
    return result;
  }

  CatchClause? _handlerFor(TryStmt s, DartThrow ex) {
    for (final c in s.catches) {
      if (c.onType == null || isType(ex.value, c.onType!)) return c;
    }
    return null;
  }

  Env _catchEnv(CatchClause handler, DartThrow ex, Env env) {
    final ce = Env(env);
    ce.define(r'$caught', Binding(ex, isFinal: true));
    if (handler.exceptionName != null) ce.define(handler.exceptionName!, Binding(ex.value, isFinal: true));
    if (handler.stackName != null) {
      ce.define(handler.stackName!, Binding(ex.stack.map((f) => '#  $f').join('\n'), isFinal: true));
    }
    _record(TraceKind.branch, handler.body.offset, 1, "Xato ushlandi (catch): ${_stringifySafe(ex.value)}", env: ce);
    return ce;
  }

  // ───────────────────────── Ifodalar ─────────────────────────

  Object? _eval(Expr e, Env env) {
    switch (e) {
      case Literal():
        return e.value;
      case StringInterp():
        final buf = StringBuffer();
        for (final p in e.parts) {
          buf.write(p is String ? p : stringify(_eval(p as Expr, env), (p).offset));
        }
        return buf.toString();
      case Identifier():
        return _lookup(e.name, env, e.offset);
      case ThisExpr():
        return _findSelf(env, e.offset);
      case SuperExpr():
        return _findSelf(env, e.offset);
      case ListLiteral():
        final list = <Object?>[];
        for (final el in e.elements) {
          _evalElement(el, env, (v) => list.add(v), null);
        }
        return _finishList(e, list);
      case SetOrMapLiteral():
        if (e.isMap) {
          final map = <Object?, Object?>{};
          for (final el in e.elements) {
            _evalElement(el, env, null, (k, v) => map[k] = v);
          }
          if (e.typeArgs.length == 2) _typeArgs[map] = '${e.typeArgs[0]}, ${e.typeArgs[1]}';
          return e.isConst ? Map<Object?, Object?>.unmodifiable(map) : map;
        }
        final set = <Object?>{};
        for (final el in e.elements) {
          _evalElement(el, env, (v) => set.add(v), null);
        }
        if (e.typeArgs.length == 1) _typeArgs[set] = e.typeArgs.first.toString();
        return set;
      case RecordLiteral():
        return KRecord([for (final p in e.positional) _eval(p, env)],
            {for (final n in e.named.entries) n.key: _eval(n.value, env)});
      case UnaryExpr():
        return _unary(e, _eval(e.operand, env));
      case IncDecExpr():
        final old = _eval(e.target, env);
        if (old is! int && old is! KDouble) {
          if (old == null) {
            _noSuchMethod(null, e.op == '++' ? '+' : '-', e.offset);
          }
          _typeError("'${e.op}' faqat sonlarga qo'llanadi, lekin ${typeName(old)} berildi", e.offset);
        }
        final updated = _binary(e.op == '++' ? '+' : '-', old, 1, e.offset);
        _assignTo(e.target, updated, env, e.offset);
        if (e.target is Identifier) {
          final n = (e.target as Identifier).name;
          _record(TraceKind.assign, e.offset, e.end - e.offset,
              "`$n` ${e.op == '++' ? '1 ga oshirildi' : '1 ga kamaytirildi'}: ${_preview(old)} → ${_preview(updated)}",
              env: env, changed: [n]);
        }
        return e.prefix ? updated : old;
      case BinaryExpr():
        switch (e.op) {
          case '&&':
            final l = _eval(e.left, env);
            if (l is! bool) _typeError("type '${typeName(l)}' is not a subtype of type 'bool'", e.left.offset);
            if (!l) return false;
            final r = _eval(e.right, env);
            if (r is! bool) _typeError("type '${typeName(r)}' is not a subtype of type 'bool'", e.right.offset);
            return r;
          case '||':
            final l = _eval(e.left, env);
            if (l is! bool) _typeError("type '${typeName(l)}' is not a subtype of type 'bool'", e.left.offset);
            if (l) return true;
            final r = _eval(e.right, env);
            if (r is! bool) _typeError("type '${typeName(r)}' is not a subtype of type 'bool'", e.right.offset);
            return r;
          case '??':
            final l = _eval(e.left, env);
            return l ?? _eval(e.right, env);
        }
        final l = _eval(e.left, env);
        final r = _eval(e.right, env);
        return _binary(e.op, l, r, e.opOffset);
      case ConditionalExpr():
        return _condition(e.condition, env, '?:') ? _eval(e.then, env) : _eval(e.otherwise, env);
      case AssignExpr():
        return _evalAssign(e, env);
      case PropertyGet():
        if (e.target is SuperExpr) return _superGet(e.name, env, e.offset);
        final t = _eval(e.target, env);
        if (t == null && e.nullAware) return null;
        return _getProperty(t, e.name, e.nameOffset);
      case IndexExpr():
        final t = _eval(e.target, env);
        if (t == null && e.nullAware) return null;
        final i = _eval(e.index, env);
        return _index(t, i, e.offset);
      case CallExpr():
        final callee = _eval(e.callee, env);
        final (pos, named) = _evalArgs(e.args, env);
        return _callValue(callee, pos, named, e.offset,
            name: e.callee is Identifier ? (e.callee as Identifier).name : null, typeArgs: e.typeArgs);
      case MethodCall():
        return _evalMethodCall(e, env);
      case CascadeExpr():
        final target = _eval(e.target, env);
        _cascadeStack.add(target);
        try {
          for (final s in e.sections) {
            _eval(s, env);
          }
        } finally {
          _cascadeStack.removeLast();
        }
        return target;
      case CascadeTarget():
        return _cascadeStack.last;
      case FunctionExpr():
        return KFunction(name: '', params: e.params, body: e.body, closure: env, isAsync: e.isAsync, isGenerator: e.isGenerator);
      case IsExpr():
        final v = _eval(e.expr, env);
        final r = isType(v, e.type);
        return e.negated ? !r : r;
      case AsExpr():
        return _asCast(e, _eval(e.expr, env));
      case NullAssertExpr():
        final v = _eval(e.expr, env);
        if (v == null) _typeError('Null check operator used on a null value', e.offset);
        return v;
      case ThrowExpr():
        final v = _eval(e.expr, env);
        if (v == null) _typeError('Throw of null.', e.offset);
        _record(TraceKind.error, e.offset, e.end - e.offset, "Xato tashlandi (throw): ${_stringifySafe(v)}", env: env);
        throw DartThrow(v, e.offset, List.of(_callStack.reversed));
      case AwaitExpr():
        throw ExecutionAbort('await_outside_async',
            "`await` faqat `async` funksiya ichida ishlatiladi (yoki bu joyda hozircha qo'llab-quvvatlanmaydi).",
            "The await expression can only be used in an async function.", e.offset,
            hint: "Funksiya tanasidan oldin `async` yozing: Future<void> main() async { ... }");
      case SwitchExpr():
        final subject = _eval(e.subject, env);
        for (final c in e.cases) {
          final ce = Env(env);
          if (_match(c.pattern, subject, ce) && (c.guard == null || _eval(c.guard!, ce) == true)) {
            return _eval(c.body, ce);
          }
        }
        _throwDart('StateError', ["switch ifodasida ${_preview(subject)} uchun mos holat topilmadi"], e.offset);
    }
  }

  Object? _unary(UnaryExpr e, Object? v) {
    switch (e.op) {
      case '!':
        if (v is! bool) _typeError("type '${typeName(v)}' is not a subtype of type 'bool'", e.offset);
        return !v;
      case '-':
        if (v is int) return -v;
        if (v is KDouble) return KDouble(-v.value);
        if (v is KInstance) return _callOperator(v, 'unary-', [], e.offset);
        _typeError("'-' operatori ${typeName(v)} uchun aniqlanmagan", e.offset);
      case '~':
        if (v is int) return ~v;
        _typeError("'~' operatori ${typeName(v)} uchun aniqlanmagan", e.offset);
    }
    return null;
  }

  Object? _asCast(AsExpr e, Object? v) {
    if (e.type.name == 'double' && v is int) {
      _typeError("type 'int' is not a subtype of type 'double' in type cast", e.offset);
    }
    if (!isType(v, e.type)) {
      _typeError("type '${typeName(v)}' is not a subtype of type '${e.type}' in type cast", e.offset);
    }
    return v;
  }

  List<Object?> _finishList(ListLiteral e, List<Object?> list) {
    if (e.typeArg != null) {
      _typeArgs[list] = e.typeArg.toString();
      for (final v in list) {
        if (!isType(v, e.typeArg!) && !(e.typeArg!.name == 'double' && v is int)) {
          _typeError("type '${typeName(v)}' is not a subtype of type '${e.typeArg}'", e.offset);
        }
      }
    }
    return e.isConst ? List<Object?>.unmodifiable(list) : list;
  }

  Object? _findSelf(Env env, int offset) {
    Env? e = env;
    while (e != null) {
      if (e.hasSelf) return e.self;
      e = e.parent;
    }
    throw ExecutionAbort('this_outside_class', "`this` faqat class metodlari ichida ishlatiladi.",
        "Invalid reference to 'this' expression.", offset);
  }

  Env? _findSelfEnv(Env env) {
    Env? e = env;
    while (e != null) {
      if (e.hasSelf) return e;
      e = e.parent;
    }
    return null;
  }

  void _evalElement(CollectionElement el, Env env, void Function(Object?)? add, void Function(Object?, Object?)? put) {
    switch (el) {
      case ExprElement():
        if (add == null) {
          throw ExecutionAbort('expected_map_entry', "Map ichida `kalit: qiymat` ko'rinishi kerak.",
              'Expected a map entry.', el.offset);
        }
        add(_eval(el.expr, env));
      case MapEntryElement():
        if (put == null) {
          throw ExecutionAbort('unexpected_map_entry', "Ro'yxat yoki Set ichida `kalit: qiymat` yozib bo'lmaydi.",
              'Unexpected map entry.', el.offset);
        }
        put(_eval(el.key, env), _eval(el.value, env));
      case SpreadElement():
        final v = _eval(el.expr, env);
        if (v == null && el.nullAware) return;
        if (put != null && v is Map) {
          v.forEach((k, val) => put(k, val));
        } else if (add != null) {
          for (final x in _iterableOf(v, el.offset, 'spread (...)')) {
            add(x);
          }
        }
      case IfElement():
        if (_condition(el.condition, env, 'collection-if')) {
          _evalElement(el.then, env, add, put);
        } else if (el.otherwise != null) {
          _evalElement(el.otherwise!, env, add, put);
        }
      case ForElement():
        final loop = el.loop;
        if (loop is ForInStmt) {
          for (final item in _iterableOf(_eval(loop.iterable, env), loop.offset, 'collection-for')) {
            _tick(el.offset);
            final ie = Env(env)..define(loop.name, Binding(item, type: loop.type));
            _evalElement(el.body, ie, add, put);
          }
        } else if (loop is ForStmt) {
          final le = Env(env);
          if (loop.init != null) _exec(loop.init!, le);
          while (loop.condition == null || _condition(loop.condition!, le, 'collection-for')) {
            _tick(el.offset);
            _evalElement(el.body, Env(le), add, put);
            for (final u in loop.updates) {
              _eval(u, le);
            }
          }
        }
    }
  }

  (List<Object?>, Map<String, Object?>) _evalArgs(Arguments a, Env env) {
    final pos = <Object?>[for (final p in a.positional) _eval(p, env)];
    final named = <String, Object?>{for (final n in a.named.entries) n.key: _eval(n.value, env)};
    return (pos, named);
  }

  Object? _evalAssign(AssignExpr e, Env env) {
    Object? value;
    if (e.op == '=') {
      value = _eval(e.value, env);
    } else if (e.op == '??=') {
      final current = _eval(e.target, env);
      if (current != null) return current;
      value = _eval(e.value, env);
    } else {
      final current = _eval(e.target, env);
      final rhs = _eval(e.value, env);
      value = _binary(e.op.substring(0, e.op.length - 1), current, rhs, e.offset);
    }
    Object? old;
    final isIdent = e.target is Identifier;
    if (isIdent && _traceOn) {
      try {
        old = _lookup((e.target as Identifier).name, env, e.offset);
      } on ExecutionAbort {
        old = null;
      }
    }
    _assignTo(e.target, value, env, e.offset);
    if (isIdent) {
      final n = (e.target as Identifier).name;
      _record(TraceKind.assign, e.offset, e.end - e.offset,
          e.op == '='
              ? "`$n` ga yangi qiymat berildi: ${_preview(old)} → ${_preview(value)}"
              : "`$n ${e.op} ${_src(e.value)}` → `$n` endi ${_preview(value)} (oldin ${_preview(old)})",
          env: env, changed: [n]);
    } else if (e.target is PropertyGet) {
      _record(TraceKind.assign, e.offset, e.end - e.offset,
          "`${_src(e.target)}` = ${_preview(value)}", env: env);
    } else if (e.target is IndexExpr) {
      _record(TraceKind.assign, e.offset, e.end - e.offset,
          "`${_src(e.target)}` = ${_preview(value)}", env: env);
    }
    return value;
  }

  void _assignTo(Expr target, Object? value, Env env, int offset) {
    switch (target) {
      case Identifier():
        _assignVar(target.name, value, env, target.offset);
      case PropertyGet():
        final obj = target.target is SuperExpr ? _findSelf(env, offset) : _eval(target.target, env);
        if (obj == null && target.nullAware) return;
        _setProperty(obj, target.name, value, target.nameOffset);
      case IndexExpr():
        final obj = _eval(target.target, env);
        final idx = _eval(target.index, env);
        _indexSet(obj, idx, value, target.offset);
      default:
        throw ExecutionAbort('invalid_assignment', "Bu ifodaga qiymat berib bo'lmaydi.", 'Invalid assignment target.', offset);
    }
  }

  Object? _evalMethodCall(MethodCall e, Env env) {
    if (e.target is SuperExpr) {
      final selfEnv = _findSelfEnv(env);
      final owner = selfEnv?.staticClass;
      final self = selfEnv?.self;
      final (pos, named) = _evalArgs(e.args, env);
      final found = owner?.superclass?.findMethod(e.name);
      if (found != null && self is KInstance) {
        final f = _makeFunction(found.$1, found.$2.staticEnv, owner: found.$2).bind(self, self.klass);
        return _invoke(f, pos, named, e.offset);
      }
      if (e.name == 'toString' && self is KInstance) return "Instance of '${self.klass.displayName}'";
      _noSuchMethod(self, e.name, e.nameOffset);
    }
    final target = _eval(e.target, env);
    if (target == null && e.nullAware) return null;
    final (pos, named) = _evalArgs(e.args, env);
    return _callMethod(target, e.name, pos, named, e.nameOffset, typeArgs: e.typeArgs);
  }

  Object? _superGet(String name, Env env, int offset) {
    final selfEnv = _findSelfEnv(env);
    final owner = selfEnv?.staticClass;
    final self = selfEnv?.self;
    if (self is KInstance) {
      final g = owner?.superclass?.findGetter(name);
      if (g != null) return _callGetter(g.$1, g.$2, self, offset);
      if (self.fields.containsKey(name)) return self.fields[name];
    }
    return _getProperty(self, name, offset);
  }

  // ───────────────────────── Operatorlar ─────────────────────────

  bool _equals(Object? a, Object? b, int offset) {
    if (a is KInstance && !a.klass.isEnum) {
      final op = a.klass.findMethod('==');
      if (op != null) {
        if (b == null) return false;
        return _invoke(_makeFunction(op.$1, op.$2.staticEnv, owner: op.$2).bind(a, a.klass), [b], const {}, offset) == true;
      }
    }
    if (a is int && b is KDouble) return a.toDouble() == b.value;
    if (a is KDouble && b is int) return a.value == b.toDouble();
    return a == b;
  }

  Object? _callOperator(KInstance obj, String op, List<Object?> args, int offset) {
    final m = obj.klass.findMethod(op == 'unary-' ? '-' : op);
    if (m == null) {
      throw ExecutionAbort('undefined_operator',
          "`${obj.klass.displayName}` class'ida `$op` operatori aniqlanmagan.",
          "The operator '$op' isn't defined for the type '${obj.klass.displayName}'.", offset);
    }
    return _invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(obj, obj.klass), args, const {}, offset);
  }

  Object? _binary(String op, Object? l, Object? r, int offset) {
    if (op == '==') return _equals(l, r, offset);
    if (op == '!=') return !_equals(l, r, offset);
    if (l is int && r is int) {
      switch (op) {
        case '+':
          return l + r;
        case '-':
          return l - r;
        case '*':
          return l * r;
        case '/':
          return KDouble(l / r);
        case '~/':
          if (r == 0) _throwDart('IntegerDivisionByZeroException', [], offset);
          return l ~/ r;
        case '%':
          if (r == 0) _throwDart('IntegerDivisionByZeroException', [], offset);
          return l % r;
        case '<':
          return l < r;
        case '>':
          return l > r;
        case '<=':
          return l <= r;
        case '>=':
          return l >= r;
        case '&':
          return l & r;
        case '|':
          return l | r;
        case '^':
          return l ^ r;
        case '<<':
          return l << r;
        case '>>':
          return l >> r;
        case '>>>':
          return l >>> r;
      }
    }
    if ((l is int || l is KDouble) && (r is int || r is KDouble)) {
      final a = l is int ? l.toDouble() : (l as KDouble).value;
      final b = r is int ? r.toDouble() : (r as KDouble).value;
      switch (op) {
        case '+':
          return KDouble(a + b);
        case '-':
          return KDouble(a - b);
        case '*':
          return KDouble(a * b);
        case '/':
          return KDouble(a / b);
        case '~/':
          if (b == 0) _throwDart('UnsupportedError', ['Result of truncating division is Infinity'], offset);
          return (a / b).truncate();
        case '%':
          return KDouble(a % b);
        case '<':
          return a < b;
        case '>':
          return a > b;
        case '<=':
          return a <= b;
        case '>=':
          return a >= b;
      }
    }
    if (l is String) {
      if (op == '+') {
        if (r is String) return l + r;
        _typeError("type '${typeName(r)}' is not a subtype of type 'String'", offset);
      }
      if (op == '*' && r is int) return r < 0 ? '' : l * r;
      if (const {'<', '>', '<=', '>='}.contains(op)) {
        _noSuchMethodOperator(l, op, offset);
      }
    }
    if (l is bool && r is bool) {
      switch (op) {
        case '&':
          return l & r;
        case '|':
          return l | r;
        case '^':
          return l ^ r;
      }
    }
    if (l is List && r is List && op == '+') return <Object?>[...l, ...r];
    if (l is KInstance) return _callOperator(l, op, [r], offset);
    if (l is DateTime && r is KInstance && op == '+') return l;
    if (l == null) {
      _noSuchMethod(null, op, offset);
    }
    _noSuchMethodOperator(l, op, offset, right: r);
  }

  Never _noSuchMethodOperator(Object? l, String op, int offset, {Object? right}) {
    if ((l is int || l is KDouble) && right is String && op == '+') {
      _typeError("type 'String' is not a subtype of type 'num'", offset);
    }
    _typeError("'$op' operatori '${typeName(l)}' va '${typeName(right)}' uchun aniqlanmagan", offset);
  }

  // ───────────────────────── Chaqiruvlar ─────────────────────────

  Object? _callValue(Object? callee, List<Object?> pos, Map<String, Object?> named, int offset,
      {String? name, List<TypeAnnotation> typeArgs = const []}) {
    if (callee is KFunction) return _invoke(callee, pos, named, offset);
    if (callee is NativeFunction) return _guard(() => callee.impl(pos, named), offset);
    if (callee is KClass) {
      final r = _instantiate(callee, '', pos, named, offset);
      if (typeArgs.isNotEmpty && r is KInstance) {
        // generic class (Box<int>) — tur argumentlari runtime'da tekshirilmaydi.
      }
      return r;
    }
    if (callee is FlutterType) return _flutterCall(callee, pos, named, offset);
    if (callee is BuiltinType) return _constructBuiltin(callee.name, '', pos, named, offset, typeArgs: typeArgs);
    if (callee is KInstance) {
      final m = callee.klass.findMethod('call');
      if (m != null) {
        return _invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(callee, callee.klass), pos, named, offset);
      }
    }
    if (callee == null) {
      _typeError("Null qiymatni funksiya sifatida chaqirib bo'lmaydi${name == null ? '' : ' (`$name`)'}", offset);
    }
    _typeError("'${typeName(callee)}' funksiya emas${name == null ? '' : ' (`$name`)'}", offset);
  }

  Object? _callGetter(FunctionDecl g, KClass owner, Object? self, int offset) =>
      _invoke(_makeFunction(g, owner.staticEnv, owner: owner).bind(self, self is KInstance ? self.klass : null),
          const [], const {}, offset, traceCall: false);

  /// Foydalanuvchi funksiyasini bajaradi.
  Object? _invoke(KFunction f, List<Object?> pos, Map<String, Object?> named, int offset, {bool traceCall = true}) {
    if (_depth >= options.maxCallDepth) {
      throw ExecutionAbort('stack_overflow',
          "Funksiya o'zini juda ko'p marta chaqirdi (Stack Overflow). Rekursiyada to'xtash sharti (base case) yo'q bo'lishi mumkin.",
          'Stack Overflow', offset,
          hint: "Rekursiv funksiya boshida to'xtash shartini yozing: if (n <= 1) return 1;");
    }
    final isPrelude = f.ownerClass != null && _preludeClasses.contains(f.ownerClass);
    if (isPrelude) _traceSuspended++;
    Env parent = f.closure;
    if (f.selfClass != null || f.self != null) {
      parent = Env(f.closure, self: f.self, selfClass: f.selfClass, staticClass: f.ownerClass);
    }
    final env = Env(parent, isFunction: true, functionName: f.name);
    _depth++;
    _callStack.add(f.name.isEmpty ? '<closure>' : f.name);
    try {
      _bindParams(f.params, pos, named, env, offset, f.name, null);
      final display = f.name.isEmpty ? 'anonim funksiya' : '`${f.name}`';
      if (traceCall && f.name != 'main' && !f.isGetter) {
        final args = [for (final p in f.params) '${p.name} = ${_preview(env.vars[p.name]?.value)}'].join(', ');
        _record(TraceKind.call, f.body?.block?.offset ?? f.body?.expr?.offset ?? offset, 1,
            "$display funksiyasi chaqirildi${args.isEmpty ? '' : ': $args'}", env: env,
            changed: [for (final p in f.params) p.name]);
      }
      Object? result;
      final body = f.body;
      if (body == null) {
        throw ExecutionAbort('abstract_call', "`${f.name}` abstrakt metod — uning tanasi yo'q.",
            "Abstract method '${f.name}' cannot be called.", offset);
      }
      if (f.isAsync || f.isGenerator) return _startAsyncBody(f, env);
      if (body.expr != null) {
        result = _eval(body.expr!, env);
      } else {
        final c = _execBlock(body.block!.statements, env);
        if (c is _Return) result = c.value;
        if (c is _Break || c is _Continue) {
          throw ExecutionAbort('break_outside_loop', "`break`/`continue` faqat sikl yoki switch ichida ishlatiladi.",
              'A break statement can\'t be used outside of a loop or switch statement.', offset);
        }
      }
      if (f.returnType != null && f.returnType!.name != 'void') {
        result = _coerce(result, f.returnType, offset, '${f.name} return');
      }
      if (traceCall && f.name != 'main' && !f.isGetter && (f.returnType?.name != 'void')) {
        _record(TraceKind.ret, offset, 1, "$display natija qaytardi: ${_preview(result)}", env: env);
      }
      return result;
    } finally {
      _depth--;
      _callStack.removeLast();
      if (isPrelude) _traceSuspended--;
    }
  }

  void _bindParams(List<Param> params, List<Object?> pos, Map<String, Object?> named, Env env, int offset, String fname,
      void Function(Param, Object?)? onField) {
    final positional = params.where((p) => !p.isNamed).toList();
    final requiredCount = positional.where((p) => !p.isOptionalPositional).length;
    final shown = fname.isEmpty ? 'funksiya' : '`$fname`';
    if (pos.length < requiredCount) {
      throw ExecutionAbort('not_enough_arguments',
          "$shown uchun $requiredCount ta argument kerak, lekin ${pos.length} ta berildi.",
          '$requiredCount positional argument(s) expected, but ${pos.length} found.', offset);
    }
    if (pos.length > positional.length) {
      throw ExecutionAbort('too_many_arguments',
          "$shown ko'pi bilan ${positional.length} ta argument qabul qiladi, lekin ${pos.length} ta berildi.",
          'Too many positional arguments: ${positional.length} expected, but ${pos.length} found.', offset);
    }
    for (final n in named.keys) {
      if (!params.any((p) => p.isNamed && p.name == n)) {
        throw ExecutionAbort('undefined_named_parameter',
            "$shown da `$n` nomli parametr yo'q.", "The named parameter '$n' isn't defined.", offset);
      }
    }
    for (var i = 0; i < positional.length; i++) {
      final p = positional[i];
      final v = i < pos.length ? pos[i] : (p.defaultValue == null ? null : _eval(p.defaultValue!, env));
      _bindOne(p, v, env, offset, onField);
    }
    for (final p in params.where((p) => p.isNamed)) {
      if (!named.containsKey(p.name) && p.isRequired) {
        throw ExecutionAbort('missing_required_argument',
            "`${p.name}` nomli argument majburiy (required), lekin berilmadi.",
            "The named parameter '${p.name}' is required, but there's no corresponding argument.", offset,
            hint: "Chaqiruvga `${p.name}: qiymat` qo'shing.");
      }
      final v = named.containsKey(p.name) ? named[p.name] : (p.defaultValue == null ? null : _eval(p.defaultValue!, env));
      _bindOne(p, v, env, offset, onField);
    }
  }

  void _bindOne(Param p, Object? v, Env env, int offset, void Function(Param, Object?)? onField) {
    if (p.isFieldFormal || p.isSuperFormal) {
      onField?.call(p, v);
      env.define(p.name, Binding(v, isFinal: true));
      return;
    }
    env.define(p.name, Binding(_coerce(v, p.type, offset, p.name), type: p.type));
  }

  // ───────────────────────── Obyektlar ─────────────────────────

  Object? _instantiate(KClass k, String ctorName, List<Object?> pos, Map<String, Object?> named, int offset) {
    if (k.isEnum) {
      throw ExecutionAbort('enum_instantiate', "Enum'dan yangi obyekt yaratib bo'lmaydi. `${k.name}.qiymat` ko'rinishida ishlating.",
          "Enums can't be instantiated.", offset);
    }
    final ctor = k.constructors[ctorName];
    if (ctor == null && (ctorName.isNotEmpty || k.constructors.isNotEmpty)) {
      throw ExecutionAbort('undefined_constructor',
          ctorName.isEmpty
              ? "`${k.name}` class'ida nomsiz konstruktor yo'q."
              : "`${k.name}.$ctorName` nomli konstruktor topilmadi.",
          "The class '${k.name}' doesn't have a constructor named '$ctorName'.", offset);
    }
    if (ctor != null && ctor.isFactory) {
      final f = KFunction(name: '${k.name}${ctorName.isEmpty ? '' : '.$ctorName'}', params: ctor.params,
          body: ctor.body, closure: k.staticEnv, ownerClass: k);
      return _invoke(f, pos, named, offset);
    }
    if (k.isAbstract) {
      throw ExecutionAbort('abstract_instantiate',
          "`${k.name}` abstrakt class — undan to'g'ridan-to'g'ri obyekt yaratib bo'lmaydi.",
          "Abstract classes can't be instantiated.", offset,
          hint: "Undan meros oluvchi (extends) oddiy class yarating.");
    }
    final obj = KInstance(k);
    final isPrelude = _preludeClasses.contains(k);
    if (isPrelude) _traceSuspended++;
    try {
      _initInstance(obj, k, ctor, pos, named, offset);
    } finally {
      if (isPrelude) _traceSuspended--;
    }
    if (!isPrelude) {
      _record(TraceKind.declare, offset, 1, "Yangi `${k.name}` obyekti yaratildi: ${_preview(obj)}");
    }
    return obj;
  }

  void _initInstance(KInstance obj, KClass k, ConstructorDecl? ctor, List<Object?> pos, Map<String, Object?> named, int offset) {
    _depth++;
    if (_depth >= options.maxCallDepth) {
      throw ExecutionAbort('stack_overflow', "Konstruktorlar bir-birini cheksiz chaqirmoqda.", 'Stack Overflow', offset);
    }
    try {
      // 1. Maydon boshlang'ich qiymatlari.
      for (final f in k.instanceFields) {
        for (final v in f.decl.vars) {
          if (!obj.fields.containsKey(v.name) || v.init != null) {
            obj.fields[v.name] = v.init == null ? null : _coerce(_eval(v.init!, Env(k.staticEnv, self: obj, selfClass: k, staticClass: k)), f.decl.type, v.offset, v.name);
          }
        }
      }
      final paramEnv = Env(k.staticEnv, isFunction: true, functionName: k.name);
      final superPos = <Object?>[];
      final superNamed = <String, Object?>{};
      if (ctor != null) {
        _bindParams(ctor.params, pos, named, paramEnv, offset, '${k.name}${ctor.name == null ? '' : '.${ctor.name}'}', (p, v) {
          if (p.isFieldFormal) {
            obj.fields[p.name] = _coerce(v, _fieldType(k, p.name), offset, p.name);
          } else if (p.isSuperFormal) {
            if (p.isNamed) {
              superNamed[p.name] = v;
            } else {
              superPos.add(v);
            }
          }
        });
        for (final a in ctor.asserts) {
          if (_eval(a.condition, paramEnv) != true) {
            final msg = a.message == null ? null : _eval(a.message!, paramEnv);
            _throwDart('AssertionError', [msg ?? "'${_srcRange(a.condition.offset, a.condition.end)}': is not true."], a.offset);
          }
        }
        for (final init in ctor.initializers) {
          obj.fields[init.field] = _coerce(_eval(init.value, paramEnv), _fieldType(k, init.field), offset, init.field);
        }
        if (ctor.redirect != null) {
          final (rp, rn) = _evalArgs(ctor.redirect!, paramEnv);
          _initInstance(obj, k, k.constructors[ctor.redirectName ?? ''], rp, rn, offset);
          return;
        }
      } else if (pos.isNotEmpty || named.isNotEmpty) {
        throw ExecutionAbort('too_many_arguments',
            "`${k.name}` class'ida konstruktor yo'q, shuning uchun argument berib bo'lmaydi.",
            'Too many positional arguments: 0 expected, but ${pos.length} found.', offset,
            hint: "Konstruktor yozing: ${k.name}(this.maydon);");
      }
      // 2. Ota class konstruktori.
      final sup = k.superclass;
      if (sup != null) {
        if (ctor?.superCall != null) {
          final (sp, sn) = _evalArgs(ctor!.superCall!, paramEnv);
          superPos.insertAll(0, sp);
          superNamed.addAll(sn);
        }
        var target = sup;
        // Mixin oraliq class'larini o'tkazib, haqiqiy ota konstruktorni topamiz.
        while (target.isMixinApplication) {
          for (final f in target.instanceFields) {
            for (final v in f.decl.vars) {
              obj.fields[v.name] = v.init == null ? null : _eval(v.init!, target.staticEnv);
            }
          }
          if (target.superclass == null) break;
          target = target.superclass!;
        }
        if (!target.isMixinApplication) {
          final superCtor = target.constructors[ctor?.superName ?? ''];
          _initInstance(obj, target, superCtor, superPos, superNamed, offset);
        }
      }
      // 3. Konstruktor tanasi.
      final body = ctor?.body;
      if (body != null && ctor != null) {
        final selfEnv = Env(paramEnv, self: obj, selfClass: obj.klass, staticClass: k);
        final env = Env(selfEnv, isFunction: true, functionName: k.name);
        // Konstruktor parametrlarini tanaga ham ko'rsatamiz (this.x parametrlardan tashqari).
        for (final e in paramEnv.vars.entries) {
          final p = ctor.params.firstWhere((p) => p.name == e.key);
          if (!p.isFieldFormal) env.define(e.key, e.value);
        }
        if (body.block != null) {
          _execBlock(body.block!.statements, env);
        } else {
          _eval(body.expr!, env);
        }
      }
    } finally {
      _depth--;
    }
  }

  Object? _findExtensionValue(Object? target, String name, int offset, {List<Object?>? args, Map<String, Object?>? named}) {
    final ext = _findExtension(target, name);
    if (ext == null) return _notFound;
    final f = _makeFunction(ext, globals).bind(target, target is KInstance ? target.klass : null);
    final bound = KFunction(name: f.name, params: f.params, body: f.body, closure: f.closure,
        returnType: f.returnType, self: target, isGetter: f.isGetter);
    if (ext.isGetter) return _invoke(bound, const [], const {}, offset);
    if (args == null) return bound;
    return _invoke(bound, args, named ?? const {}, offset);
  }

  FunctionDecl? _findExtension(Object? target, String name) {
    final candidates = _extensions[name];
    if (candidates == null) return null;
    for (final (ext, m) in candidates) {
      if (isType(target, ext.onType) || (target != null && ext.onType.name == 'num' && (target is int || target is KDouble))) {
        return m;
      }
    }
    return null;
  }

  // ───────────────────────── Matnga aylantirish ─────────────────────────

  /// `print` va interpolatsiya uchun — foydalanuvchi `toString()` ini ham chaqiradi.
  String stringify(Object? v, [int offset = 0]) {
    if (v == null) return 'null';
    if (v is String) return v;
    if (v is bool || v is int) return v.toString();
    if (v is KDouble) return formatDouble(v.value);
    if (v is KInstance) {
      final m = v.klass.findMethod('toString');
      if (m != null) {
        final r = _invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(v, v.klass), const [], const {}, offset,
            traceCall: false);
        if (r is! String) _typeError("toString() String qaytarishi kerak", offset);
        return r;
      }
      if (v.klass.isEnum) return '${v.klass.name}.${v.enumName}';
      return "Instance of '${v.klass.displayName}'";
    }
    if (v is List) return '[${v.map((e) => stringify(e, offset)).join(', ')}]';
    if (v is Set) return '{${v.map((e) => stringify(e, offset)).join(', ')}}';
    if (v is Map) {
      return '{${v.entries.map((e) => '${stringify(e.key, offset)}: ${stringify(e.value, offset)}').join(', ')}}';
    }
    if (v is Iterable) {
      final items = _guard(() => v.take(101).toList(), offset);
      final shown = items.take(100).map((e) => stringify(e, offset)).join(', ');
      return items.length > 100 ? '($shown, ...)' : '($shown)';
    }
    if (v is KRecord) {
      final parts = [
        ...v.positional.map((e) => stringify(e, offset)),
        ...v.named.entries.map((e) => '${e.key}: ${stringify(e.value, offset)}'),
      ];
      return '(${parts.join(', ')})';
    }
    if (v is KFunction) return 'Closure: ${v.signature()}';
    if (v is NativeFunction) return "Closure: ${v.signature} from Function '${v.name}': static.";
    if (v is KClass) return v.name;
    if (v is BuiltinType) return v.name;
    if (v is StringBuffer) return v.toString();
    if (v is DateTime) return v.toString();
    if (v is KRandom) return "Instance of 'Random'";
    if (v is KNamespace) return v.name;
    final asyncName = _asyncTypeName(v);
    if (asyncName != null) return "Instance of '$asyncName'";
    if (v is FNode) {
      if (v.type == 'Text' && v.pos.isNotEmpty) return 'Text("${stringify(v.pos.first)}")';
      return '${v.type}(...)';
    }
    if (v is FColor) return 'Color(0x${v.argb.toRadixString(16).toUpperCase().padLeft(8, '0')})';
    if (v is FEnum) return '${v.type}.${v.name}';
    if (v is FIcon) return 'IconData(Icons.${v.name})';
    if (v is FlutterType) return v.name;
    return v.toString();
  }

  String _stringifySafe(Object? v) {
    try {
      return stringify(v);
    } catch (_) {
      return _preview(v);
    }
  }

  /// Vizualizator uchun qisqa ko'rinish. Foydalanuvchi kodini chaqirmaydi.
  String _preview(Object? v, [int depth = 0]) {
    if (v == null) return 'null';
    if (v is String) {
      final s = v.length > 40 ? '${v.substring(0, 37)}...' : v;
      return "'${s.replaceAll('\n', r'\n')}'";
    }
    if (v is bool || v is int) return v.toString();
    if (v is KDouble) return formatDouble(v.value);
    if (depth > 1) return '…';
    if (v is List) {
      final items = v.take(8).map((e) => _preview(e, depth + 1)).join(', ');
      return '[$items${v.length > 8 ? ', …' : ''}]';
    }
    if (v is Set) return '{${v.take(8).map((e) => _preview(e, depth + 1)).join(', ')}${v.length > 8 ? ', …' : ''}}';
    if (v is Map) {
      final items = v.entries.take(6).map((e) => '${_preview(e.key, depth + 1)}: ${_preview(e.value, depth + 1)}').join(', ');
      return '{$items${v.length > 6 ? ', …' : ''}}';
    }
    if (v is KInstance) {
      if (v.klass.isEnum) return '${v.klass.name}.${v.enumName}';
      final f = v.fields.entries.take(5).map((e) => '${e.key}: ${_preview(e.value, depth + 1)}').join(', ');
      return '${v.klass.displayName}($f)';
    }
    if (v is KFunction) return v.name.isEmpty ? 'funksiya' : '${v.name}()';
    if (v is KRecord) return stringify(v);
    if (v is Iterable) return '(…)';
    if (v is NativeFunction) return '${v.name}()';
    return stringify(v);
  }

  // ───────────────────────── Trace ─────────────────────────

  bool get _traceOn => options.trace && _traceSuspended == 0;

  void _record(TraceKind kind, int offset, int length, String description, {Env? env, List<String> changed = const []}) {
    if (!_traceOn) return;
    if (trace.length >= options.maxTraceSteps) {
      traceTruncated = true;
      return;
    }
    trace.add(TraceStep(
      kind: kind,
      line: lineOf(offset),
      offset: offset,
      length: length,
      description: description,
      vars: env == null ? (trace.isEmpty ? const [] : trace.last.vars) : _snapshot(env),
      changed: changed,
      outputLength: _out.length,
      callStack: List.of(_callStack),
    ));
  }

  List<VarSnapshot> _snapshot(Env env) {
    final seen = <String>{};
    final groups = <List<VarSnapshot>>[];
    VarSnapshot snap(String name, Binding b) =>
        VarSnapshot(name, b.initialized ? _preview(b.value) : '—', b.type?.toString() ?? typeName(b.value));
    bool hidden(Env e, String key, Object? v) =>
        key.startsWith(r'$') || (e == globals && (_declNames.contains(key) || v is KClass || v is KFunction || classes.containsKey(key)));
    Env? e = env;
    while (e != null) {
      final group = <VarSnapshot>[];
      for (final entry in e.vars.entries) {
        if (hidden(e, entry.key, entry.value.value) || !seen.add(entry.key)) continue;
        group.add(snap(entry.key, entry.value));
      }
      if (e.hasSelf && e.self is KInstance) {
        for (final f in (e.self as KInstance).fields.entries) {
          final key = 'this.${f.key}';
          if (seen.add(key)) group.add(VarSnapshot(key, _preview(f.value), typeName(f.value)));
        }
      }
      groups.add(group);
      if (e.isFunction) {
        if (e != globals) {
          final g = <VarSnapshot>[];
          for (final entry in globals.vars.entries) {
            if (hidden(globals, entry.key, entry.value.value) || !seen.add(entry.key)) continue;
            g.add(snap(entry.key, entry.value));
          }
          groups.add(g);
        }
        break;
      }
      e = e.parent;
    }
    return [for (final g in groups.reversed) ...g];
  }
}
