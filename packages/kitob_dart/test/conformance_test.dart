import 'dart:io';

import 'package:kitob_dart/kitob_dart.dart';
import 'package:test/test.dart';

/// Har bir dastur haqiqiy Dart VM'da bajarilgan (`tool/update_goldens.sh`)
/// va natijasi `.expected` faylga yozilgan. Interpretator aynan shu natijani
/// berishi shart.
void main() {
  final dir = Directory('test/conformance');
  final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in files) {
    test(f.uri.pathSegments.last, () {
      final src = f.readAsStringSync();
      final expected = File(f.path.replaceAll('.dart', '.expected')).readAsStringSync();
      final r = KitobDart.run(src);
      final errors = r.diagnostics.where((d) => d.isError).toList();
      expect(errors, isEmpty, reason: errors.join('\n'));
      expect(r.error, isNull, reason: '${r.error?.message}\n${r.error?.explanation} @${r.error?.line}');
      expect(r.stdout, expected);
    });
  }
}
