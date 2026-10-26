import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import 'edu_animations_more.dart';
import 'flutter_labs.dart';
import 'story.dart';

typedef AnimBuilder = Widget Function();

/// Darslarda ishlatiladigan barcha ta'limiy animatsiyalar.
final Map<String, AnimBuilder> eduAnimations = {
  'program_flow': () => const _ProgramFlow(),
  'compiler': () => const _Compiler(),
  'algorithm': () => const _Algorithm(),
  'file_tree': () => const _FileTree(),
  'client_server': () => const _ClientServer(),
  'terminal': () => const _TerminalAnim(),
  'dart_flutter': () => const _DartFlutter(),
  'variable_box': () => const _VariableBox(),
  'final_const': () => const _FinalConst(),
  'types': () => const _Types(),
  'string_interp': () => const _StringInterp(),
  'condition': () => const _Condition(),
  'if_branch': () => const _IfBranch(),
  'loop_for': () => const _LoopFor(),
  'loop_while': () => const _LoopWhile(),
  'list_boxes': () => const _ListBoxes(),
  'map_pairs': () => const _MapPairs(),
  'null_box': () => const _NullBox(),
  'function_machine': () => const _FunctionMachine(),
  'scope': () => const _Scope(),
  'class_object': () => const _ClassObject(),
  'inheritance': () => const _Inheritance(),
  'widget_tree': () => const _WidgetTree(),
  'set_state': () => const _SetStateFlow(),
  'async_await': () => const _AsyncAwait(),
  'event_loop': () => const _EventLoop(),
  'stream_flow': () => const _StreamFlow(),
  // Interaktiv laboratoriyalar (flutter_labs.dart): haqiqiy layout va rebuild.
  'layout_constraints': () => const ConstraintsLab(),
  'state_rebuild': () => const RebuildLab(),
  // Qo'shimcha animatsion tushuntirishlar (edu_animations_more.dart).
  'operators': () => const OperatorsAnim(),
  'type_convert': () => const TypeConvertAnim(),
  'switch_lanes': () => const SwitchAnim(),
  'constructor': () => const ConstructorAnim(),
  'try_catch': () => const TryCatchAnim(),
  'stateless_props': () => const StatelessPropsAnim(),
  'list_builder': () => const ListBuilderAnim(),
  'scaffold_parts': () => const ScaffoldPartsAnim(),
  'input_flow': () => const InputFlowAnim(),
  'flex_split': () => const FlexSplitAnim(),
};

class EduAnimation extends StatelessWidget {
  const EduAnimation(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    final b = eduAnimations[id];
    if (b == null) return const SizedBox.shrink();
    return b();
  }
}

Widget _fit(Widget child) => Center(child: FittedBox(fit: BoxFit.scaleDown, child: child));

// ───────────────────────── Asoslar ─────────────────────────

class _ProgramFlow extends StatelessWidget {
  const _ProgramFlow();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Har qanday dastur uch qismdan iborat: **kirish → qayta ishlash → chiqish**.',
      'Foydalanuvchi ma\'lumot kiritadi: `2 + 3`. Bu — **kirish**.',
      'Dastur buyruqlarni birin-ketin bajaradi. Bu — **qayta ishlash**.',
      'Natija `5` ekranga chiqadi. Bu — **chiqish**.',
    ],
    builder: (context, s) => Column(children: [
      _fit(Row(children: [
        ANode(label: 'Kirish', icon: Icons.keyboard_rounded, active: s == 1, sub: 'klaviatura'),
        const SizedBox(width: 18),
        ANode(
          label: 'Dastur',
          icon: Icons.memory_rounded,
          active: s == 2,
          color: KColors.violet,
          sub: 'buyruqlar',
          child: AnimatedRotation(turns: s >= 2 ? 1 : 0, duration: const Duration(milliseconds: 1400), child: const Icon(Icons.settings_rounded, size: 18, color: KColors.violet)),
        ),
        const SizedBox(width: 18),
        ANode(label: 'Chiqish', icon: Icons.desktop_windows_rounded, active: s == 3, color: KColors.success, sub: s >= 3 ? 'ekranda: 5' : 'ekran'),
      ])),
      const SizedBox(height: 16),
      SizedBox(
        height: 36,
        child: APacket(text: s >= 3 ? '5' : '2 + 3', x: s <= 1 ? -0.8 : (s == 2 ? 0 : 0.8), visible: s >= 1, color: s >= 3 ? KColors.success : KColors.cyan),
      ),
    ]),
  );
}

class _Compiler extends StatelessWidget {
  const _Compiler();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Siz Dart tilida **kod** yozasiz — odam o\'qiy oladigan matn.',
      '**Kompilyator** kodni tekshiradi va tarjima qiladi.',
      'Natija — protsessor tushunadigan **mashina kodi** (0 va 1).',
      '**Protsessor** mashina kodini bajaradi va ekranda natija paydo bo\'ladi.',
    ],
    builder: (context, s) => Column(children: [
      _fit(Row(children: [
        ANode(label: 'Dart kodi', icon: Icons.description_outlined, active: s == 0),
        AArrow(active: s == 1),
        ANode(label: 'Kompilyator', icon: Icons.translate_rounded, active: s == 1, color: KColors.violet),
        AArrow(active: s == 2),
        ANode(label: 'Mashina kodi', icon: Icons.data_array_rounded, active: s == 2, color: KColors.orange),
        AArrow(active: s == 3),
        ANode(label: 'CPU', icon: Icons.memory_rounded, active: s == 3, color: KColors.success),
      ])),
      const SizedBox(height: 18),
      SizedBox(
        height: 36,
        child: APacket(
          text: switch (s) { 0 => "print('Salom')", 1 => 'tekshirilmoqda…', 2 => '01001011 0110…', _ => 'Salom' },
          x: [-0.9, -0.3, 0.3, 0.9][s],
          color: [KColors.primary, KColors.violet, KColors.orange, KColors.success][s],
        ),
      ),
    ]),
  );
}

class _Algorithm extends StatelessWidget {
  const _Algorithm();
  static const _steps = ['Choynakka suv quy', 'Choynakni yoq', 'Suv qaynadimi?', 'Piyolaga choy sol', 'Qaynoq suv quy'];
  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 250,
    captions: const [
      '**Ketma-ketlik**: qadamlar tartib bilan bajariladi.',
      'Ikkinchi qadam bajarilmoqda.',
      '**Shart va takrorlash**: suv qaynamagan bo\'lsa — kutamiz va qayta tekshiramiz.',
      'Shart bajarildi (qaynadi) — keyingi qadamga o\'tamiz.',
      'Algoritm tugadi — natija: bir piyola choy ☕',
    ],
    builder: (context, s) {
      final active = [0, 1, 2, 3, 4][s];
      return Column(children: [
        for (var i = 0; i < _steps.length; i++)
          AnimatedContainer(
            duration: KDurations.medium,
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: i == active ? KColors.primary.withValues(alpha: 0.16) : context.k.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: i == active ? KColors.primary : context.k.border),
            ),
            child: Row(children: [
              Icon(i < active ? Icons.check_circle_rounded : (i == 2 ? Icons.help_outline_rounded : Icons.circle_outlined),
                  size: 18, color: i < active ? KColors.success : (i == active ? KColors.primary : context.k.textMuted)),
              const SizedBox(width: 8),
              Expanded(child: Text('${i + 1}. ${_steps[i]}'.uz, style: context.text.bodyMedium)),
              if (i == 2 && s == 2)
                const _Spinner(),
            ]),
          ),
      ]);
    },
  );
}

class _Spinner extends StatefulWidget {
  const _Spinner();
  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _c, child: const Icon(Icons.autorenew_rounded, size: 18, color: KColors.warning));
}

class _FileTree extends StatelessWidget {
  const _FileTree();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Loyiha — bu papka: `loyiha/`',
      'Uning ichida `lib/` papkasi — kod shu yerda.',
      '`lib/` ichida `main.dart` fayli. Uning to\'liq yo\'li: `/loyiha/lib/main.dart`',
      'Rasmlar `assets/` da, sozlamalar `pubspec.yaml` faylida.',
    ],
    builder: (context, s) {
      Widget row(int depth, IconData icon, String name, bool show, {bool hl = false}) => AnimatedOpacity(
        duration: KDurations.medium,
        opacity: show ? 1 : 0,
        child: AnimatedContainer(
          duration: KDurations.medium,
          margin: EdgeInsets.only(left: depth * 26.0, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(color: hl ? KColors.primary.withValues(alpha: 0.18) : null, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: icon == Icons.folder_rounded ? KColors.warning : KColors.primary),
            const SizedBox(width: 6),
            Text(name, style: codeStyle(size: 13.5, color: context.k.text)),
          ]),
        ),
      );
      final path = ['/loyiha', '/loyiha/lib', '/loyiha/lib/main.dart', '/loyiha/pubspec.yaml'][s];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(8)),
          child: Text('📍 $path', style: codeStyle(size: 12.5, color: const Color(0xFFA5E38B))),
        ),
        const SizedBox(height: 10),
        row(0, Icons.folder_rounded, 'loyiha/', true, hl: s == 0),
        row(1, Icons.folder_rounded, 'lib/', s >= 1, hl: s == 1),
        row(2, Icons.description_rounded, 'main.dart', s >= 2, hl: s == 2),
        row(1, Icons.folder_rounded, 'assets/', s >= 3),
        row(1, Icons.description_rounded, 'pubspec.yaml', s >= 3, hl: s == 3),
      ]);
    },
  );
}

class _ClientServer extends StatelessWidget {
  const _ClientServer();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Telefon (klient) va server — ikki alohida kompyuter.',
      'Ilova API orqali **so\'rov** yuboradi: "Toshkentda havo qanday?"',
      'Server ma\'lumotlar bazasidan haroratni topadi.',
      'Server **javob** qaytaradi: `{"harorat": 24}`',
      'Ilova javobni chiroyli qilib ekranda ko\'rsatadi: 24°C ☀️',
    ],
    builder: (context, s) => Column(children: [
      _fit(Row(children: [
        ANode(label: 'Telefon', sub: s >= 4 ? '24°C ☀️' : 'Ob-havo ilovasi', icon: Icons.smartphone_rounded, active: s == 0 || s == 4),
        const SizedBox(width: 90),
        ANode(label: 'Server', sub: 'API + baza', icon: Icons.dns_rounded, active: s == 2, color: KColors.violet),
      ])),
      const SizedBox(height: 16),
      SizedBox(
        height: 36,
        child: APacket(
          text: s <= 2 ? 'GET /weather?city=Toshkent' : '{"harorat": 24}',
          x: switch (s) { 0 => -0.85, 1 => 0.05, 2 => 0.85, 3 => -0.05, _ => -0.85 },
          visible: s >= 1 && s <= 3,
          color: s <= 2 ? KColors.primary : KColors.success,
        ),
      ),
    ]),
  );
}

class _TerminalAnim extends StatelessWidget {
  const _TerminalAnim();
  static const _lines = [
    ('pwd', '/home/student'),
    ('mkdir my_app', ''),
    ('cd my_app', ''),
    ('pwd', '/home/student/my_app'),
  ];
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`pwd` — hozir qaysi papkadaman?',
      '`mkdir my_app` — yangi papka yaratish.',
      '`cd my_app` — papka ichiga kirish.',
      '`pwd` — endi yangi papkadamiz.',
    ],
    builder: (context, s) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i <= s; i++) ...[
          Text.rich(TextSpan(children: [
            TextSpan(text: 'student@kitob:${i >= 3 ? '~/my_app' : '~'}\$ ', style: codeStyle(size: 13, color: const Color(0xFF7DD3FC))),
            TextSpan(text: _lines[i].$1, style: codeStyle(size: 13, color: Colors.white)),
          ])),
          if (_lines[i].$2.isNotEmpty) Text(_lines[i].$2, style: codeStyle(size: 13, color: const Color(0xFFA5E38B))),
        ],
        const _Blink(),
      ]),
    ),
  );
}

class _Blink extends StatefulWidget {
  const _Blink();
  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _c, child: Container(width: 9, height: 16, color: Colors.white70));
}

class _DartFlutter extends StatelessWidget {
  const _DartFlutter();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '**Dart** — til: unda mantiq, hisob-kitob va ma\'lumot bilan ishlash yoziladi.',
      '**Flutter** — Dartda yozilgan framework: tayyor widgetlar va chizish dvigateli.',
      'Bitta kod bazasidan barcha platformalar uchun ilova chiqadi!',
    ],
    builder: (context, s) => Column(children: [
      _fit(Row(children: [
        ANode(label: 'Dart', sub: 'til', icon: Icons.code_rounded, active: s == 0),
        AArrow(active: s >= 1),
        ANode(label: 'Flutter', sub: 'framework', icon: Icons.flutter_dash_rounded, active: s == 1, color: KColors.cyan),
      ])),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        for (final (i, (icon, name)) in const [(Icons.android_rounded, 'Android'), (Icons.phone_iphone_rounded, 'iOS'), (Icons.language_rounded, 'Web'), (Icons.laptop_mac_rounded, 'Desktop')].indexed)
          AnimatedScale(
            duration: Duration(milliseconds: 400 + i * 120),
            curve: Curves.easeOutBack,
            scale: s >= 2 ? 1 : 0,
            child: Chip(avatar: Icon(icon, size: 18, color: KColors.success), label: Text(name)),
          ),
      ]),
    ]),
  );
}

// ───────────────────────── Dart asoslari ─────────────────────────

class _VariableBox extends StatelessWidget {
  const _VariableBox();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 240,
    captions: const [
      '`int yosh = 18;` — Dart bu qatorni o\'qiydi.',
      'Xotirada **int** turidagi, **yosh** nomli bo\'sh quti yaratiladi.',
      'Qutiga **18** qiymati joylanadi.',
      '`yosh = yosh + 1;` — avval o\'ng tomon hisoblanadi (18 + 1), keyin quti yangilanadi: **19**.',
      '`print(yosh);` — qutidagi qiymat konsolga chiqadi.',
    ],
    builder: (context, s) => Row(children: [
      Expanded(
        flex: 5,
        child: ACodePanel(lines: const ['int yosh = 18;', 'yosh = yosh + 1;', 'print(yosh);'], active: s <= 2 ? 0 : (s == 3 ? 1 : 2)),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 4,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('XOTIRA (RAM)', style: context.text.labelSmall),
          const SizedBox(height: 6),
          AVarBox(name: 'yosh', type: 'int', value: s >= 2 ? (s >= 3 ? '19' : '18') : null, visible: s >= 1, highlight: s == 2 || s == 3),
          const SizedBox(height: 10),
          AConsole(lines: [if (s >= 4) '19']),
        ]),
      ),
    ]),
  );
}

class _FinalConst extends StatelessWidget {
  const _FinalConst();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`var ball = 10;` — oddiy quti, qiymatini o\'zgartirish mumkin.',
      '`ball = 15;` — muvaffaqiyatli o\'zgardi ✓',
      '`final ism = \'Jasur\';` — qulflangan quti. `ism = \'Ali\';` → ✗ xato!',
      '`const pi = 3.14;` — kod yozilgandayoq muhrlangan qiymat.',
    ],
    builder: (context, s) => _fit(Row(children: [
      AVarBox(name: 'ball', type: 'var · int', value: s >= 1 ? '15' : '10', highlight: s <= 1),
      const SizedBox(width: 12),
      _Shake(
        shake: s == 2,
        child: AVarBox(name: 'ism', type: 'final', value: "'Jasur'", locked: true, highlight: s == 2, color: KColors.error),
      ),
      const SizedBox(width: 12),
      AVarBox(name: 'pi', type: 'const', value: '3.14', locked: true, highlight: s == 3, color: KColors.violet),
    ])),
  );
}

class _Shake extends StatelessWidget {
  const _Shake({required this.shake, required this.child});
  final bool shake;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(shake),
    tween: Tween(begin: 0, end: shake ? 1 : 0),
    duration: const Duration(milliseconds: 600),
    builder: (c, v, ch) => Transform.translate(offset: Offset(math.sin(v * math.pi * 6) * 8 * (1 - v), 0), child: ch),
    child: child,
  );
}

class _Types extends StatelessWidget {
  const _Types();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '10 ta olmani 3 kishiga bo\'lamiz.',
      '`10 / 3` → `3.3333…` — oddiy bo\'lish, natija **double**.',
      '`10 ~/ 3` → `3` — har kimga butun 3 tadan (**int**).',
      '`10 % 3` → `1` — ortib qolgan qoldiq.',
    ],
    builder: (context, s) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Wrap(spacing: 4, children: [
        for (var i = 0; i < 10; i++)
          AnimatedOpacity(
            duration: KDurations.medium,
            opacity: s == 3 && i < 9 ? 0.25 : 1,
            child: Text('🍎', style: TextStyle(fontSize: s == 3 && i == 9 ? 28 : 22)),
          ),
      ]),
      const SizedBox(height: 16),
      AnimatedSwitcher(
        duration: KDurations.medium,
        child: Text(
          ['10 olma ÷ 3 kishi', '10 / 3 = 3.3333333333333335', '10 ~/ 3 = 3', '10 % 3 = 1'][s],
          key: ValueKey(s),
          style: codeStyle(size: 18, color: [context.k.text, KColors.cyan, KColors.primary, KColors.orange][s], weight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 6),
      Text(['', 'double', 'int', 'int (qoldiq)'][s], style: context.text.labelMedium),
    ]),
  );
}

class _StringInterp extends StatelessWidget {
  const _StringInterp();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "`String ism = 'Dilnoza';` — o'zgaruvchi tayyor.",
      r"`'Salom, $ism!'` — matnda `$ism` — bo'sh joy (shablon).",
      'Dart `\$ism` o\'rniga qiymatni joylaydi.',
      'Natija: `Salom, Dilnoza!`',
    ],
    builder: (context, s) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AVarBox(name: 'ism', type: 'String', value: "'Dilnoza'", highlight: s == 2),
      const SizedBox(height: 18),
      AnimatedContainer(
        duration: KDurations.medium,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: CodePalette.dark.background, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text("'Salom, ", style: codeStyle(size: 16, color: CodePalette.dark.string)),
          AnimatedSwitcher(
            duration: KDurations.slow,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: s >= 2
                ? Text('Dilnoza', key: const ValueKey('v'), style: codeStyle(size: 16, color: KColors.warning, weight: FontWeight.w700))
                : Text(r'$ism', key: const ValueKey('t'), style: codeStyle(size: 16, color: CodePalette.dark.interpolation, weight: FontWeight.w700)),
          ),
          Text("!'", style: codeStyle(size: 16, color: CodePalette.dark.string)),
        ]),
      ),
      if (s >= 3) ...[const SizedBox(height: 12), const AConsole(lines: ['Salom, Dilnoza!'])],
    ]),
  );
}

class _Condition extends StatefulWidget {
  const _Condition();
  @override
  State<_Condition> createState() => _ConditionState();
}

class _ConditionState extends State<_Condition> {
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'A = false, B = false → `A && B` = false, `A || B` = false',
      'A = true, B = false → `&&` false (ikkalasi kerak), `||` true (bittasi yetarli)',
      'A = true, B = true → ikkalasi ham true',
    ],
    builder: (context, s) {
      final a = s >= 1, b = s >= 2;
      Widget sw(String n, bool v) => Column(children: [
        Text(n, style: codeStyle(size: 14, color: context.k.text, weight: FontWeight.w700)),
        Switch(value: v, onChanged: null),
        Text('$v', style: codeStyle(size: 12, color: v ? KColors.success : KColors.error)),
      ]);
      Widget bulb(String op, bool on) => Column(children: [
        AnimatedContainer(
          duration: KDurations.medium,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? KColors.warning : context.k.surfaceHigh,
            boxShadow: [if (on) BoxShadow(color: KColors.warning.withValues(alpha: 0.6), blurRadius: 24)],
          ),
          child: Icon(Icons.lightbulb_rounded, color: on ? Colors.white : context.k.textMuted),
        ),
        const SizedBox(height: 6),
        Text('A $op B', style: codeStyle(size: 13, color: context.k.text)),
        Text('$on', style: codeStyle(size: 12, color: on ? KColors.success : KColors.error)),
      ]);
      return _fit(Row(children: [sw('A', a), const SizedBox(width: 10), sw('B', b), const SizedBox(width: 30), bulb('&&', a && b), const SizedBox(width: 20), bulb('||', a || b)]));
    },
  );
}

class _IfBranch extends StatelessWidget {
  const _IfBranch();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`ball = 85` — shart: `ball >= 60` ?',
      'Shart **true** → if bloki bajariladi: "O\'tdi" ✓',
      '`ball = 45` bo\'lsa-chi? Shart qayta tekshiriladi.',
      'Shart **false** → else bloki: "Yiqildi"',
    ],
    builder: (context, s) {
      final ball = s <= 1 ? 85 : 45;
      final decided = s == 1 || s == 3;
      final result = ball >= 60;
      return Column(children: [
        AnimatedContainer(
          duration: KDurations.medium,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: KColors.violet.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: KColors.violet)),
          child: Text('ball = $ball  →  ball >= 60 ?', style: codeStyle(size: 14, color: context.k.text, weight: FontWeight.w700)),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Column(children: [
              Icon(Icons.south_west_rounded, color: decided && result ? KColors.success : context.k.borderStrong),
              ANode(label: 'O\'tdi ✓', sub: 'true', icon: Icons.check_circle_rounded, active: decided && result, color: KColors.success, width: 110),
            ]),
          ),
          Expanded(
            child: Column(children: [
              Icon(Icons.south_east_rounded, color: decided && !result ? KColors.error : context.k.borderStrong),
              ANode(label: 'Yiqildi', sub: 'false (else)', icon: Icons.cancel_rounded, active: decided && !result, color: KColors.error, width: 110),
            ]),
          ),
        ]),
      ]);
    },
  );
}

class _LoopFor extends StatelessWidget {
  const _LoopFor();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 240,
    interval: 1700,
    captions: const [
      '`var i = 0` — hisoblagich yaratiladi (bir marta).',
      'Shart `0 < 3` → true. Tana: `print(0)`. Keyin `i++`.',
      'Shart `1 < 3` → true. `print(1)`. `i++`.',
      'Shart `2 < 3` → true. `print(2)`. `i++`.',
      'Shart `3 < 3` → **false**. Sikl tugadi!',
    ],
    builder: (context, s) {
      final i = s == 0 ? 0 : s - 1 + (s == 4 ? 0 : 0);
      final iv = s == 0 ? 0 : (s == 4 ? 3 : i);
      return Row(children: [
        Expanded(
          flex: 5,
          child: ACodePanel(lines: const ['for (var i = 0; i < 3; i++) {', '  print(i);', '}'], active: s == 0 || s == 4 ? 0 : 1),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AVarBox(name: 'i', type: 'int', value: '$iv', highlight: true, color: s == 4 ? KColors.error : KColors.primary),
            const SizedBox(height: 6),
            Text(s == 4 ? '3 < 3 → false' : '$iv < 3 → true', style: codeStyle(size: 12, color: s == 4 ? KColors.error : KColors.success)),
            const SizedBox(height: 6),
            AConsole(lines: [for (var k = 0; k < (s == 4 ? 3 : s); k++) '$k']),
          ]),
        ),
      ]);
    },
  );
}

class _LoopWhile extends StatelessWidget {
  const _LoopWhile();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '**while**: avval shart tekshiriladi, keyin tana bajariladi.',
      'Shart false bo\'lsa — tana **bir marta ham** bajarilmaydi.',
      '**do-while**: avval tana bajariladi, keyin shart tekshiriladi.',
      'Shuning uchun do-while tanasi **kamida bir marta** ishlaydi.',
    ],
    builder: (context, s) {
      final isDo = s >= 2;
      Widget step(String t, bool on, Color c) => AnimatedContainer(
        duration: KDurations.medium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: on ? c.withValues(alpha: 0.18) : context.k.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: on ? c : context.k.border)),
        child: Text(t.uz, style: context.text.titleSmall),
      );
      final cond = step('Shart?', (!isDo && s == 0) || s == 3, KColors.violet);
      final body = step('Tana', (!isDo && false) || s == 2, KColors.primary);
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(isDo ? 'do { tana } while (shart);' : 'while (shart) { tana }', style: codeStyle(size: 14, color: context.k.text, weight: FontWeight.w700)),
        const SizedBox(height: 14),
        _fit(Row(children: isDo
            ? [body, const AArrow(active: true), cond, const AArrow(active: true, icon: Icons.replay_rounded)]
            : [cond, const AArrow(active: true), body, const AArrow(active: true, icon: Icons.replay_rounded)])),
        const SizedBox(height: 10),
        if (s == 1) Text('shart = false → tana bajarilmadi'.uz, style: codeStyle(size: 12.5, color: KColors.error)),
        if (s == 3) Text('tana 1 marta bajarildi, keyin shart = false'.uz, style: codeStyle(size: 12.5, color: KColors.success)),
      ]);
    },
  );
}

class _ListBoxes extends StatelessWidget {
  const _ListBoxes();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "`var mevalar = ['olma', 'nok', 'uzum'];` — 3 ta qutidan iborat poyezd.",
      '`mevalar[1]` → **nok**. Indeks 0 dan boshlanadi!',
      "`mevalar.add('anor');` — oxiriga yangi quti qo'shildi.",
      "`mevalar.remove('nok');` — quti olib tashlandi, indekslar surildi.",
    ],
    builder: (context, s) {
      final items = switch (s) {
        0 || 1 => ['olma', 'nok', 'uzum'],
        2 => ['olma', 'nok', 'uzum', 'anor'],
        _ => ['olma', 'uzum', 'anor'],
      };
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _fit(Row(children: [
          for (var i = 0; i < items.length; i++)
            TweenAnimationBuilder<double>(
              key: ValueKey(items[i]),
              tween: Tween(begin: 0, end: 1),
              duration: KDurations.slow,
              curve: Curves.easeOutBack,
              builder: (c, v, ch) => Transform.scale(scale: v, child: ch),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(children: [
                  AnimatedContainer(
                    duration: KDurations.medium,
                    width: 74,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (s == 1 && i == 1) || (s == 2 && i == 3) ? KColors.primary.withValues(alpha: 0.2) : context.k.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (s == 1 && i == 1) || (s == 2 && i == 3) ? KColors.primary : context.k.borderStrong, width: 2),
                    ),
                    child: Text("'${items[i]}'", style: codeStyle(size: 13, color: CodePalette.dark.string)),
                  ),
                  const SizedBox(height: 4),
                  Text('[$i]', style: codeStyle(size: 12, color: KColors.cyan, weight: FontWeight.w700)),
                ]),
              ),
            ),
        ])),
        const SizedBox(height: 10),
        Text('length = ${items.length}', style: codeStyle(size: 13, color: context.k.textSecondary)),
      ]);
    },
  );
}

class _MapPairs extends StatelessWidget {
  const _MapPairs();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Map — **kalit → qiymat** juftliklari: telefon kitobchasi kabi.',
      "`narxlar['sut']` → kalit topildi → **12000**",
      "`narxlar['choy']` → bunday kalit yo'q → **null**",
      "`narxlar['choy'] = 25000;` → yangi juftlik qo'shildi",
    ],
    builder: (context, s) {
      final pairs = [('non', '4000'), ('sut', '12000'), if (s >= 3) ('choy', '25000')];
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final (k, v) in pairs)
          AnimatedContainer(
            duration: KDurations.medium,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: (s == 1 && k == 'sut') || (s == 3 && k == 'choy') ? KColors.success.withValues(alpha: 0.18) : context.k.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.k.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text("'$k'", style: codeStyle(size: 14, color: CodePalette.dark.string)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_right_alt_rounded)),
              Text(v, style: codeStyle(size: 14, color: KColors.orange, weight: FontWeight.w700)),
            ]),
          ),
        const SizedBox(height: 8),
        if (s == 2)
          Text("narxlar['choy'] → null", style: codeStyle(size: 14, color: KColors.error, weight: FontWeight.w700)),
      ]);
    },
  );
}

class _NullBox extends StatelessWidget {
  const _NullBox();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`String? telefon;` — quti bor, lekin ichi **bo\'sh** (null).',
      "`telefon ?? 'Yo\\'q'` → quti bo'sh, shuning uchun zaxira qiymat olinadi.",
      '`telefon?.length` → bo\'sh quti — xato emas, natija **null**.',
      '`telefon!.length` → "ishon, bo\'sh emas!" — lekin bo\'sh edi → **xato** 💥',
    ],
    builder: (context, s) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _Shake(shake: s == 3, child: AVarBox(name: 'telefon', type: 'String?', value: 'null', highlight: true, color: s == 3 ? KColors.error : KColors.warning)),
      const SizedBox(height: 16),
      AnimatedSwitcher(
        duration: KDurations.medium,
        child: Text(
          ['bo\'sh quti', "'Yo\\'q'", 'null', 'Null check operator used on a null value'][s].replaceAll(r"\'", "'"),
          key: ValueKey(s),
          style: codeStyle(size: 14, color: [context.k.textMuted, KColors.success, KColors.cyan, KColors.error][s], weight: FontWeight.w700),
        ),
      ),
    ]),
  );
}

class _FunctionMachine extends StatelessWidget {
  const _FunctionMachine();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`int kvadrat(int son) => son * son;` — funksiya — bu "mashina".',
      '`kvadrat(5)` — argument **5** mashinaga kiradi va `son` parametriga yoziladi.',
      'Mashina ichida hisoblanadi: `5 * 5`',
      '`return` natijani — **25** ni chaqirgan joyga qaytaradi.',
    ],
    builder: (context, s) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 40,
        child: Stack(children: [
          APacket(text: '5', x: s == 0 ? -1 : (s == 1 ? -0.15 : 0), visible: s <= 1, color: KColors.primary),
          APacket(text: '25', x: s >= 3 ? 1 : 0.1, visible: s >= 3, color: KColors.success),
        ]),
      ),
      const SizedBox(height: 6),
      AnimatedContainer(
        duration: KDurations.medium,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [KColors.violet, KColors.primary.withValues(alpha: s == 2 ? 1 : 0.7)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [if (s == 2) BoxShadow(color: KColors.violet.withValues(alpha: 0.5), blurRadius: 24)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedRotation(turns: s >= 2 ? 2 : 0, duration: const Duration(milliseconds: 1500), child: const Icon(Icons.settings_rounded, color: Colors.white)),
          const SizedBox(width: 10),
          Text(s == 2 ? 'son * son = 5 * 5' : 'kvadrat(son)', style: codeStyle(size: 15, color: Colors.white, weight: FontWeight.w700)),
        ]),
      ),
    ]),
  );
}

class _Scope extends StatelessWidget {
  const _Scope();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Har bir `{ }` — alohida xona (scope).',
      '`main` ichidagi `tashqi` o\'zgaruvchisi ichki blokda **ko\'rinadi** ✓',
      'Ichki blokdagi `ichki` esa tashqarida **ko\'rinmaydi** ✗',
    ],
    builder: (context, s) {
      Widget room(String title, Color c, List<Widget> children, bool hl) => AnimatedContainer(
        duration: KDurations.medium,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: hl ? 0.14 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.7), width: hl ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: codeStyle(size: 12, color: c, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...children,
        ]),
      );
      return room('main() { }', KColors.primary, [
        Text("var tashqi = 'A';", style: codeStyle(size: 13, color: context.k.text)),
        const SizedBox(height: 6),
        room('if (true) { }', KColors.violet, [
          Text("var ichki = 'B';", style: codeStyle(size: 13, color: context.k.text)),
          Text(s >= 1 ? 'print(tashqi); ✓' : '', style: codeStyle(size: 13, color: KColors.success)),
        ], s == 1),
        const SizedBox(height: 6),
        Text(s >= 2 ? 'print(ichki); ✗ — topilmadi' : '', style: codeStyle(size: 13, color: KColors.error)),
      ], s == 2);
    },
  );
}

class _ClassObject extends StatelessWidget {
  const _ClassObject();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`class Talaba { String ism; int yosh; }` — bu **chizma** (shablon).',
      "`Talaba('Ali', 19)` — chizmadan birinchi **obyekt** yaratildi.",
      "`Talaba('Laylo', 20)` — xuddi shu chizmadan ikkinchi obyekt.",
      'Har bir obyektning qiymatlari **o\'ziniki**, tuzilishi esa bir xil.',
    ],
    builder: (context, s) {
      Widget obj(String ism, int yosh, bool show) => AnimatedScale(
        duration: KDurations.slow,
        curve: Curves.easeOutBack,
        scale: show ? 1 : 0,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: context.k.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: KColors.success, width: 1.5)),
          child: Column(children: [
            const Icon(Icons.person_rounded, color: KColors.success),
            Text("ism: '$ism'", style: codeStyle(size: 12, color: context.k.text)),
            Text('yosh: $yosh', style: codeStyle(size: 12, color: context.k.text)),
          ]),
        ),
      );
      return _fit(Row(children: [
        Container(
          width: 130,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KColors.primary, width: 1.5),
          ),
          child: Column(children: [
            const Icon(Icons.architecture_rounded, color: KColors.primary),
            Text('class Talaba', style: codeStyle(size: 12.5, color: KColors.primary, weight: FontWeight.w700)),
            Text('String ism', style: codeStyle(size: 12, color: context.k.textSecondary)),
            Text('int yosh', style: codeStyle(size: 12, color: context.k.textSecondary)),
          ]),
        ),
        const SizedBox(width: 6),
        AArrow(active: s >= 1),
        const SizedBox(width: 6),
        Column(children: [obj('Ali', 19, s >= 1), const SizedBox(height: 8), obj('Laylo', 20, s >= 2)]),
      ]));
    },
  );
}

class _Inheritance extends StatelessWidget {
  const _Inheritance();
  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`Hayvon` — ota class: hamma hayvonda `ism` va `ovoz()` bor.',
      '`It extends Hayvon` va `Mushuk extends Hayvon` — meros olishdi.',
      '`ovoz()` ni har biri **o\'zicha** qayta aniqladi (@override).',
      'Polimorfizm: bir xil chaqiruv `h.ovoz()` — har xil natija!',
    ],
    builder: (context, s) {
      Widget child(String name, String sound, bool show) => AnimatedOpacity(
        duration: KDurations.medium,
        opacity: show ? 1 : 0,
        child: Column(children: [
          ANode(label: name, icon: name == 'It' ? Icons.pets_rounded : Icons.cruelty_free_rounded, active: s >= 2, color: KColors.orange, width: 100),
          const SizedBox(height: 6),
          AnimatedScale(
            duration: KDurations.slow,
            curve: Curves.easeOutBack,
            scale: s >= 3 ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: KColors.warning, borderRadius: BorderRadius.circular(10)),
              child: Text(sound, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      );
      return Column(children: [
        const ANode(label: 'Hayvon', sub: 'ism, ovoz()', icon: Icons.category_rounded, active: true, width: 130),
        const SizedBox(height: 4),
        Icon(Icons.call_split_rounded, color: s >= 1 ? KColors.cyan : context.k.borderStrong),
        const SizedBox(height: 4),
        _fit(Row(children: [child('It', 'Vov-vov!', s >= 1), const SizedBox(width: 30), child('Mushuk', 'Miyov!', s >= 1)])),
      ]);
    },
  );
}

/// Animatsiya topilmasa ko'rsatiladigan izoh (kontent testlari buni oldini oladi).
class MissingAnimation extends StatelessWidget {
  const MissingAnimation(this.id, {super.key});
  final String id;
  @override
  Widget build(BuildContext context) => Text('Animatsiya: $id'.uz);
}


class _WidgetTree extends StatelessWidget {
  const _WidgetTree();

  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 250,
    captions: const [
      '`runApp(MaterialApp(...))` — ildiz (root) widget. Hammasi shundan boshlanadi.',
      '`MaterialApp` ichida `Scaffold` — ekran skeleti.',
      '`Scaffold` ikki farzandga ega: `appBar` va `body`.',
      'Barglar: `Text` widgetlari — ekranda ko\'rinadigan narsalar. Bu — **widget tree**.',
    ],
    builder: (context, s) {
      Widget node(String t, Color c, bool on) => AnimatedOpacity(
        duration: KDurations.medium,
        opacity: on ? 1 : 0.12,
        child: AnimatedScale(
          duration: KDurations.medium,
          scale: on ? 1 : 0.85,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.withValues(alpha: 0.8)),
            ),
            child: Text(t, style: codeStyle(size: 12.5, color: c, weight: FontWeight.w700)),
          ),
        ),
      );
      Widget edge(bool on) => AnimatedContainer(duration: KDurations.medium, width: 2, height: 14, color: on ? KColors.cyan : Colors.transparent);
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        node('MaterialApp', KColors.primary, s >= 0),
        edge(s >= 1),
        node('Scaffold', KColors.violet, s >= 1),
        edge(s >= 2),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(children: [
            node('AppBar', KColors.cyan, s >= 2),
            edge(s >= 3),
            node("Text('Salom')", KColors.success, s >= 3),
          ]),
          const SizedBox(width: 18),
          Column(children: [
            node('Center', KColors.cyan, s >= 2),
            edge(s >= 3),
            node("Text('Flutter')", KColors.success, s >= 3),
          ]),
        ]),
      ]);
    },
  );
}

class _SetStateFlow extends StatelessWidget {
  const _SetStateFlow();

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Ekranda `Son: 0`. Holat (state) — `_son = 0`.',
      'Foydalanuvchi tugmani bosdi → `onPressed` funksiyasi ishladi.',
      '`setState(() => _son++)` — holat o\'zgardi va Flutter\'ga "qayta chiz" deyildi.',
      'Flutter `build()` ni qayta chaqirdi → ekranda `Son: 1`. setState bo\'lmasa, ekran o\'zgarmasdi!',
    ],
    builder: (context, s) {
      Widget step(String t, IconData i, Color c, bool on) => AnimatedContainer(
        duration: KDurations.medium,
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: on ? c.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: on ? c : c.withValues(alpha: 0.25), width: on ? 2 : 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, color: on ? c : c.withValues(alpha: 0.4)),
          const SizedBox(height: 4),
          Text(t, style: codeStyle(size: 11.5, color: on ? c : c.withValues(alpha: 0.5), weight: FontWeight.w700)),
        ]),
      );
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: KDurations.medium,
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Text('Son: ${s >= 3 ? 1 : 0}', key: ValueKey(s >= 3), style: codeStyle(size: 26, weight: FontWeight.w800, color: s >= 3 ? KColors.success : null)),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
          step('bosish', Icons.touch_app_rounded, KColors.primary, s == 1),
          step('setState', Icons.sync_rounded, KColors.violet, s == 2),
          step('build()', Icons.construction_rounded, KColors.cyan, s == 3),
        ]),
      ]);
    },
  );
}

// ───────────────────────── Asinxron Dart ─────────────────────────

/// Tor ekranda sxemani [designWidth] kenglikda chizib, joyga sig'adigan qilib kichraytiradi.
class _FitWide extends StatelessWidget {
  const _FitWide({required this.designWidth, required this.child});
  final double designWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: SizedBox(width: math.max(c.maxWidth, designWidth), child: child),
    ),
  );
}

/// Navbat yoki holat uchun kichik "chip".
class _QueueChip extends StatelessWidget {
  const _QueueChip(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(text),
    tween: Tween(begin: 0, end: 1),
    duration: KDurations.medium,
    builder: (c, v, child) => Opacity(opacity: v, child: Transform.scale(scale: 0.85 + 0.15 * v, child: child)),
    child: Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
      child: Text(text, style: codeStyle(size: 11, color: color, weight: FontWeight.w700)),
    ),
  );
}

class _Lane extends StatelessWidget {
  const _Lane({required this.title, required this.color, required this.items, this.active = false});
  final String title;
  final Color color;
  final List<String> items;
  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: KDurations.medium,
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: active ? color.withValues(alpha: 0.10) : context.k.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: active ? color : context.k.border, width: active ? 2 : 1),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.uz, style: context.text.labelSmall!.copyWith(color: color, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      if (items.isEmpty)
        Text('bo\'sh', style: context.text.labelSmall)
      else
        Wrap(children: [for (final i in items) _QueueChip(i, color: color)]),
    ]),
  );
}

class _AsyncAwait extends StatelessWidget {
  const _AsyncAwait();

  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 270,
    captions: const [
      '`main()` ishlayapti va `yukla()` ni chaqirdi.',
      '`yukla()` ichidagi kod birinchi `await` gacha darhol bajariladi: **Yuklanmoqda**.',
      '`await` — `yukla()` shu joyda **to\'xtab turadi**, chaqiruvchiga esa darhol `Future` qaytadi.',
      'Dastur qotmaydi: `main()` davom etadi va **Boshqa ish** chiqadi.',
      '2 soniya o\'tdi — Future tugadi. `yukla()` to\'xtagan joyidan davom etadi: **Tayyor**.',
    ],
    builder: (context, s) {
      final active = switch (s) { 0 => 1, 1 => 5, 2 => 6, 3 => 2, _ => 7 };
      String state(bool running, bool waiting, bool done) => done ? 'tugadi ✓' : (waiting ? 'kutmoqda ⏸' : (running ? 'ishlayapti ▶' : '—'));
      return _FitWide(designWidth: 360, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 6,
          child: ACodePanel(lines: const [
            'void main() {',
            '  yukla();',
            "  print('Boshqa ish');",
            '}',
            'Future<void> yukla() async {',
            "  print('Yuklanmoqda');",
            '  await Future.delayed(2s);',
            "  print('Tayyor');",
            '}',
          ], active: active),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Column(children: [
            _Lane(title: 'main()', color: KColors.primary, items: [state(true, false, s >= 4)], active: s == 0 || s == 3),
            _Lane(title: 'yukla()', color: KColors.violet, items: [if (s >= 1) state(s == 1 || s == 4, s == 2 || s == 3, s >= 4)], active: s == 1 || s == 2 || s == 4),
            AnimatedOpacity(
              duration: KDurations.medium,
              opacity: s >= 2 ? 1 : 0.3,
              child: KProgressBar(value: s >= 4 ? 1 : (s >= 2 ? 0.5 : 0), color: KColors.warning, height: 6),
            ),
            const SizedBox(height: 6),
            AConsole(lines: [if (s >= 1) 'Yuklanmoqda', if (s >= 3) 'Boshqa ish', if (s >= 4) 'Tayyor']),
          ]),
        ),
      ]));
    },
  );
}

class _EventLoop extends StatelessWidget {
  const _EventLoop();

  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 300,
    captions: const [
      '`main()` call stack\'da bajarila boshladi.',
      "`print('1')` — sinxron, darhol konsolga.",
      '`Future(...)` — vazifa **event navbatiga** qo\'yildi (hali bajarilmaydi).',
      '`scheduleMicrotask(...)` — vazifa **microtask navbatiga** qo\'yildi.',
      "`print('2')` chiqdi va `main()` tugadi — stack bo'sh.",
      'Event loop avval **microtask** navbatini to\'liq bo\'shatadi → 3.',
      'So\'ng **event** navbatidan bitta vazifa olinadi → 4.',
    ],
    builder: (context, s) {
      final active = switch (s) { 0 => 0, 1 => 0, 2 => 1, 3 => 2, 4 => 3, _ => -1 };
      return _FitWide(designWidth: 360, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 5,
          child: ACodePanel(lines: const [
            "print('1');",
            "Future(() => print('4'));",
            "scheduleMicrotask(() => print('3'));",
            "print('2');",
          ], active: active),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Column(children: [
            _Lane(title: 'Call stack (hozir)', color: KColors.primary, items: [
              if (s <= 4) 'main()',
              if (s == 5) "print('3')",
              if (s == 6) "print('4')",
            ], active: true),
            _Lane(title: 'Microtask navbati', color: KColors.violet, items: [if (s >= 3 && s < 5) "print('3')"], active: s == 3 || s == 5),
            _Lane(title: 'Event navbati', color: KColors.orange, items: [if (s >= 2 && s < 6) "print('4')"], active: s == 2 || s == 6),
            AConsole(lines: [if (s >= 1) '1', if (s >= 4) '2', if (s >= 5) '3', if (s >= 6) '4']),
          ]),
        ),
      ]));
    },
  );
}

class _StreamFlow extends StatelessWidget {
  const _StreamFlow();

  @override
  Widget build(BuildContext context) => StoryAnimation(
    height: 240,
    captions: const [
      'Oqim (Stream) tayyor: manbadan 1, 2, 3 qiymatlari navbat bilan keladi.',
      '**1** keldi → `where(isOdd)` o\'tkazdi → `map(x * 10)` → tinglovchi **10** ni oldi.',
      '**2** keldi → `where(isOdd)` uni o\'tkazmadi ✗ — tinglovchiga yetmaydi.',
      '**3** keldi → filtrdan o\'tdi → **30**.',
      'Manba tugadi → `onDone` chaqirildi. Oqim yopildi.',
    ],
    builder: (context, s) {
      final current = switch (s) { 1 => '1', 2 => '2', 3 => '3', _ => null };
      final passes = s == 1 || s == 3;
      Widget stage(String label, IconData icon, Color c, bool on, {String? sub}) =>
          Flexible(child: ANode(label: label, icon: icon, active: on, color: c, sub: sub, width: 86));
      return _FitWide(designWidth: 360, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          stage('Manba', Icons.water_drop_rounded, KColors.cyan, current != null, sub: current),
          const AArrow(),
          stage('where', Icons.filter_alt_rounded, KColors.violet, current != null, sub: current == null ? null : (passes ? 'o\'tdi' : '✗')),
          const AArrow(),
          stage('map', Icons.auto_fix_high_rounded, KColors.orange, passes, sub: passes ? '×10' : null),
          const AArrow(),
          stage('listen', Icons.hearing_rounded, KColors.success, passes || s == 4, sub: s == 4 ? 'onDone' : null),
        ]),
        const SizedBox(height: 14),
        AConsole(lines: [if (s >= 1) '10', if (s >= 3) '30', if (s >= 4) 'tugadi']),
      ]));
    },
  );
}
