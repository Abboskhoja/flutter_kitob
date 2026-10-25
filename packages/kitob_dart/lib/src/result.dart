import 'diagnostics.dart';

/// Vizualizatorda ko'rsatiladigan o'zgaruvchi holati.
class VarSnapshot {
  const VarSnapshot(this.name, this.value, this.type);
  final String name;
  final String value;
  final String type;

  Map<String, Object?> toJson() => {'n': name, 'v': value, 't': type};
  factory VarSnapshot.fromJson(Map<String, Object?> j) =>
      VarSnapshot(j['n'] as String, j['v'] as String, j['t'] as String);
}

enum TraceKind { start, declare, assign, condition, loop, call, ret, output, branch, wait, error, end }

/// Dastur bajarilishining bitta qadami. Interpretator haqiqatda bajargan
/// amallardan yoziladi — uydirma emas.
class TraceStep {
  const TraceStep({
    required this.kind,
    required this.line,
    required this.description,
    required this.vars,
    required this.outputLength,
    required this.callStack,
    this.changed = const [],
    this.offset = 0,
    this.length = 0,
  });

  final TraceKind kind;
  final int line;
  final int offset;
  final int length;
  final String description;
  final List<VarSnapshot> vars;
  final List<String> changed;
  final int outputLength;
  final List<String> callStack;

  Map<String, Object?> toJson() => {
    'k': kind.index,
    'l': line,
    'o': offset,
    'len': length,
    'd': description,
    'v': [for (final v in vars) v.toJson()],
    'c': changed,
    'out': outputLength,
    's': callStack,
  };

  factory TraceStep.fromJson(Map<String, Object?> j) => TraceStep(
    kind: TraceKind.values[j['k'] as int],
    line: j['l'] as int,
    offset: j['o'] as int,
    length: j['len'] as int,
    description: j['d'] as String,
    vars: [for (final v in j['v'] as List) VarSnapshot.fromJson((v as Map).cast<String, Object?>())],
    changed: (j['c'] as List).cast<String>(),
    outputLength: j['out'] as int,
    callStack: (j['s'] as List).cast<String>(),
  );
}

/// Bajarilish vaqtidagi xato (masalan, `RangeError`, cheksiz sikl).
class RuntimeErrorInfo {
  const RuntimeErrorInfo({
    required this.type,
    required this.message,
    required this.explanation,
    required this.line,
    required this.column,
    this.hint,
    this.stack = const [],
  });

  /// `FormatException`, `RangeError`, `Timeout` ...
  final String type;

  /// Dart chiqaradigan asl matn (masalan `RangeError (index): ...`).
  final String message;

  /// O'zbekcha tushuntirish.
  final String explanation;
  final String? hint;
  final int line;
  final int column;
  final List<String> stack;

  Map<String, Object?> toJson() => {
    'type': type,
    'message': message,
    'explanation': explanation,
    'hint': hint,
    'line': line,
    'column': column,
    'stack': stack,
  };

  factory RuntimeErrorInfo.fromJson(Map<String, Object?> j) => RuntimeErrorInfo(
    type: j['type'] as String,
    message: j['message'] as String,
    explanation: j['explanation'] as String,
    hint: j['hint'] as String?,
    line: j['line'] as int,
    column: j['column'] as int,
    stack: (j['stack'] as List).cast<String>(),
  );
}

class ExecutionResult {
  const ExecutionResult({
    required this.stdout,
    required this.diagnostics,
    this.error,
    this.trace = const [],
    this.traceTruncated = false,
    this.steps = 0,
    this.elapsedMicros = 0,
  });

  final String stdout;
  final List<Diagnostic> diagnostics;
  final RuntimeErrorInfo? error;
  final List<TraceStep> trace;
  final bool traceTruncated;
  final int steps;
  final int elapsedMicros;

  bool get compiled => !diagnostics.any((d) => d.isError);
  bool get success => compiled && error == null;

  List<String> get lines {
    if (stdout.isEmpty) return const [];
    final l = stdout.split('\n');
    if (l.last.isEmpty) l.removeLast();
    return l;
  }

  Map<String, Object?> toJson() => {
    'stdout': stdout,
    'diagnostics': [for (final d in diagnostics) d.toJson()],
    'error': error?.toJson(),
    'trace': [for (final t in trace) t.toJson()],
    'traceTruncated': traceTruncated,
    'steps': steps,
    'elapsed': elapsedMicros,
  };

  factory ExecutionResult.fromJson(Map<String, Object?> j) => ExecutionResult(
    stdout: j['stdout'] as String,
    diagnostics: [
      for (final d in j['diagnostics'] as List) Diagnostic.fromJson((d as Map).cast<String, Object?>()),
    ],
    error: j['error'] == null ? null : RuntimeErrorInfo.fromJson((j['error'] as Map).cast<String, Object?>()),
    trace: [for (final t in j['trace'] as List) TraceStep.fromJson((t as Map).cast<String, Object?>())],
    traceTruncated: j['traceTruncated'] as bool,
    steps: j['steps'] as int,
    elapsedMicros: j['elapsed'] as int,
  );
}

class ExecutionOptions {
  const ExecutionOptions({
    this.maxSteps = 5000000,
    this.timeout = const Duration(seconds: 5),
    this.trace = false,
    this.maxTraceSteps = 1500,
    this.stdin = const [],
    this.maxOutputChars = 200000,
    this.maxCallDepth = 512,
    this.randomSeed,
  });

  final int maxSteps;
  final Duration timeout;
  final bool trace;
  final int maxTraceSteps;
  final List<String> stdin;
  final int maxOutputChars;
  final int maxCallDepth;
  final int? randomSeed;

  Map<String, Object?> toJson() => {
    'maxSteps': maxSteps,
    'timeout': timeout.inMilliseconds,
    'trace': trace,
    'maxTraceSteps': maxTraceSteps,
    'stdin': stdin,
    'maxOutputChars': maxOutputChars,
    'maxCallDepth': maxCallDepth,
    'seed': randomSeed,
  };

  factory ExecutionOptions.fromJson(Map<String, Object?> j) => ExecutionOptions(
    maxSteps: j['maxSteps'] as int,
    timeout: Duration(milliseconds: j['timeout'] as int),
    trace: j['trace'] as bool,
    maxTraceSteps: j['maxTraceSteps'] as int,
    stdin: (j['stdin'] as List).cast<String>(),
    maxOutputChars: j['maxOutputChars'] as int,
    maxCallDepth: j['maxCallDepth'] as int,
    randomSeed: j['seed'] as int?,
  );
}
