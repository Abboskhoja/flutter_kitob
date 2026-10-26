import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/motion.dart';
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

/// Video kabi ishlaydigan animatsion dars: sahnalar ketma-ket o'ynaydi,
/// tepada story-progress, pastda subtitr, tezlikni tanlash va qayta ko'rish.
class _StoryAnimationState extends ConsumerState<StoryAnimation> with SingleTickerProviderStateMixin {
  int _stage = 0;
  double _speed = 1;
  bool _ended = false;
  bool _started = false;

  // Joriy sahna davomiyligi — sahna progress chizig'i shu bilan silliq to'ladi.
  late final AnimationController _clock = AnimationController(vsync: this)
    ..addStatusListener((s) {
      if (s != AnimationStatus.completed || !mounted) return;
      if (_stage >= widget.captions.length - 1) {
        setState(() => _ended = true);
      } else {
        setState(() => _stage++);
        _runScene();
      }
    });

  bool get _playing => _clock.isAnimating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Harakat kamaytirilgan bo'lsa (yoki testda) — o'zi boshlanmaydi, o'quvchi bosadi.
      if (!reduceMotionOf(context, ref.read(settingsProvider)) && !KMotion.off(context)) _play();
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _runScene() {
    _clock.duration = Duration(milliseconds: (widget.interval / _speed).round());
    _clock.forward(from: 0);
  }

  void _play() {
    setState(() {
      _started = true;
      if (_ended) {
        _ended = false;
        _stage = 0;
      }
    });
    if (_clock.value > 0 && _clock.value < 1) {
      _clock.forward();
    } else {
      _runScene();
    }
  }

  void _pause() {
    _clock.stop();
    setState(() {});
  }

  void _go(int s) {
    _clock.stop();
    setState(() {
      _started = true;
      _ended = false;
      _stage = s.clamp(0, widget.captions.length - 1);
      _clock.value = 0;
    });
  }

  void _toggle() => _playing ? _pause() : _play();

  void _cycleSpeed() {
    setState(() => _speed = _speed == 1 ? 1.5 : (_speed == 1.5 ? 0.75 : 1));
    if (_playing) {
      final v = _clock.value;
      _clock.duration = Duration(milliseconds: (widget.interval / _speed).round());
      _clock.forward(from: v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final n = widget.captions.length;
    // Katta tizim shriftida sahna ham mutanosib kattalashadi — matn kesilmasin.
    final stageH = widget.height * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    return Semantics(
      label: 'Animatsion dars, $n sahna. ${widget.captions[_stage]}'.uz,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KRadius.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDark ? const [Color(0xFF0F1B33), Color(0xFF111A2E)] : const [Color(0xFFF2F8FF), Colors.white],
            ),
            border: Border.all(color: k.border),
            borderRadius: BorderRadius.circular(KRadius.xl),
          ),
          child: Column(children: [
            // ── Ekran: sahna + ustidagi story-progress va (to'xtaganda) katta ▶.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: SizedBox(
                height: stageH + 34,
                child: Stack(children: [
                  Positioned.fill(
                    top: 34,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: ExcludeSemantics(child: _ScaleToFit(child: widget.builder(context, _stage))),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: AnimatedBuilder(
                      animation: _clock,
                      builder: (context, _) => Row(children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.only(right: i == n - 1 ? 0 : 4),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(color: k.borderStrong.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2)),
                              child: FractionallySizedBox(
                                widthFactor: i < _stage || (_ended && i == _stage) ? 1 : (i == _stage ? _clock.value : 0),
                                child: Container(decoration: BoxDecoration(color: KColors.primary, borderRadius: BorderRadius.circular(2))),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 20,
                    child: Row(children: [
                      Icon(Icons.movie_filter_rounded, size: 14, color: k.textMuted),
                      const SizedBox(width: 4),
                      Text('${_stage + 1}/$n', style: numberStyle(TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: k.textMuted))),
                    ]),
                  ),
                  if (!_playing && (!_started || _ended))
                    Positioned.fill(
                      top: 34,
                      // Video kabi: sahna yengil xiralashadi, tugma uning ustida.
                      child: Container(
                        color: k.surface.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                          child: Center(
                          child: Pop(
                            trigger: _ended,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: _ended ? 18 : 22, vertical: 14),
                              decoration: BoxDecoration(
                                color: KColors.primary,
                                borderRadius: BorderRadius.circular(KRadius.pill),
                                boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_ended ? Icons.replay_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text((_ended ? 'Yana ko\'rish' : 'Ko\'rish').uz,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            // ── Subtitr: doim qorong'i fonda — qalin so'zlar va `kod` ham oq/yorqin o'qiladi.
            Theme(
              data: KitobTheme.dark(),
                child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: context.isDark ? Colors.black.withValues(alpha: 0.35) : KColors.navy.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(KRadius.md),
                ),
                child: AnimatedSwitcher(
                  duration: KDurations.medium,
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(a), child: c),
                  ),
                  child: RichUz(
                    widget.captions[_stage],
                    key: ValueKey(_stage),
                    style: context.text.bodyMedium!.copyWith(color: Colors.white, height: 1.45),
                  ),
                ),
              ),
            ),
            // ── Boshqaruv.
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 10, 8),
              child: Row(children: [
                IconButton(tooltip: 'Boshidan'.uz, onPressed: () => _go(0), icon: const Icon(Icons.replay_rounded)),
                IconButton(tooltip: 'Oldingi sahna'.uz, onPressed: _stage == 0 ? null : () => _go(_stage - 1), icon: const Icon(Icons.skip_previous_rounded)),
                IconButton.filled(
                  tooltip: (_playing ? 'Pauza' : 'Ijro').uz,
                  onPressed: _toggle,
                  icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                IconButton(tooltip: 'Keyingi sahna'.uz, onPressed: _stage >= n - 1 ? null : () => _go(_stage + 1), icon: const Icon(Icons.skip_next_rounded)),
                const Spacer(),
                TextButton(
                  onPressed: _cycleSpeed,
                  child: Text('${_speed == 0.75 ? '0.75' : _speed == 1.5 ? '1.5' : '1'}×', style: numberStyle(const TextStyle(fontWeight: FontWeight.w800))),
                ),
              ]),
            ),
          ]),
        ),
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

  /// Sahna mazmuni kamida [_minWidth] kenglikda chiziladi va joyga kenglik
  /// hamda balandlik bo'yicha sig'diriladi: kichik bo'lsa — markazda, katta
  /// bo'lsa (tor ekran, katta shrift) — butunligicha kichrayadi, kesilmaydi.
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    if (!box.hasBoundedHeight) return child;
    final w = box.maxWidth < _minWidth ? _minWidth : box.maxWidth;
    final scale = box.maxWidth / w;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: w, maxWidth: w, minHeight: box.maxHeight / scale),
        child: child,
      ),
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
