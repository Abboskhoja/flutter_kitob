import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/glossary.dart';
import '../../content/model.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../projects/projects_data.dart';
import '../widget_lab/labs.dart';

class _ErrorInfo {
  const _ErrorInfo(this.original, this.uz, this.fix);
  final String original;
  final String uz;
  final String fix;
}

const _errors = [
  _ErrorInfo("Expected ';' after this.", 'Buyruq oxirida nuqtali vergul yetishmayapti.', "Qator oxiriga `;` qo'ying."),
  _ErrorInfo("Undefined name 'x'.", 'Bunday nomli o\'zgaruvchi yoki funksiya e\'lon qilinmagan.', 'Nomni to\'g\'ri yozganingizni tekshiring (katta-kichik harf!) yoki avval e\'lon qiling.'),
  _ErrorInfo("The function 'x' isn't defined.", 'Bunday funksiya yo\'q.', 'Imloni tekshiring: `Print` emas `print`.'),
  _ErrorInfo("A value of type 'String' can't be assigned to a variable of type 'int'.", 'Turi mos kelmaydi.', 'Qiymatni to\'g\'ri turga aylantiring: `int.parse(matn)`.'),
  _ErrorInfo("The property 'x' can't be unconditionally accessed because the receiver can be 'null'.", 'Qiymat null bo\'lishi mumkin.', '`?.`, `??` ishlating yoki `if (x != null)` bilan tekshiring.'),
  _ErrorInfo("The final variable 'x' can only be set once.", 'final o\'zgaruvchini qayta o\'zgartirib bo\'lmaydi.', '`var` ishlating.'),
  _ErrorInfo('RangeError (index): Invalid value: Not in inclusive range', 'Ro\'yxatda bunday indeks yo\'q.', 'Indeks 0 dan `length - 1` gacha.'),
  _ErrorInfo('FormatException: Invalid radix-10 number', 'Matnni songa aylantirib bo\'lmadi.', '`int.tryParse` ishlating.'),
  _ErrorInfo('Null check operator used on a null value', '`!` ishlatilgan qiymat null chiqdi.', '`!` o\'rniga `??` yoki tekshiruv.'),
  _ErrorInfo("The body might complete normally, causing 'null' to be returned", 'Funksiya ba\'zi hollarda qiymat qaytarmaydi.', 'Funksiya oxiriga `return` qo\'shing.'),
  _ErrorInfo("Missing concrete implementation of", 'Abstrakt metod amalga oshirilmagan.', '`@override` bilan metodni yozing.'),
  _ErrorInfo("Non-nullable instance field 'x' must be initialized.", 'Maydonga qiymat berilmagan.', 'Konstruktorga `this.x` qo\'shing.'),
  _ErrorInfo('Conditions must have a static type of \'bool\'.', 'Shart true/false bo\'lishi kerak.', 'Taqqoslash yozing: `if (son > 0)`.'),
  _ErrorInfo('A RenderFlex overflowed by', 'Widget ekranga sig\'madi (Flutter layout xatosi).', 'Matnni `Expanded`/`Flexible` ga o\'rang yoki `SingleChildScrollView` ishlating.'),
];

const _commands = [
  ('pwd', 'Joriy papka yo\'lini ko\'rsatadi'),
  ('ls', 'Papka ichidagilarni ko\'rsatadi'),
  ('cd', 'Papkaga o\'tish'),
  ('mkdir', 'Yangi papka yaratish'),
  ('touch', 'Bo\'sh fayl yaratish'),
  ('cat', 'Fayl ichini ko\'rsatish'),
  ('flutter create', 'Yangi Flutter loyiha yaratish'),
  ('flutter run', 'Ilovani qurilmada ishga tushirish'),
  ('flutter pub get', 'Paketlarni yuklab olish'),
  ('flutter analyze', 'Kodni statik tekshirish'),
  ('flutter test', 'Testlarni ishga tushirish'),
  ('flutter build', 'Release build (apk, ios, web)'),
  ('flutter doctor', 'O\'rnatish muammolarini tekshirish'),
  ('dart run', 'Dart dasturini bajarish'),
  ('git commit', 'O\'zgarishlarni saqlash (Git)'),
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initial});
  final String? initial;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _ctrl = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _hit(String hay, String q) => hay.toLowerCase().contains(q);

  String _lessonText(Lesson l) => [
    l.title,
    l.subtitle,
    ...l.objectives,
    ...l.terms.map((t) => '${t.term} ${t.uz}'),
    ...l.skills,
    l.example?.code ?? '',
  ].join(' ');

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.text.trim().toLowerCase();
    final lessons = q.isEmpty ? <Lesson>[] : allLessons.where((l) => _hit(_lessonText(l), q)).toList();
    final topics = q.isEmpty
        ? <(Level, String)>[]
        : [for (final lv in curriculum) for (final t in lv.topics) if (_hit(t, q)) (lv, t)];
    final terms = q.isEmpty ? <GlossaryTerm>[] : searchGlossary(q);
    final labs = q.isEmpty ? <LabDef>[] : widgetLabs.where((l) => _hit('${l.title} ${l.description}', q)).toList();
    final cmds = q.isEmpty ? <(String, String)>[] : _commands.where((c) => _hit('${c.$1} ${c.$2}', q)).toList();
    final errs = q.isEmpty ? <_ErrorInfo>[] : _errors.where((e) => _hit('${e.original} ${e.uz}', q)).toList();
    final projects = q.isEmpty ? <ProjectDef>[] : allProjects.where((p) => _hit('${p.title} ${p.brief}', q)).toList();
    final total = lessons.length + terms.length + labs.length + cmds.length + errs.length + projects.length + topics.length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Dars, widget, xato matni, buyruq...'.uz,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: q.isEmpty ? null : IconButton(onPressed: () => setState(_ctrl.clear), icon: const Icon(Icons.close_rounded)),
          ),
        ),
      ),
      body: ListView(padding: pagePadding(context), children: [
        ContentWidth(
          maxWidth: 900,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (q.isEmpty) ...[
              UzText('Mashhur qidiruvlar', style: context.text.titleMedium),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in const ['o\'zgaruvchi', 'List', 'null', 'for', 'class', 'Container', 'Row', 'flutter create', 'Undefined name'])
                  ActionChip(label: Text(s.uz), onPressed: () => setState(() => _ctrl.text = s)),
              ]),
            ] else if (total == 0)
              EmptyState(
                icon: Icons.manage_search_rounded,
                title: 'Hech narsa topilmadi',
                message: '"${_ctrl.text}" bo\'yicha platformada hali dars yoki ma\'lumot yo\'q. Mavjud bo\'lmagan dars uydirilmaydi. AI ustozdan so\'rang yoki rasmiy hujjatlarga qarang: dart.dev, docs.flutter.dev',
                action: 'AI ustozdan so\'rash',
                onAction: () => context.go('/home/tutor'),
              ),
            if (lessons.isNotEmpty) ...[
              SectionHeader('Darslar (${lessons.length})', icon: Icons.menu_book_rounded),
              for (final l in lessons)
                _R(icon: l.icon, title: l.title, sub: '${levelOfLesson[l.id]!.number}-daraja · ${l.subtitle}', onTap: () => context.go('/learn/lesson/${l.id}')),
            ],
            if (terms.isNotEmpty) ...[
              SectionHeader('Atamalar (${terms.length})', icon: Icons.translate_rounded),
              for (final t in terms.take(8))
                _R(icon: Icons.translate_rounded, title: '${t.term} — ${t.uz}', sub: t.meaning, onTap: t.lessonId == null ? () => context.go('/learn/glossary') : () => context.go('/learn/lesson/${t.lessonId}')),
            ],
            if (errs.isNotEmpty) ...[
              SectionHeader('Xato xabarlari (${errs.length})', icon: Icons.error_outline_rounded),
              for (final e in errs)
                KCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.original, style: codeStyle(size: 12.5, color: context.k.errorText)),
                    const SizedBox(height: 6),
                    RichUz(e.uz, style: context.text.titleSmall),
                    const SizedBox(height: 4),
                    RichUz('**Tuzatish:** ${e.fix}', style: context.text.bodyMedium),
                  ]),
                ),
            ],
            if (labs.isNotEmpty) ...[
              SectionHeader('Widget laboratoriyalari (${labs.length})', icon: Icons.widgets_rounded),
              for (final l in labs) _R(icon: l.icon, title: l.title, sub: l.description.uz.replaceAll('`', ''), onTap: () => context.go('/practice/widgets/${l.id}')),
            ],
            if (cmds.isNotEmpty) ...[
              SectionHeader('Terminal buyruqlari (${cmds.length})', icon: Icons.terminal_rounded),
              for (final c in cmds) _R(icon: Icons.terminal_rounded, title: c.$1, sub: c.$2, onTap: () => context.go('/practice/terminal')),
            ],
            if (projects.isNotEmpty) ...[
              SectionHeader('Loyihalar (${projects.length})', icon: Icons.rocket_launch_rounded),
              for (final p in projects) _R(icon: p.icon, title: p.title, sub: p.brief, onTap: () => context.go('/practice/projects/${p.id}')),
            ],
            if (topics.isNotEmpty) ...[
              SectionHeader('O\'quv dasturidagi mavzular (${topics.length})', icon: Icons.route_rounded),
              for (final (lv, t) in topics.take(10))
                _R(icon: lv.icon, title: t, sub: '${lv.number}-daraja · ${lv.title}${lv.isReady ? '' : ' · tayyorlanmoqda'}', onTap: () => context.go('/learn/level/${lv.number}')),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _R extends StatelessWidget {
  const _R({required this.icon, required this.title, required this.sub, required this.onTap});
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: KCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(children: [
        KIconBox(icon, size: 38, color: KColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UzText(title, style: context.text.titleSmall, maxLines: 1),
            UzText(sub, style: context.text.bodySmall, maxLines: 2),
          ]),
        ),
      ]),
    ),
  );
}
