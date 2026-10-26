// Ilova ikonkalarini assets/flutter_kitob_logo.png dagi tasdiqlangan artwork'dan generatsiya qiladi.
//
// Ishga tushirish:  flutter test tool/gen_app_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kitob/src/core/design_system/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

late ui.Image _logo;

Future<void> _png(
  String path,
  int px, {
  double radius = 0,
  bool background = true,
  double glyphScale = 1,
  bool opaque = false,
  bool monochrome = false,
}) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  final size = Size(px.toDouble(), px.toDouble());
  // Barcha platforma ikonkalari foydalanuvchi bergan aynan shu artwork'dan
  // chiziladi. App Store PNG alfa qabul qilmaydi; qolgan iconlar ham maskaga mos.
  if (opaque || background) {
    canvas.drawRect(Offset.zero & size, Paint()..color = KColors.primary);
  }
  final maxSide = px * 0.94 * glyphScale;
  final scale = maxSide / _logo.width;
  final dst = Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: _logo.width * scale,
    height: _logo.height * scale,
  );
  final paint = Paint();
  if (monochrome) {
    paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn);
  }
  canvas.drawImageRect(
    _logo,
    Rect.fromLTWH(0, 0, _logo.width.toDouble(), _logo.height.toDouble()),
    dst,
    paint,
  );
  final img = await rec.endRecording().toImage(px, px);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// App Store ikonkada alfa kanal bo'lmasligi shart (shaffof piksel bo'lmasa ham).
/// macOS `sips` orqali JPEG ga o'tkazib, qayta PNG qilinadi — alfa yo'qoladi.
void _dropAlpha(String path) {
  final tmp = '${Directory.systemTemp.path}/kitob_icon_${path.hashCode}.jpg';
  Process.runSync('sips', [
    '-s',
    'format',
    'jpeg',
    '-s',
    'formatOptions',
    'best',
    path,
    '--out',
    tmp,
  ]);
  Process.runSync('sips', ['-s', 'format', 'png', tmp, '--out', path]);
  File(tmp).deleteSync();
}

void main() {
  test('ilova ikonkalari', () async {
    final bytes = await rootBundle.load('assets/flutter_kitob_logo.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    _logo = (await codec.getNextFrame()).image;
    // ── iOS: Contents.json dagi har bir o'lcham, burchaksiz va shaffofliksiz.
    const ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final images =
        (jsonDecode(File('$ios/Contents.json').readAsStringSync())['images']
                as List)
            .cast<Map<String, dynamic>>();
    for (final im in images) {
      final file = im['filename'] as String?;
      if (file == null) continue;
      final pt = double.parse((im['size'] as String).split('x').first);
      final scale = int.parse((im['scale'] as String).replaceAll('x', ''));
      await _png('$ios/$file', (pt * scale).round(), opaque: true);
      _dropAlpha('$ios/$file');
    }

    // ── Android: eski uslubdagi (API < 26) yumaloq-kvadrat ikonka.
    const res = 'android/app/src/main/res';
    const densities = {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    };
    for (final e in densities.entries) {
      await _png(
        '$res/mipmap-${e.key}/ic_launcher.png',
        (48 * e.value).round(),
      );
      // Adaptive ikonka qatlamlari: 108dp, kitob 66dp xavfsiz doira ichida.
      await _png(
        '$res/mipmap-${e.key}/ic_launcher_foreground.png',
        (108 * e.value).round(),
        background: false,
        glyphScale: 0.72,
      );
      await _png(
        '$res/mipmap-${e.key}/ic_launcher_background.png',
        (108 * e.value).round(),
        glyphScale: 0,
      );
      // Android 13 bir rangli ikonka: kitob shakli (faqat alfa ishlatiladi).
      await _png(
        '$res/mipmap-${e.key}/ic_launcher_monochrome.png',
        (108 * e.value).round(),
        background: false,
        glyphScale: 0.72,
        monochrome: true,
      );
    }

    // ── Web: favicon va PWA ikonkalari (maskable — Bitik xavfsiz zonada).
    await _png('web/favicon.png', 48);
    await _png('web/icons/Icon-192.png', 192);
    await _png('web/icons/Icon-512.png', 512);
    await _png('web/icons/Icon-maskable-192.png', 192, glyphScale: 0.8);
    await _png('web/icons/Icon-maskable-512.png', 512, glyphScale: 0.8);

    // ── Ochilish ekrani (native splash) logotipi.
    await _png('$res/drawable-xxhdpi/launch_logo.png', 288, radius: 0.28);
    const launch = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
    await _png('$launch/LaunchImage.png', 96, radius: 0.28);
    await _png('$launch/LaunchImage@2x.png', 192, radius: 0.28);
    await _png('$launch/LaunchImage@3x.png', 288, radius: 0.28);

    // macOS launcher iconlari ham shu manba artwork'dan olinadi.
    const mac = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
    for (final px in [16, 32, 64, 128, 256, 512, 1024]) {
      await _png('$mac/app_icon_$px.png', px);
    }
    _logo.dispose();
    codec.dispose();
  });
}
