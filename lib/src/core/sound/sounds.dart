import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Qisqa ovozli javoblar (`assets/sounds/`). Sinus
/// tonlardan sintez qilingan (litsenziya talab qilmaydi), har biri < 32 KB.
enum Sfx { correct, wrong, celebrate }

abstract final class Sounds {
  /// Testlarda o'chiriladi (`flutter_test_config.dart`): plagin kanali yo'q.
  static bool enabled = true;

  /// Sozlamalardagi "Ovozli effektlar" — ilova ildizida yangilanadi.
  static bool on = true;

  static final _players = <Sfx, AudioPlayer>{};
  static bool _configured = false;

  static Future<void> play(Sfx s) async {
    if (!enabled || !on) return;
    try {
      if (!_configured) {
        _configured = true;
        // Telefon "jim" rejimda bo'lsa — ovoz chiqmaydi; boshqa musiqani to'xtatmaydi.
        await AudioPlayer.global.setAudioContext(
          AudioContextConfig(respectSilence: true, focus: AudioContextConfigFocus.mixWithOthers).build(),
        );
      }
      final p = _players.putIfAbsent(s, () => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      await p.stop();
      await p.play(AssetSource('sounds/${s.name}.wav'), volume: s == Sfx.wrong ? 0.6 : 0.8);
    } catch (e) {
      // Ovoz — qo'shimcha qulaylik; ishlamasa ham o'qish to'xtamasin.
      debugPrint('Sfx ${s.name}: $e');
    }
  }
}
