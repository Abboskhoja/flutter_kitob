import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `main()` da haqiqiy instansiya bilan almashtiriladi.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('SharedPreferences berilmagan'));

final storeProvider = Provider<KStore>((ref) => KStore(ref.watch(sharedPrefsProvider)));

/// Qurilmadagi lokal xotira. Barcha yozuvlar versiyalangan kalitlar ostida.
class KStore {
  KStore(this._prefs);
  final SharedPreferences _prefs;

  static const _prefix = 'kitob.v1.';

  Map<String, Object?>? readJson(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      _prefs.setString('$_prefix$key', jsonEncode(value));

  String? readString(String key) => _prefs.getString('$_prefix$key');
  Future<void> writeString(String key, String value) => _prefs.setString('$_prefix$key', value);
  Future<void> remove(String key) => _prefs.remove('$_prefix$key');

  Iterable<String> keysWithPrefix(String p) =>
      _prefs.getKeys().where((k) => k.startsWith('$_prefix$p')).map((k) => k.substring(_prefix.length));

  Future<void> clearAll() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(k);
    }
  }
}
