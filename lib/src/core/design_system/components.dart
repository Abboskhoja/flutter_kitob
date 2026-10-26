import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/bitik.dart';
import 'adaptive.dart';
import 'motion.dart';
import 'rich_text.dart';
import 'theme.dart';
import 'tokens.dart';

/// Bosilganda biroz kichrayadigan (mikrointeraksiya) o'ram.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97, this.haptic = false});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: KDurations.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Asosiy karta komponenti.
class KCard extends StatefulWidget {
  const KCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(KSpace.lg),
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = KRadius.lg,
    this.semanticLabel,
    this.elevated = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final String? semanticLabel;
  final bool elevated;

  @override
  State<KCard> createState() => _KCardState();
}

class _KCardState extends State<KCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final interactive = widget.onTap != null;
    final card = AnimatedContainer(
      duration: KDurations.fast,
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.color ?? k.surface) : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: widget.borderColor ?? (_hover && interactive ? k.borderStrong : k.border)),
        boxShadow: [
          if (widget.elevated || (_hover && interactive))
            BoxShadow(color: k.shadow, blurRadius: _hover ? 24 : 16, offset: Offset(0, _hover ? 10 : 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onHover: interactive ? (v) => setState(() => _hover = v) : null,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      button: interactive,
      container: true,
      child: AnimatedSlide(
        offset: Offset(0, _hover && interactive ? -0.01 : 0),
        duration: KDurations.fast,
        // Web: bosiladigan kartalarda kursor ortidan yumshoq yorug'lik.
        child: Spotlight(enabled: interactive && context.look == KLook.web, radius: widget.radius, child: card),
      ),
    );
  }
}

enum KButtonVariant { primary, secondary, ghost, success, danger, dark }

class KButton extends StatelessWidget {
  const KButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = KButtonVariant.primary,
    this.loading = false,
    this.expand = false,
    this.compact = false,
    this.tooltip,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final KButtonVariant variant;
  final bool loading;
  final bool expand;
  final bool compact;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final (bg, fg, border) = switch (variant) {
      KButtonVariant.primary => (KColors.primary, Colors.white, Colors.transparent),
      KButtonVariant.secondary => (k.primarySoft, context.isDark ? const Color(0xFF8CC8FF) : KColors.primary, Colors.transparent),
      KButtonVariant.ghost => (Colors.transparent, k.text, k.borderStrong),
      KButtonVariant.success => (KColors.success, Colors.white, Colors.transparent),
      KButtonVariant.danger => (k.errorSoft, k.errorText, Colors.transparent),
      KButtonVariant.dark => (context.isDark ? Colors.white : KColors.navy, context.isDark ? KColors.navy : Colors.white, Colors.transparent),
    };
    final disabled = onPressed == null || loading;
    final h = compact ? 40.0 : 50.0;
    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
        else if (icon != null)
          Icon(icon, size: compact ? 18 : 20, color: fg),
        if ((icon != null || loading) && label.isNotEmpty) const SizedBox(width: 8),
        if (label.isNotEmpty)
          Flexible(
            child: Text(
              label.uz,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 14 : 15, color: fg),
            ),
          ),
        if (trailingIcon != null) ...[const SizedBox(width: 6), Icon(trailingIcon, size: 18, color: fg)],
      ],
    );
    final button = Pressable(
      onTap: disabled ? null : onPressed,
      child: AnimatedOpacity(
        duration: KDurations.fast,
        opacity: disabled && !loading ? 0.45 : 1,
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
          decoration: BoxDecoration(
            color: bg,
            gradient: variant == KButtonVariant.primary && !disabled
                ? const LinearGradient(colors: [KColors.primary, Color(0xFF1C8DFB)])
                : null,
            borderRadius: BorderRadius.circular(KRadius.md),
            border: Border.all(color: border),
            boxShadow: [
              if (variant == KButtonVariant.primary && !disabled)
                BoxShadow(color: KColors.primary.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: content,
        ),
      ),
    );
    final semantic = Semantics(button: true, enabled: !disabled, label: label.uz, excludeSemantics: true, child: button);
    final withFocus = FocusableActionDetector(
      enabled: !disabled,
      mouseCursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => onPressed?.call())},
      child: semantic,
    );
    final sized = expand ? SizedBox(width: double.infinity, child: withFocus) : withFocus;
    return tooltip == null ? sized : Tooltip(message: tooltip!, child: sized);
  }
}

/// Gradientli dumaloq-kvadrat ikonka.
class KIconBox extends StatelessWidget {
  const KIconBox(this.icon, {super.key, this.color = KColors.primary, this.size = 44, this.iconSize, this.filled = false});
  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: filled
          ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, Color.lerp(color, KColors.cyan, 0.45)!])
          : null,
      color: filled ? null : color.withValues(alpha: context.isDark ? 0.18 : 0.11),
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: Icon(icon, color: filled ? Colors.white : color, size: iconSize ?? size * 0.52),
  );
}

/// Animatsiyali progress halqasi. Qiymat o'zgarganda silliq to'ladi.
class KProgressRing extends StatelessWidget {
  const KProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.stroke = 7,
    this.color = KColors.primary,
    this.center,
    this.animate = true,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget? center;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final track = context.k.surfaceHigh;
    return Semantics(
      value: '${(value * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: animate ? KDurations.lazy : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(v, color, track, stroke),
            child: Center(child: center),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track, this.stroke);
  final double v;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(r, 0, math.pi * 2, false, bg);
    if (v <= 0) return;
    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, Color.lerp(color, KColors.cyan, 0.6)!, color],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(r)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color || o.track != track;
}

class KProgressBar extends StatelessWidget {
  const KProgressBar({super.key, required this.value, this.color = KColors.primary, this.height = 8, this.animate = true});
  final double value;
  final Color color;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) => Semantics(
    value: '${(value * 100).round()}%',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: context.k.surfaceHigh,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: animate ? KDurations.lazy : Duration.zero,
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, Color.lerp(color, KColors.cyan, 0.5)!]),
                borderRadius: BorderRadius.circular(height),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
  );
}

class KBadge extends StatelessWidget {
  const KBadge(this.label, {super.key, this.color = KColors.primary, this.icon, this.solid = false});
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: solid ? color : color.withValues(alpha: context.isDark ? 0.2 : 0.12),
      borderRadius: BorderRadius.circular(KRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13, color: solid ? Colors.white : color), const SizedBox(width: 4)],
        Flexible(
          child: Text(
            label.uz,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: solid ? Colors.white : color, letterSpacing: 0.2),
          ),
        ),
      ],
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle, this.action, this.onAction, this.icon});
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: KSpace.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ikonka sarlavha qatori bilan bir chiziqda (izoh uzun bo'lsa ham).
        if (icon != null) ...[Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 20, color: KColors.primary)), const SizedBox(width: 8)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: UzText(title, style: context.text.titleLarge)),
              if (subtitle != null) ...[const SizedBox(height: 2), UzText(subtitle!, style: context.text.bodySmall)],
            ],
          ),
        ),
        if (action != null) TextButton(onPressed: onAction, child: Text(action!.uz)),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(KSpace.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bo'sh holatda ham yolg'iz emassiz — Bitik o'ylab turibdi.
          const Bitik(mood: BitikMood.think, size: 104),
          const SizedBox(height: KSpace.lg),
          UzText(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: KSpace.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: RichUz(message, style: context.text.bodyMedium, textAlign: TextAlign.center),
          ),
          if (action != null) ...[const SizedBox(height: KSpace.lg), KButton(label: action!, onPressed: onAction)],
        ],
      ),
    ),
  );
}

enum FeedbackKind { success, error, warning, info }

/// Natija xabari. Rang bilan birga ikonka va matn — rangga bog'liq bo'lmagan feedback.
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({super.key, required this.kind, required this.title, this.message, this.trailing, this.child});
  final FeedbackKind kind;
  final String title;
  final String? message;
  final Widget? trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final (bg, fg, icon) = switch (kind) {
      FeedbackKind.success => (k.successSoft, k.successText, Icons.check_circle_rounded),
      FeedbackKind.error => (k.errorSoft, k.errorText, Icons.cancel_rounded),
      FeedbackKind.warning => (k.warningSoft, k.warningText, Icons.warning_amber_rounded),
      FeedbackKind.info => (k.primarySoft, context.isDark ? const Color(0xFF8CC8FF) : KColors.primary, Icons.info_rounded),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(KSpace.md + 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KRadius.md),
          border: Border.all(color: fg.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UzText(title, style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 15)),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    RichUz(message!, style: context.text.bodyMedium!.copyWith(color: k.text)),
                  ],
                  if (child != null) ...[const SizedBox(height: 8), child!],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Kontentni o'qish uchun qulay kenglikda markazlashtiradi.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = KBreakpoints.maxContent});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
  );
}

/// Sahifalar uchun standart chetlik (telefonda 16, katta ekranda ko'proq).
///
/// Yuqori/pastki tizim chetlari (status bar, shaffof navigatsiya, suzuvchi
/// [KTopBar]) ham qo'shiladi: kontent ular ortidan o'tadi, lekin oxirgi
/// element hech qachon ostida qolib ketmaydi.
EdgeInsets pagePadding(BuildContext context) {
  final w = context.screenWidth;
  final h = w < KBreakpoints.medium ? 16.0 : (w < KBreakpoints.expanded ? 24.0 : 32.0);
  final inset = MediaQuery.paddingOf(context);
  return EdgeInsets.fromLTRB(h, 12 + inset.top, h, 32 + inset.bottom);
}

class KDivider extends StatelessWidget {
  const KDivider({super.key, this.height = 24});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height, child: Center(child: Divider(color: context.k.border)));
}

/// Statistik ko'rsatkich plitkasi.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.value, required this.label, this.color = KColors.primary});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => KCard(
    padding: const EdgeInsets.all(KSpace.md + 2),
    child: Row(
      children: [
        KIconBox(icon, color: color, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: numberStyle(context.text.titleLarge!.copyWith(fontWeight: FontWeight.w800)), maxLines: 1, overflow: TextOverflow.ellipsis),
              UzText(label, style: context.text.bodySmall, maxLines: 2),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<T?> showKSheet<T>(BuildContext context, {required WidgetBuilder builder, bool scrollable = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (ctx) => scrollable
        ? DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (ctx, controller) => PrimaryScrollController(controller: controller, child: builder(ctx)),
          )
        : builder(ctx),
  );
}

void showToast(BuildContext context, String message, {IconData? icon}) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
        Expanded(child: Text(message.uz)),
      ]),
      duration: const Duration(seconds: 2),
    ));
}
