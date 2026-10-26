import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide Block;
import 'package:url_launcher/url_launcher.dart';

import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../animations/edu_animations.dart';
import '../code/code_view.dart';
import 'runnable_code.dart';

/// Bitta dars blokini chizadi.
class BlockView extends StatelessWidget {
  const BlockView(this.block, {super.key, this.lessonId});
  final Block block;
  final String? lessonId;

  @override
  Widget build(BuildContext context) {
    final b = block;
    final body = context.text.bodyLarge!;
    return switch (b) {
      ParaBlock() => RichUz(b.text, style: body),
      HeadingBlock() => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Semantics(header: true, child: UzText(b.text, style: context.text.titleLarge)),
      ),
      BulletsBlock() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < b.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 3, right: 10),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: context.k.primarySoft, borderRadius: BorderRadius.circular(b.ordered ? 7 : 11)),
                child: b.ordered
                    ? Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: KColors.primary))
                    : const Icon(Icons.circle, size: 7, color: KColors.primary),
              ),
              Expanded(child: RichUz(b.items[i], style: body)),
            ]),
          ),
      ]),
      CalloutBlock() => _Callout(b),
      AnalogyBlock() => AnalogyCard(b),
      TermBlock() => TermCard(b),
      AnimationBlock() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        EduAnimation(b.id),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.animation_rounded, size: 16, color: KColors.primary),
          const SizedBox(width: 6),
          Expanded(child: RichUz(b.caption, style: context.text.bodySmall)),
        ]),
      ]),
      SyntaxBlock() => SyntaxView(b),
      CodeBlock() => RunnableCode(block: b, lessonId: lessonId),
      CodeBlockGroup() => Column(children: [for (final c in b.blocks) Padding(padding: const EdgeInsets.only(bottom: 12), child: RunnableCode(block: c, lessonId: lessonId))]),
      BuggyCodeBlock() => BugFixer(block: b, lessonId: lessonId),
      CompareBlock() => _Compare(b),
      TerminalDemoBlock() => _TerminalDemo(b),
      WidgetLabBlock() => KCard(
        onTap: () => context.go('/practice/widgets/${b.labId}'),
        child: Row(children: [
          const KIconBox(Icons.widgets_rounded, color: KColors.cyan),
          const SizedBox(width: 12),
          Expanded(child: RichUz(b.caption, style: context.text.bodyMedium)),
          const Icon(Icons.open_in_new_rounded),
        ]),
      ),
    };
  }
}

class _Callout extends StatelessWidget {
  const _Callout(this.b);
  final CalloutBlock b;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (b.kind) {
      CalloutKind.info => (KColors.primary, Icons.info_outline_rounded),
      CalloutKind.tip => (KColors.success, Icons.tips_and_updates_outlined),
      CalloutKind.warning => (KColors.warning, Icons.warning_amber_rounded),
      CalloutKind.success => (KColors.success, Icons.verified_outlined),
      CalloutKind.why => (KColors.violet, Icons.help_outline_rounded),
      CalloutKind.where => (KColors.cyan, Icons.place_outlined),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(KRadius.md),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(b.title, style: context.text.titleSmall!.copyWith(color: color)),
            const SizedBox(height: 4),
            RichUz(b.text, style: context.text.bodyMedium!.copyWith(color: context.k.text)),
          ]),
        ),
      ]),
    );
  }
}

class AnalogyCard extends StatelessWidget {
  const AnalogyCard(this.b, {super.key});
  final AnalogyBlock b;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [KColors.warning.withValues(alpha: 0.16), KColors.orange.withValues(alpha: 0.06)],
      ),
      borderRadius: BorderRadius.circular(KRadius.lg),
      border: Border.all(color: KColors.warning.withValues(alpha: 0.4)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      KIconBox(b.icon, color: KColors.orange, size: 46, filled: true),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // "Hayotiy misol" bo'lim sarlavhasida yozilgan — bu yerda takrorlanmaydi.
          UzText(b.title, style: context.text.titleMedium),
          const SizedBox(height: 6),
          RichUz(b.text, style: context.text.bodyMedium!.copyWith(color: context.k.text)),
        ]),
      ),
    ]),
  );
}

class TermCard extends StatelessWidget {
  const TermCard(this.b, {super.key});
  final TermBlock b;

  @override
  Widget build(BuildContext context) => KCard(
    padding: EdgeInsets.zero,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: const Icon(Icons.translate_rounded, color: KColors.violet),
        title: Text(b.term, style: context.text.titleSmall!.copyWith(color: KColors.violet)),
        subtitle: UzText(b.uz, style: context.text.bodySmall),
        children: [
          RichUz(b.meaning, style: context.text.bodyMedium),
          if (b.why.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.help_outline_rounded, size: 16, color: KColors.primary),
              const SizedBox(width: 6),
              Expanded(child: RichUz('**Nima uchun kerak:** ${b.why}', style: context.text.bodySmall!.copyWith(color: context.k.textSecondary))),
            ]),
          ],
          if (b.example != null) ...[const SizedBox(height: 8), KodChip(b.example!)],
        ],
      ),
    ),
  );
}

class SyntaxView extends StatelessWidget {
  const SyntaxView(this.b, {super.key});
  final SyntaxBlock b;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    CodeFrame(title: b.title, child: CodeView(code: b.code, showLineNumbers: false)),
    const SizedBox(height: 10),
    for (final p in b.parts)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: LayoutBuilder(builder: (context, c) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Uzun bo'lak (masalan, `StatelessWidget`) yarim kenglikdan oshmasin — kichrayadi.
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 90, maxWidth: c.maxWidth * 0.5),
            child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: KodChip(p.part)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 2), child: RichUz(p.meaning, style: context.text.bodyMedium))),
        ])),
      ),
  ]);
}

class _Compare extends StatelessWidget {
  const _Compare(this.b);
  final CompareBlock b;

  @override
  Widget build(BuildContext context) {
    final left = CodeFrame(title: b.leftTitle, child: CodeView(code: b.left, showLineNumbers: false));
    final right = CodeFrame(title: b.rightTitle, child: CodeView(code: b.right, showLineNumbers: false));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      context.isCompact
          ? Column(children: [left, const SizedBox(height: 10), right])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: left), const SizedBox(width: 12), Expanded(child: right)]),
      if (b.note != null) ...[const SizedBox(height: 8), RichUz(b.note!, style: context.text.bodySmall)],
    ]);
  }
}

class _TerminalDemo extends StatelessWidget {
  const _TerminalDemo(this.b);
  final TerminalDemoBlock b;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(KRadius.md)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (cmd, out) in b.lines) ...[
          Text.rich(TextSpan(children: [
            TextSpan(text: 'student@kitob:~\$ ', style: codeStyle(size: 13, color: const Color(0xFF7DD3FC))),
            TextSpan(text: cmd, style: codeStyle(size: 13, color: Colors.white)),
          ])),
          if (out.isNotEmpty) Text(out, style: codeStyle(size: 13, color: const Color(0xFFA5E38B))),
        ],
      ]),
    ),
    if (b.caption != null) ...[const SizedBox(height: 6), RichUz(b.caption!, style: context.text.bodySmall)],
    const SizedBox(height: 8),
    Align(
      alignment: Alignment.centerLeft,
      child: KButton(label: 'Terminal laboratoriyasida sinash', icon: Icons.terminal_rounded, variant: KButtonVariant.secondary, compact: true, onPressed: () => context.go('/practice/terminal')),
    ),
  ]);
}

class DocLinksView extends StatelessWidget {
  const DocLinksView(this.links, {super.key});
  final List<DocLink> links;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
    for (final l in links)
      ActionChip(
        avatar: const Icon(Icons.open_in_new_rounded, size: 16),
        label: Text(l.title.uz),
        onPressed: () => launchUrl(Uri.parse(l.url), mode: LaunchMode.externalApplication),
      ),
  ]);
}
