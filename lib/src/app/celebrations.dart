import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system/components.dart';
import '../core/design_system/motion.dart';
import '../core/design_system/rich_text.dart';
import '../core/design_system/tokens.dart';
import '../core/sound/sounds.dart';
import '../core/state/progress.dart';
import '../core/state/settings.dart';

/// Ekran yuqorisidagi bildirishnoma: yutuq, yangi daraja yoki kunlik maqsad.
class _Toast {
  const _Toast({
    required this.id,
    required this.icon,
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.badge,
    this.levelUp,
  });

  final String id;
  final IconData icon;
  final Color color;
  final String eyebrow;
  final String title;
  final String description;
  final String? badge;

  /// Berilsa, katta "daraja oshdi" kartasi ko'rsatiladi.
  final int? levelUp;
}

/// Progressdagi o'zgarishlarni kuzatib, quvonchli lahzalarni ko'rsatadi:
/// XP uchib chiqishi, yangi yutuq, daraja oshishi, kunlik maqsad va konfetti.
///
/// Hammasi `IgnorePointer` ostida — o'quvchining ishini hech qachon to'smaydi.
class CelebrationListener extends ConsumerStatefulWidget {
  const CelebrationListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<CelebrationListener> createState() => _CelebrationListenerState();
}

class _CelebrationListenerState extends ConsumerState<CelebrationListener> with TickerProviderStateMixin {
  final _queue = <_Toast>[];
  _Toast? _current;

  // Timer o'rniga controller: vidjet yo'q qilinganda o'zi to'xtaydi.
  late final _life = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  late final _gap = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late final _xpAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  int _xpShown = 0;

  final _bursts = <int>[];
  int _burstSeq = 0;

  @override
  void dispose() {
    _life.dispose();
    _gap.dispose();
    _xpAnim.dispose();
    super.dispose();
  }

  void _push(_Toast t) {
    _queue.add(t);
    if (_current == null && !_gap.isAnimating) _next();
  }

  void _next() {
    if (!mounted) return;
    if (_queue.isEmpty) {
      setState(() => _current = null);
      return;
    }
    final t = _queue.removeAt(0);
    HapticFeedback.mediumImpact();
    setState(() => _current = t);
    _life.duration = Duration(milliseconds: t.levelUp != null ? 3600 : 2800);
    _life.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _current = null);
      _gap.forward(from: 0).whenComplete(_next);
    });
  }

  void _burst() {
    Sounds.play(Sfx.celebrate);
    if (KMotion.off(context)) return;
    setState(() => _bursts.add(_burstSeq++));
  }

  void _flyXp(int amount) {
    if (KMotion.off(context)) return;
    // Ketma-ket kelgan XP lar bitta yozuvga yig'iladi.
    _xpShown = _xpAnim.isAnimating ? _xpShown + amount : amount;
    _xpAnim.forward(from: 0);
    setState(() {});
  }

  void _onProgress(ProgressState? prev, ProgressState next) {
    if (prev == null) return;
    // Muhimlik tartibida: daraja → kunlik maqsad → yutuqlar.
    final toasts = <_Toast>[];
    var big = false;

    // Qayta o'rnatish (reset) XP ni kamaytiradi — buni bayram qilmaymiz.
    final gained = next.xp - prev.xp;
    if (gained > 0) {
      _flyXp(gained);
      if (next.userLevel > prev.userLevel) {
        big = true;
        toasts.add(_Toast(
          id: 'lvl-${next.userLevel}',
          icon: Icons.rocket_launch_rounded,
          color: KColors.violet,
          eyebrow: 'XP darajasi oshdi!',
          title: 'Lv ${next.userLevel} ga chiqdingiz',
          description: 'Lv ${next.userLevel + 1} gacha ${next.xpToNext} XP. Shu sur\'atda davom eting!',
          levelUp: next.userLevel,
        ));
      }
      final goal = ref.read(settingsProvider).dailyGoalXp;
      final today = DateTime.now();
      if (goal > 0 && prev.xpOn(today) < goal && next.xpOn(today) >= goal) {
        big = true;
        toasts.add(_Toast(
          id: 'goal-${dayKey(today)}',
          icon: Icons.local_fire_department_rounded,
          color: KColors.orange,
          eyebrow: 'Kunlik maqsad bajarildi!',
          title: next.streak > 1 ? '${next.streak} kunlik seriya 🔥' : 'Seriya boshlandi 🔥',
          description: 'Ertaga ham qaytib keling — seriya uzilmasin.',
        ));
      }
      if (next.completedCount > prev.completedCount) big = true;
    }

    if (next.celebrations.isNotEmpty) {
      for (final id in next.celebrations) {
        final def = achievementById(id);
        if (def == null) continue;
        toasts.add(_Toast(
          id: 'ach-$id',
          icon: def.icon,
          color: def.color,
          eyebrow: 'Yangi yutuq!',
          title: def.title,
          description: def.description,
          badge: def.xp > 0 ? '+${def.xp} XP' : null,
        ));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(progressProvider.notifier).consumeCelebrations());
    }

    toasts.forEach(_push);
    if (big || next.achievements.length > prev.achievements.length) _burst();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProgressState>(progressProvider, _onProgress);
    final t = _current;
    return Stack(
      children: [
        widget.child,
        for (final id in _bursts)
          Positioned.fill(
            child: ConfettiLayer(
              key: ValueKey('burst-$id'),
              onDone: () {
                if (mounted) setState(() => _bursts.remove(id));
              },
            ),
          ),
        // XP yozuvi: pastdan yuqoriga suzib, so'nib ketadi.
        Positioned(
          left: 0,
          right: 0,
          bottom: 110,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _xpAnim,
              builder: (context, _) {
                final v = _xpAnim.value;
                if (v == 0 || v == 1) return const SizedBox.shrink();
                final appear = Curves.easeOutBack.transform((v / 0.25).clamp(0.0, 1.0));
                final fade = v < 0.7 ? 1.0 : 1 - (v - 0.7) / 0.3;
                return Center(
                  child: Opacity(
                    opacity: fade.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, -70 * Curves.easeOut.transform(v)),
                      child: Transform.scale(scale: 0.6 + 0.4 * appear, child: _XpPill(amount: _xpShown)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: IgnorePointer(
            child: SafeArea(
              child: Center(
                child: AnimatedSwitcher(
                  duration: KDurations.slow,
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween(begin: const Offset(0, -1.4), end: Offset.zero).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: t == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(t.id),
                          padding: const EdgeInsets.all(12),
                          child: Material(
                            color: Colors.transparent,
                            child: t.levelUp != null ? _LevelUpCard(toast: t) : _ToastCard(toast: t),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _XpPill extends StatelessWidget {
  const _XpPill({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFB020), KColors.orange]),
        borderRadius: BorderRadius.circular(KRadius.pill),
        boxShadow: [BoxShadow(color: KColors.orange.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 8))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 4),
        Text('+$amount XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.3)),
      ]),
    ),
  );
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.toast});
  final _Toast toast;

  @override
  Widget build(BuildContext context) {
    final t = toast;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.k.surface,
        borderRadius: BorderRadius.circular(KRadius.xl),
        border: Border.all(color: t.color.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: t.color.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (c, v, child) => Transform.scale(scale: v, child: Transform.rotate(angle: (1 - v) * 0.6, child: child)),
            child: KIconBox(t.icon, color: t.color, size: 50, filled: true),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.eyebrow.uz, style: context.text.labelSmall!.copyWith(color: t.color)),
                const SizedBox(height: 2),
                UzText(t.title, style: context.text.titleMedium),
                UzText(t.description, style: context.text.bodySmall, maxLines: 2),
              ],
            ),
          ),
          if (t.badge != null) KBadge(t.badge!, color: KColors.warning, solid: true),
        ],
      ),
    );
  }
}

/// Daraja oshganda: aylanuvchi nurlar ustida katta raqam.
class _LevelUpCard extends StatelessWidget {
  const _LevelUpCard({required this.toast});
  final _Toast toast;

  @override
  Widget build(BuildContext context) {
    final t = toast;
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B1FA8), KColors.violet, Color(0xFF2E7BFF)],
        ),
        boxShadow: [BoxShadow(color: KColors.violet.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 16))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned.fill(child: Aurora(colors: const [KColors.pink, KColors.cyan, Color(0xFFFFC857)], period: const Duration(seconds: 6))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
          child: Row(children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(alignment: Alignment.center, children: [
                Ambient(
                  period: const Duration(seconds: 8),
                  builder: (context, v, _) => Transform.rotate(
                    angle: v * math.pi * 2,
                    child: const CustomPaint(size: Size(84, 84), painter: _RaysPainter()),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (c, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 18)],
                    ),
                    child: Text('${t.levelUp}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: KColors.violet)),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(t.eyebrow.uz.toUpperCase(),
                    style: const TextStyle(color: Color(0xFFFFE08A), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.4)),
                const SizedBox(height: 4),
                UzText(t.title, style: context.text.titleLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                UzText(t.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13), maxLines: 2),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.22);
    const n = 12;
    for (var i = 0; i < n; i++) {
      final a = i * math.pi * 2 / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.12) * r, c.dy + math.sin(a - 0.12) * r)
        ..lineTo(c.dx + math.cos(a + 0.12) * r, c.dy + math.sin(a + 0.12) * r)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => false;
}
