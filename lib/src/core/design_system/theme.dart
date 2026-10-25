import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

const kFontFamily = 'Inter';
const kCodeFont = 'JetBrainsMono';

abstract final class KitobTheme {
  static ThemeData light() => _build(Brightness.light, KitobColors.light);
  static ThemeData dark() => _build(Brightness.dark, KitobColors.dark);

  static TextTheme _text(Color strong, Color body, Color muted) => TextTheme(
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.8, color: strong),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.6, color: strong),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.22, letterSpacing: -0.4, color: strong),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: strong),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: strong),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: strong),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: strong),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: body),
    bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400, height: 1.55, color: body),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.45, color: muted),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2, color: strong),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2, color: body),
    labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.3, color: muted),
  );

  static ThemeData _build(Brightness b, KitobColors k) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: KColors.primary,
      brightness: b,
      primary: KColors.primary,
      secondary: KColors.cyan,
      error: KColors.error,
      surface: k.surface,
    );
    final text = _text(k.text, k.textSecondary, k.textMuted).apply(fontFamily: kFontFamily);
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      fontFamily: kFontFamily,
      scaffoldBackgroundColor: k.background,
      textTheme: text,
      extensions: [k],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: k.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        foregroundColor: k.text,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: k.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadius.lg),
          side: BorderSide(color: k.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: k.border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: k.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: k.primarySoft,
        height: 68,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? KColors.primary : k.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 24, color: s.contains(WidgetState.selected) ? KColors.primary : k.textMuted),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: k.surface,
        indicatorColor: k.primarySoft,
        selectedIconTheme: const IconThemeData(color: KColors.primary),
        unselectedIconTheme: IconThemeData(color: k.textMuted),
        selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: KColors.primary, fontSize: 12),
        unselectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w500, color: k.textMuted, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: k.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: k.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(KRadius.md), borderSide: BorderSide(color: k.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(KRadius.md), borderSide: BorderSide(color: k.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KRadius.md),
          borderSide: const BorderSide(color: KColors.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: k.surfaceAlt,
        selectedColor: k.primarySoft,
        side: BorderSide(color: k.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.pill)),
        labelStyle: TextStyle(fontFamily: kFontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: k.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: k.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(KRadius.xxl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: k.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1D2A47) : KColors.navy,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: kFontFamily, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.md)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2A3A60) : KColors.navy, borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12.5, fontFamily: kFontFamily),
        waitDuration: const Duration(milliseconds: 400),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 4, showValueIndicator: ShowValueIndicator.onDrag),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600, fontSize: 13)),
          side: WidgetStatePropertyAll(BorderSide(color: k.border)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.md)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: k.text,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: k.borderStrong),
          textStyle: const TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.md)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KColors.primary,
          textStyle: const TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(k.borderStrong),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}

/// Kod uchun shrift. Ligaturalar o'chirilgan: `<=` va `=>` boshlovchiga
/// aynan yozilganidek (ikki belgi) ko'rinishi kerak, `≤` / `⇒` emas.
TextStyle codeStyle({double size = 14, Color? color, FontWeight weight = FontWeight.w400}) => TextStyle(
  fontFamily: kCodeFont,
  fontSize: size,
  height: 1.55,
  color: color,
  fontWeight: weight,
  letterSpacing: 0,
  fontFeatures: const [FontFeature.disable('calt'), FontFeature.disable('liga')],
);
