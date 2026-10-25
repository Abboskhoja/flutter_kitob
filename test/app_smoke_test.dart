import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kitob/src/app/app.dart';
import 'package:flutter_kitob/src/app/router.dart';
import 'package:flutter_kitob/src/core/storage/store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.view(File('assets/fonts/$f').readAsBytesSync().buffer)));
    }
    await loader.load();
  }

  await load('Inter', ['Inter-Regular.ttf', 'Inter-Medium.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf', 'Inter-ExtraBold.ttf']);
  await load('JetBrainsMono', ['JetBrainsMono-Regular.ttf', 'JetBrainsMono-Medium.ttf', 'JetBrainsMono-Bold.ttf']);
  // Material ikonkalari
  final mi = FontLoader('MaterialIcons');
  final iconFont = File('${Platform.environment['FLUTTER_ROOT'] ?? '/Users/abboskhuja/Flutter/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (iconFont.existsSync()) {
    mi.addFont(Future.value(ByteData.view(iconFont.readAsBytesSync().buffer)));
    await mi.load();
  }
}

const _routes = [
  '/home',
  '/home/search?q=list',
  '/home/tutor',
  '/learn',
  '/learn?track=dart',
  '/learn?track=research',
  '/learn/level/1',
  '/learn/level/2',
  '/learn/level/3',
  '/learn/level/4',
  '/learn/level/7',
  '/learn/level/16',
  '/learn/lesson/l1_variables',
  '/learn/lesson/e2_git',
  '/learn/lesson/l4_event_loop',
  '/learn/glossary',
  '/practice',
  '/practice/playground',
  '/practice/terminal',
  '/practice/widgets',
  '/practice/widgets/container',
  '/practice/widgets/row_column',
  '/practice/visualizer',
  '/practice/projects',
  '/practice/projects/todo',
  '/tests',
  '/tests/exam/1',
  '/tests/exam/4',
  '/profile',
  '/profile/achievements',
  '/profile/settings',
];

void main() {
  setUpAll(_loadFonts);

  for (final (label, size) in const [('phone', Size(390, 844)), ('tablet', Size(800, 1100)), ('desktop', Size(1440, 900))]) {
    testWidgets('barcha sahifalar ochiladi — $label', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({
        'kitob.v1.settings': '{"onboardingDone":true,"userName":"Aziz","launchCount":3,"themeMode":"light","reduceMotion":true}',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const KitobApp()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));

      final router = container.read(routerProvider);
      final shotsDir = Directory('build/screens/$label')..createSync(recursive: true);
      for (final r in _routes) {
        router.go(r);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull, reason: 'sahifa: $r');
        if (Platform.environment['KITOB_SHOTS'] == '1') {
          final name = r.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
          await expectLater(find.byType(MaterialApp), matchesGoldenFile('../build/screens/$label/$name.png'));
        }
      }
      expect(shotsDir.existsSync(), isTrue);
      router.go('/home');
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('dark mode va onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'kitob.v1.settings': '{"themeMode":"dark","reduceMotion":true}'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(overrides: [sharedPrefsProvider.overrideWithValue(prefs)], child: const KitobApp()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
    debugPrint('Ko\'rinayotgan matnlar: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().take(12).toList()}');
    expect(find.textContaining('rgan'), findsWidgets);
    final ctx = tester.element(find.byType(Scaffold).first);
    GoRouter.of(ctx);
  });
}
