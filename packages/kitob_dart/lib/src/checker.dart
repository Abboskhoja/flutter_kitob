import 'ast.dart';
import 'diagnostics.dart';
import 'interpreter.dart' show dartAsyncNames, flutterLibraryUris, flutterMemberNames, flutterTypeNames;
import 'runtime.dart';
import 'values.dart';

typedef T = TypeAnnotation;

T _t(String name, {List<T> args = const [], bool nullable = false}) => TypeAnnotation(name, args: args, nullable: nullable);

final _int = _t('int');
final _double = _t('double');
final _num = _t('num');
final _string = _t('String');
final _bool = _t('bool');
final _void = _t('void');
final _null = _t('Null');
final _dynamic = _t('dynamic');

T _nonNull(T t) => t.nullable ? TypeAnnotation(t.name, args: t.args) : t;
T _nullable(T t) => t.nullable || t.name == 'dynamic' || t.name == 'Null' ? t : TypeAnnotation(t.name, args: t.args, nullable: true);

/// Builtin a'zo: qaytaradigan turi va argumentlar soni.
class _Member {
  const _Member(this.ret, [this.min = 0, this.max = 0]) : isGetter = false;
  const _Member.getter(this.ret)
      : min = 0,
        max = 0,
        isGetter = true;

  /// `E` — element turi, `K`/`V` — map turlari, `R` — qabul qiluvchining o'zi.
  final String ret;
  final int min;
  final int max;
  final bool isGetter;
}

const _objectMembers = {
  'toString': _Member('String'),
  'hashCode': _Member.getter('int'),
  'runtimeType': _Member.getter('Type'),
};

const _stringMembers = {
  'length': _Member.getter('int'),
  'isEmpty': _Member.getter('bool'),
  'isNotEmpty': _Member.getter('bool'),
  'codeUnits': _Member.getter('List<int>'),
  'runes': _Member.getter('Iterable<int>'),
  'toUpperCase': _Member('String'),
  'toLowerCase': _Member('String'),
  'trim': _Member('String'),
  'trimLeft': _Member('String'),
  'trimRight': _Member('String'),
  'contains': _Member('bool', 1, 2),
  'startsWith': _Member('bool', 1, 2),
  'endsWith': _Member('bool', 1, 1),
  'indexOf': _Member('int', 1, 2),
  'lastIndexOf': _Member('int', 1, 2),
  'substring': _Member('String', 1, 2),
  'split': _Member('List<String>', 1, 1),
  'replaceAll': _Member('String', 2, 2),
  'replaceFirst': _Member('String', 2, 3),
  'padLeft': _Member('String', 1, 2),
  'padRight': _Member('String', 1, 2),
  'codeUnitAt': _Member('int', 1, 1),
  'compareTo': _Member('int', 1, 1),
};

const _numMembers = {
  'isNegative': _Member.getter('bool'),
  'isFinite': _Member.getter('bool'),
  'isInfinite': _Member.getter('bool'),
  'isNaN': _Member.getter('bool'),
  'sign': _Member.getter('R'),
  'abs': _Member('R'),
  'toDouble': _Member('double'),
  'toInt': _Member('int'),
  'round': _Member('int'),
  'floor': _Member('int'),
  'ceil': _Member('int'),
  'truncate': _Member('int'),
  'roundToDouble': _Member('double'),
  'floorToDouble': _Member('double'),
  'ceilToDouble': _Member('double'),
  'toStringAsFixed': _Member('String', 1, 1),
  'toStringAsPrecision': _Member('String', 1, 1),
  'compareTo': _Member('int', 1, 1),
  'remainder': _Member('num', 1, 1),
  'clamp': _Member('num', 2, 2),
};

const _intMembers = {
  'isEven': _Member.getter('bool'),
  'isOdd': _Member.getter('bool'),
  'bitLength': _Member.getter('int'),
  'toRadixString': _Member('String', 1, 1),
  'gcd': _Member('int', 1, 1),
};

const _iterableMembers = {
  'length': _Member.getter('int'),
  'isEmpty': _Member.getter('bool'),
  'isNotEmpty': _Member.getter('bool'),
  'first': _Member.getter('E'),
  'last': _Member.getter('E'),
  'single': _Member.getter('E'),
  'map': _Member('Iterable<dynamic>', 1, 1),
  'where': _Member('Iterable<E>', 1, 1),
  'whereType': _Member('Iterable<dynamic>', 0, 0),
  'expand': _Member('Iterable<dynamic>', 1, 1),
  'forEach': _Member('void', 1, 1),
  'any': _Member('bool', 1, 1),
  'every': _Member('bool', 1, 1),
  'reduce': _Member('E', 1, 1),
  'fold': _Member('dynamic', 2, 2),
  'contains': _Member('bool', 1, 1),
  'join': _Member('String', 0, 1),
  'toList': _Member('List<E>', 0, 0),
  'toSet': _Member('Set<E>', 0, 0),
  'take': _Member('Iterable<E>', 1, 1),
  'skip': _Member('Iterable<E>', 1, 1),
  'takeWhile': _Member('Iterable<E>', 1, 1),
  'skipWhile': _Member('Iterable<E>', 1, 1),
  'firstWhere': _Member('E', 1, 1),
  'lastWhere': _Member('E', 1, 1),
  'singleWhere': _Member('E', 1, 1),
  'elementAt': _Member('E', 1, 1),
  'followedBy': _Member('Iterable<E>', 1, 1),
  'cast': _Member('Iterable<dynamic>', 0, 0),
};

const _listMembers = {
  'reversed': _Member.getter('Iterable<E>'),
  'add': _Member('void', 1, 1),
  'addAll': _Member('void', 1, 1),
  'insert': _Member('void', 2, 2),
  'insertAll': _Member('void', 2, 2),
  'remove': _Member('bool', 1, 1),
  'removeAt': _Member('E', 1, 1),
  'removeLast': _Member('E', 0, 0),
  'removeWhere': _Member('void', 1, 1),
  'retainWhere': _Member('void', 1, 1),
  'removeRange': _Member('void', 2, 2),
  'clear': _Member('void', 0, 0),
  'indexOf': _Member('int', 1, 2),
  'lastIndexOf': _Member('int', 1, 2),
  'indexWhere': _Member('int', 1, 2),
  'lastIndexWhere': _Member('int', 1, 2),
  'sublist': _Member('List<E>', 1, 2),
  'getRange': _Member('Iterable<E>', 2, 2),
  'sort': _Member('void', 0, 1),
  'shuffle': _Member('void', 0, 1),
  'fillRange': _Member('void', 2, 3),
  'asMap': _Member('Map<int, E>', 0, 0),
};

const _setMembers = {
  'add': _Member('bool', 1, 1),
  'addAll': _Member('void', 1, 1),
  'remove': _Member('bool', 1, 1),
  'containsAll': _Member('bool', 1, 1),
  'union': _Member('Set<E>', 1, 1),
  'intersection': _Member('Set<E>', 1, 1),
  'difference': _Member('Set<E>', 1, 1),
  'removeAll': _Member('void', 1, 1),
  'clear': _Member('void', 0, 0),
};

const _mapMembers = {
  'length': _Member.getter('int'),
  'isEmpty': _Member.getter('bool'),
  'isNotEmpty': _Member.getter('bool'),
  'keys': _Member.getter('Iterable<K>'),
  'values': _Member.getter('Iterable<V>'),
  'entries': _Member.getter('Iterable<MapEntry>'),
  'containsKey': _Member('bool', 1, 1),
  'containsValue': _Member('bool', 1, 1),
  'remove': _Member('V?', 1, 1),
  'clear': _Member('void', 0, 0),
  'putIfAbsent': _Member('V', 2, 2),
  'update': _Member('V', 2, 2),
  'updateAll': _Member('void', 1, 1),
  'forEach': _Member('void', 1, 1),
  'map': _Member('Map<dynamic, dynamic>', 1, 1),
  'addAll': _Member('void', 1, 1),
  'addEntries': _Member('void', 1, 1),
  'removeWhere': _Member('void', 1, 1),
};

const _stringBufferMembers = {
  'length': _Member.getter('int'),
  'isEmpty': _Member.getter('bool'),
  'isNotEmpty': _Member.getter('bool'),
  'write': _Member('void', 1, 1),
  'writeln': _Member('void', 0, 1),
  'writeAll': _Member('void', 1, 2),
  'clear': _Member('void', 0, 0),
};

const _dateTimeMembers = {
  'difference': _Member('Duration', 1, 1),
  'add': _Member('DateTime', 1, 1),
  'subtract': _Member('DateTime', 1, 1),
  'isBefore': _Member('bool', 1, 1),
  'isAfter': _Member('bool', 1, 1),
  'compareTo': _Member('int', 1, 1),
  'year': _Member.getter('int'),
  'month': _Member.getter('int'),
  'day': _Member.getter('int'),
  'hour': _Member.getter('int'),
  'minute': _Member.getter('int'),
  'second': _Member.getter('int'),
  'millisecond': _Member.getter('int'),
  'weekday': _Member.getter('int'),
  'millisecondsSinceEpoch': _Member.getter('int'),
};

const _staticMembers = <String, _Member>{
  'Future.value': _Member('Future<dynamic>', 0, 1),
  'Future.error': _Member('Future<dynamic>', 1, 2),
  'Future.delayed': _Member('Future<dynamic>', 1, 2),
  'Future.microtask': _Member('Future<dynamic>', 1, 1),
  'Future.sync': _Member('Future<dynamic>', 1, 1),
  'Future.wait': _Member('Future<List<dynamic>>', 1, 1),
  'Future.any': _Member('Future<dynamic>', 1, 1),
  'Stream.fromIterable': _Member('Stream<dynamic>', 1, 1),
  'Stream.value': _Member('Stream<dynamic>', 1, 1),
  'Stream.error': _Member('Stream<dynamic>', 1, 2),
  'Stream.empty': _Member('Stream<dynamic>', 0, 0),
  'Stream.periodic': _Member('Stream<dynamic>', 1, 2),
  'Stream.fromFuture': _Member('Stream<dynamic>', 1, 1),
  'StreamController.broadcast': _Member('StreamController<dynamic>', 0, 0),
  'Timer.periodic': _Member('Timer', 2, 2),
  'Timer.run': _Member('Timer', 1, 1),
  'int.parse': _Member('int', 1, 1),
  'int.tryParse': _Member('int?', 1, 1),
  'double.parse': _Member('double', 1, 1),
  'double.tryParse': _Member('double?', 1, 1),
  'num.parse': _Member('num', 1, 1),
  'num.tryParse': _Member('num?', 1, 1),
  'String.fromCharCode': _Member('String', 1, 1),
  'String.fromCharCodes': _Member('String', 1, 1),
  'List.filled': _Member('List<dynamic>', 2, 2),
  'List.generate': _Member('List<dynamic>', 2, 2),
  'List.empty': _Member('List<dynamic>', 0, 0),
  'List.from': _Member('List<dynamic>', 1, 1),
  'List.of': _Member('List<dynamic>', 1, 1),
  'List.unmodifiable': _Member('List<dynamic>', 1, 1),
  'Set.from': _Member('Set<dynamic>', 1, 1),
  'Set.of': _Member('Set<dynamic>', 1, 1),
  'Map.from': _Member('Map<dynamic, dynamic>', 1, 1),
  'Map.of': _Member('Map<dynamic, dynamic>', 1, 1),
  'Map.fromIterables': _Member('Map<dynamic, dynamic>', 2, 2),
  'Map.fromEntries': _Member('Map<dynamic, dynamic>', 1, 1),
  'DateTime.now': _Member('DateTime', 0, 0),
  'DateTime.parse': _Member('DateTime', 1, 1),
  'double.infinity': _Member.getter('double'),
  'double.negativeInfinity': _Member.getter('double'),
  'double.nan': _Member.getter('double'),
  'double.maxFinite': _Member.getter('double'),
  'double.minPositive': _Member.getter('double'),
};

const _futureMembers = {
  'then': _Member('Future<dynamic>', 1, 1),
  'catchError': _Member('Future<E>', 1, 1),
  'whenComplete': _Member('Future<E>', 1, 1),
  'timeout': _Member('Future<E>', 1, 1),
  'ignore': _Member('void'),
  'asStream': _Member('Stream<E>'),
};

const _streamMembers = {
  'listen': _Member('StreamSubscription<E>', 0, 1),
  'map': _Member('Stream<dynamic>', 1, 1),
  'where': _Member('Stream<E>', 1, 1),
  'take': _Member('Stream<E>', 1, 1),
  'skip': _Member('Stream<E>', 1, 1),
  'expand': _Member('Stream<dynamic>', 1, 1),
  'handleError': _Member('Stream<E>', 1, 1),
  'asBroadcastStream': _Member('Stream<E>'),
  'toList': _Member('Future<List<E>>'),
  'toSet': _Member('Future<Set<E>>'),
  'forEach': _Member('Future<void>', 1, 1),
  'join': _Member('Future<String>', 0, 1),
  'fold': _Member('Future<dynamic>', 2, 2),
  'reduce': _Member('Future<E>', 1, 1),
  'contains': _Member('Future<bool>', 1, 1),
  'firstWhere': _Member('Future<E>', 1, 1),
  'first': _Member.getter('Future<E>'),
  'last': _Member.getter('Future<E>'),
  'length': _Member.getter('Future<int>'),
  'isEmpty': _Member.getter('Future<bool>'),
  'isBroadcast': _Member.getter('bool'),
};

const _streamControllerMembers = {
  'stream': _Member.getter('Stream<E>'),
  'sink': _Member.getter('StreamSink<E>'),
  'add': _Member('void', 1, 1),
  'addError': _Member('void', 1, 2),
  'close': _Member('Future<dynamic>'),
  'hasListener': _Member.getter('bool'),
  'isClosed': _Member.getter('bool'),
  'isPaused': _Member.getter('bool'),
  'done': _Member.getter('Future<dynamic>'),
  'onListen': _Member.getter('Function?'),
  'onCancel': _Member.getter('Function?'),
  'onPause': _Member.getter('Function?'),
  'onResume': _Member.getter('Function?'),
};

const builtinTypeNames = {
  'int', 'double', 'num', 'String', 'bool', 'List', 'Map', 'Set', 'Object', 'Iterable', 'Function',
  'Null', 'dynamic', 'void', 'Never', 'Record', 'Comparable', 'Enum', 'StringBuffer', 'DateTime', 'Type',
  'Future', 'Stream', 'Symbol', 'Iterator', 'FutureOr', 'StackTrace',
  // dart:async (import talab qilinadi — _asyncGate tekshiradi)
  'Completer', 'Timer', 'StreamController', 'StreamSubscription', 'StreamSink', 'StreamIterator',
};

const _libraryNames = <String, Map<String, String>>{
  'dart:math': {
    'max': 'num', 'min': 'num', 'sqrt': 'double', 'pow': 'num', 'sin': 'double', 'cos': 'double',
    'tan': 'double', 'asin': 'double', 'acos': 'double', 'atan': 'double', 'atan2': 'double',
    'log': 'double', 'exp': 'double', 'pi': 'double', 'e': 'double', 'sqrt2': 'double', 'Random': 'Random',
  },
  'dart:io': {'stdin': 'Stdin', 'stdout': 'Stdout', 'exit': 'Never'},
  'dart:convert': {'jsonEncode': 'String', 'jsonDecode': 'dynamic'},
  'dart:async': {'scheduleMicrotask': 'void', 'unawaited': 'void'},
};

class _Var {
  _Var(this.type, {this.isFinal = false, this.isConst = false, this.isLocal = false, this.offset = 0, this.kind = 'var', this.isLate = false});
  final T? type;
  final bool isFinal;
  final bool isConst;
  final bool isLate;
  final bool isLocal;
  final int offset;

  /// 'var', 'param', 'function', 'class', 'field', 'prefix'
  final String kind;
  bool used = false;
  FunctionDecl? function;
}

class _Scope {
  _Scope(this.parent,
      {this.klass, this.isStatic = false, this.function, this.returnType, this.isFunction = false, this.asyncKind});
  final _Scope? parent;

  /// 'async', 'async*', 'sync*' yoki null (oddiy funksiya).
  final String? asyncKind;
  final Map<String, _Var> vars = {};
  final Map<String, T> promoted = {};
  final ClassDecl? klass;
  final bool isStatic;
  final String? function;
  final T? returnType;
  final bool isFunction;

  _Scope child() => _Scope(this);
}

/// Dart analyzer'ga o'xshash statik tekshiruvchi. Kodni ishga tushirmasdan
/// xatolarni topadi va o'zbek tilida tushuntiradi.
class Checker {
  Checker(this.program, {required this.preludeClasses, this.requireMain = true});

  final Program program;
  final List<ClassDecl> preludeClasses;
  final bool requireMain;
  final List<Diagnostic> diagnostics = [];
  late LineMap _lineMap;

  final Map<String, ClassDecl> _classes = {};
  final Set<String> _imported = {};
  final Map<String, String> _prefixes = {};
  late final _Scope _global = _Scope(null);
  final Map<String, List<FunctionDecl>> _extensionMembers = {};
  final List<String> _typeParams = [];
  bool _flutter = false;
  late final Set<String> _flutterNames = flutterMemberNames;

  List<Diagnostic> check(String source) {
    _lineMap = LineMap(source);
    for (final c in preludeClasses) {
      _classes[c.name] = c;
    }
    for (final imp in program.imports) {
      _checkImport(imp);
    }
    for (final c in program.classes) {
      if (_classes.containsKey(c.name) && !preludeClassNames.contains(c.name)) {
        _err('duplicate_definition', "`${c.name}` nomi ikki marta e'lon qilingan.", "The name '${c.name}' is already defined.",
            c.nameOffset, c.name.length);
      }
      _classes[c.name] = c;
      _global.vars[c.name] = _Var(_t('Type'), kind: 'class', isFinal: true);
    }
    for (final e in program.extensions) {
      for (final m in e.methods) {
        (_extensionMembers[m.name] ??= []).add(m);
      }
    }
    for (final f in program.functions) {
      if (_global.vars.containsKey(f.name)) {
        _err('duplicate_definition', "`${f.name}` nomi ikki marta e'lon qilingan.", "The name '${f.name}' is already defined.",
            f.nameOffset, f.name.length);
      }
      _global.vars[f.name] = _Var(_t('Function'), kind: 'function', isFinal: true)..function = f;
    }
    for (final v in program.variables) {
      _varDecl(v, _global, isTopLevel: true);
    }
    for (final c in program.classes) {
      _checkClass(c);
    }
    for (final e in program.extensions) {
      _checkType(e.onType);
      final scope = _Scope(_global, isFunction: true);
      scope.vars['this'] = _Var(e.onType, isFinal: true);
      for (final m in e.methods) {
        _function(m, scope, extensionOn: e.onType);
      }
    }
    for (final f in program.functions) {
      _function(f, _global);
    }
    if (requireMain && !program.functions.any((f) => f.name == 'main')) {
      _err('missing_main', "Dasturda `main()` funksiyasi yo'q. Dart dasturi doim main() dan boshlanadi.",
          "No 'main' function found.", 0, 1,
          hint: "Kodni shunday yozing:\nvoid main() {\n  print('Salom!');\n}");
    }
    diagnostics.sort((a, b) => a.offset.compareTo(b.offset));
    return diagnostics;
  }

  void _err(String code, String message, String original, int offset, int length,
      {String? hint, Severity severity = Severity.error}) {
    if (diagnostics.any((d) => d.offset == offset && d.code == code)) return;
    diagnostics.add(Diagnostic(
      code: code,
      message: message,
      original: original,
      hint: hint,
      line: _lineMap.lineOf(offset),
      column: _lineMap.columnOf(offset),
      offset: offset,
      length: length < 1 ? 1 : length,
      severity: severity,
    ));
  }

  void _checkImport(ImportDecl imp) {
    final uri = imp.uri;
    if (_libraryNames.containsKey(uri) || uri == 'dart:core' || uri == 'dart:collection') {
      if (imp.prefix != null) {
        _prefixes[imp.prefix!] = uri;
        _global.vars[imp.prefix!] = _Var(_t('dynamic'), kind: 'prefix', isFinal: true);
      } else {
        _imported.add(uri);
      }
      return;
    }
    final len = imp.uriEnd - imp.uriOffset;
    if (flutterLibraryUris.contains(uri)) {
      _flutter = true;
      return;
    }
    if (uri.startsWith('package:flutter')) {
      _err('flutter_import', "Flutter kutubxonasi faqat Flutter ilovasida ishlaydi. Bu konsol playground Dart kodini bajaradi.",
          "Target of URI doesn't exist: '$uri'.", imp.uriOffset, len,
          hint: "Flutter widgetlarini «Widget laboratoriyasi» bo'limida jonli ko'rib o'rganing. Bu yerda faqat sof Dart kodi ishga tushadi.");
      return;
    }
    if (uri == 'dart:isolate' || uri == 'dart:ffi' || uri == 'dart:html') {
      _err('unsupported_library', "`$uri` kutubxonasi hozircha bu playgroundda qo'llab-quvvatlanmaydi.",
          "The library '$uri' is not available in this runner.", imp.uriOffset, len);
      return;
    }
    _err('uri_does_not_exist', "`$uri` kutubxonasi topilmadi. Playgroundda dart:math, dart:io va dart:convert mavjud.",
        "Target of URI doesn't exist: '$uri'.", imp.uriOffset, len);
  }

  // ───────────────────────── Turlar ─────────────────────────

  bool get _asyncImported => _imported.contains('dart:async') || _prefixes.values.contains('dart:async');

  /// `Timer`, `Completer` kabi nomlar `import 'dart:async';` siz ko'rinmaydi.
  bool _needsAsyncImport(String name) => dartAsyncNames.contains(name) && !_asyncImported;

  bool _isKnownType(String name) =>
      !_needsAsyncImport(name) && builtinTypeNames.contains(name) ||
      !_needsAsyncImport(name) && _classes.containsKey(name) ||
      _typeParams.contains(name) ||
      name == 'Random' && (_imported.contains('dart:math') || _prefixes.values.contains('dart:math')) ||
      (_flutter && (flutterTypeNames.contains(name) || _flutterNames.contains(name))) ||
      name.contains('.');

  void _checkType(T? t) {
    if (t == null) return;
    if (!_isKnownType(t.name)) {
      final lower = t.name.toLowerCase();
      String? suggestion;
      for (final b in [...builtinTypeNames, ..._classes.keys]) {
        if (b.toLowerCase() == lower) suggestion = b;
      }
      suggestion ??= const {'string': 'String', 'integer': 'int', 'boolean': 'bool', 'float': 'double', 'array': 'List', 'char': 'String', 'str': 'String'}[lower];
      _err('undefined_class', "`${t.name}` nomli tur (class) topilmadi.", "Undefined class '${t.name}'.", t.offset, t.end - t.offset,
          hint: dartAsyncNames.contains(t.name)
              ? "`${t.name}` `dart:async` kutubxonasida. Fayl boshiga qo'shing: import 'dart:async';"
              : suggestion != null
              ? "Dart katta-kichik harfni farqlaydi. `$suggestion` demoqchimisiz?"
              : "Turni to'g'ri yozganingizni tekshiring yoki avval `class ${t.name} { }` ni e'lon qiling.");
    }
    for (final a in t.args) {
      _checkType(a);
    }
  }

  T _parseTypeString(String s) {
    var str = s.trim();
    var nullable = false;
    if (str.endsWith('?')) {
      nullable = true;
      str = str.substring(0, str.length - 1);
    }
    final lt = str.indexOf('<');
    if (lt < 0) return _t(str, nullable: nullable);
    final name = str.substring(0, lt);
    final inner = str.substring(lt + 1, str.length - 1);
    final args = <T>[];
    var depth = 0, start = 0;
    for (var i = 0; i < inner.length; i++) {
      final c = inner[i];
      if (c == '<') depth++;
      if (c == '>') depth--;
      if (c == ',' && depth == 0) {
        args.add(_parseTypeString(inner.substring(start, i)));
        start = i + 1;
      }
    }
    args.add(_parseTypeString(inner.substring(start)));
    return _t(name, args: args, nullable: nullable);
  }

  bool _isDynamic(T? t) => t == null || t.name == 'dynamic' || _typeParams.contains(t.name);

  /// [from] turidagi qiymatni [to] turiga berish mumkinmi?
  bool _assignable(T? from, T? to, {Expr? expr}) {
    if (_isDynamic(from) || _isDynamic(to)) return true;
    from!;
    to!;
    if (to.name == 'void') return true;
    if (from.name == 'Never') return true;
    if (from.name == 'Null') return to.nullable || to.name == 'Null' || to.name == 'dynamic';
    if (from.nullable && !to.nullable && to.name != 'dynamic') return false;
    if (to.name == 'Object') return true;
    if (from.name == to.name) {
      if (from.args.isEmpty || to.args.isEmpty || from.args.length != to.args.length) return true;
      for (var i = 0; i < from.args.length; i++) {
        if (!_assignable(from.args[i], to.args[i])) return false;
      }
      return true;
    }
    if (to.name == 'num' && (from.name == 'int' || from.name == 'double')) return true;
    if (to.name == 'double' && from.name == 'int' && _isIntLiteral(expr)) return true;
    if (to.name == 'Comparable' && const {'int', 'double', 'num', 'String'}.contains(from.name)) return true;
    if (to.name == 'Iterable' && (from.name == 'List' || from.name == 'Set')) {
      if (from.args.isEmpty || to.args.isEmpty) return true;
      return _assignable(from.args.first, to.args.first);
    }
    if (to.name == 'Function' && from.name == 'Function') return true;
    if (to.name == 'Enum' && _classes[from.name]?.kind == ClassKind.enumDecl) return true;
    if (_classes.containsKey(from.name)) return _isSubclass(from.name, to.name);
    // Noma'lum generic tur — ehtiyotkorlik bilan ruxsat beramiz.
    if (!_isKnownType(from.name) || !_isKnownType(to.name)) return true;
    return false;
  }

  bool _isIntLiteral(Expr? e) =>
      e is Literal && e.value is int || e is UnaryExpr && e.op == '-' && _isIntLiteral(e.operand);

  bool _isSubclass(String sub, String sup, [Set<String>? seen]) {
    if (sub == sup) return true;
    seen ??= {};
    if (!seen.add(sub)) return false;
    final c = _classes[sub];
    if (c == null) return false;
    final parents = [
      if (c.superclass != null) c.superclass!.name,
      ...c.interfaces.map((e) => e.name),
      ...c.mixins.map((e) => e.name),
    ];
    return parents.any((p) => _isSubclass(p, sup, seen));
  }

  String _show(T? t) => t?.toString() ?? 'dynamic';

  T? _lub(T? a, T? b) {
    if (a == null || b == null) return null;
    if (a.name == 'Never') return b;
    if (b.name == 'Never') return a;
    if (a.name == 'Null') return _nullable(b);
    if (b.name == 'Null') return _nullable(a);
    final nullable = a.nullable || b.nullable;
    if (a.name == b.name && a.args.length == b.args.length) {
      return a.toString() == b.toString() ? (nullable ? _nullable(a) : a) : _t(a.name, nullable: nullable);
    }
    if (const {'int', 'double', 'num'}.contains(a.name) && const {'int', 'double', 'num'}.contains(b.name)) {
      return _t('num', nullable: nullable);
    }
    return _t('Object', nullable: nullable);
  }

  // ───────────────────────── Class'lar ─────────────────────────

  void _checkClass(ClassDecl c) {
    _typeParams.addAll(c.typeParams);
    try {
      if (c.superclass != null) {
        _checkType(c.superclass);
        final sup = _classes[c.superclass!.name];
        if (sup != null && sup.kind == ClassKind.mixin) {
          _err('extends_mixin', "Mixin'dan `extends` qilib bo'lmaydi — `with` ishlating.", "Classes can only extend other classes.",
              c.superclass!.offset, c.superclass!.end - c.superclass!.offset);
        }
        if (sup != null && sup.modifiers.contains('final') && c.name != sup.name) {
          _err('final_class_extended', "`${sup.name}` final class — undan meros olib bo'lmaydi.",
              "The class '${sup.name}' can't be extended outside of its library because it's a final class.",
              c.superclass!.offset, c.superclass!.end - c.superclass!.offset);
        }
      }
      for (final i in [...c.interfaces, ...c.mixins]) {
        _checkType(i);
      }
      for (final f in c.fields) {
        _checkType(f.decl.type);
      }
      if (!c.isAbstract && c.kind == ClassKind.classDecl) _checkAbstractImplemented(c);
      _checkFieldInitialization(c);

      final instanceScope = _Scope(_global, klass: c, isFunction: false);
      final staticScope = _Scope(_global, klass: c, isStatic: true, isFunction: false);
      for (final f in c.fields) {
        final scope = f.isStatic ? staticScope : instanceScope;
        for (final v in f.decl.vars) {
          if (v.init != null) {
            final t = _expr(v.init!, scope, context: f.decl.type);
            _checkAssign(t, f.decl.type, v.init!, "`${v.name}` maydoni");
          }
        }
      }
      for (final ctor in c.constructors) {
        final scope = _Scope(_global, klass: c, isFunction: true, function: c.name);
        for (final p in ctor.params) {
          final type = p.isFieldFormal ? _fieldType(c, p.name) : p.type;
          if (p.isFieldFormal && _fieldType(c, p.name) == null && !_hasField(c, p.name)) {
            _err('initializing_formal_for_non_existent_field', "`this.${p.name}` — class'da `${p.name}` nomli maydon yo'q.",
                "'${p.name}' isn't a field in the enclosing class.", p.offset, p.name.length + 5,
                hint: "Class ichida maydonni e'lon qiling: String ${p.name};");
          }
          _checkType(p.type);
          if (p.defaultValue != null) _expr(p.defaultValue!, scope);
          scope.vars[p.name] = _Var(type, isLocal: true, kind: 'param', offset: p.offset)..used = true;
          if (p.isNamed && !p.isRequired && p.defaultValue == null && type != null && !type.nullable && !_isDynamic(type)) {
            _err('missing_default_value_for_parameter',
                "`${p.name}` nomli parametr ixtiyoriy, lekin turi null bo'la olmaydi. `required` qo'shing yoki standart qiymat bering.",
                "The parameter '${p.name}' can't have a value of 'null' because of its type, but the implicit default value is 'null'.",
                p.offset, p.name.length,
                hint: "Masalan: {required ${type.name} ${p.name}} yoki {${type.name} ${p.name} = ...}");
          }
        }
        for (final init in ctor.initializers) {
          final t = _expr(init.value, scope);
          if (!_hasField(c, init.field)) {
            _err('initializer_for_non_existent_field', "`${init.field}` nomli maydon yo'q.",
                "'${init.field}' isn't a field in the enclosing class.", init.value.offset, 1);
          }
          _checkAssign(t, _fieldType(c, init.field), init.value, "`${init.field}` maydoni");
        }
        if (ctor.superCall != null) _args(ctor.superCall!, scope);
        if (ctor.redirect != null) _args(ctor.redirect!, scope);
        for (final a in ctor.asserts) {
          _expr(a.condition, scope);
        }
        if (ctor.body != null) {
          final bodyScope = _Scope(scope, klass: c, isFunction: true, function: c.name, returnType: ctor.isFactory ? _t(c.name) : _void);
          if (ctor.isFactory) {
            // factory ichida `this` yo'q.
          }
          _body(ctor.body!, bodyScope, isFactory: ctor.isFactory);
        }
      }
      for (final m in c.methods) {
        _function(m, m.isStatic ? staticScope : instanceScope);
      }
      for (final ev in c.enumValues) {
        if (ev.args != null) _args(ev.args!, staticScope);
      }
    } finally {
      for (final _ in c.typeParams) {
        _typeParams.removeLast();
      }
    }
  }

  bool _hasField(ClassDecl c, String name) => _findField(c, name) != null;

  FieldDecl? _findField(ClassDecl c, String name, [Set<String>? seen]) {
    seen ??= {};
    if (!seen.add(c.name)) return null;
    for (final f in c.fields) {
      for (final v in f.decl.vars) {
        if (v.name == name) return f;
      }
    }
    for (final p in [if (c.superclass != null) c.superclass!, ...c.mixins]) {
      final pc = _classes[p.name];
      if (pc != null) {
        final r = _findField(pc, name, seen);
        if (r != null) return r;
      }
    }
    return null;
  }

  T? _fieldType(ClassDecl c, String name) {
    final f = _findField(c, name);
    if (f == null) return null;
    if (f.decl.type != null) return f.decl.type;
    final v = f.decl.vars.firstWhere((v) => v.name == name);
    if (v.init != null) return _literalType(v.init!);
    return null;
  }

  T? _literalType(Expr e) {
    if (e is Literal) {
      final v = e.value;
      if (v is int) return _int;
      if (v is KDouble) return _double;
      if (v is String) return _string;
      if (v is bool) return _bool;
    }
    if (e is StringInterp) return _string;
    return null;
  }

  /// Class a'zosini (metod, getter, maydon) ota class'lar bilan birga qidiradi.
  (String kind, T? type, FunctionDecl? fn)? _findMember(String className, String name, [Set<String>? seen]) {
    seen ??= {};
    if (!seen.add(className)) return null;
    final c = _classes[className];
    if (c == null) return null;
    for (final m in c.methods) {
      if (m.name == name && !m.isStatic) {
        if (m.isGetter) return ('getter', m.returnType, m);
        if (m.isSetter) return ('setter', m.params.isEmpty ? null : m.params.first.type, m);
        return ('method', m.returnType, m);
      }
    }
    for (final f in c.fields) {
      if (f.isStatic) continue;
      for (final v in f.decl.vars) {
        if (v.name == name) return ('field', f.decl.type ?? (v.init == null ? null : _literalType(v.init!)), null);
      }
    }
    if (c.kind == ClassKind.enumDecl) {
      if (name == 'name') return ('getter', _string, null);
      if (name == 'index') return ('getter', _int, null);
    }
    for (final p in [if (c.superclass != null) c.superclass!, ...c.mixins, ...c.interfaces]) {
      final r = _findMember(p.name, name, seen);
      if (r != null) return r;
    }
    return null;
  }

  (String kind, T? type, FunctionDecl? fn)? _findStatic(ClassDecl c, String name) {
    for (final m in c.methods) {
      if (m.name == name && m.isStatic) return (m.isGetter ? 'getter' : 'method', m.returnType, m);
    }
    for (final f in c.fields) {
      if (!f.isStatic) continue;
      for (final v in f.decl.vars) {
        if (v.name == name) {
          return ('field', f.decl.type ?? (v.init == null ? null : _literalType(v.init!)), null);
        }
      }
    }
    for (final ev in c.enumValues) {
      if (ev.name == name) return ('field', _t(c.name), null);
    }
    if (c.kind == ClassKind.enumDecl && name == 'values') return ('field', _t('List', args: [_t(c.name)]), null);
    return null;
  }

  void _checkAbstractImplemented(ClassDecl c) {
    final abstractMembers = <String, String>{};
    final concrete = <String>{};
    void collect(String name, Set<String> seen, bool isInterface) {
      if (!seen.add(name)) return;
      final k = _classes[name];
      if (k == null) return;
      for (final m in k.methods) {
        if (m.isStatic) continue;
        if (m.body == null || isInterface) {
          abstractMembers.putIfAbsent(m.name, () => k.name);
        } else {
          concrete.add(m.name);
        }
      }
      for (final f in k.fields) {
        for (final v in f.decl.vars) {
          if (isInterface) {
            abstractMembers.putIfAbsent(v.name, () => k.name);
          } else {
            concrete.add(v.name);
          }
        }
      }
      if (k.superclass != null) collect(k.superclass!.name, seen, isInterface);
      for (final mx in k.mixins) {
        collect(mx.name, seen, isInterface);
      }
      for (final i in k.interfaces) {
        collect(i.name, seen, true);
      }
    }

    // O'zi va ota class'lar — konkret a'zolar.
    final own = <String>{};
    for (final m in c.methods) {
      if (m.body != null) own.add(m.name);
      if (m.body == null) {
        _err('concrete_class_with_abstract_member', "`${m.name}` metodining tanasi yo'q, lekin `${c.name}` abstrakt emas.",
            "'${m.name}' must have a method body because '${c.name}' isn't abstract.", m.nameOffset, m.name.length,
            hint: "Yo metodga tana yozing, yo class'ni `abstract class ${c.name}` qiling.");
      }
    }
    for (final f in c.fields) {
      for (final v in f.decl.vars) {
        own.add(v.name);
      }
    }
    collect(c.name, {}, false);
    if (preludeClassNames.contains(c.name)) return;
    for (final e in abstractMembers.entries) {
      if (own.contains(e.key) || concrete.contains(e.key)) continue;
      if (preludeClassNames.contains(e.value)) continue;
      _err('non_abstract_class_inherits_abstract_member',
          "`${c.name}` class'i `${e.value}.${e.key}` ni amalga oshirmagan (implement qilmagan).",
          "Missing concrete implementation of '${e.value}.${e.key}'.", c.nameOffset, c.name.length,
          hint: "`${c.name}` ichiga `@override` bilan `${e.key}` ni yozing.");
    }
  }

  void _checkFieldInitialization(ClassDecl c) {
    for (final f in c.fields) {
      if (f.isStatic || f.decl.isLate) continue;
      final t = f.decl.type;
      for (final v in f.decl.vars) {
        if (v.init != null) continue;
        if (t == null || t.nullable || _isDynamic(t)) {
          if (f.decl.isFinal && t == null) {
            // final x; — konstruktorda berilishi shart.
          } else {
            continue;
          }
        }
        if (c.kind == ClassKind.mixin) continue;
        bool initializedBy(ConstructorDecl ctor) =>
            ctor.isFactory ||
            ctor.redirect != null ||
            ctor.params.any((p) => p.isFieldFormal && p.name == v.name) ||
            ctor.initializers.any((i) => i.field == v.name);
        final ctors = c.constructors.where((k) => !k.isFactory).toList();
        if (ctors.isEmpty) {
          _err('not_initialized_non_nullable_instance_field',
              "`${v.name}` maydoni null bo'la olmaydi, lekin unga qiymat berilmagan.",
              "Non-nullable instance field '${v.name}' must be initialized.", v.offset, v.name.length,
              hint: "Konstruktor yozing: ${c.name}(this.${v.name}); yoki boshlang'ich qiymat bering, yoki turni `${t ?? 'String'}?` qiling.");
        } else {
          for (final ctor in ctors) {
            if (!initializedBy(ctor)) {
              _err('not_initialized_non_nullable_instance_field_constructor',
                  "Konstruktor `${v.name}` maydoniga qiymat bermaydi.",
                  "Non-nullable instance field '${v.name}' must be initialized.", ctor.offset, c.name.length,
                  hint: "Konstruktor parametriga `this.${v.name}` qo'shing.");
            }
          }
        }
      }
    }
  }

  // ───────────────────────── Funksiyalar ─────────────────────────

  void _function(FunctionDecl f, _Scope parent, {T? extensionOn}) {
    _typeParams.addAll(f.typeParams);
    try {
      _checkType(f.returnType);
      final scope = _Scope(parent,
          klass: parent.klass,
          isStatic: f.isStatic || parent.isStatic,
          function: f.name,
          returnType: f.returnType,
          isFunction: true,
          asyncKind: _kindOf(f.isAsync, f.isGenerator));
      _checkAsyncReturnType(f.returnType, f.isAsync, f.isGenerator, f.nameOffset, f.name);
      for (final p in f.params) {
        _checkType(p.type);
        if (p.defaultValue != null) _expr(p.defaultValue!, scope);
        scope.vars[p.name] = _Var(p.type, isLocal: true, kind: 'param', offset: p.offset)..used = true;
        if (p.isNamed && !p.isRequired && p.defaultValue == null && p.type != null && !p.type!.nullable && !_isDynamic(p.type)) {
          _err('missing_default_value_for_parameter',
              "`${p.name}` nomli parametr ixtiyoriy, lekin turi null bo'la olmaydi. `required` qo'shing yoki standart qiymat bering.",
              "The parameter '${p.name}' can't have a value of 'null' because of its type, but the implicit default value is 'null'.",
              p.offset, p.name.length,
              hint: "Masalan: {required ${p.type!.name} ${p.name}} yoki {${p.type!.name} ${p.name} = ...}");
        }
        if (p.isOptionalPositional && p.defaultValue == null && p.type != null && !p.type!.nullable && !_isDynamic(p.type)) {
          _err('missing_default_value_for_parameter_positional',
              "`${p.name}` ixtiyoriy parametr, lekin turi null bo'la olmaydi. Standart qiymat bering yoki turni `${p.type}?` qiling.",
              "The parameter '${p.name}' can't have a value of 'null' because of its type, but the implicit default value is 'null'.",
              p.offset, p.name.length);
        }
      }
      if (f.body != null) {
        _body(f.body!, scope, functionName: f.name, isAsync: f.isAsync || f.isGenerator, nameOffset: f.nameOffset);
      }
      if (f.name == 'main' && parent == _global && f.params.length > 1) {
        _err('main_params', "main() ko'pi bilan bitta parametr (List<String> args) qabul qiladi.",
            "The function 'main' can't have more than one required positional parameter.", f.nameOffset, 4);
      }
    } finally {
      for (final _ in f.typeParams) {
        _typeParams.removeLast();
      }
    }
  }

  void _body(FunctionBody body, _Scope scope,
      {String? functionName, bool isFactory = false, bool isAsync = false, int? nameOffset}) {
    final rt = scope.returnType;
    if (body.expr != null) {
      final ert = _effectiveReturn(rt, scope.asyncKind);
      final t = _expr(body.expr!, scope, context: ert);
      if (ert != null && ert.name != 'void' && (!isAsync || scope.asyncKind == 'async')) {
        _checkReturn(scope.asyncKind == 'async' ? _awaited(t) : t, ert, body.expr!, functionName);
      }
      return;
    }
    final completes = _block(body.block!.statements, scope);
    _reportUnused(scope);
    if (completes && scope.asyncKind == 'async' && rt != null && rt.name == 'Future' && rt.args.isNotEmpty) {
      final inner = rt.args.first;
      if (!inner.nullable && !_isDynamic(inner) && inner.name != 'void' && inner.name != 'Null') {
        _err('body_might_complete_normally',
            "`${functionName ?? 'funksiya'}` `${_show(rt)}` qaytarishi kerak, lekin ba'zi hollarda `return` ga yetmaydi.",
            "The body might complete normally, causing 'null' to be returned, but the return type, 'FutureOr<${_show(inner)}>', is a potentially non-nullable type.",
            nameOffset ?? body.block!.end - 1, nameOffset == null ? 1 : (functionName?.length ?? 1),
            hint: "Funksiya oxiriga `return ...;` qo'shing.");
      }
    }
    if (completes && rt != null && !rt.nullable && !_isDynamic(rt) && rt.name != 'void' && rt.name != 'Null' && !isAsync &&
        rt.name != 'Future' && !isFactory) {
      _err('body_might_complete_normally',
          "`${functionName ?? 'funksiya'}` `${_show(rt)}` qaytarishi kerak, lekin ba'zi hollarda hech narsa qaytarmaydi.",
          "The body might complete normally, causing 'null' to be returned, but the return type, '${_show(rt)}', is a potentially non-nullable type.",
          nameOffset ?? body.block!.end - 1, nameOffset == null ? 1 : (functionName?.length ?? 1),
          hint: "Funksiya oxiriga `return ...;` qo'shing.");
    }
  }

  void _checkReturn(T? t, T rt, Expr e, String? fn) {
    if (!_assignable(t, rt, expr: e)) {
      _err('return_of_invalid_type',
          "`${_show(t)}` turidagi qiymatni qaytarib bo'lmaydi — `${fn ?? 'funksiya'}` `${_show(rt)}` qaytarishi kerak.",
          "A value of type '${_show(t)}' can't be returned from the function '${fn ?? ''}' because it has a return type of '${_show(rt)}'.",
          e.offset, e.end - e.offset);
    }
  }

  void _reportUnused(_Scope scope) {
    for (final e in scope.vars.entries) {
      final v = e.value;
      if (v.isLocal && v.kind == 'var' && !v.used && !e.key.startsWith('_')) {
        _err('unused_local_variable', "`${e.key}` o'zgaruvchisi yaratildi, lekin hech qayerda ishlatilmadi.",
            "The value of the local variable '${e.key}' isn't used.", v.offset, e.key.length,
            severity: Severity.warning);
      }
    }
  }

  // ───────────────────────── Bayonotlar ─────────────────────────

  /// Blokni tekshiradi. Natija: blok oxiriga yetib borishi mumkinmi (normal tugaydimi).
  bool _block(List<Stmt> stmts, _Scope scope) {
    var completes = true;
    for (final s in stmts) {
      if (!completes) {
        _err('dead_code', "Bu kod hech qachon bajarilmaydi (undan oldin return/break bor).", 'Dead code.', s.offset,
            s.end - s.offset, severity: Severity.warning);
        _stmt(s, scope);
        break;
      }
      completes = _stmt(s, scope);
    }
    return completes;
  }

  bool _stmt(Stmt s, _Scope scope) {
    switch (s) {
      case Block():
        final inner = scope.child();
        final r = _block(s.statements, inner);
        _reportUnused(inner);
        return r;
      case VarDecl():
        _varDecl(s, scope);
        return true;
      case ExprStmt():
        _expr(s.expr, scope);
        if (s.expr is ThrowExpr) return false;
        if (s.expr is CallExpr) {
          final c = s.expr as CallExpr;
          if (c.callee is Identifier && (c.callee as Identifier).name == 'exit') return false;
        }
        return true;
      case IfStmt():
        _condition(s.condition, scope, 'if');
        final thenScope = scope.child()..promoted.addAll(_promotions(s.condition, true, scope));
        final thenCompletes = _stmtScoped(s.then, thenScope);
        var elseCompletes = true;
        if (s.otherwise != null) {
          final elseScope = scope.child()..promoted.addAll(_promotions(s.condition, false, scope));
          elseCompletes = _stmtScoped(s.otherwise!, elseScope);
        }
        // `if (x == null) return;` — keyin x null emas.
        if (!thenCompletes) scope.promoted.addAll(_promotions(s.condition, false, scope));
        if (s.otherwise != null && !elseCompletes) scope.promoted.addAll(_promotions(s.condition, true, scope));
        return thenCompletes || elseCompletes;
      case WhileStmt():
        _condition(s.condition, scope, 'while');
        final body = scope.child()..promoted.addAll(_promotions(s.condition, true, scope));
        _stmtScoped(s.body, body, inLoop: true);
        return !_isTrueLiteral(s.condition) || _containsBreak(s.body);
      case DoWhileStmt():
        _stmtScoped(s.body, scope.child(), inLoop: true);
        _condition(s.condition, scope, 'do-while');
        return !_isTrueLiteral(s.condition) || _containsBreak(s.body);
      case ForStmt():
        final loop = scope.child();
        if (s.init != null) _stmt(s.init!, loop);
        if (s.condition != null) _condition(s.condition!, loop, 'for');
        final body = loop.child();
        if (s.condition != null) body.promoted.addAll(_promotions(s.condition!, true, loop));
        _stmtScoped(s.body, body, inLoop: true);
        for (final u in s.updates) {
          _expr(u, loop);
        }
        for (final v in loop.vars.values) {
          v.used = true;
        }
        return s.condition != null || _containsBreak(s.body);
      case ForInStmt():
        final it = _expr(s.iterable, scope);
        final loop = scope.child();
        T? elem;
        if (s.isAwait) {
          if (_enclosingFunctionScope(scope)?.asyncKind?.startsWith('async') != true) {
            _err('await_for_in_non_async', "`await for` faqat `async` funksiya ichida ishlatiladi.",
                "Asynchronous for-in can only be used in functions marked with 'async' or 'async*'.", s.offset, 5,
                hint: "Funksiyaga `async` qo'shing: Future<void> main() async { ... }");
          }
          if (it != null && !_isDynamic(it) && it.name != 'Stream') {
            _err('for_in_of_invalid_type', "`await for` faqat `Stream` bilan ishlaydi, bu yerda `${_show(it)}`.",
                "The type '${_show(it)}' used in the 'for' loop must implement 'Stream'.", s.iterable.offset,
                s.iterable.end - s.iterable.offset,
                hint: it.name == 'List' ? "Ro'yxat uchun oddiy `for (final x in royxat)` yozing." : null);
          }
          if (it != null && it.name == 'Stream' && it.args.isNotEmpty) elem = it.args.first;
        } else if (it != null && it.name == 'Stream') {
          _err('for_in_of_invalid_type', "Stream'ni oddiy `for` bilan aylanib bo'lmaydi — `await for` kerak.",
              "The type '${_show(it)}' used in the 'for' loop must implement 'Iterable'.", s.iterable.offset,
              s.iterable.end - s.iterable.offset,
              hint: "Yozing: await for (final x in oqim) { ... }");
        }
        if (it != null && !s.isAwait) {
          if (it.name == 'Map') {
            _err('for_in_of_invalid_type', "Map'ni to'g'ridan-to'g'ri for-in bilan aylanib bo'lmaydi.",
                "The type 'Map' used in the 'for' loop must implement 'Iterable'.", s.iterable.offset, s.iterable.end - s.iterable.offset,
                hint: "map.keys, map.values yoki map.entries dan foydalaning: for (final e in map.entries) { ... }");
          } else if (it.name == 'String') {
            _err('for_in_of_invalid_type', "String'ni for-in bilan aylanib bo'lmaydi.",
                "The type 'String' used in the 'for' loop must implement 'Iterable'.", s.iterable.offset,
                s.iterable.end - s.iterable.offset,
                hint: "Harflar bo'yicha aylanish: for (final h in matn.split('')) { ... }");
          } else if (const {'int', 'double', 'bool', 'num'}.contains(it.name)) {
            _err('for_in_of_invalid_type', "`${it.name}` turini for-in bilan aylanib bo'lmaydi — ro'yxat (List) kerak.",
                "The type '${it.name}' used in the 'for' loop must implement 'Iterable'.", s.iterable.offset,
                s.iterable.end - s.iterable.offset);
          } else if (it.nullable) {
            _err('for_in_nullable', "Ro'yxat null bo'lishi mumkin — avval tekshiring.",
                "The type '${_show(it)}' used in the 'for' loop must implement 'Iterable'.", s.iterable.offset,
                s.iterable.end - s.iterable.offset);
          }
          if ((it.name == 'List' || it.name == 'Set' || it.name == 'Iterable') && it.args.isNotEmpty) elem = it.args.first;
        }
        if (s.declares) {
          _checkType(s.type);
          if (s.type != null && elem != null && !_assignable(elem, s.type)) {
            _err('for_in_of_invalid_element_type',
                "Ro'yxat elementlari `${_show(elem)}` turida, ularni `${_show(s.type)}` turidagi o'zgaruvchiga berib bo'lmaydi.",
                "The type '${_show(it)}' used in the 'for' loop must implement 'Iterable' with a type argument that can be assigned to '${_show(s.type)}'.",
                s.offset, 3);
          }
          loop.vars[s.name] = _Var(s.type ?? elem, isFinal: s.isFinal, isLocal: true, offset: s.offset)..used = true;
        } else {
          _resolveName(s.name, scope, s.offset, write: true);
        }
        _stmtScoped(s.body, loop.child(), inLoop: true);
        return true;
      case YieldStmt():
        final fs = _enclosingFunctionScope(scope);
        final kind = fs?.asyncKind;
        final t = _expr(s.value, scope);
        if (kind != 'async*' && kind != 'sync*') {
          _err('yield_in_non_generator', "`yield` faqat generator funksiyada ishlatiladi: `sync*` (Iterable) yoki `async*` (Stream).",
              "Yield statements must be in a generator function (one marked with either 'async*' or 'sync*').", s.offset, 5,
              hint: "Masalan: Stream<int> sanash() async* { yield 1; }");
          return true;
        }
        final rt = fs!.returnType;
        if (s.isStar) {
          final want = kind == 'async*' ? 'Stream' : 'Iterable';
          if (t != null && !_isDynamic(t) && t.name != want && !(want == 'Iterable' && (t.name == 'List' || t.name == 'Set'))) {
            _err('yield_of_invalid_type', "`yield*` dan keyin `$want` kerak, bu yerda `${_show(t)}`.",
                "A yielded value of type '${_show(t)}' must be assignable to '$want'.", s.value.offset, s.value.end - s.value.offset);
          }
        } else if (rt != null && rt.args.isNotEmpty && t != null && !_assignable(t, rt.args.first, expr: s.value)) {
          _err('yield_of_invalid_type', "`${_show(t)}` turidagi qiymatni `${_show(rt)}` oqimiga berib bo'lmaydi.",
              "A yielded value of type '${_show(t)}' must be assignable to '${_show(rt.args.first)}'.", s.value.offset,
              s.value.end - s.value.offset);
        }
        return true;
      case BreakStmt():
      case ContinueStmt():
        return false;
      case ReturnStmt():
        final fs = _enclosingFunctionScope(scope);
        if (fs != null && (fs.asyncKind == 'async*' || fs.asyncKind == 'sync*') && s.value != null) {
          _err('return_in_generator', "Generator funksiyada (`${fs.asyncKind}`) `return` qiymat qaytara olmaydi — `yield` ishlating.",
              "Can't return a value from a generator function (using the '${fs.asyncKind}' modifier).", s.offset, 6);
          _expr(s.value!, scope);
          return false;
        }
        if (fs != null && (fs.asyncKind == 'async*' || fs.asyncKind == 'sync*')) return false;
        final rawRt = _enclosingReturnType(scope);
        final rt = rawRt == null ? null : (_effectiveReturn(rawRt.$1, fs?.asyncKind), rawRt.$2);
        if (s.value != null) {
          final t0 = _expr(s.value!, scope, context: rt?.$1);
          final t = fs?.asyncKind == 'async' ? _awaited(t0) : t0;
          if (rt != null && rt.$1 != null) {
            if (rt.$1!.name == 'void' && t?.name != 'void' && !_isDynamic(t) && t?.name != 'Null') {
              _err('return_of_invalid_type_from_void', "`void` funksiya qiymat qaytara olmaydi.",
                  "Can't return a value from a void function.", s.value!.offset, s.value!.end - s.value!.offset,
                  hint: "Funksiya turini qiymat turiga o'zgartiring, masalan: int ${rt.$2 ?? 'f'}() { ... }");
            } else if (rt.$1!.name != 'void') {
              _checkReturn(t, rt.$1!, s.value!, rt.$2);
            }
          }
        } else if (rt != null && rt.$1 != null && rt.$1!.name != 'void' && !rt.$1!.nullable && !_isDynamic(rt.$1)) {
          _err('return_without_value', "`return` dan keyin qiymat yozilishi kerak — funksiya `${_show(rt.$1)}` qaytaradi.",
              "The return value is missing after 'return'.", s.offset, 6);
        }
        return false;
      case SwitchStmt():
        final subject = _expr(s.subject, scope);
        var hasDefault = false;
        var allExit = true;
        for (final c in s.cases) {
          if (c.isDefault) hasDefault = true;
          final cs = scope.child();
          for (var i = 0; i < c.patterns.length; i++) {
            _pattern(c.patterns[i], cs, subject);
            if (c.patterns[i] is WildcardPattern) hasDefault = true;
            if (c.guards[i] != null) _condition(c.guards[i]!, cs, 'when');
          }
          final completes = _block(c.body, cs);
          if (completes && c.body.isNotEmpty && c.body.last is! BreakStmt) {
            // Dart 3: case tanasi oxirida break shart emas.
          }
          if (completes || (c.body.isNotEmpty && c.body.last is BreakStmt)) allExit = false;
        }
        if (subject != null && _classes[subject.name]?.kind == ClassKind.enumDecl && !hasDefault) {
          final e = _classes[subject.name]!;
          final covered = <String>{};
          for (final c in s.cases) {
            for (final p in c.patterns) {
              if (p is ConstPattern && p.expr is PropertyGet) covered.add((p.expr as PropertyGet).name);
            }
          }
          final missing = e.enumValues.map((v) => v.name).where((n) => !covered.contains(n)).toList();
          if (missing.isNotEmpty) {
            _err('non_exhaustive_switch_statement',
                "switch barcha holatlarni qamramaydi: ${missing.map((m) => '${e.name}.$m').join(', ')} yetishmayapti.",
                "The type '${e.name}' isn't exhaustively matched by the switch cases since it doesn't match '${e.name}.${missing.first}'.",
                s.offset, 6, hint: "Yetishmayotgan case'larni yoki `default:` ni qo'shing.");
          }
          hasDefault = missing.isEmpty;
        }
        return !(hasDefault && allExit);
      case TryStmt():
        final bodyCompletes = _stmt(s.body, scope);
        var anyCatchCompletes = false;
        for (final c in s.catches) {
          _checkType(c.onType);
          final cs = scope.child();
          if (c.exceptionName != null) cs.vars[c.exceptionName!] = _Var(c.onType, isFinal: true, isLocal: true)..used = true;
          if (c.stackName != null) cs.vars[c.stackName!] = _Var(_t('StackTrace'), isFinal: true, isLocal: true)..used = true;
          if (_block(c.body.statements, cs)) anyCatchCompletes = true;
        }
        var finallyCompletes = true;
        if (s.finallyBlock != null) finallyCompletes = _stmt(s.finallyBlock!, scope);
        return finallyCompletes && (bodyCompletes || anyCatchCompletes);
      case RethrowStmt():
        return false;
      case AssertStmt():
        _condition(s.condition, scope, 'assert');
        if (s.message != null) _expr(s.message!, scope);
        return true;
      case LocalFunctionStmt():
        scope.vars[s.function.name] = _Var(_t('Function'), kind: 'function', isFinal: true, isLocal: true)
          ..function = s.function
          ..used = true;
        _function(s.function, scope);
        return true;
      case LabeledStmt():
        return _stmt(s.body, scope);
      case EmptyStmt():
        return true;
    }
  }

  bool _stmtScoped(Stmt s, _Scope scope, {bool inLoop = false}) {
    final r = s is Block ? _block(s.statements, scope) : _stmt(s, scope);
    _reportUnused(scope);
    return r;
  }

  bool _isTrueLiteral(Expr e) => e is Literal && e.value == true;

  bool _containsBreak(Stmt s) {
    var found = false;
    void visit(Stmt st, int depth) {
      switch (st) {
        case BreakStmt():
          if (depth == 0 || st.label != null) found = true;
        case Block():
          for (final x in st.statements) {
            visit(x, depth);
          }
        case IfStmt():
          visit(st.then, depth);
          if (st.otherwise != null) visit(st.otherwise!, depth);
        case TryStmt():
          visit(st.body, depth);
          for (final c in st.catches) {
            visit(c.body, depth);
          }
        case ForStmt():
          visit(st.body, depth + 1);
        case ForInStmt():
          visit(st.body, depth + 1);
        case WhileStmt():
          visit(st.body, depth + 1);
        case DoWhileStmt():
          visit(st.body, depth + 1);
        case SwitchStmt():
          for (final c in st.cases) {
            for (final x in c.body) {
              visit(x, depth + 1);
            }
          }
        case LabeledStmt():
          visit(st.body, depth);
        default:
          break;
      }
    }

    visit(s, 0);
    return found;
  }

  _Scope? _enclosingFunctionScope(_Scope scope) {
    _Scope? s = scope;
    while (s != null) {
      if (s.isFunction) return s;
      s = s.parent;
    }
    return null;
  }

  static String? _kindOf(bool isAsync, bool isGenerator) =>
      isAsync ? (isGenerator ? 'async*' : 'async') : (isGenerator ? 'sync*' : null);

  /// `Future<int>` qaytaradigan async funksiyada `return` qiymati `int` bo'ladi.
  T? _effectiveReturn(T? rt, String? kind) {
    if (rt == null || kind != 'async') return rt;
    if ((rt.name == 'Future' || rt.name == 'FutureOr') && rt.args.isNotEmpty) return rt.args.first;
    if (rt.name == 'Future') return _dynamic;
    return rt;
  }

  /// `await x` turi: Future<T> → T.
  T? _awaited(T? t) {
    if (t == null) return null;
    if ((t.name == 'Future' || t.name == 'FutureOr') && t.args.isNotEmpty) return t.args.first;
    if (t.name == 'Future') return null;
    return t;
  }

  void _checkAsyncReturnType(T? rt, bool isAsync, bool isGenerator, int offset, String name) {
    if (rt == null || _isDynamic(rt)) return;
    final kind = _kindOf(isAsync, isGenerator);
    final ok = switch (kind) {
      'async' => rt.name == 'Future' || rt.name == 'FutureOr' || rt.name == 'void' || rt.name == 'Object',
      'async*' => rt.name == 'Stream' || rt.name == 'Object',
      'sync*' => rt.name == 'Iterable' || rt.name == 'Object',
      _ => true,
    };
    if (ok) return;
    final (want, example) = switch (kind) {
      'async' => ('Future', 'Future<${_show(rt)}> $name() async'),
      'async*' => ('Stream', 'Stream<int> $name() async*'),
      _ => ('Iterable', 'Iterable<int> $name() sync*'),
    };
    _err('illegal_${kind == 'async' ? 'async' : (kind == 'async*' ? 'async_generator' : 'sync_generator')}_return_type',
        "`$kind` funksiya `$want` qaytarishi kerak, bu yerda `${_show(rt)}`.",
        "Functions marked '$kind' must have a return type which is a supertype of '$want'.", rt.offset,
        rt.end - rt.offset, hint: "Masalan: $example { ... }");
  }

  (T?, String?)? _enclosingReturnType(_Scope scope) {
    _Scope? s = scope;
    while (s != null) {
      if (s.isFunction) return (s.returnType, s.function);
      s = s.parent;
    }
    return null;
  }

  void _condition(Expr e, _Scope scope, String what) {
    final t = _expr(e, scope);
    if (t != null && !_isDynamic(t) && (t.name != 'bool' || t.nullable)) {
      _err('non_bool_condition', "$what sharti `bool` (true/false) bo'lishi kerak, lekin bu yerda `${_show(t)}`.",
          "Conditions must have a static type of 'bool'.", e.offset, e.end - e.offset,
          hint: t.name == 'int'
              ? "Taqqoslash yozing, masalan: if (son > 0)"
              : (t.nullable && t.name == 'bool' ? "`?? false` qo'shing yoki null emasligini tekshiring." : null));
    }
  }

  void _varDecl(VarDecl s, _Scope scope, {bool isTopLevel = false}) {
    _checkType(s.type);
    for (final v in s.vars) {
      T? t;
      if (v.init != null) {
        t = _expr(v.init!, scope, context: s.type);
        if (s.type != null) {
          _checkAssign(t, s.type, v.init!, "`${v.name}`");
        }
      } else if (s.isFinal && !s.isLate && s.type == null && !isTopLevel) {
        // final x; — keyin qiymat beriladi, Dart buni ruxsat beradi.
      } else if (s.isConst) {
        _err('const_not_initialized', "const o'zgaruvchiga darhol qiymat berilishi shart.",
            "The constant '${v.name}' must be initialized.", v.offset, v.name.length);
      } else if (isTopLevel && s.type != null && !s.type!.nullable && !s.isLate && !_isDynamic(s.type)) {
        _err('not_initialized_non_nullable_variable', "`${v.name}` null bo'la olmaydi, shuning uchun unga darhol qiymat bering.",
            "The non-nullable variable '${v.name}' must be initialized.", v.offset, v.name.length,
            hint: "Masalan: ${s.type} ${v.name} = ...; yoki ${s.type}? ${v.name};");
      }
      if (scope.vars.containsKey(v.name) && scope != _global) {
        _err('duplicate_definition', "`${v.name}` nomli o'zgaruvchi shu blokda allaqachon e'lon qilingan.",
            "The name '${v.name}' is already defined.", v.offset, v.name.length,
            hint: "Qiymatini o'zgartirish uchun qaytadan e'lon qilmang: ${v.name} = yangiQiymat;");
      }
      var type = s.type ?? (t?.name == 'Null' ? null : t);
      if (s.type == null && t != null && t.name == 'List' && t.args.isEmpty) type = t;
      scope.vars[v.name] = _Var(type,
          isFinal: s.isFinal || s.isConst,
          isConst: s.isConst,
          isLate: s.isLate,
          isLocal: scope != _global,
          offset: v.offset)
        ..used = scope == _global;
      if (v.init == null && s.type != null && s.type!.nullable) {
        // Nullable — boshlang'ich qiymati null.
      }
    }
  }

  void _checkAssign(T? from, T? to, Expr e, String what) {
    if (to == null) return;
    if (e is ListLiteral && e.typeArg == null && to.name == 'List' && to.args.isNotEmpty) {
      for (final el in e.elements) {
        if (el is ExprElement) {
          final et = _literalOrKnown(el.expr);
          if (et != null && !_assignable(et, to.args.first, expr: el.expr)) {
            _err('list_element_type_not_assignable',
                "Ro'yxatga `${_show(et)}` turidagi elementni qo'shib bo'lmaydi — u `${_show(to.args.first)}` elementlari uchun.",
                "The element type '${_show(et)}' can't be assigned to the list type '${_show(to.args.first)}'.",
                el.expr.offset, el.expr.end - el.expr.offset);
          }
        }
      }
      return;
    }
    if (e is SetOrMapLiteral && e.typeArgs.isEmpty && to.name == 'Map' && to.args.length == 2) {
      for (final el in e.elements) {
        if (el is MapEntryElement) {
          final kt = _literalOrKnown(el.key), vt = _literalOrKnown(el.value);
          if (kt != null && !_assignable(kt, to.args[0], expr: el.key)) {
            _err('map_key_type_not_assignable', "Kalit `${_show(kt)}` turida, lekin map kalitlari `${_show(to.args[0])}`.",
                "The element type '${_show(kt)}' can't be assigned to the map key type '${_show(to.args[0])}'.",
                el.key.offset, el.key.end - el.key.offset);
          }
          if (vt != null && !_assignable(vt, to.args[1], expr: el.value)) {
            _err('map_value_type_not_assignable', "Qiymat `${_show(vt)}` turida, lekin map qiymatlari `${_show(to.args[1])}`.",
                "The element type '${_show(vt)}' can't be assigned to the map value type '${_show(to.args[1])}'.",
                el.value.offset, el.value.end - el.value.offset);
          }
        }
      }
      return;
    }
    if (e is SetOrMapLiteral && e.typeArgs.isEmpty && e.elements.isEmpty && to.name == 'Set') return;
    if (!_assignable(from, to, expr: e)) {
      final nullHint = from != null && from.nullable && !to.nullable
          ? "Qiymat null bo'lishi mumkin. `?? standartQiymat` qo'shing, `!` ishlating yoki turni `${to.name}?` qiling."
          : (from?.name == 'double' && to.name == 'int'
              ? "`/` har doim double qaytaradi. Butun bo'lish uchun `~/` ishlating yoki .toInt() chaqiring."
              : (from?.name == 'String' && (to.name == 'int' || to.name == 'double')
                  ? "Matnni songa aylantirish: ${to.name}.parse(matn)"
                  : ((from?.name == 'int' || from?.name == 'double') && to.name == 'String'
                      ? "Sonni matnga aylantirish: son.toString() yoki '\$son'"
                      : null)));
      _err('invalid_assignment',
          "`${_show(from)}` turidagi qiymatni `${_show(to)}` turidagi $what ga berib bo'lmaydi.",
          "A value of type '${_show(from)}' can't be assigned to a variable of type '${_show(to)}'.",
          e.offset, e.end - e.offset, hint: nullHint);
    }
  }

  T? _literalOrKnown(Expr e) => _literalType(e) ?? (e is Literal && e.value == null ? _null : null);

  // ───────────────────────── Nomlar ─────────────────────────

  /// Promotion: `x != null` shartidan keyin x null emas.
  Map<String, T> _promotions(Expr cond, bool whenTrue, _Scope scope) {
    final out = <String, T>{};
    if (cond is BinaryExpr && (cond.op == '!=' || cond.op == '==')) {
      Identifier? id;
      if (cond.left is Identifier && cond.right is Literal && (cond.right as Literal).value == null) id = cond.left as Identifier;
      if (cond.right is Identifier && cond.left is Literal && (cond.left as Literal).value == null) id = cond.right as Identifier;
      if (id != null && ((cond.op == '!=') == whenTrue)) {
        final t = _typeOfName(id.name, scope);
        if (t != null) out[id.name] = _nonNull(t);
      }
    } else if (cond is BinaryExpr && cond.op == '&&' && whenTrue) {
      out.addAll(_promotions(cond.left, true, scope));
      out.addAll(_promotions(cond.right, true, scope));
    } else if (cond is BinaryExpr && cond.op == '||' && !whenTrue) {
      out.addAll(_promotions(cond.left, false, scope));
      out.addAll(_promotions(cond.right, false, scope));
    } else if (cond is UnaryExpr && cond.op == '!') {
      out.addAll(_promotions(cond.operand, !whenTrue, scope));
    } else if (cond is IsExpr && cond.expr is Identifier && cond.negated != whenTrue) {
      out[(cond.expr as Identifier).name] = cond.type;
    }
    return out;
  }

  T? _typeOfName(String name, _Scope scope) {
    _Scope? s = scope;
    while (s != null) {
      final p = s.promoted[name];
      if (p != null) return p;
      final v = s.vars[name];
      if (v != null) return v.type;
      if (s.klass != null) {
        final m = _findMember(s.klass!.name, name) ?? _findStatic(s.klass!, name);
        if (m != null) return m.$1 == 'method' ? _t('Function') : m.$2;
      }
      s = s.parent;
    }
    return null;
  }

  ({_Var? v, T? type, bool found, String kind, FunctionDecl? fn}) _resolveName(String name, _Scope scope, int offset,
      {bool write = false, bool isCall = false, int length = 0}) {
    _Scope? s = scope;
    T? promoted;
    while (s != null) {
      if (promoted == null && s.promoted.containsKey(name)) promoted = s.promoted[name];
      final v = s.vars[name];
      if (v != null) {
        if (!write) v.used = true;
        return (v: v, type: write ? v.type : (promoted ?? v.type), found: true, kind: v.kind, fn: v.function);
      }
      // extension ichida: `this` ning a'zolari nomsiz ham ko'rinadi.
      final self = s.vars['this'];
      if (self != null && self.type != null && s.klass == null) {
        final members = _builtinMembers(_nonNull(self.type!));
        final m = members?[name] ?? _objectMembers[name];
        if (m != null) {
          return (v: null, type: m.isGetter ? _resolveRet(m.ret, self.type!) : _t('Function'), found: true, kind: m.isGetter ? 'getter' : 'method', fn: null);
        }
        if (_classes.containsKey(self.type!.name)) {
          final cm = _findMember(self.type!.name, name);
          if (cm != null) return (v: null, type: cm.$1 == 'method' ? _t('Function') : cm.$2, found: true, kind: cm.$1, fn: cm.$3);
        }
        if (_extensionMembers.containsKey(name)) {
          final f = _extensionMembers[name]!.first;
          return (v: null, type: f.isGetter ? f.returnType : _t('Function'), found: true, kind: f.isGetter ? 'getter' : 'method', fn: f.isGetter ? null : f);
        }
      }
      if (s.klass != null) {
        final m = s.isStatic ? _findStatic(s.klass!, name) : (_findMember(s.klass!.name, name) ?? _findStatic(s.klass!, name));
        if (m != null) {
          if (s.isStatic && _findStatic(s.klass!, name) == null) {
            _err('instance_member_access_from_static', "Statik metod ichida obyekt a'zosi `$name` ga murojaat qilib bo'lmaydi.",
                "Instance members can't be accessed from a static method.", offset, name.length);
          }
          return (v: null, type: promoted ?? (m.$1 == 'method' ? _t('Function') : m.$2), found: true, kind: m.$1, fn: m.$3);
        }
      }
      s = s.parent;
    }
    final lib = _libraryType(name);
    if (lib != null) return (v: null, type: promoted ?? lib, found: true, kind: 'library', fn: null);
    if (const {'print', 'identical'}.contains(name)) {
      return (v: null, type: _t('Function'), found: true, kind: 'builtin', fn: null);
    }
    if (_needsAsyncImport(name)) {
      _err('undefined_identifier', "`$name` aniqlanmagan — u `dart:async` kutubxonasida joylashgan.", "Undefined name '$name'.",
          offset, length == 0 ? name.length : length,
          hint: "Fayl boshiga qo'shing: import 'dart:async';");
      return (v: null, type: null, found: false, kind: '', fn: null);
    }
    if (builtinTypeNames.contains(name)) return (v: null, type: _t('Type'), found: true, kind: 'type', fn: null);
    if (_classes.containsKey(name)) return (v: null, type: _t('Type'), found: true, kind: 'class', fn: null);
    _undefined(name, scope, offset, isCall: isCall, length: length);
    return (v: null, type: null, found: false, kind: '', fn: null);
  }

  T? _libraryType(String name) {
    if (_flutter && _flutterNames.contains(name)) return _dynamic;
    for (final lib in _imported) {
      final m = _libraryNames[lib];
      if (m != null && m.containsKey(name)) return _parseTypeString(m[name]!);
    }
    return null;
  }

  String? _libraryProviding(String name) {
    if (flutterMemberNames.contains(name)) return 'package:flutter/material.dart';
    for (final e in _libraryNames.entries) {
      if (e.value.containsKey(name)) return e.key;
    }
    return null;
  }

  void _undefined(String name, _Scope scope, int offset, {required bool isCall, int length = 0}) {
    final lib = _libraryProviding(name);
    if (lib != null) {
      _err('undefined_identifier', "`$name` aniqlanmagan — u `$lib` kutubxonasida joylashgan.",
          "Undefined name '$name'.", offset, length == 0 ? name.length : length,
          hint: "Fayl boshiga qo'shing: import '$lib';");
      return;
    }
    final candidates = <String>{'print', 'main', ..._allNames(scope), ...builtinTypeNames, ..._classes.keys, if (_flutter) ..._flutterNames};
    String? best;
    var bestScore = 3;
    for (final c in candidates) {
      if (c.toLowerCase() == name.toLowerCase() && c != name) {
        best = c;
        bestScore = 0;
        break;
      }
      final d = _levenshtein(c, name);
      if (d < bestScore && d <= (name.length > 4 ? 2 : 1)) {
        bestScore = d;
        best = c;
      }
    }
    final hint = best != null
        ? (best.toLowerCase() == name.toLowerCase()
            ? "Dart katta-kichik harfni farqlaydi. `$best` demoqchimisiz?"
            : "`$best` demoqchimisiz?")
        : (isCall ? "Funksiyani avval e'lon qiling: void $name() { ... }" : "O'zgaruvchini avval e'lon qiling: var $name = ...;");
    if (isCall) {
      _err('undefined_function', "`$name` nomli funksiya topilmadi.", "The function '$name' isn't defined.", offset,
          length == 0 ? name.length : length, hint: hint);
    } else {
      _err('undefined_identifier', "`$name` nomi aniqlanmagan.", "Undefined name '$name'.", offset,
          length == 0 ? name.length : length, hint: hint);
    }
  }

  Iterable<String> _allNames(_Scope scope) sync* {
    _Scope? s = scope;
    while (s != null) {
      yield* s.vars.keys;
      s = s.parent;
    }
  }

  int _levenshtein(String a, String b) {
    if ((a.length - b.length).abs() > 2) return 99;
    final dp = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[a.length][b.length];
  }

  // ───────────────────────── Ifodalar ─────────────────────────

  T? _expr(Expr e, _Scope scope, {T? context}) {
    switch (e) {
      case Literal():
        final v = e.value;
        if (v == null) return _null;
        if (v is int) return context?.name == 'double' ? _double : _int;
        if (v is KDouble) return _double;
        if (v is String) return _string;
        if (v is bool) return _bool;
        return null;
      case StringInterp():
        for (final p in e.parts) {
          if (p is Expr) _expr(p, scope);
        }
        return _string;
      case Identifier():
        if (e.name == '_') return null;
        final r = _resolveName(e.name, scope, e.offset);
        if (r.kind == 'class' || r.kind == 'type') return _t('Type', args: [_t(e.name)]);
        return r.type;
      case ThisExpr():
        final k = _enclosingClass(scope);
        if (k == null) {
          final t = _typeOfName('this', scope);
          if (t != null) return t;
          _err('invalid_this', "`this` faqat class ichida ishlatiladi.", "Invalid reference to 'this' expression.", e.offset, 4);
          return null;
        }
        return _t(k.name);
      case SuperExpr():
        final k = _enclosingClass(scope);
        return k?.superclass;
      case ListLiteral():
        _checkType(e.typeArg);
        T? elem = e.typeArg;
        T? lub;
        var first = true;
        final contextElem = context?.name == 'List' && context!.args.isNotEmpty ? context.args.first : null;
        for (final el in e.elements) {
          final t = _element(el, scope, contextElem ?? e.typeArg);
          if (e.typeArg != null && t != null && el is ExprElement && !_assignable(t, e.typeArg, expr: el.expr)) {
            _err('list_element_type_not_assignable',
                "Ro'yxatga `${_show(t)}` turidagi elementni qo'shib bo'lmaydi — u `${_show(e.typeArg)}` elementlari uchun.",
                "The element type '${_show(t)}' can't be assigned to the list type '${_show(e.typeArg)}'.",
                el.expr.offset, el.expr.end - el.expr.offset);
          }
          if (el is ExprElement) {
            lub = first ? t : _lub(lub, t);
            first = false;
          } else {
            lub = null;
            first = false;
          }
        }
        elem ??= first ? (contextElem ?? _dynamic) : (lub ?? _dynamic);
        return _t('List', args: [elem]);
      case SetOrMapLiteral():
        for (final a in e.typeArgs) {
          _checkType(a);
        }
        if (e.isMap) {
          T? kl, vl;
          var first = true;
          for (final el in e.elements) {
            if (el is MapEntryElement) {
              final kt = _expr(el.key, scope);
              final vt = _expr(el.value, scope);
              kl = first ? kt : _lub(kl, kt);
              vl = first ? vt : _lub(vl, vt);
              first = false;
            } else {
              _element(el, scope, null);
              kl = null;
              vl = null;
              first = false;
            }
          }
          if (e.typeArgs.length == 2) return _t('Map', args: e.typeArgs);
          if (first && context?.name == 'Map') return context;
          return _t('Map', args: [kl ?? _dynamic, vl ?? _dynamic]);
        }
        T? lub;
        var first = true;
        for (final el in e.elements) {
          final t = _element(el, scope, null);
          lub = first ? t : _lub(lub, t);
          first = false;
        }
        return _t('Set', args: [e.typeArgs.isNotEmpty ? e.typeArgs.first : (lub ?? _dynamic)]);
      case RecordLiteral():
        for (final p in e.positional) {
          _expr(p, scope);
        }
        for (final n in e.named.values) {
          _expr(n, scope);
        }
        return _t('Record');
      case UnaryExpr():
        final t = _expr(e.operand, scope);
        if (e.op == '!') {
          if (t != null && !_isDynamic(t) && (t.name != 'bool' || t.nullable)) {
            _err('non_bool_negation', "`!` faqat bool qiymatga qo'llanadi, bu yerda `${_show(t)}`.",
                "A negation operand must have a static type of 'bool'.", e.operand.offset, e.operand.end - e.operand.offset);
          }
          return _bool;
        }
        if (t != null && t.nullable && !_isDynamic(t)) _nullableOperator(e.op, e.operand);
        return t == null ? null : _nonNull(t);
      case IncDecExpr():
        final t = _expr(e.target, scope);
        _checkWritable(e.target, scope);
        if (t != null && !_isDynamic(t)) {
          if (t.nullable) {
            _nullableOperator(e.op, e.target);
          } else if (!const {'int', 'double', 'num'}.contains(t.name)) {
            _err('undefined_operator', "`${e.op}` faqat sonlarga qo'llanadi, `${_show(t)}` ga emas.",
                "The operator '${e.op == '++' ? '+' : '-'}' isn't defined for the type '${_show(t)}'.", e.offset, e.end - e.offset);
          }
        }
        return t;
      case BinaryExpr():
        return _binary(e, scope);
      case ConditionalExpr():
        _condition(e.condition, scope, '?:');
        final ts = scope.child()..promoted.addAll(_promotions(e.condition, true, scope));
        final es = scope.child()..promoted.addAll(_promotions(e.condition, false, scope));
        final a = _expr(e.then, ts, context: context);
        final b = _expr(e.otherwise, es, context: context);
        return _lub(a, b);
      case AssignExpr():
        return _assign(e, scope);
      case PropertyGet():
        return _property(e, scope);
      case IndexExpr():
        final t = _expr(e.target, scope);
        final it = _expr(e.index, scope);
        if (t == null || _isDynamic(t)) return null;
        if (t.nullable && !e.nullAware) {
          _err('unchecked_use_of_nullable_value', "Qiymat null bo'lishi mumkin — `[]` ni to'g'ridan-to'g'ri ishlatib bo'lmaydi.",
              "The operator '[]' can't be unconditionally invoked because the receiver can be 'null'.", e.offset, e.end - e.offset,
              hint: "`?[` yoki `!` ishlating yoki avval null emasligini tekshiring.");
        }
        if (t.name == 'List') {
          if (it != null && !_isDynamic(it) && it.name != 'int') {
            _err('argument_type_not_assignable', "Ro'yxat indeksi `int` bo'lishi kerak, bu yerda `${_show(it)}`.",
                "The argument type '${_show(it)}' can't be assigned to the parameter type 'int'.", e.index.offset,
                e.index.end - e.index.offset);
          }
          final elem = t.args.isEmpty ? null : t.args.first;
          return e.nullAware && elem != null ? _nullable(elem) : elem;
        }
        if (t.name == 'String') return _string;
        if (t.name == 'Map') return t.args.length == 2 ? _nullable(t.args[1]) : null;
        if (const {'int', 'double', 'bool', 'num'}.contains(t.name)) {
          _err('undefined_operator', "`${t.name}` turida `[]` operatori yo'q.",
              "The operator '[]' isn't defined for the type '${t.name}'.", e.offset, e.end - e.offset);
        }
        return null;
      case CallExpr():
        return _call(e, scope);
      case MethodCall():
        return _methodCall(e, scope);
      case CascadeExpr():
        final t = _expr(e.target, scope);
        final cs = scope.child()..vars[r'$cascade'] = _Var(t);
        for (final s in e.sections) {
          _expr(s, cs);
        }
        return t;
      case CascadeTarget():
        return _typeOfName(r'$cascade', scope);
      case FunctionExpr():
        final fs = _Scope(scope,
            klass: scope.klass, isStatic: scope.isStatic, isFunction: true, function: '', asyncKind: _kindOf(e.isAsync, e.isGenerator));
        for (final p in e.params) {
          _checkType(p.type);
          fs.vars[p.name] = _Var(p.type, isLocal: true, kind: 'param')..used = true;
        }
        if (e.body.expr != null) {
          _expr(e.body.expr!, fs);
        } else {
          _block(e.body.block!.statements, fs);
          _reportUnused(fs);
        }
        return _t('Function');
      case IsExpr():
        _expr(e.expr, scope);
        _checkType(e.type);
        return _bool;
      case AsExpr():
        _expr(e.expr, scope);
        _checkType(e.type);
        return e.type;
      case NullAssertExpr():
        final t = _expr(e.expr, scope);
        if (t != null && !t.nullable && !_isDynamic(t) && t.name != 'Null') {
          _err('unnecessary_non_null_assertion', "`!` keraksiz — bu qiymat hech qachon null bo'lmaydi.",
              "The '!' will have no effect because the receiver can't be null.", e.end - 1, 1, severity: Severity.warning);
        }
        return t == null ? null : _nonNull(t);
      case ThrowExpr():
        _expr(e.expr, scope);
        return _t('Never');
      case AwaitExpr():
        final kind = _enclosingFunctionScope(scope)?.asyncKind;
        if (kind != 'async' && kind != 'async*') {
          _err('await_in_wrong_context', "`await` faqat `async` funksiya ichida ishlatiladi.",
              "The await expression can only be used in an async function.", e.offset, 5,
              hint: "Funksiya tanasidan oldin `async` yozing va qaytarish turini Future qiling: Future<void> main() async { ... }");
        }
        return _awaited(_expr(e.expr, scope));
      case SwitchExpr():
        final subject = _expr(e.subject, scope);
        T? result;
        var first = true;
        for (final c in e.cases) {
          final cs = scope.child();
          _pattern(c.pattern, cs, subject);
          if (c.guard != null) _condition(c.guard!, cs, 'when');
          final t = _expr(c.body, cs, context: context);
          result = first ? t : _lub(result, t);
          first = false;
        }
        return result;
    }
  }

  ClassDecl? _enclosingClass(_Scope scope) {
    _Scope? s = scope;
    while (s != null) {
      if (s.klass != null) return s.isStatic ? null : s.klass;
      s = s.parent;
    }
    return null;
  }

  T? _element(CollectionElement el, _Scope scope, T? context) {
    switch (el) {
      case ExprElement():
        return _expr(el.expr, scope, context: context);
      case MapEntryElement():
        _expr(el.key, scope);
        _expr(el.value, scope);
        return null;
      case SpreadElement():
        final t = _expr(el.expr, scope);
        return t != null && t.args.isNotEmpty ? t.args.first : null;
      case IfElement():
        _condition(el.condition, scope, 'collection-if');
        final ts = scope.child()..promoted.addAll(_promotions(el.condition, true, scope));
        final a = _element(el.then, ts, context);
        if (el.otherwise != null) return _lub(a, _element(el.otherwise!, scope, context));
        return a;
      case ForElement():
        final fs = scope.child();
        _stmt(el.loop is ForStmt ? (el.loop as ForStmt).init ?? EmptyStmt(0, 0) : EmptyStmt(0, 0), fs);
        final loop = el.loop;
        if (loop is ForInStmt) {
          final it = _expr(loop.iterable, scope);
          fs.vars[loop.name] = _Var(loop.type ?? (it != null && it.args.isNotEmpty ? it.args.first : null), isLocal: true)
            ..used = true;
        } else if (loop is ForStmt) {
          if (loop.condition != null) _expr(loop.condition!, fs);
          for (final u in loop.updates) {
            _expr(u, fs);
          }
          for (final v in fs.vars.values) {
            v.used = true;
          }
        }
        return _element(el.body, fs, context);
    }
  }

  void _nullableOperator(String op, Expr receiver) {
    _err('unchecked_use_of_nullable_value',
        "Qiymat null bo'lishi mumkin, shuning uchun `$op` amalini to'g'ridan-to'g'ri bajarib bo'lmaydi.",
        "The operator '$op' can't be unconditionally invoked because the receiver can be 'null'.",
        receiver.offset, receiver.end - receiver.offset,
        hint: "Avval tekshiring: if (x != null) { ... }, yoki `x ?? 0` / `x!` dan foydalaning.");
  }

  T? _binary(BinaryExpr e, _Scope scope) {
    if (e.op == '&&' || e.op == '||') {
      _condition(e.left, scope, "`${e.op}` ning chap tomoni");
      final rs = scope.child()..promoted.addAll(_promotions(e.left, e.op == '&&', scope));
      _condition(e.right, rs, "`${e.op}` ning o'ng tomoni");
      return _bool;
    }
    final l = _expr(e.left, scope);
    final r = _expr(e.right, scope);
    if (e.op == '??') {
      if (l != null && !l.nullable && !_isDynamic(l) && l.name != 'Null') {
        _err('dead_null_aware_expression', "`??` keraksiz — chap tomon hech qachon null bo'lmaydi.",
            "The left operand can't be null, so the right operand is never executed.", e.right.offset,
            e.right.end - e.right.offset, severity: Severity.warning);
      }
      if (l == null) return r;
      return _lub(_nonNull(l), r);
    }
    if (e.op == '==' || e.op == '!=') return _bool;
    if (l == null || r == null || _isDynamic(l) || _isDynamic(r)) {
      if (const {'<', '>', '<=', '>='}.contains(e.op)) return _bool;
      if (e.op == '/') return _double;
      if (l != null && l.name == 'String' && e.op == '+') return _string;
      return null;
    }
    if (l.nullable) {
      _nullableOperator(e.op, e.left);
      return null;
    }
    bool isNum(T t) => const {'int', 'double', 'num'}.contains(t.name);
    if (isNum(l)) {
      if (!isNum(r) || r.nullable) {
        if (r.nullable && isNum(r)) {
          _err('argument_type_not_assignable', "O'ng tomondagi qiymat null bo'lishi mumkin (`${_show(r)}`).",
              "The argument type '${_show(r)}' can't be assigned to the parameter type 'num'.", e.right.offset,
              e.right.end - e.right.offset, hint: "`?? 0` qo'shing yoki `!` ishlating.");
          return null;
        }
        if (const {'+', '-', '*', '/', '~/', '%', '<', '>', '<=', '>='}.contains(e.op)) {
          _err('argument_type_not_assignable',
              "Songa `${_show(r)}` turidagi qiymatni `${e.op}` bilan qo'shib/taqqoslab bo'lmaydi.",
              "The argument type '${_show(r)}' can't be assigned to the parameter type 'num'.", e.right.offset,
              e.right.end - e.right.offset,
              hint: r.name == 'String'
                  ? "Matnni songa aylantiring: int.parse(matn). Yoki birlashtirish uchun interpolatsiya: '\$son\$matn'"
                  : null);
        }
        return null;
      }
      switch (e.op) {
        case '<':
        case '>':
        case '<=':
        case '>=':
          return _bool;
        case '/':
          return _double;
        case '~/':
          return _int;
        case '+':
        case '-':
        case '*':
        case '%':
          if (l.name == 'int' && r.name == 'int') return _int;
          if (l.name == 'double' || r.name == 'double') return _double;
          return _num;
        case '&':
        case '|':
        case '^':
        case '<<':
        case '>>':
        case '>>>':
          return _int;
      }
    }
    if (l.name == 'String') {
      if (e.op == '+') {
        if (r.name != 'String' || r.nullable) {
          _err('argument_type_not_assignable',
              "String'ga `${_show(r)}` turidagi qiymatni `+` bilan qo'shib bo'lmaydi.",
              "The argument type '${_show(r)}' can't be assigned to the parameter type 'String'.", e.right.offset,
              e.right.end - e.right.offset,
              hint: "Interpolatsiya ishlating: 'Matn \${qiymat}' yoki qiymat.toString()");
        }
        return _string;
      }
      if (e.op == '*') return _string;
      _err('undefined_operator', "`String` turida `${e.op}` operatori yo'q.",
          "The operator '${e.op}' isn't defined for the type 'String'.", e.opOffset, e.op.length,
          hint: const {'<', '>', '<=', '>='}.contains(e.op) ? "Matnlarni taqqoslash uchun a.compareTo(b) ishlating." : null);
      return null;
    }
    if (l.name == 'bool') {
      if (const {'&', '|', '^'}.contains(e.op)) return _bool;
      _err('undefined_operator', "`bool` turida `${e.op}` operatori yo'q.",
          "The operator '${e.op}' isn't defined for the type 'bool'.", e.opOffset, e.op.length);
      return null;
    }
    if (l.name == 'List' && e.op == '+') return l;
    final c = _classes[l.name];
    if (c != null) {
      final m = _findMember(l.name, e.op);
      if (m == null) {
        _err('undefined_operator', "`${l.name}` class'ida `${e.op}` operatori aniqlanmagan.",
            "The operator '${e.op}' isn't defined for the type '${l.name}'.", e.opOffset, e.op.length,
            hint: "Class ichida operator yozing: ${l.name} operator ${e.op}(${l.name} other) { ... }");
        return null;
      }
      return m.$2;
    }
    return null;
  }

  void _checkWritable(Expr target, _Scope scope) {
    if (target is Identifier) {
      final r = _resolveName(target.name, scope, target.offset, write: true);
      final v = r.v;
      if (v != null && (v.isFinal || v.isConst) && !(v.isLate) && v.kind == 'var' && !(v.isFinal && v.type == null && v.isLocal && !v.isConst && false)) {
        _err('assignment_to_final_local',
            v.isConst
                ? "`${target.name}` const — uning qiymatini o'zgartirib bo'lmaydi."
                : "`${target.name}` final — unga faqat bir marta qiymat beriladi.",
            v.isConst ? "Constant variables can't be assigned a value." : "The final variable '${target.name}' can only be set once.",
            target.offset, target.name.length,
            hint: "Qiymat o'zgarishi kerak bo'lsa, `var` yoki tur nomi bilan e'lon qiling: var ${target.name} = ...;");
      } else if (r.kind == 'function' || r.kind == 'class') {
        _err('assignment_to_function', "`${target.name}` funksiya yoki class nomi — unga qiymat berib bo'lmaydi.",
            "Functions can't be assigned a value.", target.offset, target.name.length);
      } else if (r.kind == 'field') {
        final k = _enclosingClass(scope);
        if (k != null) {
          final f = _findField(k, target.name);
          if (f != null && (f.decl.isFinal || f.decl.isConst)) {
            _err('assignment_to_final', "`${target.name}` maydoni final — uni o'zgartirib bo'lmaydi.",
                "'${target.name}' can't be used as a setter because it's final.", target.offset, target.name.length);
          }
        }
      }
    } else if (target is PropertyGet) {
      final t = _typeOfTarget(target.target, scope);
      if (t != null && _classes.containsKey(t.name)) {
        final f = _findField(_classes[t.name]!, target.name);
        if (f != null && (f.decl.isFinal || f.decl.isConst)) {
          _err('assignment_to_final', "`${target.name}` maydoni final — obyekt yaratilgandan keyin o'zgartirib bo'lmaydi.",
              "'${target.name}' can't be used as a setter because it's final.", target.nameOffset, target.name.length,
              hint: "Maydonni o'zgaruvchan qilish uchun `final` so'zini olib tashlang.");
        }
      }
    }
  }

  T? _typeOfTarget(Expr e, _Scope scope) {
    if (e is ThisExpr) {
      final k = _enclosingClass(scope);
      return k == null ? null : _t(k.name);
    }
    if (e is Identifier) return _typeOfName(e.name, scope);
    return null;
  }

  T? _assign(AssignExpr e, _Scope scope) {
    T? targetType;
    if (e.target is Identifier) {
      final id = e.target as Identifier;
      final r = _resolveName(id.name, scope, id.offset, write: true);
      targetType = r.type;
      if (e.op != '=') r.v?.used = true;
    } else if (e.target is PropertyGet) {
      final pg = e.target as PropertyGet;
      final tt = _expr(pg.target, scope);
      targetType = _memberType(tt, pg.name, pg, scope, isSetter: true);
    } else if (e.target is IndexExpr) {
      final ie = e.target as IndexExpr;
      final tt = _expr(ie.target, scope);
      _expr(ie.index, scope);
      if (tt != null && tt.name == 'List' && tt.args.isNotEmpty) targetType = tt.args.first;
      if (tt != null && tt.name == 'Map' && tt.args.length == 2) targetType = tt.args[1];
      if (tt != null && tt.name == 'String') {
        _err('unsupported_string_index_assign', "String o'zgarmas — uning harfini `[]=` bilan almashtirib bo'lmaydi.",
            "The operator '[]=' isn't defined for the type 'String'.", ie.offset, ie.end - ie.offset);
      }
    }
    _checkWritable(e.target, scope);
    final vt = _expr(e.value, scope, context: targetType);
    if (e.op == '=') {
      _checkAssign(vt, targetType, e.value, e.target is Identifier ? "`${(e.target as Identifier).name}`" : 'maydon');
      if (e.target is Identifier) {
        final name = (e.target as Identifier).name;
        // Promotion: non-null qiymat berilsa, keyin null emas deb hisoblaymiz.
        if (vt != null && !vt.nullable && vt.name != 'Null' && targetType != null && targetType.nullable) {
          scope.promoted[name] = _nonNull(targetType);
        } else {
          _demote(name, scope);
        }
      }
      return vt;
    }
    if (e.op == '??=') {
      if (e.target is Identifier && targetType != null) scope.promoted[(e.target as Identifier).name] = _nonNull(targetType);
      return targetType == null ? vt : _nonNull(targetType);
    }
    // Murakkab amal: +=, -= ...
    final op = e.op.substring(0, e.op.length - 1);
    final synthetic = BinaryExpr(op, e.target, e.value, e.offset, e.end, e.offset);
    final rt = _binaryTypes(op, targetType, vt, synthetic);
    if (rt != null && targetType != null) _checkAssign(rt, targetType, e, "`${_targetName(e.target)}`");
    return rt;
  }

  String _targetName(Expr t) => t is Identifier ? t.name : (t is PropertyGet ? t.name : 'element');

  void _demote(String name, _Scope scope) {
    _Scope? s = scope;
    while (s != null) {
      s.promoted.remove(name);
      if (s.vars.containsKey(name)) break;
      s = s.parent;
    }
  }

  T? _binaryTypes(String op, T? l, T? r, BinaryExpr e) {
    if (l == null || r == null || _isDynamic(l) || _isDynamic(r)) return null;
    if (l.nullable) {
      _nullableOperator(op, e.left);
      return null;
    }
    bool isNum(T t) => const {'int', 'double', 'num'}.contains(t.name);
    if (isNum(l) && isNum(r) && !r.nullable) {
      if (op == '/') return _double;
      if (op == '~/') return _int;
      if (l.name == 'int' && r.name == 'int') return _int;
      if (l.name == 'double' || r.name == 'double') return _double;
      return _num;
    }
    if (l.name == 'String' && op == '+') {
      if (r.name != 'String' || r.nullable) {
        _err('argument_type_not_assignable', "String'ga `${_show(r)}` turidagi qiymatni qo'shib bo'lmaydi.",
            "The argument type '${_show(r)}' can't be assigned to the parameter type 'String'.", e.right.offset,
            e.right.end - e.right.offset, hint: "Interpolatsiya ishlating: matn += '\$qiymat';");
      }
      return _string;
    }
    if (isNum(l) && !isNum(r)) {
      _err('argument_type_not_assignable', "Songa `${_show(r)}` turidagi qiymatni qo'shib bo'lmaydi.",
          "The argument type '${_show(r)}' can't be assigned to the parameter type 'num'.", e.right.offset,
          e.right.end - e.right.offset);
    }
    return null;
  }

  T? _property(PropertyGet e, _Scope scope) {
    if (e.target is Identifier) {
      final id = e.target as Identifier;
      // Statik: int.parse, Color.red, math.pi
      final prefix = _prefixes[id.name];
      if (prefix != null && _isPrefixName(id.name, scope)) {
        _resolveName(id.name, scope, id.offset);
        final m = _libraryNames[prefix]!;
        if (!m.containsKey(e.name)) {
          _err('undefined_prefixed_name', "`${id.name}.${e.name}` topilmadi.", "Undefined name '${id.name}.${e.name}'.",
              e.nameOffset, e.name.length);
          return null;
        }
        return _parseTypeString(m[e.name]!);
      }
      if (_isTypeName(id.name, scope)) {
        _resolveName(id.name, scope, id.offset);
        return _staticMember(id.name, e.name, e.nameOffset, isCall: false);
      }
    }
    final t = _expr(e.target, scope);
    return _memberType(t, e.name, e, scope, nullAware: e.nullAware);
  }

  bool _isTypeName(String name, _Scope scope) {
    if (_typeOfLocal(name, scope)) return false;
    if (_needsAsyncImport(name)) return false;
    return builtinTypeNames.contains(name) || _classes.containsKey(name);
  }

  bool _isPrefixName(String name, _Scope scope) => !_typeOfLocal(name, scope);

  bool _typeOfLocal(String name, _Scope scope) {
    _Scope? s = scope;
    while (s != null && s != _global) {
      if (s.vars.containsKey(name)) return true;
      s = s.parent;
    }
    return false;
  }

  T? _staticMember(String typeName, String name, int offset, {required bool isCall, Arguments? args, _Scope? scope}) {
    final c = _classes[typeName];
    if (c != null) {
      if (isCall) {
        final ctor = c.constructors.where((k) => k.name == name).firstOrNull;
        if (ctor != null) {
          if (args != null && scope != null) _checkCallArgs(ctor.params, args, scope, '${c.name}.$name', offset, cls: c);
          return _t(c.name);
        }
      }
      final m = _findStatic(c, name);
      if (m == null) {
        _err('undefined_static', "`$typeName` class'ida `$name` nomli statik a'zo yoki konstruktor yo'q.",
            "Member not found: '$typeName.$name'.", offset, name.length);
        return null;
      }
      if (isCall && m.$3 != null && args != null && scope != null) _checkCallArgs(m.$3!.params, args, scope, '$typeName.$name', offset);
      return m.$2;
    }
    final m = _staticMembers['$typeName.$name'];
    if (m == null) {
      _err('undefined_static', "`$typeName.$name` mavjud emas.", "Member not found: '$typeName.$name'.", offset, name.length,
          hint: typeName == 'int' && name == 'Parse' ? "Kichik harf bilan: int.parse" : null);
      return null;
    }
    if (isCall && args != null) {
      final count = args.positional.length;
      if (count < m.min || count > m.max) {
        _err('wrong_argument_count', "`$typeName.$name` ${m.min == m.max ? '${m.min} ta' : '${m.min}–${m.max} ta'} argument qabul qiladi, lekin $count ta berildi.",
            '${m.min} positional argument(s) expected, but $count found.', offset, name.length);
      }
    }
    return _parseTypeString(m.ret);
  }

  Map<String, _Member>? _builtinMembers(T t) => switch (t.name) {
    'String' => _stringMembers,
    'int' => {..._numMembers, ..._intMembers},
    'double' || 'num' => _numMembers,
    'List' => {..._iterableMembers, ..._listMembers},
    'Set' => {..._iterableMembers, ..._setMembers},
    'Iterable' => _iterableMembers,
    'Map' => _mapMembers,
    'StringBuffer' => _stringBufferMembers,
    'DateTime' => _dateTimeMembers,
    'bool' => const {},
    'Random' => const {'nextInt': _Member('int', 1, 1), 'nextDouble': _Member('double'), 'nextBool': _Member('bool')},
    'Stdin' => const {'readLineSync': _Member('String?', 0, 0)},
    'Future' => _futureMembers,
    'Stream' => _streamMembers,
    'StreamController' => _streamControllerMembers,
    'StreamSink' => const {'add': _Member('void', 1, 1), 'addError': _Member('void', 1, 2), 'close': _Member('Future<dynamic>')},
    'StreamSubscription' => const {
      'cancel': _Member('Future<void>'), 'pause': _Member('void', 0, 1), 'resume': _Member('void'), 'isPaused': _Member.getter('bool'),
      'onData': _Member('void', 1, 1), 'onError': _Member('void', 1, 1), 'onDone': _Member('void', 1, 1),
    },
    'Completer' => const {
      'future': _Member.getter('Future<E>'), 'complete': _Member('void', 0, 1), 'completeError': _Member('void', 1, 2),
      'isCompleted': _Member.getter('bool'),
    },
    'Timer' => const {'cancel': _Member('void'), 'isActive': _Member.getter('bool'), 'tick': _Member.getter('int')},
    'Stdout' => const {'write': _Member('void', 1, 1), 'writeln': _Member('void', 0, 1), 'writeAll': _Member('void', 1, 2)},
    _ => null,
  };

  T? _resolveRet(String ret, T receiver) {
    var r = ret;
    final elem = receiver.args.isNotEmpty ? receiver.args.first.toString() : 'dynamic';
    final k = receiver.args.isNotEmpty ? receiver.args.first.toString() : 'dynamic';
    final v = receiver.args.length > 1 ? receiver.args[1].toString() : 'dynamic';
    if (receiver.name == 'Map') {
      r = r.replaceAll('K', k).replaceAll(RegExp(r'\bV\b'), v);
    } else {
      r = r.replaceAll(RegExp(r'\bE\b'), elem);
    }
    if (r == 'R') return _nonNull(receiver);
    return _parseTypeString(r);
  }

  T? _memberType(T? t, String name, Expr node, _Scope scope, {bool isSetter = false, Arguments? args, bool nullAware = false}) {
    final nameOffset = node is PropertyGet ? node.nameOffset : (node is MethodCall ? node.nameOffset : node.offset);
    final isCall = node is MethodCall;
    if (t == null || _isDynamic(t) || t.name == 'Type' || t.name == 'Never' || t.name == 'Function' && name == 'call') return null;
    if (t.nullable && !nullAware && !_objectMembers.containsKey(name)) {
      _err('unchecked_use_of_nullable_value',
          isCall
              ? "Qiymat null bo'lishi mumkin, shuning uchun `$name()` metodini to'g'ridan-to'g'ri chaqirib bo'lmaydi."
              : "Qiymat null bo'lishi mumkin, shuning uchun `.$name` ga to'g'ridan-to'g'ri murojaat qilib bo'lmaydi.",
          isCall
              ? "The method '$name' can't be unconditionally invoked because the receiver can be 'null'."
              : "The property '$name' can't be unconditionally accessed because the receiver can be 'null'.",
          nameOffset, name.length,
          hint: "Variantlar: `?.$name` (null bo'lsa null qaytaradi), `!.$name` (null emasligiga ishonchingiz komil bo'lsa) yoki avval `if (x != null)` bilan tekshiring.");
      return null;
    }
    final base = _nonNull(t);
    if (_objectMembers.containsKey(name)) {
      final r = _parseTypeString(_objectMembers[name]!.ret);
      return nullAware ? _nullable(r) : r;
    }
    T? result;
    final builtins = _builtinMembers(base);
    if (builtins != null) {
      final m = builtins[name];
      if (m != null) {
        if (isCall && m.isGetter) {
          _err('invocation_of_non_function', "`$name` — bu metod emas, xususiyat (getter). Qavslarsiz yozing: .$name",
              "'$name' isn't a function.", nameOffset, name.length);
        } else if (!isCall && !m.isGetter && !isSetter) {
          // Tear-off: list.add kabi — ruxsat.
          return _t('Function');
        }
        if (isCall && args != null) {
          final count = args.positional.length;
          if (count < m.min || count > m.max) {
            _err('wrong_argument_count',
                "`$name()` ${m.min == m.max ? '${m.min} ta' : '${m.min}–${m.max} ta'} argument qabul qiladi, lekin $count ta berildi.",
                '${m.min} positional argument(s) expected, but $count found.', nameOffset, name.length);
          }
          if (base.name == 'List' && name == 'add' && count == 1 && base.args.isNotEmpty) {
            final at = _expr(args.positional.first, scope, context: base.args.first);
            if (!_assignable(at, base.args.first, expr: args.positional.first)) {
              _err('argument_type_not_assignable',
                  "`List<${_show(base.args.first)}>` ga `${_show(at)}` turidagi qiymatni qo'shib bo'lmaydi.",
                  "The argument type '${_show(at)}' can't be assigned to the parameter type '${_show(base.args.first)}'.",
                  args.positional.first.offset, args.positional.first.end - args.positional.first.offset);
            }
            return _void;
          }
        }
        if (isSetter && !(base.name == 'List' && name == 'length') && !(base.name == 'StreamController' && name.startsWith('on'))) {
          _err('assignment_to_getter', "`$name` faqat o'qiladi — unga qiymat berib bo'lmaydi.",
              "There isn't a setter named '$name' in class '${base.name}'.", nameOffset, name.length);
        }
        result = _resolveRet(m.ret, base);
      } else if (!_extensionMembers.containsKey(name)) {
        final hint = _memberSuggestion(name, builtins.keys);
        _err(isCall ? 'undefined_method' : 'undefined_getter',
            isCall ? "`${base.name}` turida `$name()` nomli metod yo'q." : "`${base.name}` turida `$name` nomli xususiyat yo'q.",
            isCall
                ? "The method '$name' isn't defined for the type '${base.name}'."
                : "The getter '$name' isn't defined for the type '${base.name}'.",
            nameOffset, name.length, hint: hint);
        return null;
      }
    } else if (_classes.containsKey(base.name)) {
      final m = _findMember(base.name, name);
      if (m == null) {
        if (_extensionMembers.containsKey(name)) return null;
        final all = _allMemberNames(base.name);
        _err(isCall ? 'undefined_method' : 'undefined_getter',
            isCall
                ? "`${base.name}` class'ida `$name()` nomli metod yo'q."
                : "`${base.name}` class'ida `$name` nomli maydon yoki getter yo'q.",
            isCall
                ? "The method '$name' isn't defined for the type '${base.name}'."
                : "The getter '$name' isn't defined for the type '${base.name}'.",
            nameOffset, name.length, hint: _memberSuggestion(name, all));
        return null;
      }
      if (isCall && m.$1 == 'method' && m.$3 != null && args != null) {
        _checkCallArgs(m.$3!.params, args, scope, name, nameOffset);
      }
      if (m.$1 == 'method' && !isCall) return _t('Function');
      result = m.$2;
      if (isCall && (m.$1 == 'field' || m.$1 == 'getter')) result = null;
    } else {
      return null;
    }
    if (result != null && nullAware) return _nullable(result);
    return result;
  }

  Set<String> _allMemberNames(String className, [Set<String>? seen]) {
    seen ??= {};
    final out = <String>{};
    if (!seen.add(className)) return out;
    final c = _classes[className];
    if (c == null) return out;
    for (final m in c.methods) {
      out.add(m.name);
    }
    for (final f in c.fields) {
      for (final v in f.decl.vars) {
        out.add(v.name);
      }
    }
    for (final p in [if (c.superclass != null) c.superclass!, ...c.mixins, ...c.interfaces]) {
      out.addAll(_allMemberNames(p.name, seen));
    }
    return out;
  }

  String? _memberSuggestion(String name, Iterable<String> candidates) {
    const common = {
      'lenght': 'length', 'lengh': 'length', 'size': 'length', 'count': 'length', 'len': 'length',
      'toUppercase': 'toUpperCase', 'toUpper': 'toUpperCase', 'upper': 'toUpperCase', 'uppercase': 'toUpperCase',
      'toLowercase': 'toLowerCase', 'toLower': 'toLowerCase', 'push': 'add', 'append': 'add',
      'includes': 'contains', 'has': 'contains', 'parseInt': 'parse', 'toStr': 'toString',
    };
    final c = common[name];
    if (c != null && candidates.contains(c)) return "`$c` demoqchimisiz?";
    for (final cand in candidates) {
      if (cand.toLowerCase() == name.toLowerCase()) return "Dart katta-kichik harfni farqlaydi. `$cand` demoqchimisiz?";
    }
    for (final cand in candidates) {
      if (_levenshtein(cand, name) <= 2) return "`$cand` demoqchimisiz?";
    }
    return null;
  }

  void _args(Arguments a, _Scope scope) {
    for (final p in a.positional) {
      _expr(p, scope);
    }
    for (final n in a.named.values) {
      _expr(n, scope);
    }
  }

  void _checkCallArgs(List<Param> params, Arguments a, _Scope scope, String name, int offset, {ClassDecl? cls}) {
    final positional = params.where((p) => !p.isNamed).toList();
    final required = positional.where((p) => !p.isOptionalPositional).length;
    final count = a.positional.length;
    if (count < required) {
      _err('not_enough_positional_arguments',
          "`$name` uchun $required ta argument kerak, lekin $count ta berildi.",
          '$required positional argument(s) expected, but $count found.', offset, name.length,
          hint: "Chaqiruv: $name(${positional.map((p) => p.name).join(', ')})");
    } else if (count > positional.length) {
      _err('extra_positional_arguments',
          "`$name` ko'pi bilan ${positional.length} ta argument qabul qiladi, lekin $count ta berildi.",
          'Too many positional arguments: ${positional.length} expected, but $count found.', a.positional[positional.length].offset, 1,
          hint: params.any((p) => p.isNamed) ? "Bu funksiyada nomli parametrlar bor: ${params.where((p) => p.isNamed).map((p) => '${p.name}: ...').join(', ')}" : null);
    }
    for (var i = 0; i < count && i < positional.length; i++) {
      final p = positional[i];
      final pt = p.isFieldFormal && cls != null ? _fieldType(cls, p.name) : p.type;
      final at = _expr(a.positional[i], scope, context: pt);
      if (pt != null && !_assignable(at, pt, expr: a.positional[i])) {
        _err('argument_type_not_assignable',
            "`${_show(at)}` turidagi argumentni `${_show(pt)}` turidagi `${p.name}` parametriga berib bo'lmaydi.",
            "The argument type '${_show(at)}' can't be assigned to the parameter type '${_show(pt)}'.",
            a.positional[i].offset, a.positional[i].end - a.positional[i].offset,
            hint: at != null && at.nullable && !pt.nullable ? "Argument null bo'lishi mumkin: `?? standart` yoki `!` ishlating." : null);
      }
    }
    for (var i = positional.length; i < count; i++) {
      _expr(a.positional[i], scope);
    }
    for (final entry in a.named.entries) {
      final p = params.where((p) => p.isNamed && p.name == entry.key).firstOrNull;
      final at = _expr(entry.value, scope, context: p?.type);
      if (p == null) {
        _err('undefined_named_parameter', "`$name` da `${entry.key}` nomli parametr yo'q.",
            "The named parameter '${entry.key}' isn't defined.", entry.value.offset - entry.key.length - 2, entry.key.length,
            hint: params.where((p) => p.isNamed).isEmpty
                ? "Bu funksiya nomli parametr qabul qilmaydi — qiymatni nomisiz bering."
                : "Mavjud nomli parametrlar: ${params.where((p) => p.isNamed).map((p) => p.name).join(', ')}");
        continue;
      }
      final pt = p.isFieldFormal && cls != null ? _fieldType(cls, p.name) : p.type;
      if (pt != null && !_assignable(at, pt, expr: entry.value)) {
        _err('argument_type_not_assignable',
            "`${_show(at)}` turidagi qiymatni `${_show(pt)}` turidagi `${p.name}` parametriga berib bo'lmaydi.",
            "The argument type '${_show(at)}' can't be assigned to the parameter type '${_show(pt)}'.",
            entry.value.offset, entry.value.end - entry.value.offset);
      }
    }
    for (final p in params.where((p) => p.isNamed && p.isRequired)) {
      if (!a.named.containsKey(p.name)) {
        _err('missing_required_argument', "`${p.name}` nomli argument majburiy (required), lekin berilmadi.",
            "The named parameter '${p.name}' is required, but there's no corresponding argument.", offset, name.length,
            hint: "Chaqiruvga qo'shing: ${p.name}: qiymat");
      }
    }
  }

  T? _call(CallExpr e, _Scope scope) {
    final callee = e.callee;
    if (callee is Identifier) {
      final name = callee.name;
      if (name == 'print') {
        if (_typeOfLocal(name, scope)) {
          // mahalliy print nomi — oddiy chaqiruv
        } else {
          if (e.args.positional.length != 1 || e.args.named.isNotEmpty) {
            _err('print_argument_count',
                e.args.positional.isEmpty
                    ? "print() ichiga chiqariladigan qiymatni yozing."
                    : "print() faqat bitta qiymat qabul qiladi, lekin ${e.args.positional.length} ta berildi.",
                '1 positional argument expected, but ${e.args.positional.length} found.', callee.offset, 5,
                hint: e.args.positional.length > 1
                    ? "Bir nechta qiymatni birlashtiring: print('\$a \$b'); yoki print(a + b) (agar ikkalasi ham String bo'lsa)."
                    : "Masalan: print('Salom');");
          }
          final t = e.args.positional.isEmpty ? null : _expr(e.args.positional.first, scope);
          for (final a in e.args.positional.skip(1)) {
            _expr(a, scope);
          }
          if (t?.name == 'void') {
            _err('use_of_void_result', "Bu ifoda `void` — u hech qanday qiymat qaytarmaydi, uni chiqarib bo'lmaydi.",
                "This expression has a type of 'void' so its value can't be used.", e.args.positional.first.offset,
                e.args.positional.first.end - e.args.positional.first.offset,
                hint: "Funksiya qiymat qaytarishi uchun `void` o'rniga tur yozing va `return` ishlating.");
          }
          return _void;
        }
      }
      final r = _resolveName(name, scope, callee.offset, isCall: true);
      if (!r.found) {
        _args(e.args, scope);
        return null;
      }
      if (r.kind == 'class' && _classes.containsKey(name)) {
        final c = _classes[name]!;
        if (c.kind == ClassKind.enumDecl) {
          _err('instantiate_enum', "Enum'dan obyekt yaratib bo'lmaydi.", "Enums can't be instantiated.", callee.offset, name.length,
              hint: "Qiymatlaridan birini tanlang: $name.${c.enumValues.isEmpty ? 'qiymat' : c.enumValues.first.name}");
        }
        final ctor = c.constructors.where((k) => k.name == null).firstOrNull;
        if (c.isAbstract && (ctor == null || !ctor.isFactory)) {
          _err('instantiate_abstract_class', "`$name` abstrakt class — undan to'g'ridan-to'g'ri obyekt yaratib bo'lmaydi.",
              "Abstract classes can't be instantiated.", callee.offset, name.length,
              hint: "Undan meros oluvchi class yarating: class Mening$name extends $name { ... }");
        }
        if (ctor != null) {
          _checkCallArgs(ctor.params, e.args, scope, name, callee.offset, cls: c);
        } else if (c.constructors.isEmpty) {
          if (e.args.positional.isNotEmpty || e.args.named.isNotEmpty) {
            _err('extra_positional_arguments', "`$name` class'ida konstruktor yo'q, shuning uchun argument berib bo'lmaydi.",
                'Too many positional arguments: 0 expected, but ${e.args.positional.length} found.', callee.offset, name.length,
                hint: "Konstruktor yozing: $name(this.maydon1, this.maydon2);");
          }
          _args(e.args, scope);
        } else {
          _err('undefined_constructor', "`$name` class'ida nomsiz konstruktor yo'q.",
              "The class '$name' doesn't have an unnamed constructor.", callee.offset, name.length);
          _args(e.args, scope);
        }
        return _t(name);
      }
      if (r.kind == 'type') {
        _args(e.args, scope);
        if (name == 'List') {
          _err('default_list_constructor', "`List()` konstruktori ishlatilmaydi. `[]` yoki `List.filled()` yozing.",
              "The default 'List' constructor isn't available when null safety is enabled.", callee.offset, 4);
        }
        if (name == 'Map' || name == 'Set') return _t(name, args: e.typeArgs);
        if (name == 'StringBuffer') return _t('StringBuffer');
        if (name == 'DateTime') return _t('DateTime');
        if (const {'Completer', 'StreamController', 'Future'}.contains(name)) return _t(name, args: e.typeArgs);
        if (name == 'Timer') return _t('Timer');
        return null;
      }
      if (r.fn != null) {
        _checkCallArgs(r.fn!.params, e.args, scope, name, callee.offset);
        if (r.fn!.typeParams.isNotEmpty) return null;
        return r.fn!.returnType;
      }
      if (r.kind == 'library') {
        _args(e.args, scope);
        if (name == 'max' || name == 'min') {
          final ts = [for (final a in e.args.positional) _literalOrKnown(a) ?? _typeOfExprQuiet(a, scope)];
          if (ts.length == 2 && ts[0] != null && ts[1] != null && ts[0]!.name == ts[1]!.name) return ts[0];
        }
        if (name == 'pow') return _num;
        return r.type;
      }
      if (r.type != null && !_isDynamic(r.type) && r.type!.name != 'Function' && r.kind != 'method' && r.kind != 'builtin') {
        _err('invocation_of_non_function', "`$name` funksiya emas (turi `${_show(r.type)}`), uni chaqirib bo'lmaydi.",
            "'$name' isn't a function.", callee.offset, name.length);
      }
      _args(e.args, scope);
      return null;
    }
    _expr(callee, scope);
    _args(e.args, scope);
    return null;
  }

  T? _typeOfExprQuiet(Expr e, _Scope scope) => e is Identifier ? _typeOfName(e.name, scope) : null;

  T? _methodCall(MethodCall e, _Scope scope) {
    if (e.target is Identifier) {
      final id = e.target as Identifier;
      final prefix = _prefixes[id.name];
      if (prefix != null && _isPrefixName(id.name, scope)) {
        _resolveName(id.name, scope, id.offset);
        _args(e.args, scope);
        final m = _libraryNames[prefix]!;
        if (!m.containsKey(e.name)) {
          _err('undefined_prefixed_name', "`${id.name}.${e.name}` topilmadi.", "Undefined name '${id.name}.${e.name}'.",
              e.nameOffset, e.name.length);
          return null;
        }
        if (e.name == 'pow') return _num;
        return _parseTypeString(m[e.name]!);
      }
      if (_isTypeName(id.name, scope)) {
        _resolveName(id.name, scope, id.offset);
        final r = _staticMember(id.name, e.name, e.nameOffset, isCall: true, args: e.args, scope: scope);
        if (_classes[id.name]?.constructors.any((k) => k.name == e.name) != true) _args(e.args, scope);
        if (e.typeArgs.isNotEmpty && r != null && (r.name == 'List' || r.name == 'Set')) return _t(r.name, args: e.typeArgs);
        if (id.name == 'List' && e.name == 'filled' && e.args.positional.length == 2) {
          final et = _literalOrKnown(e.args.positional[1]);
          if (et != null) return _t('List', args: [et]);
        }
        return r;
      }
    }
    if (e.target is SuperExpr) {
      final k = _enclosingClass(scope);
      _args(e.args, scope);
      if (k?.superclass != null && _classes.containsKey(k!.superclass!.name) && e.name != 'toString') {
        final m = _findMember(k.superclass!.name, e.name);
        if (m == null) {
          _err('undefined_super_member', "Ota class'da `${e.name}` metodi yo'q.",
              "The method '${e.name}' isn't defined in a superclass of '${k.name}'.", e.nameOffset, e.name.length);
        }
        return m?.$2;
      }
      return null;
    }
    final t = _expr(e.target, scope);
    final r = _memberType(t, e.name, e, scope, args: e.args, nullAware: e.nullAware);
    // _memberType argumentlarni faqat ma'lum hollarda tekshiradi.
    if (!(t != null && _classes.containsKey(_nonNull(t).name) && _findMember(_nonNull(t).name, e.name)?.$1 == 'method') &&
        !(t != null && _nonNull(t).name == 'List' && e.name == 'add' && t.args.isNotEmpty)) {
      _argsWithLambdaContext(e, t, scope);
    }
    if (t != null && const {'map', 'where', 'forEach', 'any', 'every', 'firstWhere', 'reduce', 'fold', 'sort', 'removeWhere'}.contains(e.name)) {
      if (e.name == 'map' && e.args.positional.length == 1) {
        final lt = _lambdaReturnType(e.args.positional.first, t, scope);
        if (lt != null) return _t('Iterable', args: [lt]);
      }
    }
    return r;
  }

  void _argsWithLambdaContext(MethodCall e, T? receiver, _Scope scope) {
    final elem = receiver != null && receiver.args.isNotEmpty && receiver.name != 'Map' ? receiver.args.first : null;
    for (final a in e.args.positional) {
      if (a is FunctionExpr && elem != null) {
        _lambdaWithParamTypes(a, [
          if (e.name == 'fold' || e.name == 'reduce' || e.name == 'sort') ...[
            if (e.name == 'reduce' || e.name == 'sort') elem else null,
            elem,
          ] else
            elem,
        ], scope);
      } else if (a is FunctionExpr && receiver != null && receiver.name == 'Map' && receiver.args.length == 2) {
        _lambdaWithParamTypes(a, receiver.args, scope);
      } else {
        _expr(a, scope);
      }
    }
    for (final n in e.args.named.values) {
      _expr(n, scope);
    }
  }

  T? _lambdaWithParamTypes(FunctionExpr f, List<T?> types, _Scope scope) {
    final fs = _Scope(scope,
        klass: scope.klass, isStatic: scope.isStatic, isFunction: true, function: '', asyncKind: _kindOf(f.isAsync, f.isGenerator));
    for (var i = 0; i < f.params.length; i++) {
      final p = f.params[i];
      fs.vars[p.name] = _Var(p.type ?? (i < types.length ? types[i] : null), isLocal: true, kind: 'param')..used = true;
    }
    if (f.body.expr != null) return _expr(f.body.expr!, fs);
    _block(f.body.block!.statements, fs);
    _reportUnused(fs);
    return null;
  }

  T? _lambdaReturnType(Expr arg, T receiver, _Scope scope) {
    if (arg is! FunctionExpr || arg.body.expr == null || receiver.args.isEmpty) return null;
    // Diagnostikalarni takrorlamaslik uchun vaqtincha saqlab qo'yamiz.
    final saved = diagnostics.length;
    final r = _lambdaWithParamTypes(arg, [receiver.args.first], scope);
    diagnostics.removeRange(saved, diagnostics.length);
    return r;
  }

  void _pattern(Pattern p, _Scope scope, T? subject) {
    switch (p) {
      case ConstPattern():
        final t = _expr(p.expr, scope);
        if (subject != null && t != null && !_isDynamic(subject) && t.name != 'Null' &&
            !_assignable(t, _nullable(subject)) && !_assignable(subject, t)) {
          _err('constant_pattern_never_matches', "Bu case hech qachon mos kelmaydi: `${_show(subject)}` qiymat `${_show(t)}` ga teng bo'lolmaydi.",
              "The matched value type '${_show(subject)}' can never be equal to this constant of type '${_show(t)}'.",
              p.expr.offset, p.expr.end - p.expr.offset, severity: Severity.warning);
        }
      case WildcardPattern():
        break;
      case RelationalPattern():
        _expr(p.expr, scope);
      case OrPattern():
        _pattern(p.left, scope, subject);
        _pattern(p.right, scope, subject);
      case AndPattern():
        _pattern(p.left, scope, subject);
        _pattern(p.right, scope, subject);
      case BindingPattern():
        _checkType(p.type);
        if (p.name != null) scope.vars[p.name!] = _Var(p.type ?? subject, isLocal: true, kind: 'param')..used = true;
    }
  }
}
