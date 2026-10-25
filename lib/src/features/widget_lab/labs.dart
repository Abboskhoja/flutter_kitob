import 'package:flutter/material.dart';

/// Laboratoriya boshqaruv elementi.
sealed class LabControl {
  const LabControl(this.key, this.label);
  final String key;
  final String label;
}

class SliderCtl extends LabControl {
  const SliderCtl(super.key, super.label, this.min, this.max, {this.divisions, this.unit = ''});
  final double min;
  final double max;
  final int? divisions;
  final String unit;
}

class ChoiceCtl extends LabControl {
  const ChoiceCtl(super.key, super.label, this.options);

  /// ko'rinadigan nom → kod ko'rinishi
  final List<String> options;
}

class ColorCtl extends LabControl {
  const ColorCtl(super.key, super.label);
}

class ToggleCtl extends LabControl {
  const ToggleCtl(super.key, super.label);
}

class TextCtl extends LabControl {
  const TextCtl(super.key, super.label);
}

typedef LabState = Map<String, Object>;

class LabDef {
  const LabDef({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.controls,
    required this.initial,
    required this.preview,
    required this.code,
    this.tips = const [],
  });

  final String id;
  final String title;
  final IconData icon;
  final String description;
  final List<LabControl> controls;
  final LabState initial;
  final Widget Function(BuildContext context, LabState s, void Function(String key, Object value) set) preview;
  final String Function(LabState s) code;
  final List<String> tips;
}

/// Kod va preview uchun ranglar (nom — Flutter'dagi `Colors.x`).
const labColors = <String, Color>{
  'blue': Colors.blue,
  'red': Colors.red,
  'green': Colors.green,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'teal': Colors.teal,
  'pink': Colors.pink,
  'amber': Colors.amber,
  'indigo': Colors.indigo,
  'grey': Colors.grey,
  'black': Colors.black,
  'white': Colors.white,
};

Color col(LabState s, String k) => labColors[s[k]] ?? Colors.blue;
double d(LabState s, String k) => (s[k] as num).toDouble();
String str(LabState s, String k) => s[k] as String;
bool b(LabState s, String k) => s[k] as bool;
String n(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

MainAxisAlignment mainAxisOf(String v) => MainAxisAlignment.values.byName(v);
CrossAxisAlignment crossAxisOf(String v) => CrossAxisAlignment.values.byName(v);

const _alignments = {
  'topLeft': Alignment.topLeft,
  'topCenter': Alignment.topCenter,
  'topRight': Alignment.topRight,
  'centerLeft': Alignment.centerLeft,
  'center': Alignment.center,
  'centerRight': Alignment.centerRight,
  'bottomLeft': Alignment.bottomLeft,
  'bottomCenter': Alignment.bottomCenter,
  'bottomRight': Alignment.bottomRight,
};

const _weights = {'w300': FontWeight.w300, 'normal': FontWeight.normal, 'w600': FontWeight.w600, 'bold': FontWeight.bold, 'w900': FontWeight.w900};

const _icons = {
  'home': Icons.home,
  'favorite': Icons.favorite,
  'star': Icons.star,
  'settings': Icons.settings,
  'person': Icons.person,
  'school': Icons.school,
  'code': Icons.code,
  'rocket_launch': Icons.rocket_launch,
};

Widget _box(String label, Color c, {double w = 56, double h = 56}) => Container(
  width: w,
  height: h,
  alignment: Alignment.center,
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
  child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
);

final widgetLabs = <LabDef>[
  LabDef(
    id: 'container',
    title: 'Container',
    icon: Icons.crop_square_rounded,
    description: '`Container` — eng ko\'p ishlatiladigan "quti" widget: o\'lcham, rang, chekka (padding), tashqi masofa (margin), burchak radiusi va soya beradi.',
    controls: const [
      SliderCtl('width', 'width (kenglik)', 40, 260, unit: 'px'),
      SliderCtl('height', 'height (balandlik)', 40, 220, unit: 'px'),
      ColorCtl('color', 'color (rang)'),
      SliderCtl('radius', 'borderRadius', 0, 60, divisions: 12),
      SliderCtl('padding', 'padding (ichki chekka)', 0, 40, divisions: 8),
      SliderCtl('margin', 'margin (tashqi masofa)', 0, 40, divisions: 8),
      ChoiceCtl('align', 'alignment (ichki joylashuv)', ['center', 'topLeft', 'topRight', 'bottomLeft', 'bottomRight']),
      ToggleCtl('shadow', 'boxShadow (soya)'),
    ],
    initial: {'width': 180.0, 'height': 120.0, 'color': 'blue', 'radius': 16.0, 'padding': 16.0, 'margin': 16.0, 'align': 'center', 'shadow': true},
    preview: (context, s, set) => Container(
      color: Colors.black.withValues(alpha: 0.04),
      child: Container(
        width: d(s, 'width'),
        height: d(s, 'height'),
        margin: EdgeInsets.all(d(s, 'margin')),
        padding: EdgeInsets.all(d(s, 'padding')),
        alignment: _alignments[str(s, 'align')],
        decoration: BoxDecoration(
          color: col(s, 'color'),
          borderRadius: BorderRadius.circular(d(s, 'radius')),
          boxShadow: b(s, 'shadow') ? [BoxShadow(color: col(s, 'color').withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))] : null,
        ),
        child: const Text('Salom', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    ),
    code: (s) => '''Container(
  width: ${n(d(s, 'width'))},
  height: ${n(d(s, 'height'))},
  margin: const EdgeInsets.all(${n(d(s, 'margin'))}),
  padding: const EdgeInsets.all(${n(d(s, 'padding'))}),
  alignment: Alignment.${str(s, 'align')},
  decoration: BoxDecoration(
    color: Colors.${str(s, 'color')},
    borderRadius: BorderRadius.circular(${n(d(s, 'radius'))}),${b(s, 'shadow') ? '\n' '''
    boxShadow: [
      BoxShadow(
        color: Colors.${str(s, 'color')}.withValues(alpha: 0.4),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],''' : ''}
  ),
  child: const Text('Salom'),
)''',
    tips: [
      '**padding** — ichkariga, **margin** — tashqariga masofa. Preview\'dagi kulrang fon margin ni ko\'rsatadi.',
      '`color` va `decoration` ni birga berib bo\'lmaydi — rangni `BoxDecoration` ichiga yozing.',
    ],
  ),
  LabDef(
    id: 'text',
    title: 'Text',
    icon: Icons.text_fields_rounded,
    description: '`Text` — ekranga matn chiqaradi. Ko\'rinishi `TextStyle` bilan sozlanadi.',
    controls: const [
      TextCtl('text', 'Matn'),
      SliderCtl('size', 'fontSize', 10, 48, divisions: 19),
      ChoiceCtl('weight', 'fontWeight', ['normal', 'w300', 'w600', 'bold', 'w900']),
      ColorCtl('color', 'color'),
      ChoiceCtl('align', 'textAlign', ['left', 'center', 'right']),
      ToggleCtl('italic', 'fontStyle: italic'),
      SliderCtl('spacing', 'letterSpacing', 0, 8, divisions: 8),
    ],
    initial: {'text': 'Salom, Flutter!', 'size': 28.0, 'weight': 'bold', 'color': 'indigo', 'align': 'center', 'italic': false, 'spacing': 0.0},
    preview: (context, s, set) => SizedBox(
      width: 280,
      child: Text(
        str(s, 'text'),
        textAlign: TextAlign.values.byName(str(s, 'align')),
        style: TextStyle(
          fontSize: d(s, 'size'),
          fontWeight: _weights[str(s, 'weight')],
          color: col(s, 'color'),
          fontStyle: b(s, 'italic') ? FontStyle.italic : FontStyle.normal,
          letterSpacing: d(s, 'spacing'),
        ),
      ),
    ),
    code: (s) => '''Text(
  '${str(s, 'text').replaceAll("'", r"\'")}',
  textAlign: TextAlign.${str(s, 'align')},
  style: TextStyle(
    fontSize: ${n(d(s, 'size'))},
    fontWeight: FontWeight.${str(s, 'weight')},
    color: Colors.${str(s, 'color')},${b(s, 'italic') ? '\n    fontStyle: FontStyle.italic,' : ''}${d(s, 'spacing') > 0 ? '\n    letterSpacing: ${n(d(s, 'spacing'))},' : ''}
  ),
)''',
    tips: ['Ilovada bir xil uslubni takrorlamaslik uchun `Theme.of(context).textTheme` dan foydalaning.'],
  ),
  LabDef(
    id: 'row_column',
    title: 'Row va Column',
    icon: Icons.view_column_rounded,
    description: '`Row` — elementlarni gorizontal, `Column` — vertikal joylashtiradi. **mainAxis** — asosiy yo\'nalish, **crossAxis** — unga perpendikulyar yo\'nalish.',
    controls: const [
      ChoiceCtl('type', 'Widget', ['Row', 'Column']),
      ChoiceCtl('main', 'mainAxisAlignment', ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
      ChoiceCtl('cross', 'crossAxisAlignment', ['start', 'center', 'end', 'stretch']),
      SliderCtl('count', 'Bolalar soni', 1, 5, divisions: 4),
      SliderCtl('gap', 'spacing', 0, 24, divisions: 6),
    ],
    initial: {'type': 'Row', 'main': 'spaceEvenly', 'cross': 'center', 'count': 3.0, 'gap': 0.0},
    preview: (context, s, set) {
      final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red];
      final kids = [for (var i = 0; i < d(s, 'count').round(); i++) _box('${i + 1}', colors[i], w: 48 + i * 6.0, h: 48 + (i % 2) * 18.0)];
      final isRow = str(s, 'type') == 'Row';
      return Container(
        width: 300,
        height: 260,
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.4), width: 2), borderRadius: BorderRadius.circular(8)),
        child: isRow
            ? Row(mainAxisAlignment: mainAxisOf(str(s, 'main')), crossAxisAlignment: crossAxisOf(str(s, 'cross')), spacing: d(s, 'gap'), children: kids)
            : Column(mainAxisAlignment: mainAxisOf(str(s, 'main')), crossAxisAlignment: crossAxisOf(str(s, 'cross')), spacing: d(s, 'gap'), children: kids),
      );
    },
    code: (s) => '''${str(s, 'type')}(
  mainAxisAlignment: MainAxisAlignment.${str(s, 'main')},
  crossAxisAlignment: CrossAxisAlignment.${str(s, 'cross')},${d(s, 'gap') > 0 ? '\n  spacing: ${n(d(s, 'gap'))},' : ''}
  children: [
${[for (var i = 0; i < d(s, 'count').round(); i++) '    Box(${i + 1}),'].join('\n')}
  ],
)''',
    tips: [
      '`Row` uchun mainAxis — gorizontal, `Column` uchun — vertikal. Tugmani bosib almashtirib ko\'ring!',
      '`stretch` — bolalarni crossAxis bo\'ylab cho\'zadi.',
    ],
  ),
  LabDef(
    id: 'stack',
    title: 'Stack va Positioned',
    icon: Icons.layers_rounded,
    description: '`Stack` — widgetlarni bir-birining **ustiga** qo\'yadi (qatlamlar). `Positioned` bilan aniq joy beriladi.',
    controls: const [
      SliderCtl('top', 'Positioned top', 0, 140),
      SliderCtl('left', 'Positioned left', 0, 180),
      ChoiceCtl('align', 'Stack alignment', ['topLeft', 'center', 'bottomRight']),
      ToggleCtl('badge', 'Badge qatlami'),
    ],
    initial: {'top': 30.0, 'left': 40.0, 'align': 'center', 'badge': true},
    preview: (context, s, set) => SizedBox(
      width: 280,
      height: 220,
      child: Stack(alignment: _alignments[str(s, 'align')]!, children: [
        Container(width: 280, height: 220, decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(16))),
        _box('A', Colors.indigo, w: 120, h: 90),
        Positioned(top: d(s, 'top'), left: d(s, 'left'), child: _box('B', Colors.orange)),
        if (b(s, 'badge')) Positioned(top: 8, right: 8, child: CircleAvatar(radius: 14, backgroundColor: Colors.red, child: const Text('3', style: TextStyle(color: Colors.white)))),
      ]),
    ),
    code: (s) => '''Stack(
  alignment: Alignment.${str(s, 'align')},
  children: [
    Container(width: 280, height: 220, color: Colors.indigo.shade100),
    Box('A'),
    Positioned(
      top: ${n(d(s, 'top'))},
      left: ${n(d(s, 'left'))},
      child: Box('B'),
    ),${b(s, 'badge') ? '\n' '''
    const Positioned(
      top: 8,
      right: 8,
      child: CircleAvatar(radius: 14, child: Text('3')),
    ),''' : ''}
  ],
)''',
    tips: ['Ro\'yxatdagi oxirgi bola eng **ustki** qatlam bo\'ladi.'],
  ),
  LabDef(
    id: 'padding_align',
    title: 'Padding, Center, Align',
    icon: Icons.format_align_center_rounded,
    description: '`Padding` — atrofga bo\'sh joy qo\'shadi. `Center` — markazga, `Align` — istalgan joyga joylaydi.',
    controls: const [
      SliderCtl('h', 'horizontal padding', 0, 60, divisions: 12),
      SliderCtl('v', 'vertical padding', 0, 60, divisions: 12),
      ChoiceCtl('align', 'Align.alignment', ['topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight']),
    ],
    initial: {'h': 20.0, 'v': 12.0, 'align': 'center'},
    preview: (context, s, set) => Container(
      width: 280,
      height: 220,
      color: Colors.teal.shade50,
      child: Align(
        alignment: _alignments[str(s, 'align')]!,
        child: Container(
          color: Colors.teal.shade200,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: d(s, 'h'), vertical: d(s, 'v')),
            child: const Text('Flutter', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ),
        ),
      ),
    ),
    code: (s) => '''Align(
  alignment: Alignment.${str(s, 'align')},
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: ${n(d(s, 'h'))},
      vertical: ${n(d(s, 'v'))},
    ),
    child: const Text('Flutter'),
  ),
)''',
    tips: ['`Center(child: x)` — bu `Align(alignment: Alignment.center, child: x)` ning qisqa shakli.'],
  ),
  LabDef(
    id: 'expanded',
    title: 'Expanded va Flexible',
    icon: Icons.width_full_rounded,
    description: '`Expanded` — Row/Column dagi bo\'sh joyni **flex** nisbatida bo\'lib oladi. Responsive dizaynning asosi.',
    controls: const [
      SliderCtl('f1', 'Birinchi flex', 1, 5, divisions: 4),
      SliderCtl('f2', 'Ikkinchi flex', 1, 5, divisions: 4),
      ToggleCtl('fixed', 'Uchinchisi — qat\'iy 60px'),
    ],
    initial: {'f1': 1.0, 'f2': 2.0, 'fixed': true},
    preview: (context, s, set) => SizedBox(
      width: 300,
      height: 90,
      child: Row(children: [
        Expanded(flex: d(s, 'f1').round(), child: _box('flex ${d(s, 'f1').round()}', Colors.blue, h: 70)),
        const SizedBox(width: 6),
        Expanded(flex: d(s, 'f2').round(), child: _box('flex ${d(s, 'f2').round()}', Colors.orange, h: 70)),
        if (b(s, 'fixed')) ...[const SizedBox(width: 6), _box('60', Colors.green, w: 60, h: 70)],
      ]),
    ),
    code: (s) => '''Row(
  children: [
    Expanded(flex: ${d(s, 'f1').round()}, child: Box()),
    Expanded(flex: ${d(s, 'f2').round()}, child: Box()),${b(s, 'fixed') ? '\n    SizedBox(width: 60, child: Box()),' : ''}
  ],
)''',
    tips: ['Flex 1 va 2 — joy 1:2 nisbatda bo\'linadi. Qat\'iy o\'lchamli widget avval o\'z joyini oladi.'],
  ),
  LabDef(
    id: 'buttons',
    title: 'Tugmalar (Buttons)',
    icon: Icons.smart_button_rounded,
    description: 'Material 3 tugmalari: `FilledButton`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`. Tugma bosilganda `onPressed` funksiyasi chaqiriladi.',
    controls: const [
      ChoiceCtl('type', 'Tugma turi', ['FilledButton', 'ElevatedButton', 'OutlinedButton', 'TextButton']),
      TextCtl('text', 'Matn'),
      ToggleCtl('icon', 'Ikonka bilan (.icon)'),
      ToggleCtl('enabled', 'Faol (onPressed != null)'),
    ],
    initial: {'type': 'FilledButton', 'text': 'Bosing', 'icon': true, 'enabled': true, 'count': 0.0},
    preview: (context, s, set) {
      final onTap = b(s, 'enabled') ? () => set('count', d(s, 'count') + 1) : null;
      final label = Text(str(s, 'text'));
      const icon = Icon(Icons.touch_app);
      final w = switch (str(s, 'type')) {
        'ElevatedButton' => b(s, 'icon') ? ElevatedButton.icon(onPressed: onTap, icon: icon, label: label) : ElevatedButton(onPressed: onTap, child: label),
        'OutlinedButton' => b(s, 'icon') ? OutlinedButton.icon(onPressed: onTap, icon: icon, label: label) : OutlinedButton(onPressed: onTap, child: label),
        'TextButton' => b(s, 'icon') ? TextButton.icon(onPressed: onTap, icon: icon, label: label) : TextButton(onPressed: onTap, child: label),
        _ => b(s, 'icon') ? FilledButton.icon(onPressed: onTap, icon: icon, label: label) : FilledButton(onPressed: onTap, child: label),
      };
      return Column(mainAxisSize: MainAxisSize.min, children: [
        w,
        const SizedBox(height: 16),
        Text('Bosildi: ${d(s, 'count').round()} marta', style: const TextStyle(fontSize: 16)),
      ]);
    },
    code: (s) => '''${str(s, 'type')}${b(s, 'icon') ? '.icon' : ''}(
  onPressed: ${b(s, 'enabled') ? '() {\n    setState(() => bosildi++);\n  }' : 'null, // o\'chirilgan holat'},${b(s, 'icon') ? '\n  icon: const Icon(Icons.touch_app),\n  label: const Text(\'${str(s, 'text')}\'),' : '\n  child: const Text(\'${str(s, 'text')}\'),'}
)''',
    tips: ['`onPressed: null` — tugma avtomatik "o\'chirilgan" ko\'rinishga o\'tadi.', 'Tugmani preview\'da bosing — hisoblagich haqiqatan oshadi (setState).'],
  ),
  LabDef(
    id: 'listview',
    title: 'ListView',
    icon: Icons.view_list_rounded,
    description: '`ListView` — aylantiriladigan ro\'yxat. Ko\'p elementlar uchun `ListView.builder` faqat ko\'rinib turganlarini quradi — tez ishlaydi.',
    controls: const [
      SliderCtl('count', 'itemCount', 1, 50, divisions: 49),
      ToggleCtl('divider', 'separated (ajratgich)'),
      ChoiceCtl('dir', 'scrollDirection', ['vertical', 'horizontal']),
    ],
    initial: {'count': 12.0, 'divider': true, 'dir': 'vertical'},
    preview: (context, s, set) {
      final count = d(s, 'count').round();
      final horizontal = str(s, 'dir') == 'horizontal';
      Widget item(BuildContext c, int i) => horizontal
          ? Container(width: 90, margin: const EdgeInsets.all(6), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.primaries[i % 18].shade200, borderRadius: BorderRadius.circular(12)), child: Text('#${i + 1}'))
          : ListTile(leading: CircleAvatar(child: Text('${i + 1}')), title: Text('Element ${i + 1}'), subtitle: const Text('ListTile'));
      return SizedBox(
        width: 300,
        height: horizontal ? 120 : 280,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: b(s, 'divider')
              ? ListView.separated(scrollDirection: horizontal ? Axis.horizontal : Axis.vertical, itemCount: count, itemBuilder: item, separatorBuilder: (_, _) => horizontal ? const SizedBox(width: 2) : const Divider(height: 1))
              : ListView.builder(scrollDirection: horizontal ? Axis.horizontal : Axis.vertical, itemCount: count, itemBuilder: item),
        ),
      );
    },
    code: (s) => '''ListView.${b(s, 'divider') ? 'separated' : 'builder'}(
  scrollDirection: Axis.${str(s, 'dir')},
  itemCount: ${d(s, 'count').round()},
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('\${index + 1}')),
      title: Text('Element \${index + 1}'),
    );
  },${b(s, 'divider') ? '\n  separatorBuilder: (context, index) => const Divider(),' : ''}
)''',
    tips: ['Preview ichidagi ro\'yxatni barmoq bilan aylantirib ko\'ring.'],
  ),
  LabDef(
    id: 'card',
    title: 'Card va ListTile',
    icon: Icons.credit_card_rounded,
    description: '`Card` — soyali, burchaklari yumaloq yuza. `ListTile` — ikonka, sarlavha, izoh va o\'ng tomondagi element bilan tayyor qator.',
    controls: const [
      TextCtl('title', 'title'),
      TextCtl('subtitle', 'subtitle'),
      ChoiceCtl('icon', 'leading Icon', ['school', 'person', 'favorite', 'code', 'rocket_launch']),
      SliderCtl('elevation', 'elevation', 0, 12, divisions: 12),
      ToggleCtl('trailing', 'trailing (o\'ng tomonda)'),
    ],
    initial: {'title': 'Flutter darsi', 'subtitle': '12 daqiqa · Boshlang\'ich', 'icon': 'school', 'elevation': 2.0, 'trailing': true},
    preview: (context, s, set) => SizedBox(
      width: 320,
      child: Card(
        elevation: d(s, 'elevation'),
        child: ListTile(
          leading: Icon(_icons[str(s, 'icon')], color: Colors.blue, size: 32),
          title: Text(str(s, 'title')),
          subtitle: Text(str(s, 'subtitle')),
          trailing: b(s, 'trailing') ? const Icon(Icons.chevron_right) : null,
          onTap: () {},
        ),
      ),
    ),
    code: (s) => '''Card(
  elevation: ${n(d(s, 'elevation'))},
  child: ListTile(
    leading: const Icon(Icons.${str(s, 'icon')}),
    title: const Text('${str(s, 'title').replaceAll("'", r"\'")}'),
    subtitle: const Text('${str(s, 'subtitle').replaceAll("'", r"\'")}'),${b(s, 'trailing') ? '\n    trailing: const Icon(Icons.chevron_right),' : ''}
    onTap: () {},
  ),
)''',
  ),
  LabDef(
    id: 'textfield',
    title: 'TextField',
    icon: Icons.input_rounded,
    description: '`TextField` — foydalanuvchi matn kiritadigan maydon. `InputDecoration` bilan label, ikonka va xato matni beriladi.',
    controls: const [
      TextCtl('label', 'labelText'),
      ToggleCtl('obscure', 'obscureText (parol)'),
      ChoiceCtl('border', 'border', ['OutlineInputBorder', 'UnderlineInputBorder']),
      ToggleCtl('error', 'errorText ko\'rsatish'),
    ],
    initial: {'label': 'Email', 'obscure': false, 'border': 'OutlineInputBorder', 'error': false},
    preview: (context, s, set) => SizedBox(
      width: 300,
      child: TextField(
        obscureText: b(s, 'obscure'),
        decoration: InputDecoration(
          labelText: str(s, 'label'),
          prefixIcon: Icon(b(s, 'obscure') ? Icons.lock : Icons.email),
          filled: false,
          border: str(s, 'border') == 'OutlineInputBorder' ? const OutlineInputBorder() : const UnderlineInputBorder(),
          enabledBorder: str(s, 'border') == 'OutlineInputBorder' ? const OutlineInputBorder() : const UnderlineInputBorder(),
          errorText: b(s, 'error') ? 'Bu maydon to\'ldirilishi shart' : null,
        ),
      ),
    ),
    code: (s) => '''TextField(${b(s, 'obscure') ? '\n  obscureText: true,' : ''}
  decoration: InputDecoration(
    labelText: '${str(s, 'label')}',
    prefixIcon: const Icon(Icons.${b(s, 'obscure') ? 'lock' : 'email'}),
    border: const ${str(s, 'border')}(),${b(s, 'error') ? "\n    errorText: 'Bu maydon to\\'ldirilishi shart'," : ''}
  ),
)''',
    tips: ['Preview\'dagi maydonga haqiqatan yozib ko\'ring.'],
  ),
  LabDef(
    id: 'icon',
    title: 'Icon va CircleAvatar',
    icon: Icons.emoji_emotions_rounded,
    description: '`Icon` — Material ikonkalari (`Icons.x`). `CircleAvatar` — dumaloq profil rasmi yoki bosh harf.',
    controls: const [
      ChoiceCtl('icon', 'Icons.', ['home', 'favorite', 'star', 'settings', 'person', 'school', 'code', 'rocket_launch']),
      SliderCtl('size', 'size', 16, 96, divisions: 10),
      ColorCtl('color', 'color'),
      SliderCtl('radius', 'CircleAvatar radius', 16, 60, divisions: 11),
    ],
    initial: {'icon': 'favorite', 'size': 48.0, 'color': 'red', 'radius': 36.0},
    preview: (context, s, set) => Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(_icons[str(s, 'icon')], size: d(s, 'size'), color: col(s, 'color')),
      const SizedBox(width: 28),
      CircleAvatar(radius: d(s, 'radius'), backgroundColor: col(s, 'color'), child: Text('AK', style: TextStyle(color: Colors.white, fontSize: d(s, 'radius') * 0.6))),
    ]),
    code: (s) => '''Row(
  children: [
    Icon(Icons.${str(s, 'icon')}, size: ${n(d(s, 'size'))}, color: Colors.${str(s, 'color')}),
    const SizedBox(width: 28),
    CircleAvatar(
      radius: ${n(d(s, 'radius'))},
      backgroundColor: Colors.${str(s, 'color')},
      child: const Text('AK'),
    ),
  ],
)''',
  ),
  LabDef(
    id: 'animated',
    title: 'AnimatedContainer',
    icon: Icons.animation_rounded,
    description: '`AnimatedContainer` — xususiyatlari o\'zgarganda **o\'zi silliq animatsiya** qiladi. Faqat yangi qiymat va `duration` bering.',
    controls: const [
      ToggleCtl('big', 'Holat: katta'),
      SliderCtl('ms', 'duration (ms)', 100, 1500, divisions: 14),
      ChoiceCtl('curve', 'curve', ['easeInOut', 'easeOutBack', 'bounceOut', 'linear', 'elasticOut']),
    ],
    initial: {'big': false, 'ms': 600.0, 'curve': 'easeOutBack'},
    preview: (context, s, set) {
      final curve = switch (str(s, 'curve')) {
        'easeOutBack' => Curves.easeOutBack,
        'bounceOut' => Curves.bounceOut,
        'linear' => Curves.linear,
        'elasticOut' => Curves.elasticOut,
        _ => Curves.easeInOut,
      };
      final big = b(s, 'big');
      return GestureDetector(
        onTap: () => set('big', !big),
        child: AnimatedContainer(
          duration: Duration(milliseconds: d(s, 'ms').round()),
          curve: curve,
          width: big ? 220 : 100,
          height: big ? 160 : 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: big ? Colors.purple : Colors.teal, borderRadius: BorderRadius.circular(big ? 40 : 12)),
          child: const Text('Meni bosing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
    },
    code: (s) => '''AnimatedContainer(
  duration: const Duration(milliseconds: ${d(s, 'ms').round()}),
  curve: Curves.${str(s, 'curve')},
  width: katta ? 220 : 100,
  height: katta ? 160 : 100,
  decoration: BoxDecoration(
    color: katta ? Colors.purple : Colors.teal,
    borderRadius: BorderRadius.circular(katta ? 40 : 12),
  ),
)
// Bosilganda: setState(() => katta = !katta);''',
    tips: ['Preview\'dagi qutini bosing — `setState` holatni o\'zgartiradi va animatsiya o\'zi ishlaydi.'],
  ),
];

LabDef? labById(String? id) => widgetLabs.where((l) => l.id == id).firstOrNull;
