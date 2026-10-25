import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system/components.dart';
import '../core/design_system/rich_text.dart';
import '../core/design_system/tokens.dart';
import '../core/state/progress.dart';

/// Yangi yutuq ochilganda ekranning yuqorisida chiroyli bildirishnoma ko'rsatadi.
class CelebrationListener extends ConsumerStatefulWidget {
  const CelebrationListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<CelebrationListener> createState() =>
      _CelebrationListenerState();
}

class _CelebrationListenerState extends ConsumerState<CelebrationListener> {
  final _queue = <String>[];
  AchievementDef? _current;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _enqueue(List<String> ids) {
    _queue.addAll(ids);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).consumeCelebrations(),
    );
    if (_current == null) _next();
  }

  void _next() {
    if (_queue.isEmpty) {
      setState(() => _current = null);
      return;
    }
    final def = achievementById(_queue.removeAt(0));
    if (def == null) return _next();
    HapticFeedback.mediumImpact();
    setState(() => _current = def);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() => _current = null);
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) _next();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<String>>(progressProvider.select((s) => s.celebrations), (
      prev,
      next,
    ) {
      if (next.isNotEmpty) _enqueue(next);
    });
    final def = _current;
    return Stack(
      children: [
        widget.child,
        // Bildirishnoma ostidagi tugmalarni to'smasligi uchun bosishlar o'tkaziladi.
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
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -1.4),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: def == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(def.id),
                          padding: const EdgeInsets.all(12),
                          child: GestureDetector(
                            onTap: () => setState(() => _current = null),
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: context.k.surface,
                                  borderRadius: BorderRadius.circular(
                                    KRadius.xl,
                                  ),
                                  border: Border.all(
                                    color: def.color.withValues(alpha: 0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: def.color.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.4, end: 1),
                                      duration: const Duration(
                                        milliseconds: 700,
                                      ),
                                      curve: Curves.elasticOut,
                                      builder: (c, v, child) => Transform.scale(
                                        scale: v,
                                        child: child,
                                      ),
                                      child: KIconBox(
                                        def.icon,
                                        color: def.color,
                                        size: 50,
                                        filled: true,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Yangi yutuq!'.uz,
                                            style: context.text.labelSmall!
                                                .copyWith(color: def.color),
                                          ),
                                          const SizedBox(height: 2),
                                          UzText(
                                            def.title,
                                            style: context.text.titleMedium,
                                          ),
                                          UzText(
                                            def.description,
                                            style: context.text.bodySmall,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (def.xp > 0)
                                      KBadge(
                                        '+${def.xp} XP',
                                        color: KColors.warning,
                                        solid: true,
                                      ),
                                  ],
                                ),
                              ),
                            ),
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
