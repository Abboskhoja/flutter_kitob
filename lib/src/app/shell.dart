import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/components.dart';
import '../core/design_system/motion.dart';
import '../core/design_system/rich_text.dart';
import '../core/design_system/theme.dart';
import '../core/design_system/tokens.dart';
import '../core/state/progress.dart';
import '../core/state/settings.dart';
import '../shared/logo.dart';
import 'bottom_nav.dart';

class _Dest {
  const _Dest(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _mainDests = [
  _Dest('Bosh sahifa', Icons.home_outlined, Icons.home_rounded),
  _Dest('Darslar', Icons.menu_book_outlined, Icons.menu_book_rounded),
  _Dest('Amaliyot', Icons.code_outlined, Icons.code_rounded),
  _Dest('Testlar', Icons.quiz_outlined, Icons.quiz_rounded),
  _Dest('Profil', Icons.person_outline_rounded, Icons.person_rounded),
];

class _SideItem {
  const _SideItem(this.label, this.icon, this.location, {this.match});
  final String label;
  final IconData icon;
  final String location;

  /// Qaysi yo'llarda tanlangan holatda ko'rinadi.
  final bool Function(String path, Map<String, String> query)? match;
}

final _sideSections = <(String, List<_SideItem>)>[
  ('O\'rganish', [
    _SideItem('Dashboard', Icons.space_dashboard_outlined, '/home', match: (p, q) => p == '/home' || p == '/home/search'),
    _SideItem('Mening ta\'lim yo\'lim', Icons.route_outlined, '/learn',
        match: (p, q) => (p == '/learn' && q['track'] == null) || p.startsWith('/learn/level') || p.startsWith('/learn/glossary')),
    _SideItem('Dart akademiyasi', Icons.code_rounded, '/learn?track=dart', match: (p, q) => p == '/learn' && q['track'] == 'dart'),
    _SideItem('Flutter akademiyasi', Icons.flutter_dash_rounded, '/learn?track=flutter',
        match: (p, q) => p == '/learn' && q['track'] == 'flutter'),
  ]),
  ('Amaliyot', [
    _SideItem('Widget laboratoriyasi', Icons.widgets_outlined, '/practice/widgets', match: (p, q) => p.startsWith('/practice/widgets')),
    _SideItem('Code Playground', Icons.terminal_outlined, '/practice/playground', match: (p, q) => p == '/practice/playground'),
    _SideItem('Terminal laboratoriyasi', Icons.keyboard_command_key_rounded, '/practice/terminal',
        match: (p, q) => p == '/practice/terminal'),
    _SideItem('Kod vizualizatori', Icons.slow_motion_video_rounded, '/practice/visualizer',
        match: (p, q) => p == '/practice/visualizer'),
    _SideItem('Amaliy loyihalar', Icons.rocket_launch_outlined, '/practice/projects', match: (p, q) => p.startsWith('/practice/projects')),
    _SideItem('Intervyuga tayyorgarlik', Icons.work_outline_rounded, '/practice/interview', match: (p, q) => p == '/practice/interview'),
  ]),
  ('Natijalar', [
    _SideItem('Test va imtihonlar', Icons.quiz_outlined, '/tests', match: (p, q) => p.startsWith('/tests')),
    _SideItem('Yutuqlar', Icons.emoji_events_outlined, '/profile/achievements', match: (p, q) => p == '/profile/achievements'),
    _SideItem('Profil', Icons.person_outline_rounded, '/profile', match: (p, q) => p == '/profile'),
    _SideItem('Sozlamalar', Icons.settings_outlined, '/profile/settings', match: (p, q) => p == '/profile/settings'),
  ]),
];

/// Ekran kengligiga qarab navigatsiyani almashtiradigan asosiy qobiq.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  /// Bu sahifalarda telefonda pastki navigatsiya yashiriladi — ko'proq joy.
  static bool isImmersive(String path) =>
      path.startsWith('/learn/lesson') ||
      path.startsWith('/practice/') ||
      path.startsWith('/tests/review') ||
      path.startsWith('/tests/exam');

  void _goBranch(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) => _GlobalShortcuts(onBranch: _goBranch, child: _layout(context));

  Widget _layout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final state = GoRouterState.of(context);
    final path = state.uri.path;
    if (width >= KBreakpoints.expanded) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(path: path, query: state.uri.queryParameters),
            VerticalDivider(width: 1, color: context.k.border),
            Expanded(child: shell),
          ],
        ),
      );
    }
    if (width >= KBreakpoints.medium) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _goBranch,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: const KitobLogo(size: 40),
                ),
                destinations: [
                  for (final d in _mainDests)
                    NavigationRailDestination(icon: Icon(d.icon), selectedIcon: _PopIcon(d.selectedIcon), label: Text(d.label.uz)),
                ],
              ),
            ),
            VerticalDivider(width: 1, color: context.k.border),
            Expanded(child: shell),
          ],
        ),
      );
    }
    final hideNav = isImmersive(path) && path != '/practice';
    return Scaffold(
      // Kontent navigatsiya ortidan ham ko'rinadi — panel shaffof.
      extendBody: true,
      // Immersiv sahifalar (kod muharriri, terminal, dars) o'z tepa qismini chizadi.
      body: hideNav ? shell : _StatusScrim(child: shell),
      bottomNavigationBar: AnimatedSize(
        duration: KDurations.medium,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: hideNav
            ? const SizedBox(width: double.infinity, height: 0)
            : KBottomNav(
                index: shell.currentIndex,
                onSelect: _goBranch,
                items: [for (final d in _mainDests) NavItem(d.label, d.icon, d.selectedIcon)],
              ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.path, required this.query});
  final String path;
  final Map<String, String> query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final k = context.k;
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    return Container(
      width: 272,
      color: k.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                const KitobLogo(size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('FLUTTER_KITOB', style: context.text.titleMedium!.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                    Text('O\'rgan. Kod yoz. Yarat.'.uz, style: context.text.bodySmall),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Pressable(
                onTap: () => context.go('/home/search'),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: k.surfaceAlt,
                    borderRadius: BorderRadius.circular(KRadius.md),
                    border: Border.all(color: k.border),
                  ),
                  child: Row(children: [
                    Icon(Icons.search_rounded, size: 20, color: k.textMuted),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Qidirish...', style: TextStyle(color: k.textMuted))),
                    Tooltip(
                      message: 'Qidiruv: / yoki Ctrl/⌘ + K · Barcha yorliqlar: ?'.uz,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(border: Border.all(color: k.border), borderRadius: BorderRadius.circular(6)),
                        child: Text('/', style: TextStyle(color: k.textMuted, fontSize: 12)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: [
                  for (final (title, items) in _sideSections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                      child: Text(title.uz.toUpperCase(), style: context.text.labelSmall),
                    ),
                    for (final it in items)
                      _SideTile(item: it, selected: it.match?.call(path, query) ?? path == it.location),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: KCard(
                padding: const EdgeInsets.all(12),
                onTap: () => context.go('/profile'),
                child: Row(children: [
                  KProgressRing(
                    value: progress.levelProgress,
                    size: 42,
                    stroke: 4.5,
                    center: Text('${progress.userLevel}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(settings.userName.isEmpty ? 'O\'quvchi'.uz : settings.userName,
                          style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Lv ${progress.userLevel} · ${progress.xp} XP · 🔥 ${progress.streak} kun', style: context.text.bodySmall),
                    ]),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideTile extends StatelessWidget {
  const _SideTile({required this.item, required this.selected});
  final _SideItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final fg = selected ? (context.isDark ? const Color(0xFF8CC8FF) : KColors.primary) : k.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: AnimatedContainer(
        duration: KDurations.medium,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? k.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(KRadius.md),
        ),
          child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(KRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(KRadius.md),
            onTap: () => context.go(item.location),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                AnimatedScale(scale: selected ? 1.12 : 1, duration: KDurations.medium, curve: Curves.easeOutBack, child: Icon(item.icon, size: 20, color: fg)),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: KDurations.fast,
                    style: TextStyle(fontFamily: kFontFamily, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: fg, fontSize: 14),
                    child: Text(item.label.uz),
                  ),
                ),
                AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: KDurations.medium,
                  curve: Curves.easeOutBack,
                  child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: KColors.primary, shape: BoxShape.circle)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tanlangan navigatsiya ikonkasi paydo bo'lganda biroz sakrab chiqadi.
class _PopIcon extends StatelessWidget {
  const _PopIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Reveal(
    offset: const Offset(0, 5),
    scale: 0.55,
    duration: const Duration(milliseconds: 420),
    child: Icon(icon),
  );
}

/// Edge-to-edge sahifalarda status bar ostidagi kontentni yumshoq yashiradi,
/// shunda soat va batareya belgilari doim o'qiladi.
class _StatusScrim extends StatelessWidget {
  const _StatusScrim({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return child;
    final bg = context.k.background;
    return Stack(children: [
      child,
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: top + 14,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bg.withValues(alpha: 0.94), bg.withValues(alpha: 0)],
                stops: const [0.6, 1],
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Klaviatura yorliqlari (web va desktop):
/// `/` yoki Ctrl/⌘+K — qidiruv, Alt+1…5 — bo'limlar, `?` — yorliqlar ro'yxati.
/// Bitta tugmali yorliqlar matn yozilayotganda ishlamaydi.
class _GlobalShortcuts extends StatelessWidget {
  const _GlobalShortcuts({required this.onBranch, required this.child});
  final ValueChanged<int> onBranch;
  final Widget child;

  static bool get _typing => FocusManager.instance.primaryFocus?.context?.findAncestorStateOfType<EditableTextState>() != null;

  static void showHelp(BuildContext context) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Klaviatura yorliqlari'.uz),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (keys, what) in const [
          ('/   yoki   Ctrl/⌘ + K', 'Qidiruv'),
          ('Alt + 1 … 5', 'Bosh sahifa, Darslar, Amaliyot, Testlar, Profil'),
          ('Ctrl/⌘ + Enter', 'Kodni ishga tushirish (muharrirda)'),
          ('?', 'Shu oyna'),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 170, child: Text(keys, style: codeStyle(size: 13, weight: FontWeight.w700))),
              Expanded(child: Text(what.uz, style: ctx.text.bodyMedium)),
            ]),
          ),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Yopish'.uz))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    void search() => context.go('/home/search');
    bool unlessTyping(VoidCallback f) {
      if (_typing) return false;
      f();
      return true;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        final k = HardwareKeyboard.instance;
        final key = e.logicalKey;
        if ((k.isControlPressed || k.isMetaPressed) && key == LogicalKeyboardKey.keyK) {
          search();
          return KeyEventResult.handled;
        }
        if (k.isAltPressed) {
          const digits = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3, LogicalKeyboardKey.digit4, LogicalKeyboardKey.digit5];
          final i = digits.indexOf(key);
          if (i >= 0) {
            onBranch(i);
            return KeyEventResult.handled;
          }
        }
        if (k.isControlPressed || k.isMetaPressed || k.isAltPressed) return KeyEventResult.ignored;
        final handled = switch (e.character) {
          '/' => unlessTyping(search),
          '?' => unlessTyping(() => showHelp(context)),
          _ => false,
        };
        return handled ? KeyEventResult.handled : KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
