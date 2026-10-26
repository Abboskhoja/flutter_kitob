import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/design_system/motion.dart';
import '../core/design_system/rich_text.dart';
import '../core/design_system/tokens.dart';

/// Bitik kayfiyati.
enum BitikMood {
  /// Oddiy holat: yengil suzib turadi.
  idle,

  /// To'g'ri javob, muvaffaqiyat.
  happy,

  /// Katta yutuq: tezroq sakraydi va yulduzcha ko'rsatadi.
  cheer,

  /// O'ylayapti: savol belgisi ko'rinadi.
  think,

  /// Xato bo'ldi — tanbeh emas, dalda.
  encourage,
}

/// **Bitik** — FLUTTER_KITOB maskoti.
///
/// Qadimgi turkiy "bitik" (kitob, yozuv) va dasturlashdagi "bit" so'zlaridan.
/// U — qanotli sahifalari, Dart kod yozilgan sahifasi va to'q sariq xatcho'pli
/// kitob. Holatlari yengil harakat va kichik belgilarda ko'rinadi.
class Bitik extends StatelessWidget {
  const Bitik({super.key, this.mood = BitikMood.idle, this.size = 96});
  final BitikMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fast = mood == BitikMood.cheer;
    final moodLabel = switch (mood) {
      BitikMood.idle => 'xotirjam',
      BitikMood.happy => 'xursand',
      BitikMood.cheer => 'g\'alabani nishonlayapti',
      BitikMood.think => 'o\'ylayapti',
      BitikMood.encourage => 'dalda beryapti',
    };
    return Semantics(
      label: 'Bitik — $moodLabel',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: RepaintBoundary(
          child: Ambient(
            period: Duration(milliseconds: fast ? 700 : 4200),
            builder: (context, t, _) {
              final bounce = fast
                  ? 5.0 * math.sin(t * math.pi * 2).abs()
                  : 1.5 * math.sin(t * math.pi * 2);
              final badge = switch (mood) {
                BitikMood.think => (
                  Icons.question_mark_rounded,
                  KColors.violet,
                ),
                BitikMood.cheer => (Icons.auto_awesome_rounded, KColors.orange),
                BitikMood.encourage => (Icons.favorite_rounded, KColors.pink),
                _ => null,
              };
              return Transform.translate(
                offset: Offset(0, -bounce),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/bitik_mascot.png',
                        fit: BoxFit.contain,
                        cacheWidth:
                            (size * MediaQuery.devicePixelRatioOf(context))
                                .round()
                                .clamp(96, 768),
                        excludeFromSemantics: true,
                      ),
                    ),
                    if (badge case final value?)
                      Positioned(
                        top: size * 0.02,
                        right: size * 0.03,
                        child: Container(
                          width: size * 0.27,
                          height: size * 0.27,
                          decoration: BoxDecoration(
                            color: context.k.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: value.$2.withValues(alpha: 0.22),
                                blurRadius: size * 0.08,
                                spreadRadius: size * 0.01,
                              ),
                            ],
                          ),
                          child: Icon(
                            value.$1,
                            size: size * 0.18,
                            color: value.$2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Bitik va uning gap pufagi.
class BitikSays extends StatelessWidget {
  const BitikSays({
    super.key,
    required this.text,
    this.mood = BitikMood.idle,
    this.size = 64,
    this.color,
  });
  final String text;
  final BitikMood mood;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final bubble = color ?? k.surface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Bitik(mood: mood, size: size),
        const SizedBox(width: 4),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubble,
                border: Border.all(color: k.border),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(KRadius.lg),
                  topRight: Radius.circular(KRadius.lg),
                  bottomRight: Radius.circular(KRadius.lg),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: k.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RichUz(
                text,
                style: context.text.bodyMedium!.copyWith(color: k.text),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
