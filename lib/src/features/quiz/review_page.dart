import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import 'quiz_runner.dart';

/// Intervalli takrorlash: dars savollaridan qisqa test.
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = lessonById[lessonId];
    if (lesson == null) {
      return Scaffold(extendBodyBehindAppBar: true, appBar: const KTopBar(), body: Builder(builder: (context) => const EmptyState(icon: Icons.search_off_rounded, title: 'Dars topilmadi', message: 'Takrorlash uchun dars mavjud emas.')));
    }
    final seed = DateTime.now().day + lessonId.hashCode;
    final qs = List.of(lesson.quiz)..shuffle(math.Random(seed));
    final questions = qs.take(math.min(3, qs.length)).toList();
    return Scaffold(
extendBodyBehindAppBar: true,
      appBar: KTopBar(close: true, onBack: () => context.canPop() ? context.pop() : context.go('/tests'), title: 'Takrorlash', subtitle: lesson.title),
      body: Builder(builder: (context) => ListView(padding: pagePadding(context), children: [
        ContentWidth(
          maxWidth: 820,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RichUz('Eslab qolish uchun eng yaxshi usul — **xotiradan qayta chiqarish**. 80% va undan yuqori natija keyingi takrorlash oralig\'ini uzaytiradi.',
                style: context.text.bodyMedium),
            const SizedBox(height: 14),
            QuizRunner(
              questions: questions,
              seed: seed,
              passScore: 80,
              onFinished: (s) => ref.read(progressProvider.notifier).submitReview(lessonId, s.score, s.wrongTopics),
              resultsActions: (context, s, retry) => Wrap(spacing: 8, runSpacing: 8, children: [
                KButton(label: 'Darsni ochish', icon: Icons.menu_book_rounded, variant: KButtonVariant.secondary, compact: true, onPressed: () => context.go('/learn/lesson/$lessonId')),
                KButton(label: 'Testlar', icon: Icons.quiz_rounded, compact: true, onPressed: () => context.go('/tests')),
              ]),
            ),
          ]),
        ),
      ])),
    );
  }
}
