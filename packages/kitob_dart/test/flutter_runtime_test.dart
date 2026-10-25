import 'package:kitob_dart/kitob_dart.dart';
import 'package:test/test.dart';

class _Host extends FlutterHost {
  int setStates = 0;
  @override
  void onSetState(KInstance state) => setStates++;
}

const counterApp = r'''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hisoblagich')),
        body: const CounterPage(title: 'Bosishlar'),
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});
  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.title, style: TextStyle(fontSize: 20, color: Colors.blue.shade700)),
          Text('$_count'),
          ElevatedButton(onPressed: _increment, child: const Text('Qo\'shish')),
          Icon(Icons.favorite, color: Colors.red),
        ],
      ),
    );
  }
}
''';

void main() {
  test('Flutter kodi checkerdan o\'tadi', () {
    final d = KitobDart.analyze(counterApp).where((d) => d.isError).toList();
    expect(d, isEmpty, reason: d.join('\n'));
  });

  test('widget daraxti yoyiladi va setState ishlaydi', () {
    final host = _Host();
    final (rt, diags, err) = FlutterRuntime.open(counterApp, host: host);
    expect(err, isNull, reason: err?.message);
    expect(rt, isNotNull, reason: diags.join('\n'));
    var tree = rt!.expand();
    final texts = tree.all.where((d) => d.type == 'Text').map((d) => d.text).toList();
    expect(texts, containsAll(['Hisoblagich', 'Bosishlar', '0', "Qo'shish"]));
    final button = tree.all.firstWhere((d) => d.type == 'ElevatedButton');
    rt.call(button.onTap);
    expect(host.setStates, 1);
    tree = rt.expand();
    expect(tree.all.where((d) => d.type == 'Text').map((d) => d.text), contains('1'));
    final icon = tree.all.firstWhere((d) => d.type == 'Icon');
    expect(icon.props['icon'], 'favorite');
  });

  test('build metodi yo\'q bo\'lsa — xato', () {
    const bad = "import 'package:flutter/material.dart';\nvoid main() { runApp(A()); }\nclass A extends StatelessWidget {}\n";
    final d = KitobDart.analyze(bad).where((d) => d.isError).toList();
    expect(d.map((e) => e.code), contains('non_abstract_class_inherits_abstract_member'));
  });

  test('noto\'g\'ri widget nomi — taklif bilan xato', () {
    const bad = "import 'package:flutter/material.dart';\nvoid main() { runApp(Contaner()); }\n";
    final d = KitobDart.analyze(bad).where((d) => d.isError).toList();
    expect(d, isNotEmpty);
    expect(d.first.hint, contains('Container'));
  });

  test('flutter importisiz Text — import maslahati', () {
    const bad = "void main() { var t = Text('x'); print(t); }\n";
    final d = KitobDart.analyze(bad).where((d) => d.isError).toList();
    expect(d.first.hint, contains('package:flutter/material.dart'));
  });
}
