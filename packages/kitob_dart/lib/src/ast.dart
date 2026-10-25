// Dart kodining sintaksis daraxti (AST). Har bir tugun manba koddagi joyini
// biladi — xatolarni ko'rsatish va qadam-baqadam vizualizatsiya uchun.

abstract class Node {
  Node(this.offset, this.end);
  final int offset;
  final int end;
}

class TypeAnnotation {
  TypeAnnotation(this.name, {this.args = const [], this.nullable = false, this.offset = 0, this.end = 0});
  final String name;
  final List<TypeAnnotation> args;
  final bool nullable;
  final int offset;
  final int end;

  bool get isDynamic => name == 'dynamic';

  @override
  String toString() =>
      '$name${args.isEmpty ? '' : '<${args.join(', ')}>'}${nullable ? '?' : ''}';
}

// ───────────────────────── Ifodalar (Expressions) ─────────────────────────

sealed class Expr extends Node {
  Expr(super.offset, super.end);
}

class Literal extends Expr {
  Literal(this.value, super.offset, super.end);
  final Object? value;
}

class StringInterp extends Expr {
  StringInterp(this.parts, super.offset, super.end);

  /// `String` yoki `Expr`.
  final List<Object> parts;
}

class Identifier extends Expr {
  Identifier(this.name, super.offset, super.end);
  final String name;
}

class ThisExpr extends Expr {
  ThisExpr(super.offset, super.end);
}

class SuperExpr extends Expr {
  SuperExpr(super.offset, super.end);
}

sealed class CollectionElement {
  CollectionElement(this.offset);
  final int offset;
}

class ExprElement extends CollectionElement {
  ExprElement(this.expr) : super(expr.offset);
  final Expr expr;
}

class MapEntryElement extends CollectionElement {
  MapEntryElement(this.key, this.value) : super(key.offset);
  final Expr key;
  final Expr value;
}

class SpreadElement extends CollectionElement {
  SpreadElement(this.expr, this.nullAware, super.offset);
  final Expr expr;
  final bool nullAware;
}

class IfElement extends CollectionElement {
  IfElement(this.condition, this.then, this.otherwise, super.offset);
  final Expr condition;
  final CollectionElement then;
  final CollectionElement? otherwise;
}

class ForElement extends CollectionElement {
  ForElement(this.loop, this.body, super.offset);

  /// [ForStmt] yoki [ForInStmt] ning sarlavha qismi (tanasi bo'sh).
  final Stmt loop;
  final CollectionElement body;
}

class ListLiteral extends Expr {
  ListLiteral(this.elements, this.typeArg, this.isConst, super.offset, super.end);
  final List<CollectionElement> elements;
  final TypeAnnotation? typeArg;
  final bool isConst;
}

/// `{...}` — map yoki set. Elementlarga qarab aniqlanadi.
class SetOrMapLiteral extends Expr {
  SetOrMapLiteral(this.elements, this.typeArgs, this.isConst, super.offset, super.end);
  final List<CollectionElement> elements;
  final List<TypeAnnotation> typeArgs;
  final bool isConst;

  bool get isMap {
    if (typeArgs.length == 2) return true;
    if (typeArgs.length == 1) return false;
    if (elements.isEmpty) return true;
    bool check(CollectionElement e) => switch (e) {
      MapEntryElement() => true,
      IfElement(:final then) => check(then),
      ForElement(:final body) => check(body),
      _ => false,
    };
    return elements.any(check);
  }
}

class RecordLiteral extends Expr {
  RecordLiteral(this.positional, this.named, super.offset, super.end);
  final List<Expr> positional;
  final Map<String, Expr> named;
}

class UnaryExpr extends Expr {
  UnaryExpr(this.op, this.operand, super.offset, super.end);
  final String op;
  final Expr operand;
}

class IncDecExpr extends Expr {
  IncDecExpr(this.op, this.target, this.prefix, super.offset, super.end);
  final String op;
  final Expr target;
  final bool prefix;
}

class BinaryExpr extends Expr {
  BinaryExpr(this.op, this.left, this.right, super.offset, super.end, this.opOffset);
  final String op;
  final Expr left;
  final Expr right;
  final int opOffset;
}

class ConditionalExpr extends Expr {
  ConditionalExpr(this.condition, this.then, this.otherwise, super.offset, super.end);
  final Expr condition;
  final Expr then;
  final Expr otherwise;
}

class AssignExpr extends Expr {
  AssignExpr(this.op, this.target, this.value, super.offset, super.end);

  /// `=`, `+=`, `??=` ...
  final String op;
  final Expr target;
  final Expr value;
}

class PropertyGet extends Expr {
  PropertyGet(this.target, this.name, this.nullAware, super.offset, super.end, this.nameOffset);
  final Expr target;
  final String name;
  final bool nullAware;
  final int nameOffset;
}

class IndexExpr extends Expr {
  IndexExpr(this.target, this.index, this.nullAware, super.offset, super.end);
  final Expr target;
  final Expr index;
  final bool nullAware;
}

class Arguments {
  Arguments(this.positional, this.named);
  final List<Expr> positional;
  final Map<String, Expr> named;
  static final empty = Arguments(const [], const {});
}

class CallExpr extends Expr {
  CallExpr(this.callee, this.args, super.offset, super.end, {this.typeArgs = const []});
  final Expr callee;
  final Arguments args;
  final List<TypeAnnotation> typeArgs;
}

class MethodCall extends Expr {
  MethodCall(this.target, this.name, this.args, this.nullAware, super.offset, super.end, this.nameOffset,
      {this.typeArgs = const []});
  final Expr target;
  final String name;
  final Arguments args;
  final bool nullAware;
  final int nameOffset;
  final List<TypeAnnotation> typeArgs;
}

class CascadeExpr extends Expr {
  CascadeExpr(this.target, this.sections, super.offset, super.end);
  final Expr target;

  /// Har biri [CascadeTarget] ga nisbatan yozilgan ifoda.
  final List<Expr> sections;
}

/// Kaskad (`..`) ichida joriy obyektni bildiradi.
class CascadeTarget extends Expr {
  CascadeTarget(super.offset, super.end);
}

class FunctionExpr extends Expr {
  FunctionExpr(this.params, this.body, super.offset, super.end, {this.isAsync = false, this.isGenerator = false});
  final List<Param> params;
  final FunctionBody body;
  final bool isAsync;

  /// `sync*` yoki `async*`.
  final bool isGenerator;
}

class IsExpr extends Expr {
  IsExpr(this.expr, this.type, this.negated, super.offset, super.end);
  final Expr expr;
  final TypeAnnotation type;
  final bool negated;
}

class AsExpr extends Expr {
  AsExpr(this.expr, this.type, super.offset, super.end);
  final Expr expr;
  final TypeAnnotation type;
}

class NullAssertExpr extends Expr {
  NullAssertExpr(this.expr, super.offset, super.end);
  final Expr expr;
}

class ThrowExpr extends Expr {
  ThrowExpr(this.expr, super.offset, super.end);
  final Expr expr;
}

class AwaitExpr extends Expr {
  AwaitExpr(this.expr, super.offset, super.end);
  final Expr expr;
}

class SwitchExprCase {
  SwitchExprCase(this.pattern, this.guard, this.body);
  final Pattern pattern;
  final Expr? guard;
  final Expr body;
}

class SwitchExpr extends Expr {
  SwitchExpr(this.subject, this.cases, super.offset, super.end);
  final Expr subject;
  final List<SwitchExprCase> cases;
}

// ───────────────────────── Patternlar ─────────────────────────

sealed class Pattern {
  Pattern(this.offset);
  final int offset;
}

class ConstPattern extends Pattern {
  ConstPattern(this.expr) : super(expr.offset);
  final Expr expr;
}

class WildcardPattern extends Pattern {
  WildcardPattern(super.offset);
}

class RelationalPattern extends Pattern {
  RelationalPattern(this.op, this.expr, super.offset);
  final String op;
  final Expr expr;
}

class OrPattern extends Pattern {
  OrPattern(this.left, this.right) : super(left.offset);
  final Pattern left;
  final Pattern right;
}

class AndPattern extends Pattern {
  AndPattern(this.left, this.right) : super(left.offset);
  final Pattern left;
  final Pattern right;
}

/// `int n`, `String s`, `var x`, `final y` yoki `int _`.
class BindingPattern extends Pattern {
  BindingPattern(this.type, this.name, super.offset);
  final TypeAnnotation? type;
  final String? name;
}

// ───────────────────────── Bayonotlar (Statements) ─────────────────────────

sealed class Stmt extends Node {
  Stmt(super.offset, super.end);
}

class Block extends Stmt {
  Block(this.statements, super.offset, super.end);
  final List<Stmt> statements;
}

class VarDeclarator {
  VarDeclarator(this.name, this.init, this.offset, this.end);
  final String name;
  final Expr? init;
  final int offset;
  final int end;
}

class VarDecl extends Stmt {
  VarDecl(this.type, this.vars, super.offset, super.end,
      {this.isFinal = false, this.isConst = false, this.isLate = false, this.isVar = false});
  final TypeAnnotation? type;
  final List<VarDeclarator> vars;
  final bool isFinal;
  final bool isConst;
  final bool isLate;
  final bool isVar;
}

class ExprStmt extends Stmt {
  ExprStmt(this.expr, super.offset, super.end);
  final Expr expr;
}

class IfStmt extends Stmt {
  IfStmt(this.condition, this.then, this.otherwise, super.offset, super.end);
  final Expr condition;
  final Stmt then;
  final Stmt? otherwise;
}

class ForStmt extends Stmt {
  ForStmt(this.init, this.condition, this.updates, this.body, super.offset, super.end);

  /// [VarDecl] yoki [ExprStmt] yoki null.
  final Stmt? init;
  final Expr? condition;
  final List<Expr> updates;
  final Stmt body;
}

class ForInStmt extends Stmt {
  ForInStmt(this.name, this.type, this.declares, this.isFinal, this.iterable, this.body, super.offset, super.end,
      {this.isAwait = false});
  final String name;

  /// `await for (x in stream)`.
  final bool isAwait;
  final TypeAnnotation? type;
  final bool declares;
  final bool isFinal;
  final Expr iterable;
  final Stmt body;
}

class WhileStmt extends Stmt {
  WhileStmt(this.condition, this.body, super.offset, super.end);
  final Expr condition;
  final Stmt body;
}

class DoWhileStmt extends Stmt {
  DoWhileStmt(this.body, this.condition, super.offset, super.end);
  final Stmt body;
  final Expr condition;
}

class BreakStmt extends Stmt {
  BreakStmt(this.label, super.offset, super.end);
  final String? label;
}

class ContinueStmt extends Stmt {
  ContinueStmt(this.label, super.offset, super.end);
  final String? label;
}

/// `yield x;` yoki `yield* oqim;` (generator funksiyalarda).
class YieldStmt extends Stmt {
  YieldStmt(this.value, this.isStar, super.offset, super.end);
  final Expr value;
  final bool isStar;
}

class ReturnStmt extends Stmt {
  ReturnStmt(this.value, super.offset, super.end);
  final Expr? value;
}

class SwitchCase {
  SwitchCase(this.patterns, this.guards, this.body, this.isDefault, this.offset);
  final List<Pattern> patterns;
  final List<Expr?> guards;
  final List<Stmt> body;
  final bool isDefault;
  final int offset;
}

class SwitchStmt extends Stmt {
  SwitchStmt(this.subject, this.cases, super.offset, super.end);
  final Expr subject;
  final List<SwitchCase> cases;
}

class CatchClause {
  CatchClause(this.onType, this.exceptionName, this.stackName, this.body);
  final TypeAnnotation? onType;
  final String? exceptionName;
  final String? stackName;
  final Block body;
}

class TryStmt extends Stmt {
  TryStmt(this.body, this.catches, this.finallyBlock, super.offset, super.end);
  final Block body;
  final List<CatchClause> catches;
  final Block? finallyBlock;
}

class RethrowStmt extends Stmt {
  RethrowStmt(super.offset, super.end);
}

class AssertStmt extends Stmt {
  AssertStmt(this.condition, this.message, super.offset, super.end);
  final Expr condition;
  final Expr? message;
}

class LocalFunctionStmt extends Stmt {
  LocalFunctionStmt(this.function) : super(function.offset, function.end);
  final FunctionDecl function;
}

class LabeledStmt extends Stmt {
  LabeledStmt(this.label, this.body, super.offset, super.end);
  final String label;
  final Stmt body;
}

class EmptyStmt extends Stmt {
  EmptyStmt(super.offset, super.end);
}

// ───────────────────────── E'lonlar (Declarations) ─────────────────────────

class Param {
  Param(this.name, this.type, this.offset,
      {this.isNamed = false,
      this.isRequired = false,
      this.isOptionalPositional = false,
      this.defaultValue,
      this.isFieldFormal = false,
      this.isSuperFormal = false});
  final String name;
  final TypeAnnotation? type;
  final bool isNamed;
  final bool isRequired;
  final bool isOptionalPositional;
  final Expr? defaultValue;
  final bool isFieldFormal;
  final bool isSuperFormal;
  final int offset;
}

class FunctionBody {
  FunctionBody.block(Block this.block) : expr = null;
  FunctionBody.arrow(Expr this.expr) : block = null;
  final Block? block;
  final Expr? expr;
}

class FunctionDecl extends Node {
  FunctionDecl(this.name, this.returnType, this.params, this.body, super.offset, super.end,
      {this.isGetter = false,
      this.isSetter = false,
      this.isStatic = false,
      this.isOperator = false,
      this.isAsync = false,
      this.isGenerator = false,
      this.nameOffset = 0,
      this.typeParams = const []});
  final String name;
  final List<String> typeParams;
  final TypeAnnotation? returnType;
  final List<Param> params;

  /// Abstrakt metodlar uchun null.
  final FunctionBody? body;
  final bool isGetter;
  final bool isSetter;
  final bool isStatic;
  final bool isOperator;
  final bool isAsync;

  /// `sync*` yoki `async*`.
  final bool isGenerator;
  final int nameOffset;
}

class FieldDecl {
  FieldDecl(this.decl, {this.isStatic = false});
  final VarDecl decl;
  final bool isStatic;
}

class ConstructorInitializer {
  ConstructorInitializer(this.field, this.value);
  final String field;
  final Expr value;
}

class ConstructorDecl extends Node {
  ConstructorDecl(this.className, this.name, this.params, super.offset, super.end,
      {this.initializers = const [],
      this.superCall,
      this.superName,
      this.redirect,
      this.redirectName,
      this.body,
      this.isFactory = false,
      this.isConst = false,
      this.asserts = const []});
  final String className;
  final String? name;
  final List<Param> params;
  final List<ConstructorInitializer> initializers;
  final Arguments? superCall;
  final String? superName;
  final Arguments? redirect;
  final String? redirectName;
  final FunctionBody? body;
  final bool isFactory;
  final bool isConst;
  final List<AssertStmt> asserts;
}

enum ClassKind { classDecl, mixin, enumDecl }

class ClassDecl extends Node {
  ClassDecl(this.name, super.offset, super.end,
      {this.superclass,
      this.interfaces = const [],
      this.mixins = const [],
      this.isAbstract = false,
      this.modifiers = const [],
      this.kind = ClassKind.classDecl,
      required this.fields,
      required this.methods,
      required this.constructors,
      this.enumValues = const [],
      this.typeParams = const [],
      this.nameOffset = 0});
  final String name;
  final TypeAnnotation? superclass;
  final List<TypeAnnotation> interfaces;
  final List<TypeAnnotation> mixins;
  final bool isAbstract;

  /// `sealed`, `final`, `base`, `interface`.
  final List<String> modifiers;
  final ClassKind kind;
  final List<FieldDecl> fields;
  final List<FunctionDecl> methods;
  final List<ConstructorDecl> constructors;
  final List<EnumValueDecl> enumValues;
  final List<String> typeParams;
  final int nameOffset;
}

class EnumValueDecl {
  EnumValueDecl(this.name, this.args, this.offset);
  final String name;
  final Arguments? args;
  final int offset;
}

class ExtensionDecl extends Node {
  ExtensionDecl(this.name, this.onType, this.methods, super.offset, super.end);
  final String? name;
  final TypeAnnotation onType;
  final List<FunctionDecl> methods;
}

class ImportDecl extends Node {
  ImportDecl(this.uri, super.offset, super.end, {this.prefix, this.uriOffset = 0, this.uriEnd = 0});
  final String uri;
  final String? prefix;
  final int uriOffset;
  final int uriEnd;
}

class Program {
  Program({
    required this.imports,
    required this.functions,
    required this.classes,
    required this.variables,
    required this.extensions,
  });
  final List<ImportDecl> imports;
  final List<FunctionDecl> functions;
  final List<ClassDecl> classes;
  final List<VarDecl> variables;
  final List<ExtensionDecl> extensions;
}
