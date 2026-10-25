enum Severity { error, warning, info }

/// Kompilyatsiya bosqichida topilgan muammo (analyzer xabari).
///
/// Har bir xabar o'zbekcha tushuntirish va Dart analyzer uslubidagi inglizcha
/// asl matnga ega — o'quvchi haqiqiy IDE'da ham shu xatoni taniy olishi uchun.
class Diagnostic {
  const Diagnostic({
    required this.code,
    required this.message,
    required this.original,
    required this.line,
    required this.column,
    required this.offset,
    this.length = 1,
    this.severity = Severity.error,
    this.hint,
  });

  /// Masalan: `undefined_identifier`, `expected_token`.
  final String code;

  /// O'zbekcha xabar.
  final String message;

  /// Dart analyzer'dagi inglizcha muqobil xabar.
  final String original;

  /// Tuzatish bo'yicha maslahat.
  final String? hint;
  final int line;
  final int column;
  final int offset;
  final int length;
  final Severity severity;

  bool get isError => severity == Severity.error;

  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    'original': original,
    'hint': hint,
    'line': line,
    'column': column,
    'offset': offset,
    'length': length,
    'severity': severity.name,
  };

  factory Diagnostic.fromJson(Map<String, Object?> json) => Diagnostic(
    code: json['code'] as String,
    message: json['message'] as String,
    original: json['original'] as String,
    hint: json['hint'] as String?,
    line: json['line'] as int,
    column: json['column'] as int,
    offset: json['offset'] as int,
    length: json['length'] as int,
    severity: Severity.values.byName(json['severity'] as String),
  );

  @override
  String toString() => '$line:$column $code — $message';
}

/// Parser/lexer ichida darhol to'xtash uchun ishlatiladi.
class CompileError implements Exception {
  CompileError(this.diagnostic);
  final Diagnostic diagnostic;

  @override
  String toString() => diagnostic.toString();
}

/// Manba koddagi joyni (offset) qator va ustunga aylantiradi.
class LineMap {
  LineMap(String source) {
    _starts.add(0);
    for (var i = 0; i < source.length; i++) {
      if (source.codeUnitAt(i) == 10) _starts.add(i + 1);
    }
  }

  final List<int> _starts = [];

  int lineOf(int offset) {
    var lo = 0, hi = _starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_starts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  int columnOf(int offset) => offset - _starts[lineOf(offset) - 1] + 1;
}
