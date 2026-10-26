import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/storage/store.dart';
import '../code/code_controller.dart';
import '../code/code_editor.dart';
import 'vfs.dart';

class TerminalPage extends ConsumerStatefulWidget {
  const TerminalPage({super.key});

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  final _shell = VirtualShell();
  final _lines = <TermLine>[];
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  int _historyIndex = -1;
  Set<String> _done = {};

  static const _key = 'terminal';

  @override
  void initState() {
    super.initState();
    final j = ref.read(storeProvider).readJson(_key);
    if (j != null) {
      _shell.load(j);
      _done = ((j['done'] as List?) ?? const []).cast<String>().toSet();
    }
    _lines.add(const TermLine('FLUTTER_KITOB o\'quv terminali. Bu xavfsiz virtual muhit — haqiqiy kompyuteringizga ta\'sir qilmaydi.', LineKind.info));
    _lines.add(const TermLine("Boshlash uchun 'help' yozing yoki missiyalarni (🏁) bajaring.", LineKind.info));
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _persist() {
    ref.read(storeProvider).writeJson(_key, {..._shell.toJson(), 'done': _done.toList()});
  }

  Future<void> _submit(String text) async {
    final out = _shell.execute(text);
    _input.clear();
    _historyIndex = -1;
    if (out.length == 1 && out.first.text == '\u0000clear') {
      setState(_lines.clear);
    } else if (out.isNotEmpty && out.last.text.startsWith('\u0000edit ')) {
      setState(() => _lines.addAll(out.take(out.length - 1)));
      await _edit(out.last.text.substring(6));
    } else {
      setState(() => _lines.addAll(out));
    }
    final before = _done.length;
    for (final m in terminalMissions) {
      if (!_done.contains(m.id) && m.test(_shell)) {
        _done.add(m.id);
        _lines.add(TermLine('✓ Missiya bajarildi: ${m.title} (+10 XP)', LineKind.success));
      }
    }
    final newMissions = _done.length - before;
    final notifier = ref.read(progressProvider.notifier);
    if (text.trim().isNotEmpty) notifier.recordTerminalCommand(missionCompleted: newMissions > 0);
    for (var i = 1; i < newMissions; i++) {
      notifier.recordTerminalCommand(missionCompleted: true);
    }
    _persist();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: KDurations.fast, curve: Curves.easeOut);
      _focus.requestFocus();
    });
  }

  Future<void> _edit(String path) async {
    final node = _shell.resolve(path);
    final ctrl = CodeEditingController(text: node?.isDir == false ? node!.content : '');
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => Scaffold(
        appBar: KTopBar(
          close: true,
          title: path.split('/').last,
          actions: [
            KButton(label: 'Saqlash', icon: Icons.save_rounded, compact: true, onPressed: () => Navigator.pop(ctx, true)),
          ],
        ),
        body: KitobCodeEditor(controller: ctrl, analyze: path.endsWith('.dart'), onSave: () => Navigator.pop(ctx, true)),
      ),
    ));
    if (saved == true) {
      final parentPath = path.substring(0, path.lastIndexOf('/'));
      final parent = _shell.resolve(parentPath.isEmpty ? '/' : parentPath);
      final name = path.split('/').last;
      if (parent != null && parent.isDir) {
        parent.children.putIfAbsent(name, () => VNode.file(name)).content = ctrl.text;
        setState(() => _lines.add(TermLine('Saqlandi: $path', LineKind.success)));
        _persist();
      }
    }
    ctrl.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final h = _shell.history;
    if (e.logicalKey == LogicalKeyboardKey.arrowUp && h.isNotEmpty) {
      _historyIndex = _historyIndex < 0 ? h.length - 1 : (_historyIndex - 1).clamp(0, h.length - 1);
      _setInput(h[_historyIndex]);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowDown && _historyIndex >= 0) {
      _historyIndex++;
      _setInput(_historyIndex >= h.length ? '' : h[_historyIndex]);
      if (_historyIndex >= h.length) _historyIndex = -1;
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.tab) {
      _setInput(_shell.complete(_input.text));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.keyL && HardwareKeyboard.instance.isControlPressed) {
      setState(_lines.clear);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _setInput(String s) => _input.value = TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));

  Color _color(LineKind k) => switch (k) {
    LineKind.prompt => Colors.white,
    LineKind.output => const Color(0xFFE2E8F0),
    LineKind.error => const Color(0xFFFCA5A5),
    LineKind.info => const Color(0xFF94A3B8),
    LineKind.success => const Color(0xFF86EFAC),
  };

  @override
  Widget build(BuildContext context) {
    final wide = context.screenWidth >= 900;
    final terminal = Container(
      color: const Color(0xFF070C17),
      child: Column(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _focus.requestFocus(),
            child: SelectionArea(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(14),
                itemCount: _lines.length,
                itemBuilder: (context, i) {
                  final l = _lines[i];
                  if (l.kind == LineKind.prompt) {
                    return Text.rich(TextSpan(children: [
                      TextSpan(text: 'student@kitob', style: codeStyle(size: 13.5, color: const Color(0xFF86EFAC), weight: FontWeight.w700)),
                      TextSpan(text: ':${l.cwd}\$ ', style: codeStyle(size: 13.5, color: const Color(0xFF7DD3FC))),
                      TextSpan(text: l.text, style: codeStyle(size: 13.5, color: Colors.white)),
                    ]));
                  }
                  return Text(l.kind == LineKind.output ? l.text : l.text.uz, style: codeStyle(size: 13.5, color: _color(l.kind)));
                },
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
          decoration: const BoxDecoration(color: Color(0xFF0B1220), border: Border(top: BorderSide(color: Color(0xFF1E2B47)))),
          child: Row(children: [
            Text('${_shell.displayCwd}\$ ', style: codeStyle(size: 14, color: const Color(0xFF7DD3FC))),
            Expanded(
              child: Focus(
                onKeyEvent: _onKey,
                child: TextField(
                  controller: _input,
                  focusNode: _focus,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  style: codeStyle(size: 14, color: Colors.white),
                  cursorColor: KColors.cyan,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    hintText: 'buyruq yozing...'.uz,
                    hintStyle: codeStyle(size: 14, color: Colors.white24),
                  ),
                  onSubmitted: _submit,
                ),
              ),
            ),
            IconButton(tooltip: 'Bajarish', color: KColors.cyan, onPressed: () => _submit(_input.text), icon: const Icon(Icons.keyboard_return_rounded)),
          ]),
        ),
        Container(
          height: 44,
          color: const Color(0xFF0B1220),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: [
              for (final c in const ['ls', 'pwd', 'cd ..', 'cd ', 'mkdir ', 'touch ', 'cat ', 'tree', 'clear', 'help', 'dart run ', 'flutter '])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF16213A),
                    side: BorderSide.none,
                    label: Text(c.trim(), style: codeStyle(size: 12.5, color: Colors.white)),
                    onPressed: () {
                      if (c.endsWith(' ')) {
                        _setInput(c);
                        _focus.requestFocus();
                      } else {
                        _submit(c);
                      }
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  backgroundColor: const Color(0xFF16213A),
                  side: BorderSide.none,
                  label: Text('Tab ⇥', style: codeStyle(size: 12.5, color: Colors.white)),
                  onPressed: () => _setInput(_shell.complete(_input.text)),
                ),
              ),
            ],
          ),
        ),
      ]),
    );

    final missions = _MissionsPanel(done: _done, shell: _shell, onReset: () {
      setState(() {
        _shell.reset();
        _done = {};
        _lines
          ..clear()
          ..add(const TermLine('Virtual fayl tizimi qayta yaratildi.', LineKind.info));
      });
      _persist();
    });

    return Scaffold(
      backgroundColor: context.k.console,
      appBar: KTopBar(
        dark: true,
        background: context.k.console,
        title: 'Terminal laboratoriyasi',
        onBack: () => context.canPop() ? context.pop() : context.go('/practice'),
        showBack: !context.isExpanded,
        actions: [
          if (!wide)
            GlassIconButton(
              dark: true,
              tooltip: 'Missiyalar',
              onPressed: () => showKSheet<void>(context, builder: (ctx) => missions),
              icon: Icons.flag_rounded,
              badge: KBadge('${_done.length}/${terminalMissions.length}', color: KColors.error, solid: true),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: wide ? Row(children: [SizedBox(width: 360, child: missions), Expanded(child: terminal)]) : terminal,
      ),
    );
  }
}

class _MissionsPanel extends StatelessWidget {
  const _MissionsPanel({required this.done, required this.shell, required this.onReset});
  final Set<String> done;
  final VirtualShell shell;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => ListView(
    controller: PrimaryScrollController.maybeOf(context),
    padding: const EdgeInsets.all(16),
    children: [
      Row(children: [
        Expanded(child: UzText('Missiyalar', style: context.text.titleLarge)),
        Text('${done.length}/${terminalMissions.length}', style: context.text.titleMedium!.copyWith(color: KColors.primary)),
      ]),
      const SizedBox(height: 6),
      KProgressBar(value: done.length / terminalMissions.length),
      const SizedBox(height: 12),
      RichUz('**Terminal** — kompyuterga matnli buyruq berish oynasi. **Shell** buyruqni o\'qib bajaradi. **Path** — papka manzili: `/home/student` (absolute) yoki `loyihalar` (relative — joriy papkaga nisbatan).',
          style: context.text.bodySmall),
      const SizedBox(height: 12),
      for (final m in terminalMissions)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: KCard(
            padding: const EdgeInsets.all(12),
            borderColor: done.contains(m.id) ? KColors.success.withValues(alpha: 0.5) : null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(done.contains(m.id) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: done.contains(m.id) ? KColors.success : context.k.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  UzText(m.title, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  RichUz(m.task, style: context.text.bodySmall),
                  if (!done.contains(m.id)) ...[
                    const SizedBox(height: 4),
                    Text('Maslahat: ${m.hint}'.uz, style: codeStyle(size: 12, color: KColors.primary)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: onReset, icon: const Icon(Icons.restart_alt_rounded), label: Text('Fayl tizimini qayta boshlash'.uz)),
    ],
  );
}
