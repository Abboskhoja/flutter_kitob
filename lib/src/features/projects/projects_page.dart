import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../lessons/runnable_code.dart';
import 'projects_data.dart';

String stepKey(String projectId, int i) => 'practice:project:$projectId:$i';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    return Scaffold(
extendBodyBehindAppBar: true,
      appBar: KTopBar(title: 'Amaliy loyihalar', onBack: () => context.canPop() ? context.pop() : context.go('/practice'), showBack: !context.isExpanded),
      body: Builder(builder: (context) => ListView(padding: pagePadding(context), children: [
        ContentWidth(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RichUz('Kichik mashqlardan haqiqiy dasturlarga. Har bir loyiha **brief → talablar → arxitektura → bosqichma-bosqich kod → testlar → code review** yo\'lidan o\'tadi.',
                style: context.text.bodyLarge),
            const SizedBox(height: 16),
            for (final pr in allProjects)
              Builder(builder: (context) {
                final done = [for (var i = 0; i < pr.steps.length; i++) p.achievements.contains(stepKey(pr.id, i))].where((x) => x).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KCard(
                    onTap: () => context.go('/practice/projects/${pr.id}'),
                    child: Row(children: [
                      KIconBox(pr.icon, color: KColors.orange, size: 50, filled: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: UzText(pr.title, style: context.text.titleMedium)),
                            KBadge(pr.level, color: KColors.violet),
                          ]),
                          const SizedBox(height: 4),
                          UzText(pr.brief, style: context.text.bodySmall, maxLines: 2),
                          const SizedBox(height: 8),
                          KProgressBar(value: done / pr.steps.length, color: KColors.orange, height: 6),
                          const SizedBox(height: 4),
                          Text('$done / ${pr.steps.length} bosqich'.uz, style: context.text.labelSmall),
                        ]),
                      ),
                    ]),
                  ),
                );
              }),
            const SizedBox(height: 8),
            const FeedbackBanner(
              kind: FeedbackKind.info,
              title: 'Keyingi loyihalar',
              message: 'Counter, Notes, Weather (API), Login & Profile, News, E-Commerce, Chat, Maps va yakuniy production-style ilova Flutter preview runtime bilan bosqichma-bosqich qo\'shiladi. Hozircha ular ro\'yxatda ko\'rsatilmaydi — mavjud bo\'lmagan loyiha ochilmaydi.',
            ),
          ]),
        ),
      ])),
    );
  }
}

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pr = projectById(projectId);
    if (pr == null) {
      return Scaffold(extendBodyBehindAppBar: true, appBar: const KTopBar(), body: Builder(builder: (context) => const EmptyState(icon: Icons.search_off_rounded, title: 'Loyiha topilmadi', message: 'Bunday loyiha mavjud emas.')));
    }
    final p = ref.watch(progressProvider);
    final doneAll = [for (var i = 0; i < pr.steps.length; i++) p.achievements.contains(stepKey(pr.id, i))].every((x) => x);
    Widget sec(String title, IconData icon, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Icon(icon, color: KColors.primary, size: 20), const SizedBox(width: 8), Expanded(child: UzText(title, style: context.text.titleLarge))]),
        const SizedBox(height: 8),
        child,
      ]),
    );
    Widget bullets(List<String> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final s in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_rounded, size: 18, color: KColors.success),
            const SizedBox(width: 8),
            Expanded(child: RichUz(s, style: context.text.bodyMedium)),
          ]),
        ),
    ]);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: KTopBar(title: pr.title),
      body: Builder(builder: (context) => ListView(padding: pagePadding(context), children: [
        ContentWidth(
          maxWidth: 900,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (doneAll)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: FeedbackBanner(kind: FeedbackKind.success, title: 'Loyiha yakunlandi! 🚀', message: 'Barcha bosqichlar testlardan o\'tdi. Code review ro\'yxatini o\'zingiz tekshiring.'),
              ),
            sec('Project brief', Icons.description_rounded, RichUz(pr.brief, style: context.text.bodyLarge)),
            sec('Funksional talablar', Icons.rule_rounded, bullets(pr.functional)),
            if (pr.ui.isNotEmpty) sec('UI talablari', Icons.palette_rounded, bullets(pr.ui)),
            sec('Arxitektura', Icons.architecture_rounded, RichUz(pr.architecture, style: context.text.bodyMedium)),
            sec('Papka tuzilmasi', Icons.folder_rounded, Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(KRadius.md)),
              child: Text(pr.folders, style: codeStyle(size: 13, color: context.k.consoleText)),
            )),
            for (var i = 0; i < pr.steps.length; i++)
              sec(pr.steps[i].title, p.achievements.contains(stepKey(pr.id, i)) ? Icons.check_circle_rounded : Icons.construction_rounded, Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichUz(pr.steps[i].explanation, style: context.text.bodyMedium),
                  const SizedBox(height: 10),
                  TaskWorkspace(
                    task: pr.steps[i].task,
                    practiceId: 'project:${pr.id}:$i',
                    onSolved: () {
                      final s = ref.read(progressProvider);
                      final all = [for (var k = 0; k < pr.steps.length; k++) k == i || s.achievements.contains(stepKey(pr.id, k))].every((x) => x);
                      if (all) ref.read(progressProvider.notifier).completeProject(pr.id);
                    },
                  ),
                ],
              )),
            sec('Testlash talablari', Icons.science_rounded, bullets(pr.testing)),
            sec('Yakuniy code review', Icons.rate_review_rounded, bullets(pr.review)),
            if (pr.flutterNote != null) FeedbackBanner(kind: FeedbackKind.info, title: 'Flutter versiyasi', message: pr.flutterNote),
          ]),
        ),
      ])),
    );
  }
}
