import 'package:flutter/material.dart';
import 'package:flutter_kitob/src/core/design_system/theme.dart';
import 'package:flutter_kitob/src/features/flutter_preview/preview_view.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(String code) => MaterialApp(
  theme: KitobTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: Center(child: FlutterPreview(source: code)))),
);

const _counter = r'''
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Hisoblagich')),
        body: const Counter(),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Son: $n', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() => n++);
              print('bosildi $n');
            },
            child: const Text('Oshirish'),
          ),
        ],
      ),
    );
  }
}
''';

void main() {
  testWidgets('hisoblagich: tugma bosilganda setState ekranni yangilaydi', (tester) async {
    await tester.pumpWidget(_host(_counter));
    await tester.pumpAndSettle();
    expect(find.text('Hisoblagich'), findsOneWidget);
    expect(find.text('Son: 0'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Oshirish'));
    await tester.pumpAndSettle();
    expect(find.text('Son: 1'), findsOneWidget);
    expect(find.text('bosildi 1'), findsOneWidget);
  });

  testWidgets('Text ga son berilsa — o\'zbekcha xato', (tester) async {
    await tester.pumpWidget(_host("import 'package:flutter/material.dart';\nvoid main() { runApp(const Center(child: Text('a'))); }\n"));
    await tester.pumpAndSettle();
    expect(find.text('a'), findsOneWidget);
    await tester.pumpWidget(_host("import 'package:flutter/material.dart';\nvoid main() { runApp(Center(child: Text(5))); }\n"));
    await tester.pumpAndSettle();
    expect(find.text('Widget xatosi'), findsOneWidget);
    expect(find.textContaining('String', findRichText: true), findsWidgets);
  });

  testWidgets('noto\'g\'ri parametr nomi — taklif', (tester) async {
    await tester.pumpWidget(_host("import 'package:flutter/material.dart';\nvoid main() { runApp(Container(colr: Colors.red)); }\n"));
    await tester.pumpAndSettle();
    expect(find.textContaining('color', findRichText: true), findsWidgets);
  });

  testWidgets('ListView.builder, TextField va Navigator.push', (tester) async {
    const code = r'''
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final items = <String>['Olma', 'Nok'];
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        TextField(controller: controller, decoration: const InputDecoration(hintText: 'Meva')),
        FilledButton(
          onPressed: () => setState(() {
            items.add(controller.text);
            controller.clear();
          }),
          child: const Text('Qo\'sh'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(items[i]),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(body: Text('Tanlandi: ${items[i]}')))),
            ),
          ),
        ),
      ]),
    );
  }
}
''';
    await tester.pumpWidget(_host(code));
    await tester.pumpAndSettle();
    expect(find.text('Olma'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Uzum');
    await tester.tap(find.text("Qo'sh"));
    await tester.pumpAndSettle();
    expect(find.text('Uzum'), findsOneWidget);
    await tester.tap(find.text('Nok'));
    await tester.pumpAndSettle();
    expect(find.text('Tanlandi: Nok'), findsOneWidget);
  });
}
