import 'package:flutter/material.dart';
import 'package:flutter_kitob/src/app/app.dart';
import 'package:flutter_kitob/src/app/router.dart';
import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/content/model.dart';
import 'package:flutter_kitob/src/core/design_system/rich_text.dart';
import 'package:flutter_kitob/src/core/state/progress.dart';
import 'package:flutter_kitob/src/core/storage/store.dart';
import 'package:flutter_kitob/src/features/code/code_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Haqiqiy qurilmada (macOS/iOS/Android/Chrome) to'liq o'quv siklini bosib o'tadi.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder textAnywhere(String s) => find.byWidgetPredicate(skipOffstage: false, (w) {
    if (w is Text) return (w.data ?? w.textSpan?.toPlainText() ?? '').contains(s);
    if (w is SelectableText) return (w.data ?? '').contains(s);
    if (w is RichText) return w.text.toPlainText().contains(s);
    return false;
  });

  Future<void> pumpUntil(WidgetTester t, Finder f, {int seconds = 20, String? why}) async {
    for (var i = 0; i < seconds * 10; i++) {
      await t.pump(const Duration(milliseconds: 100));
      if (f.evaluate().isNotEmpty) return;
    }
    final all = find.byWidgetPredicate(skipOffstage: false, (w) => w is Text || w is SelectableText).evaluate().map((e) {
      final w = e.widget;
      return w is Text ? (w.data ?? w.textSpan?.toPlainText() ?? '') : (w as SelectableText).data ?? '';
    }).where((x) => x.length > 3).take(60).join(' | ');
    // ignore: avoid_print
    print('EKRANDA: $all');
    fail('Kutilgan element chiqmadi: ${why ?? f}');
  }

  Future<void> tapText(WidgetTester t, String label) async {
    final f = find.text(label.uz).first;
    await t.ensureVisible(f);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(f, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<void> setCode(WidgetTester t, String code) async {
    final field = t.widget<TextField>(find.descendant(of: find.byType(KitobCodeEditor, skipOffstage: false).first, matching: find.byType(TextField), skipOffstage: false));
    field.controller!.text = code;
    await t.pump(const Duration(milliseconds: 600));
  }

  testWidgets('Vertikal slays: O\'zgaruvchilar darsi boshidan oxirigacha', (t) async {
    SharedPreferences.setMockInitialValues({
      'kitob.v1.settings': '{"onboardingDone":true,"userName":"Test","launchCount":2,"reduceMotion":true,"startLevel":"littleCode"}',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    await t.pumpWidget(UncontrolledProviderScope(container: container, child: const KitobApp()));
    await pumpUntil(t, textAnywhere('Bugun nimani'), why: 'bosh sahifa');

    // 1–3. Dart kursi → O'zgaruvchilar darsi
    container.read(routerProvider).go('/learn/level/3');
    await pumpUntil(t, textAnywhere('O‘zgaruvchilar'));
    final row = textAnywhere('4. O‘zgaruvchilar').first;
    await t.ensureVisible(row);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(row);
    await pumpUntil(t, textAnywhere('Bu darsda o‘rganasiz'), why: 'dars sahifasi');

    // 4. Ta'rif
    await tapText(t, 'Davom etish');
    await pumpUntil(t, textAnywhere('Oddiy tushuntirish'));
    // 5–6. Animatsiya va kod tahlili
    await tapText(t, 'Davom etish');
    await pumpUntil(t, textAnywhere('Interaktiv animatsiya'));
    expect(textAnywhere('int yosh = 18;'), findsWidgets);

    // 8–9. Ishga tushirish — haqiqiy natija
    await tapText(t, 'Ishga tushirish');
    await pumpUntil(t, find.byWidgetPredicate(skipOffstage: false, (w) => w is SelectableText && w.data == '18'), why: 'konsolda 18');

    // 7. Kodni o'zgartirish: yosh = 25 → natija 25
    await tapText(t, 'Tahrirlash');
    await t.pump(const Duration(milliseconds: 500));
    await setCode(t, 'void main() {\n  int yosh = 25;\n  print(yosh);\n}');
    await t.pump(const Duration(milliseconds: 600));
    await tapText(t, 'Ishga tushirish');
    await pumpUntil(t, find.byWidgetPredicate(skipOffstage: false, (w) => w is SelectableText && w.data == '25'), why: 'o\'zgartirilgan kod natijasi 25');

    // Qadam-baqadam vizualizator (haqiqiy trace)
    await tapText(t, 'Qadam-baqadam');
    await pumpUntil(t, textAnywhere('Dastur ishga tushdi'), why: 'vizualizator 1-qadam');
    await t.tap(find.byTooltip('Keyingi qadam'));
    await pumpUntil(t, textAnywhere('nomli o‘zgaruvchi yaratildi'), why: 'yosh e\'lon qilindi qadami');
    await t.tap(find.byType(CloseButton).first);
    await t.pump(const Duration(milliseconds: 600));

    // 10. Xatoli kodni tuzatish
    await tapText(t, 'Davom etish');
    await pumpUntil(t, textAnywhere('Xatoli kodni tuzating'));
    final lesson = lessonById['l1_variables']!;
    await setCode(t, lesson.buggy!.fixed);
    await t.pump(const Duration(milliseconds: 500));
    await tapText(t, 'Tekshirish');
    await pumpUntil(t, textAnywhere('Xato tuzatildi'), why: 'bug fix qabul qilindi');

    // 12–13. Mustaqil vazifa — test runner tekshiradi (avval noto'g'ri, keyin to'g'ri)
    await tapText(t, 'Davom etish');
    await pumpUntil(t, textAnywhere('Mustaqil vazifa'));
    await setCode(t, "void main() {\n  print('25');\n  print('30');\n}");
    await t.pump(const Duration(milliseconds: 500));
    await tapText(t, 'Tekshirish');
    await pumpUntil(t, textAnywhere('test o‘tdi'), why: 'qisman o\'tgan natija');
    expect(textAnywhere('Barcha testlardan'), findsNothing, reason: 'qattiq yozilgan natija qabul qilinmasligi kerak');
    await setCode(t, lesson.task!.solution);
    await t.pump(const Duration(milliseconds: 500));
    await tapText(t, 'Tekshirish');
    await pumpUntil(t, textAnywhere('Barcha testlardan'), why: 'to\'g\'ri yechim qabul qilindi');

    // 11. Mini test — UI orqali javob beriladi
    await tapText(t, 'Davom etish');
    await pumpUntil(t, textAnywhere('Savol 1 /'));
    for (final q in lesson.quiz) {
      switch (q) {
        case SingleChoice():
          await t.tap(find.text(q.options[q.correct].uz, findRichText: true).last);
        case MultiChoice():
          for (final i in q.correct) {
            final f = find.text(q.options[i].uz, findRichText: true).last;
            await t.ensureVisible(f);
            await t.tap(f);
            await t.pump(const Duration(milliseconds: 150));
          }
        case PredictOutput():
          final correct = q.options!.firstWhere((o) => o == '20');
          final f = find.text(correct).last;
          await t.ensureVisible(f);
          await t.tap(f);
        case FillBlank():
          await t.enterText(find.byType(TextField).last, '7');
        default:
          fail('Kutilmagan savol turi');
      }
      await t.pump(const Duration(milliseconds: 300));
      await tapText(t, 'Tekshirish');
      await pumpUntil(t, textAnywhere('To‘g‘ri!'), why: 'savol to\'g\'ri baholandi: ${q.prompt}');
      final last = q == lesson.quiz.last;
      await tapText(t, last ? 'Natijani ko\'rish' : 'Keyingi savol');
    }
    await pumpUntil(t, textAnywhere('100%'), why: 'test natijasi');

    // 14–15. Progress saqlandi va keyingi mavzu ochildi
    final progress = container.read(progressProvider);
    expect(progress.isCompleted('l1_variables'), isTrue);
    expect(progress.of('l1_variables').taskSolved, isTrue);
    expect(progress.of('l1_variables').bugFixed, isTrue);
    expect(progress.of('l1_variables').bestQuiz, 100);
    expect(progress.xp, greaterThan(0));
    expect(container.read(progressProvider.notifier).statusOf('l1_var_final_const'), isNot(LessonStatus.locked));
    expect(prefs.getString('kitob.v1.progress'), contains('l1_variables'));
  });

  testWidgets('Playground va terminal haqiqiy ishlaydi', (t) async {
    SharedPreferences.setMockInitialValues({'kitob.v1.settings': '{"onboardingDone":true,"launchCount":2,"reduceMotion":true}'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    await t.pumpWidget(UncontrolledProviderScope(container: container, child: const KitobApp()));
    await pumpUntil(t, textAnywhere('Bugun nimani'));

    container.read(routerProvider).go('/practice/playground');
    await pumpUntil(t, find.byType(KitobCodeEditor));
    await setCode(t, "void main() {\n  var s = 0;\n  for (var i = 1; i <= 100; i++) {\n    s += i;\n  }\n  print('Yig\\'indi: \$s');\n}");
    await t.pump(const Duration(milliseconds: 800));
    final run = find.ancestor(of: find.byIcon(Icons.play_arrow_rounded), matching: find.byType(FilledButton)).first;
    await t.tap(run);
    await pumpUntil(t, find.byWidgetPredicate(skipOffstage: false, (w) => w is SelectableText && (w.data ?? '').contains("Yig'indi: 5050")), why: 'playground natijasi');

    // Cheksiz sikl to'xtatiladi
    if (find.text('Kod').evaluate().isNotEmpty) {
      await t.tap(find.text('Kod').first);
      await t.pump(const Duration(milliseconds: 400));
    }
    await setCode(t, 'void main() {\n  while (true) {}\n}');
    await t.pump(const Duration(milliseconds: 800));
    await t.tap(run);
    await pumpUntil(t, textAnywhere('juda uzoq ishladi'), seconds: 15, why: 'cheksiz sikl himoyasi');

    container.read(routerProvider).go('/practice/terminal');
    await pumpUntil(t, textAnywhere('o‘quv terminali'));
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    Future<void> cmd(String c) async {
      final field = t.widget<TextField>(find.byType(TextField).last);
      field.onSubmitted!(c);
      await t.pump(const Duration(milliseconds: 300));
    }

    for (final c in ['mkdir loyihalar', 'cd loyihalar', 'pwd']) {
      await cmd(c);
    }
    await pumpUntil(t, textAnywhere('/home/student/loyihalar'), why: 'pwd natijasi');
    await cmd('cd ..');
    await cmd('ls');
    await pumpUntil(t, textAnywhere('loyihalar/'), why: 'ls yangi papkani ko\'rsatadi');
    await cmd('dart run salom.dart');
    await pumpUntil(t, textAnywhere('Salom, terminal!'), why: 'dart run haqiqatan bajardi');
  });
}
