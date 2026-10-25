part of 'interpreter.dart';

/// Flutter kutubxonasi URI lari — o'quv Flutter runtime'i bilan qo'llab-quvvatlanadi.
const flutterLibraryUris = {'package:flutter/material.dart', 'package:flutter/widgets.dart', 'package:flutter/cupertino.dart'};

bool usesFlutter(Program p) => p.imports.any((i) => flutterLibraryUris.contains(i.uri));

/// Flutter widgeti yoki qiymati (masalan `Text('Salom')`, `EdgeInsets.all(8)`).
class FNode {
  FNode(this.type, this.pos, this.named);
  final String type;
  final List<Object?> pos;
  final Map<String, Object?> named;

  @override
  String toString() => '$type(...)';
}

class FColor {
  const FColor(this.argb, [this.swatch]);
  final int argb;
  final String? swatch;

  @override
  bool operator ==(Object other) => other is FColor && other.argb == argb;
  @override
  int get hashCode => argb.hashCode;
}

/// `MainAxisAlignment.center`, `FontWeight.bold` kabi qiymatlar.
class FEnum {
  const FEnum(this.type, this.name);
  final String type;
  final String name;

  @override
  bool operator ==(Object other) => other is FEnum && other.type == type && other.name == name;
  @override
  int get hashCode => Object.hash(type, name);
}

class FIcon {
  const FIcon(this.name);
  final String name;
  @override
  bool operator ==(Object other) => other is FIcon && other.name == name;
  @override
  int get hashCode => name.hashCode;
}

/// `Text`, `Container`, `Colors`, `EdgeInsets` — chaqiriladigan va statik a'zoli tur.
class FlutterType {
  const FlutterType(this.name);
  final String name;
}

/// O'quv runtime qo'llab-quvvatlaydigan widgetlar.
const flutterWidgetTypes = {
  'MaterialApp', 'Scaffold', 'AppBar', 'Text', 'Icon', 'Container', 'SizedBox', 'Padding', 'Center', 'Align',
  'Row', 'Column', 'Stack', 'Positioned', 'Expanded', 'Flexible', 'Spacer', 'ListView', 'GridView',
  'SingleChildScrollView', 'SafeArea', 'Card', 'ListTile', 'ElevatedButton', 'FilledButton', 'TextButton',
  'OutlinedButton', 'IconButton', 'FloatingActionButton', 'Divider', 'CircleAvatar', 'Image', 'Switch', 'Checkbox',
  'TextField', 'Wrap', 'Opacity', 'ClipRRect', 'GestureDetector', 'InkWell', 'AnimatedContainer', 'Chip',
  'Placeholder', 'CircularProgressIndicator', 'LinearProgressIndicator', 'Builder', 'Tooltip', 'Badge',
  'NavigationBar', 'NavigationDestination', 'BottomNavigationBar', 'BottomNavigationBarItem', 'AspectRatio',
  'FittedBox', 'ConstrainedBox', 'AnimatedOpacity', 'DecoratedBox', 'Material', 'SwitchListTile', 'CheckboxListTile',
};

const _flutterValueTypes = {
  'Color', 'TextStyle', 'EdgeInsets', 'BoxDecoration', 'BoxShadow', 'Border', 'BorderRadius', 'Radius', 'Offset',
  'Size', 'InputDecoration', 'ThemeData', 'ColorScheme', 'MaterialPageRoute', 'SnackBar', 'BoxConstraints',
  'OutlineInputBorder', 'UnderlineInputBorder', 'BorderSide', 'LinearGradient', 'NetworkImage',
};

const _flutterEnums = <String, Set<String>>{
  'FontWeight': {'w100', 'w200', 'w300', 'w400', 'w500', 'w600', 'w700', 'w800', 'w900', 'bold', 'normal'},
  'FontStyle': {'italic', 'normal'},
  'TextAlign': {'left', 'right', 'center', 'justify', 'start', 'end'},
  'MainAxisAlignment': {'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly'},
  'CrossAxisAlignment': {'start', 'end', 'center', 'stretch', 'baseline'},
  'MainAxisSize': {'min', 'max'},
  'Alignment': {'topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight'},
  'BoxShape': {'rectangle', 'circle'},
  'BoxFit': {'cover', 'contain', 'fill', 'fitWidth', 'fitHeight', 'none', 'scaleDown'},
  'Curves': {'linear', 'easeIn', 'easeOut', 'easeInOut', 'bounceOut', 'elasticOut', 'easeOutBack', 'fastOutSlowIn'},
  'Axis': {'horizontal', 'vertical'},
  'TextOverflow': {'ellipsis', 'clip', 'fade', 'visible'},
  'Clip': {'none', 'hardEdge', 'antiAlias'},
  'StackFit': {'loose', 'expand'},
  'WrapAlignment': {'start', 'end', 'center', 'spaceBetween', 'spaceAround', 'spaceEvenly'},
  'Brightness': {'light', 'dark'},
  'TextInputType': {'text', 'number', 'emailAddress', 'phone', 'multiline'},
};

/// Preview'da mavjud ikonkalar (ilova ularni haqiqiy `Icons.x` ga moslaydi).
const flutterIconNames = {
  'add', 'remove', 'home', 'favorite', 'favorite_border', 'star', 'star_border', 'settings', 'person', 'search',
  'menu', 'close', 'check', 'delete', 'edit', 'share', 'info', 'warning', 'error', 'help', 'school', 'code', 'phone',
  'email', 'lock', 'visibility', 'visibility_off', 'arrow_back', 'arrow_forward', 'chevron_right', 'chevron_left',
  'shopping_cart', 'notifications', 'camera_alt', 'photo', 'music_note', 'play_arrow', 'pause', 'stop', 'refresh',
  'thumb_up', 'thumb_down', 'map', 'location_on', 'calendar_today', 'access_time', 'cloud', 'wb_sunny', 'bolt',
  'rocket_launch', 'book', 'lightbulb', 'directions_car', 'pets', 'sports_soccer', 'restaurant', 'local_cafe',
  'shopping_bag', 'account_circle', 'logout', 'login', 'send', 'chat', 'flag', 'done', 'done_all', 'language',
  'dark_mode', 'light_mode', 'wifi', 'battery_full', 'flutter_dash', 'emoji_emotions', 'celebration', 'task_alt',
  'list', 'grid_view', 'calculate', 'savings', 'attach_money', 'event', 'more_vert', 'more_horiz', 'expand_more',
  'expand_less', 'keyboard_arrow_down', 'keyboard_arrow_up', 'add_circle', 'remove_circle', 'check_circle', 'cancel',
};

const flutterPreludeSource = r'''
abstract class Widget {
  final Key? key;
  const Widget({this.key});
}
class Key {
  final dynamic value;
  const Key(this.value);
}
class ValueKey extends Key {
  const ValueKey(super.value);
}
class BuildContext {
  BuildContext();
}
abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});
  Widget build(BuildContext context);
}
abstract class StatefulWidget extends Widget {
  const StatefulWidget({super.key});
  State createState();
}
abstract class State<T> {
  late T widget;
  late BuildContext context;
  bool mounted = true;
  void initState() {}
  void didUpdateWidget(T oldWidget) {}
  void dispose() {}
  void setState(void Function() fn) {
    fn();
    __kitobSetState(this);
  }
  Widget build(BuildContext context);
}
class TextEditingController {
  String text = '';
  TextEditingController({this.text = ''});
  void clear() {
    text = '';
  }
  void dispose() {}
}
''';

const flutterPreludeClassNames = {
  'Widget', 'Key', 'ValueKey', 'BuildContext', 'StatelessWidget', 'StatefulWidget', 'State', 'TextEditingController',
};

/// Checker uchun: Flutter kutubxonasi beradigan barcha nomlar.
Set<String> get flutterMemberNames => {
  ...flutterWidgetTypes,
  ..._flutterValueTypes,
  ..._flutterEnums.keys,
  'Colors', 'Icons', 'Theme', 'MediaQuery', 'Navigator', 'ScaffoldMessenger', 'runApp', 'debugPrint', 'kDebugMode',
  'VoidCallback', 'ValueChanged', 'IconData', 'Duration',
};

/// Checker turlarni tanishi uchun.
const flutterTypeNames = {
  'Widget', 'Color', 'TextStyle', 'EdgeInsets', 'IconData', 'VoidCallback', 'ValueChanged', 'BoxDecoration',
  'BuildContext', 'Key', 'State', 'StatelessWidget', 'StatefulWidget', 'TextEditingController', 'ThemeData',
  'Alignment', 'MainAxisAlignment', 'CrossAxisAlignment', 'FontWeight', 'Size', 'Offset', 'BorderRadius', 'Icon',
  'Text', 'Route', 'MaterialPageRoute',
};

Program? _flutterPreludeCache;
Program get flutterPrelude => _flutterPreludeCache ??= Parser(flutterPreludeSource).parseProgram();

/// Preview oynasi bilan bog'lanish: holat yangilanishi, navigatsiya, mavzu.
abstract class FlutterHost {
  void onSetState(KInstance state);
  void onPush(Object? route) {}
  void onPop() {}
  void onSnackBar(Object? snackBar) {}
  double get screenWidth => 390;
  double get screenHeight => 760;
  bool get isDark => false;

  /// Kod ichida timer (Future.delayed, Timer) bor: [delay] dan keyin `FlutterRuntime.pump()` ni chaqiring.
  void scheduleWake(Duration delay) {}
}

extension _FlutterBuiltins on Interpreter {
  Map<String, Object?> _flutterLibrary() => {
    for (final w in flutterWidgetTypes) w: FlutterType(w),
    for (final v in _flutterValueTypes) v: FlutterType(v),
    for (final e in _flutterEnums.keys) e: FlutterType(e),
    'Colors': const FlutterType('Colors'),
    'Icons': const FlutterType('Icons'),
    'Theme': const FlutterType('Theme'),
    'MediaQuery': const FlutterType('MediaQuery'),
    'Navigator': const FlutterType('Navigator'),
    'ScaffoldMessenger': const FlutterType('ScaffoldMessenger'),
    'kDebugMode': true,
    'runApp': NativeFunction('runApp', (p, n) {
      flutterRoot = p.isEmpty ? null : p.first;
      return null;
    }, signature: '(Widget) => void'),
    'debugPrint': NativeFunction('debugPrint', (p, n) {
      _write('${stringify(p.first)}\n');
      return null;
    }, signature: '(String?) => void'),
    '__kitobSetState': NativeFunction('setState', (p, n) {
      final s = p.first;
      flutterSetStates++;
      if (s is KInstance) flutterHost?.onSetState(s);
      return null;
    }),
  };

  FColor _colorConst(String name, int offset) {
    final sw = materialSwatches[name];
    if (sw != null) return FColor(sw[500]!, name);
    final plain = plainColors[name];
    if (plain != null) return FColor(plain);
    throw ExecutionAbort('unknown_color', "`Colors.$name` rangi topilmadi.", "Member not found: 'Colors.$name'.", offset,
        hint: 'Mavjud ranglar: ${materialSwatches.keys.take(8).join(', ')}, black, white...');
  }

  Object? _flutterTypeProperty(FlutterType t, String name, int offset) {
    switch (t.name) {
      case 'Colors':
        return _colorConst(name, offset);
      case 'Icons':
        if (flutterIconNames.contains(name)) return FIcon(name);
        throw ExecutionAbort('unknown_icon', "`Icons.$name` ikonkasi bu preview'da mavjud emas.", "Member not found: 'Icons.$name'.", offset,
            hint: 'Masalan: Icons.home, Icons.favorite, Icons.star, Icons.add');
      case 'EdgeInsets':
        if (name == 'zero') return FNode('EdgeInsets.all', [0], {});
      case 'BorderRadius':
        if (name == 'zero') return FNode('BorderRadius.circular', [0], {});
      case 'Offset':
        if (name == 'zero') return FNode('Offset', [0, 0], {});
    }
    final e = _flutterEnums[t.name];
    if (e != null && e.contains(name)) return FEnum(t.name, name);
    throw ExecutionAbort('unknown_flutter_member', "`${t.name}.$name` topilmadi.", "Member not found: '${t.name}.$name'.", offset);
  }

  Object? _flutterCall(FlutterType t, List<Object?> pos, Map<String, Object?> named, int offset) {
    if (t.name == 'Color') return FColor(_intArg(pos.first, offset));
    if (_flutterEnums.containsKey(t.name) || t.name == 'Colors' || t.name == 'Icons') {
      throw ExecutionAbort('not_constructor', "`${t.name}` dan obyekt yaratilmaydi — `${t.name}.qiymat` ko'rinishida ishlating.",
          "The class '${t.name}' doesn't have an unnamed constructor.", offset);
    }
    return FNode(t.name, pos, named);
  }

  Object? _flutterStaticMethod(FlutterType t, String name, List<Object?> pos, Map<String, Object?> named, int offset) {
    final host = flutterHost;
    switch ('${t.name}.$name') {
      case 'Theme.of':
        return _themeData(host?.isDark ?? false);
      case 'MediaQuery.of':
        return FNode('MediaQueryData', const [], {
          'size': FNode('Size', const [], {'width': KDouble(host?.screenWidth ?? 390), 'height': KDouble(host?.screenHeight ?? 760)}),
        });
      case 'MediaQuery.sizeOf':
        return FNode('Size', const [], {'width': KDouble(host?.screenWidth ?? 390), 'height': KDouble(host?.screenHeight ?? 760)});
      case 'Navigator.of':
        return FNode('NavigatorState', const [], const {});
      case 'Navigator.push':
        host?.onPush(pos.length > 1 ? pos[1] : null);
        return null;
      case 'Navigator.pop':
        host?.onPop();
        return null;
      case 'ScaffoldMessenger.of':
        return FNode('ScaffoldMessengerState', const [], const {});
      case 'Color.fromARGB':
        return FColor((_intArg(pos[0], offset) << 24) | (_intArg(pos[1], offset) << 16) | (_intArg(pos[2], offset) << 8) | _intArg(pos[3], offset));
    }
    return FNode('${t.name}.$name', pos, named);
  }

  FNode _themeData(bool dark) {
    FNode ts(double size, String weight) => FNode('TextStyle', const [], {'fontSize': KDouble(size), 'fontWeight': FEnum('FontWeight', weight)});
    return FNode('ThemeData', const [], {
      'colorScheme': FNode('ColorScheme', const [], {
        'primary': const FColor(0xFF087CF7),
        'secondary': const FColor(0xFF03B8E8),
        'surface': FColor(dark ? 0xFF111A2E : 0xFFFFFFFF),
        'onPrimary': const FColor(0xFFFFFFFF),
        'error': const FColor(0xFFEF4444),
      }),
      'textTheme': FNode('TextTheme', const [], {
        'headlineLarge': ts(32, 'w700'),
        'headlineMedium': ts(28, 'w700'),
        'headlineSmall': ts(24, 'w700'),
        'titleLarge': ts(22, 'w600'),
        'titleMedium': ts(16, 'w600'),
        'bodyLarge': ts(16, 'normal'),
        'bodyMedium': ts(14, 'normal'),
        'bodySmall': ts(12, 'normal'),
        'labelLarge': ts(14, 'w600'),
      }),
      'primaryColor': const FColor(0xFF087CF7),
    });
  }

  Object? _flutterValueProperty(Object t, String name, int offset) {
    if (t is FColor) {
      if (name.startsWith('shade') && t.swatch != null) {
        final v = int.tryParse(name.substring(5));
        final sw = materialSwatches[t.swatch];
        if (v != null && sw != null && sw.containsKey(v)) return FColor(sw[v]!, t.swatch);
      }
      switch (name) {
        case 'value':
          return t.argb;
        case 'alpha':
          return (t.argb >> 24) & 0xFF;
        case 'opacity':
          return KDouble(((t.argb >> 24) & 0xFF) / 255);
      }
    }
    if (t is FEnum && name == 'name') return t.name;
    if (t is FNode) {
      if (t.named.containsKey(name)) return t.named[name];
      if (t.type == 'Size' && (name == 'width' || name == 'height')) return KDouble(0);
    }
    return _notFound;
  }

  Object? _flutterValueMethod(Object t, String name, List<Object?> pos, Map<String, Object?> named, int offset) {
    if (t is FColor) {
      int alphaOf(double a) => (a.clamp(0, 1) * 255).round();
      switch (name) {
        case 'withOpacity':
          return FColor((t.argb & 0x00FFFFFF) | (alphaOf(_numOf(pos.first).toDouble()) << 24), t.swatch);
        case 'withValues':
          final a = named['alpha'];
          return a == null ? t : FColor((t.argb & 0x00FFFFFF) | (alphaOf(_numOf(a).toDouble()) << 24), t.swatch);
        case 'withAlpha':
          return FColor((t.argb & 0x00FFFFFF) | ((_intArg(pos.first, offset) & 0xFF) << 24), t.swatch);
      }
    }
    if (t is FNode) {
      if (name == 'copyWith') return FNode(t.type, t.pos, {...t.named, ...named});
      if (t.type == 'NavigatorState') {
        if (name == 'push') flutterHost?.onPush(pos.isEmpty ? null : pos.first);
        if (name == 'pop') flutterHost?.onPop();
        if (name == 'push' || name == 'pop') return null;
      }
      if (t.type == 'ScaffoldMessengerState' && name == 'showSnackBar') {
        flutterHost?.onSnackBar(pos.isEmpty ? null : pos.first);
        return null;
      }
    }
    return _notFound;
  }
}

// ───────────────────────── Runtime va baholash ─────────────────────────

/// Widget daraxtining sodda tavsifi (baholash va testlar uchun).
class WidgetDesc {
  WidgetDesc(this.type, {this.text, this.children = const [], this.props = const {}, this.onTap});
  final String type;
  final String? text;
  final List<WidgetDesc> children;
  final Map<String, String> props;

  /// Bosiladigan widget uchun callback.
  final Object? onTap;

  Iterable<WidgetDesc> get all sync* {
    yield this;
    for (final c in children) {
      yield* c.all;
    }
  }

  String dump([String indent = '']) {
    final keys = props.keys.toList()..sort();
    final ps = keys.map((k) => '$k: ${props[k]}').join(', ');
    final b = StringBuffer('$indent$type${text == null ? '' : "('$text')"}${ps.isEmpty ? '' : ' {$ps}'}\n');
    for (final c in children) {
      b.write(c.dump('$indent  '));
    }
    return b.toString();
  }
}

class FlutterRunError implements Exception {
  FlutterRunError(this.info);
  final RuntimeErrorInfo info;
  @override
  String toString() => info.message;
}

/// Flutter o'quv runtime'i: o'quvchi yozgan widget kodini bajaradi.
class FlutterRuntime {
  FlutterRuntime._(this.interp);
  final Interpreter interp;

  /// Preview'da (host bor) timer'lar haqiqiy vaqt bilan, baholashda esa virtual vaqt bilan ishlaydi.
  final Stopwatch _clock = Stopwatch()..start();
  final Map<String, KInstance> _states = {};
  late final KInstance context = interp._instantiate(interp.classes['BuildContext']!, '', const [], const {}, 0) as KInstance;

  Object? get root => interp.flutterRoot;
  int get setStateCount => interp.flutterSetStates;
  String get stdout => interp.stdout;

  set host(FlutterHost? h) => interp.flutterHost = h;

  static (FlutterRuntime?, List<Diagnostic>, RuntimeErrorInfo?) open(String source, {FlutterHost? host}) {
    final diagnostics = KitobDart.analyze(source);
    if (diagnostics.any((d) => d.isError)) return (null, diagnostics, null);
    final program = Parser(source).parseProgram();
    final interp = Interpreter(source, program, const ExecutionOptions(maxSteps: 3000000, timeout: Duration(seconds: 3)));
    interp.flutterHost = host;
    interp.drainEventLoopOnMain = false;
    try {
      interp.load();
      interp.runMain();
      interp.advanceTo(interp.nowMicros);
    } catch (e, st) {
      return (null, diagnostics, KitobDart.describeError(e, interp, st));
    }
    if (interp.flutterRoot == null) {
      return (null, diagnostics, const RuntimeErrorInfo(
        type: 'no_run_app',
        message: 'runApp() was not called',
        explanation: "main() ichida `runApp(...)` chaqirilmadi — Flutter ilova ekrani shu funksiya orqali ko'rsatiladi.",
        hint: 'Masalan: void main() { runApp(const MyApp()); }',
        line: 1,
        column: 1,
      ));
    }
    return (FlutterRuntime._(interp), diagnostics, null);
  }

  /// Preview'da haqiqiy o'tgan vaqt, baholashda joriy virtual vaqt.
  int get _target {
    if (interp.flutterHost == null) return interp.nowMicros;
    final real = _clock.elapsedMicroseconds;
    return real > interp.nowMicros ? real : interp.nowMicros;
  }

  T _guarded<T>(T Function() body) {
    interp.resetBudget();
    try {
      _advance(_target);
      final r = body();
      _advance(_target);
      return r;
    } catch (e, st) {
      final info = KitobDart.describeError(e, interp, st);
      if (info == null) rethrow;
      throw FlutterRunError(info);
    }
  }

  void _advance(int micros) {
    final next = interp.advanceTo(micros);
    final host = interp.flutterHost;
    if (next != null && host != null) host.scheduleWake(Duration(microseconds: next));
  }

  /// Preview: haqiqiy vaqt o'tgach vaqti kelgan timer'larni bajaradi (host.scheduleWake'dan keyin chaqiriladi).
  void pump() => _guarded(() {});

  /// Baholash: virtual vaqtni [max] gacha surib, kutilayotgan timer'larni (Future.delayed) bajaradi.
  void settle({Duration max = const Duration(seconds: 30)}) =>
      _guarded(() => _advance(interp.nowMicros + max.inMicroseconds));

  bool isStateless(Object? v) => v is KInstance && v.klass.isSubtypeOf('StatelessWidget');
  bool isStateful(Object? v) => v is KInstance && v.klass.isSubtypeOf('StatefulWidget');
  bool isState(Object? v) => v is KInstance && v.klass.isSubtypeOf('State');

  Object? build(KInstance widget) => _guarded(() => interp._callMethod(widget, 'build', [context], const {}, 0));

  KInstance createState(KInstance widget) => _guarded(() {
    final s = interp._callMethod(widget, 'createState', const [], const {}, 0);
    if (s is! KInstance) {
      throw ExecutionAbort('bad_state', 'createState() State obyekti qaytarishi kerak.', 'createState must return a State.', 0);
    }
    s.fields['widget'] = widget;
    s.fields['context'] = context;
    interp._callMethod(s, 'initState', const [], const {}, 0);
    return s;
  });

  void updateWidget(KInstance state, KInstance widget) {
    final old = state.fields['widget'];
    state.fields['widget'] = widget;
    if (!identical(old, widget)) {
      _guarded(() => interp._callMethod(state, 'didUpdateWidget', [old], const {}, 0));
    }
  }

  Object? buildState(KInstance state) => _guarded(() => interp._callMethod(state, 'build', [context], const {}, 0));

  /// Callback'ni chaqiradi (masalan `onPressed`).
  Object? call(Object? fn, [List<Object?> args = const []]) {
    if (fn == null) return null;
    return _guarded(() => interp._callValue(fn, args, const {}, 0));
  }

  String className(Object? v) => v is KInstance ? v.klass.name : interp.typeName(v);

  String display(Object? v) => interp.stringify(v);

  // ───── baholash uchun daraxtni yoyish ─────

  static const _childKeys = ['home', 'appBar', 'title', 'leading', 'body', 'child', 'floatingActionButton', 'bottomNavigationBar', 'subtitle', 'trailing', 'label', 'icon', 'content'];

  WidgetDesc expand([Object? v, String path = 'root', int depth = 0]) {
    v ??= root;
    if (depth > 60) return WidgetDesc('…');
    if (isStateless(v)) {
      final inst = v as KInstance;
      return WidgetDesc(inst.klass.name, children: [expand(build(inst), '$path/${inst.klass.name}', depth + 1)]);
    }
    if (isStateful(v)) {
      final inst = v as KInstance;
      final key = '$path/${inst.klass.name}';
      var s = _states[key];
      if (s == null) {
        s = createState(inst);
        _states[key] = s;
      } else {
        updateWidget(s, inst);
      }
      return WidgetDesc(inst.klass.name, children: [expand(buildState(s), key, depth + 1)]);
    }
    if (v is FNode) {
      final kids = <WidgetDesc>[];
      var i = 0;
      for (final k in _childKeys) {
        final c = v.named[k];
        if (c != null && _isWidgetValue(c)) kids.add(expand(c, '$path/${v.type}.$k', depth + 1));
      }
      final list = v.named['children'];
      if (list is List) {
        for (final c in list) {
          kids.add(expand(c, '$path/${v.type}[${i++}]', depth + 1));
        }
      }
      if (v.type == 'ListView.builder' || v.type == 'GridView.builder' || v.type == 'ListView.separated') {
        final n = (v.named['itemCount'] as int?) ?? 0;
        for (var j = 0; j < n && j < 40; j++) {
          kids.add(expand(call(v.named['itemBuilder'], [context, j]), '$path/item$j', depth + 1));
        }
      }
      if (v.type == 'Builder') kids.add(expand(call(v.named['builder'], [context]), '$path/builder', depth + 1));
      final type = v.type.contains('.') && flutterWidgetTypes.contains(v.type.split('.').first) ? v.type.split('.').first : v.type;
      String? text;
      if (type == 'Text' && v.pos.isNotEmpty) text = interp.stringify(v.pos.first);
      final props = <String, String>{
        for (final e in v.named.entries)
          if (e.value is! FNode && e.value is! List && e.value is! KFunction && e.value is! KInstance) e.key: _propText(e.value),
      };
      if (type == 'Icon' && v.pos.isNotEmpty && v.pos.first is FIcon) props['icon'] = (v.pos.first as FIcon).name;
      return WidgetDesc(type, text: text, children: kids, props: props, onTap: v.named['onPressed'] ?? v.named['onTap'] ?? v.named['onChanged']);
    }
    if (v == null) return WidgetDesc('null');
    return WidgetDesc(interp.typeName(v));
  }

  bool _isWidgetValue(Object? c) => c is FNode || c is KInstance;

  String _propText(Object? v) => switch (v) {
    FColor() => '0x${v.argb.toRadixString(16).toUpperCase()}',
    FEnum() => '${v.type}.${v.name}',
    FIcon() => 'Icons.${v.name}',
    _ => interp.stringify(v),
  };
}
