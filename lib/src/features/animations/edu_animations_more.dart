import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import 'story.dart';

// Darslar uchun qo'shimcha animatsion tushuntirishlar ("video o'rniga").
// Har biri bitta tushunchani sahnalarga bo'lib ko'rsatadi.

Widget _code(String t, {Color? color, double size = 14, bool on = true}) => AnimatedOpacity(
  duration: KDurations.medium,
  opacity: on ? 1 : 0.25,
  child: Text(t, style: codeStyle(size: size, color: color, weight: FontWeight.w700)),
);

class _Chip extends StatelessWidget {
  const _Chip(this.text, {this.color = KColors.primary, this.on = true, this.result});
  final String text;
  final Color color;
  final bool on;
  final String? result;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: KDurations.slow,
    curve: Curves.easeOutCubic,
    margin: const EdgeInsets.all(4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: on ? color.withValues(alpha: context.isDark ? 0.25 : 0.12) : context.k.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: on ? color : context.k.border, width: on ? 2 : 1),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(text, style: codeStyle(size: 14, color: context.k.text, weight: FontWeight.w700)),
      AnimatedSwitcher(
        duration: KDurations.medium,
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: result == null || !on
            ? const SizedBox.shrink()
            : Text('  →  $result', key: ValueKey(result), style: codeStyle(size: 14, color: color, weight: FontWeight.w800)),
      ),
    ]),
  );
}

/// Arifmetik va taqqoslash operatorlari.
class OperatorsAnim extends StatelessWidget {
  const OperatorsAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`int a = 7, b = 3;` — ikki son. **Operatorlar** ular ustida amal bajaradi.',
      '`a + b` → **10**, `a - b` → **4**, `a * b` → **21** — oddiy matematika.',
      '`a / b` → **2.33…** (doim `double`!), `a ~/ b` → **2** (butun qism), `a % b` → **1** (qoldiq).',
      'Taqqoslash natijasi — `bool`: `a > b` → **true**, `a == b` → **false**.',
    ],
    // Tor ekranda butun sahna kichrayadi — chiplar qatorga sig'masa ham kesilmaydi.
    builder: (context, s) => FittedBox(fit: BoxFit.scaleDown, child: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Chip('a = 7', color: KColors.primary, on: true),
        _Chip('b = 3', color: KColors.violet, on: true),
      ]),
      const SizedBox(height: 8),
      Wrap(alignment: WrapAlignment.center, children: [
        _Chip('a + b', color: KColors.success, on: s >= 1, result: '10'),
        _Chip('a - b', color: KColors.success, on: s >= 1, result: '4'),
        _Chip('a * b', color: KColors.success, on: s >= 1, result: '21'),
        _Chip('a / b', color: KColors.warning, on: s >= 2, result: '2.33…'),
        _Chip('a ~/ b', color: KColors.warning, on: s >= 2, result: '2'),
        _Chip('a % b', color: KColors.warning, on: s >= 2, result: '1'),
        _Chip('a > b', color: KColors.cyan, on: s >= 3, result: 'true'),
        _Chip('a == b', color: KColors.error, on: s >= 3, result: 'false'),
      ]),
    ]))),
  );
}

/// Turlarni o'zgartirish: String ↔ int, xavfsiz tryParse.
class TypeConvertAnim extends StatelessWidget {
  const TypeConvertAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "`'42'` — bu **matn** (String). U bilan hisoblab bo'lmaydi: `'42' + 1` — xato.",
      "`int.parse('42')` — matn \"konvertor\"dan o'tib, **42** soniga aylandi. Endi `42 + 1` → **43**.",
      "`42.toString()` — teskari yo'l: son yana matnga aylandi → `'42'`.",
      "`int.parse('salom')` → **FormatException**! Xavfsiz usul: `int.tryParse('salom')` → **null**.",
    ],
    builder: (context, s) {
      final bad = s == 3;
      final input = switch (s) { 2 => '42', 3 => "'salom'", _ => "'42'" };
      final output = switch (s) { 0 => '?', 1 => '42', 2 => "'42'", _ => 'null' };
      final inColor = s == 2 ? KColors.primary : CodePalette.dark.string;
      final outColor = switch (s) { 1 => KColors.primary, 2 => CodePalette.dark.string, 3 => KColors.error, _ => context.k.textMuted };
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _box(context, input, s == 2 ? 'int' : 'String', inColor),
        const SizedBox(width: 10),
        AnimatedContainer(
          duration: KDurations.slow,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: bad ? [KColors.error, KColors.orange] : [KColors.violet, KColors.primary]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: (bad ? KColors.error : KColors.violet).withValues(alpha: 0.4), blurRadius: 18)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedRotation(turns: s.toDouble(), duration: const Duration(milliseconds: 900), child: Icon(bad ? Icons.error_rounded : Icons.autorenew_rounded, color: Colors.white)),
            const SizedBox(height: 4),
            Text(switch (s) { 2 => '.toString()', 3 => 'tryParse', _ => 'int.parse' }, style: codeStyle(size: 12, color: Colors.white, weight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(width: 10),
        _box(context, output, switch (s) { 1 => 'int', 2 => 'String', 3 => 'int?', _ => '' }, outColor),
      ]);
    },
  );

  Widget _box(BuildContext context, String value, String type, Color color) => Column(mainAxisSize: MainAxisSize.min, children: [
    AnimatedContainer(
      duration: KDurations.slow,
      width: 96,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.k.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: color, width: 2)),
      child: AnimatedSwitcher(duration: KDurations.medium, child: Text(value, key: ValueKey(value), style: codeStyle(size: 15, color: color, weight: FontWeight.w800))),
    ),
    const SizedBox(height: 4),
    Text(type, style: codeStyle(size: 11.5, color: context.k.textMuted)),
  ]);
}

/// switch: qiymat mos case'ga oqib boradi.
class SwitchAnim extends StatelessWidget {
  const SwitchAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`switch (kun)` — `kun = 3`. Qiymat har bir `case` bilan **tartib bilan** solishtiriladi.',
      '`case 1` — mos emas. `case 2` — mos emas. Keyingisiga o\'tamiz...',
      '`case 3` — **mos keldi!** Natija: `\'Chorshanba\'`. Qolganlari tekshirilmaydi.',
      'Hech biri mos kelmasa — `default` (yoki Dart 3 da `_`) ishlaydi.',
    ],
    builder: (context, s) {
      final active = switch (s) { 0 => -1, 1 => 1, 2 => 2, _ => 3 };
      Widget lane(String c, String r, int i) {
        final hit = (s == 2 && i == 2) || (s == 3 && i == 3);
        final checking = s == 1 && i <= 1;
        final color = hit ? KColors.success : (checking ? KColors.error : context.k.borderStrong);
        return AnimatedContainer(
          duration: KDurations.medium,
          width: 260,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: hit ? KColors.success.withValues(alpha: 0.14) : context.k.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: hit ? 2 : 1),
          ),
          child: Row(children: [
            Expanded(child: Text(c, style: codeStyle(size: 13, color: context.k.text, weight: FontWeight.w700))),
            Text(r, style: codeStyle(size: 13, color: CodePalette.dark.string)),
            const SizedBox(width: 6),
            Icon(hit ? Icons.check_circle_rounded : (checking ? Icons.close_rounded : Icons.circle_outlined), size: 16, color: color),
          ]),
        );
      }

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(
          duration: KDurations.slow,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: KColors.primary, borderRadius: BorderRadius.circular(14)),
          child: Text(s == 3 ? 'kun = 9' : 'kun = 3', style: codeStyle(size: 14, color: Colors.white, weight: FontWeight.w800)),
        ),
        AnimatedPadding(
          duration: KDurations.slow,
          padding: EdgeInsets.only(left: 10, top: active < 0 ? 0 : active * 18.0),
          child: const Icon(Icons.arrow_forward_rounded, color: KColors.primary),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          lane('case 1:', "'Dushanba'", 0),
          lane('case 2:', "'Seshanba'", 1),
          lane('case 3:', "'Chorshanba'", 2),
          lane('default:', "'Noma\\'lum'", 3),
        ]),
      ]);
    },
  );
}

/// Konstruktor: chizmadan obyektlar.
class ConstructorAnim extends StatelessWidget {
  const ConstructorAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`class Talaba` — **chizma** (blueprint): `ism` va `yosh` maydonlari bor, lekin hali hech kim yo\'q.',
      "`Talaba('Ali', 20)` — **konstruktor** chizmadan yangi obyekt yasaydi.",
      '`Talaba(this.ism, this.yosh)` — argumentlar shu obyektning **o\'z** maydonlariga yoziladi.',
      "`Talaba('Vali', 22)` — xuddi shu chizmadan **ikkinchi**, mustaqil obyekt. Ular bir-biriga ta'sir qilmaydi.",
    ],
    builder: (context, s) {
      Widget obj(String ism, String yosh, bool show, bool filled) => AnimatedScale(
        duration: KDurations.slow,
        curve: Curves.easeOutBack,
        scale: show ? 1 : 0,
        child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KColors.success, width: 2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('obyekt', style: codeStyle(size: 11, color: KColors.success)),
            _code("ism: ${filled ? "'$ism'" : '…'}", size: 12.5, color: context.k.text),
            _code('yosh: ${filled ? yosh : '…'}', size: 12.5, color: context.k.text),
          ]),
        ),
      );
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KColors.primary, width: 2, strokeAlign: BorderSide.strokeAlignInside),
            color: KColors.primary.withValues(alpha: 0.06),
          ),
          child: Column(children: [
            _code('class Talaba', color: KColors.primary, size: 13),
            _code('String ism;  int yosh;', size: 12, color: context.k.textSecondary),
          ]),
        ),
        const SizedBox(height: 6),
        Icon(Icons.arrow_downward_rounded, color: s >= 1 ? KColors.success : context.k.borderStrong),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          obj('Ali', '20', s >= 1, s >= 2),
          obj('Vali', '22', s >= 3, s >= 3),
        ]),
      ]);
    },
  );
}

/// try/catch: xato otiladi va ushlanadi.
class TryCatchAnim extends StatelessWidget {
  const TryCatchAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      'Dastur qatorma-qator bajarilmoqda...',
      "`int.parse('abc')` — bu matnni songa aylantirib bo'lmaydi: **xato (exception) otildi!**",
      "`try` bo'lmasa — xato yuqoriga ko'tariladi va dastur **to'xtaydi** (crash).",
      "`try { … } catch (e) { … }` — xato **ushlandi**, foydalanuvchiga tushunarli xabar ko'rsatildi va dastur **davom etdi**.",
    ],
    builder: (context, s) {
      final lines = [
        "print('Boshlandi');",
        "int.parse('abc');",
        "print('Davom etdi');",
      ];
      return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 230,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CodePalette.dark.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: s == 3 ? KColors.success : (s == 2 ? KColors.error : const Color(0xFF223052)), width: s >= 2 ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (s == 3) _code('try {', color: CodePalette.dark.control, size: 12.5),
            for (var i = 0; i < lines.length; i++)
              AnimatedContainer(
                duration: KDurations.medium,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: (s == 0 && i == 0) || (s >= 1 && i == 1) ? (i == 1 ? KColors.error.withValues(alpha: 0.25) : KColors.primary.withValues(alpha: 0.2)) : Colors.transparent,
                child: _code((s == 3 ? '  ' : '') + lines[i], size: 12.5, color: CodePalette.dark.text, on: !(s == 2 && i == 2)),
              ),
            if (s == 3) _code("} catch (e) { print('Xato: raqam kiriting'); }", color: CodePalette.dark.control, size: 11.5),
          ]),
        ),
        const SizedBox(width: 14),
        AnimatedSwitcher(
          duration: KDurations.medium,
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: switch (s) {
            0 => const SizedBox(key: ValueKey(0), width: 90),
            1 => _badge('Exception!', Icons.warning_rounded, KColors.error, 1),
            2 => _badge('CRASH', Icons.dangerous_rounded, KColors.error, 2),
            _ => _badge('Ushlandi ✓', Icons.sports_handball_rounded, KColors.success, 3),
          },
        ),
      ]);
    },
  );

  Widget _badge(String t, IconData i, Color c, int key) => Container(
    key: ValueKey(key),
    width: 96,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 16)]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, color: Colors.white),
      const SizedBox(height: 4),
      Text(t, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
    ]),
  );
}

/// Telefon ramkasi — Flutter UI animatsiyalari uchun.
class _Phone extends StatelessWidget {
  const _Phone({required this.child, this.width = 150, this.height = 250});
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: KColors.navy, borderRadius: BorderRadius.circular(24)),
    child: ClipRRect(borderRadius: BorderRadius.circular(18), child: ColoredBox(color: Colors.white, child: child)),
  );
}

/// StatelessWidget: faqat otadan kelgan parametrlardan chiziladi.
class StatelessPropsAnim extends StatelessWidget {
  const StatelessPropsAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "`Salom(ism: 'Ali')` — ota widget ma'lumotni **parametr** orqali beradi.",
      '`StatelessWidget` faqat shu ma\'lumotdan chiziladi → ekranda **Salom, Ali!**',
      "Ota yangi qiymat bersa — `Salom(ism: 'Vali')` — widget **qaytadan quriladi**.",
      "O'zi o'zgara olmaydi: tugma bosilganda o'zgaradigan narsa kerak bo'lsa — `StatefulWidget`.",
    ],
    builder: (context, s) {
      final ism = s >= 2 ? 'Vali' : 'Ali';
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          _Chip('Ota', color: KColors.violet),
          AnimatedSwitcher(
            duration: KDurations.medium,
            child: Padding(
              key: ValueKey(ism),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _code("ism: '$ism'", color: KColors.violet, size: 13),
            ),
          ),
          const Icon(Icons.arrow_downward_rounded, color: KColors.violet),
          _Chip('Salom', color: KColors.primary, on: s >= 1),
          AnimatedOpacity(
            duration: KDurations.medium,
            opacity: s == 3 ? 1 : 0,
            child: Text('o\'zi o\'zgarmaydi', style: codeStyle(size: 11.5, color: context.k.textMuted)),
          ),
        ]),
        const SizedBox(width: 18),
        _Phone(
          width: 140,
          height: 200,
          child: Center(
            child: AnimatedSwitcher(
              duration: KDurations.slow,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: s == 0
                  ? const SizedBox(key: ValueKey('e'))
                  : Text('Salom, $ism!', key: ValueKey(ism), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: KColors.navy)),
            ),
          ),
        ),
      ]);
    },
  );
}

/// ListView.builder: faqat ko'rinadigan elementlar quriladi.
class ListBuilderAnim extends StatelessWidget {
  const ListBuilderAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "1000 ta mahsulot. Hammasini birdaniga yasash — **sekin** va xotira ko'p ketadi.",
      '`ListView.builder` faqat **ekranda ko\'rinadigan** elementlarni quradi (yashil).',
      "Aylantirsangiz: chiqib ketganlari olib tashlanadi, pastdan yangilari quriladi.",
      "Natija: 1000 emas, bir vaqtda faqat ekrandagilar va biroz zaxira (cache) — **o'nga yaqin** widget. Tez va tejamkor!",
    ],
    builder: (context, s) {
      final offset = s >= 2 ? 3 : 0;
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 150,
          height: 240,
          // Aylantirilgan ro'yxat sahnadan tashqariga chiqmasin.
          child: Stack(clipBehavior: Clip.hardEdge, children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
              top: -offset * 30.0,
              left: 10,
              right: 10,
              child: Column(children: [
                for (var i = 0; i < 12; i++)
                  Builder(builder: (context) {
                    final visible = s >= 1 && i >= offset && i < offset + 6;
                    return AnimatedContainer(
                      duration: KDurations.medium,
                      height: 26,
                      margin: const EdgeInsets.only(bottom: 4),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: visible ? KColors.success.withValues(alpha: 0.2) : (s == 0 ? KColors.warning.withValues(alpha: 0.15) : context.k.surfaceAlt.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: visible ? KColors.success : context.k.border),
                      ),
                      child: Text('Mahsulot ${i + 1}', style: codeStyle(size: 11, color: visible ? context.k.text : context.k.textMuted)),
                    );
                  }),
              ]),
            ),
            // Ekran oynasi.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: KColors.navy, width: 4)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('qurilgan widgetlar', style: codeStyle(size: 11.5, color: context.k.textMuted)),
          AnimatedSwitcher(
            duration: KDurations.medium,
            child: Text(s == 0 ? '1000' : '≈10', key: ValueKey(s == 0), style: numberStyle(TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: s == 0 ? KColors.warning : KColors.success))),
          ),
        ]),
      ]);
    },
  );
}

/// Scaffold — ekran "skeleti".
class ScaffoldPartsAnim extends StatelessWidget {
  const ScaffoldPartsAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`Scaffold` — ekranning tayyor **skeleti**. Unga bo\'laklarni joylaymiz.',
      '`appBar:` — tepadagi sarlavha paneli.',
      '`body:` — asosiy kontent: ro\'yxat, matn, rasm...',
      '`floatingActionButton:` va `bottomNavigationBar:` — asosiy amal tugmasi va pastki menyu.',
    ],
    builder: (context, s) {
      Widget part(String label, bool on, Color c, {double? h, bool expand = false}) {
        final box = AnimatedContainer(
          duration: KDurations.slow,
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? c.withValues(alpha: 0.85) : const Color(0xFFEFF3F9),
            border: Border.all(color: on ? c : const Color(0xFFDCE3EE)),
          ),
          child: AnimatedOpacity(
            duration: KDurations.medium,
            opacity: on ? 1 : 0.35,
            child: Text(label, style: codeStyle(size: 11, color: on ? Colors.white : KColors.navy, weight: FontWeight.w700)),
          ),
        );
        return expand ? Expanded(child: box) : box;
      }

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Phone(
          width: 160,
          height: 260,
          child: Stack(children: [
            Column(children: [
              part('appBar', s >= 1, KColors.primary, h: 40),
              part('body', s >= 2, KColors.violet, expand: true),
              part('bottomNavigationBar', s >= 3, KColors.navy, h: 34),
            ]),
            Positioned(
              right: 10,
              bottom: 44,
              child: AnimatedScale(
                duration: KDurations.slow,
                curve: Curves.easeOutBack,
                scale: s >= 3 ? 1 : 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(color: KColors.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
      ]);
    },
  );
}

/// TextField → controller → setState → yangi matn.
class InputFlowAnim extends StatelessWidget {
  const InputFlowAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      "Foydalanuvchi `TextField` ga yozadi: **A… Al… Ali**",
      '`onChanged: (v) => …` — har bir harfda funksiya chaqiriladi, `v` = hozirgi matn.',
      '`setState(() => _ism = v)` — holat yangilandi, Flutter `build()` ni qayta chaqiradi.',
      "Ekranda: **Salom, Ali!** Kiritish → holat → ekran — har qanday formaning asosi.",
    ],
    builder: (context, s) {
      final typed = switch (s) { 0 => 'Al', _ => 'Ali' };
      Widget step(String t, bool on, Color c) => _Chip(t, color: c, on: on);
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Phone(
          width: 150,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: KColors.primary, width: 2), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Text(typed, style: const TextStyle(color: KColors.navy, fontWeight: FontWeight.w700)),
                  Container(width: 2, height: 16, color: KColors.primary),
                ]),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: KDurations.slow,
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Text(s >= 3 ? 'Salom, Ali!' : 'Salom, !', key: ValueKey(s >= 3), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: s >= 3 ? KColors.success : KColors.navy)),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 12),
        Column(mainAxisSize: MainAxisSize.min, children: [
          step('onChanged', s >= 1, KColors.violet),
          const Icon(Icons.arrow_downward_rounded, size: 18),
          step('setState', s >= 2, KColors.primary),
          const Icon(Icons.arrow_downward_rounded, size: 18),
          step('build()', s >= 3, KColors.success),
        ]),
      ]);
    },
  );
}

/// Expanded flex bo'yicha joy bo'lish va Stack qatlamlari.
class FlexSplitAnim extends StatelessWidget {
  const FlexSplitAnim({super.key});

  @override
  Widget build(BuildContext context) => StoryAnimation(
    captions: const [
      '`Row` ichida 60 px li qat\'iy quti va ikkita `Expanded`. Qolgan joy qanday bo\'linadi?',
      '`Expanded(flex: 2)` va `Expanded(flex: 1)` → qolgan joy **2 : 1** nisbatda bo\'lindi.',
      '`flex` ni o\'zgartirsak (1 : 1) — joy teng bo\'linadi. Ekran kengligi qanday bo\'lsa ham!',
      '`Stack` esa boshqacha: farzandlar **ustma-ust** — oxirgisi eng tepada (masalan, rasm ustidagi yozuv).',
    ],
    builder: (context, s) {
      final a = s >= 2 ? 1 : 2;
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (s < 3)
          SizedBox(
            width: 300,
            height: 64,
            child: Row(children: [
              Container(width: 60, color: KColors.cyan.withValues(alpha: 0.4), alignment: Alignment.center, child: _code('60', size: 12)),
              AnimatedExpanded(
                flex: s == 0 ? 0 : a,
                child: Container(
                  color: KColors.primary,
                  alignment: Alignment.center,
                  child: FittedBox(child: _code(s == 0 ? '?' : 'flex: $a', color: Colors.white, size: 12)),
                ),
              ),
              AnimatedExpanded(
                flex: s == 0 ? 0 : 1,
                child: Container(
                  color: KColors.violet,
                  alignment: Alignment.center,
                  child: FittedBox(child: _code(s == 0 ? '?' : 'flex: 1', color: Colors.white, size: 12)),
                ),
              ),
            ]),
          )
        else
          SizedBox(
            width: 200,
            height: 150,
            child: Stack(children: [
              for (final (i, c, label) in [(0, KColors.primary, 'rasm'), (1, KColors.violet, 'gradient'), (2, KColors.orange, 'matn')])
                TweenAnimationBuilder<double>(
                  key: ValueKey(i),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + i * 300),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) => Positioned(left: 14.0 * i + 10, top: 14.0 * i + 10 - (1 - v) * 30, child: Opacity(opacity: v.clamp(0, 1), child: child!)),
                  child: Container(
                    width: 140,
                    height: 90,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 10)]),
                    child: Text('$i: $label', style: codeStyle(size: 11, color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
      ]);
    },
  );
}

/// `Expanded` ni flex o'zgarganda silliq animatsiya qiladi (0 — hali joy yo'q).
class AnimatedExpanded extends StatelessWidget {
  const AnimatedExpanded({super.key, required this.flex, required this.child});
  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: flex.toDouble()),
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeInOutCubic,
    builder: (context, v, child) => v < 0.01 ? const SizedBox.shrink() : Flexible(fit: FlexFit.tight, flex: (v * 100).round(), child: child!),
    child: child,
  );
}
