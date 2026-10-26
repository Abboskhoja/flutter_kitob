import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/design_system/adaptive.dart';
import '../core/design_system/motion.dart';
import '../core/design_system/rich_text.dart';
import '../core/design_system/tokens.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Telefon uchun pastki navigatsiya. Kontent uning ortidan ko'rinib turadi
/// (`Scaffold.extendBody: true`).
///
/// * Glass / Web — suzuvchi shisha kapsula, tanlangan bo'lim ostida "suyuq"
///   linza bir joydan ikkinchisiga cho'zilib oqib o'tadi.
/// * Material — to'liq kenglikdagi shaffof panel, kengayadigan pill indikator.
class KBottomNav extends StatelessWidget {
  const KBottomNav({super.key, required this.items, required this.index, required this.onSelect});
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    void tap(int i) {
      kHaptic(context);
      onSelect(i);
    }

    return context.look == KLook.material
        ? _MaterialNav(items: items, index: index, onSelect: tap)
        : _GlassNav(items: items, index: index, onSelect: tap);
  }
}

class _GlassNav extends StatelessWidget {
  const _GlassNav({required this.items, required this.index, required this.onSelect});
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final off = KMotion.off(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, math.max(bottom, 10) + 4),
      child: SizedBox(
        height: 64,
        child: Glass(
          radius: BorderRadius.circular(32),
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth / items.length;
            return Stack(children: [
              // Linza: masofa qancha katta bo'lsa, harakat paytida shuncha cho'ziladi.
              TweenAnimationBuilder<double>(
                tween: Tween(end: index.toDouble()),
                duration: off ? Duration.zero : const Duration(milliseconds: 560),
                curve: Curves.easeOutBack,
                builder: (context, v, _) {
                  final stretch = math.min((v - index).abs(), 1.0) * 0.45;
                  final lw = (w - 10) * (1 + stretch);
                  return Positioned(
                    left: v * w + 5 - (lw - (w - 10)) / 2,
                    top: 5,
                    bottom: 5,
                    width: lw,
                    child: Glass(
                      radius: BorderRadius.circular(27),
                      strong: true,
                      shadow: false,
                      // Qorong'i rejimda linza ko'zni qamashtirmasin — to'qroq ko'k.
                      tint: context.isDark ? const Color(0xFF24457E) : Color.lerp(Colors.white, KColors.primary, 0.1),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
              Row(children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(child: _GlassItem(item: items[i], selected: i == index, onTap: () => onSelect(i))),
              ]),
            ]);
          }),
        ),
      ),
    );
  }
}

class _GlassItem extends StatelessWidget {
  const _GlassItem({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? (context.isDark ? const Color(0xFF8CC8FF) : KColors.primary) : context.k.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label.uz,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        highlightShape: BoxShape.rectangle,
        containedInkWell: false,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedScale(
            scale: selected ? 1.12 : 1,
            duration: KDurations.medium,
            curve: Curves.easeOutBack,
            child: Icon(selected ? item.selectedIcon : item.icon, size: 24, color: fg),
          ),
          const SizedBox(height: 2),
          Text(
            item.label.uz,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(fontSize: 10.5, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: fg),
          ),
        ]),
      ),
    );
  }
}

class _MaterialNav extends StatelessWidget {
  const _MaterialNav({required this.items, required this.index, required this.onSelect});
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Glass(
      radius: const BorderRadius.vertical(top: Radius.circular(KRadius.xxl)),
      shadow: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SizedBox(
          height: 76,
          child: Row(children: [
            for (var i = 0; i < items.length; i++)
              Expanded(child: _MaterialItem(item: items[i], selected: i == index, onTap: () => onSelect(i))),
          ]),
        ),
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  const _MaterialItem({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final accent = context.isDark ? const Color(0xFF8CC8FF) : KColors.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label.uz,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 34,
            width: 64,
            child: Stack(alignment: Alignment.center, children: [
              // M3 Expressive: indikator markazdan kengayib chiqadi.
              TweenAnimationBuilder<double>(
                tween: Tween(end: selected ? 1 : 0),
                duration: KMotion.off(context) ? Duration.zero : KDurations.slow,
                curve: Curves.easeOutBack,
                // Sakrash (overshoot) faqat kattalashishda; manfiy kenglik bo'lmasin.
                builder: (context, v, _) => Container(
                  width: 64 * v.clamp(0.0, 1.15),
                  height: 34,
                  decoration: BoxDecoration(
                    color: k.primarySoft.withValues(alpha: v.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(KRadius.pill),
                  ),
                ),
              ),
              Icon(selected ? item.selectedIcon : item.icon, size: 24, color: selected ? accent : k.textMuted),
            ]),
          ),
          const SizedBox(height: 4),
          Text(
            item.label.uz,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? accent : k.textMuted),
          ),
        ]),
      ),
    );
  }
}
