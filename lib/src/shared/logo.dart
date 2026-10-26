import 'package:flutter/material.dart';

import '../core/design_system/tokens.dart';

/// FLUTTER_KITOB belgisi: gradientli kvadrat ichida ochiq kitob — o'ng
/// sahifada `</>` kod belgisi, pastda to'q sariq xatcho'p.
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
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0).toDouble(),
        child: Image.asset(
          'assets/flutter_kitob_logo.png',
          fit: BoxFit.contain,
          semanticLabel: 'FLUTTER_KITOB logotipi',
        ),
      ),
    ),
  );
}

class KitobLogoPainter extends CustomPainter {
  KitobLogoPainter(this.progress, {this.radius = 0.28, this.background = true, this.glyphScale = 1});
  final double progress;

  /// Burchak radiusi (o'lchamga nisbatan). App Store ikonkasi uchun 0 — burchakni tizim o'zi yumaloqlaydi.
  final double radius;

  /// `false` — faqat oq belgi (Android adaptive ikonkaning old qatlami).
  final bool background;

  /// Belgini markaz atrofida kichraytirish (adaptive ikonka xavfsiz zonasi uchun).
  final double glyphScale;

  /// Logotip shaklidagi asosiy nuqtalar (0..1 koordinatada) — splash zarrachalari shu yerga yig'iladi.
  static const anchorPoints = <Offset>[
    // Chap sahifa qirrasi, umurtqa va o'ng sahifa — splash zarrachalari shu yerga yig'iladi.
    Offset(0.18, 0.30), Offset(0.18, 0.50), Offset(0.18, 0.70), Offset(0.34, 0.27), Offset(0.34, 0.73),
    Offset(0.50, 0.32), Offset(0.50, 0.55), Offset(0.50, 0.78),
    Offset(0.66, 0.27), Offset(0.66, 0.73), Offset(0.82, 0.30), Offset(0.82, 0.70),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(s * radius));
    if (background) _paintBackground(canvas, s, rect, rrect);

    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.scale(glyphScale);
    canvas.translate(-s / 2, -s / 2);
    _paintGlyph(canvas, s);
    canvas.restore();
  }

  void _paintBackground(Canvas canvas, double s, Rect rect, RRect rrect) {
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
  }

  /// Ochiq kitob: chap sahifada matn qatorlari, o'ngda `</>` kod belgisi,
  /// pastda xatcho'p. [progress] bo'yicha bosqichma-bosqich chiziladi (splash).
  void _paintGlyph(Canvas canvas, double s) {
    final p = progress.clamp(0.0, 1.0);
    Offset o(double x, double y) => Offset(s * x, s * y);

    // 1) Sahifalar markazdan ochiladi.
    final open = Curves.easeOutBack.transform(_seg(p, 0, 0.45));
    if (open > 0) {
      canvas.save();
      canvas.translate(s * 0.5, 0);
      canvas.scale(open.clamp(0.0, 1.1), 1);
      canvas.translate(-s * 0.5, 0);
      Path page(double dir) => Path()
        ..moveTo(s * 0.5, s * 0.33)
        ..quadraticBezierTo(s * (0.5 + dir * 0.16), s * 0.22, s * (0.5 + dir * 0.33), s * 0.27)
        ..lineTo(s * (0.5 + dir * 0.33), s * 0.71)
        ..quadraticBezierTo(s * (0.5 + dir * 0.16), s * 0.67, s * 0.5, s * 0.78)
        ..close();
      // Muqova qirrasi — sahifalar ostida to'qroq chiziq.
      for (final dir in [-1.0, 1.0]) {
        canvas.drawPath(page(dir).shift(o(0, 0.035)), Paint()..color = const Color(0xFF0B3F8F).withValues(alpha: background ? 0.55 : 0.0));
      }
      canvas.drawPath(page(-1), Paint()..color = Colors.white);
      canvas.drawPath(page(1), Paint()..color = const Color(0xFFEAF6FF));
      // Umurtqa soyasi.
      canvas.drawLine(o(0.5, 0.34), o(0.5, 0.77), Paint()
        ..color = KColors.primary.withValues(alpha: background ? 0.35 : 0)
        ..strokeWidth = s * 0.012);
      // Chap sahifadagi matn qatorlari.
      final line = Paint()
        ..color = const Color(0xFF9ED0FF)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * 0.035;
      for (final (y, w) in const [(0.40, 0.17), (0.49, 0.2), (0.58, 0.14)]) {
        canvas.drawLine(o(0.25, y), o(0.25 + w, y - 0.012), line);
      }
      canvas.restore();
    }

    // 2) O'ng sahifada `</>` — kod belgisi chiziladi.
    final code = _seg(p, 0.35, 0.8);
    if (code > 0) {
      final pen = Paint()
        ..color = KColors.primary
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.04;
      final marks = [
        [o(0.605, 0.435), o(0.565, 0.5), o(0.605, 0.565)],
        [o(0.68, 0.41), o(0.65, 0.59)],
        [o(0.725, 0.435), o(0.765, 0.5), o(0.725, 0.565)],
      ];
      for (var i = 0; i < marks.length; i++) {
        final t = _seg(code, i / 3, (i + 1) / 3);
        if (t <= 0) continue;
        final path = Path()..moveTo(marks[i][0].dx, marks[i][0].dy);
        for (final pt in marks[i].skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        for (final m in path.computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * t), pen);
        }
      }
    }

    // 3) Xatcho'p tushadi.
    final ribbon = _seg(p, 0.7, 1);
    if (ribbon > 0) {
      final h = 0.14 * Curves.easeOutBack.transform(ribbon);
      final r = Path()
        ..moveTo(s * 0.4, s * 0.73)
        ..lineTo(s * 0.4, s * (0.73 + h))
        ..lineTo(s * 0.43, s * (0.73 + h - 0.03))
        ..lineTo(s * 0.46, s * (0.73 + h))
        ..lineTo(s * 0.46, s * 0.73)
        ..close();
      canvas.drawPath(r, Paint()..color = KColors.orange);
    }
  }

  double _seg(double p, double a, double b) => ((p - a) / (b - a)).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(KitobLogoPainter old) =>
      old.progress != progress || old.radius != radius || old.background != background || old.glyphScale != glyphScale;
}
