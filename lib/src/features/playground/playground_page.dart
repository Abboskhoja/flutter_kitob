import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/motion.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/runner/runner.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../code/code_controller.dart';
import '../code/code_editor.dart';
import '../code/code_palette.dart';
import '../code/console_view.dart';
import '../flutter_preview/preview_view.dart';
import '../visualizer/visualizer_view.dart';
import 'playground_store.dart';

enum _Panel { code, output, problems, input }

class PlaygroundPage extends ConsumerStatefulWidget {
  const PlaygroundPage({super.key, this.initialCode});
  final String? initialCode;

  @override
  ConsumerState<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends ConsumerState<PlaygroundPage> {
  late final CodeEditingController _ctrl;
  final _editorKey = GlobalKey<KitobCodeEditorState>();
  final _runner = CodeRunner();
  final _stdinCtrl = TextEditingController();
  ExecutionResult? _result;

  /// Flutter kodi ishga tushirilganda — telefon oynasida ko'rsatiladigan manba.
  String? _flutterSource;
  bool _running = false;
  List<Diagnostic> _diags = const [];
  _Panel _panel = _Panel.code;
  Timer? _autosave;
  bool _saved = true;
  late final PlaygroundNotifier _store;

  @override
  void initState() {
    super.initState();
    _store = ref.read(playgroundProvider.notifier);
    final pg = ref.read(playgroundProvider);
    _ctrl = CodeEditingController(text: pg.current.code);
    _stdinCtrl.text = pg.stdin;
    _ctrl.addListener(_onEdit);
    final init = widget.initialCode;
    if (init != null && init.trim().isNotEmpty && init != pg.current.code) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final id = ref.read(playgroundProvider.notifier).create(name: 'dars_misoli.dart', code: init);
        _load(id);
      });
    }
  }

  @override
  void dispose() {
    _autosave?.cancel();
    final code = _ctrl.text;
    final store = _store;
    Future.microtask(() => store.updateCode(code));
    _runner.stop();
    _ctrl.removeListener(_onEdit);
    _ctrl.dispose();
    _stdinCtrl.dispose();
    super.dispose();
  }

  void _onEdit() {
    if (_saved) setState(() => _saved = false);
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 700), _flush);
  }

  void _flush() {
    if (!mounted) return;
    _store.updateCode(_ctrl.text);
    if (!_saved) setState(() => _saved = true);
  }

  void _load(String id) {
    _flush();
    ref.read(playgroundProvider.notifier).select(id);
    final f = ref.read(playgroundProvider).current;
    _ctrl.removeListener(_onEdit);
    _ctrl.value = TextEditingValue(text: f.code, selection: const TextSelection.collapsed(offset: 0));
    _ctrl.addListener(_onEdit);
    setState(() {
      _result = null;
      _flutterSource = null;
      _saved = true;
    });
  }

  static final _flutterImport = RegExp(r'''import\s+['"]package:flutter/''');

  Future<void> _run() async {
    _flush();
    final code = _ctrl.text;
    if (_flutterImport.hasMatch(code)) {
      ref.read(progressProvider.notifier).recordCodeRun();
      setState(() {
        _result = null;
        // Bir xil kod qayta ishga tushirilsa ham ilova boshidan ochilsin.
        _flutterSource = _flutterSource == code ? '$code\n' : code;
        if (context.screenWidth < 900) _panel = _Panel.output;
      });
      return;
    }
    _flutterSource = null;
    final stdin = _stdinCtrl.text.isEmpty ? const <String>[] : _stdinCtrl.text.split('\n');
    setState(() {
      _running = true;
      if (context.screenWidth < 900) _panel = _Panel.output;
    });
    final r = await _runner.run(_ctrl.text, options: ExecutionOptions(stdin: stdin));
    if (!mounted) return;
    ref.read(progressProvider.notifier).recordCodeRun();
    setState(() {
      _running = false;
      _result = r;
      if (!r.compiled && context.screenWidth < 900) _panel = _Panel.problems;
    });
  }

  void _stop() {
    _runner.stop();
    setState(() {
      _running = false;
      _result = stoppedResult();
    });
  }

  void _format() {
    final formatted = formatDart(_ctrl.text);
    _ctrl.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length.clamp(0, formatted.length)));
    showToast(context, 'Kod tartibga keltirildi', icon: Icons.auto_fix_high_rounded);
  }

  void _check() {
    final d = KitobDart.analyze(_ctrl.text);
    _ctrl.diagnostics = d;
    setState(() {
      _diags = d;
      _panel = _Panel.problems;
    });
    if (!context.isCompact) _showProblemsSheetIfWide(d);
  }

  void _showProblemsSheetIfWide(List<Diagnostic> d) {
    if (d.isEmpty) showToast(context, 'Analyzer xato topmadi ✓', icon: Icons.verified_rounded);
  }

  Future<void> _rename(PlayFile f) async {
    final c = TextEditingController(text: f.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Fayl nomi'.uz),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(suffixText: '.dart')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Bekor'.uz)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text('Saqlash'.uz)),
        ],
      ),
    );
    if (name != null) ref.read(playgroundProvider.notifier).rename(f.id, name);
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kodni tozalaysizmi?'.uz),
        content: Text('Joriy fayl boshlang\'ich namunaga qaytariladi.'.uz),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Yo\'q'.uz)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Ha, tozalash'.uz)),
        ],
      ),
    );
    if (ok == true) _ctrl.text = defaultProgram;
  }

  @override
  Widget build(BuildContext context) {
    final pg = ref.watch(playgroundProvider);
    final settings = ref.watch(settingsProvider);
    final palette = codePaletteOf(ref);
    final wide = context.screenWidth >= 900;
    final errors = _diags.where((d) => d.isError).length;
    final file = pg.current;

    final editor = KitobCodeEditor(
      key: _editorKey,
      controller: _ctrl,
      onRun: _run,
      onSave: () {
        _flush();
        showToast(context, 'Saqlandi', icon: Icons.save_rounded);
      },
      onDiagnostics: (d) => setState(() => _diags = d),
    );

    final outputPanel = ListView(padding: const EdgeInsets.all(12), children: [
      if (_flutterSource != null)
        Center(child: FlutterPreview(source: _flutterSource!, height: 560, onJumpToLine: _jump))
      else if (_result != null && !_result!.compiled)
        ProblemsView(diagnostics: _result!.diagnostics.where((d) => d.isError).toList(), onTap: (d) => _jump(d.line))
      else
        ConsoleView(result: _result, running: _running, onJumpToLine: _jump),
    ]);
    final problemsPanel = ListView(padding: const EdgeInsets.all(12), children: [
      ProblemsView(diagnostics: _diags, onTap: (d) => _jump(d.line)),
    ]);
    final inputPanel = ListView(padding: const EdgeInsets.all(12), children: [
      UzText('Kiritma (stdin)', style: context.text.titleSmall),
      const SizedBox(height: 4),
      RichUz('`stdin.readLineSync()` har chaqirilganda shu yerdan bitta qator oladi.', style: context.text.bodySmall),
      const SizedBox(height: 8),
      TextField(
        controller: _stdinCtrl,
        maxLines: 6,
        minLines: 3,
        style: codeStyle(size: 14, color: context.k.text),
        decoration: InputDecoration(hintText: 'Har bir qator — bitta kiritma'.uz),
        onChanged: (v) => ref.read(playgroundProvider.notifier).setStdin(v),
      ),
    ]);

    final toolbar = _Toolbar(
      running: _running,
      saved: _saved,
      fileName: file.name,
      files: pg.files,
      currentId: pg.currentId,
      onRun: _run,
      onStop: _stop,
      onFormat: _format,
      onCheck: _check,
      onSelect: _load,
      onNew: () => _load(ref.read(playgroundProvider.notifier).create()),
      onRename: () => _rename(file),
      onDelete: () {
        ref.read(playgroundProvider.notifier).delete(file.id);
        _load(ref.read(playgroundProvider).currentId);
      },
      onReset: _confirmReset,
      onVisualize: () => showVisualizer(context, _ctrl.text, stdin: _stdinCtrl.text.isEmpty ? const [] : _stdinCtrl.text.split('\n')),
      onFind: () => _editorKey.currentState?.openFind(),
      onSample: (code) => _load(ref.read(playgroundProvider.notifier).create(name: 'namuna.dart', code: code)),
      onZoom: (d) => ref.read(settingsProvider.notifier).setCodeFontSize(settings.codeFontSize + d),
      onTheme: () => ref.read(settingsProvider.notifier).setEditorDark(!settings.editorDark),
    );

    Widget body;
    if (wide) {
      body = Row(children: [
        Expanded(flex: 6, child: editor),
        VerticalDivider(width: 1, color: palette.isDark ? const Color(0xFF1E2B47) : context.k.border),
        Expanded(
          flex: 4,
          child: DefaultTabController(
            length: 3,
            child: Column(children: [
              TabBar(tabs: [
                Tab(text: 'Natija'.uz),
                Tab(text: errors > 0 ? 'Muammolar ($errors)'.uz : 'Muammolar'.uz),
                Tab(text: 'Kiritma'.uz),
              ]),
              Expanded(child: TabBarView(children: [outputPanel, problemsPanel, inputPanel])),
            ]),
          ),
        ),
      ]);
    } else {
      body = Column(children: [
        Expanded(
          child: IndexedStack(index: _panel.index, children: [editor, outputPanel, problemsPanel, inputPanel]),
        ),
        _PanelTabs(
          panel: _panel,
          errors: errors,
          palette: palette,
          onChanged: (p) => setState(() => _panel = p),
        ),
      ]);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: KTopBar(
        dark: palette.isDark,
        background: palette.gutter,
        onBack: () => context.canPop() ? context.pop() : context.go('/practice'),
        showBack: !context.isExpanded,
        center: toolbar.title(context, palette),
        actions: toolbar.actions(context, palette),
      ),
      // Telefonda pastki tablar uy indikatori ostigacha cho'ziladi (o'z chetini o'zi qo'shadi).
      body: SafeArea(top: false, bottom: wide, child: body),
    );
  }

  void _jump(int line) {
    setState(() => _panel = _Panel.code);
    WidgetsBinding.instance.addPostFrameCallback((_) => _editorKey.currentState?.jumpToLine(line));
  }
}

class _Toolbar {
  _Toolbar({
    required this.running,
    required this.saved,
    required this.fileName,
    required this.files,
    required this.currentId,
    required this.onRun,
    required this.onStop,
    required this.onFormat,
    required this.onCheck,
    required this.onSelect,
    required this.onNew,
    required this.onRename,
    required this.onDelete,
    required this.onReset,
    required this.onVisualize,
    required this.onFind,
    required this.onSample,
    required this.onZoom,
    required this.onTheme,
  });

  final bool running;
  final bool saved;
  final String fileName;
  final List<PlayFile> files;
  final String currentId;
  final VoidCallback onRun, onStop, onFormat, onCheck, onNew, onRename, onDelete, onReset, onVisualize, onFind, onTheme;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onSample;
  final ValueChanged<double> onZoom;

  Widget title(BuildContext context, CodePalette p) => PopupMenuButton<String>(
    tooltip: 'Fayllar',
    onSelected: (id) => id == '+new' ? onNew() : onSelect(id),
    itemBuilder: (_) => [
      for (final f in files)
        PopupMenuItem(
          value: f.id,
          child: Row(children: [
            Icon(Icons.description_outlined, size: 18, color: f.id == currentId ? KColors.primary : null),
            const SizedBox(width: 8),
            Text(f.name, style: TextStyle(fontWeight: f.id == currentId ? FontWeight.w700 : FontWeight.w400)),
          ]),
        ),
      const PopupMenuDivider(),
      PopupMenuItem(value: '+new', child: Row(children: [const Icon(Icons.add_rounded, size: 18), const SizedBox(width: 8), Text('Yangi fayl'.uz)])),
    ],
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.description_rounded, size: 18, color: p.function),
      const SizedBox(width: 6),
      Flexible(child: Text(fileName, overflow: TextOverflow.ellipsis, style: codeStyle(size: 14, color: p.text, weight: FontWeight.w700))),
      Icon(Icons.arrow_drop_down_rounded, color: p.lineNumber),
      const SizedBox(width: 4),
      Tooltip(
        message: (saved ? 'Saqlangan' : 'Saqlanmoqda...').uz,
        child: Icon(saved ? Icons.cloud_done_rounded : Icons.sync_rounded, size: 16, color: saved ? KColors.success : KColors.warning),
      ),
    ]),
  );

  List<Widget> actions(BuildContext context, CodePalette p) {
    final wide = context.screenWidth >= 700;
    final runBtn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: running
          ? FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: KColors.error, minimumSize: const Size(40, 40)),
              onPressed: onStop,
              icon: const Icon(Icons.stop_rounded),
              label: Text('Stop'.uz),
            )
          : FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: KColors.success, minimumSize: const Size(40, 40)),
              onPressed: onRun,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(wide ? 'Ishga tushirish'.uz : 'Run'),
            ),
    );
    return [
      if (wide) ...[
        IconButton(tooltip: 'Tartiblash (Format)', color: p.text, onPressed: onFormat, icon: const Icon(Icons.auto_fix_high_rounded)),
        IconButton(tooltip: 'Tekshirish (Check)', color: p.text, onPressed: onCheck, icon: const Icon(Icons.fact_check_outlined)),
        IconButton(tooltip: 'Qadam-baqadam', color: p.text, onPressed: onVisualize, icon: const Icon(Icons.slow_motion_video_rounded)),
      ],
      runBtn,
      PopupMenuButton<String>(
        tooltip: 'Ko\'proq',
        iconColor: p.text,
        onSelected: (v) {
          switch (v) {
            case 'format':
              onFormat();
            case 'check':
              onCheck();
            case 'visual':
              onVisualize();
            case 'find':
              onFind();
            case 'rename':
              onRename();
            case 'delete':
              onDelete();
            case 'reset':
              onReset();
            case 'zoomin':
              onZoom(1);
            case 'zoomout':
              onZoom(-1);
            case 'theme':
              onTheme();
            default:
              if (v.startsWith('sample:')) onSample(playgroundSamples[v.substring(7)]!);
          }
        },
        itemBuilder: (_) {
          PopupMenuItem<String> it(String v, IconData i, String t) =>
              PopupMenuItem(value: v, child: Row(children: [Icon(i, size: 18), const SizedBox(width: 10), Text(t.uz)]));
          return [
            if (!wide) ...[
              it('format', Icons.auto_fix_high_rounded, 'Tartiblash (Format)'),
              it('check', Icons.fact_check_outlined, 'Tekshirish (Check)'),
              it('visual', Icons.slow_motion_video_rounded, 'Qadam-baqadam'),
            ],
            it('find', Icons.find_replace_rounded, 'Qidirish / almashtirish'),
            const PopupMenuDivider(),
            it('zoomin', Icons.zoom_in_rounded, 'Shriftni kattalashtirish'),
            it('zoomout', Icons.zoom_out_rounded, 'Shriftni kichraytirish'),
            it('theme', Icons.contrast_rounded, 'Editor mavzusi (yorug\'/qorong\'i)'),
            const PopupMenuDivider(),
            it('rename', Icons.drive_file_rename_outline_rounded, 'Nomini o\'zgartirish'),
            it('reset', Icons.restart_alt_rounded, 'Boshlang\'ich holatga (Reset)'),
            it('delete', Icons.delete_outline_rounded, 'Faylni o\'chirish'),
            const PopupMenuDivider(),
            for (final name in playgroundSamples.keys) it('sample:$name', Icons.lightbulb_outline_rounded, 'Namuna: $name'),
          ];
        },
      ),
      const SizedBox(width: 4),
    ];
  }
}

/// Telefon: editor ostidagi bo'limlar almashtirgichi. Editor rangiga mos,
/// tanlov indikatori bir bo'limdan ikkinchisiga silliq siljiydi.
class _PanelTabs extends StatelessWidget {
  const _PanelTabs({required this.panel, required this.errors, required this.palette, required this.onChanged});
  final _Panel panel;
  final int errors;
  final CodePalette palette;
  final ValueChanged<_Panel> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_Panel.code, 'Kod', Icons.code_rounded),
      (_Panel.output, 'Natija', Icons.terminal_rounded),
      (_Panel.problems, errors > 0 ? '$errors xato' : 'Xato', errors > 0 ? Icons.error_rounded : Icons.check_circle_outline_rounded),
      (_Panel.input, 'Kirish', Icons.keyboard_rounded),
    ];
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      color: palette.gutter,
      padding: EdgeInsets.fromLTRB(10, 6, 10, 6 + bottom),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(KRadius.pill),
          border: Border.all(color: palette.lineNumber.withValues(alpha: 0.25)),
        ),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth / items.length;
          return Stack(children: [
            AnimatedPositioned(
              duration: KMotion.off(context) ? Duration.zero : KDurations.slow,
              curve: Curves.easeOutBack,
              left: panel.index * w + 3,
              top: 3,
              bottom: 3,
              width: w - 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [KColors.primary, Color(0xFF1C9BF5)]),
                  borderRadius: BorderRadius.circular(KRadius.pill),
                  boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.4), blurRadius: 10)],
                ),
              ),
            ),
            Positioned.fill(
              child: Row(children: [
                for (final (p, label, icon) in items)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: p == panel,
                      label: label.uz,
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(KRadius.pill),
                        onTap: () {
                          kHaptic(context);
                          onChanged(p);
                        },
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(icon, size: 17, color: p == panel ? Colors.white : (p == _Panel.problems && errors > 0 ? KColors.error : palette.lineNumber)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(label.uz,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p == panel ? Colors.white : palette.text.withValues(alpha: 0.75))),
                          ),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}
