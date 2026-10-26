import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../i18n/kitob_localizations.dart';
import 'theme.dart';
import 'tokens.dart';

final _apostropheBetweenLetters = RegExp(r"(?<=[A-Za-zʻ‘’])'(?=[A-Za-z])");

/// O'zbek matnidagi oddiy apostroflarni tipografik belgilarga almashtiradi:
/// `o'` → `o‘`, `g'` → `g‘`, boshqa joylarda `’` (tutuq belgisi).
/// Kod bo'laklariga (`...`) tegmaydi.
String uzify(String text) {
  final out = StringBuffer();
  var inCode = false;
  var segStart = 0;
  void flush(int end) {
    final seg = text.substring(segStart, end);
    out.write(inCode ? seg : _typography(seg));
  }

  for (var i = 0; i < text.length; i++) {
    if (text[i] == '`') {
      flush(i);
      out.write('`');
      inCode = !inCode;
      segStart = i + 1;
    }
  }
  flush(text.length);
  return out.toString();
}

String _typography(String s) => s.replaceAllMapped(_apostropheBetweenLetters, (
  m,
) {
  final prev = m.start > 0 ? s[m.start - 1] : '';
  return (prev == 'o' || prev == 'O' || prev == 'g' || prev == 'G') ? '‘' : '’';
});

/// `**qalin**` va `` `kod` `` belgilashli matnni chiroyli ko'rsatadi.
class RichUz extends StatelessWidget {
  const RichUz(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.onCodeTap,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final void Function(String code)? onCodeTap;

  @override
  Widget build(BuildContext context) {
    final base = style ?? context.text.bodyLarge!;
    return Text.rich(
      TextSpan(
        children: buildSpans(
          context,
          uzify(KitobLocalizations.text(text)),
          base,
          onCodeTap: onCodeTap,
        ),
      ),
      style: base,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }

  static List<InlineSpan> buildSpans(
    BuildContext context,
    String text,
    TextStyle base, {
    void Function(String code)? onCodeTap,
  }) {
    final k = context.k;
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`)');
    var last = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final tok = m.group(0)!;
      if (tok.startsWith('**')) {
        final inner = tok.substring(2, tok.length - 2);
        final bold = TextStyle(fontWeight: FontWeight.w700, color: k.text);
        // `**`int`**` — qalin matn ichidagi kod ham kod sifatida chiziladi
        // (teskari tirnoqlar ko'rinib qolmasin).
        spans.add(
          inner.contains('`')
              ? TextSpan(style: bold, children: buildSpans(context, inner, base.merge(bold), onCodeTap: onCodeTap))
              : TextSpan(text: inner, style: bold),
        );
      } else {
        final code = tok.substring(1, tok.length - 1);
        spans.add(
          TextSpan(
            text: ' $code ',
            recognizer: onCodeTap == null
                ? null
                : (TapGestureRecognizer()..onTap = () => onCodeTap(code)),
            style: codeStyle(
              size: (base.fontSize ?? 15) * 0.9,
              color: context.isDark
                  ? const Color(0xFF8CC8FF)
                  : const Color(0xFF0B5CC4),
            ).copyWith(backgroundColor: k.primarySoft, height: base.height),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }
}

/// [RichUz] + ```` ``` ```` bilan o'ralgan ko'p qatorli kod/natija bloklari (vazifa shartlari uchun).
class RichUzBlocks extends StatelessWidget {
  const RichUzBlocks(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('```');
    if (parts.length < 3) return RichUz(text, style: style);
    final k = context.k;
    final base = style ?? context.text.bodyLarge!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < parts.length; i++)
          if (i.isOdd)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: k.surfaceAlt,
                borderRadius: BorderRadius.circular(KRadius.sm),
                border: Border.all(color: k.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  parts[i].replaceAll(RegExp(r'^\n|\n$'), ''),
                  style: codeStyle(
                    size: (base.fontSize ?? 15) * 0.85,
                    color: k.text,
                  ),
                ),
              ),
            )
          else if (parts[i].trim().isNotEmpty)
            RichUz(parts[i].trim(), style: base),
      ],
    );
  }
}

/// Oddiy matn — faqat tipografik apostroflar bilan.
class UzText extends StatelessWidget {
  const UzText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
    uzify(KitobLocalizations.text(text)).replaceAll('`', ''),
    style: style,
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
  );
}

extension UzString on String {
  String get uz => uzify(KitobLocalizations.text(this)).replaceAll('`', '');
}

/// Matndagi `kod` bo'laklarini olib tashlamasdan ko'rsatish uchun yordamchi.
class KodChip extends StatelessWidget {
  const KodChip(this.code, {super.key, this.color});
  final String code;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color ?? context.k.primarySoft,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      code,
      style: codeStyle(
        size: 13,
        color: context.isDark ? const Color(0xFF8CC8FF) : KColors.primary,
      ),
    ),
  );
}
