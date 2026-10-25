import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';
import 'code_palette.dart';

class _Range {
  _Range(this.start, this.end, this.key);
  final int start;
  final int end;
  final String key;
}

bool _isWordChar(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);

/// [explain] kalitlarining koddagi joylarini topadi (uzunroq kalitlar ustun).
List<_Range> _explainRanges(String code, Map<String, String> explain) {
  final keys = explain.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
  final taken = List<bool>.filled(code.length, false);
  final out = <_Range>[];
  for (final key in keys) {
    if (key.isEmpty) continue;
    var from = 0;
    while (true) {
      final i = code.indexOf(key, from);
      if (i < 0) break;
      from = i + 1;
      final end = i + key.length;
      final wordKey = _isWordChar(key[0]) && _isWordChar(key[key.length - 1]);
      if (wordKey) {
        if (i > 0 && _isWordChar(code[i - 1])) continue;
        if (end < code.length && _isWordChar(code[end])) continue;
      }
      var free = true;
      for (var k = i; k < end; k++) {
        if (taken[k]) {
          free = false;
          break;
        }
      }
      if (!free) continue;
      for (var k = i; k < end; k++) {
        taken[k] = true;
      }
      out.add(_Range(i, end, key));
    }
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

/// Faqat o'qish uchun rangli kod. Izohli tokenlarni bosish mumkin.
class CodeView extends ConsumerStatefulWidget {
  const CodeView({
    super.key,
    required this.code,
    this.explain = const {},
    this.highlightLine,
    this.highlightRange,
    this.showLineNumbers = true,
    this.fontSize,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.lineMarkers = const {},
    this.dimmed = false,
  });

  final String code;
  final Map<String, String> explain;
  final int? highlightLine;

  /// (offset, length) — trace qadamidagi ifoda.
  final (int, int)? highlightRange;
  final bool showLineNumbers;
  final double? fontSize;
  final EdgeInsets padding;
  final Map<int, Color> lineMarkers;
  final bool dimmed;

  @override
  ConsumerState<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends ConsumerState<CodeView> {
  final _recognizers = <TapGestureRecognizer>[];
  String? _selectedKey;

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _showExplanation(String key) {
    HapticFeedback.selectionClick();
    setState(() => _selectedKey = key);
    final text = widget.explain[key]!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const KIconBox(Icons.touch_app_rounded, size: 36),
                const SizedBox(width: 12),
                Flexible(child: KodChip(key)),
              ]),
              const SizedBox(height: 14),
              RichUz(text, style: ctx.text.bodyLarge),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedKey = null);
    });
  }

  List<InlineSpan> _spans(CodePalette p, double size) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final code = widget.code;
    final tokens = highlightDart(code);
    final ranges = _explainRanges(code, widget.explain);
    final hr = widget.highlightRange;
    final bounds = <int>{0, code.length};
    for (final t in tokens) {
      bounds..add(t.start)..add(t.end);
    }
    for (final r in ranges) {
      bounds..add(r.start)..add(r.end);
    }
    if (hr != null) {
      bounds..add(hr.$1.clamp(0, code.length))..add((hr.$1 + hr.$2).clamp(0, code.length));
    }
    final sorted = bounds.toList()..sort();
    final kindAt = List<HighlightKind>.filled(code.length + 1, HighlightKind.plain);
    for (final t in tokens) {
      for (var i = t.start; i < t.end && i < code.length; i++) {
        kindAt[i] = t.kind;
      }
    }
    final spans = <InlineSpan>[];
    var ri = 0;
    for (var b = 0; b < sorted.length - 1; b++) {
      final s = sorted[b], e = sorted[b + 1];
      if (s >= e) continue;
      while (ri < ranges.length && ranges[ri].end <= s) {
        ri++;
      }
      final range = ri < ranges.length && ranges[ri].start <= s && ranges[ri].end >= e ? ranges[ri] : null;
      final inHr = hr != null && s >= hr.$1 && e <= hr.$1 + hr.$2;
      var style = codeTextStyle(size, colorForKind(p, kindAt[s]));
      if (kindAt[s] == HighlightKind.comment) style = style.copyWith(fontStyle: FontStyle.italic);
      if (range != null) {
        style = style.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: KColors.cyan,
          backgroundColor: _selectedKey == range.key ? KColors.cyan.withValues(alpha: 0.3) : null,
        );
      }
      if (inHr) style = style.copyWith(backgroundColor: KColors.warning.withValues(alpha: p.isDark ? 0.32 : 0.28));
      TapGestureRecognizer? rec;
      if (range != null) {
        final key = range.key;
        rec = TapGestureRecognizer()..onTap = () => _showExplanation(key);
        _recognizers.add(rec);
      }
      spans.add(TextSpan(
        text: code.substring(s, e),
        style: style,
        recognizer: rec,
        mouseCursor: rec != null ? SystemMouseCursors.click : null,
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final p = codePaletteOf(ref);
    final size = widget.fontSize ?? ref.watch(settingsProvider).codeFontSize;
    final lines = '\n'.allMatches(widget.code).length + 1;
    final lh = codeLineHeight(size);
    final strut = codeStrut(size);
    final hl = widget.highlightLine;
    return Container(
      color: p.background,
      child: Stack(
        children: [
          if (hl != null && hl >= 1 && hl <= lines)
            AnimatedPositioned(
              duration: KDurations.medium,
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              top: widget.padding.top + (hl - 1) * lh,
              height: lh,
              child: Container(
                decoration: BoxDecoration(
                  color: KColors.primary.withValues(alpha: p.isDark ? 0.22 : 0.12),
                  border: const Border(left: BorderSide(color: KColors.cyan, width: 3)),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showLineNumbers)
                Container(
                  padding: widget.padding.copyWith(left: 10, right: 10),
                  color: p.gutter.withValues(alpha: 0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 1; i <= lines; i++)
                        SizedBox(
                          height: lh,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (widget.lineMarkers[i] != null)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(color: widget.lineMarkers[i], shape: BoxShape.circle),
                              ),
                            Text('$i',
                                strutStyle: strut,
                                style: codeTextStyle(size * 0.86, i == hl ? KColors.cyan : p.lineNumber)
                                    .copyWith(fontWeight: i == hl ? FontWeight.w700 : FontWeight.w400)),
                          ]),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: widget.padding.copyWith(left: 14, right: 20),
                  child: AnimatedOpacity(
                    opacity: widget.dimmed ? 0.5 : 1,
                    duration: KDurations.fast,
                    child: Text.rich(
                      TextSpan(children: _spans(p, size)),
                      strutStyle: strut,
                      softWrap: false,
                      semanticsLabel: widget.code,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kod bloki uchun ramka: sarlavha, nusxa olish tugmasi.
class CodeFrame extends ConsumerWidget {
  const CodeFrame({super.key, required this.child, this.title, this.actions = const [], this.code, this.footer});
  final Widget child;
  final String? title;
  final List<Widget> actions;
  final String? code;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = codePaletteOf(ref);
    return ClipRRect(
      borderRadius: BorderRadius.circular(KRadius.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.background,
          border: Border.all(color: p.isDark ? const Color(0xFF1E2B47) : context.k.border),
          borderRadius: BorderRadius.circular(KRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: p.gutter,
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              child: Row(children: [
                for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                  Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text((title ?? 'main.dart').uz,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.lineNumber, fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                ...actions,
                if (code != null)
                  IconButton(
                    tooltip: 'Nusxa olish',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    color: p.lineNumber,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code!));
                      showToast(context, 'Kod nusxalandi', icon: Icons.check_rounded);
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
              ]),
            ),
            child,
            ?footer,
          ],
        ),
      ),
    );
  }
}
