import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/settings.dart';
import '../features/curriculum/curriculum_page.dart';
import '../features/curriculum/glossary_page.dart';
import '../features/curriculum/level_page.dart';
import '../features/home/home_page.dart';
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
import '../features/tutor/tutor_page.dart';
import '../features/visualizer/visualizer_page.dart';
import '../features/widget_lab/widget_lab_page.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage<void>(
  key: state.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (context, animation, secondary, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved),
        child: child,
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
      GoRoute(path: '/', pageBuilder: (c, s) => _fade(s, const SplashPage())),
      GoRoute(path: '/onboarding', pageBuilder: (c, s) => _fade(s, const OnboardingPage())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (c, s) => _fade(s, const HomePage()),
              routes: [
                GoRoute(path: 'search', pageBuilder: (c, s) => _fade(s, SearchPage(initial: s.uri.queryParameters['q']))),
                GoRoute(path: 'tutor', pageBuilder: (c, s) => _fade(s, TutorPage(context: s.extra is String ? s.extra! as String : null))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/learn',
              pageBuilder: (c, s) => _fade(s, CurriculumPage(track: s.uri.queryParameters['track'])),
              routes: [
                GoRoute(path: 'level/:n', pageBuilder: (c, s) => _fade(s, LevelPage(number: int.parse(s.pathParameters['n']!)))),
                GoRoute(path: 'lesson/:id', pageBuilder: (c, s) => _fade(s, LessonPage(lessonId: s.pathParameters['id']!))),
                GoRoute(path: 'glossary', pageBuilder: (c, s) => _fade(s, const GlossaryPage())),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/practice',
              pageBuilder: (c, s) => _fade(s, const PracticePage()),
              routes: [
                GoRoute(
                  path: 'playground',
                  pageBuilder: (c, s) => _fade(s, PlaygroundPage(initialCode: s.extra is String ? s.extra! as String : null)),
                ),
                GoRoute(path: 'terminal', pageBuilder: (c, s) => _fade(s, const TerminalPage())),
                GoRoute(path: 'widgets', pageBuilder: (c, s) => _fade(s, const WidgetLabPage())),
                GoRoute(path: 'widgets/:id', pageBuilder: (c, s) => _fade(s, WidgetLabPage(labId: s.pathParameters['id']))),
                GoRoute(
                  path: 'visualizer',
                  pageBuilder: (c, s) => _fade(s, VisualizerPage(initialCode: s.extra is String ? s.extra! as String : null)),
                ),
                GoRoute(path: 'projects', pageBuilder: (c, s) => _fade(s, const ProjectsPage())),
                GoRoute(path: 'projects/:id', pageBuilder: (c, s) => _fade(s, ProjectDetailPage(projectId: s.pathParameters['id']!))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tests',
              pageBuilder: (c, s) => _fade(s, const TestsPage()),
              routes: [
                GoRoute(path: 'review/:id', pageBuilder: (c, s) => _fade(s, ReviewPage(lessonId: s.pathParameters['id']!))),
                GoRoute(path: 'exam/:n', pageBuilder: (c, s) => _fade(s, ExamPage(levelNumber: int.parse(s.pathParameters['n']!)))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (c, s) => _fade(s, const ProfilePage()),
              routes: [
                GoRoute(path: 'achievements', pageBuilder: (c, s) => _fade(s, const AchievementsPage())),
                GoRoute(path: 'settings', pageBuilder: (c, s) => _fade(s, const SettingsPage())),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
