import 'package:flutter/material.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import 'icon_map.dart';

/// Renderer xatosi: o'quvchiga tushunarli xabar.
class RenderProblem implements Exception {
  RenderProblem(this.message, {this.hint});
  final String message;
  final String? hint;
}

/// Har bir widget qabul qiladigan nomli parametrlar.
const _allowed = <String, Set<String>>{
  'MaterialApp': {'home', 'title', 'theme', 'darkTheme', 'themeMode', 'debugShowCheckedModeBanner', 'color'},
  'Scaffold': {'appBar', 'body', 'floatingActionButton', 'backgroundColor', 'bottomNavigationBar', 'drawer', 'floatingActionButtonLocation'},
  'AppBar': {'title', 'backgroundColor', 'foregroundColor', 'actions', 'centerTitle', 'leading', 'elevation'},
  'Text': {'style', 'textAlign', 'maxLines', 'overflow', 'softWrap', 'key'},
  'Icon': {'size', 'color', 'semanticLabel', 'key'},
  'Container': {'width', 'height', 'color', 'padding', 'margin', 'alignment', 'decoration', 'child', 'constraints', 'key'},
  'AnimatedContainer': {'width', 'height', 'color', 'padding', 'margin', 'alignment', 'decoration', 'child', 'duration', 'curve', 'key'},
  'SizedBox': {'width', 'height', 'child', 'key'},
  'Padding': {'padding', 'child', 'key'},
  'Center': {'child', 'widthFactor', 'heightFactor', 'key'},
  'Align': {'alignment', 'child', 'key'},
  'Row': {'mainAxisAlignment', 'crossAxisAlignment', 'mainAxisSize', 'spacing', 'children', 'key'},
  'Column': {'mainAxisAlignment', 'crossAxisAlignment', 'mainAxisSize', 'spacing', 'children', 'key'},
  'Stack': {'alignment', 'fit', 'children', 'clipBehavior', 'key'},
  'Positioned': {'top', 'left', 'right', 'bottom', 'width', 'height', 'child', 'key'},
  'Expanded': {'flex', 'child', 'key'},
  'Flexible': {'flex', 'child', 'key'},
  'Spacer': {'flex', 'key'},
  'ListView': {'children', 'padding', 'scrollDirection', 'shrinkWrap', 'key'},
  'ListView.builder': {'itemCount', 'itemBuilder', 'padding', 'scrollDirection', 'shrinkWrap', 'key'},
  'ListView.separated': {'itemCount', 'itemBuilder', 'separatorBuilder', 'padding', 'scrollDirection', 'key'},
  'GridView.count': {'crossAxisCount', 'children', 'mainAxisSpacing', 'crossAxisSpacing', 'padding', 'childAspectRatio', 'shrinkWrap', 'key'},
  'SingleChildScrollView': {'child', 'padding', 'scrollDirection', 'key'},
  'SafeArea': {'child', 'key'},
  'Card': {'child', 'elevation', 'color', 'margin', 'key'},
  'ListTile': {'leading', 'title', 'subtitle', 'trailing', 'onTap', 'tileColor', 'key'},
  'ElevatedButton': {'onPressed', 'child', 'style', 'key'},
  'FilledButton': {'onPressed', 'child', 'style', 'key'},
  'TextButton': {'onPressed', 'child', 'style', 'key'},
  'OutlinedButton': {'onPressed', 'child', 'style', 'key'},
  'ElevatedButton.icon': {'onPressed', 'icon', 'label', 'key'},
  'FilledButton.icon': {'onPressed', 'icon', 'label', 'key'},
  'TextButton.icon': {'onPressed', 'icon', 'label', 'key'},
  'OutlinedButton.icon': {'onPressed', 'icon', 'label', 'key'},
  'IconButton': {'icon', 'onPressed', 'color', 'iconSize', 'tooltip', 'key'},
  'FloatingActionButton': {'onPressed', 'child', 'tooltip', 'backgroundColor', 'foregroundColor', 'key'},
  'FloatingActionButton.extended': {'onPressed', 'label', 'icon', 'key'},
  'Divider': {'height', 'thickness', 'color', 'key'},
  'CircleAvatar': {'radius', 'backgroundColor', 'foregroundColor', 'child', 'key'},
  'Image.network': {'width', 'height', 'fit', 'key'},
  'Switch': {'value', 'onChanged', 'key'},
  'Checkbox': {'value', 'onChanged', 'key'},
  'SwitchListTile': {'value', 'onChanged', 'title', 'subtitle', 'key'},
  'CheckboxListTile': {'value', 'onChanged', 'title', 'subtitle', 'key'},
  'TextField': {'controller', 'decoration', 'onChanged', 'onSubmitted', 'obscureText', 'keyboardType', 'maxLines', 'key'},
  'Wrap': {'spacing', 'runSpacing', 'children', 'alignment', 'key'},
  'Opacity': {'opacity', 'child', 'key'},
  'AnimatedOpacity': {'opacity', 'duration', 'curve', 'child', 'key'},
  'ClipRRect': {'borderRadius', 'child', 'key'},
  'GestureDetector': {'onTap', 'onDoubleTap', 'onLongPress', 'child', 'key'},
  'InkWell': {'onTap', 'onLongPress', 'child', 'borderRadius', 'key'},
  'Chip': {'label', 'avatar', 'backgroundColor', 'key'},
  'Placeholder': {'key', 'fallbackHeight', 'fallbackWidth', 'color'},
  'CircularProgressIndicator': {'value', 'color', 'key'},
  'LinearProgressIndicator': {'value', 'color', 'key'},
  'Builder': {'builder', 'key'},
  'Tooltip': {'message', 'child', 'key'},
  'Badge': {'label', 'child', 'key'},
  'AspectRatio': {'aspectRatio', 'child', 'key'},
  'FittedBox': {'fit', 'child', 'key'},
  'ConstrainedBox': {'constraints', 'child', 'key'},
  'DecoratedBox': {'decoration', 'child', 'key'},
  'Material': {'color', 'elevation', 'child', 'key'},
  'NavigationBar': {'selectedIndex', 'onDestinationSelected', 'destinations', 'key'},
  'NavigationDestination': {'icon', 'label', 'selectedIcon', 'key'},
  'BottomNavigationBar': {'items', 'currentIndex', 'onTap', 'key'},
  'BottomNavigationBarItem': {'icon', 'label'},
};

/// Preview'ni boshqaruvchi kontekst.
class PreviewScope {
  PreviewScope(this.rt, this.onState, {this.afterCallback});

  /// Har bir callback'dan keyin (masalan konsolni yangilash uchun).
  final VoidCallback? afterCallback;
  final FlutterRuntime rt;
  /// O'quvchi State obyekti → uni qayta chizuvchi funksiya.
  final Map<KInstance, VoidCallback> refreshers = {};
  final Map<KInstance, TextEditingController> controllers = {};

  /// Callback xatosi yoki boshqa ish vaqti muammosi.
  final void Function(Object error) onState;

  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
  }
}

class KitobRenderer {
  KitobRenderer(this.scope);
  final PreviewScope scope;
  FlutterRuntime get rt => scope.rt;

  Widget render(Object? v) {
    try {
      return _render(v);
    } on RenderProblem catch (p) {
      return PreviewErrorBox(title: p.message, hint: p.hint);
    } on FlutterRunError catch (e) {
      return PreviewErrorBox(title: e.info.explanation, hint: e.info.message);
    }
  }

  Widget _render(Object? v) {
    if (v == null) throw RenderProblem('Widget o\'rniga `null` berildi.', hint: 'build() har doim widget qaytarishi kerak.');
    if (rt.isStateless(v)) return _KStateless(inst: v as KInstance, renderer: this);
    if (rt.isStateful(v)) return _KStateful(inst: v as KInstance, renderer: this);
    if (v is FNode) return _node(v);
    if (v is String) {
      throw RenderProblem('Widget kutilgan joyga matn (String) berildi: "$v"', hint: "Matnni `Text('$v')` ichiga o'rang.");
    }
    throw RenderProblem('`${rt.className(v)}` — bu widget emas.', hint: 'Bu joyga Text, Container, Column kabi widget yozing.');
  }

  // ───── qiymatlarni aylantirish ─────

  double? num_(Object? v) => v is int ? v.toDouble() : (v is KDouble ? v.value : null);
  Color? color(Object? v) => v is FColor ? Color(v.argb) : null;
  String? str(Object? v) => v is String ? v : (v == null ? null : rt.display(v));

  EdgeInsets? insets(Object? v) {
    if (v is! FNode) return null;
    double n(Object? x) => num_(x) ?? 0;
    return switch (v.type) {
      'EdgeInsets.all' => EdgeInsets.all(n(v.pos.firstOrNull)),
      'EdgeInsets.symmetric' => EdgeInsets.symmetric(horizontal: n(v.named['horizontal']), vertical: n(v.named['vertical'])),
      'EdgeInsets.only' => EdgeInsets.only(left: n(v.named['left']), top: n(v.named['top']), right: n(v.named['right']), bottom: n(v.named['bottom'])),
      'EdgeInsets.fromLTRB' => EdgeInsets.fromLTRB(n(v.pos[0]), n(v.pos[1]), n(v.pos[2]), n(v.pos[3])),
      _ => throw RenderProblem('`${v.type}` — EdgeInsets emas.', hint: 'Masalan: EdgeInsets.all(16)'),
    };
  }

  Radius _radius(Object? v) {
    if (v is FNode && v.type == 'Radius.circular') return Radius.circular(num_(v.pos.firstOrNull) ?? 0);
    return Radius.zero;
  }

  BorderRadius? radius(Object? v) {
    if (v is! FNode) return null;
    return switch (v.type) {
      'BorderRadius.circular' => BorderRadius.circular(num_(v.pos.firstOrNull) ?? 0),
      'BorderRadius.all' => BorderRadius.all(_radius(v.pos.firstOrNull)),
      'BorderRadius.only' => BorderRadius.only(
        topLeft: _radius(v.named['topLeft']),
        topRight: _radius(v.named['topRight']),
        bottomLeft: _radius(v.named['bottomLeft']),
        bottomRight: _radius(v.named['bottomRight']),
      ),
      _ => null,
    };
  }

  Alignment? align(Object? v) {
    if (v is FEnum && v.type == 'Alignment') {
      return const {
        'topLeft': Alignment.topLeft, 'topCenter': Alignment.topCenter, 'topRight': Alignment.topRight,
        'centerLeft': Alignment.centerLeft, 'center': Alignment.center, 'centerRight': Alignment.centerRight,
        'bottomLeft': Alignment.bottomLeft, 'bottomCenter': Alignment.bottomCenter, 'bottomRight': Alignment.bottomRight,
      }[v.name];
    }
    if (v is FNode && v.type == 'Alignment') return Alignment(num_(v.pos[0]) ?? 0, num_(v.pos[1]) ?? 0);
    return null;
  }

  FontWeight? weight(Object? v) {
    if (v is! FEnum) return null;
    return const {
      'w100': FontWeight.w100, 'w200': FontWeight.w200, 'w300': FontWeight.w300, 'w400': FontWeight.w400,
      'w500': FontWeight.w500, 'w600': FontWeight.w600, 'w700': FontWeight.w700, 'w800': FontWeight.w800,
      'w900': FontWeight.w900, 'bold': FontWeight.bold, 'normal': FontWeight.normal,
    }[v.name];
  }

  TextStyle? textStyle(Object? v) {
    if (v is! FNode || v.type != 'TextStyle') return null;
    final n = v.named;
    return TextStyle(
      fontSize: num_(n['fontSize']),
      fontWeight: weight(n['fontWeight']),
      color: color(n['color']),
      fontStyle: n['fontStyle'] is FEnum && (n['fontStyle'] as FEnum).name == 'italic' ? FontStyle.italic : null,
      letterSpacing: num_(n['letterSpacing']),
      height: num_(n['height']),
      backgroundColor: color(n['backgroundColor']),
      fontFamily: n['fontFamily'] == 'monospace' ? kCodeFont : null,
    );
  }

  Curve curve(Object? v) => v is FEnum
      ? (const {
          'linear': Curves.linear, 'easeIn': Curves.easeIn, 'easeOut': Curves.easeOut, 'easeInOut': Curves.easeInOut,
          'bounceOut': Curves.bounceOut, 'elasticOut': Curves.elasticOut, 'easeOutBack': Curves.easeOutBack,
          'fastOutSlowIn': Curves.fastOutSlowIn,
        }[v.name] ?? Curves.linear)
      : Curves.linear;

  Duration duration(Object? v) {
    if (v is KInstance && v.klass.name == 'Duration') return Duration(microseconds: (v.fields['inMicroseconds'] as int?) ?? 0);
    return const Duration(milliseconds: 300);
  }

  BoxDecoration? decoration(Object? v) {
    if (v is! FNode || v.type != 'BoxDecoration') return null;
    final n = v.named;
    final shadows = n['boxShadow'];
    final border = n['border'];
    final grad = n['gradient'];
    return BoxDecoration(
      color: color(n['color']),
      borderRadius: radius(n['borderRadius']),
      shape: n['shape'] is FEnum && (n['shape'] as FEnum).name == 'circle' ? BoxShape.circle : BoxShape.rectangle,
      border: border is FNode && border.type == 'Border.all'
          ? Border.all(color: color(border.named['color']) ?? Colors.black, width: num_(border.named['width']) ?? 1)
          : null,
      boxShadow: shadows is List
          ? [
              for (final s in shadows.whereType<FNode>())
                BoxShadow(
                  color: color(s.named['color']) ?? Colors.black26,
                  blurRadius: num_(s.named['blurRadius']) ?? 0,
                  spreadRadius: num_(s.named['spreadRadius']) ?? 0,
                  offset: s.named['offset'] is FNode
                      ? Offset(num_((s.named['offset'] as FNode).pos[0]) ?? 0, num_((s.named['offset'] as FNode).pos[1]) ?? 0)
                      : Offset.zero,
                ),
            ]
          : null,
      gradient: grad is FNode && grad.type == 'LinearGradient'
          ? LinearGradient(
              colors: [for (final c in (grad.named['colors'] as List? ?? const [])) color(c) ?? Colors.transparent],
              begin: align(grad.named['begin']) ?? Alignment.centerLeft,
              end: align(grad.named['end']) ?? Alignment.centerRight,
            )
          : null,
    );
  }

  IconData icon(Object? v) {
    if (v is FIcon) return kIconMap[v.name] ?? Icons.help_outline;
    throw RenderProblem('Ikonka kutilgan edi.', hint: 'Masalan: Icon(Icons.home)');
  }

  Widget? child(FNode n, String key) {
    final c = n.named[key];
    return c == null ? null : render(c);
  }

  List<Widget> children(FNode n, [String key = 'children']) {
    final c = n.named[key];
    if (c == null) return const [];
    if (c is! List) throw RenderProblem('`$key` ro\'yxat (List) bo\'lishi kerak.', hint: '$key: [ Text(\'a\'), Text(\'b\') ]');
    return [for (final w in c) render(w)];
  }

  VoidCallback? callback(Object? fn) => fn == null ? null : () => _safe(() => rt.call(fn));
  ValueChanged<T>? callback1<T>(Object? fn) => fn == null ? null : (T v) => _safe(() => rt.call(fn, [v]));

  void _safe(void Function() body) {
    try {
      body();
    } catch (e) {
      scope.onState(e);
    }
    scope.afterCallback?.call();
  }

  ThemeData _theme(Object? t, {Brightness brightness = Brightness.light}) {
    Color? seed;
    if (t is FNode && t.type == 'ThemeData') {
      seed = color(t.named['colorSchemeSeed']) ?? color(t.named['primarySwatch']) ?? color(t.named['primaryColor']);
      final cs = t.named['colorScheme'];
      if (cs is FNode && cs.type == 'ColorScheme.fromSeed') seed = color(cs.named['seedColor']);
      if (t.named['brightness'] is FEnum && (t.named['brightness'] as FEnum).name == 'dark') brightness = Brightness.dark;
    }
    return ThemeData(useMaterial3: true, colorSchemeSeed: seed ?? Colors.deepPurple, brightness: brightness, fontFamily: kFontFamily);
  }

  void _check(FNode n) {
    final allowed = _allowed[n.type];
    if (allowed == null) return;
    for (final k in n.named.keys) {
      if (!allowed.contains(k)) {
        final close = allowed.where((a) => a.toLowerCase() == k.toLowerCase() || _near(a, k)).firstOrNull;
        throw RenderProblem('`${n.type}` widgetida `$k` nomli parametr yo\'q.',
            hint: close != null ? '`$close` demoqchimisiz?' : 'Mavjud parametrlar: ${allowed.where((a) => a != 'key').join(', ')}');
      }
    }
  }

  bool _near(String a, String b) {
    if ((a.length - b.length).abs() > 2) return false;
    var diff = 0;
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) diff++;
    }
    return diff + (a.length - b.length).abs() <= 2;
  }

  Widget _node(FNode n) {
    _check(n);
    final a = n.named;
    switch (n.type) {
      case 'MaterialApp':
        return _PreviewApp(home: a['home'], renderer: this, title: str(a['title']) ?? '', theme: _theme(a['theme']),
            banner: a['debugShowCheckedModeBanner'] != false);
      case 'Scaffold':
        return Scaffold(
          appBar: a['appBar'] == null ? null : PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: render(a['appBar'])),
          body: child(n, 'body'),
          floatingActionButton: child(n, 'floatingActionButton'),
          bottomNavigationBar: child(n, 'bottomNavigationBar'),
          backgroundColor: color(a['backgroundColor']),
        );
      case 'AppBar':
        return AppBar(
          title: child(n, 'title'),
          backgroundColor: color(a['backgroundColor']),
          foregroundColor: color(a['foregroundColor']),
          centerTitle: a['centerTitle'] as bool?,
          leading: child(n, 'leading'),
          actions: a['actions'] == null ? null : children(n, 'actions'),
          elevation: num_(a['elevation']),
        );
      case 'Text':
        if (n.pos.isEmpty) throw RenderProblem("Text() ichiga matn yozing.", hint: "Text('Salom')");
        final data = n.pos.first;
        if (data is! String) {
          throw RenderProblem('Text faqat String (matn) qabul qiladi, lekin `${rt.className(data)}` berildi.',
              hint: "Sonni matnga aylantiring: Text('\$son') yoki Text(son.toString())");
        }
        return Text(
          data,
          style: textStyle(a['style']),
          textAlign: a['textAlign'] is FEnum ? TextAlign.values.byName((a['textAlign'] as FEnum).name) : null,
          maxLines: a['maxLines'] as int?,
          overflow: a['overflow'] is FEnum ? TextOverflow.values.byName((a['overflow'] as FEnum).name) : null,
        );
      case 'Icon':
        return Icon(icon(n.pos.firstOrNull), size: num_(a['size']), color: color(a['color']));
      case 'Container':
        return Container(
          width: num_(a['width']),
          height: num_(a['height']),
          color: a['decoration'] == null ? color(a['color']) : null,
          padding: insets(a['padding']),
          margin: insets(a['margin']),
          alignment: align(a['alignment']),
          decoration: _withColor(decoration(a['decoration']), a),
          child: child(n, 'child'),
        );
      case 'AnimatedContainer':
        return AnimatedContainer(
          duration: duration(a['duration']),
          curve: curve(a['curve']),
          width: num_(a['width']),
          height: num_(a['height']),
          color: a['decoration'] == null ? color(a['color']) : null,
          padding: insets(a['padding']),
          margin: insets(a['margin']),
          alignment: align(a['alignment']),
          decoration: decoration(a['decoration']),
          child: child(n, 'child'),
        );
      case 'SizedBox':
        return SizedBox(width: num_(a['width']), height: num_(a['height']), child: child(n, 'child'));
      case 'SizedBox.expand':
        return SizedBox.expand(child: child(n, 'child'));
      case 'Padding':
        return Padding(padding: insets(a['padding']) ?? EdgeInsets.zero, child: child(n, 'child'));
      case 'Center':
        return Center(child: child(n, 'child'));
      case 'Align':
        return Align(alignment: align(a['alignment']) ?? Alignment.center, child: child(n, 'child'));
      case 'Row' || 'Column':
        final main = a['mainAxisAlignment'] is FEnum ? MainAxisAlignment.values.byName((a['mainAxisAlignment'] as FEnum).name) : MainAxisAlignment.start;
        final cross = a['crossAxisAlignment'] is FEnum ? CrossAxisAlignment.values.byName((a['crossAxisAlignment'] as FEnum).name) : CrossAxisAlignment.center;
        final size = a['mainAxisSize'] is FEnum && (a['mainAxisSize'] as FEnum).name == 'min' ? MainAxisSize.min : MainAxisSize.max;
        final kids = children(n);
        final spacing = num_(a['spacing']) ?? 0;
        return n.type == 'Row'
            ? Row(mainAxisAlignment: main, crossAxisAlignment: cross, mainAxisSize: size, spacing: spacing, children: kids)
            : Column(mainAxisAlignment: main, crossAxisAlignment: cross, mainAxisSize: size, spacing: spacing, children: kids);
      case 'Stack':
        return Stack(
          alignment: align(a['alignment']) ?? AlignmentDirectional.topStart,
          fit: a['fit'] is FEnum && (a['fit'] as FEnum).name == 'expand' ? StackFit.expand : StackFit.loose,
          children: children(n),
        );
      case 'Positioned':
        return Positioned(
          top: num_(a['top']),
          left: num_(a['left']),
          right: num_(a['right']),
          bottom: num_(a['bottom']),
          width: num_(a['width']),
          height: num_(a['height']),
          child: child(n, 'child') ?? const SizedBox(),
        );
      case 'Positioned.fill':
        return Positioned.fill(child: child(n, 'child') ?? const SizedBox());
      case 'Expanded':
        return Expanded(flex: (a['flex'] as int?) ?? 1, child: child(n, 'child') ?? const SizedBox());
      case 'Flexible':
        return Flexible(flex: (a['flex'] as int?) ?? 1, child: child(n, 'child') ?? const SizedBox());
      case 'Spacer':
        return Spacer(flex: (a['flex'] as int?) ?? 1);
      case 'ListView':
        return ListView(
          padding: insets(a['padding']),
          shrinkWrap: a['shrinkWrap'] == true,
          scrollDirection: _axis(a['scrollDirection']),
          children: children(n),
        );
      case 'ListView.builder' || 'ListView.separated':
        final count = a['itemCount'];
        if (count is! int) throw RenderProblem('ListView.builder uchun `itemCount` (int) kerak.', hint: 'itemCount: royxat.length');
        Widget item(BuildContext c, int i) => render(rt.call(a['itemBuilder'], [rt.context, i]));
        if (n.type == 'ListView.separated') {
          return ListView.separated(
            padding: insets(a['padding']),
            scrollDirection: _axis(a['scrollDirection']),
            itemCount: count,
            itemBuilder: item,
            separatorBuilder: (c, i) => render(rt.call(a['separatorBuilder'], [rt.context, i])),
          );
        }
        return ListView.builder(
          padding: insets(a['padding']),
          shrinkWrap: a['shrinkWrap'] == true,
          scrollDirection: _axis(a['scrollDirection']),
          itemCount: count,
          itemBuilder: item,
        );
      case 'GridView.count':
        return GridView.count(
          crossAxisCount: (a['crossAxisCount'] as int?) ?? 2,
          mainAxisSpacing: num_(a['mainAxisSpacing']) ?? 0,
          crossAxisSpacing: num_(a['crossAxisSpacing']) ?? 0,
          padding: insets(a['padding']),
          childAspectRatio: num_(a['childAspectRatio']) ?? 1,
          shrinkWrap: a['shrinkWrap'] == true,
          children: children(n),
        );
      case 'SingleChildScrollView':
        return SingleChildScrollView(padding: insets(a['padding']), scrollDirection: _axis(a['scrollDirection']), child: child(n, 'child'));
      case 'SafeArea':
        return SafeArea(child: child(n, 'child') ?? const SizedBox());
      case 'Card':
        return Card(elevation: num_(a['elevation']), color: color(a['color']), margin: insets(a['margin']), child: child(n, 'child'));
      case 'ListTile':
        return ListTile(
          leading: child(n, 'leading'),
          title: child(n, 'title'),
          subtitle: child(n, 'subtitle'),
          trailing: child(n, 'trailing'),
          tileColor: color(a['tileColor']),
          onTap: callback(a['onTap']),
        );
      case 'ElevatedButton':
        return ElevatedButton(onPressed: callback(a['onPressed']), child: child(n, 'child'));
      case 'FilledButton':
        return FilledButton(onPressed: callback(a['onPressed']), child: child(n, 'child'));
      case 'TextButton':
        return TextButton(onPressed: callback(a['onPressed']), child: child(n, 'child') ?? const SizedBox());
      case 'OutlinedButton':
        return OutlinedButton(onPressed: callback(a['onPressed']), child: child(n, 'child'));
      case 'ElevatedButton.icon':
        return ElevatedButton.icon(onPressed: callback(a['onPressed']), icon: child(n, 'icon'), label: child(n, 'label') ?? const SizedBox());
      case 'FilledButton.icon':
        return FilledButton.icon(onPressed: callback(a['onPressed']), icon: child(n, 'icon'), label: child(n, 'label') ?? const SizedBox());
      case 'TextButton.icon':
        return TextButton.icon(onPressed: callback(a['onPressed']), icon: child(n, 'icon'), label: child(n, 'label') ?? const SizedBox());
      case 'OutlinedButton.icon':
        return OutlinedButton.icon(onPressed: callback(a['onPressed']), icon: child(n, 'icon'), label: child(n, 'label') ?? const SizedBox());
      case 'IconButton':
        return IconButton(onPressed: callback(a['onPressed']), icon: child(n, 'icon') ?? const SizedBox(), color: color(a['color']), iconSize: num_(a['iconSize']), tooltip: str(a['tooltip']));
      case 'FloatingActionButton':
        return FloatingActionButton(
          onPressed: callback(a['onPressed']),
          tooltip: str(a['tooltip']),
          backgroundColor: color(a['backgroundColor']),
          foregroundColor: color(a['foregroundColor']),
          child: child(n, 'child'),
        );
      case 'FloatingActionButton.extended':
        return FloatingActionButton.extended(onPressed: callback(a['onPressed']), label: child(n, 'label') ?? const SizedBox(), icon: child(n, 'icon'));
      case 'Divider':
        return Divider(height: num_(a['height']), thickness: num_(a['thickness']), color: color(a['color']));
      case 'CircleAvatar':
        return CircleAvatar(radius: num_(a['radius']), backgroundColor: color(a['backgroundColor']), foregroundColor: color(a['foregroundColor']), child: child(n, 'child'));
      case 'Image.network':
        final url = n.pos.firstOrNull;
        if (url is! String) throw RenderProblem('Image.network ga rasm manzili (String) kerak.');
        return Image.network(
          url,
          width: num_(a['width']),
          height: num_(a['height']),
          fit: a['fit'] is FEnum ? BoxFit.values.byName((a['fit'] as FEnum).name) : null,
          errorBuilder: (c, e, s) => Container(
            width: num_(a['width']) ?? 120,
            height: num_(a['height']) ?? 80,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Text('Rasm yuklanmadi\n(internet?)'.uz, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ),
        );
      case 'Image.asset':
        throw RenderProblem('Image.asset — loyiha fayllaridagi rasm; preview\'da mavjud emas.', hint: 'Image.network(...) yoki Icon(...) ishlating.');
      case 'Switch':
        return Switch(value: a['value'] == true, onChanged: callback1<bool>(a['onChanged']));
      case 'Checkbox':
        return Checkbox(value: a['value'] == true, onChanged: a['onChanged'] == null ? null : (v) => _safe(() => rt.call(a['onChanged'], [v])));
      case 'SwitchListTile':
        return SwitchListTile(value: a['value'] == true, onChanged: callback1<bool>(a['onChanged']), title: child(n, 'title'), subtitle: child(n, 'subtitle'));
      case 'CheckboxListTile':
        return CheckboxListTile(
          value: a['value'] == true,
          onChanged: a['onChanged'] == null ? null : (v) => _safe(() => rt.call(a['onChanged'], [v])),
          title: child(n, 'title'),
          subtitle: child(n, 'subtitle'),
        );
      case 'TextField':
        return _textField(n);
      case 'Wrap':
        return Wrap(spacing: num_(a['spacing']) ?? 0, runSpacing: num_(a['runSpacing']) ?? 0, children: children(n));
      case 'Opacity':
        return Opacity(opacity: (num_(a['opacity']) ?? 1).clamp(0, 1), child: child(n, 'child'));
      case 'AnimatedOpacity':
        return AnimatedOpacity(opacity: (num_(a['opacity']) ?? 1).clamp(0, 1), duration: duration(a['duration']), curve: curve(a['curve']), child: child(n, 'child'));
      case 'ClipRRect':
        return ClipRRect(borderRadius: radius(a['borderRadius']) ?? BorderRadius.zero, child: child(n, 'child'));
      case 'GestureDetector':
        return GestureDetector(onTap: callback(a['onTap']), onDoubleTap: callback(a['onDoubleTap']), onLongPress: callback(a['onLongPress']), child: child(n, 'child'));
      case 'InkWell':
        return InkWell(onTap: callback(a['onTap']), onLongPress: callback(a['onLongPress']), borderRadius: radius(a['borderRadius']), child: child(n, 'child'));
      case 'Chip':
        return Chip(label: child(n, 'label') ?? const SizedBox(), avatar: child(n, 'avatar'), backgroundColor: color(a['backgroundColor']));
      case 'Placeholder':
        return Placeholder(color: color(a['color']) ?? const Color(0xFF455A64), fallbackHeight: num_(a['fallbackHeight']) ?? 100, fallbackWidth: num_(a['fallbackWidth']) ?? 100);
      case 'CircularProgressIndicator':
        return CircularProgressIndicator(value: num_(a['value']), color: color(a['color']));
      case 'LinearProgressIndicator':
        return LinearProgressIndicator(value: num_(a['value']), color: color(a['color']));
      case 'Builder':
        return Builder(builder: (c) => render(rt.call(a['builder'], [rt.context])));
      case 'Tooltip':
        return Tooltip(message: str(a['message']) ?? '', child: child(n, 'child'));
      case 'Badge':
        return Badge(label: child(n, 'label'), child: child(n, 'child'));
      case 'AspectRatio':
        return AspectRatio(aspectRatio: num_(a['aspectRatio']) ?? 1, child: child(n, 'child'));
      case 'FittedBox':
        return FittedBox(child: child(n, 'child'));
      case 'ConstrainedBox':
        final c = a['constraints'];
        return ConstrainedBox(
          constraints: c is FNode
              ? BoxConstraints(
                  minWidth: num_(c.named['minWidth']) ?? 0,
                  maxWidth: num_(c.named['maxWidth']) ?? double.infinity,
                  minHeight: num_(c.named['minHeight']) ?? 0,
                  maxHeight: num_(c.named['maxHeight']) ?? double.infinity,
                )
              : const BoxConstraints(),
          child: child(n, 'child'),
        );
      case 'DecoratedBox':
        return DecoratedBox(decoration: decoration(a['decoration']) ?? const BoxDecoration(), child: child(n, 'child'));
      case 'Material':
        return Material(color: color(a['color']), elevation: num_(a['elevation']) ?? 0, child: child(n, 'child'));
      case 'NavigationBar':
        return NavigationBar(
          selectedIndex: (a['selectedIndex'] as int?) ?? 0,
          onDestinationSelected: callback1<int>(a['onDestinationSelected']),
          destinations: children(n, 'destinations'),
        );
      case 'NavigationDestination':
        return NavigationDestination(icon: child(n, 'icon') ?? const Icon(Icons.circle), label: str(a['label']) ?? '', selectedIcon: child(n, 'selectedIcon'));
      case 'BottomNavigationBar':
        final items = a['items'];
        return BottomNavigationBar(
          currentIndex: (a['currentIndex'] as int?) ?? 0,
          onTap: callback1<int>(a['onTap']),
          items: [
            for (final it in (items as List? ?? const []).whereType<FNode>())
              BottomNavigationBarItem(icon: render(it.named['icon']), label: str(it.named['label'])),
          ],
        );
    }
    throw RenderProblem('`${n.type}` — bu widget preview\'da hozircha qo\'llab-quvvatlanmaydi.',
        hint: 'Asosiy widgetlar: Text, Container, Row, Column, Stack, ListView, Card, ListTile, tugmalar, Scaffold, AppBar.');
  }

  BoxDecoration? _withColor(BoxDecoration? d, Map<String, Object?> a) {
    if (d != null && a['color'] != null) {
      throw RenderProblem('Container\'ga `color` va `decoration` ni birga berib bo\'lmaydi.', hint: 'Rangni BoxDecoration(color: ...) ichiga yozing.');
    }
    return d;
  }

  Axis _axis(Object? v) => v is FEnum && v.name == 'horizontal' ? Axis.horizontal : Axis.vertical;

  Widget _textField(FNode n) {
    final a = n.named;
    final ctrlObj = a['controller'];
    TextEditingController? controller;
    if (ctrlObj is KInstance) {
      controller = scope.controllers.putIfAbsent(ctrlObj, () => TextEditingController(text: (ctrlObj.fields['text'] as String?) ?? ''));
      final want = (ctrlObj.fields['text'] as String?) ?? '';
      if (controller.text != want) controller.text = want;
    }
    final d = a['decoration'];
    return TextField(
      controller: controller,
      obscureText: a['obscureText'] == true,
      maxLines: (a['maxLines'] as int?) ?? 1,
      onChanged: (v) {
        if (ctrlObj is KInstance) ctrlObj.fields['text'] = v;
        if (a['onChanged'] != null) _safe(() => rt.call(a['onChanged'], [v]));
      },
      onSubmitted: a['onSubmitted'] == null ? null : (v) => _safe(() => rt.call(a['onSubmitted'], [v])),
      decoration: d is FNode
          ? InputDecoration(
              labelText: str(d.named['labelText']),
              hintText: str(d.named['hintText']),
              helperText: str(d.named['helperText']),
              errorText: str(d.named['errorText']),
              prefixIcon: d.named['prefixIcon'] == null ? null : render(d.named['prefixIcon']),
              suffixIcon: d.named['suffixIcon'] == null ? null : render(d.named['suffixIcon']),
              border: d.named['border'] is FNode && (d.named['border'] as FNode).type == 'OutlineInputBorder'
                  ? const OutlineInputBorder()
                  : const UnderlineInputBorder(),
              filled: false,
            )
          : const InputDecoration(),
    );
  }
}

class _KStateless extends StatelessWidget {
  const _KStateless({required this.inst, required this.renderer});
  final KInstance inst;
  final KitobRenderer renderer;

  @override
  Widget build(BuildContext context) {
    try {
      return renderer.render(renderer.rt.build(inst));
    } on FlutterRunError catch (e) {
      return PreviewErrorBox(title: '${inst.klass.name}.build(): ${e.info.explanation}', hint: e.info.message);
    }
  }
}

class _KStateful extends StatefulWidget {
  const _KStateful({required this.inst, required this.renderer});
  final KInstance inst;
  final KitobRenderer renderer;

  @override
  State<_KStateful> createState() => _KStatefulState();
}

class _KStatefulState extends State<_KStateful> {
  KInstance? _state;
  Object? _error;

  void _create() {
    try {
      _state = widget.renderer.rt.createState(widget.inst);
      widget.renderer.scope.refreshers[_state!] = refresh;
      _error = null;
    } catch (e) {
      _error = e;
    }
  }

  @override
  void initState() {
    super.initState();
    _create();
  }

  @override
  void didUpdateWidget(_KStateful old) {
    super.didUpdateWidget(old);
    if (old.inst.klass != widget.inst.klass) {
      if (_state != null) widget.renderer.scope.refreshers.remove(_state);
      _create();
    } else if (_state != null && !identical(old.inst, widget.inst)) {
      try {
        widget.renderer.rt.updateWidget(_state!, widget.inst);
      } catch (e) {
        _error = e;
      }
    }
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_state != null) widget.renderer.scope.refreshers.remove(_state);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final err = _error;
    if (err != null) return PreviewErrorBox(title: err is FlutterRunError ? err.info.explanation : '$err');
    try {
      return widget.renderer.render(widget.renderer.rt.buildState(_state!));
    } on FlutterRunError catch (e) {
      return PreviewErrorBox(title: '${widget.inst.klass.name}: ${e.info.explanation}', hint: e.info.message);
    }
  }
}

/// O'quvchining MaterialApp'i — o'z Navigator va ScaffoldMessenger bilan.
class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.home, required this.renderer, required this.title, required this.theme, required this.banner});
  final Object? home;
  final KitobRenderer renderer;
  final String title;
  final ThemeData theme;
  final bool banner;

  @override
  Widget build(BuildContext context) {
    final host = PreviewHostScope.of(context);
    return MaterialApp(
      navigatorKey: host?.navigatorKey,
      scaffoldMessengerKey: host?.messengerKey,
      title: title,
      theme: theme,
      debugShowCheckedModeBanner: banner,
      home: home == null ? const SizedBox() : renderer.render(home),
    );
  }
}

/// Preview host kalitlarini (navigatsiya, snackbar) yetkazib beradi.
class PreviewHostScope extends InheritedWidget {
  const PreviewHostScope({super.key, required this.navigatorKey, required this.messengerKey, required super.child});
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  static PreviewHostScope? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PreviewHostScope>();

  @override
  bool updateShouldNotify(PreviewHostScope old) => false;
}

/// Flutter'dagi qizil xato ekraniga o'xshash, lekin o'zbekcha tushuntirishli.
class PreviewErrorBox extends StatelessWidget {
  const PreviewErrorBox({super.key, required this.title, this.hint});
  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 60),
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    color: const Color(0xFFB71C1C),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      const Row(children: [
        Icon(Icons.error_outline, color: Colors.white, size: 18),
        SizedBox(width: 6),
        Text('Widget xatosi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 4),
      Text(title.uz, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
      if (hint != null) ...[
        const SizedBox(height: 4),
        Text('💡 $hint'.uz, style: const TextStyle(color: Color(0xFFFFE082), fontSize: 12.5, height: 1.4)),
      ],
    ]),
  );
}
