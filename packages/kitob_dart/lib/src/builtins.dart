part of 'interpreter.dart';

extension _Builtins on Interpreter {
  Map<String, Object?> _createBuiltins() => {
    'print': NativeFunction('print', (p, n) {
      if (p.length != 1) {
        throw ExecutionAbort('print_args', "print() aynan bitta qiymat qabul qiladi.",
            '1 positional argument expected, but ${p.length} found.', _lastUserOffset,
            hint: "Bir nechta qiymatni chiqarish uchun interpolatsiya ishlating: print('\$a \$b');");
      }
      final text = stringify(p.single, _lastUserOffset);
      _write('$text\n');
      _record(TraceKind.output, _lastUserOffset, 5, "Konsolga chiqdi: $text");
      return null;
    }, signature: '(Object?) => void'),
    'identical': NativeFunction('identical', (p, n) => identical(p[0], p[1]) || (p[0] is int && p[0] == p[1]),
        signature: '(Object?, Object?) => bool'),
    for (final t in const [
      'int', 'double', 'num', 'String', 'bool', 'List', 'Map', 'Set', 'Object', 'Iterable', 'Function',
      'Null', 'dynamic', 'StringBuffer', 'DateTime', 'Comparable', 'Record', 'Enum', 'Type', 'Future', 'Stream',
    ])
      t: BuiltinType(t),
  };

  Map<String, Object?> _mathLibrary() => {
    'pi': const KDouble(math.pi),
    'e': const KDouble(math.e),
    'sqrt2': const KDouble(math.sqrt2),
    'max': NativeFunction('max', (p, n) => _numOf(p[0]) >= _numOf(p[1]) ? p[0] : p[1], signature: '(T, T) => T'),
    'min': NativeFunction('min', (p, n) => _numOf(p[0]) <= _numOf(p[1]) ? p[0] : p[1], signature: '(T, T) => T'),
    'sqrt': NativeFunction('sqrt', (p, n) => KDouble(math.sqrt(_numOf(p[0]))), signature: '(num) => double'),
    'pow': NativeFunction('pow', (p, n) {
      final a = p[0], b = p[1];
      if (a is int && b is int && b >= 0) {
        var r = 1;
        for (var i = 0; i < b; i++) {
          r *= a;
        }
        return r;
      }
      return KDouble(math.pow(_numOf(a), _numOf(b)).toDouble());
    }, signature: '(num, num) => num'),
    'sin': NativeFunction('sin', (p, n) => KDouble(math.sin(_numOf(p[0]))), signature: '(num) => double'),
    'cos': NativeFunction('cos', (p, n) => KDouble(math.cos(_numOf(p[0]))), signature: '(num) => double'),
    'tan': NativeFunction('tan', (p, n) => KDouble(math.tan(_numOf(p[0]))), signature: '(num) => double'),
    'asin': NativeFunction('asin', (p, n) => KDouble(math.asin(_numOf(p[0]))), signature: '(num) => double'),
    'acos': NativeFunction('acos', (p, n) => KDouble(math.acos(_numOf(p[0]))), signature: '(num) => double'),
    'atan': NativeFunction('atan', (p, n) => KDouble(math.atan(_numOf(p[0]))), signature: '(num) => double'),
    'atan2': NativeFunction('atan2', (p, n) => KDouble(math.atan2(_numOf(p[0]), _numOf(p[1]))), signature: '(num, num) => double'),
    'log': NativeFunction('log', (p, n) => KDouble(math.log(_numOf(p[0]))), signature: '(num) => double'),
    'exp': NativeFunction('exp', (p, n) => KDouble(math.exp(_numOf(p[0]))), signature: '(num) => double'),
    'Random': NativeFunction('Random', (p, n) {
      final seed = p.isEmpty ? options.randomSeed : p[0] as int?;
      return KRandom(seed == null ? _random : math.Random(seed));
    }, signature: '([int?]) => Random'),
  };

  Map<String, Object?> _ioLibrary() => {
    'stdin': const KNative('stdin'),
    'stdout': const KNative('stdout'),
    'exit': NativeFunction('exit', (p, n) => throw _ExitSignal(p.isEmpty ? 0 : p[0] as int), signature: '(int) => Never'),
  };

  Map<String, Object?> _convertLibrary() => {
    'jsonEncode': NativeFunction('jsonEncode', (p, n) => convert.jsonEncode(_toNative(p[0])), signature: '(Object?) => String'),
    'jsonDecode': NativeFunction('jsonDecode', (p, n) => _fromNative(convert.jsonDecode(p[0] as String)),
        signature: '(String) => dynamic'),
  };

  Object? _toNative(Object? v) {
    if (v is KDouble) return v.value;
    if (v is List) return [for (final e in v) _toNative(e)];
    if (v is Map) return {for (final e in v.entries) stringify(e.key): _toNative(e.value)};
    if (v is KInstance) {
      final m = v.klass.findMethod('toJson');
      if (m != null) {
        return _toNative(_invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(v, v.klass), const [], const {}, _lastUserOffset));
      }
      _throwDart('UnsupportedError', ["Converting object to an encodable object failed: Instance of '${v.klass.name}'"], _lastUserOffset);
    }
    return v;
  }

  Object? _fromNative(Object? v) {
    if (v is List) return <Object?>[for (final e in v) _fromNative(e)];
    if (v is Map) return <Object?, Object?>{for (final e in v.entries) e.key: _fromNative(e.value)};
    if (v is double && v != v.truncateToDouble()) return KDouble(v);
    if (v is double) return v.isFinite && v.abs() < 9007199254740992 ? v.toInt() : KDouble(v);
    return v;
  }

  num _numOf(Object? v) {
    if (v is int) return v;
    if (v is KDouble) return v.value;
    _typeError("type '${typeName(v)}' is not a subtype of type 'num'", _lastUserOffset);
  }

  int _intArg(Object? v, int offset, [String what = 'argument']) {
    if (v is int) return v;
    _typeError("type '${typeName(v)}' is not a subtype of type 'int' of '$what'", offset);
  }

  String _strArg(Object? v, int offset, [String what = 'argument']) {
    if (v is String) return v;
    _typeError("type '${typeName(v)}' is not a subtype of type 'String' of '$what'", offset);
  }

  bool _asBool(Object? v, int offset) {
    if (v is bool) return v;
    _typeError("type '${typeName(v)}' is not a subtype of type 'bool'", offset);
  }

  Object? Function(Object?) _fn1(Object? f, int offset) => (a) => _callValue(f, [a], const {}, offset);
  Object? Function(Object?, Object?) _fn2(Object? f, int offset) => (a, b) => _callValue(f, [a, b], const {}, offset);

  int _compare(Object? a, Object? b, int offset) {
    if ((a is int || a is KDouble) && (b is int || b is KDouble)) return _numOf(a).compareTo(_numOf(b));
    if (a is String && b is String) return a.compareTo(b);
    if (a is bool && b is bool) return a == b ? 0 : (a ? 1 : -1);
    if (a is KInstance) {
      final m = a.klass.findMethod('compareTo');
      if (m != null) {
        return _intArg(_invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(a, a.klass), [b], const {}, offset), offset);
      }
    }
    _typeError("type '${typeName(a)}' is not a subtype of type 'Comparable<dynamic>'", offset);
  }

  List<Object?> _newList(Iterable<Object?> items, [String? elementType, bool growable = true]) {
    final l = List<Object?>.of(items, growable: growable);
    if (elementType != null) _typeArgs[l] = elementType;
    return l;
  }

  Object? _checkElement(Object coll, Object? v, int offset) {
    final t = _typeArgs[coll];
    if (t == null) return v;
    final nullable = t.endsWith('?');
    final name = nullable ? t.substring(0, t.length - 1) : t;
    if (name.contains('<') || name.contains(',')) return v;
    final ta = TypeAnnotation(name, nullable: nullable);
    if (name == 'double' && v is int) return KDouble(v.toDouble());
    if (!isType(v, ta)) {
      _typeError("type '${typeName(v)}' is not a subtype of type '$t' of 'value'", offset);
    }
    return v;
  }

  MapEntryLike _entry(Object? k, Object? v, int offset) =>
      MapEntryLike(_instantiate(classes['MapEntry']!, '', [k, v], const {}, offset) as KInstance);

  bool _hasBuiltinMethod(Object? t, String name) {
    const string = {
      'toUpperCase', 'toLowerCase', 'trim', 'trimLeft', 'trimRight', 'contains', 'startsWith', 'endsWith',
      'indexOf', 'lastIndexOf', 'substring', 'split', 'replaceAll', 'replaceFirst', 'padLeft', 'padRight',
      'codeUnitAt', 'compareTo', 'toString',
    };
    const number = {
      'abs', 'toDouble', 'toInt', 'round', 'floor', 'ceil', 'truncate', 'toString', 'toStringAsFixed',
      'toStringAsPrecision', 'toRadixString', 'compareTo', 'remainder', 'clamp', 'gcd', 'roundToDouble',
      'floorToDouble', 'ceilToDouble',
    };
    const iterable = {
      'map', 'where', 'whereType', 'expand', 'forEach', 'any', 'every', 'reduce', 'fold', 'contains', 'join',
      'toList', 'toSet', 'take', 'skip', 'takeWhile', 'skipWhile', 'firstWhere', 'lastWhere', 'singleWhere',
      'elementAt', 'followedBy', 'cast', 'toString',
    };
    const list = {
      'add', 'addAll', 'insert', 'insertAll', 'remove', 'removeAt', 'removeLast', 'removeWhere', 'retainWhere',
      'removeRange', 'clear', 'indexOf', 'lastIndexOf', 'indexWhere', 'lastIndexWhere', 'sublist', 'getRange',
      'sort', 'shuffle', 'fillRange', 'asMap',
    };
    const map = {
      'containsKey', 'containsValue', 'remove', 'clear', 'putIfAbsent', 'update', 'updateAll', 'forEach', 'map',
      'addAll', 'addEntries', 'removeWhere', 'toString',
    };
    if (t is String) return string.contains(name);
    if (t is int || t is KDouble) return number.contains(name);
    if (t is List) return list.contains(name) || iterable.contains(name);
    if (t is Map) return map.contains(name);
    if (t is Iterable) return iterable.contains(name) || const {'add', 'addAll', 'remove', 'union', 'intersection', 'difference'}.contains(name);
    return false;
  }

  // ───────────────────────── Xususiyatlar (getter) ─────────────────────────

  Object? _getProperty(Object? t, String name, int offset) {
    if (name == 'runtimeType') return BuiltinType(typeName(t));
    if (name == 'hashCode') return t.hashCode;
    if (t is KInstance) {
      if (t.fields.containsKey(name)) return t.fields[name];
      final g = t.klass.findGetter(name);
      if (g != null) return _callGetter(g.$1, g.$2, t, offset);
      final m = t.klass.findMethod(name);
      if (m != null) return _makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(t, t.klass);
      if (t.klass.isEnum) {
        if (name == 'name') return t.enumName;
        if (name == 'index') return t.enumIndex;
      }
      final ext = _findExtensionValue(t, name, offset);
      if (!identical(ext, _notFound)) return ext;
      throw ExecutionAbort('undefined_getter',
          "`${t.klass.displayName}` class'ida `$name` nomli maydon yoki getter yo'q.",
          "The getter '$name' isn't defined for the class '${t.klass.displayName}'.", offset);
    }
    if (t is KClass) {
      final r = _lookupStatic(t, name, offset);
      if (!identical(r, _notFound)) return r;
      throw ExecutionAbort('undefined_static',
          "`${t.name}` class'ida `$name` nomli statik a'zo yo'q.",
          "Member not found: '${t.name}.$name'.", offset);
    }
    if (t is KNamespace) {
      if (t.members.containsKey(name)) return t.members[name];
      throw ExecutionAbort('undefined_prefixed', "`${t.name}.$name` topilmadi.", "Undefined name '${t.name}.$name'.", offset);
    }
    if (t is BuiltinType) {
      switch ('${t.name}.$name') {
        case 'double.infinity':
          return const KDouble(double.infinity);
        case 'double.negativeInfinity':
          return const KDouble(double.negativeInfinity);
        case 'double.nan':
          return const KDouble(double.nan);
        case 'double.maxFinite':
          return const KDouble(double.maxFinite);
        case 'double.minPositive':
          return const KDouble(double.minPositive);
      }
    }
    if (t is FlutterType) return _flutterTypeProperty(t, name, offset);
    if (t is FNode || t is FColor || t is FEnum || t is FIcon) {
      final r = _flutterValueProperty(t!, name, offset);
      if (!identical(r, _notFound)) return r;
      throw ExecutionAbort('undefined_getter', "`${typeName(t)}` da `$name` xususiyati yo'q.",
          "The getter '$name' isn't defined for the type '${typeName(t)}'.", offset);
    }
    if (t is KRecord) {
      if (name.startsWith(r'$')) {
        final i = int.tryParse(name.substring(1));
        if (i != null && i >= 1 && i <= t.positional.length) return t.positional[i - 1];
      }
      if (t.named.containsKey(name)) return t.named[name];
    }
    final ar = _asyncProperty(t, name, offset);
    if (!identical(ar, _notFound)) return ar;
    final r = _guard(() => _builtinGetter(t, name, offset), offset);
    if (!identical(r, _notFound)) return r;
    final ext = _findExtensionValue(t, name, offset);
    if (!identical(ext, _notFound)) return ext;
    if (t == null) _noSuchMethod(null, name, offset, getter: true);
    throw ExecutionAbort('undefined_getter',
        "`${typeName(t)}` turida `$name` nomli xususiyat yo'q.",
        "The getter '$name' isn't defined for the type '${typeName(t)}'.", offset,
        hint: _suggest(t, name));
  }

  String? _suggest(Object? t, String name) {
    const common = {
      'lenght': 'length', 'lengh': 'length', 'size': 'length', 'count': 'length',
      'toUppercase': 'toUpperCase', 'toUpper': 'toUpperCase', 'upper': 'toUpperCase',
      'toLowercase': 'toLowerCase', 'push': 'add', 'append': 'add', 'len': 'length',
    };
    final s = common[name];
    return s == null ? null : "Ehtimol `$s` demoqchisiz?";
  }

  Object? _builtinGetter(Object? t, String name, int offset) {
    if (t is String) {
      switch (name) {
        case 'length':
          return t.length;
        case 'isEmpty':
          return t.isEmpty;
        case 'isNotEmpty':
          return t.isNotEmpty;
        case 'codeUnits':
          return _newList(t.codeUnits, 'int');
        case 'runes':
          return t.runes.toList();
      }
    }
    if (t is int) {
      switch (name) {
        case 'isEven':
          return t.isEven;
        case 'isOdd':
          return t.isOdd;
        case 'isNegative':
          return t.isNegative;
        case 'sign':
          return t.sign;
        case 'bitLength':
          return t.bitLength;
        case 'isFinite':
          return true;
        case 'isInfinite':
        case 'isNaN':
          return false;
      }
    }
    if (t is KDouble) {
      switch (name) {
        case 'isNaN':
          return t.value.isNaN;
        case 'isInfinite':
          return t.value.isInfinite;
        case 'isFinite':
          return t.value.isFinite;
        case 'isNegative':
          return t.value.isNegative;
        case 'sign':
          return KDouble(t.value.sign);
      }
    }
    if (t is Map) {
      switch (name) {
        case 'length':
          return t.length;
        case 'isEmpty':
          return t.isEmpty;
        case 'isNotEmpty':
          return t.isNotEmpty;
        case 'keys':
          return t.keys;
        case 'values':
          return t.values;
        case 'entries':
          return t.entries.map((e) => _entry(e.key, e.value, offset).instance);
      }
    }
    if (t is Iterable) {
      switch (name) {
        case 'length':
          return t.length;
        case 'isEmpty':
          return t.isEmpty;
        case 'isNotEmpty':
          return t.isNotEmpty;
        case 'first':
          return t.first;
        case 'last':
          return t.last;
        case 'single':
          return t.single;
        case 'reversed':
          if (t is List) return t.reversed;
      }
    }
    if (t is StringBuffer) {
      switch (name) {
        case 'length':
          return t.length;
        case 'isEmpty':
          return t.isEmpty;
        case 'isNotEmpty':
          return t.isNotEmpty;
      }
    }
    if (t is DateTime) {
      switch (name) {
        case 'year':
          return t.year;
        case 'month':
          return t.month;
        case 'day':
          return t.day;
        case 'hour':
          return t.hour;
        case 'minute':
          return t.minute;
        case 'second':
          return t.second;
        case 'millisecond':
          return t.millisecond;
        case 'weekday':
          return t.weekday;
        case 'millisecondsSinceEpoch':
          return t.millisecondsSinceEpoch;
      }
    }
    return _notFound;
  }

  void _setProperty(Object? t, String name, Object? value, int offset) {
    if (t is KInstance) {
      final s = t.klass.findSetter(name);
      if (s != null) {
        _invoke(_makeFunction(s.$1, s.$2.staticEnv, owner: s.$2).bind(t, t.klass), [value], const {}, offset);
        return;
      }
      if (t.fields.containsKey(name)) {
        _setField(t, name, value, offset);
        return;
      }
      throw ExecutionAbort('undefined_setter',
          "`${t.klass.displayName}` class'ida `$name` nomli maydon yo'q.",
          "The setter '$name' isn't defined for the class '${t.klass.displayName}'.", offset,
          hint: "Avval class ichida maydonni e'lon qiling: String $name = '';");
    }
    if (t is KClass) {
      final b = t.statics[name];
      if (b != null) {
        if (b.isFinal) {
          throw ExecutionAbort('assign_final', "`${t.name}.$name` final — o'zgartirib bo'lmaydi.",
              "The final variable '$name' can only be set once.", offset);
        }
        b.value = _coerce(value, b.type, offset, name);
        return;
      }
    }
    if (t is List && name == 'length') {
      _guard(() => t.length = _intArg(value, offset), offset);
      return;
    }
    if (_setAsyncProperty(t, name, value)) return;
    if (t == null) _noSuchMethod(null, '$name=', offset);
    throw ExecutionAbort('undefined_setter', "`${typeName(t)}` turida `$name` ni o'zgartirib bo'lmaydi.",
        "The setter '$name' isn't defined for the type '${typeName(t)}'.", offset);
  }

  // ───────────────────────── Indeks ─────────────────────────

  Object? _index(Object? t, Object? i, int offset) {
    if (t is List) {
      final idx = _intArg(i, offset, 'index');
      return _guard(() => t[idx], offset);
    }
    if (t is String) {
      final idx = _intArg(i, offset, 'index');
      return _guard(() => t[idx], offset);
    }
    if (t is Map) return t[i];
    if (t is KInstance) return _callOperator(t, '[]', [i], offset);
    if (t == null) _noSuchMethod(null, '[]', offset);
    _typeError("'${typeName(t)}' turida `[]` operatori yo'q", offset);
  }

  void _indexSet(Object? t, Object? i, Object? v, int offset) {
    if (t is List) {
      final idx = _intArg(i, offset, 'index');
      final value = _checkElement(t, v, offset);
      _guard(() => t[idx] = value, offset);
      return;
    }
    if (t is Map) {
      _guard(() => t[i] = v, offset);
      return;
    }
    if (t is KInstance) {
      _callOperator(t, '[]=', [i, v], offset);
      return;
    }
    if (t is String) {
      _typeError("String o'zgarmas (immutable) — uning harfini indeks orqali almashtirib bo'lmaydi", offset);
    }
    if (t == null) _noSuchMethod(null, '[]=', offset);
    _typeError("'${typeName(t)}' turida `[]=` operatori yo'q", offset);
  }

  // ───────────────────────── Metodlar ─────────────────────────

  Object? _callMethod(Object? t, String name, List<Object?> pos, Map<String, Object?> named, int offset,
      {List<TypeAnnotation> typeArgs = const []}) {
    if (t is KInstance) {
      final m = t.klass.findMethod(name);
      if (m != null) {
        return _invoke(_makeFunction(m.$1, m.$2.staticEnv, owner: m.$2).bind(t, t.klass), pos, named, offset);
      }
      if (t.fields.containsKey(name)) return _callValue(t.fields[name], pos, named, offset, name: name);
      final g = t.klass.findGetter(name);
      if (g != null) return _callValue(_callGetter(g.$1, g.$2, t, offset), pos, named, offset, name: name);
      if (name == 'toString' && pos.isEmpty) return stringify(t, offset);
      final ext = _findExtensionValue(t, name, offset, args: pos, named: named);
      if (!identical(ext, _notFound)) return ext;
      throw ExecutionAbort('undefined_method',
          "`${t.klass.displayName}` class'ida `$name()` nomli metod yo'q.",
          "The method '$name' isn't defined for the class '${t.klass.displayName}'.", offset);
    }
    if (t is KClass) {
      if (t.constructors.containsKey(name)) return _instantiate(t, name, pos, named, offset);
      final r = _lookupStatic(t, name, offset);
      if (!identical(r, _notFound)) return _callValue(r, pos, named, offset, name: name);
      throw ExecutionAbort('undefined_static_method',
          "`${t.name}` class'ida `$name` nomli statik metod yoki konstruktor yo'q.",
          "Member not found: '${t.name}.$name'.", offset);
    }
    if (t is KNamespace) {
      return _callValue(_getProperty(t, name, offset), pos, named, offset, name: name);
    }
    if (t is FlutterType) return _flutterStaticMethod(t, name, pos, named, offset);
    if (t is FNode || t is FColor) {
      final r = _flutterValueMethod(t!, name, pos, named, offset);
      if (!identical(r, _notFound)) return r;
      throw ExecutionAbort('undefined_method', "`${typeName(t)}` da `$name()` metodi yo'q.",
          "The method '$name' isn't defined for the type '${typeName(t)}'.", offset);
    }
    if (t is BuiltinType) return _guard(() => _builtinStatic(t.name, name, pos, named, offset, typeArgs), offset);
    if (t is KFunction || t is NativeFunction) {
      if (name == 'call') return _callValue(t, pos, named, offset);
    }
    if (t is KFuture || t is KStream || t is KCompleter || t is KTimer || t is KStreamController || t is KStreamSink ||
        t is KSubscription) {
      final ar = _asyncMethod(t, name, pos, named, offset);
      if (!identical(ar, _notFound)) return ar;
    }
    if (name == 'toString' && pos.isEmpty && t is! StringBuffer) return stringify(t, offset);
    final r = _guard(() => _builtinMethod(t, name, pos, named, offset, typeArgs), offset);
    if (!identical(r, _notFound)) return r;
    final ext = _findExtensionValue(t, name, offset, args: pos, named: named);
    if (!identical(ext, _notFound)) return ext;
    if (t == null) _noSuchMethod(null, name, offset);
    throw ExecutionAbort('undefined_method',
        "`${typeName(t)}` turida `$name()` nomli metod yo'q.",
        "The method '$name' isn't defined for the type '${typeName(t)}'.", offset,
        hint: _suggest(t, name));
  }

  Object? _builtinStatic(String type, String name, List<Object?> p, Map<String, Object?> n, int offset,
      List<TypeAnnotation> typeArgs) {
    final elem = typeArgs.isEmpty ? null : typeArgs.first.toString();
    if (const {'Future', 'Stream', 'Timer', 'StreamController', 'Completer'}.contains(type)) {
      final r = _asyncStatic(type, name, p, n, offset, elem);
      if (!identical(r, _notFound)) return r;
    }
    switch ('$type.$name') {
      case 'int.parse':
        final radix = n['radix'] as int?;
        return int.parse(_strArg(p[0], offset, 'source'), radix: radix);
      case 'int.tryParse':
        return int.tryParse(_strArg(p[0], offset, 'source'), radix: n['radix'] as int?);
      case 'double.parse':
        return KDouble(double.parse(_strArg(p[0], offset, 'source')));
      case 'double.tryParse':
        final d = double.tryParse(_strArg(p[0], offset, 'source'));
        return d == null ? null : KDouble(d);
      case 'num.parse':
        final s = _strArg(p[0], offset, 'source');
        return int.tryParse(s) ?? KDouble(double.parse(s));
      case 'num.tryParse':
        final s = _strArg(p[0], offset, 'source');
        final i = int.tryParse(s);
        if (i != null) return i;
        final d = double.tryParse(s);
        return d == null ? null : KDouble(d);
      case 'String.fromCharCode':
        return String.fromCharCode(_intArg(p[0], offset));
      case 'String.fromCharCodes':
        return String.fromCharCodes([for (final c in _iterableOf(p[0], offset, 'fromCharCodes')) _intArg(c, offset)]);
      case 'List.filled':
        final list = List<Object?>.filled(_intArg(p[0], offset, 'length'), p[1], growable: n['growable'] == true);
        if (elem != null) _typeArgs[list] = elem;
        return list;
      case 'List.generate':
        final f = _fn1(p[1], offset);
        final list = List<Object?>.generate(_intArg(p[0], offset, 'length'), (i) => f(i), growable: n['growable'] != false);
        if (elem != null) _typeArgs[list] = elem;
        return list;
      case 'List.empty':
        final list = List<Object?>.empty(growable: n['growable'] == true);
        if (elem != null) _typeArgs[list] = elem;
        return list;
      case 'List.from':
      case 'List.of':
        return _newList(_iterableOf(p[0], offset, name), elem, n['growable'] != false);
      case 'List.unmodifiable':
        return List<Object?>.unmodifiable(_iterableOf(p[0], offset, name));
      case 'Set.from':
      case 'Set.of':
        return Set<Object?>.of(_iterableOf(p[0], offset, name));
      case 'Map.from':
      case 'Map.of':
        return Map<Object?, Object?>.of(p[0] as Map);
      case 'Map.fromIterables':
        return Map<Object?, Object?>.fromIterables(_iterableOf(p[0], offset, name), _iterableOf(p[1], offset, name));
      case 'Map.fromEntries':
        return {
          for (final e in _iterableOf(p[0], offset, name))
            (e as KInstance).fields['key']: e.fields['value'],
        };
      case 'DateTime.now':
        return virtualNow;
      case 'DateTime.parse':
        return DateTime.parse(_strArg(p[0], offset));
    }
    throw ExecutionAbort('undefined_static_method', "`$type.$name` mavjud emas.", "Member not found: '$type.$name'.", offset);
  }

  Object? _constructBuiltin(String type, String ctor, List<Object?> p, Map<String, Object?> n, int offset,
      {List<TypeAnnotation> typeArgs = const []}) {
    final ar = _asyncConstruct(type, p, n, offset, typeArgs.isEmpty ? null : typeArgs.first.toString());
    if (!identical(ar, _notFound)) return ar;
    switch (type) {
      case 'Map':
        final m = <Object?, Object?>{};
        if (typeArgs.length == 2) _typeArgs[m] = '${typeArgs[0]}, ${typeArgs[1]}';
        return m;
      case 'Set':
        final s = <Object?>{};
        if (typeArgs.length == 1) _typeArgs[s] = typeArgs[0].toString();
        return s;
      case 'StringBuffer':
        return StringBuffer(p.isEmpty ? '' : stringify(p[0], offset));
      case 'DateTime':
        return DateTime(_intArg(p[0], offset), p.length > 1 ? _intArg(p[1], offset) : 1, p.length > 2 ? _intArg(p[2], offset) : 1,
            p.length > 3 ? _intArg(p[3], offset) : 0, p.length > 4 ? _intArg(p[4], offset) : 0);
      case 'List':
        throw ExecutionAbort('list_constructor', "`List()` konstruktori Dart null safety'da olib tashlangan. `[]` yoki `List.filled()` ishlating.",
            "The default 'List' constructor isn't available when null safety is enabled.", offset);
    }
    throw ExecutionAbort('no_constructor', "`$type` turidan to'g'ridan-to'g'ri obyekt yaratib bo'lmaydi.",
        "The class '$type' doesn't have an unnamed constructor.", offset);
  }

  Object? _builtinMethod(Object? t, String name, List<Object?> p, Map<String, Object?> n, int offset,
      List<TypeAnnotation> typeArgs) {
    if (t is String) return _stringMethod(t, name, p, offset);
    if (t is int) return _intMethod(t, name, p, offset);
    if (t is KDouble) return _doubleMethod(t, name, p, offset);
    if (t is bool) return _notFound;
    if (t is List) {
      final r = _listMethod(t, name, p, n, offset);
      if (!identical(r, _notFound)) return r;
    }
    if (t is Set) {
      final r = _setMethod(t, name, p, offset);
      if (!identical(r, _notFound)) return r;
    }
    if (t is Map) return _mapMethod(t, name, p, n, offset);
    if (t is Iterable) return _iterableMethod(t, name, p, n, offset, typeArgs);
    if (t is StringBuffer) {
      switch (name) {
        case 'write':
          t.write(stringify(p.isEmpty ? '' : p[0], offset));
          return null;
        case 'writeln':
          t.writeln(p.isEmpty ? '' : stringify(p[0], offset));
          return null;
        case 'writeAll':
          t.writeAll(_iterableOf(p[0], offset, 'writeAll').map((e) => stringify(e, offset)), p.length > 1 ? p[1] as String : '');
          return null;
        case 'clear':
          t.clear();
          return null;
        case 'toString':
          return t.toString();
      }
    }
    if (t is KRandom) {
      switch (name) {
        case 'nextInt':
          return t.random.nextInt(_intArg(p[0], offset, 'max'));
        case 'nextDouble':
          return KDouble(t.random.nextDouble());
        case 'nextBool':
          return t.random.nextBool();
      }
    }
    if (t is KNative) {
      if (t.kind == 'stdin' && name == 'readLineSync') {
        if (_stdinIndex >= options.stdin.length) return null;
        final line = options.stdin[_stdinIndex++];
        _record(TraceKind.output, _lastUserOffset, 1, "Foydalanuvchi kiritdi: '$line'");
        return line;
      }
      if (t.kind == 'stdout') {
        switch (name) {
          case 'write':
            _write(stringify(p[0], offset));
            return null;
          case 'writeln':
            _write('${p.isEmpty ? '' : stringify(p[0], offset)}\n');
            return null;
          case 'writeAll':
            _write(_iterableOf(p[0], offset, 'writeAll').map((e) => stringify(e, offset)).join(p.length > 1 ? p[1] as String : ''));
            return null;
        }
      }
    }
    if (t is DateTime) {
      switch (name) {
        case 'toString':
          return t.toString();
        case 'difference':
          final o = p[0];
          if (o is! DateTime) _typeError("type '${typeName(o)}' is not a subtype of type 'DateTime'", offset);
          return _duration(t.difference(o).inMicroseconds, offset);
        case 'add':
          return t.add(Duration(microseconds: _durationMicros(p[0], offset)));
        case 'subtract':
          return t.subtract(Duration(microseconds: _durationMicros(p[0], offset)));
        case 'isBefore':
          return t.isBefore(p[0] as DateTime);
        case 'isAfter':
          return t.isAfter(p[0] as DateTime);
        case 'compareTo':
          return t.compareTo(p[0] as DateTime);
      }
    }
    return _notFound;
  }

  Object? _duration(int micros, int offset) => _instantiate(classes['Duration']!, '', const [], {'microseconds': micros}, offset);

  Object? _stringMethod(String s, String name, List<Object?> p, int offset) {
    switch (name) {
      case 'toUpperCase':
        return s.toUpperCase();
      case 'toLowerCase':
        return s.toLowerCase();
      case 'trim':
        return s.trim();
      case 'trimLeft':
        return s.trimLeft();
      case 'trimRight':
        return s.trimRight();
      case 'contains':
        return s.contains(_strArg(p[0], offset, 'other'));
      case 'startsWith':
        return s.startsWith(_strArg(p[0], offset, 'pattern'));
      case 'endsWith':
        return s.endsWith(_strArg(p[0], offset, 'other'));
      case 'indexOf':
        return s.indexOf(_strArg(p[0], offset, 'pattern'), p.length > 1 ? _intArg(p[1], offset) : 0);
      case 'lastIndexOf':
        return s.lastIndexOf(_strArg(p[0], offset, 'pattern'));
      case 'substring':
        return s.substring(_intArg(p[0], offset, 'start'), p.length > 1 ? _intArg(p[1], offset, 'end') : null);
      case 'split':
        return _newList(s.split(_strArg(p[0], offset, 'pattern')), 'String');
      case 'replaceAll':
        return s.replaceAll(_strArg(p[0], offset, 'from'), _strArg(p[1], offset, 'replace'));
      case 'replaceFirst':
        return s.replaceFirst(_strArg(p[0], offset, 'from'), _strArg(p[1], offset, 'to'));
      case 'padLeft':
        return s.padLeft(_intArg(p[0], offset, 'width'), p.length > 1 ? _strArg(p[1], offset) : ' ');
      case 'padRight':
        return s.padRight(_intArg(p[0], offset, 'width'), p.length > 1 ? _strArg(p[1], offset) : ' ');
      case 'codeUnitAt':
        return s.codeUnitAt(_intArg(p[0], offset, 'index'));
      case 'compareTo':
        return s.compareTo(_strArg(p[0], offset, 'other'));
      case 'toString':
        return s;
    }
    return _notFound;
  }

  Object? _intMethod(int v, String name, List<Object?> p, int offset) {
    switch (name) {
      case 'abs':
        return v.abs();
      case 'toDouble':
        return KDouble(v.toDouble());
      case 'toInt':
      case 'round':
      case 'floor':
      case 'ceil':
      case 'truncate':
        return v;
      case 'toString':
        return v.toString();
      case 'toStringAsFixed':
        return v.toDouble().toStringAsFixed(_intArg(p[0], offset, 'fractionDigits'));
      case 'toRadixString':
        return v.toRadixString(_intArg(p[0], offset, 'radix'));
      case 'compareTo':
        return v.compareTo(_numOf(p[0]));
      case 'remainder':
        final o = p[0];
        if (o is int) return v.remainder(o);
        return KDouble(v.toDouble().remainder(_numOf(o)));
      case 'clamp':
        final lo = p[0], hi = p[1];
        if (lo is int && hi is int) return v.clamp(lo, hi);
        return KDouble(v.toDouble().clamp(_numOf(lo), _numOf(hi)).toDouble());
      case 'gcd':
        return v.gcd(_intArg(p[0], offset));
      case 'roundToDouble':
      case 'floorToDouble':
      case 'ceilToDouble':
        return KDouble(v.toDouble());
    }
    return _notFound;
  }

  Object? _doubleMethod(KDouble d, String name, List<Object?> p, int offset) {
    final v = d.value;
    switch (name) {
      case 'abs':
        return KDouble(v.abs());
      case 'round':
        return v.round();
      case 'floor':
        return v.floor();
      case 'ceil':
        return v.ceil();
      case 'truncate':
      case 'toInt':
        return v.toInt();
      case 'toDouble':
        return d;
      case 'toString':
        return formatDouble(v);
      case 'toStringAsFixed':
        return v.toStringAsFixed(_intArg(p[0], offset, 'fractionDigits'));
      case 'toStringAsPrecision':
        return v.toStringAsPrecision(_intArg(p[0], offset, 'precision'));
      case 'roundToDouble':
        return KDouble(v.roundToDouble());
      case 'floorToDouble':
        return KDouble(v.floorToDouble());
      case 'ceilToDouble':
        return KDouble(v.ceilToDouble());
      case 'compareTo':
        return v.compareTo(_numOf(p[0]));
      case 'remainder':
        return KDouble(v.remainder(_numOf(p[0])));
      case 'clamp':
        return KDouble(v.clamp(_numOf(p[0]), _numOf(p[1])).toDouble());
    }
    return _notFound;
  }

  int _indexOfEq(List<Object?> list, Object? x, int start) {
    for (var i = start; i < list.length; i++) {
      if (_equals(list[i], x, _lastUserOffset)) return i;
    }
    return -1;
  }

  Object? _listMethod(List<Object?> list, String name, List<Object?> p, Map<String, Object?> n, int offset) {
    switch (name) {
      case 'add':
        list.add(_checkElement(list, p[0], offset));
        return null;
      case 'addAll':
        list.addAll([for (final e in _iterableOf(p[0], offset, 'addAll')) _checkElement(list, e, offset)]);
        return null;
      case 'insert':
        list.insert(_intArg(p[0], offset, 'index'), _checkElement(list, p[1], offset));
        return null;
      case 'insertAll':
        list.insertAll(_intArg(p[0], offset, 'index'), _iterableOf(p[1], offset, 'insertAll'));
        return null;
      case 'remove':
        final i = _indexOfEq(list, p[0], 0);
        if (i < 0) return false;
        list.removeAt(i);
        return true;
      case 'removeAt':
        return list.removeAt(_intArg(p[0], offset, 'index'));
      case 'removeLast':
        return list.removeLast();
      case 'removeWhere':
        final f = _fn1(p[0], offset);
        list.removeWhere((e) => _asBool(f(e), offset));
        return null;
      case 'retainWhere':
        final f = _fn1(p[0], offset);
        list.retainWhere((e) => _asBool(f(e), offset));
        return null;
      case 'removeRange':
        list.removeRange(_intArg(p[0], offset), _intArg(p[1], offset));
        return null;
      case 'clear':
        list.clear();
        return null;
      case 'indexOf':
        return _indexOfEq(list, p[0], p.length > 1 ? _intArg(p[1], offset) : 0);
      case 'lastIndexOf':
        for (var i = list.length - 1; i >= 0; i--) {
          if (_equals(list[i], p[0], offset)) return i;
        }
        return -1;
      case 'indexWhere':
        final f = _fn1(p[0], offset);
        return list.indexWhere((e) => _asBool(f(e), offset));
      case 'lastIndexWhere':
        final f = _fn1(p[0], offset);
        return list.lastIndexWhere((e) => _asBool(f(e), offset));
      case 'sublist':
        return _newList(list.sublist(_intArg(p[0], offset, 'start'), p.length > 1 ? _intArg(p[1], offset, 'end') : null),
            _typeArgs[list]);
      case 'getRange':
        return list.getRange(_intArg(p[0], offset), _intArg(p[1], offset));
      case 'sort':
        if (p.isEmpty || p[0] == null) {
          list.sort((a, b) => _compare(a, b, offset));
        } else {
          final f = _fn2(p[0], offset);
          list.sort((a, b) => _intArg(f(a, b), offset, 'compare'));
        }
        return null;
      case 'shuffle':
        list.shuffle(_random);
        return null;
      case 'fillRange':
        list.fillRange(_intArg(p[0], offset), _intArg(p[1], offset), p.length > 2 ? p[2] : null);
        return null;
      case 'asMap':
        return <Object?, Object?>{for (var i = 0; i < list.length; i++) i: list[i]};
    }
    return _notFound;
  }

  Object? _setMethod(Set<Object?> set, String name, List<Object?> p, int offset) {
    switch (name) {
      case 'add':
        return set.add(_checkElement(set, p[0], offset));
      case 'addAll':
        set.addAll(_iterableOf(p[0], offset, 'addAll'));
        return null;
      case 'remove':
        return set.remove(p[0]);
      case 'contains':
        return set.contains(p[0]);
      case 'containsAll':
        return set.containsAll(_iterableOf(p[0], offset, 'containsAll'));
      case 'union':
        return set.union(p[0] as Set<Object?>);
      case 'intersection':
        return set.intersection(p[0] as Set<Object?>);
      case 'difference':
        return set.difference(p[0] as Set<Object?>);
      case 'removeAll':
        set.removeAll(_iterableOf(p[0], offset, 'removeAll'));
        return null;
      case 'clear':
        set.clear();
        return null;
    }
    return _notFound;
  }

  Object? _mapMethod(Map<Object?, Object?> map, String name, List<Object?> p, Map<String, Object?> n, int offset) {
    switch (name) {
      case 'containsKey':
        return map.containsKey(p[0]);
      case 'containsValue':
        return map.containsValue(p[0]);
      case 'remove':
        return map.remove(p[0]);
      case 'clear':
        map.clear();
        return null;
      case 'putIfAbsent':
        final f = p[1];
        return map.putIfAbsent(p[0], () => _callValue(f, const [], const {}, offset));
      case 'update':
        final f = _fn1(p[1], offset);
        final ifAbsent = n['ifAbsent'];
        return map.update(p[0], (v) => f(v),
            ifAbsent: ifAbsent == null ? null : () => _callValue(ifAbsent, const [], const {}, offset));
      case 'updateAll':
        final f = _fn2(p[0], offset);
        map.updateAll((k, v) => f(k, v));
        return null;
      case 'forEach':
        final f = _fn2(p[0], offset);
        map.forEach((k, v) => f(k, v));
        return null;
      case 'map':
        final f = _fn2(p[0], offset);
        final out = <Object?, Object?>{};
        map.forEach((k, v) {
          final e = f(k, v);
          if (e is! KInstance || e.klass.name != 'MapEntry') {
            _typeError("map() funksiyasi MapEntry qaytarishi kerak", offset);
          }
          out[e.fields['key']] = e.fields['value'];
        });
        return out;
      case 'addAll':
        map.addAll(p[0] as Map<Object?, Object?>);
        return null;
      case 'addEntries':
        for (final e in _iterableOf(p[0], offset, 'addEntries')) {
          final me = e as KInstance;
          map[me.fields['key']] = me.fields['value'];
        }
        return null;
      case 'removeWhere':
        final f = _fn2(p[0], offset);
        map.removeWhere((k, v) => _asBool(f(k, v), offset));
        return null;
      case 'toString':
        return stringify(map, offset);
    }
    return _notFound;
  }

  Object? _iterableMethod(Iterable<Object?> it, String name, List<Object?> p, Map<String, Object?> n, int offset,
      List<TypeAnnotation> typeArgs) {
    switch (name) {
      case 'map':
        final f = _fn1(p[0], offset);
        return it.map((e) => f(e));
      case 'where':
        final f = _fn1(p[0], offset);
        return it.where((e) => _asBool(f(e), offset));
      case 'whereType':
        if (typeArgs.isEmpty) return it;
        return it.where((e) => isType(e, typeArgs.first));
      case 'expand':
        final f = _fn1(p[0], offset);
        return it.expand((e) => _iterableOf(f(e), offset, 'expand'));
      case 'forEach':
        final f = _fn1(p[0], offset);
        for (final e in it) {
          f(e);
        }
        return null;
      case 'any':
        final f = _fn1(p[0], offset);
        return it.any((e) => _asBool(f(e), offset));
      case 'every':
        final f = _fn1(p[0], offset);
        return it.every((e) => _asBool(f(e), offset));
      case 'reduce':
        final f = _fn2(p[0], offset);
        return it.reduce((a, b) => f(a, b));
      case 'fold':
        final f = _fn2(p[1], offset);
        return it.fold<Object?>(p[0], (a, b) => f(a, b));
      case 'contains':
        return it.any((e) => _equals(e, p[0], offset));
      case 'join':
        return it.map((e) => stringify(e, offset)).join(p.isEmpty ? '' : _strArg(p[0], offset, 'separator'));
      case 'toList':
        return _newList(it, _typeArgs[it] ?? (it is List ? null : null), n['growable'] != false);
      case 'toSet':
        return Set<Object?>.of(it);
      case 'take':
        return it.take(_intArg(p[0], offset, 'count'));
      case 'skip':
        return it.skip(_intArg(p[0], offset, 'count'));
      case 'takeWhile':
        final f = _fn1(p[0], offset);
        return it.takeWhile((e) => _asBool(f(e), offset));
      case 'skipWhile':
        final f = _fn1(p[0], offset);
        return it.skipWhile((e) => _asBool(f(e), offset));
      case 'firstWhere':
        final f = _fn1(p[0], offset);
        final orElse = n['orElse'];
        return it.firstWhere((e) => _asBool(f(e), offset),
            orElse: orElse == null ? null : () => _callValue(orElse, const [], const {}, offset));
      case 'lastWhere':
        final f = _fn1(p[0], offset);
        final orElse = n['orElse'];
        return it.lastWhere((e) => _asBool(f(e), offset),
            orElse: orElse == null ? null : () => _callValue(orElse, const [], const {}, offset));
      case 'singleWhere':
        final f = _fn1(p[0], offset);
        return it.singleWhere((e) => _asBool(f(e), offset));
      case 'elementAt':
        return it.elementAt(_intArg(p[0], offset, 'index'));
      case 'followedBy':
        return it.followedBy(_iterableOf(p[0], offset, 'followedBy'));
      case 'cast':
        return it;
    }
    return _notFound;
  }
}

/// `MapEntry` instansiyasini o'rab turadi.
class MapEntryLike {
  MapEntryLike(this.instance);
  final KInstance instance;
}
