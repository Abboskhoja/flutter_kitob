import 'package:flutter/material.dart';

/// FLUTTER_KITOB brend ranglari.
abstract final class KColors {
  static const primary = Color(0xFF087CF7);
  static const cyan = Color(0xFF03B8E8);
  static const navy = Color(0xFF0B1220);
  static const surfaceWhite = Color(0xFFF8FAFD);
  static const softBlue = Color(0xFFEAF4FF);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const violet = Color(0xFF7C5CFF);
  static const pink = Color(0xFFEC4899);
  static const orange = Color(0xFFF97316);
  static const teal = Color(0xFF14B8A6);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, cyan],
  );
}

abstract final class KSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 48.0;
}

abstract final class KRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const pill = 999.0;
}

/// Ekran kengligiga qarab moslashuv chegaralari (content-based).
abstract final class KBreakpoints {
  static const medium = 600.0;
  static const expanded = 1024.0;
  static const maxContent = 1180.0;
  static const maxReading = 760.0;
}

abstract final class KDurations {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 450);
  static const lazy = Duration(milliseconds: 800);
}

/// Kod sintaksis ranglari (editor va kod bloklari uchun).
class CodePalette {
  const CodePalette({
    required this.background,
    required this.gutter,
    required this.lineNumber,
    required this.activeLine,
    required this.text,
    required this.keyword,
    required this.control,
    required this.type,
    required this.function,
    required this.string,
    required this.number,
    required this.comment,
    required this.operator,
    required this.literal,
    required this.annotation,
    required this.interpolation,
    required this.selection,
    required this.bracketMatch,
    required this.isDark,
  });

  final Color background;
  final Color gutter;
  final Color lineNumber;
  final Color activeLine;
  final Color text;
  final Color keyword;
  final Color control;
  final Color type;
  final Color function;
  final Color string;
  final Color number;
  final Color comment;
  final Color operator;
  final Color literal;
  final Color annotation;
  final Color interpolation;
  final Color selection;
  final Color bracketMatch;
  final bool isDark;

  static const dark = CodePalette(
    background: Color(0xFF0D1526),
    gutter: Color(0xFF0A1120),
    lineNumber: Color(0xFF4B5A78),
    activeLine: Color(0xFF16213A),
    text: Color(0xFFE4EAF6),
    keyword: Color(0xFF5FB4FF),
    control: Color(0xFFC792EA),
    type: Color(0xFF4FD1C5),
    function: Color(0xFFFFCB6B),
    string: Color(0xFFA5E38B),
    number: Color(0xFFF78C6C),
    comment: Color(0xFF6B7A99),
    operator: Color(0xFF89DDFF),
    literal: Color(0xFFFF8FA3),
    annotation: Color(0xFFB4BCFF),
    interpolation: Color(0xFF89DDFF),
    selection: Color(0x553A7BD5),
    bracketMatch: Color(0x5503B8E8),
    isDark: true,
  );

  static const light = CodePalette(
    background: Color(0xFFF6F9FE),
    gutter: Color(0xFFEDF2FA),
    lineNumber: Color(0xFF94A3B8),
    activeLine: Color(0xFFE7F0FD),
    text: Color(0xFF1E293B),
    keyword: Color(0xFF0B63CE),
    control: Color(0xFF8B2FC9),
    type: Color(0xFF0E7C86),
    function: Color(0xFFB45309),
    string: Color(0xFF15803D),
    number: Color(0xFFC2410C),
    comment: Color(0xFF7C8AA5),
    operator: Color(0xFF0369A1),
    literal: Color(0xFFBE185D),
    annotation: Color(0xFF6366F1),
    interpolation: Color(0xFF0369A1),
    selection: Color(0x44087CF7),
    bracketMatch: Color(0x3303B8E8),
    isDark: false,
  );
}

/// Light/Dark rejimga qarab o'zgaradigan semantik ranglar.
@immutable
class KitobColors extends ThemeExtension<KitobColors> {
  const KitobColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceHigh,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.primarySoft,
    required this.successSoft,
    required this.warningSoft,
    required this.errorSoft,
    required this.successText,
    required this.warningText,
    required this.errorText,
    required this.shadow,
    required this.console,
    required this.consoleText,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceHigh;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color primarySoft;
  final Color successSoft;
  final Color warningSoft;
  final Color errorSoft;
  final Color successText;
  final Color warningText;
  final Color errorText;
  final Color shadow;
  final Color console;
  final Color consoleText;

  static const light = KitobColors(
    background: KColors.surfaceWhite,
    surface: Colors.white,
    surfaceAlt: Color(0xFFF1F5FB),
    surfaceHigh: Color(0xFFE9EFF8),
    border: Color(0xFFE2E8F2),
    borderStrong: Color(0xFFCBD5E1),
    text: Color(0xFF0B1220),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF7A8699),
    primarySoft: KColors.softBlue,
    successSoft: Color(0xFFE8F8EE),
    warningSoft: Color(0xFFFFF5E1),
    errorSoft: Color(0xFFFDECEC),
    successText: Color(0xFF15803D),
    warningText: Color(0xFFB45309),
    errorText: Color(0xFFDC2626),
    shadow: Color(0x140B1220),
    console: Color(0xFF0B1220),
    consoleText: Color(0xFFE2E8F0),
  );

  static const dark = KitobColors(
    background: KColors.navy,
    surface: Color(0xFF111A2E),
    surfaceAlt: Color(0xFF16213A),
    surfaceHigh: Color(0xFF1D2A47),
    border: Color(0xFF223052),
    borderStrong: Color(0xFF314270),
    text: Color(0xFFF1F5FB),
    textSecondary: Color(0xFFB4C0D6),
    textMuted: Color(0xFF8391AD),
    primarySoft: Color(0xFF12284A),
    successSoft: Color(0xFF0F2A1C),
    warningSoft: Color(0xFF2E2210),
    errorSoft: Color(0xFF331617),
    successText: Color(0xFF4ADE80),
    warningText: Color(0xFFFBBF24),
    errorText: Color(0xFFF87171),
    shadow: Color(0x66000000),
    console: Color(0xFF070C17),
    consoleText: Color(0xFFE2E8F0),
  );

  @override
  KitobColors copyWith() => this;

  @override
  KitobColors lerp(KitobColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KitobColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      primarySoft: l(primarySoft, other.primarySoft),
      successSoft: l(successSoft, other.successSoft),
      warningSoft: l(warningSoft, other.warningSoft),
      errorSoft: l(errorSoft, other.errorSoft),
      successText: l(successText, other.successText),
      warningText: l(warningText, other.warningText),
      errorText: l(errorText, other.errorText),
      shadow: l(shadow, other.shadow),
      console: l(console, other.console),
      consoleText: l(consoleText, other.consoleText),
    );
  }
}

extension KitobThemeX on BuildContext {
  KitobColors get k => Theme.of(this).extension<KitobColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isCompact => screenWidth < KBreakpoints.medium;
  bool get isExpanded => screenWidth >= KBreakpoints.expanded;
}
