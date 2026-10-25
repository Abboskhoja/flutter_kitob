import 'package:kitob_dart/kitob_dart.dart';

/// Virtual fayl tizimi tuguni.
class VNode {
  VNode.dir(this.name) : isDir = true, content = '';
  VNode.file(this.name, [this.content = '']) : isDir = false;

  String name;
  final bool isDir;
  String content;
  final Map<String, VNode> children = {};

  Map<String, Object?> toJson() => {
    'n': name,
    'd': isDir,
    if (!isDir) 'c': content,
    if (isDir) 'ch': [for (final c in children.values) c.toJson()],
  };

  static VNode fromJson(Map<String, Object?> j) {
    final isDir = j['d'] as bool;
    final n = isDir ? VNode.dir(j['n'] as String) : VNode.file(j['n'] as String, j['c'] as String? ?? '');
    if (isDir) {
      for (final c in (j['ch'] as List? ?? const [])) {
        final child = fromJson((c as Map).cast<String, Object?>());
        n.children[child.name] = child;
      }
    }
    return n;
  }

  VNode clone() {
    final n = isDir ? VNode.dir(name) : VNode.file(name, content);
    for (final c in children.values) {
      n.children[c.name] = c.clone();
    }
    return n;
  }
}

enum LineKind { prompt, output, error, info, success }

class TermLine {
  const TermLine(this.text, this.kind, {this.cwd});
  final String text;
  final LineKind kind;
  final String? cwd;
}

const home = '/home/student';

/// Xavfsiz o'quv terminali. Hech qanday haqiqiy shell buyrug'i bajarilmaydi.
class VirtualShell {
  VirtualShell() {
    reset();
  }

  late VNode root;
  String cwd = home;
  final List<String> history = [];
  final Set<String> events = {};
  String? gitRepo;
  final Set<String> gitStaged = {};
  int gitCommits = 0;

  void reset() {
    root = VNode.dir('');
    final h = _mkdirs('/home/student');
    h.children['salom.dart'] = VNode.file('salom.dart', "void main() {\n  print('Salom, terminal!');\n}\n");
    h.children['README.txt'] = VNode.file('README.txt', 'Bu sizning uy papkangiz. "help" yozing — barcha buyruqlar ro\'yxati.\n');
    _mkdirs('/tmp');
    cwd = home;
    history.clear();
    events.clear();
    gitRepo = null;
    gitStaged.clear();
    gitCommits = 0;
  }

  Map<String, Object?> toJson() => {
    'root': root.toJson(),
    'cwd': cwd,
    'history': history.length > 200 ? history.sublist(history.length - 200) : history,
    'events': events.toList(),
    'git': gitRepo,
    'commits': gitCommits,
  };

  void load(Map<String, Object?> j) {
    root = VNode.fromJson((j['root'] as Map).cast<String, Object?>());
    cwd = j['cwd'] as String? ?? home;
    history
      ..clear()
      ..addAll((j['history'] as List? ?? const []).cast<String>());
    events
      ..clear()
      ..addAll((j['events'] as List? ?? const []).cast<String>());
    gitRepo = j['git'] as String?;
    gitCommits = j['commits'] as int? ?? 0;
    if (resolve(cwd) == null) cwd = home;
  }

  String get displayCwd => cwd == home ? '~' : (cwd.startsWith('$home/') ? '~${cwd.substring(home.length)}' : cwd);

  // ───────────────────────── Yo'llar ─────────────────────────

  String normalize(String path) {
    var p = path.trim();
    if (p.isEmpty) return cwd;
    if (p == '~' || p.startsWith('~/')) p = home + p.substring(1);
    final abs = p.startsWith('/') ? p : '$cwd/$p';
    final parts = <String>[];
    for (final seg in abs.split('/')) {
      if (seg.isEmpty || seg == '.') continue;
      if (seg == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(seg);
      }
    }
    return '/${parts.join('/')}';
  }

  VNode? resolve(String path) {
    final abs = normalize(path);
    var n = root;
    for (final seg in abs.split('/').where((s) => s.isNotEmpty)) {
      if (!n.isDir) return null;
      final c = n.children[seg];
      if (c == null) return null;
      n = c;
    }
    return n;
  }

  (VNode?, String) _parentOf(String path) {
    final abs = normalize(path);
    final idx = abs.lastIndexOf('/');
    final parent = idx <= 0 ? '/' : abs.substring(0, idx);
    return (resolve(parent), abs.substring(idx + 1));
  }

  VNode _mkdirs(String abs) {
    var n = root;
    for (final seg in abs.split('/').where((s) => s.isNotEmpty)) {
      n = n.children.putIfAbsent(seg, () => VNode.dir(seg));
    }
    return n;
  }

  bool _validName(String n) => n.isNotEmpty && !n.contains('/') && n != '.' && n != '..';

  // ───────────────────────── Buyruqlar ─────────────────────────

  List<String> _tokenize(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    String? quote;
    var had = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (quote != null) {
        if (c == quote) {
          quote = null;
        } else {
          buf.write(c);
        }
        continue;
      }
      if (c == '"' || c == "'") {
        quote = c;
        had = true;
      } else if (c == ' ' || c == '\t') {
        if (buf.isNotEmpty || had) {
          out.add(buf.toString());
          buf.clear();
          had = false;
        }
      } else if (c == '>') {
        if (buf.isNotEmpty) {
          out.add(buf.toString());
          buf.clear();
        }
        if (i + 1 < line.length && line[i + 1] == '>') {
          out.add('>>');
          i++;
        } else {
          out.add('>');
        }
      } else {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty || had) out.add(buf.toString());
    return out;
  }

  /// Buyruqni bajaradi va chiqadigan qatorlarni qaytaradi.
  List<TermLine> execute(String line) {
    final input = line.trim();
    final out = <TermLine>[TermLine(input, LineKind.prompt, cwd: displayCwd)];
    if (input.isEmpty) return out;
    history.add(input);
    final args = _tokenize(input);
    if (args.isEmpty) return out;

    // Yo'naltirish: echo ... > fayl
    String? redirect;
    var append = false;
    final ri = args.indexWhere((a) => a == '>' || a == '>>');
    var cmdArgs = args;
    if (ri >= 0) {
      if (ri + 1 >= args.length) {
        out.add(const TermLine('bash: sintaksis xatosi: ">" dan keyin fayl nomi kerak', LineKind.error));
        return out;
      }
      append = args[ri] == '>>';
      redirect = args[ri + 1];
      cmdArgs = args.sublist(0, ri);
    }

    final cmd = cmdArgs.first;
    final rest = cmdArgs.skip(1).toList();
    final result = <TermLine>[];
    void o(String s, [LineKind k = LineKind.output]) => result.add(TermLine(s, k));
    void err(String s) => result.add(TermLine(s, LineKind.error));

    switch (cmd) {
      case 'help':
        o('Mavjud buyruqlar:', LineKind.info);
        for (final h in const [
          'pwd                  — joriy papka yo\'li',
          'ls [-a] [papka]      — papka ichidagilar',
          'cd <papka>           — papkaga o\'tish (.. — yuqoriga, ~ — uyga)',
          'mkdir [-p] <nom>     — yangi papka',
          'touch <fayl>         — bo\'sh fayl yaratish',
          'cat <fayl>           — fayl ichini ko\'rsatish',
          'echo <matn> [> fayl] — matn chiqarish / faylga yozish',
          'rm [-r] <yo\'l>       — o\'chirish',
          'cp, mv <a> <b>       — nusxalash, ko\'chirish',
          'tree                 — papkalar daraxti',
          'clear                — ekranni tozalash',
          'history              — buyruqlar tarixi',
          'dart --version | dart create <nom> | dart run [fayl]',
          'flutter --version | doctor | create <nom> | pub get | analyze | test | run | build',
          'git init | status | add <fayl> | commit -m "xabar"',
        ]) {
          o('  $h');
        }
      case 'pwd':
        o(cwd);
        events.add('pwd');
      case 'whoami':
        o('student');
      case 'date':
        o(DateTime.now().toString().substring(0, 19));
      case 'clear':
        events.add('clear');
        return [const TermLine('\u0000clear', LineKind.info)];
      case 'history':
        for (var i = 0; i < history.length; i++) {
          o('${(i + 1).toString().padLeft(4)}  ${history[i]}');
        }
      case 'ls':
        final showAll = rest.contains('-a') || rest.contains('-la') || rest.contains('-al');
        final long = rest.contains('-l') || rest.contains('-la') || rest.contains('-al');
        final target = rest.where((a) => !a.startsWith('-')).firstOrNull ?? '.';
        final n = resolve(target);
        if (n == null) {
          err("ls: '$target' ga kirib bo'lmadi: Bunday fayl yoki papka yo'q");
        } else if (!n.isDir) {
          o(n.name);
        } else {
          final names = n.children.values.where((c) => showAll || !c.name.startsWith('.')).toList()..sort((a, b) => a.name.compareTo(b.name));
          if (names.isEmpty) {
            o(showAll ? '.  ..' : '(papka bo\'sh)', LineKind.info);
          } else if (long) {
            for (final c in names) {
              o('${c.isDir ? 'd' : '-'}rwxr-xr-x  student  ${c.isDir ? '-' : c.content.length.toString().padLeft(5)}  ${c.name}${c.isDir ? '/' : ''}');
            }
          } else {
            o(names.map((c) => c.isDir ? '${c.name}/' : c.name).join('   '));
          }
          events.add('ls');
        }
      case 'cd':
        final target = rest.isEmpty ? '~' : rest.first;
        final n = resolve(target);
        if (n == null) {
          err("cd: $target: Bunday papka yo'q");
          o("  Maslahat: avval 'ls' bilan mavjud papkalarni ko'ring.", LineKind.info);
        } else if (!n.isDir) {
          err('cd: $target: Bu papka emas, fayl');
        } else {
          cwd = normalize(target);
          events.add('cd');
        }
      case 'mkdir':
        if (rest.where((a) => !a.startsWith('-')).isEmpty) {
          err('mkdir: papka nomi kiritilmadi. Masalan: mkdir loyihalar');
        }
        final parents = rest.contains('-p');
        for (final name in rest.where((a) => !a.startsWith('-'))) {
          if (parents) {
            _mkdirs(normalize(name));
            events.add('mkdir');
            continue;
          }
          final (parent, base) = _parentOf(name);
          if (parent == null || !parent.isDir) {
            err("mkdir: '$name' yaratib bo'lmadi: ota papka mavjud emas (mkdir -p ishlating)");
          } else if (!_validName(base)) {
            err("mkdir: noto'g'ri nom: '$name'");
          } else if (parent.children.containsKey(base)) {
            err("mkdir: '$name' yaratib bo'lmadi: Bunday nom allaqachon bor");
          } else {
            parent.children[base] = VNode.dir(base);
            events.add('mkdir');
          }
        }
      case 'touch':
        if (rest.isEmpty) err('touch: fayl nomi kiritilmadi. Masalan: touch main.dart');
        for (final name in rest) {
          final (parent, base) = _parentOf(name);
          if (parent == null || !parent.isDir) {
            err("touch: '$name': ota papka mavjud emas");
          } else if (!_validName(base)) {
            err("touch: noto'g'ri nom: '$name'");
          } else {
            parent.children.putIfAbsent(base, () => VNode.file(base));
            events.add('touch');
          }
        }
      case 'cat':
        if (rest.isEmpty) err('cat: fayl nomi kiritilmadi');
        for (final name in rest) {
          final n = resolve(name);
          if (n == null) {
            err("cat: $name: Bunday fayl yo'q");
          } else if (n.isDir) {
            err('cat: $name: Bu papka');
          } else {
            final c = n.content.endsWith('\n') ? n.content.substring(0, n.content.length - 1) : n.content;
            if (c.isNotEmpty) o(c);
            events.add('cat');
            if (n.content.isNotEmpty) events.add('cat_content');
          }
        }
      case 'echo':
        final text = rest.join(' ');
        if (redirect != null) {
          final (parent, base) = _parentOf(redirect);
          if (parent == null || !parent.isDir || !_validName(base)) {
            err("bash: $redirect: Bunday papka yo'q");
          } else {
            final f = parent.children[base];
            if (f != null && f.isDir) {
              err('bash: $redirect: Bu papka');
            } else {
              final node = parent.children.putIfAbsent(base, () => VNode.file(base));
              node.content = append ? '${node.content}$text\n' : '$text\n';
              events.add('echo_file');
            }
          }
          return [...out, ...result];
        }
        o(text);
      case 'rm':
        final recursive = rest.contains('-r') || rest.contains('-rf') || rest.contains('-fr');
        final targets = rest.where((a) => !a.startsWith('-')).toList();
        if (targets.isEmpty) err('rm: nima o\'chirilishi ko\'rsatilmadi');
        for (final t in targets) {
          final abs = normalize(t);
          if (abs == '/' || abs == home || home.startsWith('$abs/')) {
            err("rm: '$t' ni o'chirish xavfli — bu himoyalangan papka. Haqiqiy kompyuterda bu katta zarar keltirishi mumkin!");
            continue;
          }
          final (parent, base) = _parentOf(t);
          final n = parent?.children[base];
          if (n == null) {
            err("rm: '$t' o'chirib bo'lmadi: Bunday fayl yoki papka yo'q");
          } else if (n.isDir && !recursive) {
            err("rm: '$t' — bu papka. Papkani o'chirish uchun: rm -r $t");
          } else {
            parent!.children.remove(base);
            if (normalize(cwd).startsWith(abs)) cwd = normalize('$abs/..');
            events.add('rm');
          }
        }
      case 'rmdir':
        for (final t in rest) {
          final (parent, base) = _parentOf(t);
          final n = parent?.children[base];
          if (n == null || !n.isDir) {
            err("rmdir: '$t': papka topilmadi");
          } else if (n.children.isNotEmpty) {
            err("rmdir: '$t': papka bo'sh emas");
          } else {
            parent!.children.remove(base);
          }
        }
      case 'cp':
      case 'mv':
        if (rest.where((a) => !a.startsWith('-')).length < 2) {
          err('$cmd: ikkita yo\'l kerak: $cmd <manba> <manzil>');
          break;
        }
        final paths = rest.where((a) => !a.startsWith('-')).toList();
        final src = resolve(paths[0]);
        if (src == null) {
          err("$cmd: '${paths[0]}': Bunday fayl yo'q");
          break;
        }
        if (src.isDir && cmd == 'cp' && !rest.contains('-r')) {
          err("cp: '${paths[0]}' — papka. Nusxalash uchun: cp -r");
          break;
        }
        var dest = resolve(paths[1]);
        VNode? destParent;
        String destName;
        if (dest != null && dest.isDir) {
          destParent = dest;
          destName = src.name;
        } else {
          final (p, b) = _parentOf(paths[1]);
          destParent = p;
          destName = b;
        }
        if (destParent == null || !destParent.isDir) {
          err("$cmd: '${paths[1]}': manzil papka mavjud emas");
          break;
        }
        final copy = src.clone()..name = destName;
        destParent.children[destName] = copy;
        if (cmd == 'mv') {
          final (sp, sb) = _parentOf(paths[0]);
          sp?.children.remove(sb);
        }
        events.add(cmd);
      case 'tree':
        final start = resolve(rest.isEmpty ? '.' : rest.first);
        if (start == null || !start.isDir) {
          err("tree: papka topilmadi");
          break;
        }
        o(rest.isEmpty ? '.' : rest.first);
        void walk(VNode n, String prefix) {
          final kids = n.children.values.where((c) => !c.name.startsWith('.')).toList()..sort((a, b) => a.name.compareTo(b.name));
          for (var i = 0; i < kids.length; i++) {
            final last = i == kids.length - 1;
            o('$prefix${last ? '└── ' : '├── '}${kids[i].name}${kids[i].isDir ? '/' : ''}');
            if (kids[i].isDir) walk(kids[i], '$prefix${last ? '    ' : '│   '}');
          }
        }
        walk(start, '');
        events.add('tree');
      case 'nano':
      case 'edit':
      case 'code':
        if (rest.isEmpty) {
          err('$cmd: fayl nomi kiritilmadi');
        } else {
          return [...out, TermLine('\u0000edit ${normalize(rest.first)}', LineKind.info)];
        }
      case 'dart':
        _dart(rest, o, err);
      case 'flutter':
        _flutter(rest, o, err);
      case 'git':
        _git(rest, o, err);
      case 'sudo':
        err('sudo: bu o\'quv terminali — administrator huquqlari kerak emas va berilmaydi.');
      default:
        err('$cmd: buyruq topilmadi');
        final sug = _suggest(cmd);
        o(sug == null ? "  'help' yozib, mavjud buyruqlarni ko'ring." : "  Ehtimol '$sug' demoqchimisiz?", LineKind.info);
    }

    if (redirect != null && cmd != 'echo') {
      final (parent, base) = _parentOf(redirect);
      if (parent != null && parent.isDir && _validName(base)) {
        final node = parent.children.putIfAbsent(base, () => VNode.file(base));
        final text = result.where((l) => l.kind == LineKind.output).map((l) => l.text).join('\n');
        node.content = append ? '${node.content}$text\n' : '$text\n';
        return [...out, ...result.where((l) => l.kind == LineKind.error)];
      }
    }
    return [...out, ...result];
  }

  String? _suggest(String cmd) {
    const all = ['pwd', 'ls', 'cd', 'mkdir', 'touch', 'cat', 'echo', 'rm', 'clear', 'help', 'tree', 'dart', 'flutter', 'git', 'history', 'cp', 'mv'];
    for (final c in all) {
      if (c.startsWith(cmd) || cmd.startsWith(c) || (cmd.length >= 2 && _dist(c, cmd) <= 1)) return c;
    }
    return null;
  }

  int _dist(String a, String b) {
    if ((a.length - b.length).abs() > 1) return 9;
    var diff = 0;
    for (var i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) diff++;
    }
    return diff + (a.length - b.length).abs();
  }

  void _dart(List<String> a, void Function(String, [LineKind]) o, void Function(String) err) {
    if (a.isEmpty || a.first == '--help') {
      o('Foydalanish: dart <buyruq>  (--version, create, run)');
      return;
    }
    switch (a.first) {
      case '--version':
        o('Dart SDK version: 3.13.5 (stable) on "kitob_sandbox"');
        events.add('dart_version');
      case 'create':
        if (a.length < 2) {
          err('dart create: loyiha nomi kerak. Masalan: dart create hello');
          return;
        }
        final name = a[1];
        if (!RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name)) {
          err("dart create: '$name' — noto'g'ri nom. Faqat kichik harf, raqam va _ (masalan: my_app)");
          return;
        }
        final dir = _mkdirs(normalize(name));
        _mkdirs(normalize('$name/bin'));
        _mkdirs(normalize('$name/test'));
        resolve('$name/bin')!.children['$name.dart'] = VNode.file('$name.dart', "void main(List<String> arguments) {\n  print('Hello world: \${6 * 7}!');\n}\n");
        dir.children['pubspec.yaml'] = VNode.file('pubspec.yaml', 'name: $name\nenvironment:\n  sdk: ^3.13.0\n');
        dir.children['README.md'] = VNode.file('README.md', '# $name\n');
        o('Creating $name using template console...', LineKind.info);
        o('  $name/bin/$name.dart\n  $name/pubspec.yaml\n  $name/test/');
        o("Tayyor! Endi: cd $name  va  dart run", LineKind.success);
        events.add('dart_create');
      case 'run':
        String? path;
        if (a.length >= 2) {
          path = a[1];
        } else {
          final pub = resolve('pubspec.yaml');
          if (pub != null) {
            final name = RegExp(r'name:\s*(\w+)').firstMatch(pub.content)?.group(1);
            if (name != null && resolve('bin/$name.dart') != null) path = 'bin/$name.dart';
          }
        }
        if (path == null) {
          err("dart run: bajariladigan fayl topilmadi. 'dart run fayl.dart' yozing yoki loyiha papkasiga kiring.");
          return;
        }
        final f = resolve(path);
        if (f == null || f.isDir) {
          err("dart run: '$path' fayli topilmadi");
          return;
        }
        final r = KitobDart.run(f.content);
        if (!r.compiled) {
          for (final d in r.diagnostics.where((d) => d.isError)) {
            err('$path:${d.line}:${d.column}: Error: ${d.original}');
            o('  ${d.message}', LineKind.info);
          }
          return;
        }
        for (final line in r.lines) {
          o(line);
        }
        if (r.error != null) {
          err(r.error!.message);
          o('  ${r.error!.explanation}', LineKind.info);
        } else {
          events.add('dart_run');
        }
      case 'analyze':
        final f = resolve(a.length >= 2 ? a[1] : 'bin');
        if (f == null) {
          err('dart analyze: fayl topilmadi');
          return;
        }
        final files = <(String, VNode)>[];
        void collect(VNode n, String p) {
          if (n.isDir) {
            for (final c in n.children.values) {
              collect(c, '$p/${c.name}');
            }
          } else if (n.name.endsWith('.dart')) {
            files.add((p, n));
          }
        }
        collect(f, a.length >= 2 ? a[1] : 'bin');
        var issues = 0;
        for (final (p, n) in files) {
          for (final d in KitobDart.analyze(n.content)) {
            issues++;
            o('  ${d.isError ? 'error' : 'warning'} • ${d.original} • $p:${d.line}:${d.column}', d.isError ? LineKind.error : LineKind.info);
          }
        }
        o(issues == 0 ? 'No issues found!' : '$issues issue(s) found.', issues == 0 ? LineKind.success : LineKind.error);
        events.add('dart_analyze');
      default:
        err("dart: '${a.first}' buyrug'i bu o'quv terminalida yo'q. Mavjud: --version, create, run, analyze");
    }
  }

  void _flutter(List<String> a, void Function(String, [LineKind]) o, void Function(String) err) {
    const sim = '(o\'quv simulyatsiyasi — haqiqiy kompyuteringizda shunga o\'xshash natija chiqadi)';
    if (a.isEmpty) {
      o('Foydalanish: flutter <buyruq>  (--version, doctor, create, pub get, analyze, test, run, build)');
      return;
    }
    switch (a.first) {
      case '--version':
        o('Flutter 3.47.7 • channel stable • https://github.com/flutter/flutter.git');
        o('Framework • revision abaf9c5237');
        o('Tools • Dart 3.13.5 • DevTools 2.60.0');
        events.add('flutter_version');
      case 'doctor':
        o('Doctor summary (to see all details, run flutter doctor -v):');
        o('[✓] Flutter (Channel stable, 3.47.7)', LineKind.success);
        o('[✓] Android toolchain - develop for Android devices', LineKind.success);
        o('[✓] Xcode - develop for iOS and macOS', LineKind.success);
        o('[✓] Chrome - develop for the web', LineKind.success);
        o('[✓] VS Code', LineKind.success);
        o('• No issues found!', LineKind.success);
        o(sim, LineKind.info);
        o("Haqiqiy kompyuterda [✗] chiqsa — o'sha qatordagi ko'rsatmani bajaring (masalan, Android SDK o'rnatish).", LineKind.info);
        events.add('flutter_doctor');
      case 'create':
        if (a.length < 2) {
          err('flutter create: loyiha nomi kerak. Masalan: flutter create my_app');
          return;
        }
        final name = a[1];
        if (!RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name)) {
          err("\"$name\" is not a valid Dart package name. Faqat kichik harf, raqam va _ ishlating (my_app).");
          return;
        }
        final dir = _mkdirs(normalize(name));
        for (final sub in ['lib', 'test', 'android', 'ios', 'web', 'assets']) {
          _mkdirs(normalize('$name/$sub'));
        }
        resolve('$name/lib')!.children['main.dart'] = VNode.file('main.dart', _flutterMain);
        resolve('$name/test')!.children['widget_test.dart'] = VNode.file('widget_test.dart', "// Widget testlari shu yerda yoziladi\n");
        dir.children['pubspec.yaml'] = VNode.file('pubspec.yaml', 'name: $name\ndescription: "A new Flutter project."\nversion: 1.0.0+1\n\nenvironment:\n  sdk: ^3.13.5\n\ndependencies:\n  flutter:\n    sdk: flutter\n\nflutter:\n  uses-material-design: true\n');
        dir.children['analysis_options.yaml'] = VNode.file('analysis_options.yaml', 'include: package:flutter_lints/flutter.yaml\n');
        o('Creating project $name...', LineKind.info);
        o('  $name/lib/main.dart\n  $name/pubspec.yaml\n  $name/android/  $name/ios/  $name/web/');
        o('All done! Ilovani ishga tushirish uchun:', LineKind.success);
        o('  \$ cd $name\n  \$ flutter run');
        o(sim, LineKind.info);
        events.add('flutter_create');
      case 'pub':
        if (a.length >= 2 && a[1] == 'get') {
          if (resolve('pubspec.yaml') == null) {
            err('Expected to find project root in current working directory. (pubspec.yaml topilmadi — loyiha papkasiga kiring)');
            return;
          }
          o('Resolving dependencies...');
          o('Got dependencies!', LineKind.success);
          o(sim, LineKind.info);
          events.add('pub_get');
        } else {
          o('Foydalanish: flutter pub get | flutter pub add <paket>');
        }
      case 'run' || 'analyze' || 'test' || 'build':
        if (resolve('pubspec.yaml') == null) {
          err('Error: No pubspec.yaml file found. Bu buyruq Flutter loyiha papkasi ichida ishga tushiriladi (cd my_app).');
          return;
        }
        switch (a.first) {
          case 'run':
            o('Launching lib/main.dart on Chrome in debug mode...');
            o('Flutter run key commands: r — Hot reload 🔥, R — Hot restart, q — Quit');
          case 'analyze':
            o('Analyzing project...');
            o('No issues found! (ran in 1.2s)', LineKind.success);
          case 'test':
            o('00:02 +1: All tests passed!', LineKind.success);
          case 'build':
            final target = a.length >= 2 ? a[1] : 'apk';
            o('Building $target in release mode...');
            o('✓ Built build/${target == 'web' ? 'web' : 'app/outputs/flutter-apk/app-release.apk'}', LineKind.success);
        }
        o(sim, LineKind.info);
        events.add('flutter_${a.first}');
      default:
        err("flutter: '${a.first}' buyrug'i bu o'quv terminalida yo'q.");
    }
  }

  void _git(List<String> a, void Function(String, [LineKind]) o, void Function(String) err) {
    if (a.isEmpty) {
      o('Foydalanish: git init | status | add <fayl> | commit -m "xabar" | log');
      return;
    }
    switch (a.first) {
      case 'init':
        final dir = resolve('.')!;
        dir.children['.git'] = VNode.dir('.git');
        gitRepo = cwd;
        gitStaged.clear();
        o('Initialized empty Git repository in $cwd/.git/', LineKind.success);
        events.add('git_init');
      case 'status':
        if (gitRepo == null || !cwd.startsWith(gitRepo!)) {
          err('fatal: not a git repository. Avval "git init" qiling.');
          return;
        }
        o('On branch main');
        final files = resolve(gitRepo!)!.children.values.where((c) => !c.name.startsWith('.')).map((c) => c.name).toList();
        final untracked = files.where((f) => !gitStaged.contains(f)).toList();
        if (gitStaged.isNotEmpty) {
          o('Changes to be committed:');
          for (final f in gitStaged) {
            o('        new file:   $f', LineKind.success);
          }
        }
        if (untracked.isNotEmpty) {
          o('Untracked files:');
          for (final f in untracked) {
            o('        $f', LineKind.error);
          }
        }
        if (gitStaged.isEmpty && untracked.isEmpty) o('nothing to commit, working tree clean');
        events.add('git_status');
      case 'add':
        if (gitRepo == null) {
          err('fatal: not a git repository');
          return;
        }
        if (a.length < 2) {
          err('Nothing specified, nothing added. Masalan: git add .  yoki  git add main.dart');
          return;
        }
        final repo = resolve(gitRepo!)!;
        if (a[1] == '.') {
          gitStaged.addAll(repo.children.keys.where((k) => !k.startsWith('.')));
        } else if (repo.children.containsKey(a[1])) {
          gitStaged.add(a[1]);
        } else {
          err("fatal: pathspec '${a[1]}' did not match any files");
          return;
        }
        events.add('git_add');
      case 'commit':
        if (gitRepo == null) {
          err('fatal: not a git repository');
          return;
        }
        final mi = a.indexOf('-m');
        if (mi < 0 || mi + 1 >= a.length) {
          err('Commit xabari kerak: git commit -m "birinchi commit"');
          return;
        }
        if (gitStaged.isEmpty) {
          err('nothing added to commit (avval git add)');
          return;
        }
        gitCommits++;
        o('[main ${(gitCommits * 7919).toRadixString(16).padLeft(7, 'a')}] ${a[mi + 1]}', LineKind.success);
        o(' ${gitStaged.length} file(s) changed');
        gitStaged.clear();
        events.add('git_commit');
      case 'log':
        if (gitCommits == 0) {
          o('Hali commit yo\'q.');
        } else {
          for (var i = gitCommits; i >= 1; i--) {
            o('commit ${(i * 7919).toRadixString(16).padLeft(7, 'a')}  (${i == gitCommits ? 'HEAD -> main' : ''})');
          }
        }
      default:
        err("git: '${a.first}' — bu o'quv terminalida qo'llab-quvvatlanmaydi");
    }
  }

  /// Tab bilan to'ldirish: buyruq yoki yo'l.
  String complete(String line) {
    final parts = line.split(' ');
    final last = parts.last;
    if (parts.length == 1) {
      const cmds = ['pwd', 'ls', 'cd', 'mkdir', 'touch', 'cat', 'echo', 'rm', 'clear', 'help', 'tree', 'dart', 'flutter', 'git', 'history'];
      final m = cmds.where((c) => c.startsWith(last)).toList();
      return m.length == 1 ? '${m.first} ' : line;
    }
    final slash = last.lastIndexOf('/');
    final dirPart = slash >= 0 ? last.substring(0, slash + 1) : '';
    final prefix = slash >= 0 ? last.substring(slash + 1) : last;
    final dir = resolve(dirPart.isEmpty ? '.' : dirPart);
    if (dir == null || !dir.isDir) return line;
    final m = dir.children.values.where((c) => c.name.startsWith(prefix)).toList();
    if (m.length != 1) return line;
    parts[parts.length - 1] = '$dirPart${m.first.name}${m.first.isDir ? '/' : ''}';
    return parts.join(' ');
  }
}

const _flutterMain = r'''import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Salom, Flutter!')),
      ),
    );
  }
}
''';

class Mission {
  const Mission(this.id, this.title, this.task, this.hint, this.test);
  final String id;
  final String title;
  final String task;
  final String hint;
  final bool Function(VirtualShell s) test;
}

final terminalMissions = <Mission>[
  Mission('m1', 'Qayerdaman?', 'Hozirgi papkangizni bilib oling.', 'pwd', (s) => s.events.contains('pwd')),
  Mission('m2', 'Atrofga qarash', 'Uy papkangizdagi fayllarni ko\'ring.', 'ls', (s) => s.events.contains('ls')),
  Mission('m3', 'Papka yaratish', '`loyihalar` nomli papka yarating.', 'mkdir loyihalar', (s) => s.resolve('$home/loyihalar')?.isDir == true),
  Mission('m4', 'Papkaga kirish', '`loyihalar` papkasiga kiring.', 'cd loyihalar', (s) => s.cwd == '$home/loyihalar'),
  Mission('m5', 'Fayl yaratish', '`loyihalar` ichida `eslatma.txt` faylini yarating.', 'touch eslatma.txt', (s) => s.resolve('$home/loyihalar/eslatma.txt') != null),
  Mission('m6', 'Faylga yozish', '`eslatma.txt` ga "Flutter o\'rganaman" matnini yozing va `cat` bilan o\'qing.', "echo \"Flutter o'rganaman\" > eslatma.txt", (s) => (s.resolve('$home/loyihalar/eslatma.txt')?.content ?? '').trim().isNotEmpty && s.events.contains('cat_content')),
  Mission('m7', 'Orqaga qaytish', 'Bir papka yuqoriga chiqing (uy papkasiga).', 'cd ..', (s) => s.events.contains('cd') && s.cwd == home && s.resolve('$home/loyihalar') != null),
  Mission('m8', 'Dart dasturini ishga tushirish', 'Uy papkasidagi `salom.dart` faylini bajaring.', 'dart run salom.dart', (s) => s.events.contains('dart_run')),
  Mission('m9', 'Dart loyihasi', '`hello` nomli Dart loyihasini yarating, ichiga kiring va `dart run` qiling.', 'dart create hello', (s) => s.events.contains('dart_create') && s.events.contains('dart_run') && s.cwd.endsWith('/hello')),
  Mission('m10', 'Flutter tekshiruvi', 'Flutter versiyasini va `flutter doctor` natijasini ko\'ring.', 'flutter doctor', (s) => s.events.contains('flutter_version') && s.events.contains('flutter_doctor')),
  Mission('m11', 'Flutter loyihasi', '`my_app` Flutter loyihasini yarating va unda `flutter pub get` bajaring.', 'flutter create my_app', (s) => s.events.contains('flutter_create') && s.events.contains('pub_get')),
  Mission('m12', 'Git bilan saqlash', 'Loyiha papkasida: `git init`, `git add .`, `git commit -m "birinchi"`.', 'git init', (s) => s.events.contains('git_commit')),
];
