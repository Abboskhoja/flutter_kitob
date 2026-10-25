import 'diagnostics.dart';
import 'token.dart';

const _operators = <String>[
  '>>>=', '...?', '>>=', '<<=', '~/=', '??=', '...', '>>>', '&&', '||',
  '==', '!=', '<=', '>=', '??', '?.', '=>', '++', '--', '+=', '-=', '*=',
  '/=', '%=', '~/', '<<', '&=', '|=', '^=', '..', '!', '=', '<', '>', '+',
  '-', '*', '/', '%', '&', '|', '^', '~', '?', ':', '.', '@', '#',
];

const _punctuation = '()[]{},;';

/// Manba kodni tokenlarga ajratadi.
class Lexer {
  Lexer(this.source, {this.baseOffset = 0, LineMap? lineMap, String? fullSource})
    : _lineMap = lineMap ?? LineMap(fullSource ?? source);

  final String source;

  /// Interpolatsiya ichidagi kod uchun: asosiy fayldagi boshlanish joyi.
  final int baseOffset;
  final LineMap _lineMap;

  int _pos = 0;
  bool _sawNewline = false;
  final List<Token> _tokens = [];

  List<Token> tokenize() {
    while (true) {
      _skipTrivia();
      if (_pos >= source.length) {
        _tokens.add(_make(TokenType.eof, '', _pos));
        return _tokens;
      }
      _scanToken();
    }
  }

  Token _make(TokenType type, String lexeme, int start, {List<StringPart>? parts}) {
    final abs = baseOffset + start;
    final t = Token(
      type,
      lexeme,
      abs,
      _lineMap.lineOf(abs),
      _lineMap.columnOf(abs),
      parts: parts,
      precededByNewline: _sawNewline,
    );
    _sawNewline = false;
    return t;
  }

  Never _error(String code, String message, String original, int at, {int length = 1, String? hint}) {
    final abs = baseOffset + at;
    throw CompileError(Diagnostic(
      code: code,
      message: message,
      original: original,
      hint: hint,
      line: _lineMap.lineOf(abs),
      column: _lineMap.columnOf(abs),
      offset: abs,
      length: length,
    ));
  }

  int _peek([int ahead = 0]) {
    final i = _pos + ahead;
    return i < source.length ? source.codeUnitAt(i) : 0;
  }

  void _skipTrivia() {
    while (_pos < source.length) {
      final c = _peek();
      if (c == 10) {
        _sawNewline = true;
        _pos++;
      } else if (c == 32 || c == 9 || c == 13) {
        _pos++;
      } else if (c == 47 && _peek(1) == 47) {
        while (_pos < source.length && _peek() != 10) {
          _pos++;
        }
      } else if (c == 47 && _peek(1) == 42) {
        final start = _pos;
        _pos += 2;
        var depth = 1;
        while (depth > 0) {
          if (_pos >= source.length) {
            _error('unterminated_comment', "Ko'p qatorli izoh yopilmagan. `*/` qo'ying.",
                'Unterminated multi-line comment.', start, length: 2);
          }
          if (_peek() == 47 && _peek(1) == 42) {
            depth++;
            _pos += 2;
          } else if (_peek() == 42 && _peek(1) == 47) {
            depth--;
            _pos += 2;
          } else {
            if (_peek() == 10) _sawNewline = true;
            _pos++;
          }
        }
      } else {
        break;
      }
    }
  }

  static bool _isIdentStart(int c) =>
      (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 || c == 36;
  static bool _isIdentPart(int c) => _isIdentStart(c) || _isDigit(c);
  static bool _isDigit(int c) => c >= 48 && c <= 57;
  static bool _isHex(int c) =>
      _isDigit(c) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102);

  void _scanToken() {
    final start = _pos;
    final c = _peek();

    if (c == 114 /* r */ && (_peek(1) == 39 || _peek(1) == 34)) {
      _pos++;
      _scanString(start, raw: true);
      return;
    }
    if (_isIdentStart(c)) {
      while (_isIdentPart(_peek())) {
        _pos++;
      }
      final word = source.substring(start, _pos);
      _tokens.add(_make(
        dartKeywords.contains(word) ? TokenType.keyword : TokenType.identifier,
        word,
        start,
      ));
      return;
    }
    if (_isDigit(c) || (c == 46 && _isDigit(_peek(1)))) {
      _scanNumber(start);
      return;
    }
    if (c == 39 || c == 34) {
      _scanString(start, raw: false);
      return;
    }
    if (_punctuation.contains(String.fromCharCode(c))) {
      _pos++;
      _tokens.add(_make(TokenType.punctuation, String.fromCharCode(c), start));
      return;
    }
    for (final op in _operators) {
      if (source.startsWith(op, _pos)) {
        _pos += op.length;
        _tokens.add(_make(TokenType.operator, op, start));
        return;
      }
    }
    final ch = String.fromCharCode(c);
    _error('illegal_character', "Kutilmagan belgi: `$ch`. Dart kodida bu belgi ishlatilmaydi.",
        "Illegal character '$c'.", start,
        hint: ch == '‘' || ch == '’' || ch == '“' || ch == '”'
            ? "Bu chiroyli (typografik) qo'shtirnoq. Dartda oddiy ' yoki \" belgisidan foydalaning."
            : null);
  }

  void _scanNumber(int start) {
    if (_peek() == 48 && (_peek(1) == 120 || _peek(1) == 88)) {
      _pos += 2;
      if (!_isHex(_peek())) {
        _error('missing_hex_digit', "0x dan keyin o'n oltilik raqam bo'lishi kerak.",
            'A hex digit (0-9 or A-F) must follow \'0x\'.', start, length: 2);
      }
      while (_isHex(_peek()) || _peek() == 95) {
        _pos++;
      }
      _tokens.add(_make(TokenType.intLiteral, source.substring(start, _pos), start));
      return;
    }
    var isDouble = false;
    while (_isDigit(_peek()) || (_peek() == 95 && _isDigit(_peek(1)))) {
      _pos++;
    }
    if (_peek() == 46 && _isDigit(_peek(1))) {
      isDouble = true;
      _pos++;
      while (_isDigit(_peek())) {
        _pos++;
      }
    }
    if (_peek() == 101 || _peek() == 69) {
      final save = _pos;
      _pos++;
      if (_peek() == 43 || _peek() == 45) _pos++;
      if (_isDigit(_peek())) {
        isDouble = true;
        while (_isDigit(_peek())) {
          _pos++;
        }
      } else {
        _pos = save;
      }
    }
    _tokens.add(_make(
      isDouble ? TokenType.doubleLiteral : TokenType.intLiteral,
      source.substring(start, _pos),
      start,
    ));
  }

  void _scanString(int start, {required bool raw}) {
    final quote = _peek();
    final triple = _peek(1) == quote && _peek(2) == quote;
    _pos += triple ? 3 : 1;
    final parts = <StringPart>[];
    final buf = StringBuffer();

    void flush() {
      if (buf.isNotEmpty) {
        parts.add(StringPart.text(buf.toString()));
        buf.clear();
      }
    }

    while (true) {
      if (_pos >= source.length || (!triple && _peek() == 10)) {
        _error('unterminated_string', 'Satr (String) yopilmagan. Oxiriga ${String.fromCharCode(quote)} qo\'ying.',
            'Unterminated string literal.', start,
            length: (_pos - start).clamp(1, 40));
      }
      final c = _peek();
      if (c == quote && (!triple || (_peek(1) == quote && _peek(2) == quote))) {
        _pos += triple ? 3 : 1;
        break;
      }
      if (c == 92 /* \ */ && !raw) {
        _pos++;
        final e = _peek();
        _pos++;
        switch (e) {
          case 110: buf.write('\n');
          case 116: buf.write('\t');
          case 114: buf.write('\r');
          case 98: buf.write('\b');
          case 102: buf.write('\f');
          case 118: buf.write('\v');
          case 120:
            final hex = source.substring(_pos, (_pos + 2).clamp(0, source.length));
            buf.writeCharCode(int.tryParse(hex, radix: 16) ?? 63);
            _pos += 2;
          case 117:
            if (_peek() == 123) {
              final close = source.indexOf('}', _pos);
              final hex = source.substring(_pos + 1, close);
              buf.writeCharCode(int.tryParse(hex, radix: 16) ?? 63);
              _pos = close + 1;
            } else {
              final hex = source.substring(_pos, (_pos + 4).clamp(0, source.length));
              buf.writeCharCode(int.tryParse(hex, radix: 16) ?? 63);
              _pos += 4;
            }
          default:
            buf.writeCharCode(e);
        }
        continue;
      }
      if (c == 36 /* $ */ && !raw) {
        if (_peek(1) == 123) {
          flush();
          final exprStart = _pos + 2;
          _pos = exprStart;
          var depth = 1;
          while (depth > 0) {
            if (_pos >= source.length) {
              _error('unterminated_interpolation', "`\${` ochilgan, lekin `}` bilan yopilmagan.",
                  'Expected to find \'}\'.', exprStart - 2, length: 2);
            }
            final d = _peek();
            if (d == 123) depth++;
            if (d == 125) depth--;
            if (d == 39 || d == 34) {
              // Ichki satrni o'tkazib yuboramiz.
              final q = d;
              _pos++;
              while (_pos < source.length && _peek() != q) {
                if (_peek() == 92) _pos++;
                _pos++;
              }
            }
            _pos++;
          }
          parts.add(StringPart.expr(
              source.substring(exprStart, _pos - 1), baseOffset + exprStart));
          continue;
        }
        if (_isIdentStart(_peek(1)) && _peek(1) != 36) {
          flush();
          final nameStart = _pos + 1;
          _pos = nameStart;
          while (_isIdentPart(_peek()) && _peek() != 36) {
            _pos++;
          }
          parts.add(StringPart.expr(source.substring(nameStart, _pos), baseOffset + nameStart));
          continue;
        }
        _error('invalid_interpolation', "`\$` belgisidan keyin o'zgaruvchi nomi yoki `{` kelishi kerak. Oddiy \$ belgisi uchun `\\\$` yozing.",
            "A '\$' has special meaning inside a string, and must be followed by an identifier or an expression in curly braces ({}).",
            _pos);
      }
      buf.writeCharCode(c);
      _pos++;
    }
    flush();
    _tokens.add(_make(TokenType.string, source.substring(start, _pos), start, parts: parts));
  }
}
