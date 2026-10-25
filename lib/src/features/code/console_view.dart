import 'package:flutter/material.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';

/// Dastur natijasi: konsol matni, ish vaqtidagi xato, vaqt.
class ConsoleView extends StatelessWidget {
  const ConsoleView({
    super.key,
    required this.result,
    this.running = false,
    this.emptyHint = 'Natijani ko\'rish uchun ▶ Ishga tushirish tugmasini bosing',
    this.onJumpToLine,
    this.maxHeight,
    this.visibleOutputLength,
  });

  final ExecutionResult? result;
  final bool running;
  final String emptyHint;
  final void Function(int line)? onJumpToLine;
  final double? maxHeight;

  /// Vizualizator uchun: faqat shu uzunlikkacha bo'lgan natija.
  final int? visibleOutputLength;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final r = result;
    Widget body;
    if (running) {
      body = Row(children: [
        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: KColors.cyan)),
        const SizedBox(width: 10),
        Text('Bajarilmoqda...'.uz, style: codeStyle(size: 13.5, color: k.consoleText)),
      ]);
    } else if (r == null) {
      body = Text(emptyHint.uz, style: codeStyle(size: 13, color: k.consoleText.withValues(alpha: 0.55)));
    } else if (!r.compiled) {
      body = Row(children: [
        Icon(Icons.block_rounded, size: 16, color: k.errorText),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Kod ishga tushmadi — avval "Muammolar"dagi xatolarni tuzating.'.uz,
              style: codeStyle(size: 13, color: const Color(0xFFFCA5A5))),
        ),
      ]);
    } else {
      var out = r.stdout;
      if (visibleOutputLength != null && visibleOutputLength! < out.length) out = out.substring(0, visibleOutputLength);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (out.isEmpty && r.error == null)
            Text('(dastur hech narsa chiqarmadi)'.uz, style: codeStyle(size: 13, color: k.consoleText.withValues(alpha: 0.5)))
          else if (out.isNotEmpty)
            SelectableText(out.endsWith('\n') ? out.substring(0, out.length - 1) : out,
                style: codeStyle(size: 14, color: k.consoleText)),
          if (r.error != null && visibleOutputLength == null) ...[
            if (out.isNotEmpty) const SizedBox(height: 10),
            RuntimeErrorCard(error: r.error!, onJumpToLine: onJumpToLine),
          ],
          if (visibleOutputLength == null) ...[
            const SizedBox(height: 8),
            Text(
              r.error == null
                  ? '✓ ${(r.elapsedMicros / 1000).toStringAsFixed(1)} ms · ${r.steps} qadam'.uz
                  : '✗ dastur xato bilan to\'xtadi'.uz,
              style: codeStyle(size: 11.5, color: k.consoleText.withValues(alpha: 0.45)),
            ),
          ],
        ],
      );
    }
    return Semantics(
      label: 'Konsol natijasi',
      liveRegion: true,
      child: Container(
        width: double.infinity,
        constraints: maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight!),
        decoration: BoxDecoration(color: k.console, borderRadius: BorderRadius.circular(KRadius.md)),
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.terminal_rounded, size: 14, color: KColors.cyan),
                const SizedBox(width: 6),
                Text('KONSOL', style: codeStyle(size: 11, color: KColors.cyan, weight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

class RuntimeErrorCard extends StatelessWidget {
  const RuntimeErrorCard({super.key, required this.error, this.onJumpToLine});
  final RuntimeErrorInfo error;
  final void Function(int line)? onJumpToLine;

  @override
  Widget build(BuildContext context) {
    final stopped = error.type == 'stopped';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1416),
        borderRadius: BorderRadius.circular(KRadius.sm),
        border: Border.all(color: const Color(0xFF7F1D1D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(stopped ? Icons.stop_circle_outlined : Icons.error_rounded, size: 18, color: const Color(0xFFFCA5A5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                stopped ? 'To\'xtatildi'.uz : 'Ish vaqtidagi xato · ${error.line}-qator'.uz,
                style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w700),
              ),
            ),
            if (onJumpToLine != null && !stopped)
              TextButton(
                onPressed: () => onJumpToLine!(error.line),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFCA5A5), visualDensity: VisualDensity.compact),
                child: Text('Qatorga o\'tish'.uz),
              ),
          ]),
          const SizedBox(height: 6),
          RichUz(error.explanation, style: const TextStyle(color: Color(0xFFFDE2E2), fontSize: 14, height: 1.5)),
          if (!stopped) ...[
            const SizedBox(height: 8),
            SelectableText(error.message, style: codeStyle(size: 12.5, color: const Color(0xFFF8B4B4))),
          ],
          if (error.hint != null) ...[
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: KColors.warning),
              const SizedBox(width: 6),
              Expanded(child: RichUz(error.hint!, style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 13.5, height: 1.45))),
            ]),
          ],
        ],
      ),
    );
  }
}

/// Analyzer topgan muammolar ro'yxati.
class ProblemsView extends StatelessWidget {
  const ProblemsView({super.key, required this.diagnostics, this.onTap, this.compact = false});
  final List<Diagnostic> diagnostics;
  final void Function(Diagnostic d)? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (diagnostics.isEmpty) {
      return const FeedbackBanner(kind: FeedbackKind.success, title: 'Muammo topilmadi', message: 'Analyzer kodda xato topmadi.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final d in diagnostics) DiagnosticTile(d: d, onTap: onTap == null ? null : () => onTap!(d), compact: compact)],
    );
  }
}

class DiagnosticTile extends StatelessWidget {
  const DiagnosticTile({super.key, required this.d, this.onTap, this.compact = false});
  final Diagnostic d;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final isError = d.isError;
    final color = isError ? k.errorText : k.warningText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isError ? k.errorSoft : k.warningSoft,
        borderRadius: BorderRadius.circular(KRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(KRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('${d.line}:${d.column}', style: codeStyle(size: 12, color: color, weight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(isError ? 'Xato'.uz : 'Ogohlantirish'.uz,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  RichUz(d.message, style: context.text.bodyMedium!.copyWith(color: k.text)),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(d.original, style: codeStyle(size: 12, color: k.textMuted)),
                  ],
                  if (d.hint != null) ...[
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.lightbulb_outline_rounded, size: 15, color: KColors.warning),
                      const SizedBox(width: 6),
                      Expanded(child: RichUz(d.hint!, style: context.text.bodySmall!.copyWith(color: k.textSecondary))),
                    ]),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
