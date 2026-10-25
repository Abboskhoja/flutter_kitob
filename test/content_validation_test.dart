import 'dart:io';

import 'package:flutter_kitob/src/content/curriculum.dart';
import 'package:flutter_kitob/src/content/model.dart';
import 'package:flutter_kitob/src/core/runner/grader.dart';
import 'package:flutter_kitob/src/features/animations/edu_animations.dart';
import 'package:flutter_kitob/src/features/projects/projects_data.dart';
import 'package:flutter_kitob/src/features/quiz/quiz_engine.dart';
import 'package:flutter_kitob/src/features/terminal/shell_grader.dart';
import 'package:flutter_kitob/src/features/terminal/vfs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitob_dart/kitob_dart.dart';

/// O'quv kontentining sifat nazorati: har bir kod namunasi haqiqatan
/// ishlashi, har bir vazifa yechilishi va har bir savol to'g'ri bo'lishi shart.
void main() {
  // Haqiqiy Dart VM bilan qo'shimcha tekshirish uchun namunalar shu yerga yoziladi.
  final dumpDir = Directory('build/content_samples')..createSync(recursive: true);
  var dumpIndex = 0;
  void dump(String id, String code, String expected) {
    final name = '${(dumpIndex++).toString().padLeft(3, '0')}_$id';
    File('${dumpDir.path}/$name.dart').writeAsStringSync(code);
    File('${dumpDir.path}/$name.expected').writeAsStringSync(expected);
  }

  String errorsOf(ExecutionResult r) =>
      [...r.diagnostics.where((d) => d.isError).map((d) => d.toString()), if (r.error != null) '${r.error!.message} @${r.error!.line}'].join('\n');

  // Flutter kodi: ilova ochiladimi va widget daraxti (matn ko'rinishida) qanday.
  (String? tree, String errors) flutterTree(String code) {
    final (rt, diags, err) = FlutterRuntime.open(code);
    final errors = [...diags.where((d) => d.isError).map((d) => d.toString()), if (err != null) '${err.message} @${err.line}'].join('\n');
    if (rt == null) return (null, errors);
    try {
      return (rt.expand().dump(), errors);
    } on FlutterRunError catch (e) {
      return (null, e.info.message);
    }
  }

  for (final level in curriculum) {
    for (final l in level.lessons) {
      group('${level.number}-daraja / ${l.id}', () {
        test('tuzilma', () {
          expect(l.objectives, isNotEmpty);
          expect(l.intro, isNotEmpty);
          expect(l.why, isNotEmpty);
          expect(l.where, isNotEmpty);
          expect(l.summary, isNotEmpty);
          expect(l.revisionTip, isNotEmpty);
          expect(l.quiz.length, greaterThanOrEqualTo(2), reason: 'kamida 2 ta savol');
          if (level.number == 2) expect(l.terminalTask, isNotNull, reason: 'dasturchi muhiti darsida terminal amaliyoti bo\'lishi shart');
          if (level.track != Track.foundations) {
            expect(l.example, isNotNull, reason: 'Dart darsida ishlaydigan kod bo\'lishi shart');
            expect(l.buggy, isNotNull, reason: 'xatoli kod mashqi bo\'lishi shart');
            expect(l.task, isNotNull, reason: 'mustaqil vazifa bo\'lishi shart');
          }
          if (l.animation != null) {
            expect(eduAnimations.containsKey(l.animation!.id), isTrue, reason: 'animatsiya topilmadi: ${l.animation!.id}');
          }
          for (final b in l.extra) {
            if (b is AnimationBlock) expect(eduAnimations.containsKey(b.id), isTrue);
          }
          for (final p in l.prerequisites) {
            expect(allLessons.any((x) => x.title == p), isTrue, reason: 'oldingi dars topilmadi: "$p"');
          }
        });

        final codes = <CodeBlock>[?l.example, ...l.examples, ...l.extra.whereType<CodeBlock>()];
        for (var i = 0; i < codes.length; i++) {
          test('kod namunasi #$i ishlaydi', () {
            final c = codes[i];
            if (c.preview) {
              final (tree, errors) = flutterTree(c.code);
              expect(tree, isNotNull, reason: errors);
              expect(tree, isNot(contains('null\n')), reason: 'daraxtda null widget bor:\n$tree');
              for (final key in c.explain.keys) {
                expect(c.code.contains(key), isTrue, reason: 'izoh kaliti kodda yo\'q: "$key"');
              }
              return;
            }
            final r = KitobDart.run(c.code, options: ExecutionOptions(stdin: c.stdin));
            expect(r.success, isTrue, reason: errorsOf(r));
            if (c.expectedOutput != null) {
              expect(r.stdout, c.expectedOutput, reason: 'Kutilgan natija mos emas');
              if (c.stdin.isEmpty) dump('${l.id}_ex$i', c.code, c.expectedOutput!);
            }
            for (final key in c.explain.keys) {
              expect(c.code.contains(key), isTrue, reason: 'izoh kaliti kodda yo\'q: "$key"');
            }
            final lines = c.code.split('\n').length;
            for (final ln in c.lineNotes.keys) {
              expect(ln, inInclusiveRange(1, lines));
            }
          });
        }

        if (l.buggy != null) {
          test('xatoli kod haqiqatan xato, tuzatilgani ishlaydi', () {
            if (l.buggy!.preview) {
              final (good, errors) = flutterTree(l.buggy!.fixed);
              expect(good, isNotNull, reason: errors);
              final (bad, _) = flutterTree(l.buggy!.code);
              expect(bad, isNot(good), reason: 'xatoli kod to\'g\'ri variant bilan bir xil ekran beryapti');
              return;
            }
            final bad = KitobDart.run(l.buggy!.code, options: const ExecutionOptions(maxSteps: 50000));
            final good = KitobDart.run(l.buggy!.fixed);
            expect(good.success, isTrue, reason: errorsOf(good));
            final differs = !bad.success || normalizeOutput(bad.stdout) != normalizeOutput(good.stdout);
            expect(differs, isTrue, reason: 'xatoli kod to\'g\'ri natija beryapti');
          });
        }

        if (l.terminalTask != null) {
          test('terminal vazifasi: yechim buyruqlari o\'tadi, bo\'sh terminal o\'tmaydi', () {
            final t = l.terminalTask!;
            expect(t.hints, isNotEmpty);
            expect(terminalTaskPasses(VirtualShell(), t), isFalse, reason: 'hech narsa qilmasdan o\'tib ketyapti');
            final shell = VirtualShell();
            for (final cmd in t.solution) {
              final out = shell.execute(cmd);
              expect(out.where((o) => o.kind == LineKind.error), isEmpty, reason: '`$cmd` xato berdi: ${out.map((o) => o.text).join(' | ')}');
            }
            for (final c in t.checks) {
              expect(shellCheckPasses(shell, c), isTrue, reason: 'bajarilmadi: ${c.label}');
            }
          });
        }

        if (l.task != null) {
          test('vazifa: yechim o\'tadi, boshlang\'ich kod o\'tmaydi', () {
            final t = l.task!;
            expect(t.hints, isNotEmpty);
            final ok = gradeTask(t, t.solution);
            expect(ok.passed, isTrue,
                reason: [
                  ...ok.diagnostics.where((d) => d.isError).map((d) => d.toString()),
                  for (final r in ok.results.where((r) => !r.passed)) '${r.title}: ${r.actual} (kutilgan ${r.expected})',
                  ?ok.error?.message,
                ].join('\n'));
            expect(gradeTask(t, t.starter).passed, isFalse, reason: 'boshlang\'ich kod testlardan o\'tib ketyapti');
          });
        }

        test('savollar to\'g\'ri tuzilgan', () {
          for (final q in l.quiz) {
            switch (q) {
              case SingleChoice():
                expect(q.correct, inInclusiveRange(0, q.options.length - 1));
              case MultiChoice():
                expect(q.correct.every((i) => i >= 0 && i < q.options.length), isTrue);
              case PredictOutput():
                final r = runCached(q.code!);
                expect(r.success, isTrue, reason: errorsOf(r));
                if (q.options != null) {
                  final actual = actualOutputOf(q);
                  final matching = q.options!.where((o) => normalizeOutput(o) == actual).length;
                  expect(matching, 1, reason: '"${q.prompt}": aynan bitta variant haqiqiy natija ($actual) ga teng bo\'lishi kerak');
                }
                dump('${l.id}_predict', q.code!, r.stdout);
              case FillBlank():
                expect(q.template.contains('____'), isTrue);
                if (q.expectedOutput != null && q.accepted.isNotEmpty) {
                  expect(gradeQuestion(q, TextAnswer(q.accepted.first)).correct, isTrue, reason: q.prompt);
                }
              case ArrangeLines():
                if (q.byOutput) {
                  expect(gradeQuestion(q, OrderAnswer(q.lines)).correct, isTrue, reason: q.prompt);
                }
              case FindBug():
                expect(q.bugLine, inInclusiveRange(1, q.code!.split('\n').length));
              case MatchPairs():
                expect(q.pairs.map((p) => p.$2).toSet().length, q.pairs.length, reason: 'o\'ng tomondagi qiymatlar takrorlanmasin');
              case TrueFalse():
                break;
              case WriteCode():
                expect(gradeTask(q.task, q.task.solution).passed, isTrue);
            }
            if (q.code != null && q is! PredictOutput && q is! FindBug) {
              final r = runCached(q.code!);
              expect(r.diagnostics.where((d) => d.code == 'expected_semicolon'), isEmpty);
            }
          }
        });
      });
    }
  }

  group('loyihalar', () {
    for (final p in allProjects) {
      for (var i = 0; i < p.steps.length; i++) {
        test('${p.id} / ${i + 1}-bosqich', () {
          final t = p.steps[i].task;
          final ok = gradeTask(t, t.solution);
          expect(ok.passed, isTrue,
              reason: [
                ...ok.diagnostics.where((d) => d.isError).map((d) => d.toString()),
                for (final r in ok.results.where((r) => !r.passed)) '${r.title}: ${r.actual}',
              ].join('\n'));
          expect(gradeTask(t, t.starter).passed, isFalse);
        });
      }
    }
  });
}
