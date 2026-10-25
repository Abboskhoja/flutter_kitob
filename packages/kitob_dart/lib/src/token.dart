/// Token turlari. Lexer manba kodini shu bo'laklarga ajratadi.
enum TokenType {
  identifier,
  keyword,
  intLiteral,
  doubleLiteral,
  string,
  operator,
  punctuation,
  eof,
}

const dartKeywords = <String>{
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
  'catch', 'class', 'const', 'continue', 'default', 'do', 'dynamic', 'else',
  'enum', 'extends', 'extension', 'external', 'factory', 'false', 'final',
  'finally', 'for', 'get', 'if', 'implements', 'import', 'in', 'interface',
  'is', 'late', 'mixin', 'new', 'null', 'on', 'operator', 'required',
  'rethrow', 'return', 'sealed', 'set', 'static', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'when', 'while', 'with', 'yield',
};

/// Kontekstga qarab identifikator sifatida ham ishlatilishi mumkin bo'lgan
/// so'zlar (Dartda "built-in identifier"lar).
const contextualKeywords = <String>{
  'abstract', 'as', 'async', 'await', 'base', 'dynamic', 'extension',
  'external', 'factory', 'get', 'implements', 'interface', 'late', 'mixin',
  'on', 'operator', 'required', 'sealed', 'set', 'static', 'when', 'yield',
};

/// Satr ichidagi bo'lak: oddiy matn yoki `$x` / `${...}` ifodasi.
class StringPart {
  StringPart.text(this.text) : source = null, offset = 0;
  StringPart.expr(this.source, this.offset) : text = null;

  final String? text;
  final String? source;

  /// [source] ning manba koddagi boshlanish joyi.
  final int offset;

  bool get isText => text != null;
}

class Token {
  Token(
    this.type,
    this.lexeme,
    this.offset,
    this.line,
    this.column, {
    this.parts,
    this.precededByNewline = false,
  });

  final TokenType type;
  final String lexeme;
  final int offset;
  final int line;
  final int column;

  /// Faqat [TokenType.string] uchun.
  final List<StringPart>? parts;
  final bool precededByNewline;

  int get length => lexeme.length;
  int get end => offset + lexeme.length;

  bool isOp(String op) =>
      (type == TokenType.operator || type == TokenType.punctuation) &&
      lexeme == op;

  bool isKeyword(String k) => type == TokenType.keyword && lexeme == k;

  @override
  String toString() => '$type($lexeme)@$line:$column';
}
