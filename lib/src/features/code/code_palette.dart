import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';

CodePalette codePaletteOf(WidgetRef ref) => ref.watch(settingsProvider).editorDark ? CodePalette.dark : CodePalette.light;

Color colorForKind(CodePalette p, HighlightKind k) => switch (k) {
  HighlightKind.keyword => p.keyword,
  HighlightKind.control => p.control,
  HighlightKind.type => p.type,
  HighlightKind.function => p.function,
  HighlightKind.string => p.string,
  HighlightKind.number => p.number,
  HighlightKind.comment => p.comment,
  HighlightKind.operator => p.operator,
  HighlightKind.punctuation => p.text.withValues(alpha: 0.75),
  HighlightKind.annotation => p.annotation,
  HighlightKind.literal => p.literal,
  HighlightKind.interpolation => p.interpolation,
  HighlightKind.identifier || HighlightKind.plain => p.text,
};

TextStyle codeTextStyle(double size, Color color) => codeStyle(size: size, color: color);

/// Barcha qatorlar balandligi bir xil bo'lishi uchun (raqamlar bilan tekislash).
StrutStyle codeStrut(double size) =>
    StrutStyle(fontFamily: kCodeFont, fontSize: size, height: 1.55, forceStrutHeight: true, leading: 0);

double codeLineHeight(double size) => size * 1.55;
