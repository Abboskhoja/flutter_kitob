import '../../content/model.dart';
import 'vfs.dart';

String _abs(String path) => path == '~' ? home : (path.startsWith('~/') ? '$home${path.substring(1)}' : path);

VNode? _file(VirtualShell s, String path) {
  final n = s.resolve(_abs(path));
  return n != null && !n.isDir ? n : null;
}

/// Terminal vazifasi tekshiruvi: virtual fayl tizimining haqiqiy holatiga qaraydi.
bool shellCheckPasses(VirtualShell s, ShellCheck c) => switch (c) {
  DirExists() => s.resolve(_abs(c.path))?.isDir == true,
  FileExists() => _file(s, c.path) != null,
  FileContains() => _file(s, c.path)?.content.toLowerCase().contains(c.text.toLowerCase()) ?? false,
  CwdIs() => s.cwd == _abs(c.path),
  ShellEvent() => s.events.contains(c.event),
  GitCommits() => s.gitCommits >= c.min,
};

bool terminalTaskPasses(VirtualShell s, TerminalTask t) => t.checks.every((c) => shellCheckPasses(s, c));
