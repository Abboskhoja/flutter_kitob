import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/store.dart';

@immutable
class PlayFile {
  const PlayFile({required this.id, required this.name, required this.code, required this.updated});
  final String id;
  final String name;
  final String code;
  final int updated;

  PlayFile copyWith({String? name, String? code}) =>
      PlayFile(id: id, name: name ?? this.name, code: code ?? this.code, updated: DateTime.now().millisecondsSinceEpoch);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'code': code, 'u': updated};
  factory PlayFile.fromJson(Map<String, Object?> j) =>
      PlayFile(id: j['id'] as String, name: j['name'] as String, code: j['code'] as String, updated: j['u'] as int? ?? 0);
}

@immutable
class PlaygroundState {
  const PlaygroundState({required this.files, required this.currentId, this.stdin = ''});
  final List<PlayFile> files;
  final String currentId;
  final String stdin;

  PlayFile get current => files.firstWhere((f) => f.id == currentId, orElse: () => files.first);

  PlaygroundState copyWith({List<PlayFile>? files, String? currentId, String? stdin}) =>
      PlaygroundState(files: files ?? this.files, currentId: currentId ?? this.currentId, stdin: stdin ?? this.stdin);
}

const defaultProgram = r'''void main() {
  print('Salom, FLUTTER_KITOB!');

  var ism = 'Dasturchi';
  for (var i = 1; i <= 3; i++) {
    print('$i. $ism, kod yozishda davom et!');
  }
}
''';

const playgroundSamples = <String, String>{
  'Salom dunyo': "void main() {\n  print('Salom, dunyo!');\n}\n",
  'O\'zgaruvchilar': "void main() {\n  String ism = 'Aziz';\n  int yosh = 20;\n  double boy = 1.78;\n  bool talaba = true;\n  print('\$ism, \$yosh yosh, bo\\'yi \$boy, talaba: \$talaba');\n}\n",
  'Shartlar': "void main() {\n  var ball = 78;\n  if (ball >= 90) {\n    print(\"A'lo\");\n  } else if (ball >= 70) {\n    print('Yaxshi');\n  } else {\n    print('Qoniqarli');\n  }\n}\n",
  'Sikllar': "void main() {\n  for (var i = 1; i <= 5; i++) {\n    print('3 x \$i = \${3 * i}');\n  }\n}\n",
  'List va Map': "void main() {\n  var mevalar = ['olma', 'nok', 'uzum'];\n  mevalar.add('anor');\n  print(mevalar);\n\n  var narxlar = {'non': 4000, 'sut': 12000};\n  narxlar.forEach((k, v) => print('\$k: \$v so\\'m'));\n}\n",
  'Funksiyalar': "int kvadrat(int n) => n * n;\n\nString salom({required String ism}) => 'Salom, \$ism!';\n\nvoid main() {\n  print(kvadrat(7));\n  print(salom(ism: 'Laylo'));\n}\n",
  'Class va obyekt': "class Talaba {\n  final String ism;\n  int ball = 0;\n  Talaba(this.ism);\n\n  void bahola(int b) => ball += b;\n\n  @override\n  String toString() => '\$ism: \$ball ball';\n}\n\nvoid main() {\n  var t = Talaba('Ali');\n  t.bahola(40);\n  t.bahola(45);\n  print(t);\n}\n",
  'Kiritish (stdin)': "import 'dart:io';\n\nvoid main() {\n  stdout.write('Ismingiz: ');\n  var ism = stdin.readLineSync() ?? 'Mehmon';\n  print('Salom, \$ism!');\n}\n",
  'Xatolarni ushlash': "void main() {\n  try {\n    var son = int.parse('12a');\n    print(son);\n  } on FormatException {\n    print('Bu son emas!');\n  } finally {\n    print('Tugadi');\n  }\n}\n",
  'Asinxron: Future va Stream': r'''import 'dart:async';

Future<String> yukla(String nom) async {
  await Future.delayed(Duration(seconds: 1));
  return '$nom yuklandi';
}

Stream<int> sanash(int n) async* {
  for (var i = n; i >= 1; i--) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

Future<void> main() async {
  print('Boshlandi');
  scheduleMicrotask(() => print('microtask'));
  print(await yukla('Profil'));
  final natijalar = await Future.wait([yukla('Rasm'), yukla('Xabarlar')]);
  print(natijalar);
  await for (final s in sanash(3)) {
    print('$s...');
  }
  print('Tayyor!');
}
''',
  'Flutter: hisoblagich': '''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Hisoblagich()));

class Hisoblagich extends StatefulWidget {
  const Hisoblagich({super.key});

  @override
  State<Hisoblagich> createState() => _HisoblagichState();
}

class _HisoblagichState extends State<Hisoblagich> {
  int _son = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hisoblagich')),
      body: Center(
        child: Text('\$_son', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _son++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
''',
  'Flutter: ro\'yxat': '''import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Mevalar()));

class Mevalar extends StatefulWidget {
  const Mevalar({super.key});

  @override
  State<Mevalar> createState() => _MevalarState();
}

class _MevalarState extends State<Mevalar> {
  final _mevalar = ['Olma', 'Nok', 'Uzum'];
  final _ctrl = TextEditingController();

  void _qosh() {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      _mevalar.add(_ctrl.text);
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mevalar (\${_mevalar.length})')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Yangi meva'))),
            IconButton(icon: const Icon(Icons.add_circle), onPressed: _qosh),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _mevalar.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.local_cafe),
              title: Text(_mevalar[i]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _mevalar.removeAt(i)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
''',
};

class PlaygroundNotifier extends Notifier<PlaygroundState> {
  static const _key = 'playground';

  @override
  PlaygroundState build() {
    final j = ref.read(storeProvider).readJson(_key);
    if (j != null) {
      final files = [for (final f in (j['files'] as List? ?? const [])) PlayFile.fromJson((f as Map).cast<String, Object?>())];
      if (files.isNotEmpty) {
        return PlaygroundState(files: files, currentId: j['current'] as String? ?? files.first.id, stdin: j['stdin'] as String? ?? '');
      }
    }
    final f = PlayFile(id: 'f1', name: 'main.dart', code: defaultProgram, updated: DateTime.now().millisecondsSinceEpoch);
    return PlaygroundState(files: [f], currentId: f.id);
  }

  void _save(PlaygroundState s) {
    state = s;
    ref.read(storeProvider).writeJson(_key, {
      'files': [for (final f in s.files) f.toJson()],
      'current': s.currentId,
      'stdin': s.stdin,
    });
  }

  void updateCode(String code) {
    if (state.current.code == code) return;
    _save(state.copyWith(files: [for (final f in state.files) f.id == state.currentId ? f.copyWith(code: code) : f]));
  }

  void select(String id) => _save(state.copyWith(currentId: id));
  void setStdin(String s) => _save(state.copyWith(stdin: s));

  String create({String? name, String code = defaultProgram}) {
    final id = 'f${DateTime.now().microsecondsSinceEpoch}';
    var n = name ?? 'yangi_${state.files.length + 1}.dart';
    if (!n.endsWith('.dart')) n = '$n.dart';
    _save(state.copyWith(files: [...state.files, PlayFile(id: id, name: n, code: code, updated: DateTime.now().millisecondsSinceEpoch)], currentId: id));
    return id;
  }

  void rename(String id, String name) {
    var n = name.trim().isEmpty ? 'main.dart' : name.trim();
    if (!n.endsWith('.dart')) n = '$n.dart';
    _save(state.copyWith(files: [for (final f in state.files) f.id == id ? f.copyWith(name: n) : f]));
  }

  void delete(String id) {
    if (state.files.length <= 1) {
      _save(state.copyWith(files: [state.files.first.copyWith(code: defaultProgram)]));
      return;
    }
    final files = state.files.where((f) => f.id != id).toList();
    _save(state.copyWith(files: files, currentId: state.currentId == id ? files.first.id : state.currentId));
  }
}

final playgroundProvider = NotifierProvider<PlaygroundNotifier, PlaygroundState>(PlaygroundNotifier.new);
