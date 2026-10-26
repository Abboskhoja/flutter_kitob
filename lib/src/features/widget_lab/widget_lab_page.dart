import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../code/code_view.dart';
import 'labs.dart';

class WidgetLabPage extends StatelessWidget {
  const WidgetLabPage({super.key, this.labId});
  final String? labId;

  @override
  Widget build(BuildContext context) {
    final lab = labById(labId);
    if (lab != null) return _LabDetail(key: ValueKey(lab.id), lab: lab);
    return Scaffold(
extendBodyBehindAppBar: true,
      appBar: KTopBar(title: 'Widget laboratoriyasi', onBack: () => context.canPop() ? context.pop() : context.go('/practice'), showBack: !context.isExpanded),
      body: Builder(builder: (context) => ListView(padding: pagePadding(context), children: [
        ContentWidth(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RichUz('Har bir laboratoriyada widget xususiyatlarini o\'zgartirasiz — **haqiqiy Flutter widgeti** darhol yangilanadi va unga mos **kod** yoziladi.',
                style: context.text.bodyLarge),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 520 ? 2 : 1);
              final w = (c.maxWidth - (cols - 1) * 12) / cols;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final l in widgetLabs)
                  SizedBox(
                    width: w,
                    child: KCard(
                      onTap: () => context.go('/practice/widgets/${l.id}'),
                      child: Row(children: [
                        KIconBox(l.icon, color: KColors.cyan, size: 46),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.title.uz, style: context.text.titleMedium),
                            const SizedBox(height: 2),
                            RichUz(l.description, style: context.text.bodySmall, maxLines: 2),
                          ]),
                        ),
                      ]),
                    ),
                  ),
              ]);
            }),
            const SizedBox(height: 16),
            const FeedbackBanner(
              kind: FeedbackKind.info,
              title: 'Cheklov haqida ochiq',
              message: 'Laboratoriyalar parametrli: siz xususiyatlarni boshqaruvlar orqali o\'zgartirasiz. Erkin yozilgan Flutter kodini telefon ichida kompilyatsiya qilib bo\'lmaydi, shuning uchun kod maydoni bu yerda faqat o\'qish uchun.',
            ),
          ]),
        ),
      ])),
    );
  }
}

class _LabDetail extends ConsumerStatefulWidget {
  const _LabDetail({super.key, required this.lab});
  final LabDef lab;

  @override
  ConsumerState<_LabDetail> createState() => _LabDetailState();
}

class _LabDetailState extends ConsumerState<_LabDetail> {
  late LabState _s = Map.of(widget.lab.initial);
  int _changes = 0;

  void _set(String k, Object v) {
    setState(() => _s = {..._s, k: v});
    _changes++;
    if (_changes == 3) ref.read(progressProvider.notifier).recordLabUse();
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.lab;
    final wide = context.screenWidth >= 980;
    final preview = Container(
      constraints: const BoxConstraints(minHeight: 280),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1B2540) : Colors.white,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: context.k.border),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter(context.k.border))),
        Positioned(left: 12, top: 10, child: KBadge('Jonli preview', icon: Icons.visibility_rounded, color: KColors.success)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
          child: Center(
            child: Theme(
              data: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue, brightness: Brightness.light, fontFamily: 'Inter'),
              child: Material(color: Colors.transparent, child: FittedBox(fit: BoxFit.scaleDown, child: lab.preview(context, _s, _set))),
            ),
          ),
        ),
      ]),
    );
    final code = CodeFrame(title: '${lab.id}.dart', code: lab.code(_s), child: CodeView(code: lab.code(_s), showLineNumbers: true));
    final controls = _Controls(lab: lab, state: _s, onChanged: _set, onReset: () => setState(() => _s = Map.of(lab.initial)));
    final info = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      RichUz(lab.description, style: context.text.bodyMedium),
      for (final t in lab.tips) ...[const SizedBox(height: 8), FeedbackBanner(kind: FeedbackKind.info, title: 'Maslahat', message: t)],
    ]);
    return Scaffold(
extendBodyBehindAppBar: true,
      appBar: KTopBar(title: lab.title),
      body: Builder(builder: (context) => wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 340, child: ListView(padding: pagePadding(context).copyWith(left: 16, right: 16), children: [info, const SizedBox(height: 16), controls])),
              VerticalDivider(width: 1, color: context.k.border),
              Expanded(child: ListView(padding: pagePadding(context).copyWith(left: 20, right: 20), children: [preview, const SizedBox(height: 16), code])),
            ])
          : ListView(padding: pagePadding(context), children: [
              preview,
              const SizedBox(height: 12),
              info,
              const SizedBox(height: 12),
              controls,
              const SizedBox(height: 16),
              code,
            ])),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.lab, required this.state, required this.onChanged, required this.onReset});
  final LabDef lab;
  final LabState state;
  final void Function(String, Object) onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => KCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text('Xususiyatlar'.uz, style: context.text.titleMedium)),
        TextButton.icon(onPressed: onReset, icon: const Icon(Icons.restart_alt_rounded, size: 18), label: Text('Asl holat'.uz)),
      ]),
      for (final c in lab.controls) ...[
        const SizedBox(height: 10),
        Text(c.label, style: codeStyle(size: 12.5, color: context.k.textSecondary, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        switch (c) {
          SliderCtl() => Row(children: [
            Expanded(
              child: Slider(
                value: (state[c.key] as num).toDouble().clamp(c.min, c.max),
                min: c.min,
                max: c.max,
                divisions: c.divisions ?? (c.max - c.min).round(),
                label: n((state[c.key] as num).toDouble()),
                onChanged: (v) => onChanged(c.key, v),
              ),
            ),
            SizedBox(width: 44, child: Text(n((state[c.key] as num).toDouble()), textAlign: TextAlign.end, style: codeStyle(size: 13, color: context.k.text))),
          ]),
          ChoiceCtl() => Wrap(spacing: 6, runSpacing: 6, children: [
            for (final o in c.options)
              ChoiceChip(
                label: Text(o, style: codeStyle(size: 12, color: context.k.text)),
                selected: state[c.key] == o,
                onSelected: (_) => onChanged(c.key, o),
              ),
          ]),
          ColorCtl() => Wrap(spacing: 8, runSpacing: 8, children: [
            for (final e in labColors.entries)
              Tooltip(
                message: 'Colors.${e.key}',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onChanged(c.key, e.key),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: state[c.key] == e.key ? KColors.primary : context.k.border, width: state[c.key] == e.key ? 3 : 1),
                    ),
                    child: state[c.key] == e.key ? Icon(Icons.check_rounded, size: 16, color: e.key == 'white' ? Colors.black : Colors.white) : null,
                  ),
                ),
              ),
          ]),
          ToggleCtl() => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state[c.key] == true ? 'Yoqilgan'.uz : 'O\'chirilgan'.uz),
            value: state[c.key] as bool,
            onChanged: (v) => onChanged(c.key, v),
          ),
          TextCtl() => TextFormField(
            initialValue: state[c.key] as String,
            onChanged: (v) => onChanged(c.key, v),
          ),
        },
      ],
    ]),
  );
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.color != color;
}
