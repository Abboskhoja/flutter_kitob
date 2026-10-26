import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/model.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../../shared/bitik.dart';

/// Daraja sarlavhasi: rang, unvon, progress. Bosilsa — daraja tafsilotlari.
class LevelBanner extends StatelessWidget {
  const LevelBanner({super.key, required this.level, required this.progress});
  final Level level;
  final ProgressState progress;

  @override
  Widget build(BuildContext context) {
    final done = level.lessons.where((l) => progress.isCompleted(l.id)).length;
    final total = level.lessons.length;
    final complete = level.isReady && done == total;
    final c = level.isReady ? level.color : context.k.textMuted;
    return Semantics(
      button: true,
      label: '${level.number}-daraja: ${level.title}',
      child: Pressable(
        onTap: () => context.go('/learn/level/${level.number}'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KRadius.xl),
            gradient: level.isReady
                ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c, Color.lerp(c, KColors.cyan, 0.45)!])
                : null,
            color: level.isReady ? null : context.k.surfaceAlt,
            border: level.isReady ? null : Border.all(color: context.k.border),
            boxShadow: [if (level.isReady) BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: level.isReady ? Colors.white.withValues(alpha: 0.22) : context.k.surfaceHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: complete
                  ? const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26)
                  : level.isReady
                      ? Text('${level.number}', style: numberStyle(const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)))
                      : Icon(Icons.lock_rounded, color: context.k.textMuted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (level.rank != null)
                  Text(level.rank!,
                      style: context.text.labelSmall!.copyWith(
                        color: level.isReady ? Colors.white.withValues(alpha: 0.85) : c,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      )),
                UzText(level.title,
                    style: context.text.titleMedium!.copyWith(color: level.isReady ? Colors.white : context.k.text, fontWeight: FontWeight.w800),
                    maxLines: 1),
                const SizedBox(height: 2),
                Text(
                  (level.isReady
                          ? (complete ? 'Tugallandi · $total dars' : '$done / $total dars · ${level.modules.length} modul')
                          : 'Tayyorlanmoqda · ${level.topics.length} mavzu rejalashtirilgan')
                      .uz,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: level.isReady ? Colors.white.withValues(alpha: 0.9) : context.k.textMuted),
                ),
              ]),
            ),
            if (level.isReady && !complete)
              KProgressRing(value: total == 0 ? 0 : done / total, size: 40, stroke: 4.5, color: Colors.white),
            Icon(Icons.chevron_right_rounded, color: level.isReady ? Colors.white : context.k.textMuted),
          ]),
        ),
      ),
    );
  }
}

/// Darslar ilon izi: tugunlar egri yo'l bilan bog'langan.
class LessonTrail extends ConsumerWidget {
  const LessonTrail({super.key, required this.level, this.currentKey});
  final Level level;

  /// Hozirgi dars tuguni — sahifa ochilganda shu joyga aylantiriladi.
  final GlobalKey? currentKey;

  static const _rowH = 128.0;
  static const _node = 66.0;

  /// Tugunning gorizontal siljishi (-1..1): Duolingo'dagi kabi to'lqinsimon.
  static double _wave(int i) => math.sin(i * math.pi / 3.2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final lessons = level.lessons;
    final statuses = [for (final l in lessons) notifier.statusOf(l.id)];
    // Hozirgi: birinchi tugallanmagan va ochiq dars.
    final current = statuses.indexWhere((s) => s == LessonStatus.inProgress || s == LessonStatus.available);
    return LayoutBuilder(builder: (context, c) {
      final amp = math.min(c.maxWidth * 0.26, 130.0);
      final cx = c.maxWidth / 2;
      final centers = [for (var i = 0; i < lessons.length; i++) Offset(cx + _wave(i) * amp, i * _rowH + _node / 2 + 12)];
      return SizedBox(
        height: lessons.length * _rowH + 8,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: CustomPaint(painter: _TrailPainter(centers, statuses, level.color, context.k.borderStrong)),
          ),
          for (var i = 0; i < lessons.length; i++)
            Positioned(
              left: centers[i].dx - 80,
              top: centers[i].dy - _node / 2,
              width: 160,
              child: Reveal(
                index: i,
                offset: const Offset(0, 16),
                scale: 0.8,
                child: _LessonNode(
                  key: i == current ? currentKey : null,
                  lesson: lessons[i],
                  status: statuses[i],
                  color: level.color,
                  current: i == current,
                ),
              ),
            ),
          // Bitik hozirgi dars yonida: to'lqinning qarama-qarshi tomonida.
          if (current >= 0)
            Positioned(
              left: _wave(current) > 0 ? centers[current].dx - 150 : centers[current].dx + 62,
              top: centers[current].dy - 52,
              child: IgnorePointer(
                child: Column(children: [
                  _Bubble(text: statuses[current] == LessonStatus.inProgress ? 'Davom etamiz!' : (current == 0 && level.number == 1 ? 'Shu yerdan!' : 'Navbatdagisi!')),
                  const Bitik(mood: BitikMood.happy, size: 64),
                ]),
              ),
            ),
        ]),
      );
    });
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.k.surface,
      borderRadius: BorderRadius.circular(KRadius.md),
      border: Border.all(color: context.k.border),
      boxShadow: [BoxShadow(color: context.k.shadow, blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Text(text.uz, style: context.text.labelMedium!.copyWith(fontWeight: FontWeight.w800, color: context.k.text)),
  );
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.centers, this.statuses, this.color, this.muted);
  final List<Offset> centers;
  final List<LessonStatus> statuses;
  final Color color;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i + 1 < centers.length; i++) {
      final a = centers[i], b = centers[i + 1];
      final mid = (a.dy + b.dy) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, mid, b.dx, mid, b.dx, b.dy);
      final done = statuses[i] == LessonStatus.completed;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8
        ..color = done ? color.withValues(alpha: 0.55) : muted.withValues(alpha: 0.6);
      if (done) {
        canvas.drawPath(path, paint);
      } else {
        // Hali o'tilmagan yo'l — uzuq chiziq.
        for (final m in path.computeMetrics()) {
          for (var d = 0.0; d < m.length; d += 22) {
            canvas.drawPath(m.extractPath(d, math.min(d + 10, m.length)), paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter o) => o.color != color || o.muted != muted || !_eq(o.statuses, statuses) || !_eq(o.centers, centers);

  static bool _eq<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _LessonNode extends StatefulWidget {
  const _LessonNode({super.key, required this.lesson, required this.status, required this.color, required this.current});
  final Lesson lesson;
  final LessonStatus status;
  final Color color;
  final bool current;

  /// Sessiya davomida oxirgi ko'rilgan holat: avval qulfda bo'lib, endi ochilgan
  /// dars uchun "qulf ochildi" animatsiyasi bir marta o'ynaydi.
  static final _seen = <String, LessonStatus>{};

  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode> with SingleTickerProviderStateMixin {
  late final _unlock = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  int _shake = 0;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(_LessonNode old) {
    super.didUpdateWidget(old);
    _check();
  }

  void _check() {
    final id = widget.lesson.id;
    final before = _LessonNode._seen[id];
    _LessonNode._seen[id] = widget.status;
    if (before == LessonStatus.locked && widget.status != LessonStatus.locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (KMotion.off(context)) {
          _unlock.value = 1;
        } else {
          _unlock.forward(from: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _unlock.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.status == LessonStatus.locked) {
      kHaptic(context);
      setState(() => _shake++);
      showToast(context, 'Avval oldingi darsni tugating — bilimlar ketma-ket quriladi', icon: Icons.lock_rounded);
      return;
    }
    kHaptic(context);
    context.go('/learn/lesson/${widget.lesson.id}');
  }

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final s = widget.status;
    final locked = s == LessonStatus.locked;
    final done = s == LessonStatus.completed;
    final c = done ? KColors.success : (locked ? k.surfaceHigh : widget.color);
    final icon = done ? Icons.check_rounded : (locked ? Icons.lock_rounded : (widget.current ? Icons.play_arrow_rounded : widget.lesson.icon));
    final size = widget.current ? 74.0 : LessonTrail._node;

    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: locked ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(c, Colors.white, 0.15)!, c]),
        color: locked ? c : null,
        border: Border.all(color: widget.current ? Colors.white : Colors.transparent, width: 4),
        // "3D" tugma: pastki qalin soya.
        boxShadow: [
          BoxShadow(color: locked ? k.borderStrong : Color.lerp(c, Colors.black, 0.25)!, offset: const Offset(0, 5)),
          if (!locked) BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(icon, color: locked ? k.textMuted : Colors.white, size: widget.current ? 36 : 28),
    );
    if (widget.current) circle = PulseGlow(color: widget.color, spread: 14, child: circle);

    // Qulf ochilishi: aylanib kattalashadi va yorug'lik halqasi tarqaladi.
    circle = AnimatedBuilder(
      animation: _unlock,
      child: circle,
      builder: (context, child) {
        final v = _unlock.value;
        if (v == 0 || v == 1) return child!;
        final pop = 1 + 0.25 * math.sin(math.min(v / 0.6, 1) * math.pi);
        return Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
          Container(
            width: size * (1 + v * 1.2),
            height: size * (1 + v * 1.2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color.withValues(alpha: (1 - v) * 0.8), width: 4)),
          ),
          Transform.rotate(angle: (1 - Curves.easeOutBack.transform(v)) * 0.8, child: Transform.scale(scale: pop, child: child)),
        ]);
      },
    );

    return Semantics(
      button: true,
      label: '${widget.lesson.title}${done ? ', tugallangan' : (locked ? ', yopiq' : '')}'.uz,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Shake(trigger: _shake == 0 ? null : _shake, child: Pressable(onTap: _tap, scale: 0.92, child: circle)),
          const SizedBox(height: 8),
          // Fon — yo'l chizig'i nom ustidan o'tmasin.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: k.background, borderRadius: BorderRadius.circular(KRadius.sm)),
            child: UzText(
              widget.lesson.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: context.text.labelMedium!.copyWith(
                color: locked ? k.textMuted : k.text,
                fontWeight: widget.current ? FontWeight.w800 : FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
