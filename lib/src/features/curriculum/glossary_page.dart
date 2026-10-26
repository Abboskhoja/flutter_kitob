import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/glossary.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';

class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key});

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final items = searchGlossary(_q);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const KTopBar(title: 'Atamalar lug\'ati'),
      body: Builder(builder: (context) => ListView(
        padding: pagePadding(context),
        children: [
          ContentWidth(
            maxWidth: 860,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              UzText('Har bir inglizcha atama: asl nomi, o\'zbekcha izohi va qaysi darsda o\'rganilgani.', style: context.text.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(hintText: 'Atama qidirish: variable, widget, API...'.uz, prefixIcon: const Icon(Icons.search_rounded)),
                onChanged: (v) => setState(() => _q = v),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Atama topilmadi',
                  message: '"$_q" bo\'yicha lug\'atda ma\'lumot yo\'q. Boshqa so\'z bilan qidirib ko\'ring yoki umumiy qidiruvdan foydalaning.',
                ),
              for (final t in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KCard(
                    onTap: t.lessonId == null ? null : () => context.go('/learn/lesson/${t.lessonId}'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(t.term, style: context.text.titleMedium!.copyWith(color: KColors.primary))),
                        KBadge(t.category, color: KColors.violet),
                      ]),
                      const SizedBox(height: 2),
                      UzText(t.uz, style: context.text.titleSmall),
                      const SizedBox(height: 6),
                      RichUz(t.meaning, style: context.text.bodyMedium),
                      if (t.example != null) ...[const SizedBox(height: 8), KodChip(t.example!)],
                      if (t.lessonId != null) ...[
                        const SizedBox(height: 8),
                        Text('📘 ${lessonById[t.lessonId]?.title ?? ''}'.uz, style: context.text.labelMedium),
                      ],
                    ]),
                  ),
                ),
            ]),
          ),
        ],
      )),
    );
  }
}
