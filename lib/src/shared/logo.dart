import 'package:flutter/material.dart';

import '../core/design_system/tokens.dart';

/// FLUTTER_KITOB belgisi: gradientli kvadrat ichida geometrik "K" —
/// vertikal "kitob umurtqasi" va ikki "chevron" (kod qavsi `<`).
class KitobLogo extends StatelessWidget {
  const KitobLogo({super.key, this.size = 48, this.progress = 1});
  final double size;

  /// 0..1 — shakl chizilish bosqichi (splash animatsiyasi uchun).
  final double progress;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'FLUTTER_KITOB logotipi',
    image: true,
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: KitobLogoPainter(progress)),
    ),
  );
}

class KitobLogoPainter extends CustomPainter {
  KitobLogoPainter(this.progress);
  final double progress;

  /// Logotip shaklidagi asosiy nuqtalar (0..1 koordinatada) — splash zarrachalari shu yerga yig'iladi.
  static const anchorPoints = <Offset>[
    Offset(0.32, 0.22), Offset(0.32, 0.36), Offset(0.32, 0.50), Offset(0.32, 0.64), Offset(0.32, 0.78),
    Offset(0.46, 0.50), Offset(0.56, 0.40), Offset(0.66, 0.30), Offset(0.74, 0.22),
    Offset(0.56, 0.60), Offset(0.66, 0.70), Offset(0.74, 0.78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28));
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [KColors.primary, KColors.cyan],
      ).createShader(rect);
    canvas.drawRRect(rrect, bg);

    // Yaltiroq qatlam
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, s, s * 0.55));
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s * 0.5), gloss);
    canvas.restore();

    final p = progress.clamp(0.0, 1.0);
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = s * 0.115
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Umurtqa
    final spine = Path()
      ..moveTo(s * 0.32, s * 0.22)
      ..lineTo(s * 0.32, s * 0.22 + s * 0.56 * _seg(p, 0, 0.4));
    canvas.drawPath(spine, stroke);

    // Yuqori chevron
    final t1 = _seg(p, 0.3, 0.7);
    if (t1 > 0) {
      final from = Offset(s * 0.46, s * 0.50);
      final to = Offset(s * 0.74, s * 0.22);
      canvas.drawLine(from, Offset.lerp(from, to, t1)!, stroke);
    }
    // Pastki chevron (cyan-oq)
    final t2 = _seg(p, 0.55, 1.0);
    if (t2 > 0) {
      final from = Offset(s * 0.53, s * 0.57);
      final to = Offset(s * 0.74, s * 0.78);
      canvas.drawLine(
        from,
        Offset.lerp(from, to, t2)!,
        stroke..color = const Color(0xFFDFF6FF),
      );
    }
  }

  double _seg(double p, double a, double b) => ((p - a) / (b - a)).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(KitobLogoPainter old) => old.progress != progress;
}
