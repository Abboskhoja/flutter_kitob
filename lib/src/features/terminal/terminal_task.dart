import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../core/storage/store.dart';
import 'shell_grader.dart';
import 'vfs.dart';

/// Dars ichidagi terminal vazifasi: xavfsiz virtual terminal + jonli tekshiriladigan maqsadlar.
///
/// Tekshiruv buyruq matnini emas, fayl tizimining haqiqiy holatini (papka bormi, fayl ichida nima bor,
/// commit qilinganmi) ko'radi — shuning uchun vazifani turli usulda bajarish ham qabul qilinadi.
class TerminalTaskWorkspace extends ConsumerStatefulWidget {
  const TerminalTaskWorkspace({super.key, required this.task, required this.lessonId});
  final TerminalTask task;
  final String lessonId;

  @override
  ConsumerState<TerminalTaskWorkspace> createState() => _TerminalTaskWorkspaceState();
}

class _TerminalTaskWorkspaceState extends ConsumerState<TerminalTaskWorkspace> {
  final _shell = VirtualShell();
  final _lines = <TermLine>[];
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  int _hints = 0;

  String get _key => 'terminal_task.${widget.lessonId}';

  @override
  void initState() {
    super.initState();
    final j = ref.read(storeProvider).readJson(_key);
    if (j != null) _shell.load(j);
    _lines.add(const TermLine('Virtual terminal — haqiqiy kompyuteringizga ta\'sir qilmaydi. "help" — buyruqlar ro\'yxati.', LineKind.info));
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _solved => terminalTaskPasses(_shell, widget.task);

  void _submit(String text) {
    final wasSolved = _solved;
    final out = _shell.execute(text);
    _input.clear();
    setState(() {
      if (out.length == 1 && out.first.text == '\u0000clear') {
        _lines.clear();
      } else {
        // Dars ichida fayl muharriri ochilmaydi — echo ... > fayl bilan yoziladi.
        _lines.addAll(out.where((l) => !l.text.startsWith('\u0000')));
        if (out.any((l) => l.text.startsWith('\u0000edit '))) {
          _lines.add(const TermLine("Bu mashqda faylga echo bilan yozing: echo \"matn\" > fayl.txt", LineKind.info));
        }
      }
    });
    ref.read(storeProvider).writeJson(_key, _shell.toJson());
    final notifier = ref.read(progressProvider.notifier);
    if (text.trim().isNotEmpty) notifier.recordTerminalCommand(missionCompleted: false);
    if (!wasSolved && _solved) notifier.solveTask(widget.lessonId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: KDurations.fast, curve: Curves.easeOut);
      _focus.requestFocus();
    });
  }

  void _reset() {
    setState(() {
      _shell.reset();
      _lines
        ..clear()
        ..add(const TermLine('Virtual fayl tizimi qayta yaratildi.', LineKind.info));
    });
    ref.read(storeProvider).writeJson(_key, _shell.toJson());
  }

  Color _color(LineKind k) => switch (k) {
    LineKind.prompt => Colors.white,
    LineKind.output => const Color(0xFFE2E8F0),
    LineKind.error => const Color(0xFFFCA5A5),
    LineKind.info => const Color(0xFF94A3B8),
    LineKind.success => const Color(0xFF86EFAC),
  };

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final solved = _solved;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          UzText(t.title, style: context.text.titleMedium),
          const SizedBox(height: 6),
          RichUzBlocks(t.instructions, style: context.text.bodyMedium),
          const SizedBox(height: 12),
          for (final c in t.checks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                AnimatedSwitcher(
                  duration: KDurations.medium,
                  child: shellCheckPasses(_shell, c)
                      ? const Icon(Icons.check_circle_rounded, key: ValueKey(true), color: KColors.success, size: 20)
                      : Icon(Icons.radio_button_unchecked_rounded, key: const ValueKey(false), color: context.k.textMuted, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(child: RichUz(c.label, style: context.text.bodySmall)),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 10),
      Semantics(
        label: 'Virtual terminal',
        container: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 300,
            color: const Color(0xFF070C17),
            child: Column(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _focus.requestFocus(),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _lines.length,
                    itemBuilder: (context, i) {
                      final l = _lines[i];
                      if (l.kind == LineKind.prompt) {
                        return Text.rich(TextSpan(children: [
                          TextSpan(text: '${l.cwd}\$ ', style: codeStyle(size: 13, color: const Color(0xFF7DD3FC))),
                          TextSpan(text: l.text, style: codeStyle(size: 13, color: Colors.white)),
                        ]));
                      }
                      return Text(l.kind == LineKind.output ? l.text : l.text.uz, style: codeStyle(size: 13, color: _color(l.kind)));
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
                decoration: const BoxDecoration(color: Color(0xFF0B1220), border: Border(top: BorderSide(color: Color(0xFF1E2B47)))),
                child: Row(children: [
                  Text('${_shell.displayCwd}\$ ', style: codeStyle(size: 13.5, color: const Color(0xFF7DD3FC))),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      style: codeStyle(size: 13.5, color: Colors.white),
                      cursorColor: KColors.cyan,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        hintText: 'buyruq yozing...'.uz,
                        hintStyle: codeStyle(size: 13.5, color: Colors.white24),
                      ),
                      onSubmitted: _submit,
                    ),
                  ),
                  IconButton(tooltip: 'Bajarish', color: KColors.cyan, onPressed: () => _submit(_input.text), icon: const Icon(Icons.keyboard_return_rounded)),
                ]),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 10),
      if (solved)
        const FeedbackBanner(
          kind: FeedbackKind.success,
          title: 'Vazifa bajarildi! +20 XP',
          message: 'Fayl tizimi holati barcha talablarga mos. Endi testga o\'ting.',
        )
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (_hints < t.hints.length)
            KButton(
              label: _hints == 0 ? 'Ishora' : 'Yana ishora',
              icon: Icons.lightbulb_outline_rounded,
              compact: true,
              variant: KButtonVariant.secondary,
              onPressed: () => setState(() => _hints++),
            ),
          KButton(label: 'Qaytadan boshlash', icon: Icons.restart_alt_rounded, compact: true, variant: KButtonVariant.secondary, onPressed: _reset),
        ]),
      for (var i = 0; i < _hints && i < t.hints.length; i++) ...[
        const SizedBox(height: 8),
        FeedbackBanner(kind: FeedbackKind.info, title: '${i + 1}-ishora', child: Text(t.hints[i], style: codeStyle(size: 13, color: context.k.text))),
      ],
    ]);
  }
}
