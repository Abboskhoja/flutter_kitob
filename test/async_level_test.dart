import 'package:flutter/material.dart';
import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/core/design_system/theme.dart';
import 'package:flutter_kitob/src/core/state/progress.dart';
import 'package:flutter_kitob/src/core/storage/store.dart';
import 'package:flutter_kitob/src/features/animations/edu_animations.dart';
import 'package:flutter_kitob/src/features/playground/playground_store.dart';
import 'package:flutter_kitob/src/features/terminal/terminal_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitob_dart/kitob_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2- va 4-daraja qo'shimchalari: animatsiyalar tor ekranda buzilmaydi, terminal vazifasi
/// haqiqiy fayl tizimi holati bo'yicha tekshiriladi va progress yoziladi.
void main() {
  Future<ProviderContainer> host(WidgetTester t, Widget child, {Size size = const Size(360, 900)}) async {
    t.view.physicalSize = size * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({'kitob.v1.settings': '{"onboardingDone":true,"reduceMotion":true}'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: KitobTheme.light(), home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child))),
    ));
    await t.pump();
    return container;
  }

  for (final id in eduAnimations.keys) {
    for (final dark in const [false, true]) {
      testWidgets('animatsiya $id barcha bosqichlari 360px da ${dark ? 'qorong\'i' : 'yorug\''} rejimda chiziladi', (t) async {
        t.view.physicalSize = const Size(720, 1800);
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        SharedPreferences.setMockInitialValues({'kitob.v1.settings': '{"onboardingDone":true,"reduceMotion":true}'});
        final prefs = await SharedPreferences.getInstance();
        await t.pumpWidget(ProviderScope(
          overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: dark ? KitobTheme.dark() : KitobTheme.light(),
            home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: eduAnimations[id]!())),
          ),
        ));
        await t.pump(const Duration(milliseconds: 500));
        for (var i = 0; i < 10; i++) {
          final next = find.widgetWithIcon(IconButton, Icons.skip_next_rounded);
          if (next.evaluate().isEmpty) break;
          final btn = t.widget<IconButton>(next);
          if (btn.onPressed == null) break;
          await t.tap(next);
          await t.pump(const Duration(milliseconds: 900));
        }
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('terminal vazifasi: buyruqlar → maqsadlar bajariladi → taskSolved', (t) async {
    final lesson = lessonById['e2_files']!;
    final c = await host(t, TerminalTaskWorkspace(task: lesson.terminalTask!, lessonId: lesson.id));
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(3));
    Future<void> run(String cmd) async {
      await t.enterText(find.byType(TextField), cmd);
      await t.testTextInput.receiveAction(TextInputAction.done);
      // AnimatedSwitcher o'tishi tugashi uchun.
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(seconds: 1));
    }

    await run('mkdir -p sayt/css');
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(2));
    expect(c.read(progressProvider).of(lesson.id).taskSolved, isFalse);
    await run('echo "Salom dunyo" > sayt/index.html');
    await run('echo "Mening saytim haqida" > sayt/README.md');
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
    expect(find.textContaining('Vazifa bajarildi'), findsOneWidget);
    expect(c.read(progressProvider).of(lesson.id).taskSolved, isTrue);
    expect(t.takeException(), isNull);
  });

  test('Playground Dart namunalari xatosiz ishlaydi; asinxron namuna Dart VM natijasini beradi', () {
    for (final e in playgroundSamples.entries.where((e) => !e.value.contains('package:flutter'))) {
      final r = KitobDart.run(e.value, options: const ExecutionOptions(stdin: ['Aziz']));
      expect(r.success, isTrue, reason: '${e.key}: ${r.error?.explanation ?? r.diagnostics.join()}');
    }
    // `dart run` (Dart 3.13.5) natijasi:
    expect(KitobDart.run(playgroundSamples['Asinxron: Future va Stream']!).stdout,
        'Boshlandi\nmicrotask\nProfil yuklandi\n[Rasm yuklandi, Xabarlar yuklandi]\n3...\n2...\n1...\nTayyor!\n');
  });
}
