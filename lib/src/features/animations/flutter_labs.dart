import 'package:flutter/material.dart';

import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';

// Flutter tushunchalari uchun interaktiv laboratoriyalar. Ular rasm emas:
// ko'rsatilgan qiymatlar shu yerda ishlayotgan haqiqiy Flutter layout va
// rebuild mexanizmidan olinadi.

// ───────────────────── Constraints go down, sizes go up ─────────────────────

enum _Parent {
  center('Center ichida', 'Ota bo\'sh (loose) chegara beradi: 0 dan maksimumgacha istalgan o\'lcham.'),
  tight('SizedBox 120×80', 'Ota qat\'iy (tight) chegara beradi: bola so\'raganidan qat\'i nazar aynan 120×80 bo\'ladi.'),
  column('Column ichida', 'Column asosiy o\'q bo\'yicha cheksiz (∞) balandlik beradi — bola xohlagancha cho\'zila oladi va ekrandan chiqib ketishi mumkin.'),
  expanded('Row + Expanded', 'Row 60 px li qo\'shniga joy ajratib, Expanded bolaga qolgan kenglikni qat\'iy beradi.');

  const _Parent(this.title, this.note);
  final String title;
  final String note;
}

/// "Constraints go down, sizes go up" qoidasini jonli ko'rsatadi.
class ConstraintsLab extends StatefulWidget {
  const ConstraintsLab({super.key});

  @override
  State<ConstraintsLab> createState() => _ConstraintsLabState();
}

class _ConstraintsLabState extends State<ConstraintsLab> {
  static const _frame = Size(260, 160);
  _Parent _parent = _Parent.center;
  double _w = 180;
  double _h = 100;

  /// Ota bolaga beradigan chegara — quyidagi haqiqiy widgetlar bilan bir xil.
  BoxConstraints get _constraints => switch (_parent) {
    _Parent.center => BoxConstraints.loose(_frame),
    _Parent.tight => BoxConstraints.tight(const Size(120, 80)),
    _Parent.column => BoxConstraints(maxWidth: _frame.width),
    _Parent.expanded => BoxConstraints.tightFor(width: _frame.width - 60).copyWith(minHeight: 0, maxHeight: _frame.height),
  };

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final c = _constraints;
    final got = c.constrain(Size(_w, _h));
    final clampedW = got.width != _w, clampedH = got.height != _h;
    final overflow = _parent == _Parent.column && got.height > _frame.height;
    String range(double min, double max) => '${min.round()} ≤ … ≤ ${max.isInfinite ? '∞' : max.round()}';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final p in _Parent.values)
          ChoiceChip(label: Text(p.title.uz), selected: _parent == p, onSelected: (_) => setState(() => _parent = p)),
      ]),
      const SizedBox(height: 12),
      // Haqiqiy layout: bola ichidagi LayoutBuilder otadan kelgan chegarani o'zi ko'rsatadi.
      Center(
        child: FittedBox(
          child: Container(
            width: _frame.width,
            height: _frame.height,
            decoration: BoxDecoration(color: k.surfaceAlt, borderRadius: BorderRadius.circular(8)),
            // Chegara chizig'i ustida: decoration.border bolaga joyni 1–2 px kichraytirib yuborardi.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: overflow ? KColors.error : k.borderStrong, width: overflow ? 2 : 1),
            ),
            clipBehavior: Clip.hardEdge,
            child: _liveParent(),
          ),
        ),
      ),
      const SizedBox(height: 12),
      _Step(n: 1, icon: Icons.south_rounded, color: KColors.primary, title: 'Ota beradi (constraints ↓)', value: 'kenglik ${range(c.minWidth, c.maxWidth)}\nbalandlik ${range(c.minHeight, c.maxHeight)}'),
      _Step(n: 2, icon: Icons.straighten_rounded, color: KColors.violet, title: 'Bola so\'raydi', value: 'Container(width: ${_w.round()}, height: ${_h.round()})'),
      _Step(
        n: 3,
        icon: Icons.north_rounded,
        color: clampedW || clampedH ? KColors.warning : KColors.success,
        title: 'Bola oladi (size ↑)',
        value: '${got.width.round()} × ${got.height.round()}${clampedW || clampedH ? '  — chegaradan chiqib bo\'lmaydi' : ''}',
      ),
      const SizedBox(height: 4),
      _Slider(label: 'width', value: _w, max: 320, onChanged: (v) => setState(() => _w = v)),
      _Slider(label: 'height', value: _h, max: 220, onChanged: (v) => setState(() => _h = v)),
      const SizedBox(height: 4),
      RichUz(_parent.note, style: context.text.bodySmall),
      if (overflow) ...[
        const SizedBox(height: 6),
        RichUz(
          'Ekranda bu holat sariq-qora chiziqli **overflow** xatosi bo\'lardi. Yechim — bolani `Expanded` bilan o\'rash yoki `SingleChildScrollView` ishlatish.',
          style: context.text.bodySmall!.copyWith(color: context.k.errorText),
        ),
      ],
    ]);
  }

  Widget _liveParent() {
    final child = LayoutBuilder(builder: (context, c) => _ProbeBox(width: _w, height: _h, constraints: c));
    return switch (_parent) {
      _Parent.center => Center(child: child),
      _Parent.tight => Center(child: SizedBox(width: 120, height: 80, child: child)),
      // OverflowBox Column'ga haqiqiy cheksiz balandlik beradi; ramka kesadi.
      _Parent.column => OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
      ),
      _Parent.expanded => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 60, color: KColors.cyan.withValues(alpha: 0.25), alignment: Alignment.center, child: const Text('60', style: TextStyle(fontSize: 11))),
        // Bola to'g'ridan-to'g'ri Expanded ichida: Align qo'yilsa chegarani bo'shatib yuboradi.
        Expanded(child: child),
      ]),
    };
  }
}

class _ProbeBox extends StatelessWidget {
  const _ProbeBox({required this.width, required this.height, required this.constraints});
  final double width;
  final double height;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    String f(double v) => v.isInfinite ? '∞' : '${v.round()}';
    return AnimatedContainer(
      duration: KMotion.off(context) ? Duration.zero : KDurations.medium,
      curve: KMotion.emphasized,
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [KColors.primary, KColors.cyan]),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        child: Text('w ≤ ${f(constraints.maxWidth)}\nh ≤ ${f(constraints.maxHeight)}',
            textAlign: TextAlign.center, style: codeStyle(size: 12, color: Colors.white, weight: FontWeight.w700)),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.icon, required this.color, required this.title, required this.value});
  final int n;
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 13, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$n. $title'.uz, style: context.text.labelLarge),
          AnimatedSwitcher(
            duration: KDurations.fast,
            child: Text(value.uz, key: ValueKey(value), style: codeStyle(size: 12.5, color: context.k.textSecondary)),
          ),
        ]),
      ),
    ]),
  );
}

class _Slider extends StatelessWidget {
  const _Slider({required this.label, required this.value, required this.max, required this.onChanged});
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 52, child: Text(label, style: codeStyle(size: 12.5))),
    Expanded(child: Slider(value: value, min: 20, max: max, onChanged: onChanged)),
    SizedBox(width: 36, child: Text('${value.round()}', textAlign: TextAlign.end, style: codeStyle(size: 12.5))),
  ]);
}

// ───────────────────── Qaysi widget qayta quriladi? ─────────────────────

/// `build()` chaqiruvlarini sanaydigan jurnal (har bir laboratoriya uchun alohida).
class _BuildLog extends InheritedWidget {
  const _BuildLog({required this.counts, required super.child});
  final Map<String, int> counts;

  static Map<String, int> of(BuildContext context) => context.getInheritedWidgetOfExactType<_BuildLog>()!.counts;

  @override
  bool updateShouldNotify(_BuildLog old) => false;
}

/// Daraxt tuguni: har bir `build()` da hisobni oshiradi va yonib o'chadi.
/// `const` nusxasi Flutter tomonidan qayta qurilmaydi — hisob o'zgarmaydi.
class _Probe extends StatelessWidget {
  const _Probe(this.id, this.label, {this.children = const [], this.onTap, this.hint});
  final String id;
  final String label;
  final List<Widget> children;
  final VoidCallback? onTap;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final log = _BuildLog.of(context);
    final n = log[id] = (log[id] ?? 0) + 1;
    final k = context.k;
    final node = TweenAnimationBuilder<double>(
      // Har bir yangi build — yangi kalit — chaqnash qaytadan boshlanadi.
      key: ValueKey(n),
      tween: Tween(begin: KMotion.off(context) || n == 1 ? 0 : 1, end: 0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, v, child) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Color.lerp(k.surface, KColors.warning.withValues(alpha: 0.35), v),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color.lerp(k.border, KColors.warning, v)!, width: 1 + v),
        ),
        child: child,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(label, style: codeStyle(size: 12.5, weight: FontWeight.w700, color: k.text))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: k.surfaceHigh, borderRadius: BorderRadius.circular(999)),
          child: Text('build ×$n', style: numberStyle(TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: k.textSecondary))),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 30), padding: const EdgeInsets.symmetric(horizontal: 10)),
            onPressed: onTap,
            child: Text('setState()', style: codeStyle(size: 12, color: Colors.white, weight: FontWeight.w700)),
          ),
        ],
        if (hint != null) ...[const SizedBox(width: 6), Text(hint!.uz, style: context.text.labelSmall)],
      ]),
    );
    if (children.isEmpty) return node;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      node,
      Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: k.borderStrong, width: 2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children),
      ),
    ]);
  }
}

/// setState nimani qayta quradi: holat qayerda turishi va `const` ning ta'siri.
class RebuildLab extends StatefulWidget {
  const RebuildLab({super.key});

  @override
  State<RebuildLab> createState() => _RebuildLabState();
}

class _RebuildLabState extends State<RebuildLab> {
  final _counts = <String, int>{};
  bool _stateLow = false;
  bool _useConst = false;
  int _epoch = 0;

  void _reset(VoidCallback change) => setState(() {
    change();
    _counts.clear();
    _epoch++;
  });

  @override
  Widget build(BuildContext context) {
    final caption = _stateLow
        ? 'Holat **pastda**: `setState` faqat **Hisob bloki**ni qayta quradi — Sahifa va Sarlavha tinch turadi.'
        : _useConst
            ? '`const Sarlavha` qayta qurilmaydi: Flutter aynan **o\'sha obyekt** ekanini biladi va uni o\'tkazib yuboradi.'
            : 'Holat **yuqorida**: `setState` butun Sahifani qayta quradi — o\'zgarmagan Sarlavha ham qaytadan quriladi.';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 6, runSpacing: 6, children: [
        ChoiceChip(label: Text('Holat yuqorida'.uz), selected: !_stateLow, onSelected: (_) => _reset(() => _stateLow = false)),
        ChoiceChip(label: Text('Holat pastda'.uz), selected: _stateLow, onSelected: (_) => _reset(() => _stateLow = true)),
        FilterChip(label: const Text('const Sarlavha'), selected: _useConst, onSelected: (v) => _reset(() => _useConst = v)),
      ]),
      const SizedBox(height: 12),
      _BuildLog(
        counts: _counts,
        child: KeyedSubtree(
          key: ValueKey(_epoch),
          child: _stateLow ? _LowPage(useConst: _useConst) : _HighPage(useConst: _useConst),
        ),
      ),
      const SizedBox(height: 6),
      RichUz(caption, style: context.text.bodySmall),
      const SizedBox(height: 4),
      Text('Yonib o\'chgan tugunlar — shu bosishda qayta qurilganlar.'.uz, style: context.text.labelSmall),
    ]);
  }
}

class _HighPage extends StatefulWidget {
  const _HighPage({required this.useConst});
  final bool useConst;

  @override
  State<_HighPage> createState() => _HighPageState();
}

class _HighPageState extends State<_HighPage> {
  int _n = 0;

  @override
  Widget build(BuildContext context) => _Probe('page', 'Sahifa (State: n)', children: [
    if (widget.useConst) const _Probe('title', 'Sarlavha', hint: 'const') else _Probe('title', 'Sarlavha'),
    _Probe('text', 'Text("n = $_n")'),
    _Probe('button', 'Tugma', onTap: () => setState(() => _n++)),
  ]);
}

class _LowPage extends StatelessWidget {
  const _LowPage({required this.useConst});
  final bool useConst;

  @override
  Widget build(BuildContext context) => _Probe('page', 'Sahifa', children: [
    if (useConst) const _Probe('title', 'Sarlavha', hint: 'const') else _Probe('title', 'Sarlavha'),
    const _CounterArea(),
  ]);
}

class _CounterArea extends StatefulWidget {
  const _CounterArea();

  @override
  State<_CounterArea> createState() => _CounterAreaState();
}

class _CounterAreaState extends State<_CounterArea> {
  int _n = 0;

  @override
  Widget build(BuildContext context) => _Probe('area', 'Hisob bloki (State: n)', children: [
    _Probe('text', 'Text("n = $_n")'),
    _Probe('button', 'Tugma', onTap: () => setState(() => _n++)),
  ]);
}
