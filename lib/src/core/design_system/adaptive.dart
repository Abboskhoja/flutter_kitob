import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/settings.dart';
import 'rich_text.dart';
import 'tokens.dart';

/// Platformaga xos vizual til.
///
/// * [glass] — iOS / macOS: "Liquid Glass" — xira, yorug'likni sindiradigan
///   shaffof yuzalar, suzuvchi boshqaruvlar.
/// * [material] — Android: Material 3 Expressive — tonal yuzalar, pill
///   indikatorlar, sakrovchi harakat.
/// * [web] — brauzer: aniq chegaralar, hover va klaviatura uchun holatlar.
enum KLook { glass, material, web }

KLook resolveLook(LookPref pref, {TargetPlatform? platform, bool? web}) {
  switch (pref) {
    case LookPref.glass:
      return KLook.glass;
    case LookPref.material:
      return KLook.material;
    case LookPref.auto:
      if (web ?? kIsWeb) return KLook.web;
      final p = platform ?? defaultTargetPlatform;
      return p == TargetPlatform.iOS || p == TargetPlatform.macOS ? KLook.glass : KLook.material;
  }
}

class KLookScope extends InheritedWidget {
  const KLookScope({super.key, required this.look, required super.child});
  final KLook look;

  static KLook of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<KLookScope>()?.look ?? KLook.material;

  @override
  bool updateShouldNotify(KLookScope old) => old.look != look;
}

extension KLookX on BuildContext {
  KLook get look => KLookScope.of(this);
  bool get isGlass => look == KLook.glass;
}

/// Platformaga mos "yengil" haptik javob (iOS'da selection, Android'da click).
void kHaptic(BuildContext context) {
  context.isGlass ? HapticFeedback.selectionClick() : HapticFeedback.lightImpact();
}

/// Orqasidagi kontent ko'rinib turadigan yuza.
///
/// Glass uslubida: kuchli xiralash + to'yinganlik (rang "suvdan" o'tgandek
/// jonliroq ko'rinadi), yorug'lik tushgan qirralar va ichki yaltiroqlik.
/// Material/Web uslubida: yarim shaffof tonal yuza va yumshoq xiralash.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(KRadius.xl)),
    this.padding = EdgeInsets.zero,
    this.circle = false,
    this.strong = false,
    this.tint,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final bool circle;

  /// Ustma-ust turgan elementlar (masalan, tanlangan "linza") uchun yorqinroq.
  final bool strong;
  final Color? tint;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final look = context.look;
    final dark = context.isDark;
    final k = context.k;
    final r = circle ? BorderRadius.circular(999) : radius;
    final glass = look == KLook.glass;

    final double sigma = glass ? 22 : (look == KLook.web ? 20 : 14);
    final ui.ImageFilter filter = glass
        ? ui.ImageFilter.compose(outer: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma), inner: _saturate(1.8))
        : ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

    final base = tint ?? (dark ? const Color(0xFF16203A) : Colors.white);
    final fill = glass
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: (dark ? 0.52 : 0.62) + (strong ? 0.18 : 0)),
              base.withValues(alpha: (dark ? 0.34 : 0.4) + (strong ? 0.18 : 0)),
            ],
          )
        : null;

    Widget surface = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: filter,
        child: CustomPaint(
          foregroundPainter: glass ? _GlassEdgePainter(r, dark, strong) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: fill,
              color: glass ? null : (tint ?? k.surface).withValues(alpha: look == KLook.web ? 0.78 : 0.86),
              borderRadius: r,
              border: glass ? null : Border.all(color: k.border.withValues(alpha: look == KLook.web ? 1 : 0.6)),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
    if (shadow) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.35 : (glass ? 0.1 : 0.07)), blurRadius: glass ? 28 : 18, offset: const Offset(0, 8)),
          ],
        ),
        child: surface,
      );
    }
    return surface;
  }

  static ColorFilter _saturate(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final a = 1 - s;
    return ColorFilter.matrix([
      r * a + s, g * a, b * a, 0, 0,
      r * a, g * a + s, b * a, 0, 0,
      r * a, g * a, b * a + s, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }
}

/// Shisha qirrasi: yuqori-chapdan tushgan yorug'lik va pastki-o'ngdagi aks.
class _GlassEdgePainter extends CustomPainter {
  _GlassEdgePainter(this.radius, this.dark, this.strong);
  final BorderRadius radius;
  final bool dark;
  final bool strong;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = radius.toRRect(rect).deflate(0.5);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.45 : 0.95),
          Colors.white.withValues(alpha: dark ? 0.06 : 0.25),
          Colors.white.withValues(alpha: dark ? 0.22 : 0.6),
        ],
        stops: const [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, edge);
    // Ichki yaltiroqlik — yuqori qismda yumshoq oq nur.
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [Colors.white.withValues(alpha: (dark ? 0.1 : 0.35) + (strong ? 0.1 : 0)), Colors.white.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(rect, gloss);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassEdgePainter o) => o.dark != dark || o.strong != strong || o.radius != radius;
}

/// Suzuvchi dumaloq tugma (orqaga, sozlamalar va h.k.).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 44, this.badge, this.dark = false});
  final bool dark;
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final btn = Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: size,
          height: size,
          child: Glass(
            circle: true,
            shadow: context.isGlass,
            tint: dark ? const Color(0xFF1D2A47) : null,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed == null
                    ? null
                    : () {
                        kHaptic(context);
                        onPressed!();
                      },
                child: Center(child: Icon(icon, size: size * 0.48, color: dark ? Colors.white : context.k.text)),
              ),
            ),
          ),
        ),
      ),
    );
    if (badge == null) return btn;
    return Stack(clipBehavior: Clip.none, children: [btn, Positioned(right: -4, top: -4, child: badge!)]);
  }
}

/// AppBar o'rnini bosuvchi suzuvchi yuqori qism: alohida "panel" yo'q —
/// kontent ekranning eng tepasigacha boradi, ustida faqat shisha tugmalar
/// va o'qilishi uchun yumshoq gradient.
///
/// `Scaffold(extendBodyBehindAppBar: true, appBar: KTopBar(...))` bilan ishlatiladi.
class KTopBar extends StatelessWidget implements PreferredSizeWidget {
  const KTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.center,
    this.actions = const [],
    this.leading,
    this.showBack = true,
    this.bottom,
    this.bottomHeight = 0,
    this.close = false,
    this.onBack,
    this.dark = false,
    this.background,
  });

  /// Gradient foni (standart: sahifa foni).
  final Color? background;

  final String? title;

  /// [title] o'rniga ixtiyoriy vidjet (masalan, qidiruv maydoni).
  final Widget? center;
  final bool showBack;
  final String? subtitle;
  final List<Widget> actions;

  /// `null` — orqaga tugmasi avtomatik (sahifani yopish mumkin bo'lsa).
  final Widget? leading;
  final Widget? bottom;
  final double bottomHeight;

  /// Orqaga strelka o'rniga ✕ (immersiv sahifalar: dars, imtihon).
  final bool close;
  final VoidCallback? onBack;

  /// Qorong'i fonli sahifalar (kod muharriri, terminal) uchun.
  final bool dark;

  static const height = 60.0;

  @override
  Size get preferredSize => Size.fromHeight(height + bottomHeight);

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final bg = background ?? (dark ? const Color(0xFF0B1220) : k.background);
    final back = onBack ?? (Navigator.of(context).canPop() ? () => Navigator.of(context).maybePop() : null);
    final lead = leading ??
        (back == null || !showBack
            ? null
            : GlassIconButton(
                icon: close ? Icons.close_rounded : (context.isGlass ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded),
                tooltip: close ? 'Yopish' : 'Orqaga',
                onPressed: back,
                dark: dark,
              ));
    final top = MediaQuery.paddingOf(context).top;
    return Stack(children: [
      // Kontent tugmalar ostidan o'tganda ham matn o'qilsin. Fon bosishlarni
      // o'tkazadi — faqat tugmalarning o'zi bosiladi, ortidagi kontent emas.
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bg.withValues(alpha: 0.96), bg.withValues(alpha: 0.82), bg.withValues(alpha: 0)],
                stops: const [0, 0.7, 1],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: top),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                ?lead,
                if (center != null)
                  Expanded(child: Padding(padding: const EdgeInsets.only(left: 10), child: center))
                else if (title != null)
                  Expanded(
                    // Sarlavha bosishlarni "yutmasin": uning ortidagi kontent bosiladigan qolsin.
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title!.uz, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium!.copyWith(fontWeight: FontWeight.w800, color: dark ? Colors.white : null)),
                          if (subtitle != null)
                            Text(subtitle!.uz, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall!.copyWith(color: dark ? Colors.white70 : null)),
                        ]),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                for (final a in actions) Padding(padding: const EdgeInsets.only(left: 8), child: a),
              ]),
            ),
          ),
          if (bottom != null) SizedBox(height: bottomHeight, child: bottom),
        ]),
      ),
    ]);
  }
}
