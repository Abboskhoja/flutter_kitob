import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/adaptive.dart';
import '../core/design_system/motion.dart';
import '../core/state/settings.dart';
import '../features/curriculum/curriculum_page.dart';
import '../features/curriculum/glossary_page.dart';
import '../features/curriculum/level_page.dart';
import '../features/home/home_page.dart';
import '../features/interview/interview_page.dart';
import '../features/lessons/lesson_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/practice/practice_page.dart';
import '../features/playground/playground_page.dart';
import '../features/profile/achievements_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/settings_page.dart';
import '../features/projects/projects_page.dart';
import '../features/quiz/exam_page.dart';
import '../features/quiz/review_page.dart';
import '../features/quiz/tests_page.dart';
import '../features/search/search_page.dart';
import '../features/splash/splash_page.dart';
import '../features/terminal/terminal_page.dart';
import '../features/visualizer/visualizer_page.dart';
import '../features/widget_lab/widget_lab_page.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Sahifa o'tishi platformaga mos:
/// * Glass (iOS) — `CupertinoPage`: chetdan surib orqaga qaytish ishlaydi.
/// * Material (Android) — tema'dagi predictive-back o'tishi.
/// * Web — yengil fade + ko'tarilish.
Page<void> _page(BuildContext context, GoRouterState state, Widget child) => switch (KLookScope.of(context)) {
  KLook.glass => CupertinoPage<void>(key: state.pageKey, child: child),
  KLook.material => MaterialPage<void>(key: state.pageKey, child: child),
  KLook.web => _fade(state, child),
};

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 220),
  transitionsBuilder: (context, animation, secondary, child) {
    final curved = CurvedAnimation(parent: animation, curve: KMotion.emphasized, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.025), end: Offset.zero).animate(curved),
        child: ScaleTransition(scale: Tween(begin: 0.985, end: 1.0).animate(curved), child: child),
      ),
    );
  },
);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboardingDone;
      final loc = state.matchedLocation;
      if (!done && loc != '/' && loc != '/onboarding') return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', pageBuilder: (c, s) => _page(c, s, const SplashPage())),
      GoRoute(path: '/onboarding', pageBuilder: (c, s) => _page(c, s, const OnboardingPage())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (c, s) => _page(c, s, const HomePage()),
              routes: [
                GoRoute(path: 'search', pageBuilder: (c, s) => _page(c, s, SearchPage(initial: s.uri.queryParameters['q']))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/learn',
              pageBuilder: (c, s) => _page(c, s, CurriculumPage(track: s.uri.queryParameters['track'])),
              routes: [
                GoRoute(path: 'level/:n', pageBuilder: (c, s) => _page(c, s, LevelPage(number: int.parse(s.pathParameters['n']!)))),
                GoRoute(path: 'lesson/:id', pageBuilder: (c, s) => _page(c, s, LessonPage(
                  // Har bir dars — o'z holati: "Keyingi dars" ga o'tganda eski bosqich raqami qolmasin.
                  key: ValueKey(s.pathParameters['id']),
                  lessonId: s.pathParameters['id']!,
                ))),
                GoRoute(path: 'glossary', pageBuilder: (c, s) => _page(c, s, const GlossaryPage())),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/practice',
              pageBuilder: (c, s) => _page(c, s, const PracticePage()),
              routes: [
                GoRoute(
                  path: 'playground',
                  pageBuilder: (c, s) => _page(c, s, PlaygroundPage(initialCode: s.extra is String ? s.extra! as String : null)),
                ),
                GoRoute(path: 'terminal', pageBuilder: (c, s) => _page(c, s, const TerminalPage())),
                GoRoute(path: 'widgets', pageBuilder: (c, s) => _page(c, s, const WidgetLabPage())),
                GoRoute(path: 'widgets/:id', pageBuilder: (c, s) => _page(c, s, WidgetLabPage(labId: s.pathParameters['id']))),
                GoRoute(
                  path: 'visualizer',
                  pageBuilder: (c, s) => _page(c, s, VisualizerPage(initialCode: s.extra is String ? s.extra! as String : null)),
                ),
                GoRoute(path: 'projects', pageBuilder: (c, s) => _page(c, s, const ProjectsPage())),
                GoRoute(path: 'interview', pageBuilder: (c, s) => _page(c, s, const InterviewPage())),
                GoRoute(path: 'projects/:id', pageBuilder: (c, s) => _page(c, s, ProjectDetailPage(projectId: s.pathParameters['id']!))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tests',
              pageBuilder: (c, s) => _page(c, s, const TestsPage()),
              routes: [
                GoRoute(path: 'review/:id', pageBuilder: (c, s) => _page(c, s, ReviewPage(lessonId: s.pathParameters['id']!))),
                GoRoute(path: 'exam/:n', pageBuilder: (c, s) => _page(c, s, ExamPage(levelNumber: int.parse(s.pathParameters['n']!)))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (c, s) => _page(c, s, const ProfilePage()),
              routes: [
                GoRoute(path: 'achievements', pageBuilder: (c, s) => _page(c, s, const AchievementsPage())),
                GoRoute(path: 'settings', pageBuilder: (c, s) => _page(c, s, const SettingsPage())),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
