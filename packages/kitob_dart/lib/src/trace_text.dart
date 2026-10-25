part of 'interpreter.dart';

extension _TraceText on Interpreter {
  String _declDescription(VarDecl s, VarDeclarator v, Object? value) {
    final kind = s.isConst
        ? "const (kompilyatsiya vaqtidagi o'zgarmas)"
        : s.isFinal
            ? "final (bir marta beriladigan)"
            : "o'zgaruvchi";
    final type = s.type?.toString() ?? typeName(value);
    final init = v.init;
    final computed = init != null && init is! Literal;
    final expr = computed ? " (`${_src(init)}` hisoblandi)" : '';
    return "`${v.name}` nomli $kind yaratildi, turi `$type`, qiymati ${_preview(value)}$expr.";
  }
}
