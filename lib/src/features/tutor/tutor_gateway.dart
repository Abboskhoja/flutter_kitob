import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Server tomonidagi AI gateway manzili. Build vaqtida beriladi:
/// `flutter run --dart-define=KITOB_AI_URL=https://api.example.uz/tutor`
///
/// API kalit hech qachon ilova ichida saqlanmaydi — u faqat gateway serverda.
const aiGatewayUrl = String.fromEnvironment('KITOB_AI_URL');

bool get onlineTutorConfigured => aiGatewayUrl.isNotEmpty;

class GatewayMessage {
  const GatewayMessage(this.role, this.text);
  final String role;
  final String text;
  Map<String, String> toJson() => {'role': role, 'content': text};
}

/// Gateway'ga so'rov yuboradi. Xato bo'lsa null qaytaradi (oflayn ustozga qaytiladi).
Future<String?> askGateway(List<GatewayMessage> history, {String? mode, String? lessonTitle}) async {
  if (!onlineTutorConfigured) return null;
  try {
    final res = await http
        .post(
          Uri.parse(aiGatewayUrl),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'messages': [for (final m in history) m.toJson()],
            'mode': mode,
            'lesson': lessonTitle,
            'language': 'uz-Latn',
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) return null;
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is Map && body['reply'] is String) return body['reply'] as String;
    return null;
  } catch (e) {
    debugPrint('AI gateway xatosi: $e');
    return null;
  }
}
