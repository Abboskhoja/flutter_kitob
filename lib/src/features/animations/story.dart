import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';

/// Bosqichma-bosqich ta'limiy animatsiya ramkasi.
class StoryAnimation extends ConsumerStatefulWidget {
  const StoryAnimation({super.key, required this.captions, required this.builder, this.height = 220, this.interval = 2200});
  final List<String> captions;
  final Widget Function(BuildContext context, int stage) builder;
  final double height;
  final int interval;

  @override
  ConsumerState<StoryAnimation> createState() => _StoryAnimationState();
}

class _StoryAnimationState extends ConsumerState<StoryAnimation> {
  int _stage = 0;
  bool _playing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!reduceMotionOf(context, ref.read(settingsProvider))) _play();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _play() {
    _timer?.cancel();
    setState(() {
      _playing = true;
      if (_stage >= widget.captions.length - 1) _stage = 0;
    });
    _timer = Timer.periodic(Duration(milliseconds: widget.interval), (t) {
      if (!mounted) return;
      if (_stage >= widget.captions.length - 1) {
        t.cancel();
        setState(() => _playing = false);
        return;
      }
      setState(() => _stage++);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _playing = false);
  }

  void _go(int s) {
    _pause();
    setState(() => _stage = s.clamp(0, widget.captions.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final n = widget.captions.length;
    return Semantics(
      label: 'Animatsiya, $n bosqich. ${widget.captions[_stage]}'.uz,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.isDark ? const [Color(0xFF0F1B33), Color(0xFF111A2E)] : const [Color(0xFFF2F8FF), Colors.white],
          ),
          borderRadius: BorderRadius.circular(KRadius.lg),
          border: Border.all(color: k.border),
        ),
        child: Column(children: [
          SizedBox(
            height: widget.height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: ExcludeSemantics(child: _ScaleToFit(child: widget.builder(context, _stage))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: KDurations.medium,
              child: Row(
                key: ValueKey(_stage),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: KColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: Text('${_stage + 1}/$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: RichUz(widget.captions[_stage], style: context.text.bodyMedium!.copyWith(color: k.text))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
            child: Row(children: [
              IconButton(tooltip: 'Boshidan'.uz, onPressed: () => _go(0), icon: const Icon(Icons.replay_rounded)),
              IconButton(tooltip: 'Orqaga'.uz, onPressed: _stage == 0 ? null : () => _go(_stage - 1), icon: const Icon(Icons.skip_previous_rounded)),
              IconButton.filled(
                tooltip: _playing ? 'Pauza' : 'Ijro',
                onPressed: _playing ? _pause : _play,
                icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
              IconButton(tooltip: 'Keyingi'.uz, onPressed: _stage >= n - 1 ? null : () => _go(_stage + 1), icon: const Icon(Icons.skip_next_rounded)),
              const Spacer(),
              for (var i = 0; i < n; i++)
                GestureDetector(
                  onTap: () => _go(i),
                  child: AnimatedContainer(
                    duration: KDurations.fast,
                    width: i == _stage ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(color: i <= _stage ? KColors.primary : k.borderStrong, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              const SizedBox(width: 8),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Umumiy qurilish bloklari ─────────────────────────

/// Tor ekranda (telefon) sxemani kengroq virtual maydonda chizib, bir tekis kichraytiradi —
/// shunda animatsiya hech qachon chegaradan chiqib ketmaydi (overflow bo'lmaydi).
class _ScaleToFit extends StatelessWidget {
  const _ScaleToFit({required this.child});
  final Widget child;
  static const _minWidth = 440.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    if (box.maxWidth >= _minWidth || !box.hasBoundedHeight) return child;
    final scale = box.maxWidth / _minWidth;
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: SizedBox(width: _minWidth, height: box.maxHeight / scale, child: child),
    );
  });
}

class ANode extends StatelessWidget {
  const ANode({super.key, required this.label, this.icon, this.active = false, this.color = KColors.primary, this.sub, this.width = 92, this.child});
  final String label;
  final IconData? icon;
  final bool active;
  final Color color;
  final String? sub;
  final double width;
  final Widget? child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: KDurations.slow,
    curve: Curves.easeOutCubic,
    width: width,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    decoration: BoxDecoration(
      color: active ? color.withValues(alpha: context.isDark ? 0.3 : 0.14) : context.k.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: active ? color : context.k.border, width: active ? 2 : 1),
      boxShadow: [if (active) BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) AnimatedScale(scale: active ? 1.15 : 1, duration: KDurations.medium, child: Icon(icon, color: color, size: 28)),
      ?child,
      const SizedBox(height: 4),
      Text(label.uz, textAlign: TextAlign.center, style: context.text.labelMedium!.copyWith(color: context.k.text)),
      if (sub != null) Text(sub!.uz, textAlign: TextAlign.center, style: context.text.labelSmall),
    ]),
  );
}

/// Chapdan o'ngga harakatlanuvchi ma'lumot bo'lagi.
class APacket extends StatelessWidget {
  const APacket({super.key, required this.text, required this.x, this.visible = true, this.color = KColors.cyan, this.mono = true});
  final String text;

  /// -1 (chap) .. 1 (o'ng)
  final double x;
  final bool visible;
  final Color color;
  final bool mono;

  @override
  Widget build(BuildContext context) => AnimatedAlign(
    duration: const Duration(milliseconds: 900),
    curve: Curves.easeInOutCubic,
    alignment: Alignment(x, 0),
    child: AnimatedOpacity(
      duration: KDurations.medium,
      opacity: visible ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 12)],
        ),
        child: Text(text, style: mono ? codeStyle(size: 13, color: Colors.white, weight: FontWeight.w700) : const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    ),
  );
}

class AConsole extends StatelessWidget {
  const AConsole({super.key, required this.lines, this.title = 'Konsol', this.height});
  final List<String> lines;
  final String title;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.uz.toUpperCase(), style: codeStyle(size: 10, color: KColors.cyan, weight: FontWeight.w700)),
      const SizedBox(height: 4),
      for (final l in lines)
        TweenAnimationBuilder<double>(
          key: ValueKey(l),
          tween: Tween(begin: 0, end: 1),
          duration: KDurations.medium,
          builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 6 * (1 - v)), child: child)),
          child: Text(l, style: codeStyle(size: 12.5, color: const Color(0xFFA5E38B))),
        ),
    ]),
  );
}

class ACodeLine extends StatelessWidget {
  const ACodeLine(this.code, {super.key, this.active = false, this.done = false});
  final String code;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: KDurations.medium,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: active ? KColors.primary.withValues(alpha: 0.25) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      border: Border(left: BorderSide(color: active ? KColors.cyan : Colors.transparent, width: 3)),
    ),
    child: Text(code, style: codeStyle(size: 12.5, color: done ? CodePalette.dark.lineNumber : CodePalette.dark.text)),
  );
}

class ACodePanel extends StatelessWidget {
  const ACodePanel({super.key, required this.lines, required this.active, this.width});
  final List<String> lines;
  final int active;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: CodePalette.dark.background, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < lines.length; i++) ACodeLine(lines[i], active: i == active, done: i < active),
    ]),
  );
}

/// Xotiradagi "quti" — o'zgaruvchi.
class AVarBox extends StatelessWidget {
  const AVarBox({super.key, required this.name, required this.type, required this.value, this.visible = true, this.highlight = false, this.locked = false, this.color = KColors.primary});
  final String name;
  final String type;
  final String? value;
  final bool visible;
  final bool highlight;
  final bool locked;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    duration: KDurations.slow,
    curve: Curves.easeOutBack,
    scale: visible ? 1 : 0,
    child: AnimatedContainer(
      duration: KDurations.medium,
      width: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.2) : context.k.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? color : context.k.borderStrong, width: highlight ? 2 : 1),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text(type, maxLines: 1, overflow: TextOverflow.ellipsis, style: codeStyle(size: 10.5, color: CodePalette.dark.type))),
          if (locked) ...[const SizedBox(width: 4), const Icon(Icons.lock_rounded, size: 12, color: KColors.warning)],
        ]),
        const SizedBox(height: 4),
        Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: context.k.surfaceAlt, borderRadius: BorderRadius.circular(8)),
          child: AnimatedSwitcher(
            duration: KDurations.slow,
            transitionBuilder: (c, a) => SlideTransition(
              position: Tween(begin: const Offset(0, -1.2), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
              child: FadeTransition(opacity: a, child: c),
            ),
            child: Text(value ?? '—', key: ValueKey(value), style: codeStyle(size: 16, color: value == null ? context.k.textMuted : CodePalette.dark.number, weight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: codeStyle(size: 13, color: context.k.text, weight: FontWeight.w700)),
      ]),
    ),
  );
}

class AArrow extends StatelessWidget {
  const AArrow({super.key, this.active = false, this.label, this.icon = Icons.arrow_forward_rounded});
  final bool active;
  final String? label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    AnimatedScale(
      duration: KDurations.medium,
      scale: active ? 1.2 : 1,
      child: Icon(icon, color: active ? KColors.cyan : context.k.borderStrong),
    ),
    if (label != null) Text(label!.uz, style: context.text.labelSmall),
  ]);
}
