import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/content/model.dart';
import 'package:flutter_kitob/src/core/runner/grader.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter vazifalarini baholash — `dart:io` siz, shuning uchun web (Chrome) da ham ishlaydi:
/// `flutter test --platform chrome test/flutter_grading_test.dart`
void main() {
  for (final l in allLessons.where((l) => l.task?.preview ?? false)) {
    test('${l.id}: yechim o\'tadi, boshlang\'ich kod o\'tmaydi', () {
      final t = l.task!;
      final ok = gradeTask(t, t.solution);
      expect(ok.passed, isTrue, reason: [for (final r in ok.results.where((r) => !r.passed)) '${r.title}: ${r.detail} ${r.actual}'].join('\n'));
      expect(gradeTask(t, t.starter).passed, isFalse);
    });
  }

  // Asinxron tugma: `onPressed: () async { await ...; setState(...); }` — baholovchi
  // kutilayotgan Future'larni (virtual vaqtda) tugatib, keyin ekranni tekshiradi.
  const asyncApp = r'''
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Yuklovchi()));

class Yuklovchi extends StatefulWidget {
  const Yuklovchi({super.key});
  @override
  State<Yuklovchi> createState() => _YuklovchiState();
}

class _YuklovchiState extends State<Yuklovchi> {
  String _holat = 'Bosing';

  Future<String> _serverdan() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'Ma\'lumot keldi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(_holat)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() => _holat = 'Yuklanmoqda...');
          final javob = await _serverdan();
          setState(() => _holat = javob);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';

  test('async onPressed: Future tugagach setState natijasi baholanadi', () {
    const task = CodeTask(
      title: 't',
      instructions: 'i',
      starter: '',
      solution: asyncApp,
      hints: ['h'],
      preview: true,
      checks: [WidgetExists('Text', text: 'Bosing'), AfterTap('refresh', "Ma'lumot keldi")],
    );
    final r = gradeTask(task, asyncApp);
    expect(r.passed, isTrue, reason: [for (final x in r.results.where((x) => !x.passed)) '${x.title}: ${x.detail} ${x.actual}'].join('\n'));
  });
}
