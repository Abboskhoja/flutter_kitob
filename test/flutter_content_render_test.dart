import 'package:flutter/material.dart';
import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/content/model.dart';
import 'package:flutter_kitob/src/core/design_system/theme.dart';
import 'package:flutter_kitob/src/features/flutter_preview/preview_view.dart';
import 'package:flutter_kitob/src/features/playground/playground_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Har bir Flutter kod namunasi (namuna, tuzatilgan variant, yechim) haqiqiy
/// Flutter renderida xatosiz chizilishi kerak: layout xatosi, noma'lum parametr yo'q.
void main() {
  final samples = <(String, String)>[];
  for (final l in allLessons) {
    for (final c in [?l.example, ...l.examples, ...l.extra.whereType<CodeBlock>()]) {
      if (c.preview) samples.add(('${l.id} / ${c.title ?? 'namuna'}', c.code));
    }
    if (l.buggy?.preview ?? false) samples.add(('${l.id} / tuzatilgan', l.buggy!.fixed));
    if (l.task?.preview ?? false) samples.add(('${l.id} / yechim', l.task!.solution));
  }
  for (final e in playgroundSamples.entries) {
    if (e.value.contains('package:flutter/')) samples.add(('playground / ${e.key}', e.value));
  }

  test('Flutter namunalari bor', () => expect(samples.length, greaterThanOrEqualTo(8)));

  for (final (name, code) in samples) {
    testWidgets('chiziladi: $name', (tester) async {
      tester.view.physicalSize = const Size(420 * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: KitobTheme.light(),
        home: Scaffold(body: SingleChildScrollView(child: Center(child: FlutterPreview(source: code)))),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Widget xatosi'), findsNothing, reason: 'preview xato ko\'rsatdi');
      expect(find.textContaining('Xato', findRichText: true), findsNothing);
      final ex = tester.takeException();
      if (ex != null) debugPrint((ex as FlutterError).toStringDeep());
      expect(ex, isNull);
    });
  }
}
