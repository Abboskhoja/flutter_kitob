import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';
import 'code_controller.dart';
import 'code_palette.dart';

class _RunIntent extends Intent {
  const _RunIntent();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _FindIntent extends Intent {
  const _FindIntent();
}

class _IndentIntent extends Intent {
  const _IndentIntent({this.outdent = false});
  final bool outdent;
}

class _CommentIntent extends Intent {
  const _CommentIntent();
}

class _ZoomIntent extends Intent {
  const _ZoomIntent(this.delta);
  final double delta;
}

/// Haqiqiy kod muharriri. Telefon va kompyuterda bir xil ishlaydi.
class KitobCodeEditor extends ConsumerStatefulWidget {
  const KitobCodeEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.onRun,
    this.onSave,
    this.readOnly = false,
    this.showKeyBar,
    this.analyze = true,
    this.requireMain = true,
    this.onDiagnostics,
    this.minLines = 6,
    this.autofocus = false,
    this.expands = true,
  });

  final CodeEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onRun;
  final VoidCallback? onSave;
  final bool readOnly;

  /// null — telefonda avtomatik ko'rinadi.
  final bool? showKeyBar;
  final bool analyze;
  final bool requireMain;
  final ValueChanged<List<Diagnostic>>? onDiagnostics;
  final int minLines;
  final bool autofocus;

  /// true — ota widgetning balandligini to'ldiradi (playground);
  /// false — kod uzunligiga qarab o'sadi (dars ichidagi muharrir).
  final bool expands;

  @override
  ConsumerState<KitobCodeEditor> createState() => KitobCodeEditorState();
}

class KitobCodeEditorState extends ConsumerState<KitobCodeEditor> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  final _undo = UndoHistoryController();
  final _vScroll = ScrollController();
  final _hScroll = ScrollController();
  Timer? _debounce;
  bool _findOpen = false;
  final _findCtrl = TextEditingController();
  final _replaceCtrl = TextEditingController();
  String _lastAnalyzed = '\u0000';

  CodeEditingController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onChange);
    _focus.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleAnalyze(immediate: true));
  }

  @override
  void didUpdateWidget(covariant KitobCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    c.removeListener(_onChange);
    if (widget.focusNode == null) _focus.dispose();
    _undo.dispose();
    _vScroll.dispose();
    _hScroll.dispose();
    _findCtrl.dispose();
    _replaceCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    if (c.text != _lastAnalyzed) _scheduleAnalyze();
    if (mounted) setState(() {});
  }

  void _scheduleAnalyze({bool immediate = false}) {
    if (!widget.analyze) return;
    _debounce?.cancel();
    _debounce = Timer(immediate ? Duration.zero : const Duration(milliseconds: 380), () {
      if (!mounted) return;
      final src = c.text;
      _lastAnalyzed = src;
      final d = KitobDart.analyze(src, requireMain: widget.requireMain);
      c.diagnostics = d;
      widget.onDiagnostics?.call(d);
    });
  }

  /// Berilgan qatorga o'tadi va uni ko'rinadigan qiladi.
  void jumpToLine(int line) {
    final offset = c.offsetOfLine(line);
    final lineEnd = c.text.indexOf('\n', offset);
    c.selection = TextSelection(baseOffset: offset, extentOffset: lineEnd < 0 ? c.text.length : lineEnd);
    _focus.requestFocus();
    final lh = codeLineHeight(c.fontSize);
    if (_vScroll.hasClients) {
      final target = ((line - 3) * lh).clamp(0.0, _vScroll.position.maxScrollExtent);
      _vScroll.animateTo(target, duration: KDurations.medium, curve: Curves.easeOutCubic);
    }
  }

  void insertText(String s) {
    if (widget.readOnly) return;
    if (s == '\t') {
      c.indentSelection();
    } else if (s == '=>') {
      c.insert(' => ');
    } else {
      c.insert(s);
    }
    _focus.requestFocus();
  }

  void openFind() => setState(() => _findOpen = true);

  void closeFind() {
    c.search = '';
    setState(() => _findOpen = false);
  }

  void _findNext({bool back = false}) {
    final q = _findCtrl.text;
    if (q.isEmpty) return;
    final text = c.text;
    final from = back ? c.selection.start - 1 : c.selection.end;
    int idx;
    if (back) {
      idx = from < 0 ? -1 : text.lastIndexOf(q, from);
      if (idx < 0) idx = text.lastIndexOf(q);
    } else {
      idx = text.indexOf(q, from.clamp(0, text.length));
      if (idx < 0) idx = text.indexOf(q);
    }
    if (idx < 0) return;
    c.selection = TextSelection(baseOffset: idx, extentOffset: idx + q.length);
    final line = '\n'.allMatches(text.substring(0, idx)).length + 1;
    final lh = codeLineHeight(c.fontSize);
    if (_vScroll.hasClients) {
      _vScroll.animateTo(((line - 3) * lh).clamp(0.0, _vScroll.position.maxScrollExtent),
          duration: KDurations.fast, curve: Curves.easeOut);
    }
  }

  bool get _touchFirst =>
      defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final palette = codePaletteOf(ref);
    c
      ..palette = palette
      ..fontSize = settings.codeFontSize;
    final size = settings.codeFontSize;
    final lh = codeLineHeight(size);
    final strut = codeStrut(size);
    final showBar = !widget.readOnly && (widget.showKeyBar ?? (_touchFirst || context.isCompact));
    final errorLines = <int, bool>{};
    for (final d in c.diagnostics) {
      errorLines[d.line] = (errorLines[d.line] ?? false) || d.isError;
    }
    final cursorLine = _focus.hasFocus ? c.cursorLine : null;
    final activeLine = c.activeLine ?? cursorLine;
    const pad = EdgeInsets.fromLTRB(12, 12, 24, 12);

    final field = TextField(
      controller: c,
      focusNode: _focus,
      undoController: _undo,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: null,
      minLines: widget.minLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      textCapitalization: TextCapitalization.none,
      enableIMEPersonalizedLearning: false,
      inputFormatters: [CodeInputFormatter()],
      cursorColor: KColors.cyan,
      cursorWidth: 2,
      strutStyle: strut,
      style: codeTextStyle(size, palette.text),
      scrollPhysics: const NeverScrollableScrollPhysics(),
      decoration: const InputDecoration(
        filled: false,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );

    final editorArea = LayoutBuilder(builder: (context, constraints) {
      final lines = c.lineCount;
      // Raqamlar haqiqiy shrift bilan o'lchanadi: 8 px chap + belgi 8 + oraliq 3 + o'ng 8.
      final digits = TextPainter(
        text: TextSpan(text: '8' * lines.toString().length, style: codeTextStyle(size * 0.82, palette.lineNumber)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final gutterWidth = 28.0 + digits.width.ceilToDouble();
      final contentMinHeight = widget.expands && constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
      final content = ConstrainedBox(
        constraints: BoxConstraints(minHeight: contentMinHeight),
        child: Stack(children: [
          if (activeLine != null && activeLine <= lines)
            Positioned(
              left: 0,
              right: 0,
              top: pad.top + (activeLine - 1) * lh,
              height: lh,
              child: ColoredBox(color: c.activeLine != null ? KColors.primary.withValues(alpha: 0.22) : palette.activeLine),
            ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Qator raqamlari
            Container(
              width: gutterWidth,
              padding: EdgeInsets.only(top: pad.top, bottom: pad.bottom),
              color: palette.gutter.withValues(alpha: 0.65),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 1; i <= lines; i++)
                  SizedBox(
                    height: lh,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        if (errorLines.containsKey(i))
                          Tooltip(
                            message: c.diagnostics.where((d) => d.line == i).map((d) => d.message.uz).join('\n'),
                            child: Icon(errorLines[i]! ? Icons.circle : Icons.change_history_rounded,
                                size: 8, color: errorLines[i]! ? KColors.error : KColors.warning),
                          ),
                        const SizedBox(width: 3),
                        Text('$i',
                            strutStyle: strut,
                            style: codeTextStyle(size * 0.82, i == activeLine ? palette.text : palette.lineNumber)),
                      ]),
                    ),
                  ),
              ]),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, inner) {
                return Scrollbar(
                  controller: _hScroll,
                  child: SingleChildScrollView(
                    controller: _hScroll,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: inner.maxWidth),
                      child: IntrinsicWidth(child: Padding(padding: pad, child: field)),
                    ),
                  ),
                );
              }),
            ),
          ]),
        ]),
      );
      final scroller = SingleChildScrollView(
        controller: _vScroll,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!_focus.hasFocus) {
              _focus.requestFocus();
              c.selection = TextSelection.collapsed(offset: c.text.length);
            }
          },
          child: content,
        ),
      );
      return Scrollbar(controller: _vScroll, child: scroller);
    });

    final (prefix, suggestions) = _focus.hasFocus && c.selection.isValid
        ? completionsFor(c.text, c.selection.baseOffset)
        : ('', const <String>[]);

    final body = Column(
      mainAxisSize: widget.expands ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (_findOpen) _FindBar(state: this, palette: palette),
        if (widget.expands) Expanded(child: editorArea) else editorArea,
        if (!widget.readOnly && suggestions.isNotEmpty)
          _SuggestionBar(
            palette: palette,
            items: suggestions,
            onPick: (w) {
              final o = c.selection.baseOffset;
              c.value = TextEditingValue(
                text: c.text.replaceRange(o - prefix.length, o, w),
                selection: TextSelection.collapsed(offset: o - prefix.length + w.length),
              );
              _focus.requestFocus();
            },
          ),
        if (showBar) _KeyBar(state: this, palette: palette),
      ],
    );

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter, control: true): _RunIntent(),
        SingleActivator(LogicalKeyboardKey.enter, meta: true): _RunIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: true): _FindIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, meta: true): _FindIntent(),
        SingleActivator(LogicalKeyboardKey.tab): _IndentIntent(),
        SingleActivator(LogicalKeyboardKey.tab, shift: true): _IndentIntent(outdent: true),
        SingleActivator(LogicalKeyboardKey.slash, control: true): _CommentIntent(),
        SingleActivator(LogicalKeyboardKey.slash, meta: true): _CommentIntent(),
        SingleActivator(LogicalKeyboardKey.equal, control: true): _ZoomIntent(1),
        SingleActivator(LogicalKeyboardKey.minus, control: true): _ZoomIntent(-1),
      },
      child: Actions(
        actions: {
          _RunIntent: CallbackAction<_RunIntent>(onInvoke: (_) => widget.onRun?.call()),
          _SaveIntent: CallbackAction<_SaveIntent>(onInvoke: (_) => widget.onSave?.call()),
          _FindIntent: CallbackAction<_FindIntent>(onInvoke: (_) => openFind()),
          _IndentIntent: CallbackAction<_IndentIntent>(onInvoke: (i) {
            if (!widget.readOnly) c.indentSelection(outdent: i.outdent);
            return null;
          }),
          _CommentIntent: CallbackAction<_CommentIntent>(onInvoke: (_) {
            if (!widget.readOnly) c.toggleComment();
            return null;
          }),
          _ZoomIntent: CallbackAction<_ZoomIntent>(onInvoke: (z) {
            ref.read(settingsProvider.notifier).setCodeFontSize(settings.codeFontSize + z.delta);
            return null;
          }),
        },
        child: Container(color: palette.background, child: body),
      ),
    );
  }
}

class _KeyBar extends StatelessWidget {
  const _KeyBar({required this.state, required this.palette});
  final KitobCodeEditorState state;
  final CodePalette palette;

  static const _keys = ['⇥', '{', '}', '(', ')', '[', ']', ';', '=', '.', '=>', "'", '"', r'$', '?', '!', ':', ',', '<', '>', '+', '-', '*', '/', '_'];

  @override
  Widget build(BuildContext context) {
    final c = state.c;
    Widget key(String label, VoidCallback onTap, {String? tip, IconData? icon}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 6),
      child: Material(
        color: palette.isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, size: 18, color: palette.text)
                : Text(label, style: codeStyle(size: 15, color: palette.text, weight: FontWeight.w600)),
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: palette.gutter,
        border: Border(top: BorderSide(color: palette.isDark ? const Color(0xFF1E2B47) : const Color(0xFFDDE5F0))),
      ),
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        children: [
          key('', () => state._undo.undo(), icon: Icons.undo_rounded),
          key('', () => state._undo.redo(), icon: Icons.redo_rounded),
          key('', () => c.moveCursor(-1), icon: Icons.chevron_left_rounded),
          key('', () => c.moveCursor(1), icon: Icons.chevron_right_rounded),
          key('', () => c.indentSelection(outdent: true), icon: Icons.format_indent_decrease_rounded),
          for (final k in _keys) key(k, () => state.insertText(k == '⇥' ? '\t' : k)),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.palette, required this.items, required this.onPick});
  final CodePalette palette;
  final List<String> items;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    color: palette.gutter.withValues(alpha: 0.9),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(Icons.auto_awesome_rounded, size: 16, color: palette.lineNumber),
        ),
        for (final w in items)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              backgroundColor: palette.isDark ? const Color(0xFF1A2540) : Colors.white,
              side: BorderSide.none,
              label: Text(w, style: codeStyle(size: 13, color: palette.keyword)),
              onPressed: () => onPick(w),
            ),
          ),
      ],
    ),
  );
}

class _FindBar extends StatelessWidget {
  const _FindBar({required this.state, required this.palette});
  final KitobCodeEditorState state;
  final CodePalette palette;

  @override
  Widget build(BuildContext context) {
    final c = state.c;
    InputDecoration deco(String hint) => InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: palette.isDark ? const Color(0xFF1A2540) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
    return Container(
      color: palette.gutter,
      padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          SizedBox(
            width: 170,
            child: TextField(
              controller: state._findCtrl,
              autofocus: true,
              style: codeStyle(size: 13, color: palette.text),
              decoration: deco('Qidirish'.uz),
              onChanged: (v) => c.search = v,
              onSubmitted: (_) => state._findNext(),
            ),
          ),
          SizedBox(
            width: 150,
            child: TextField(
              controller: state._replaceCtrl,
              style: codeStyle(size: 13, color: palette.text),
              decoration: deco('Almashtirish'.uz),
            ),
          ),
          IconButton(tooltip: 'Oldingi', iconSize: 20, color: palette.text, onPressed: () => state._findNext(back: true), icon: const Icon(Icons.keyboard_arrow_up_rounded)),
          IconButton(tooltip: 'Keyingi', iconSize: 20, color: palette.text, onPressed: state._findNext, icon: const Icon(Icons.keyboard_arrow_down_rounded)),
          TextButton(
            onPressed: () {
              final sel = c.selection;
              if (!sel.isCollapsed && c.text.substring(sel.start, sel.end) == state._findCtrl.text) {
                c.insert(state._replaceCtrl.text);
              }
              state._findNext();
            },
            child: Text('Almashtir'.uz),
          ),
          TextButton(
            onPressed: () {
              final n = c.replaceAll(state._findCtrl.text, state._replaceCtrl.text);
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('$n ta almashtirildi'.uz)));
            },
            child: Text('Hammasi'.uz),
          ),
          IconButton(
            tooltip: 'Yopish',
            iconSize: 20,
            color: palette.text,
            onPressed: state.closeFind,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
