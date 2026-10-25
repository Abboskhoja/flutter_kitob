import 'highlighter.dart';

/// Kodni Dart uslubida tartibga keltiradi: 2 bo'shliqli chekinish,
/// `case` tanalari uchun qo'shimcha chekinish, ortiqcha bo'sh qatorlar va qator
/// oxiridagi bo'shliqlarni olib tashlaydi.
///
/// To'liq `dart format` emas — lekin satrlar va izohlar ichini hech qachon
/// o'zgartirmaydi, shuning uchun kod ma'nosi saqlanadi.
String formatDart(String source) {
  final src = source.replaceAll('\r\n', '\n').replaceAll('\t', '  ');
  final tokens = highlightDart(src);
  final protected = List<bool>.filled(src.length + 1, false);
  for (final t in tokens) {
    if (t.kind == HighlightKind.string || t.kind == HighlightKind.comment || t.kind == HighlightKind.interpolation) {
      for (var i = t.start; i < t.end; i++) {
        protected[i] = true;
      }
    }
  }
  final lines = src.split('\n');
  final out = <String>[];
  var depth = 0;
  var offset = 0;
  var blankRun = 0;
  final caseLevels = <int>[];

  for (final raw in lines) {
    final lineStart = offset;
    offset += raw.length + 1;
    if (raw.isNotEmpty && _insideMultilineString(tokens, lineStart)) {
      out.add(raw.trimRight());
      continue;
    }
    final text = raw.trim();
    if (text.isEmpty) {
      blankRun++;
      if (blankRun == 1 && out.isNotEmpty && !out.last.trimRight().endsWith('{')) out.add('');
      continue;
    }
    blankRun = 0;

    var lineDepth = depth;
    for (var k = 0; k < text.length && '}])'.contains(text[k]); k++) {
      lineDepth--;
    }
    if (lineDepth < 0) lineDepth = 0;
    while (caseLevels.isNotEmpty && caseLevels.last > lineDepth) {
      caseLevels.removeLast();
    }
    final isCase = RegExp(r'^(case\b|default\s*:)').hasMatch(text);
    if (isCase && (caseLevels.isEmpty || caseLevels.last != lineDepth)) caseLevels.add(lineDepth);
    var indent = lineDepth + caseLevels.where((l) => l <= lineDepth).length;
    if (isCase) indent--;
    if (RegExp(r'^(\.\.|\.[a-zA-Z_]|\?\.|&&|\|\||\?\?)').hasMatch(text)) indent += 2;
    if ('}])'.contains(text[0]) && out.isNotEmpty && out.last.isEmpty) out.removeLast();
    out.add('${'  ' * indent}$text');

    for (var i = 0; i < raw.length; i++) {
      final abs = lineStart + i;
      if (protected[abs]) continue;
      final ch = raw[i];
      if (ch == '{' || ch == '[' || ch == '(') {
        depth++;
      } else if (ch == '}' || ch == ']' || ch == ')') {
        depth--;
      }
    }
    if (depth < 0) depth = 0;
  }
  while (out.isNotEmpty && out.last.isEmpty) {
    out.removeLast();
  }
  return '${out.join('\n')}\n';
}

bool _insideMultilineString(List<HighlightToken> tokens, int offset) {
  for (final t in tokens) {
    if (t.start >= offset) return false;
    if (t.end > offset && t.kind == HighlightKind.string) return true;
  }
  return false;
}
