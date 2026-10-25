import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';
import '../../shared/logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _Particle {
  _Particle(this.symbol, this.start, this.target, this.delay, this.color);
  final String symbol;
  final Offset start;
  final Offset target;
  final double delay;
  final Color color;
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;
  bool _left = false;
  Timer? _fallback;

  static const _symbols = ['{', '}', ';', '=>', '(', ')', '<>', '[', ']', 'var', '\$', 'int', '?', '!', '//', '=='];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    final rnd = math.Random(7);
    _particles = [
      for (var i = 0; i < 24; i++)
        _Particle(
          _symbols[i % _symbols.length],
          Offset(math.cos(i * 2.4) * (1.1 + rnd.nextDouble() * 0.6), math.sin(i * 2.4) * (1.1 + rnd.nextDouble() * 0.6)),
          KitobLogoPainter.anchorPoints[i % KitobLogoPainter.anchorPoints.length],
          rnd.nextDouble() * 0.25,
          i.isEven ? KColors.primary : KColors.cyan,
        ),
    ];
    final firstTime = settings.launchCount == 0;
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: firstTime ? 1900 : 900));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduce = reduceMotionOf(context, settings);
      if (reduce) _c.duration = const Duration(milliseconds: 350);
      ref.read(settingsProvider.notifier).registerLaunch();
      _c.forward().whenComplete(_leave);
      // Brauzer fon tabida animatsiya kadrlarini to'xtatsa ham splash qotib qolmasin.
      _fallback = Timer(_c.duration! + const Duration(milliseconds: 600), _leave);
    });
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    final done = ref.read(settingsProvider).onboardingDone;
    context.go(done ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context, ref.watch(settingsProvider));
    final dark = context.isDark;
    return Scaffold(
      backgroundColor: dark ? KColors.navy : KColors.surfaceWhite,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: Semantics(
          label: 'FLUTTER_KITOB yuklanmoqda. O\'tkazib yuborish uchun bosing.'.uz,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              const logoSize = 112.0;
              final fly = Curves.easeInOutCubic.transform(_seg(t, 0.0, 0.55));
              final logoP = Curves.easeOutCubic.transform(_seg(t, 0.42, 0.8));
              final title = Curves.easeOutCubic.transform(_seg(t, 0.62, 1.0));
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Fon nuri
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.9,
                          colors: [KColors.primary.withValues(alpha: (dark ? 0.25 : 0.12) * logoP), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  if (!reduce)
                    for (final p in _particles)
                      Builder(builder: (context) {
                        final local = Curves.easeOutCubic.transform(((fly - p.delay) / (1 - p.delay)).clamp(0.0, 1.0));
                        final screen = MediaQuery.sizeOf(context);
                        final startPx = Offset(p.start.dx * screen.width * 0.5, p.start.dy * screen.height * 0.5);
                        final targetPx = Offset((p.target.dx - 0.5) * logoSize, (p.target.dy - 0.5) * logoSize - 24);
                        final pos = Offset.lerp(startPx, targetPx, local)!;
                        final opacity = (_seg(t, 0.0, 0.15) * (1 - _seg(t, 0.5, 0.72))).clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: pos,
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.rotate(
                              angle: (1 - local) * 2.2,
                              child: Text(p.symbol,
                                  style: codeStyle(size: 18 - local * 6, color: p.color, weight: FontWeight.w700)),
                            ),
                          ),
                        );
                      }),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Opacity(
                      opacity: reduce ? 1 : _seg(t, 0.4, 0.6),
                      child: Transform.scale(
                        scale: reduce ? 1 : 0.85 + 0.15 * Curves.easeOutBack.transform(logoP),
                        child: KitobLogo(size: logoSize, progress: reduce ? 1 : logoP),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.sizeOf(context).height / 2 + 56,
                    child: Opacity(
                      opacity: reduce ? 1 : title,
                      child: Transform.translate(
                        offset: Offset(0, reduce ? 0 : 14 * (1 - title)),
                        child: Column(children: [
                          ShaderMask(
                            shaderCallback: (r) => KColors.brandGradient.createShader(r),
                            child: Text('FLUTTER_KITOB',
                                style: context.text.headlineMedium!.copyWith(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 6),
                          Text('O\'rgan. Kod yoz. Yarat.'.uz, style: context.text.bodyMedium),
                        ]),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
