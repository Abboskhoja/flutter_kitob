import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system/theme.dart';
import '../core/state/settings.dart';
import 'celebrations.dart';
import 'router.dart';

class KitobApp extends ConsumerWidget {
  const KitobApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FLUTTER_KITOB',
      debugShowCheckedModeBanner: false,
      theme: KitobTheme.light(),
      darkTheme: KitobTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Juda katta tizim shriftida ham layout buzilmasligi uchun chegaralaymiz.
        final scaler = mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.6);
        return MediaQuery(
          data: mq.copyWith(textScaler: scaler, disableAnimations: mq.disableAnimations || settings.reduceMotion),
          child: CelebrationListener(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
