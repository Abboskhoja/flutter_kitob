import 'package:flutter/material.dart';
import 'package:flutter_kitob/src/app/app.dart';
import 'package:flutter_kitob/src/app/router.dart';
import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/core/design_system/rich_text.dart';
import 'package:flutter_kitob/src/core/state/progress.dart';
import 'package:flutter_kitob/src/core/storage/store.dart';
import 'package:flutter_kitob/src/features/code/code_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flutter darsi ilova ichida: namuna telefon oynasida ochiladi, tugmalar ishlaydi,
/// vazifa haqiqiy tekshiruvdan o'tadi va progress yoziladi.
void main() {
  Finder textAnywhere(String s) => find.byWidgetPredicate(skipOffstage: false, (w) {
    if (w is Text) return (w.data ?? w.textSpan?.toPlainText() ?? '').contains(s);
    if (w is RichText) return w.text.toPlainText().contains(s);
    return false;
  });

  Future<void> pumpUntil(WidgetTester t, Finder f, {String? why}) async {
    for (var i = 0; i < 100; i++) {
      // Baholash alohida isolate'da — unga haqiqiy vaqt kerak.
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await t.pump(const Duration(milliseconds: 100));
      if (f.evaluate().isNotEmpty) return;
    }
    final all = find.byWidgetPredicate(skipOffstage: false, (w) => w is Text).evaluate().map((e) {
      final w = e.widget as Text;
      return w.data ?? w.textSpan?.toPlainText() ?? '';
    }).where((x) => x.length > 3).take(80).join(' | ');
    debugPrint('EKRANDA: $all');
    fail('Kutilgan element chiqmadi: ${why ?? f}');
  }

  Future<void> tap(WidgetTester t, Finder f) async {
    await t.ensureVisible(f.first);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(f.first, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('StatefulWidget darsi: preview, setState va vazifa', (t) async {
    t.view.physicalSize = const Size(1440, 2400);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({
      'kitob.v1.settings': '{"onboardingDone":true,"userName":"Test","launchCount":2,"reduceMotion":true}',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(container: container, child: const KitobApp()));
    await t.pump(const Duration(seconds: 2));

    container.read(routerProvider).go('/learn/lesson/l5_stateful');
    await pumpUntil(t, textAnywhere('StatefulWidget va setState'), why: 'dars sahifasi');

    // "Ko'rib o'rgan" bosqichigacha
    for (var i = 0; i < 4 && find.text('Ekranda ko\'rish'.uz).evaluate().isEmpty; i++) {
      await tap(t, find.text('Davom etish'.uz));
      await t.pump(const Duration(milliseconds: 600));
    }
    await tap(t, find.text('Ekranda ko\'rish'.uz));
    await pumpUntil(t, find.text('Yurakchani bosing'), why: 'preview ochildi');
    expect(find.text('0'), findsWidgets);

    // Preview ichidagi FAB — o'quvchining _oshir() funksiyasini chaqiradi
    await tap(t, find.byType(FloatingActionButton));
    await t.pumpAndSettle();
    expect(find.text('1'), findsWidgets);
    await tap(t, find.byIcon(Icons.favorite_border));
    await t.pumpAndSettle();
    expect(find.text('Yoqdi!'), findsOneWidget);

    // Mustaqil vazifa
    for (var i = 0; i < 6 && textAnywhere('Mustaqil vazifa').evaluate().isEmpty; i++) {
      await tap(t, find.text('Davom etish'.uz));
      await t.pump(const Duration(milliseconds: 600));
    }
    final editor = find.byType(KitobCodeEditor).last;
    final field = t.widget<TextField>(find.descendant(of: editor, matching: find.byType(TextField)));
    final task = lessonById['l5_stateful']!.task!;

    // Boshlang'ich kod (setState yo'q) — o'tmasligi kerak
    await tap(t, find.text('Tekshirish'.uz).last);
    await pumpUntil(t, textAnywhere('test o‘tdi'), why: 'baholash natijasi');
    expect(textAnywhere('setState() chaqirilmadi'), findsWidgets);

    field.controller!.text = task.solution;
    await t.pump(const Duration(milliseconds: 600));
    await tap(t, find.text('Tekshirish'.uz).last);
    await pumpUntil(t, textAnywhere('Barcha testlardan'), why: 'yechim qabul qilindi');
    expect(container.read(progressProvider).lessons['l5_stateful']?.taskSolved, isTrue);
    await t.pump(const Duration(seconds: 3));
  });
}
