import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/runner/runner.dart';
import '../../core/state/progress.dart';
import '../code/code_view.dart';
import '../code/console_view.dart';

/// Kodni trace bilan bajarib, qadam-baqadam ko'rsatadi.
class VisualizerView extends ConsumerStatefulWidget {
  const VisualizerView({super.key, required this.code, this.stdin = const [], this.compactLayout});
  final String code;
  final List<String> stdin;
  final bool? compactLayout;

  @override
  ConsumerState<VisualizerView> createState() => _VisualizerViewState();
}

class _VisualizerViewState extends ConsumerState<VisualizerView> {
  final _runner = CodeRunner();
  ExecutionResult? _result;
  int _step = 0;
  bool _playing = false;
  double _speed = 1;
  Timer? _timer;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void didUpdateWidget(covariant VisualizerView old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code) _run();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _runner.stop();
    super.dispose();
  }

  Future<void> _run() async {
    _timer?.cancel();
    setState(() {
      _result = null;
      _step = 0;
      _playing = false;
    });
    final r = await _runner.run(widget.code, options: ExecutionOptions(trace: true, stdin: widget.stdin, maxTraceSteps: 1500));
    if (!mounted) return;
    setState(() => _result = r);
    if (!_recorded && r.trace.isNotEmpty) {
      _recorded = true;
      ref.read(progressProvider.notifier).recordVisualization();
    }
  }

  void _go(int s) {
    final n = _result?.trace.length ?? 0;
    if (n == 0) return;
    HapticFeedback.selectionClick();
    setState(() => _step = s.clamp(0, n - 1));
  }

  void _togglePlay() {
    if (_playing) {
      _timer?.cancel();
      setState(() => _playing = false);
      return;
    }
    final n = _result?.trace.length ?? 0;
    if (_step >= n - 1) _step = 0;
    setState(() => _playing = true);
    _tick();
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: (1100 / _speed).round()), () {
      if (!mounted || !_playing) return;
      final n = _result?.trace.length ?? 0;
      if (_step >= n - 1) {
        setState(() => _playing = false);
        return;
      }
      setState(() => _step++);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    if (r == null) {
      return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
    }
    if (!r.compiled) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const FeedbackBanner(kind: FeedbackKind.error, title: 'Kodni vizualizatsiya qilib bo\'lmaydi', message: 'Avval xatolarni tuzating:'),
        const SizedBox(height: 10),
        ProblemsView(diagnostics: r.diagnostics.where((d) => d.isError).toList()),
      ]);
    }
    if (r.trace.isEmpty) {
      return FeedbackBanner(
        kind: FeedbackKind.warning,
        title: 'Qadamlar yozilmadi',
        message: r.error?.explanation ?? 'Dastur hech qanday qadam bajarmadi.',
      );
    }
    final t = r.trace[_step];
    final n = r.trace.length;
    final isLast = _step == n - 1;
    final compact = widget.compactLayout ?? context.screenWidth < 900;

    final codePanel = CodeFrame(
      title: 'Bajarilayotgan qator: ${t.line}',
      child: CodeView(
        code: widget.code,
        highlightLine: t.kind == TraceKind.end ? null : t.line,
        highlightRange: t.length > 1 ? (t.offset, t.length) : null,
      ),
    );

    final controls = KCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(children: [
        Row(children: [
          _KindIcon(kind: t.kind),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: KDurations.fast,
              child: RichUz(t.description, key: ValueKey(_step), style: context.text.bodyLarge!.copyWith(color: context.k.text)),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text('${_step + 1}/$n', style: context.text.labelMedium),
          Expanded(
            child: Slider(
              value: _step.toDouble(),
              min: 0,
              max: (n - 1).toDouble().clamp(0, double.infinity),
              divisions: n > 1 ? n - 1 : null,
              label: '${_step + 1}',
              onChanged: n > 1 ? (v) => _go(v.round()) : null,
            ),
          ),
        ]),
        Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 2, children: [
          IconButton(tooltip: 'Boshi', onPressed: () => _go(0), icon: const Icon(Icons.first_page_rounded)),
          IconButton(tooltip: 'Oldingi qadam', onPressed: _step == 0 ? null : () => _go(_step - 1), icon: const Icon(Icons.skip_previous_rounded)),
          IconButton.filled(
            tooltip: _playing ? 'Pauza' : 'Avtomatik ijro',
            onPressed: _togglePlay,
            icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          ),
          IconButton(tooltip: 'Keyingi qadam', onPressed: isLast ? null : () => _go(_step + 1), icon: const Icon(Icons.skip_next_rounded)),
          IconButton(tooltip: 'Oxiri', onPressed: () => _go(n - 1), icon: const Icon(Icons.last_page_rounded)),
          const SizedBox(width: 8),
          PopupMenuButton<double>(
            tooltip: 'Tezlik',
            initialValue: _speed,
            onSelected: (v) => setState(() => _speed = v),
            itemBuilder: (_) => [for (final v in const [0.5, 1.0, 2.0, 4.0]) PopupMenuItem(value: v, child: Text('${v}x'))],
            child: Chip(avatar: const Icon(Icons.speed_rounded, size: 16), label: Text('${_speed}x')),
          ),
        ]),
        if (r.traceTruncated)
          Text('Trace birinchi 1500 qadam bilan cheklangan.'.uz, style: context.text.bodySmall),
      ]),
    );

    final varsPanel = _VariablesPanel(step: t);
    final console = ConsoleView(
      result: r,
      visibleOutputLength: isLast ? null : t.outputLength,
      emptyHint: 'Hali hech narsa chiqmadi',
    );
    final stack = t.callStack.length > 1
        ? Wrap(spacing: 6, runSpacing: 6, children: [
            Text('Chaqiruvlar steki:'.uz, style: context.text.labelMedium),
            for (final f in t.callStack) Chip(visualDensity: VisualDensity.compact, label: Text('$f()', style: codeStyle(size: 12))),
          ])
        : const SizedBox.shrink();

    if (compact) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        codePanel,
        const SizedBox(height: 10),
        controls,
        const SizedBox(height: 10),
        varsPanel,
        const SizedBox(height: 8),
        stack,
        const SizedBox(height: 8),
        console,
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [codePanel, const SizedBox(height: 10), controls])),
      const SizedBox(width: 16),
      Expanded(
        flex: 4,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [varsPanel, const SizedBox(height: 10), stack, const SizedBox(height: 10), console]),
      ),
    ]);
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.kind});
  final TraceKind kind;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      TraceKind.start => (Icons.play_circle_rounded, KColors.primary),
      TraceKind.declare => (Icons.add_box_rounded, KColors.success),
      TraceKind.assign => (Icons.edit_rounded, KColors.warning),
      TraceKind.condition => (Icons.alt_route_rounded, KColors.violet),
      TraceKind.loop => (Icons.loop_rounded, KColors.cyan),
      TraceKind.call => (Icons.call_made_rounded, KColors.orange),
      TraceKind.ret => (Icons.keyboard_return_rounded, KColors.orange),
      TraceKind.output => (Icons.terminal_rounded, KColors.success),
      TraceKind.branch => (Icons.call_split_rounded, KColors.violet),
      TraceKind.wait => (Icons.hourglass_top_rounded, KColors.cyan),
      TraceKind.error => (Icons.error_rounded, KColors.error),
      TraceKind.end => (Icons.flag_rounded, KColors.success),
    };
    return KIconBox(icon, color: color, size: 38);
  }
}

class _VariablesPanel extends StatelessWidget {
  const _VariablesPanel({required this.step});
  final TraceStep step;

  @override
  Widget build(BuildContext context) => KCard(
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.memory_rounded, size: 18, color: KColors.primary),
        const SizedBox(width: 6),
        Text('Xotira (o\'zgaruvchilar)'.uz, style: context.text.titleSmall),
      ]),
      const SizedBox(height: 10),
      if (step.vars.isEmpty)
        Text('Hozircha o\'zgaruvchi yo\'q'.uz, style: context.text.bodySmall)
      else
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final v in step.vars)
            AnimatedContainer(
              key: ValueKey(v.name),
              duration: KDurations.medium,
              constraints: const BoxConstraints(minWidth: 96),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: step.changed.contains(v.name) ? KColors.warning.withValues(alpha: 0.18) : context.k.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: step.changed.contains(v.name) ? KColors.warning : context.k.border, width: step.changed.contains(v.name) ? 2 : 1),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(v.type, style: codeStyle(size: 10.5, color: KColors.teal)),
                Text(v.name, style: codeStyle(size: 13, color: context.k.text, weight: FontWeight.w700)),
                AnimatedSwitcher(
                  duration: KDurations.medium,
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Text(v.value, key: ValueKey(v.value), style: codeStyle(size: 14, color: KColors.orange, weight: FontWeight.w700)),
                ),
              ]),
            ),
        ]),
    ]),
  );
}

Future<void> showVisualizer(BuildContext context, String code, {List<String> stdin = const []}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (ctx) => Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const KTopBar(close: true, title: 'Qadam-baqadam bajarish'),
      body: Builder(builder: (ctx) => ListView(
        padding: pagePadding(ctx),
        children: [ContentWidth(child: VisualizerView(code: code, stdin: stdin))],
      )),
    ),
  ),
);
