import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system/adaptive.dart';
import '../core/design_system/theme.dart';
import '../core/sound/sounds.dart';
import '../core/i18n/kitob_localizations.dart';
import '../core/state/settings.dart';
import 'celebrations.dart';
import 'reminders_host.dart';
import 'router.dart';

class KitobApp extends ConsumerWidget {
  const KitobApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    KitobLocalizations.activeLanguage = settings.language;
    final look = resolveLook(settings.look);
    Sounds.on = settings.soundOn;
    return MaterialApp.router(
      title: 'FLUTTER_KITOB',
      locale: settings.language.locale,
      supportedLocales: KitobLocalizations.supportedLocales,
      localizationsDelegates: const [
        KitobLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: KitobTheme.light(look),
      darkTheme: KitobTheme.dark(look),
      themeMode: settings.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Juda katta tizim shriftida ham layout buzilmasligi uchun chegaralaymiz.
        final scaler = mq.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.6,
        );
        return MediaQuery(
          data: mq.copyWith(
            textScaler: scaler,
            disableAnimations: mq.disableAnimations || settings.reduceMotion,
          ),
          child: KLookScope(
            look: look,
            child: RemindersHost(
              child: CelebrationListener(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
