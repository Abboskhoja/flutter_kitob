import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/tokens.dart';
import 'code_palette.dart';

const _pairs = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"'};
const _closers = {')', ']', '}'};

/// Rang beruvchi, xatolarni chizuvchi va qavslarni moslashtiruvchi controller.
class CodeEditingController extends TextEditingController {
  CodeEditingController({super.text});

  CodePalette palette = CodePalette.dark;
  double fontSize = 14;
  List<Diagnostic> _diagnostics = const [];
  String _search = '';
  int? _activeLine;

  List<Diagnostic> get diagnostics => _diagnostics;
  set diagnostics(List<Diagnostic> d) {
    _diagnostics = d;
    notifyListeners();
  }

  String get search => _search;
  set search(String s) {
    _search = s;
    notifyListeners();
  }

  /// Vizualizator uchun ajratilgan qator.
  int? get activeLine => _activeLine;
  set activeLine(int? l) {
    _activeLine = l;
    notifyListeners();
  }

  int get lineCount => '\n'.allMatches(text).length + 1;

  int get cursorLine {
    final o = selection.baseOffset.clamp(0, text.length);
    return '\n'.allMatches(text.substring(0, o)).length + 1;
  }

  int offsetOfLine(int line) {
    var l = 1, i = 0;
    while (l < line && i < text.length) {
      if (text.codeUnitAt(i) == 10) l++;
      i++;
    }
    return i;
  }

  void insert(String s, {int cursorBack = 0}) {
    final sel = selection.isValid ? selection : TextSelection.collapsed(offset: text.length);
    final newText = text.replaceRange(sel.start, sel.end, s);
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + s.length - cursorBack),
    );
  }

  void moveCursor(int delta) {
    final o = (selection.baseOffset + delta).clamp(0, text.length);
    selection = TextSelection.collapsed(offset: o);
  }

  /// Tanlangan qatorlarni 2 bo'shliqqa suradi yoki qaytaradi.
  void indentSelection({bool outdent = false}) {
    final sel = selection;
    if (!sel.isValid) return;
    final start = text.lastIndexOf('\n', (sel.start - 1).clamp(0, text.length)) + 1;
    final collapsed = sel.isCollapsed;
    if (collapsed && !outdent) {
      insert('  ');
      return;
    }
    var end = sel.end;
    final lines = text.substring(start, end).split('\n');
    var removedFirst = 0;
    final changed = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (outdent) {
        final n = l.startsWith('  ') ? 2 : (l.startsWith(' ') ? 1 : 0);
        if (i == 0) removedFirst = n;
        changed.add(l.substring(n));
      } else {
        changed.add('  $l');
      }
    }
    final replaced = changed.join('\n');
    final newText = text.replaceRange(start, end, replaced);
    value = TextEditingValue(
      text: newText,
      selection: collapsed
          ? TextSelection.collapsed(offset: (sel.start - removedFirst).clamp(start, newText.length))
          : TextSelection(baseOffset: start, extentOffset: start + replaced.length),
    );
  }

  void toggleComment() {
    final sel = selection;
    if (!sel.isValid) return;
    final start = text.lastIndexOf('\n', (sel.start - 1).clamp(0, text.length)) + 1;
    var end = text.indexOf('\n', sel.end);
    if (end < 0) end = text.length;
    final lines = text.substring(start, end).split('\n');
    final allCommented = lines.where((l) => l.trim().isNotEmpty).every((l) => l.trimLeft().startsWith('//'));
    final changed = [
      for (final l in lines)
        if (l.trim().isEmpty)
          l
        else if (allCommented)
          l.replaceFirst(RegExp(r'// ?'), '')
        else
          l.replaceFirstMapped(RegExp(r'^(\s*)'), (m) => '${m[1]}// '),
    ].join('\n');
    value = TextEditingValue(
      text: text.replaceRange(start, end, changed),
      selection: TextSelection.collapsed(offset: start + changed.length),
    );
  }

  int replaceAll(String find, String repl) {
    if (find.isEmpty) return 0;
    final n = find.allMatches(text).length;
    if (n == 0) return 0;
    value = TextEditingValue(text: text.replaceAll(find, repl), selection: const TextSelection.collapsed(offset: 0));
    return n;
  }

  /// Kursor yonidagi qavs va uning juftini topadi.
  (int, int)? _bracketPair(List<bool> protected) {
    final o = selection.baseOffset;
    if (!selection.isValid || !selection.isCollapsed) return null;
    for (final pos in [o - 1, o]) {
      if (pos < 0 || pos >= text.length || protected[pos]) continue;
      final c = text[pos];
      const open = '([{', close = ')]}';
      final oi = open.indexOf(c), ci = close.indexOf(c);
      if (oi >= 0) {
        var depth = 0;
        for (var i = pos; i < text.length; i++) {
          if (protected[i]) continue;
          if (text[i] == c) depth++;
          if (text[i] == close[oi]) {
            depth--;
            if (depth == 0) return (pos, i);
          }
        }
      } else if (ci >= 0) {
        var depth = 0;
        for (var i = pos; i >= 0; i--) {
          if (protected[i]) continue;
          if (text[i] == c) depth++;
          if (text[i] == open[ci]) {
            depth--;
            if (depth == 0) return (i, pos);
          }
        }
      }
    }
    return null;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final base = codeTextStyle(fontSize, palette.text);
    final src = text;
    if (src.isEmpty) return TextSpan(style: base, text: '');
    final composing = value.composing;
    if (withComposing && composing.isValid && !composing.isCollapsed) {
      // IME yozish paytida (masalan, telefon klaviaturasi taklifi) oddiy ko'rinish.
      return TextSpan(style: base, children: [
        TextSpan(text: composing.textBefore(src)),
        TextSpan(text: composing.textInside(src), style: const TextStyle(decoration: TextDecoration.underline)),
        TextSpan(text: composing.textAfter(src)),
      ]);
    }
    final tokens = highlightDart(src);
    final protected = List<bool>.filled(src.length + 1, false);
    final kindAt = List<HighlightKind>.filled(src.length + 1, HighlightKind.plain);
    final bounds = <int>{0, src.length};
    for (final t in tokens) {
      bounds..add(t.start)..add(t.end);
      for (var i = t.start; i < t.end && i < src.length; i++) {
        kindAt[i] = t.kind;
        if (t.kind == HighlightKind.string || t.kind == HighlightKind.comment) protected[i] = true;
      }
    }
    final errAt = List<int>.filled(src.length + 1, 0); // 0 yo'q, 1 ogohlantirish, 2 xato
    for (final d in _diagnostics) {
      final s = d.offset.clamp(0, src.length);
      var e = (d.offset + d.length).clamp(0, src.length);
      if (e <= s) e = (s + 1).clamp(0, src.length);
      bounds..add(s)..add(e);
      final level = d.isError ? 2 : 1;
      for (var i = s; i < e; i++) {
        if (errAt[i] < level) errAt[i] = level;
      }
    }
    final pair = _bracketPair(protected);
    if (pair != null) {
      bounds..add(pair.$1)..add(pair.$1 + 1)..add(pair.$2)..add(pair.$2 + 1);
    }
    final searchAt = List<bool>.filled(src.length + 1, false);
    if (_search.isNotEmpty) {
      for (final m in _search.allMatches(src)) {
        bounds..add(m.start)..add(m.end);
        for (var i = m.start; i < m.end; i++) {
          searchAt[i] = true;
        }
      }
    }
    final sorted = bounds.where((b) => b >= 0 && b <= src.length).toList()..sort();
    final children = <TextSpan>[];
    for (var b = 0; b < sorted.length - 1; b++) {
      final s = sorted[b], e = sorted[b + 1];
      if (s >= e) continue;
      final kind = kindAt[s];
      var st = TextStyle(color: colorForKind(palette, kind));
      if (kind == HighlightKind.comment) st = st.copyWith(fontStyle: FontStyle.italic);
      if (errAt[s] > 0) {
        st = st.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy,
          decorationColor: errAt[s] == 2 ? KColors.error : KColors.warning,
          decorationThickness: 1.6,
        );
      }
      if (pair != null && (s == pair.$1 || s == pair.$2)) {
        st = st.copyWith(backgroundColor: palette.bracketMatch, fontWeight: FontWeight.w700);
      }
      if (searchAt[s]) st = st.copyWith(backgroundColor: KColors.warning.withValues(alpha: 0.35));
      children.add(TextSpan(text: src.substring(s, e), style: st));
    }
    return TextSpan(style: base, children: children);
  }
}

/// Avtomatik chekinish va qavslarni yopish.
class CodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final o = oldValue.text, n = newValue.text;
    final os = oldValue.selection;
    if (!os.isValid || !newValue.selection.isValid || !newValue.selection.isCollapsed) return newValue;

    // Bitta belgi qo'shildi
    if (os.isCollapsed && n.length == o.length + 1 && newValue.selection.baseOffset == os.baseOffset + 1 &&
        n.substring(0, os.baseOffset) == o.substring(0, os.baseOffset)) {
      final pos = os.baseOffset;
      final ch = n[pos];
      final next = pos < o.length ? o[pos] : '';
      final prev = pos > 0 ? o[pos - 1] : '';

      if (ch == '\n') {
        final lineStart = o.lastIndexOf('\n', pos - 1) + 1;
        final line = o.substring(lineStart, pos);
        final indent = RegExp(r'^\s*').stringMatch(line) ?? '';
        final trimmed = line.trimRight();
        final opens = trimmed.endsWith('{') || trimmed.endsWith('(') || trimmed.endsWith('[');
        final extra = opens ? '  ' : '';
        if (opens && _closers.contains(next)) {
          final insert = '\n$indent$extra\n$indent';
          return _replace(o, pos, pos, insert, pos + 1 + indent.length + extra.length);
        }
        final insert = '\n$indent$extra';
        return _replace(o, pos, pos, insert, pos + insert.length);
      }

      if (_closers.contains(ch) && next == ch) {
        // Yopuvchi qavs allaqachon bor — ustidan o'tamiz.
        return TextEditingValue(text: o, selection: TextSelection.collapsed(offset: pos + 1));
      }

      if (ch == '}') {
        final lineStart = o.lastIndexOf('\n', pos - 1) + 1;
        final before = o.substring(lineStart, pos);
        if (before.trim().isEmpty && before.length >= 2) {
          final dedented = before.substring(2);
          return _replace(o, lineStart, pos, '$dedented}', lineStart + dedented.length + 1);
        }
      }

      if (ch == "'" || ch == '"') {
        if (next == ch) return TextEditingValue(text: o, selection: TextSelection.collapsed(offset: pos + 1));
        // So'z ichidagi apostrof (o'zbekcha "o'z") — juftlamaymiz.
        if (RegExp(r'[A-Za-z0-9]').hasMatch(prev)) return newValue;
        if (_inStringOrComment(o, pos)) return newValue;
      }

      final close = _pairs[ch];
      if (close != null && (next.isEmpty || RegExp(r'[\s\)\]\};,]').hasMatch(next))) {
        if ((ch == '(' || ch == '[' || ch == '{') && _inStringOrComment(o, pos)) return newValue;
        return _replace(o, pos, pos, '$ch$close', pos + 1);
      }
      return newValue;
    }

    // Bitta belgi o'chirildi (Backspace): bo'sh juftni birga o'chiramiz.
    if (os.isCollapsed && n.length == o.length - 1 && newValue.selection.baseOffset == os.baseOffset - 1) {
      final pos = os.baseOffset - 1;
      final deleted = o[pos];
      final close = _pairs[deleted];
      if (close != null && pos + 1 < o.length && o[pos + 1] == close) {
        return _replace(o, pos, pos + 2, '', pos);
      }
    }
    return newValue;
  }

  bool _inStringOrComment(String src, int pos) {
    for (final t in highlightDart(src)) {
      if (t.start < pos && pos < t.end && (t.kind == HighlightKind.string || t.kind == HighlightKind.comment)) return true;
      if (t.start >= pos) break;
    }
    return false;
  }

  TextEditingValue _replace(String src, int start, int end, String insert, int cursor) =>
      TextEditingValue(text: src.replaceRange(start, end, insert), selection: TextSelection.collapsed(offset: cursor));
}

const _dartWords = [
  'void', 'main', 'print', 'int', 'double', 'String', 'bool', 'var', 'final', 'const', 'dynamic', 'List', 'Map',
  'Set', 'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default', 'break', 'continue', 'return', 'class',
  'extends', 'implements', 'with', 'abstract', 'enum', 'mixin', 'extension', 'this', 'super', 'new', 'null', 'true',
  'false', 'try', 'catch', 'finally', 'throw', 'on', 'required', 'late', 'static', 'import', 'Object', 'num',
  'Iterable', 'Function', 'override', 'async', 'await', 'Future', 'StringBuffer', 'stdin', 'readLineSync',
];

const _memberWords = [
  'length', 'isEmpty', 'isNotEmpty', 'toString', 'toUpperCase', 'toLowerCase', 'contains', 'substring', 'split',
  'trim', 'replaceAll', 'startsWith', 'endsWith', 'indexOf', 'add', 'addAll', 'remove', 'removeAt', 'insert',
  'clear', 'first', 'last', 'map', 'where', 'forEach', 'reduce', 'fold', 'join', 'toList', 'toSet', 'sort', 'any',
  'every', 'keys', 'values', 'entries', 'containsKey', 'putIfAbsent', 'round', 'floor', 'ceil', 'toInt', 'toDouble',
  'toStringAsFixed', 'abs', 'isEven', 'isOdd', 'parse', 'tryParse', 'reversed', 'padLeft', 'sublist',
];

/// Kursor oldidagi so'z uchun avtoto'ldirish takliflari.
(String prefix, List<String> suggestions) completionsFor(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return ('', const []);
  var i = cursor;
  while (i > 0 && RegExp(r'[A-Za-z0-9_]').hasMatch(text[i - 1])) {
    i--;
  }
  final prefix = text.substring(i, cursor);
  if (prefix.isEmpty) return ('', const []);
  final afterDot = i > 0 && text[i - 1] == '.';
  final ids = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(text).map((m) => m[0]!).toSet();
  final pool = <String>{...(afterDot ? _memberWords : _dartWords), ...ids};
  final lower = prefix.toLowerCase();
  final out = pool.where((w) => w != prefix && w.toLowerCase().startsWith(lower)).toList()
    ..sort((a, b) {
      final ai = a.startsWith(prefix) ? 0 : 1, bi = b.startsWith(prefix) ? 0 : 1;
      if (ai != bi) return ai - bi;
      return a.length.compareTo(b.length);
    });
  return (prefix, out.take(8).toList());
}
