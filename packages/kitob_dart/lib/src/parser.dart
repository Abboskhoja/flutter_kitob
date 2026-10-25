import 'ast.dart';
import 'diagnostics.dart';
import 'lexer.dart';
import 'token.dart';
import 'values.dart';

const _assignOps = {
  '=', '+=', '-=', '*=', '/=', '%=', '~/=', '??=', '&=', '|=', '^=', '<<=', '>>=', '>>>=',
};

/// Tokenlardan sintaksis daraxti (AST) quradi.
class Parser {
  Parser(this.source) : lineMap = LineMap(source) {
    _tokens = Lexer(source, lineMap: lineMap).tokenize();
  }

  Parser._sub(this.source, this.lineMap, String fragment, int baseOffset) {
    _tokens = Lexer(fragment, baseOffset: baseOffset, lineMap: lineMap).tokenize();
  }

  final String source;
  final LineMap lineMap;
  late List<Token> _tokens;
  int _p = 0;

  Token get _cur => _tokens[_p];
  Token _peek([int n = 1]) => _tokens[(_p + n).clamp(0, _tokens.length - 1)];
  Token get _prev => _tokens[(_p - 1).clamp(0, _tokens.length - 1)];
  bool get _atEnd => _cur.type == TokenType.eof;

  Token _advance() => _tokens[_p++];

  bool _isOp(String op) => _cur.isOp(op);
  bool _isKw(String kw) => _cur.isKeyword(kw);

  bool _matchOp(String op) {
    if (_isOp(op)) {
      _p++;
      return true;
    }
    return false;
  }

  bool _matchKw(String kw) {
    if (_isKw(kw)) {
      _p++;
      return true;
    }
    return false;
  }

  /// Identifikator sifatida ishlatsa bo'ladigan token.
  bool _isIdent([Token? t]) {
    final tok = t ?? _cur;
    return tok.type == TokenType.identifier ||
        (tok.type == TokenType.keyword && contextualKeywords.contains(tok.lexeme));
  }

  Never _error(String code, String message, String original, {Token? at, String? hint}) {
    final t = at ?? _cur;
    throw CompileError(Diagnostic(
      code: code,
      message: message,
      original: original,
      hint: hint,
      line: t.line,
      column: t.column,
      offset: t.offset,
      length: t.length == 0 ? 1 : t.length,
    ));
  }

  String _describe(Token t) => t.type == TokenType.eof ? 'fayl oxiri' : '`${t.lexeme}`';

  Token _expectOp(String op, [String? context]) {
    if (_isOp(op)) return _advance();
    if (op == ';') _missingSemicolon();
    _error(
      'expected_token',
      '`$op` kutilgan edi, lekin ${_describe(_cur)} topildi${context == null ? '' : ' ($context)'}.',
      "Expected to find '$op'.",
      hint: _bracketHint(op),
    );
  }

  String? _bracketHint(String op) => switch (op) {
    ')' => "Har bir ochilgan `(` qavs `)` bilan yopilishi kerak.",
    '}' => "Har bir ochilgan `{` qavs `}` bilan yopilishi kerak. Qavslar juft bo'lishini tekshiring.",
    ']' => "Ro'yxat `[` bilan ochilgan bo'lsa, `]` bilan yopiladi.",
    _ => null,
  };

  Never _missingSemicolon() {
    final p = _prev;
    throw CompileError(Diagnostic(
      code: 'expected_semicolon',
      message: "Bu yerda `;` (nuqtali vergul) yetishmayapti.",
      original: "Expected ';' after this.",
      hint: "Dartda har bir buyruq oxiriga `;` qo'yiladi. Masalan: print('Salom');",
      line: p.line,
      column: p.column,
      offset: p.offset,
      length: p.length == 0 ? 1 : p.length,
    ));
  }

  void _expectSemicolon() {
    if (!_matchOp(';')) _missingSemicolon();
  }

  String _expectIdent([String what = 'nom']) {
    if (_isIdent()) return _advance().lexeme;
    if (_cur.type == TokenType.keyword) {
      _error('reserved_word', '`${_cur.lexeme}` — Dartning maxsus kalit so\'zi, uni $what sifatida ishlatib bo\'lmaydi.',
          "'${_cur.lexeme}' can't be used as an identifier because it's a keyword.",
          hint: "Boshqa nom tanlang, masalan `${_cur.lexeme}Qiymat`.");
    }
    _error('expected_identifier', '$what kutilgan edi, lekin ${_describe(_cur)} topildi.',
        'Expected an identifier.');
  }

  // ───────────────────────── Dastur ─────────────────────────

  Program parseProgram() {
    final imports = <ImportDecl>[];
    final functions = <FunctionDecl>[];
    final classes = <ClassDecl>[];
    final variables = <VarDecl>[];
    final extensions = <ExtensionDecl>[];

    while (!_atEnd) {
      _skipAnnotations();
      final start = _cur;
      if (_isKw('import') || (_isIdent() && _cur.lexeme == 'export')) {
        _advance();
        if (_cur.type != TokenType.string) {
          _error('expected_string', "import dan keyin kutubxona manzili satr ko'rinishida yoziladi.",
              'Expected a string literal.', hint: "Masalan: import 'dart:math';");
        }
        final uriTok = _advance();
        final uri = uriTok.parts!.map((e) => e.text ?? '').join();
        String? prefix;
        if (_matchKw('as')) prefix = _expectIdent('prefiks');
        while (!_isOp(';') && !_atEnd) {
          _advance();
        }
        _expectSemicolon();
        imports.add(ImportDecl(uri, start.offset, _prev.end,
            prefix: prefix, uriOffset: uriTok.offset, uriEnd: uriTok.end));
        continue;
      }
      if (_isIdent() && _cur.lexeme == 'typedef') {
        while (!_isOp(';') && !_atEnd) {
          _advance();
        }
        _expectSemicolon();
        continue;
      }
      final modifiers = <String>[];
      while ((_isKw('abstract') || _isKw('sealed') || _isKw('base') || _isKw('interface') || _isKw('final')) &&
          (_peek().isKeyword('class') || _peek().isKeyword('mixin') || _peek().isKeyword('abstract') ||
              _peek().isKeyword('base') || _peek().isKeyword('interface') || _peek().isKeyword('final') ||
              _peek().isKeyword('sealed'))) {
        modifiers.add(_advance().lexeme);
      }
      if (_isKw('mixin') && _peek().isKeyword('class')) {
        _advance();
      }
      if (_isKw('class')) {
        classes.add(_parseClass(start, modifiers));
        continue;
      }
      if (_isKw('mixin')) {
        classes.add(_parseMixin(start));
        continue;
      }
      if (_isKw('enum')) {
        classes.add(_parseEnum(start));
        continue;
      }
      if (_isKw('extension') && !_peek().isOp('(')) {
        extensions.add(_parseExtension(start));
        continue;
      }
      // Funksiya yoki o'zgaruvchi.
      if (_isKw('var') || _isKw('final') || _isKw('const') || _isKw('late')) {
        variables.add(_parseVarDecl());
        _expectSemicolon();
        continue;
      }
      final save = _p;
      var type = _tryType();
      if (type != null && !_isIdent()) {
        _p = save;
        type = null;
      }
      if (_isKw('get') && _isIdent(_peek())) {
        _advance();
        final nameTok = _advance();
        final body = _parseFunctionBody(semicolonAfterArrow: true);
        functions.add(FunctionDecl(nameTok.lexeme, type, const [], body, start.offset, _prev.end,
            isGetter: true, nameOffset: nameTok.offset));
        continue;
      }
      if (_isIdent() && (_peek().isOp('(') || _peek().isOp('<') && _isGenericFunctionAhead())) {
        functions.add(_parseFunctionRest(start, type));
        continue;
      }
      if (type != null && _isIdent()) {
        _p = save;
        variables.add(_parseVarDecl());
        _expectSemicolon();
        continue;
      }
      _p = save;
      if (_isIdent() && _peek().type == TokenType.punctuation && _peek().lexeme == '{') {
        _error('missing_function_parameters', "Funksiya nomidan keyin `()` qavslari bo'lishi kerak.",
            'Functions must have an explicit list of parameters.',
            at: _peek(), hint: 'Masalan: void ${_cur.lexeme}() { ... }');
      }
      _error('unexpected_top_level', "Bu yerda ${_describe(_cur)} kutilmagan. Fayl darajasida faqat import, funksiya, class, enum va o'zgaruvchi e'lon qilinadi.",
          'Expected a declaration, but got ${_cur.lexeme}.',
          hint: "Buyruqlarni `void main() { ... }` ichiga yozing.");
    }
    return Program(
      imports: imports,
      functions: functions,
      classes: classes,
      variables: variables,
      extensions: extensions,
    );
  }

  void _skipAnnotations() {
    while (_isOp('@')) {
      _advance();
      _expectIdent('annotatsiya nomi');
      while (_matchOp('.')) {
        _expectIdent();
      }
      if (_isOp('(')) _parseArguments();
    }
  }

  // ───────────────────────── Turlar ─────────────────────────

  /// Agar joriy joyda tur yozilgan bo'lsa o'qiydi, aks holda joyni tiklab null qaytaradi.
  TypeAnnotation? _tryType() {
    final save = _p;
    try {
      final t = _parseTypeOrNull();
      if (t == null) _p = save;
      return t;
    } on CompileError {
      _p = save;
      return null;
    }
  }

  TypeAnnotation? _parseTypeOrNull() {
    final start = _cur;
    if (_isKw('void')) {
      _advance();
      if (_isIdent() && _cur.lexeme == 'Function' && _peek().isOp('(')) {
        _advance();
        _skipBalanced();
        _matchOp('?');
        return TypeAnnotation('Function', offset: start.offset, end: _prev.end);
      }
      return TypeAnnotation('void', offset: start.offset, end: _prev.end);
    }
    if (_isOp('(')) {
      // Record turi: (int, String)
      final save = _p;
      _advance();
      final parts = <TypeAnnotation>[];
      if (!_isOp(')')) {
        do {
          if (_isOp('{')) return null;
          final t = _parseTypeOrNull();
          if (t == null) {
            _p = save;
            return null;
          }
          parts.add(t);
          if (_isIdent()) _advance();
        } while (_matchOp(','));
      }
      if (!_matchOp(')')) {
        _p = save;
        return null;
      }
      final nullable = _matchOp('?');
      return TypeAnnotation('Record', args: parts, nullable: nullable, offset: start.offset, end: _prev.end);
    }
    if (!_isIdent() && !_isKw('dynamic')) return null;
    var name = _advance().lexeme;
    if (_isOp('.') && _isIdent(_peek())) {
      // prefiks bilan: math.Random
      _advance();
      name = '$name.${_advance().lexeme}';
    }
    var args = <TypeAnnotation>[];
    if (_isOp('<')) {
      final save = _p;
      _advance();
      final list = <TypeAnnotation>[];
      while (true) {
        final t = _parseTypeOrNull();
        if (t == null) {
          _p = save;
          return null;
        }
        list.add(t);
        if (_matchOp(',')) continue;
        break;
      }
      if (!_consumeCloseAngle()) {
        _p = save;
        return null;
      }
      args = list;
    }
    if (name == 'Function' && _isOp('(')) {
      _skipBalanced();
    }
    var nullable = false;
    if (_isOp('?') && !_cur.precededByNewline) {
      // `a ? b : c` dan farqlash: tur bo'lsa ? dan keyin nom keladi.
      nullable = true;
      _advance();
    }
    final t = TypeAnnotation(name, args: args, nullable: nullable, offset: start.offset, end: _prev.end);
    if (_isIdent() && _cur.lexeme == 'Function' && _peek().isOp('(')) {
      _advance();
      _skipBalanced();
      _matchOp('?');
      return TypeAnnotation('Function', offset: start.offset, end: _prev.end);
    }
    return t;
  }

  void _skipBalanced() {
    final open = _cur.lexeme;
    final close = switch (open) { '(' => ')', '[' => ']', '{' => '}', _ => ')' };
    var depth = 0;
    do {
      if (_isOp(open)) depth++;
      if (_isOp(close)) depth--;
      _advance();
    } while (depth > 0 && !_atEnd);
  }

  /// `>`, `>>` yoki `>>>` ni yopuvchi burchak qavsi sifatida iste'mol qiladi.
  bool _consumeCloseAngle() {
    final t = _cur;
    if (t.isOp('>')) {
      _advance();
      return true;
    }
    if (t.type == TokenType.operator && t.lexeme.startsWith('>') && t.lexeme.length > 1) {
      final rest = t.lexeme.substring(1);
      _tokens[_p] = Token(TokenType.operator, rest, t.offset + 1, t.line, t.column + 1);
      return true;
    }
    return false;
  }

  TypeAnnotation _parseType() {
    final t = _parseTypeOrNull();
    if (t == null) {
      _error('expected_type', 'Tur (type) nomi kutilgan edi, lekin ${_describe(_cur)} topildi.', 'Expected a type name.');
    }
    return t;
  }

  /// Bu joyda `Tur nom` yoki `var nom` shaklidagi e'lon bormi?
  bool _looksLikeDeclaration() {
    if (_isKw('var') || _isKw('final') || _isKw('const') || _isKw('late')) return true;
    final save = _p;
    final type = _tryType();
    var result = false;
    if (type != null && _isIdent()) {
      final next = _peek();
      result = next.isOp('=') || next.isOp(';') || next.isOp(',') || next.isOp('(') || next.isKeyword('in') || next.isOp('<');
    }
    _p = save;
    return result;
  }

  // ───────────────────────── Funksiyalar ─────────────────────────

  /// `nom<T>(` — generic funksiya e'loni.
  bool _isGenericFunctionAhead() {
    var i = _p + 1;
    var depth = 0;
    while (i < _tokens.length) {
      final t = _tokens[i];
      if (t.isOp('<')) depth++;
      if (t.isOp('>')) depth--;
      if (t.isOp('>>')) depth -= 2;
      if (depth <= 0) return _tokens[i + 1].isOp('(');
      if (t.isOp(';') || t.isOp('{') || t.type == TokenType.eof) return false;
      i++;
    }
    return false;
  }

  FunctionDecl _parseFunctionRest(Token start, TypeAnnotation? returnType, {bool isStatic = false}) {
    final nameTok = _advance();
    final typeParams = _parseTypeParams();
    final params = _parseParams();
    final body = _parseFunctionBody(semicolonAfterArrow: true);
    return FunctionDecl(nameTok.lexeme, returnType, params, body, start.offset, _prev.end,
        isStatic: isStatic, isAsync: _lastBodyAsync, isGenerator: _lastBodyGenerator, nameOffset: nameTok.offset, typeParams: typeParams);
  }

  bool _lastBodyAsync = false;
  bool _lastBodyGenerator = false;

  FunctionBody? _parseFunctionBody({required bool semicolonAfterArrow, bool allowAbstract = false}) {
    _lastBodyAsync = false;
    _lastBodyGenerator = false;
    if (_isIdent() && (_cur.lexeme == 'async' || _cur.lexeme == 'sync')) {
      _lastBodyAsync = _cur.lexeme == 'async';
      final kw = _advance();
      _lastBodyGenerator = _matchOp('*');
      if (kw.lexeme == 'sync' && !_lastBodyGenerator) {
        _error('expected_star', "`sync` dan keyin `*` yozilishi kerak: `sync*`.", "Expected '*' after 'sync'.", at: kw);
      }
    }
    if (_matchOp('=>')) {
      if (_lastBodyGenerator) {
        _error('generator_arrow', "Generator funksiya (`sync*`/`async*`) `=>` bilan yozilmaydi — `{ yield ...; }` ishlating.",
            "Generators can't use '=>' to return a value.", at: _prev);
      }
      final isAsync = _lastBodyAsync, isGenerator = _lastBodyGenerator;
      final e = parseExpression();
      if (semicolonAfterArrow) _expectSemicolon();
      // Ichki lambda'lar bu maydonlarni o'zgartirgan bo'lishi mumkin — tiklaymiz.
      _lastBodyAsync = isAsync;
      _lastBodyGenerator = isGenerator;
      return FunctionBody.arrow(e);
    }
    if (_isOp('{')) {
      final isAsync = _lastBodyAsync, isGenerator = _lastBodyGenerator;
      final block = _parseBlock();
      _lastBodyAsync = isAsync;
      _lastBodyGenerator = isGenerator;
      return FunctionBody.block(block);
    }
    if (allowAbstract && _matchOp(';')) return null;
    _error('expected_function_body', "Funksiya tanasi kutilgan edi: `{ ... }` yoki `=> ifoda;`.",
        'A function body must be provided.',
        hint: "Masalan: void salom() { print('Salom'); }");
  }

  List<Param> _parseParams() {
    _expectOp('(', 'parametrlar ro\'yxati');
    final params = <Param>[];
    var mode = 0; // 0 = oddiy, 1 = [ixtiyoriy], 2 = {nomli}
    while (!_isOp(')')) {
      if (_matchOp('[')) {
        mode = 1;
        continue;
      }
      if (_matchOp('{')) {
        mode = 2;
        continue;
      }
      if (_matchOp(']') || _matchOp('}')) {
        mode = 0;
        if (_matchOp(',')) continue;
        continue;
      }
      _skipAnnotations();
      final pStart = _cur;
      var isRequired = false;
      if (_isKw('required')) {
        _advance();
        isRequired = true;
      }
      if (_isKw('final') || _isKw('var') || _isKw('covariant') || _isKw('const')) _advance();
      TypeAnnotation? type;
      var fieldFormal = false;
      var superFormal = false;
      if (!(_isKw('this') || _isKw('super'))) {
        final save = _p;
        type = _tryType();
        if (type != null && !(_isIdent() || _isKw('this') || _isKw('super'))) {
          _p = save;
          type = null;
        }
      }
      if (_isKw('this') && _peek().isOp('.')) {
        _advance();
        _advance();
        fieldFormal = true;
      } else if (_isKw('super') && _peek().isOp('.')) {
        _advance();
        _advance();
        superFormal = true;
      }
      final name = _expectIdent('parametr nomi');
      if (_isOp('(')) {
        // Funksiya turidagi parametr: void f(int x)
        _skipBalanced();
        type = TypeAnnotation('Function');
      }
      Expr? def;
      if (_matchOp('=') || (mode == 2 && _matchOp(':'))) {
        def = parseExpression();
      }
      params.add(Param(name, type, pStart.offset,
          isNamed: mode == 2,
          isRequired: mode == 0 || isRequired,
          isOptionalPositional: mode == 1,
          defaultValue: def,
          isFieldFormal: fieldFormal,
          isSuperFormal: superFormal));
      if (!_matchOp(',')) {
        if (_matchOp(']') || _matchOp('}')) {
          mode = 0;
          _matchOp(',');
        }
        break;
      }
    }
    _expectOp(')', 'parametrlar ro\'yxati oxiri');
    return params;
  }

  // ───────────────────────── Class / Enum / Mixin ─────────────────────────

  List<String> _parseTypeParams() {
    final out = <String>[];
    if (_matchOp('<')) {
      do {
        out.add(_expectIdent('tur parametri'));
        if (_matchKw('extends')) _parseType();
      } while (_matchOp(','));
      if (!_consumeCloseAngle()) _expectOp('>');
    }
    return out;
  }

  ClassDecl _parseClass(Token start, List<String> modifiers) {
    _advance(); // class
    final nameTok = _cur;
    final name = _expectIdent('class nomi');
    final typeParams = _parseTypeParams();
    TypeAnnotation? superclass;
    var interfaces = <TypeAnnotation>[];
    var mixins = <TypeAnnotation>[];
    if (_matchKw('extends')) superclass = _parseType();
    if (_matchKw('with')) mixins = _parseTypeList();
    if (_matchKw('implements')) interfaces = _parseTypeList();
    final members = _parseClassBody(name);
    return ClassDecl(name, start.offset, _prev.end,
        superclass: superclass,
        interfaces: interfaces,
        mixins: mixins,
        isAbstract: modifiers.contains('abstract') || modifiers.contains('sealed'),
        modifiers: modifiers,
        fields: members.fields,
        methods: members.methods,
        constructors: members.constructors,
        typeParams: typeParams,
        nameOffset: nameTok.offset);
  }

  ClassDecl _parseMixin(Token start) {
    _advance(); // mixin
    final nameTok = _cur;
    final name = _expectIdent('mixin nomi');
    _parseTypeParams();
    var interfaces = <TypeAnnotation>[];
    if (_matchKw('on')) interfaces = _parseTypeList();
    if (_matchKw('implements')) interfaces.addAll(_parseTypeList());
    final members = _parseClassBody(name);
    return ClassDecl(name, start.offset, _prev.end,
        kind: ClassKind.mixin,
        interfaces: interfaces,
        fields: members.fields,
        methods: members.methods,
        constructors: members.constructors,
        nameOffset: nameTok.offset);
  }

  ClassDecl _parseEnum(Token start) {
    _advance(); // enum
    final nameTok = _cur;
    final name = _expectIdent('enum nomi');
    var mixins = <TypeAnnotation>[];
    var interfaces = <TypeAnnotation>[];
    if (_matchKw('with')) mixins = _parseTypeList();
    if (_matchKw('implements')) interfaces = _parseTypeList();
    _expectOp('{', 'enum tanasi');
    final values = <EnumValueDecl>[];
    while (!_isOp('}') && !_isOp(';')) {
      _skipAnnotations();
      final vTok = _cur;
      final vName = _expectIdent('enum qiymati');
      Arguments? args;
      if (_isOp('(')) args = _parseArguments();
      values.add(EnumValueDecl(vName, args, vTok.offset));
      if (!_matchOp(',')) break;
    }
    var members = _ClassMembers();
    if (_matchOp(';')) {
      members = _parseClassMembersUntilBrace(name);
    }
    _expectOp('}', 'enum oxiri');
    return ClassDecl(name, start.offset, _prev.end,
        kind: ClassKind.enumDecl,
        mixins: mixins,
        interfaces: interfaces,
        fields: members.fields,
        methods: members.methods,
        constructors: members.constructors,
        enumValues: values,
        nameOffset: nameTok.offset);
  }

  ExtensionDecl _parseExtension(Token start) {
    _advance(); // extension
    String? name;
    if (_isIdent() && !_isKw('on')) name = _advance().lexeme;
    _parseTypeParams();
    if (!_matchKw('on')) {
      _error('expected_on', "extension'dan keyin `on Tur` yozilishi kerak.", "Expected 'on'.",
          hint: 'Masalan: extension Kvadrat on int { ... }');
    }
    final onType = _parseType();
    final members = _parseClassBody(name ?? '');
    return ExtensionDecl(name, onType, members.methods, start.offset, _prev.end);
  }

  List<TypeAnnotation> _parseTypeList() {
    final list = <TypeAnnotation>[_parseType()];
    while (_matchOp(',')) {
      list.add(_parseType());
    }
    return list;
  }

  _ClassMembers _parseClassBody(String className) {
    _expectOp('{', 'class tanasi');
    final m = _parseClassMembersUntilBrace(className);
    _expectOp('}', 'class oxiri');
    return m;
  }

  _ClassMembers _parseClassMembersUntilBrace(String className) {
    final m = _ClassMembers();
    while (!_isOp('}') && !_atEnd) {
      _skipAnnotations();
      if (_isOp('}')) break;
      final start = _cur;
      var isStatic = false;
      var isConst = false;
      var isFactory = false;
      while (true) {
        if (_isKw('static')) {
          isStatic = true;
          _advance();
        } else if (_isKw('external') || _isKw('covariant')) {
          _advance();
        } else if (_isKw('const') && (_peek().lexeme == className)) {
          isConst = true;
          _advance();
        } else if (_isKw('factory')) {
          isFactory = true;
          _advance();
        } else {
          break;
        }
      }
      // Konstruktor
      if (_cur.lexeme == className && _isIdent() && (_peek().isOp('(') || _peek().isOp('.'))) {
        m.constructors.add(_parseConstructor(start, className, isFactory: isFactory, isConst: isConst));
        continue;
      }
      if (_isKw('var') || _isKw('final') || _isKw('const') || _isKw('late')) {
        final decl = _parseVarDecl();
        _expectSemicolon();
        m.fields.add(FieldDecl(decl, isStatic: isStatic));
        continue;
      }
      final save = _p;
      var type = _tryType();
      if (type != null && !_isIdent() && !_isKw('get') && !_isKw('set') && !_isKw('operator')) {
        _p = save;
        type = null;
      }
      if (type != null && (type.name == 'get' || type.name == 'set' || type.name == 'operator') && _isIdent()) {
        // `get nom` — tur emas, getter.
        _p = save;
        type = null;
      }
      if (_isKw('get') && (_isIdent(_peek()) || _peek().type == TokenType.keyword)) {
        _advance();
        final nameTok = _advance();
        final body = _parseFunctionBody(semicolonAfterArrow: true, allowAbstract: true);
        m.methods.add(FunctionDecl(nameTok.lexeme, type, const [], body, start.offset, _prev.end,
            isGetter: true, isStatic: isStatic, nameOffset: nameTok.offset));
        continue;
      }
      if (_isKw('set') && _isIdent(_peek())) {
        _advance();
        final nameTok = _advance();
        final params = _parseParams();
        final body = _parseFunctionBody(semicolonAfterArrow: true, allowAbstract: true);
        m.methods.add(FunctionDecl(nameTok.lexeme, type, params, body, start.offset, _prev.end,
            isSetter: true, isStatic: isStatic, nameOffset: nameTok.offset));
        continue;
      }
      if (_isKw('operator')) {
        _advance();
        final opTok = _advance();
        var op = opTok.lexeme;
        if (op == '[' && _matchOp(']')) {
          op = '[]';
          if (_matchOp('=')) op = '[]=';
        }
        final params = _parseParams();
        final body = _parseFunctionBody(semicolonAfterArrow: true, allowAbstract: true);
        m.methods.add(FunctionDecl(op, type, params, body, start.offset, _prev.end,
            isOperator: true, nameOffset: opTok.offset));
        continue;
      }
      if (_isIdent() && (_peek().isOp('(') || _peek().isOp('<'))) {
        final nameTok = _advance();
        final typeParams = _parseTypeParams();
        final params = _parseParams();
        final body = _parseFunctionBody(semicolonAfterArrow: true, allowAbstract: true);
        m.methods.add(FunctionDecl(nameTok.lexeme, type, params, body, start.offset, _prev.end,
            isStatic: isStatic, isAsync: _lastBodyAsync, isGenerator: _lastBodyGenerator, nameOffset: nameTok.offset, typeParams: typeParams));
        continue;
      }
      if (type != null && _isIdent()) {
        _p = save;
        final decl = _parseVarDecl();
        _expectSemicolon();
        m.fields.add(FieldDecl(decl, isStatic: isStatic));
        continue;
      }
      _error('unexpected_class_member', "Class ichida ${_describe(_cur)} kutilmagan. Bu yerda maydon, konstruktor yoki metod e'lon qilinadi.",
          'Expected a class member, but got ${_cur.lexeme}.');
    }
    return m;
  }

  ConstructorDecl _parseConstructor(Token start, String className, {required bool isFactory, required bool isConst}) {
    _advance(); // class nomi
    String? name;
    if (_matchOp('.')) name = _expectIdent('konstruktor nomi');
    final params = _parseParams();
    final inits = <ConstructorInitializer>[];
    final asserts = <AssertStmt>[];
    Arguments? superCall;
    String? superName;
    Arguments? redirect;
    String? redirectName;
    if (_matchOp(':')) {
      do {
        final iStart = _cur;
        if (_isKw('super')) {
          _advance();
          if (_matchOp('.')) superName = _expectIdent();
          superCall = _parseArguments();
        } else if (_isKw('this') && (_peek().isOp('(') || _peek().isOp('.') && _peek(3).isOp('('))) {
          _advance();
          if (_matchOp('.')) redirectName = _expectIdent();
          redirect = _parseArguments();
        } else if (_isKw('assert')) {
          _advance();
          _expectOp('(');
          final cond = parseExpression();
          Expr? msg;
          if (_matchOp(',')) {
            if (!_isOp(')')) msg = parseExpression();
          }
          _expectOp(')');
          asserts.add(AssertStmt(cond, msg, iStart.offset, _prev.end));
        } else {
          if (_isKw('this')) {
            _advance();
            _expectOp('.');
          }
          final field = _expectIdent('maydon nomi');
          _expectOp('=');
          inits.add(ConstructorInitializer(field, _parseConditional()));
        }
      } while (_matchOp(','));
    }
    FunctionBody? body;
    if (isFactory && _isOp('=') && !_peek().isOp('>')) {
      // factory A() = B; — qo'llab-quvvatlanmaydi, lekin sintaksis xatosi emas.
      while (!_isOp(';')) {
        _advance();
      }
    }
    if (_matchOp(';')) {
      body = null;
    } else {
      body = _parseFunctionBody(semicolonAfterArrow: true);
    }
    return ConstructorDecl(className, name, params, start.offset, _prev.end,
        initializers: inits,
        superCall: superCall,
        superName: superName,
        redirect: redirect,
        redirectName: redirectName,
        body: body,
        isFactory: isFactory,
        isConst: isConst,
        asserts: asserts);
  }

  // ───────────────────────── Bayonotlar ─────────────────────────

  Block _parseBlock() {
    final open = _expectOp('{');
    final stmts = <Stmt>[];
    while (!_isOp('}')) {
      if (_atEnd) {
        _error('unclosed_block', "`{` qavs ${open.line}-qatorda ochilgan, lekin yopilmagan. Oxiriga `}` qo'ying.",
            "Expected to find '}'.", at: _cur,
            hint: "Har bir `{` uchun bitta `}` bo'lishi kerak. Qavslar sonini sanab chiqing.");
      }
      stmts.add(_parseStatement());
    }
    _advance();
    return Block(stmts, open.offset, _prev.end);
  }

  Stmt _parseStatement() {
    final start = _cur;
    _skipAnnotations();
    if (_isOp('{')) return _parseBlock();
    if (_matchOp(';')) return EmptyStmt(start.offset, start.end);
    if (_cur.type == TokenType.keyword) {
      switch (_cur.lexeme) {
        case 'if':
          return _parseIf();
        case 'for':
          return _parseFor();
        case 'while':
          _advance();
          _expectOp('(', 'while sharti');
          final cond = parseExpression();
          _expectOp(')', 'while sharti oxiri');
          final body = _parseStatement();
          return WhileStmt(cond, body, start.offset, _prev.end);
        case 'do':
          _advance();
          final body = _parseStatement();
          if (!_matchKw('while')) {
            _error('expected_while', "`do { ... }` dan keyin `while (shart);` yozilishi kerak.", "Expected 'while'.");
          }
          _expectOp('(');
          final cond = parseExpression();
          _expectOp(')');
          _expectSemicolon();
          return DoWhileStmt(body, cond, start.offset, _prev.end);
        case 'switch':
          if (_isSwitchExpressionAhead()) break;
          return _parseSwitch();
        case 'return':
          _advance();
          Expr? value;
          if (!_isOp(';')) value = parseExpression();
          _expectSemicolon();
          return ReturnStmt(value, start.offset, _prev.end);
        case 'break':
          _advance();
          String? label;
          if (_isIdent()) label = _advance().lexeme;
          _expectSemicolon();
          return BreakStmt(label, start.offset, _prev.end);
        case 'continue':
          _advance();
          String? label;
          if (_isIdent()) label = _advance().lexeme;
          _expectSemicolon();
          return ContinueStmt(label, start.offset, _prev.end);
        case 'yield':
          if (_peek().isOp('=') || _peek().isOp('.') || _peek().isOp(';')) break;
          _advance();
          final star = _matchOp('*');
          final value = parseExpression();
          _expectSemicolon();
          return YieldStmt(value, star, start.offset, _prev.end);
        case 'try':
          return _parseTry();
        case 'rethrow':
          _advance();
          _expectSemicolon();
          return RethrowStmt(start.offset, _prev.end);
        case 'assert':
          _advance();
          _expectOp('(');
          final cond = parseExpression();
          Expr? msg;
          if (_matchOp(',')) {
            if (!_isOp(')')) msg = parseExpression();
          }
          _expectOp(')');
          _expectSemicolon();
          return AssertStmt(cond, msg, start.offset, _prev.end);
        case 'else':
          _error('else_without_if', "`else` faqat `if` blokidan keyin keladi.", "Unexpected 'else'.",
              hint: "if blokining yopuvchi `}` qavsi va else orasida boshqa buyruq bo'lmasligi kerak.");
        case 'class':
          _error('class_in_function', "Class'ni funksiya ichida e'lon qilib bo'lmaydi. Uni `main()` dan tashqarida yozing.",
              "Classes can't be declared inside other declarations.");
      }
    }
    if (_isKw('await')) {
      // `await for (...)` yoki `await f();` — bu deklaratsiya emas.
      if (_peek().isKeyword('for')) {
        _advance();
        _advance();
        return _parseForHeader(start, _parseStatement, awaitFor: true);
      }
      final expr = parseExpression();
      if (!_isOp(';')) _missingSemicolon();
      _advance();
      return ExprStmt(expr, start.offset, _prev.end);
    }
    if (_isIdent() && _peek().isOp(':') && !_peek(2).isOp(':')) {
      final label = _advance().lexeme;
      _advance();
      final body = _parseStatement();
      return LabeledStmt(label, body, start.offset, _prev.end);
    }
    if (_looksLikeDeclaration()) {
      // Mahalliy funksiya yoki o'zgaruvchi.
      if (!(_isKw('var') || _isKw('final') || _isKw('const') || _isKw('late'))) {
        final save = _p;
        final type = _tryType();
        if (_isIdent() && (_peek().isOp('(') || _peek().isOp('<') && _isGenericFunctionAhead())) {
          final f = _parseFunctionRest(start, type);
          return LocalFunctionStmt(f);
        }
        _p = save;
      }
      final decl = _parseVarDecl();
      _expectSemicolon();
      return decl;
    }
    // Funksiya qaytarish turisiz e'lon qilingan mahalliy funksiya: nom() { ... }
    if (_isIdent() && _peek().isOp('(')) {
      final save = _p;
      _advance();
      final closeIdx = _findMatching(_p);
      if (closeIdx != null && _tokens[closeIdx + 1].isOp('{')) {
        _p = save;
        return LocalFunctionStmt(_parseFunctionRest(start, null));
      }
      _p = save;
    }
    final expr = parseExpression();
    if (!_isOp(';')) {
      if (_cur.type == TokenType.identifier && !_cur.precededByNewline && expr is Identifier) {
        _error('unknown_type_or_missing_op', "`${expr.name}` dan keyin ${_describe(_cur)} kutilmagan.",
            "Expected ';' after this.",
            at: _cur,
            hint: "Agar o'zgaruvchi e'lon qilmoqchi bo'lsangiz, tur nomini to'g'ri yozing (masalan `int`, `String`) — Dart katta-kichik harfni farqlaydi.");
      }
      _missingSemicolon();
    }
    _advance();
    return ExprStmt(expr, start.offset, _prev.end);
  }

  int? _findMatching(int openIdx) {
    var depth = 0;
    for (var i = openIdx; i < _tokens.length; i++) {
      final t = _tokens[i];
      if (t.isOp('(') || t.isOp('[') || t.isOp('{')) depth++;
      if (t.isOp(')') || t.isOp(']') || t.isOp('}')) {
        depth--;
        if (depth == 0) return i;
      }
      if (t.type == TokenType.eof) return null;
    }
    return null;
  }

  bool _isSwitchExpressionAhead() {
    // `switch (x) {` — tanadagi birinchi a'zo `case`/`default` bo'lsa — bayonot.
    final open = _findMatching(_p + 1);
    if (open == null) return false;
    final brace = open + 1;
    if (!_tokens[brace].isOp('{')) return false;
    final first = _tokens[brace + 1];
    return !(first.isKeyword('case') || first.isKeyword('default') || first.isOp('}'));
  }

  Stmt _parseIf() {
    final start = _advance();
    _expectOp('(', 'if sharti');
    final cond = parseExpression();
    _expectOp(')', 'if sharti oxiri');
    final then = _parseStatement();
    Stmt? otherwise;
    if (_matchKw('else')) otherwise = _parseStatement();
    return IfStmt(cond, then, otherwise, start.offset, _prev.end);
  }

  /// `for (...)` sarlavhasi. [body] null bo'lsa — collection-for uchun.
  Stmt _parseForHeader(Token start, Stmt Function() body, {bool awaitFor = false}) {
    final isAwait = awaitFor || _matchKw('await');
    _expectOp('(', 'for sarlavhasi');
    // for-in?
    final save = _p;
    var isFinal = false;
    var declares = false;
    TypeAnnotation? type;
    if (_isKw('var') || _isKw('final') || _isKw('const')) {
      isFinal = _cur.lexeme != 'var';
      declares = true;
      _advance();
    }
    if (_isIdent() && _peek().isKeyword('in')) {
      // var x in / x in
    } else {
      final t = _tryType();
      if (t != null && _isIdent() && _peek().isKeyword('in')) {
        type = t;
        declares = true;
      } else {
        _p = save;
        declares = false;
        isFinal = false;
      }
    }
    if (_isIdent() && _peek().isKeyword('in')) {
      final name = _advance().lexeme;
      _advance(); // in
      final iterable = parseExpression();
      _expectOp(')', 'for sarlavhasi oxiri');
      final b = body();
      return ForInStmt(name, type, declares, isFinal, iterable, b, start.offset, _prev.end, isAwait: isAwait);
    }
    if (isAwait) {
      _error('await_for_in', "`await for` faqat `for (x in oqim)` ko'rinishida yoziladi.",
          "Asynchronous for-in loops must use 'in'.");
    }
    _p = save;
    Stmt? init;
    if (!_isOp(';')) {
      if (_looksLikeDeclaration()) {
        init = _parseVarDecl();
      } else {
        final e = parseExpression();
        init = ExprStmt(e, e.offset, e.end);
      }
    }
    _expectSemicolon();
    Expr? cond;
    if (!_isOp(';')) cond = parseExpression();
    _expectSemicolon();
    final updates = <Expr>[];
    if (!_isOp(')')) {
      do {
        updates.add(parseExpression());
      } while (_matchOp(','));
    }
    _expectOp(')', 'for sarlavhasi oxiri');
    final b = body();
    return ForStmt(init, cond, updates, b, start.offset, _prev.end);
  }

  Stmt _parseFor() {
    final start = _advance();
    return _parseForHeader(start, _parseStatement);
  }

  Stmt _parseSwitch() {
    final start = _advance();
    _expectOp('(', 'switch qiymati');
    final subject = parseExpression();
    _expectOp(')');
    _expectOp('{', 'switch tanasi');
    final cases = <SwitchCase>[];
    var patterns = <Pattern>[];
    var guards = <Expr?>[];
    var isDefault = false;
    var caseStart = _cur.offset;
    while (!_isOp('}')) {
      if (_atEnd) _expectOp('}');
      if (_isKw('case')) {
        if (patterns.isEmpty && !isDefault) caseStart = _cur.offset;
        _advance();
        patterns.add(_parsePattern());
        guards.add(_matchKw('when') ? parseExpression() : null);
        _expectOp(':', 'case dan keyin');
        if (_isKw('case') || _isKw('default')) continue;
      } else if (_isKw('default')) {
        if (patterns.isEmpty) caseStart = _cur.offset;
        _advance();
        _expectOp(':', 'default dan keyin');
        isDefault = true;
        if (_isKw('case')) continue;
      } else {
        _error('expected_case', "switch ichida `case` yoki `default` kutilgan edi.", "Expected 'case' or 'default'.");
      }
      final body = <Stmt>[];
      while (!_isKw('case') && !_isKw('default') && !_isOp('}')) {
        if (_atEnd) _expectOp('}');
        body.add(_parseStatement());
      }
      cases.add(SwitchCase(patterns, guards, body, isDefault, caseStart));
      patterns = [];
      guards = [];
      isDefault = false;
    }
    _advance();
    return SwitchStmt(subject, cases, start.offset, _prev.end);
  }

  Stmt _parseTry() {
    final start = _advance();
    final body = _parseBlock();
    final catches = <CatchClause>[];
    while (_isKw('on') || _isKw('catch')) {
      TypeAnnotation? onType;
      String? exName;
      String? stName;
      if (_matchKw('on')) onType = _parseType();
      if (_matchKw('catch')) {
        _expectOp('(');
        exName = _expectIdent();
        if (_matchOp(',')) stName = _expectIdent();
        _expectOp(')');
      }
      catches.add(CatchClause(onType, exName, stName, _parseBlock()));
    }
    Block? fin;
    if (_matchKw('finally')) fin = _parseBlock();
    if (catches.isEmpty && fin == null) {
      _error('missing_catch', "`try` blokidan keyin `catch` yoki `finally` bo'lishi kerak.",
          "A try block must be followed by an 'on', 'catch', or 'finally' clause.");
    }
    return TryStmt(body, catches, fin, start.offset, _prev.end);
  }

  VarDecl _parseVarDecl() {
    final start = _cur;
    var isFinal = false, isConst = false, isLate = false, isVar = false;
    if (_matchKw('late')) isLate = true;
    if (_matchKw('final')) {
      isFinal = true;
    } else if (_matchKw('const')) {
      isConst = true;
    } else if (_matchKw('var')) {
      isVar = true;
    }
    TypeAnnotation? type;
    if (!(_isIdent() && (_peek().isOp('=') || _peek().isOp(';') || _peek().isOp(',') || _peek().isKeyword('in')))) {
      type = _parseType();
      if (isVar) {
        _error('var_and_type', "`var` va tur nomini birga yozib bo'lmaydi. Yoki `var x`, yoki `${type.name} x` deb yozing.",
            "Variables can't be declared using both 'var' and a type name.", at: start);
      }
    }
    if (!isVar && !isFinal && !isConst && !isLate && type == null) {
      _error('expected_type', 'Tur kutilgan edi.', 'Expected a type.');
    }
    final vars = <VarDeclarator>[];
    do {
      final nameTok = _cur;
      final name = _expectIdent("o'zgaruvchi nomi");
      Expr? init;
      if (_matchOp('=')) init = parseExpression();
      vars.add(VarDeclarator(name, init, nameTok.offset, _prev.end));
    } while (_matchOp(','));
    return VarDecl(type, vars, start.offset, _prev.end,
        isFinal: isFinal, isConst: isConst, isLate: isLate, isVar: isVar);
  }

  // ───────────────────────── Patternlar ─────────────────────────

  Pattern _parsePattern() {
    var left = _parseAndPattern();
    while (_matchOp('||')) {
      left = OrPattern(left, _parseAndPattern());
    }
    return left;
  }

  Pattern _parseAndPattern() {
    var left = _parsePrimaryPattern();
    while (_matchOp('&&')) {
      left = AndPattern(left, _parsePrimaryPattern());
    }
    return left;
  }

  Pattern _parsePrimaryPattern() {
    final start = _cur;
    if (_isIdent() && _cur.lexeme == '_' ) {
      _advance();
      return WildcardPattern(start.offset);
    }
    for (final op in const ['<=', '>=', '<', '>', '==', '!=']) {
      if (_isOp(op)) {
        _advance();
        return RelationalPattern(op, _parseShift(), start.offset);
      }
    }
    if (_isKw('var') || _isKw('final')) {
      _advance();
      TypeAnnotation? type;
      if (!(_isIdent() && (_peek().isOp(':') || _peek().isOp('=>') || _peek().isKeyword('when') || _peek().isOp(',') || _peek().isOp(')')))) {
        type = _parseType();
      }
      return BindingPattern(type, _expectIdent(), start.offset);
    }
    if (_isOp('(')) {
      _advance();
      final p = _parsePattern();
      _expectOp(')');
      return p;
    }
    // `int n` yoki `String _` yoki `int()`
    final save = _p;
    final type = _tryType();
    if (type != null && _isIdent()) {
      final name = _advance().lexeme;
      return BindingPattern(type, name == '_' ? null : name, start.offset);
    }
    if (type != null && _isOp('(') && _peek().isOp(')') && type.name[0].toUpperCase() == type.name[0]) {
      _advance();
      _advance();
      return BindingPattern(type, null, start.offset);
    }
    _p = save;
    return ConstPattern(_parseBitwiseOr());
  }

  // ───────────────────────── Ifodalar ─────────────────────────

  Expr parseExpression() {
    final start = _cur;
    var expr = _parseExpressionNoCascade();
    if (_isOp('..') || (_isOp('?') && _peek().isOp('..') && _peek().offset == _cur.end)) {
      final sections = <Expr>[];
      while (_isOp('..') || (_isOp('?') && _peek().isOp('..'))) {
        if (_isOp('?')) _advance();
        final dots = _advance();
        Expr section = CascadeTarget(dots.offset, dots.end);
        // birinchi selektor: ..nom yoki ..[i]
        if (_isOp('[')) {
          section = _parseSelectorsFrom(section, allowFirstIndex: true);
        } else {
          final nameTok = _cur;
          final name = _expectIdent();
          if (_isOp('(')) {
            final args = _parseArguments();
            section = MethodCall(section, name, args, false, dots.offset, _prev.end, nameTok.offset);
          } else {
            section = PropertyGet(section, name, false, dots.offset, _prev.end, nameTok.offset);
          }
          section = _parseSelectorsFrom(section);
        }
        if (_assignOps.contains(_cur.lexeme) && _cur.type == TokenType.operator) {
          final op = _advance().lexeme;
          final value = _parseExpressionNoCascade();
          section = AssignExpr(op, section, value, section.offset, _prev.end);
        }
        sections.add(section);
      }
      expr = CascadeExpr(expr, sections, start.offset, _prev.end);
    }
    return expr;
  }

  Expr _parseExpressionNoCascade() {
    if (_isKw('throw')) {
      final start = _advance();
      final value = parseExpression();
      return ThrowExpr(value, start.offset, _prev.end);
    }
    final start = _cur;
    final left = _parseConditional();
    if (_cur.type == TokenType.operator && _assignOps.contains(_cur.lexeme)) {
      final opTok = _advance();
      if (!(left is Identifier || left is PropertyGet || left is IndexExpr)) {
        _error('invalid_assignment_target', "Faqat o'zgaruvchiga, maydonga yoki ro'yxat elementiga qiymat berish mumkin.",
            'Missing selector such as \'.identifier\' or \'[0]\'.', at: opTok,
            hint: "Taqqoslash uchun `=` emas, `==` ishlatiladi.");
      }
      final value = _parseExpressionNoCascade();
      return AssignExpr(opTok.lexeme, left, value, start.offset, _prev.end);
    }
    return left;
  }

  Expr _parseConditional() {
    final start = _cur;
    final cond = _parseIfNull();
    if (_isOp('?')) {
      _advance();
      final then = _parseExpressionNoCascade();
      _expectOp(':', 'shartli ifoda (? :)');
      final otherwise = _parseExpressionNoCascade();
      return ConditionalExpr(cond, then, otherwise, start.offset, _prev.end);
    }
    return cond;
  }

  Expr _binaryLevel(Set<String> ops, Expr Function() next) {
    final start = _cur;
    var left = next();
    while (_cur.type == TokenType.operator && ops.contains(_cur.lexeme)) {
      final opTok = _advance();
      final right = next();
      left = BinaryExpr(opTok.lexeme, left, right, start.offset, _prev.end, opTok.offset);
    }
    return left;
  }

  Expr _parseIfNull() => _binaryLevel(const {'??'}, _parseLogicalOr);
  Expr _parseLogicalOr() => _binaryLevel(const {'||'}, _parseLogicalAnd);
  Expr _parseLogicalAnd() => _binaryLevel(const {'&&'}, _parseEquality);
  Expr _parseEquality() => _binaryLevel(const {'==', '!='}, _parseRelational);

  Expr _parseRelational() {
    final start = _cur;
    var left = _parseBitwiseOr();
    while (true) {
      if (_cur.type == TokenType.operator && const {'<', '>', '<=', '>='}.contains(_cur.lexeme)) {
        final opTok = _advance();
        final right = _parseBitwiseOr();
        left = BinaryExpr(opTok.lexeme, left, right, start.offset, _prev.end, opTok.offset);
      } else if (_isKw('is')) {
        _advance();
        final negated = _matchOp('!');
        final type = _parseType();
        left = IsExpr(left, type, negated, start.offset, _prev.end);
      } else if (_isKw('as')) {
        _advance();
        final type = _parseType();
        left = AsExpr(left, type, start.offset, _prev.end);
      } else {
        return left;
      }
    }
  }

  Expr _parseBitwiseOr() => _binaryLevel(const {'|'}, _parseBitwiseXor);
  Expr _parseBitwiseXor() => _binaryLevel(const {'^'}, _parseBitwiseAnd);
  Expr _parseBitwiseAnd() => _binaryLevel(const {'&'}, _parseShift);
  Expr _parseShift() => _binaryLevel(const {'<<', '>>', '>>>'}, _parseAdditive);
  Expr _parseAdditive() => _binaryLevel(const {'+', '-'}, _parseMultiplicative);
  Expr _parseMultiplicative() => _binaryLevel(const {'*', '/', '~/', '%'}, _parseUnary);

  Expr _parseUnary() {
    final start = _cur;
    if (_isOp('-') || _isOp('!') || _isOp('~')) {
      final op = _advance().lexeme;
      final operand = _parseUnary();
      if (op == '-' && operand is Literal && operand.value is int) {
        return Literal(-(operand.value as int), start.offset, _prev.end);
      }
      if (op == '-' && operand is Literal && operand.value is KDouble) {
        return Literal(KDouble(-(operand.value as KDouble).value), start.offset, _prev.end);
      }
      return UnaryExpr(op, operand, start.offset, _prev.end);
    }
    if (_isOp('++') || _isOp('--')) {
      final op = _advance().lexeme;
      final target = _parseUnary();
      return IncDecExpr(op, target, true, start.offset, _prev.end);
    }
    if (_isKw('await')) {
      _advance();
      final e = _parseUnary();
      return AwaitExpr(e, start.offset, _prev.end);
    }
    return _parsePostfix();
  }

  Expr _parsePostfix() {
    final primary = _parsePrimary();
    return _parseSelectorsFrom(primary);
  }

  Expr _parseSelectorsFrom(Expr expr, {bool allowFirstIndex = false}) {
    final startOffset = expr.offset;
    while (true) {
      if (_isOp('.') || _isOp('?.')) {
        final nullAware = _advance().lexeme == '?.';
        final nameTok = _cur;
        final String name;
        if (_isIdent() || _cur.type == TokenType.keyword) {
          name = _advance().lexeme;
        } else {
          _error('expected_member', "Nuqtadan keyin a'zo (maydon yoki metod) nomi kutilgan edi.",
              'Expected an identifier.');
        }
        var typeArgs = const <TypeAnnotation>[];
        if (_isOp('<')) typeArgs = _tryTypeArgsBeforeCall();
        if (_isOp('(')) {
          final args = _parseArguments();
          expr = MethodCall(expr, name, args, nullAware, startOffset, _prev.end, nameTok.offset, typeArgs: typeArgs);
        } else {
          expr = PropertyGet(expr, name, nullAware, startOffset, _prev.end, nameTok.offset);
        }
      } else if (_isOp('(')) {
        final args = _parseArguments();
        expr = CallExpr(expr, args, startOffset, _prev.end);
      } else if (_isOp('<') && expr is Identifier) {
        final save = _p;
        final isTypeName = expr.name.isNotEmpty && expr.name[0].toUpperCase() == expr.name[0] && expr.name[0] != '_';
        final ta = _tryTypeArgsBeforeCall(allowNamedConstructor: isTypeName);
        if (ta.isEmpty) {
          _p = save;
          return expr;
        }
        if (_matchOp('.')) {
          // `StreamController<int>.broadcast()`, `List<int>.filled(3, 0)`
          final nameTok = _advance();
          final args = _parseArguments();
          expr = MethodCall(expr, nameTok.lexeme, args, false, startOffset, _prev.end, nameTok.offset, typeArgs: ta);
          continue;
        }
        final args = _parseArguments();
        expr = CallExpr(expr, args, startOffset, _prev.end, typeArgs: ta);
      } else if (_isOp('[')) {
        _advance();
        final index = parseExpression();
        _expectOp(']');
        expr = IndexExpr(expr, index, false, startOffset, _prev.end);
      } else if (_isOp('?') && _peek().isOp('[') && _peek().offset == _cur.end) {
        _advance();
        _advance();
        final index = parseExpression();
        _expectOp(']');
        expr = IndexExpr(expr, index, true, startOffset, _prev.end);
      } else if (_isOp('!') && !_peek().isOp('=')) {
        _advance();
        expr = NullAssertExpr(expr, startOffset, _prev.end);
      } else if ((_isOp('++') || _isOp('--')) && !_cur.precededByNewline) {
        final op = _advance().lexeme;
        expr = IncDecExpr(op, expr, false, startOffset, _prev.end);
      } else {
        return expr;
      }
    }
  }

  /// `<int>(` ko'rinishidagi tur argumentlari; topilmasa bo'sh ro'yxat.
  List<TypeAnnotation> _tryTypeArgsBeforeCall({bool allowNamedConstructor = false}) {
    final save = _p;
    if (!_matchOp('<')) return const [];
    final list = <TypeAnnotation>[];
    while (true) {
      final t = _tryType();
      if (t == null) {
        _p = save;
        return const [];
      }
      list.add(t);
      if (!_matchOp(',')) break;
    }
    if (!_consumeCloseAngle() ||
        !(_isOp('(') || allowNamedConstructor && _isOp('.') && _peek().type == TokenType.identifier && _peek(2).isOp('('))) {
      _p = save;
      return const [];
    }
    return list;
  }

  Arguments _parseArguments() {
    _expectOp('(', 'argumentlar');
    final positional = <Expr>[];
    final named = <String, Expr>{};
    while (!_isOp(')')) {
      if (_atEnd) _expectOp(')');
      if (_isIdent() && _peek().isOp(':') || (_cur.type == TokenType.keyword && _peek().isOp(':'))) {
        final nameTok = _advance();
        _advance();
        if (named.containsKey(nameTok.lexeme)) {
          _error('duplicate_named_argument', "`${nameTok.lexeme}` nomli argument ikki marta berildi.",
              "The argument for the named parameter '${nameTok.lexeme}' was already specified.", at: nameTok);
        }
        named[nameTok.lexeme] = parseExpression();
      } else {
        positional.add(parseExpression());
      }
      if (!_matchOp(',')) break;
    }
    _expectOp(')', 'argumentlar oxiri');
    return Arguments(positional, named);
  }

  Expr _parsePrimary() {
    final t = _cur;
    switch (t.type) {
      case TokenType.intLiteral:
        _advance();
        final text = t.lexeme.replaceAll('_', '');
        final v = text.startsWith('0x') || text.startsWith('0X')
            ? int.tryParse(text.substring(2), radix: 16)
            : int.tryParse(text);
        if (v == null) {
          _error('integer_too_big', "Butun son juda katta: ${t.lexeme}.", 'The integer literal ${t.lexeme} can\'t be represented in 64 bits.', at: t);
        }
        return Literal(v, t.offset, t.end);
      case TokenType.doubleLiteral:
        _advance();
        return Literal(KDouble(double.parse(t.lexeme.replaceAll('_', ''))), t.offset, t.end);
      case TokenType.string:
        return _parseStrings();
      case TokenType.identifier:
        _advance();
        return Identifier(t.lexeme, t.offset, t.end);
      case TokenType.keyword:
        return _parseKeywordPrimary(t);
      case TokenType.punctuation:
      case TokenType.operator:
        return _parsePunctPrimary(t);
      case TokenType.eof:
        _error('unexpected_eof', "Kod tugab qoldi — ifoda kutilgan edi. Ehtimol qavs yoki qator yakunlanmagan.",
            'Expected an expression, but reached the end of the file.');
    }
  }

  Expr _parseKeywordPrimary(Token t) {
    switch (t.lexeme) {
      case 'true':
        _advance();
        return Literal(true, t.offset, t.end);
      case 'false':
        _advance();
        return Literal(false, t.offset, t.end);
      case 'null':
        _advance();
        return Literal(null, t.offset, t.end);
      case 'this':
        _advance();
        return ThisExpr(t.offset, t.end);
      case 'super':
        _advance();
        return SuperExpr(t.offset, t.end);
      case 'new':
        _advance();
        return _parsePrimary();
      case 'const':
        _advance();
        if (_isOp('[') || _isOp('{') || _isOp('<')) return _parseCollection(isConst: true);
        return _parsePrimary();
      case 'switch':
        return _parseSwitchExpr();
      case 'throw':
        return _parseExpressionNoCascade();
      case 'void':
        _error('unexpected_void', "`void` faqat funksiya qaytaradigan tur sifatida yoziladi.", "Expected an expression, but got 'void'.");
      default:
        if (contextualKeywords.contains(t.lexeme) || t.lexeme == 'dynamic') {
          _advance();
          return Identifier(t.lexeme, t.offset, t.end);
        }
        _error('unexpected_keyword', "`${t.lexeme}` kalit so'zi bu yerda kutilmagan.",
            "Expected an expression, but got '${t.lexeme}'.");
    }
  }

  Expr _parsePunctPrimary(Token t) {
    if (t.isOp('(')) {
      // Lambda yoki qavs ichidagi ifoda yoki record.
      final close = _findMatching(_p);
      if (close != null) {
        final after = _tokens[close + 1];
        var afterAsync = after.lexeme == 'async' || after.lexeme == 'sync' ? _tokens[close + 2] : after;
        if ((after.lexeme == 'async' || after.lexeme == 'sync') && afterAsync.isOp('*')) afterAsync = _tokens[close + 3];
        if (afterAsync.isOp('=>') || afterAsync.isOp('{')) {
          return _parseFunctionExpr();
        }
      }
      _advance();
      if (_isOp(')')) {
        _advance();
        return RecordLiteral(const [], const {}, t.offset, _prev.end);
      }
      final positional = <Expr>[];
      final named = <String, Expr>{};
      var isRecord = false;
      while (true) {
        if (_isIdent() && _peek().isOp(':')) {
          isRecord = true;
          final name = _advance().lexeme;
          _advance();
          named[name] = parseExpression();
        } else {
          positional.add(parseExpression());
        }
        if (_matchOp(',')) {
          isRecord = true;
          if (_isOp(')')) break;
          continue;
        }
        break;
      }
      _expectOp(')', 'qavs yopilishi');
      if (!isRecord) return positional.single;
      return RecordLiteral(positional, named, t.offset, _prev.end);
    }
    if (t.isOp('[') || t.isOp('{') || t.isOp('<')) return _parseCollection(isConst: false);
    if (t.isOp('#')) {
      _advance();
      final name = _expectIdent();
      return Literal('Symbol("$name")', t.offset, _prev.end);
    }
    if (t.isOp('=')) {
      _error('unexpected_equals', "Bu yerda `=` kutilmagan.", "Expected an expression, but got '='.",
          hint: "O'zgaruvchiga qiymat berish uchun avval uning nomini yozing: x = 5;");
    }
    _error('expected_expression', "Ifoda kutilgan edi, lekin ${_describe(t)} topildi.",
        "Expected an expression, but got '${t.lexeme}'.");
  }

  Expr _parseFunctionExpr() {
    final start = _cur;
    final params = _parseParams();
    final body = _parseFunctionBody(semicolonAfterArrow: false);
    return FunctionExpr(params, body!, start.offset, _prev.end, isAsync: _lastBodyAsync, isGenerator: _lastBodyGenerator);
  }

  Expr _parseSwitchExpr() {
    final start = _advance();
    _expectOp('(');
    final subject = parseExpression();
    _expectOp(')');
    _expectOp('{');
    final cases = <SwitchExprCase>[];
    while (!_isOp('}')) {
      if (_atEnd) _expectOp('}');
      final pattern = _isKw('default') ? WildcardPattern(_advance().offset) : _parsePattern();
      final guard = _matchKw('when') ? parseExpression() : null;
      _expectOp('=>', 'switch ifodasi');
      final body = parseExpression();
      cases.add(SwitchExprCase(pattern, guard, body));
      if (!_matchOp(',')) break;
    }
    _expectOp('}');
    return SwitchExpr(subject, cases, start.offset, _prev.end);
  }

  Expr _parseStrings() {
    final start = _cur;
    final parts = <Object>[];
    while (_cur.type == TokenType.string) {
      final tok = _advance();
      for (final part in tok.parts!) {
        if (part.isText) {
          parts.add(part.text!);
        } else {
          final sub = Parser._sub(source, lineMap, part.source!, part.offset);
          if (sub._atEnd) {
            _error('empty_interpolation', "`\${}` ichi bo'sh. Ichiga ifoda yozing, masalan `\${a + b}`.",
                'Expected an expression.', at: tok);
          }
          final e = sub.parseExpression();
          if (!sub._atEnd) {
            sub._error('expected_token', "Interpolatsiya ichidagi ifoda noto'g'ri.", "Expected to find '}'.");
          }
          parts.add(e);
        }
      }
    }
    if (parts.every((p) => p is String)) {
      return Literal(parts.cast<String>().join(), start.offset, _prev.end);
    }
    return StringInterp(parts, start.offset, _prev.end);
  }

  Expr _parseCollection({required bool isConst}) {
    final start = _cur;
    var typeArgs = <TypeAnnotation>[];
    if (_matchOp('<')) {
      typeArgs = [_parseType()];
      while (_matchOp(',')) {
        typeArgs.add(_parseType());
      }
      if (!_consumeCloseAngle()) _expectOp('>');
    }
    if (_matchOp('[')) {
      final elements = <CollectionElement>[];
      while (!_isOp(']')) {
        if (_atEnd) _expectOp(']');
        elements.add(_parseElement());
        if (!_matchOp(',')) break;
      }
      _expectOp(']', "ro'yxat oxiri");
      return ListLiteral(elements, typeArgs.isEmpty ? null : typeArgs.first, isConst, start.offset, _prev.end);
    }
    if (_matchOp('{')) {
      final elements = <CollectionElement>[];
      while (!_isOp('}')) {
        if (_atEnd) _expectOp('}');
        elements.add(_parseElement(allowMapEntry: true));
        if (!_matchOp(',')) break;
      }
      _expectOp('}', 'map/set oxiri');
      return SetOrMapLiteral(elements, typeArgs, isConst, start.offset, _prev.end);
    }
    _error('expected_collection', "`[` yoki `{` kutilgan edi.", "Expected '[' or '{'.");
  }

  CollectionElement _parseElement({bool allowMapEntry = false}) {
    final start = _cur;
    if (_isOp('...') || _isOp('...?')) {
      final nullAware = _advance().lexeme == '...?';
      return SpreadElement(parseExpression(), nullAware, start.offset);
    }
    if (_isKw('if')) {
      _advance();
      _expectOp('(');
      final cond = parseExpression();
      _expectOp(')');
      final then = _parseElement(allowMapEntry: allowMapEntry);
      CollectionElement? otherwise;
      if (_matchKw('else')) otherwise = _parseElement(allowMapEntry: allowMapEntry);
      return IfElement(cond, then, otherwise, start.offset);
    }
    if (_isKw('for')) {
      final forTok = _advance();
      late CollectionElement body;
      final loop = _parseForHeader(forTok, () {
        body = _parseElement(allowMapEntry: allowMapEntry);
        return EmptyStmt(_prev.offset, _prev.end);
      });
      return ForElement(loop, body, start.offset);
    }
    final e = parseExpression();
    if (allowMapEntry && _matchOp(':')) {
      return MapEntryElement(e, parseExpression());
    }
    return ExprElement(e);
  }
}

class _ClassMembers {
  final fields = <FieldDecl>[];
  final methods = <FunctionDecl>[];
  final constructors = <ConstructorDecl>[];
}
