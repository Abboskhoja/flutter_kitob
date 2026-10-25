import 'token.dart';

enum HighlightKind {
  plain,
  keyword,
  control,
  type,
  function,
  identifier,
  number,
  string,
  interpolation,
  comment,
  operator,
  punctuation,
  annotation,
  literal,
}

class HighlightToken {
  const HighlightToken(this.kind, this.start, this.end);
  final HighlightKind kind;
  final int start;
  final int end;

  @override
  String toString() => '$kind[$start,$end)';
}

const _control = {
  'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default', 'break', 'continue', 'return',
  'try', 'catch', 'finally', 'throw', 'rethrow', 'in', 'when', 'await', 'yield', 'on', 'assert',
};

const _builtinTypes = {
  'int', 'double', 'num', 'String', 'bool', 'List', 'Map', 'Set', 'Object', 'dynamic', 'void',
  'Iterable', 'Function', 'Future', 'Stream', 'Null', 'Never', 'Record', 'Type', 'Duration', 'DateTime',
  'StringBuffer', 'Exception', 'Error',
};

bool _identStart(int c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 || c == 36;
bool _identPart(int c) => _identStart(c) || (c >= 48 && c <= 57);
bool _digit(int c) => c >= 48 && c <= 57;

/// Dart kodini rang berish uchun bo'laklarga ajratadi. Hech qachon xato bermaydi
/// — yarim yozilgan kod uchun ham ishlaydi.
List<HighlightToken> highlightDart(String src) {
  final out = <HighlightToken>[];
  var i = 0;
  final n = src.length;
  int at(int k) => k < n ? src.codeUnitAt(k) : 0;

  void add(HighlightKind k, int s, int e) {
    if (e > s) out.add(HighlightToken(k, s, e));
  }

  // Satrni o'qiydi; interpolatsiyalarni alohida belgilaydi.
  int scanString(int start, {required bool raw}) {
    var p = start;
    if (raw) p++;
    final q = at(p);
    final triple = at(p + 1) == q && at(p + 2) == q;
    p += triple ? 3 : 1;
    var segStart = start;
    while (p < n) {
      final c = at(p);
      if (!triple && c == 10) break;
      if (c == q && (!triple || (at(p + 1) == q && at(p + 2) == q))) {
        p += triple ? 3 : 1;
        add(HighlightKind.string, segStart, p);
        return p;
      }
      if (c == 92 && !raw) {
        p += 2;
        continue;
      }
      if (c == 36 && !raw) {
        if (at(p + 1) == 123) {
          add(HighlightKind.string, segStart, p);
          add(HighlightKind.interpolation, p, p + 2);
          var depth = 1;
          var k = p + 2;
          final innerStart = k;
          while (k < n && depth > 0) {
            final d = at(k);
            if (d == 123) depth++;
            if (d == 125) depth--;
            if (depth == 0) break;
            if (!triple && d == 10) break;
            k++;
          }
          // ichki ifodani qayta rang beramiz
          for (final t in highlightDart(src.substring(innerStart, k))) {
            out.add(HighlightToken(t.kind, t.start + innerStart, t.end + innerStart));
          }
          if (k < n && at(k) == 125) {
            add(HighlightKind.interpolation, k, k + 1);
            k++;
          }
          p = k;
          segStart = p;
          continue;
        }
        if (_identStart(at(p + 1)) && at(p + 1) != 36) {
          add(HighlightKind.string, segStart, p);
          var k = p + 1;
          while (k < n && _identPart(at(k)) && at(k) != 36) {
            k++;
          }
          add(HighlightKind.interpolation, p, k);
          p = k;
          segStart = p;
          continue;
        }
      }
      p++;
    }
    add(HighlightKind.string, segStart, p);
    return p;
  }

  while (i < n) {
    final c = at(i);
    if (c == 32 || c == 9 || c == 10 || c == 13) {
      final s = i;
      while (i < n && (at(i) == 32 || at(i) == 9 || at(i) == 10 || at(i) == 13)) {
        i++;
      }
      add(HighlightKind.plain, s, i);
      continue;
    }
    if (c == 47 && at(i + 1) == 47) {
      final s = i;
      while (i < n && at(i) != 10) {
        i++;
      }
      add(HighlightKind.comment, s, i);
      continue;
    }
    if (c == 47 && at(i + 1) == 42) {
      final s = i;
      i += 2;
      while (i < n && !(at(i) == 42 && at(i + 1) == 47)) {
        i++;
      }
      i = i + 2 > n ? n : i + 2;
      add(HighlightKind.comment, s, i);
      continue;
    }
    if (c == 114 && (at(i + 1) == 39 || at(i + 1) == 34)) {
      i = scanString(i, raw: true);
      continue;
    }
    if (c == 39 || c == 34) {
      i = scanString(i, raw: false);
      continue;
    }
    if (c == 64 && _identStart(at(i + 1))) {
      final s = i;
      i++;
      while (i < n && _identPart(at(i))) {
        i++;
      }
      add(HighlightKind.annotation, s, i);
      continue;
    }
    if (_identStart(c)) {
      final s = i;
      while (i < n && _identPart(at(i))) {
        i++;
      }
      final w = src.substring(s, i);
      var k = i;
      while (k < n && (at(k) == 32)) {
        k++;
      }
      final next = at(k);
      HighlightKind kind;
      if (w == 'true' || w == 'false' || w == 'null') {
        kind = HighlightKind.literal;
      } else if (_control.contains(w)) {
        kind = HighlightKind.control;
      } else if (_builtinTypes.contains(w)) {
        kind = HighlightKind.type;
      } else if (dartKeywords.contains(w) && !(contextualKeywords.contains(w) && next == 40)) {
        kind = HighlightKind.keyword;
      } else if (next == 40 || (next == 60 && w.isNotEmpty && w[0] != w[0].toUpperCase())) {
        kind = w[0] == w[0].toUpperCase() && w[0] != '_' && w[0] != r'$' ? HighlightKind.type : HighlightKind.function;
      } else if (w[0] == w[0].toUpperCase() && w[0] != '_' && w[0] != r'$') {
        kind = HighlightKind.type;
      } else {
        kind = HighlightKind.identifier;
      }
      add(kind, s, i);
      continue;
    }
    if (_digit(c) || (c == 46 && _digit(at(i + 1)))) {
      final s = i;
      if (c == 48 && (at(i + 1) == 120 || at(i + 1) == 88)) {
        i += 2;
        while (i < n && (_identPart(at(i)))) {
          i++;
        }
      } else {
        while (i < n && (_digit(at(i)) || at(i) == 95)) {
          i++;
        }
        if (at(i) == 46 && _digit(at(i + 1))) {
          i++;
          while (i < n && _digit(at(i))) {
            i++;
          }
        }
        if (at(i) == 101 || at(i) == 69) {
          var k = i + 1;
          if (at(k) == 43 || at(k) == 45) k++;
          if (_digit(at(k))) {
            i = k;
            while (i < n && _digit(at(i))) {
              i++;
            }
          }
        }
      }
      add(HighlightKind.number, s, i);
      continue;
    }
    if ('()[]{},;'.contains(String.fromCharCode(c))) {
      add(HighlightKind.punctuation, i, i + 1);
      i++;
      continue;
    }
    final s = i;
    while (i < n && '+-*/%=<>!&|^~?:.'.contains(String.fromCharCode(at(i)))) {
      if (at(i) == 47 && (at(i + 1) == 47 || at(i + 1) == 42)) break;
      i++;
    }
    if (i == s) i++;
    add(HighlightKind.operator, s, i);
  }
  return out;
}
