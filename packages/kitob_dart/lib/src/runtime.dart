import 'dart:math' as math;

import 'ast.dart';

/// O'zgaruvchi saqlanadigan "quti".
class Binding {
  Binding(this.value, {this.isFinal = false, this.type, this.initialized = true, this.isLate = false});
  Object? value;
  final bool isFinal;
  final TypeAnnotation? type;
  bool initialized;
  final bool isLate;
}

/// Ko'rinish sohasi (scope). Ichma-ich bloklar zanjir hosil qiladi.
class Env {
  Env(this.parent, {this.self, this.selfClass, this.staticClass, this.isFunction = false, this.functionName});

  final Env? parent;
  final Map<String, Binding> vars = {};

  /// Metod ichida `this` qiymati.
  final Object? self;
  final KClass? selfClass;

  /// Statik a'zolar ko'rinadigan class.
  final KClass? staticClass;
  final bool isFunction;
  final String? functionName;

  bool get hasSelf => selfClass != null || self != null;

  void define(String name, Binding b) => vars[name] = b;
}

class KFunction {
  KFunction({
    required this.name,
    required this.params,
    required this.body,
    required this.closure,
    this.returnType,
    this.self,
    this.ownerClass,
    this.isGetter = false,
    this.isStatic = false,
    this.isAsync = false,
    this.isGenerator = false,
    this.selfClass,
  });

  final String name;
  final List<Param> params;
  final FunctionBody? body;
  final Env closure;
  final TypeAnnotation? returnType;
  final Object? self;
  final KClass? ownerClass;
  final KClass? selfClass;
  final bool isGetter;
  final bool isStatic;
  final bool isAsync;

  /// `sync*` / `async*` generator.
  final bool isGenerator;

  KFunction bind(Object? newSelf, KClass? newSelfClass) => KFunction(
    name: name,
    params: params,
    body: body,
    closure: closure,
    returnType: returnType,
    self: newSelf,
    ownerClass: ownerClass,
    isGetter: isGetter,
    isStatic: isStatic,
    isAsync: isAsync,
    isGenerator: isGenerator,
    selfClass: newSelfClass,
  );

  String signature() {
    final ps = params.map((p) => p.type?.toString() ?? 'dynamic').join(', ');
    return '($ps) => ${returnType?.toString() ?? 'dynamic'}';
  }
}

typedef NativeImpl = Object? Function(List<Object?> positional, Map<String, Object?> named);

class NativeFunction {
  NativeFunction(this.name, this.impl, {this.signature = '(dynamic) => dynamic'});
  final String name;
  final NativeImpl impl;
  final String signature;
}

class KClass {
  KClass(this.name, this.decl, {this.superclass, this.isMixinApplication = false});

  final String name;
  final ClassDecl decl;
  KClass? superclass;
  final bool isMixinApplication;

  final Map<String, FunctionDecl> methods = {};
  final Map<String, FunctionDecl> getters = {};
  final Map<String, FunctionDecl> setters = {};
  final Map<String, ConstructorDecl> constructors = {};
  final List<FieldDecl> instanceFields = [];
  final Set<String> finalFields = {};
  final Map<String, Binding> statics = {};
  final Map<String, FunctionDecl> staticMethods = {};
  final Map<String, FunctionDecl> staticGetters = {};
  final Set<String> interfaceNames = {};
  final List<KInstance> enumValues = [];
  late Env staticEnv;

  bool get isAbstract => decl.isAbstract;
  bool get isEnum => decl.kind == ClassKind.enumDecl;

  bool isSubtypeOf(String other) {
    KClass? c = this;
    while (c != null) {
      if (c.name == other || c.interfaceNames.contains(other)) return true;
      c = c.superclass;
    }
    return false;
  }

  (FunctionDecl, KClass)? findMethod(String n) {
    KClass? c = this;
    while (c != null) {
      final m = c.methods[n];
      if (m != null) return (m, c);
      c = c.superclass;
    }
    return null;
  }

  (FunctionDecl, KClass)? findGetter(String n) {
    KClass? c = this;
    while (c != null) {
      final m = c.getters[n];
      if (m != null) return (m, c);
      c = c.superclass;
    }
    return null;
  }

  (FunctionDecl, KClass)? findSetter(String n) {
    KClass? c = this;
    while (c != null) {
      final m = c.setters[n];
      if (m != null) return (m, c);
      c = c.superclass;
    }
    return null;
  }

  bool hasFinalField(String n) {
    KClass? c = this;
    while (c != null) {
      if (c.finalFields.contains(n)) return true;
      c = c.superclass;
    }
    return false;
  }

  /// Ko'rinadigan nom: mixin qo'llanilgan bo'lsa ham asl class nomi.
  String get displayName => name;
}

class KInstance {
  KInstance(this.klass);
  final KClass klass;
  final Map<String, Object?> fields = {};

  /// Enum qiymatlari uchun.
  String? enumName;
  int enumIndex = -1;
}

/// `int`, `String`, `List` kabi o'rnatilgan tur obyekti (masalan `int.parse`).
class BuiltinType {
  const BuiltinType(this.name);
  final String name;

  @override
  bool operator ==(Object other) => other is BuiltinType && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

/// `dart:math` dagi `Random`.
class KRandom {
  KRandom(this.random);
  final math.Random random;
}

/// Foydalanuvchi kodida `throw` qilingan qiymat.
class DartThrow implements Exception {
  DartThrow(this.value, this.offset, this.stack);
  final Object? value;
  final int offset;
  final List<String> stack;
}

/// Dastur bajarilishini to'xtatuvchi ichki xatolar (cheksiz sikl, xotira).
class ExecutionAbort implements Exception {
  ExecutionAbort(this.kind, this.message, this.original, this.offset, {this.hint});
  final String kind;
  final String message;
  final String original;
  final String? hint;
  final int offset;
}

/// Dart'ning o'zida yozilgan standart kutubxona qismi.
const preludeSource = r'''
class Object {
  Object();
}
class Exception {
  final dynamic message;
  Exception([this.message]);
  String toString() => message == null ? 'Exception' : 'Exception: $message';
}
class FormatException implements Exception {
  final String message;
  final dynamic source;
  final int? offset;
  FormatException([this.message = '', this.source, this.offset]);
  String toString() {
    var s = 'FormatException';
    if (message != '') s = '$s: $message';
    if (source != null) s = '$s\n$source';
    return s;
  }
}
class Error {
  Error();
  String toString() => 'Error';
}
class ArgumentError extends Error {
  final dynamic message;
  ArgumentError([this.message]);
  String toString() => message == null ? 'Invalid argument(s)' : 'Invalid argument(s): $message';
}
class RangeError extends ArgumentError {
  final String text;
  RangeError(this.text) : super(text);
  String toString() => text;
}
class StateError extends Error {
  final String message;
  StateError(this.message);
  String toString() => 'Bad state: $message';
}
class UnsupportedError extends Error {
  final String? message;
  UnsupportedError(this.message);
  String toString() => 'Unsupported operation: $message';
}
class UnimplementedError extends Error {
  final String? message;
  UnimplementedError([this.message]);
  String toString() => message == null ? 'UnimplementedError' : 'UnimplementedError: $message';
}
class TypeError extends Error {
  final String text;
  TypeError(this.text);
  String toString() => text;
}
class NoSuchMethodError extends Error {
  final String text;
  NoSuchMethodError(this.text);
  String toString() => text;
}
class AssertionError extends Error {
  final dynamic message;
  AssertionError([this.message]);
  String toString() => message == null ? 'Assertion failed' : 'Assertion failed: $message';
}
class LateInitializationError extends Error {
  final String text;
  LateInitializationError(this.text);
  String toString() => 'LateInitializationError: $text';
}
class IntegerDivisionByZeroException implements Exception {
  IntegerDivisionByZeroException();
  String toString() => 'IntegerDivisionByZeroException';
}
class ConcurrentModificationError extends Error {
  ConcurrentModificationError();
  String toString() => 'Concurrent modification during iteration.';
}
class MapEntry {
  final dynamic key;
  final dynamic value;
  const MapEntry(this.key, this.value);
  String toString() => 'MapEntry($key: $value)';
}
class Duration {
  static const zero = Duration();
  final int inMicroseconds;
  const Duration({int days = 0, int hours = 0, int minutes = 0, int seconds = 0, int milliseconds = 0, int microseconds = 0})
      : inMicroseconds = ((((days * 24 + hours) * 60 + minutes) * 60 + seconds) * 1000 + milliseconds) * 1000 + microseconds;
  int get inMilliseconds => inMicroseconds ~/ 1000;
  int get inSeconds => inMicroseconds ~/ 1000000;
  int get inMinutes => inMicroseconds ~/ 60000000;
  int get inHours => inMicroseconds ~/ 3600000000;
  int get inDays => inMicroseconds ~/ 86400000000;
  String toString() {
    var us = inMicroseconds;
    var sign = '';
    if (us < 0) { sign = '-'; us = -us; }
    final h = us ~/ 3600000000;
    final m = (us ~/ 60000000) % 60;
    final s = (us ~/ 1000000) % 60;
    final rest = us % 1000000;
    return '$sign$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${rest.toString().padLeft(6, '0')}';
  }
  Duration operator +(Duration other) => Duration(microseconds: inMicroseconds + other.inMicroseconds);
  Duration operator -(Duration other) => Duration(microseconds: inMicroseconds - other.inMicroseconds);
  Duration operator *(num factor) => Duration(microseconds: (inMicroseconds * factor).round());
  bool operator <(Duration other) => inMicroseconds < other.inMicroseconds;
  bool operator >(Duration other) => inMicroseconds > other.inMicroseconds;
  bool operator ==(Object other) => other is Duration && other.inMicroseconds == inMicroseconds;
  int get hashCode => inMicroseconds.hashCode;
}
class TimeoutException implements Exception {
  final String? message;
  final Duration? duration;
  TimeoutException(this.message, [this.duration]);
  String toString() {
    var result = 'TimeoutException';
    if (duration != null) result = 'TimeoutException after $duration';
    if (message != null) result = '$result: $message';
    return result;
  }
}
''';

const preludeClassNames = {
  'Object', 'Exception', 'FormatException', 'Error', 'ArgumentError', 'RangeError', 'StateError',
  'UnsupportedError', 'UnimplementedError', 'TypeError', 'NoSuchMethodError', 'AssertionError',
  'LateInitializationError', 'IntegerDivisionByZeroException', 'ConcurrentModificationError',
  'MapEntry', 'Duration', 'TimeoutException',
};
