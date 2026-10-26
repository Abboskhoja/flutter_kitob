import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';
import 'tokens.dart';

/// Animatsiyalar uchun global kalit.
///
/// Testlarda `false` qilinadi (`test/flutter_test_config.dart`): takrorlanuvchi
/// fon animatsiyalari `pumpAndSettle` ni cheksiz kutishga majbur qilmasin.
abstract final class KMotion {
  static bool enabled = true;

  /// Ilova "Animatsiyalarni kamaytirish" yoki tizim sozlamasi bilan ham o'chadi.
  static bool off(BuildContext context) => !enabled || MediaQuery.disableAnimationsOf(context);

  /// Ta'sirchan, biroz "sakrovchi" kirish egri chizig'i.
  static const emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
}

/// Ekranga chiqishda pastdan suzib, xiralikdan paydo bo'ladi.
///
/// [index] berilsa, ro'yxat elementlari ketma-ket (stagger) chiqadi.
/// Kechikish `Interval` bilan qilinadi — Timer ishlatilmaydi.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.step = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 24),
    this.scale = 0.97,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Duration step;
  final Duration duration;
  final Offset offset;
  final double scale;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  late Animation<double> _t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || KMotion.off(context)) return;
    // Uzun ro'yxatlarda oxirgi elementlar ham tez chiqsin.
    final wait = widget.delay + widget.step * math.min(widget.index, 10);
    final total = wait + widget.duration;
    _c = AnimationController(vsync: this, duration: total);
    _t = CurvedAnimation(
      parent: _c!,
      curve: Interval(wait.inMicroseconds / total.inMicroseconds, 1, curve: KMotion.emphasized),
    );
    _c!.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null) return widget.child;
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.offset * (1 - v),
            child: Transform.scale(scale: widget.scale + (1 - widget.scale) * v, child: child),
          ),
        );
      },
    );
  }
}

/// Son o'zgarganda eski qiymatdan yangisiga "sanab" boradi.
class CountUp extends StatelessWidget {
  const CountUp(this.value, {super.key, this.style, this.prefix = '', this.suffix = '', this.duration = const Duration(milliseconds: 900)});
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final s = numberStyle(DefaultTextStyle.of(context).style.merge(style));
    if (KMotion.off(context)) return Text('$prefix$value$suffix', style: s);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$prefix${v.round()}$suffix', style: s),
    );
  }
}

/// Doimiy takrorlanuvchi animatsiyalar uchun asos. Harakat o'chirilganda
/// controller umuman ishga tushmaydi va [builder] `t = 0` bilan chaqiriladi.
class Ambient extends StatefulWidget {
  const Ambient({super.key, required this.builder, this.period = const Duration(seconds: 2), this.reverse = false, this.child});
  final Widget Function(BuildContext context, double t, Widget? child) builder;
  final Duration period;
  final bool reverse;
  final Widget? child;

  @override
  State<Ambient> createState() => _AmbientState();
}

class _AmbientState extends State<Ambient> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (KMotion.off(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: widget.reverse);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) => widget.builder(context, _c.value, child),
  );
}

/// Yengil yuqoriga-pastga suzish (ikonka, maskot, bezaklar uchun).
class Floaty extends StatelessWidget {
  const Floaty({super.key, required this.child, this.amplitude = 6, this.period = const Duration(milliseconds: 2600), this.phase = 0});
  final Widget child;
  final double amplitude;
  final Duration period;
  final double phase;

  @override
  Widget build(BuildContext context) => Ambient(
    period: period,
    child: child,
    builder: (context, t, child) => Transform.translate(
      offset: Offset(0, math.sin((t + phase) * math.pi * 2) * amplitude),
      child: child,
    ),
  );
}

/// Atrofida "nafas oluvchi" yorug'lik halqasi — joriy maqsadga e'tibor tortadi.
class PulseGlow extends StatelessWidget {
  const PulseGlow({super.key, required this.child, required this.color, this.radius = 999, this.spread = 10, this.active = true});
  final Widget child;
  final Color color;
  final double radius;
  final double spread;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    return Ambient(
      period: const Duration(milliseconds: 1600),
      reverse: true,
      child: child,
      builder: (context, t, child) {
        final v = Curves.easeInOut.transform(t);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.18 + 0.32 * v), blurRadius: 8 + spread * v, spreadRadius: 1 + spread * 0.4 * v),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

/// Ustidan diagonal yorug'lik chizig'i o'tadi (CTA tugma va kartalar uchun).
class Sheen extends StatelessWidget {
  const Sheen({super.key, required this.child, this.period = const Duration(milliseconds: 3200), this.radius = KRadius.md, this.opacity = 0.35});
  final Widget child;
  final Duration period;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) => Ambient(
    period: period,
    child: child,
    builder: (context, t, child) {
      // Davrning faqat birinchi 40% ida o'tadi, qolganida dam oladi.
      final p = (t / 0.4).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) return child!;
      final x = -1.5 + 3.0 * Curves.easeInOut.transform(p);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(children: [
          child!,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(x - 0.6, -1),
                    end: Alignment(x + 0.6, 1),
                    colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: opacity), Colors.white.withValues(alpha: 0)],
                    stops: const [0.35, 0.5, 0.65],
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    },
  );
}

/// Sekin harakatlanuvchi rangli "aurora" dog'lari — hero kartalar foni.
class Aurora extends StatelessWidget {
  const Aurora({super.key, required this.colors, this.period = const Duration(seconds: 14), this.child});
  final List<Color> colors;
  final Duration period;
  final Widget? child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Ambient(
      period: period,
      child: child,
      builder: (context, t, child) => CustomPaint(painter: _AuroraPainter(t, colors), child: child),
    ),
  );
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.colors);
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final a = t * math.pi * 2;
    for (var i = 0; i < colors.length; i++) {
      final ph = i * 2.1;
      final c = Offset(
        size.width * (0.5 + 0.42 * math.cos(a + ph)),
        size.height * (0.5 + 0.48 * math.sin(a * (i.isEven ? 1 : -1) + ph)),
      );
      final r = size.shortestSide * (0.75 + 0.2 * math.sin(a * 2 + ph));
      final paint = Paint()
        ..shader = RadialGradient(colors: [colors[i].withValues(alpha: 0.55), colors[i].withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter o) => o.t != t || o.colors != colors;
}

/// [trigger] o'zgarganda gorizontal silkinadi (noto'g'ri javob uchun).
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child, this.distance = 10});
  final Object? trigger;
  final Widget child;
  final double distance;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && widget.trigger != null && !KMotion.off(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      final v = _c.value;
      final dx = math.sin(v * math.pi * 6) * widget.distance * (1 - v);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
  );
}

/// [trigger] o'zgarganda elastik "pop" qiladi (to'g'ri javob, yangi qiymat).
class Pop extends StatefulWidget {
  const Pop({super.key, required this.trigger, required this.child, this.amount = 0.12});
  final Object? trigger;
  final Widget child;
  final double amount;

  @override
  State<Pop> createState() => _PopState();
}

class _PopState extends State<Pop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);

  @override
  void didUpdateWidget(Pop old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && widget.trigger != null && !KMotion.off(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) => Transform.scale(scale: 1 + widget.amount * math.sin(_c.value * math.pi), child: child),
  );
}

/// Kursor ortidan ergashuvchi yumshoq yorug'lik (web/desktop hover effekti).
class Spotlight extends StatefulWidget {
  const Spotlight({super.key, required this.child, this.color = KColors.primary, this.radius = KRadius.lg, this.enabled = true});
  final Widget child;
  final Color color;
  final double radius;
  final bool enabled;

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  Offset? _pos;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || KMotion.off(context)) return widget.child;
    final pos = _pos;
    return MouseRegion(
      onHover: (e) => setState(() => _pos = e.localPosition),
      onExit: (_) => setState(() => _pos = null),
      // passthrough: ota bergan kenglik kartaga to'liq o'tsin (aks holda karta torayadi).
      child: Stack(fit: StackFit.passthrough, children: [
        widget.child,
        if (pos != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: CustomPaint(painter: _SpotPainter(pos, widget.color.withValues(alpha: context.isDark ? 0.16 : 0.09))),
              ),
            ),
          ),
      ]),
    );
  }
}

class _SpotPainter extends CustomPainter {
  _SpotPainter(this.pos, this.color);
  final Offset pos;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.max(140.0, size.shortestSide * 0.9);
    canvas.drawCircle(
      pos,
      r,
      Paint()..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: pos, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_SpotPainter o) => o.pos != pos || o.color != color;
}

// ───────────────────────── Konfetti ─────────────────────────

/// Ekran ustida bir martalik konfetti portlashi. Bosishlarni to'smaydi.
abstract final class Confetti {
  static const palette = [KColors.primary, KColors.cyan, KColors.warning, KColors.success, KColors.pink, KColors.violet, KColors.orange];

  /// [origin] — global koordinata; berilmasa ekranning yuqori markazi.
  static void burst(BuildContext context, {Offset? origin, int count = 90, List<Color> colors = palette}) {
    if (KMotion.off(context)) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ConfettiLayer(origin: origin, count: count, colors: colors, onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _Particle {
  _Particle(math.Random r, this.color)
      : angle = -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 1.1,
        speed = 420 + r.nextDouble() * 520,
        spin = (r.nextDouble() - 0.5) * 14,
        size = 6 + r.nextDouble() * 7,
        wobble = r.nextDouble() * math.pi * 2,
        circle = r.nextDouble() < 0.3;

  final Color color;
  final double angle;
  final double speed;
  final double spin;
  final double size;
  final double wobble;
  final bool circle;
}

/// Bir martalik konfetti qatlami. O'z Overlay'i bo'lmagan joyda (masalan,
/// Navigator ustida) to'g'ridan-to'g'ri Stack ichiga qo'yiladi.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, this.origin, this.count = 90, this.colors = Confetti.palette, required this.onDone});
  final Offset? origin;
  final int count;
  final List<Color> colors;
  final VoidCallback onDone;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final List<_Particle> _ps;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _ps = [for (var i = 0; i < widget.count; i++) _Particle(r, widget.colors[i % widget.colors.length])];
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_ps, _c.value, widget.origin),
        ),
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.ps, this.t, this.origin);
  final List<_Particle> ps;
  final double t;
  final Offset? origin;

  @override
  void paint(Canvas canvas, Size size) {
    final o = origin ?? Offset(size.width / 2, size.height * 0.28);
    final time = t * 2.4;
    const gravity = 900.0;
    final fade = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
    final paint = Paint();
    for (final p in ps) {
      // Havo qarshiligi: tezlik vaqt o'tishi bilan susayadi.
      final drag = (1 - math.exp(-2.2 * time)) / 2.2;
      final x = o.dx + math.cos(p.angle) * p.speed * drag + math.sin(time * 6 + p.wobble) * 12;
      final y = o.dy + math.sin(p.angle) * p.speed * drag + 0.5 * gravity * time * time * 0.55;
      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * time);
      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      } else {
        // Aylanayotgan qog'oz effekti: eni kosinus bo'yicha torayadi.
        final w = p.size * (0.35 + 0.65 * math.cos(time * 9 + p.wobble).abs());
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: p.size * 0.55), const Radius.circular(1.5)), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.t != t;
}
