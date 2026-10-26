import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../content/interview.dart';
import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/motion.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../../core/storage/store.dart';
import '../../shared/bitik.dart';
import '../code/code_view.dart';

/// O'quvchi o'zi "bilaman" deb belgilagan savollar (qurilmada saqlanadi).
///
/// O'z-o'zini baholash uchun XP berilmaydi — tugma bosish bilan ball
/// yig'ilmasin; bu faqat takrorlash ro'yxatini boshqaradi.
class InterviewNotifier extends Notifier<Set<String>> {
  static const _key = 'interview';

  @override
  Set<String> build() {
    final j = ref.read(storeProvider).readJson(_key);
    return {...((j?['known'] as List?) ?? const []).cast<String>()};
  }

  void mark(String id, {required bool known}) {
    state = known ? {...state, id} : ({...state}..remove(id));
    ref.read(storeProvider).writeJson(_key, {'known': state.toList()});
  }
}

final interviewProvider = NotifierProvider<InterviewNotifier, Set<String>>(InterviewNotifier.new);

class InterviewPage extends ConsumerStatefulWidget {
  const InterviewPage({super.key});

  @override
  ConsumerState<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends ConsumerState<InterviewPage> {
  InterviewTrack? _track;
  InterviewLevel? _level;
  bool _revealed = false;
  int _cursor = 0;
  BitikMood _mood = BitikMood.think;

  List<InterviewQuestion> get _filtered => [
    for (final q in interviewQuestions)
      if ((_track == null || q.track == _track) && (_level == null || q.level == _level)) q,
  ];

  /// Kartochka: avval hali "bilaman" deyilmagan savollar.
  InterviewQuestion? _current(Set<String> known) {
    final pool = _filtered.where((q) => !known.contains(q.id)).toList();
    if (pool.isEmpty) return null;
    return pool[_cursor % pool.length];
  }

  void _rate(InterviewQuestion q, bool known) {
    kHaptic(context);
    ref.read(interviewProvider.notifier).mark(q.id, known: known);
    setState(() {
      _revealed = false;
      _mood = known ? BitikMood.happy : BitikMood.encourage;
      // "Qayta ko'raman" — savol ro'yxat oxiriga suriladi.
      if (!known) _cursor++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final known = ref.watch(interviewProvider);
    final all = _filtered;
    final done = all.where((q) => known.contains(q.id)).length;
    final current = _current(known);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: KTopBar(title: 'Intervyuga tayyorgarlik', onBack: () => context.canPop() ? context.pop() : context.go('/practice'), showBack: !context.isExpanded),
      body: Builder(
        builder: (context) => ListView(padding: pagePadding(context), children: [
          ContentWidth(
            maxWidth: 860,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              RichUz(
                'Junior va Middle Flutter dasturchi intervyularida **eng ko\'p so\'raladigan** savollar. Avval o\'zingiz javob berib ko\'ring, keyin namunaviy javob bilan solishtiring.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _chip('Hammasi', _track == null, () => setState(() => _track = null)),
                for (final t in InterviewTrack.values) _chip(t.title, _track == t, () => setState(() => _track = t)),
                for (final l in InterviewLevel.values) _chip(l.title, _level == l, () => setState(() => _level = _level == l ? null : l)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: KProgressBar(value: all.isEmpty ? 0 : done / all.length, color: KColors.success)),
                const SizedBox(width: 10),
                Text('$done / ${all.length} bilaman'.uz, style: context.text.labelLarge),
              ]),
              const SizedBox(height: KSpace.lg),
              AnimatedSwitcher(
                duration: KDurations.medium,
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a), child: c),
                ),
                child: current == null
                    ? KCard(
                        key: const ValueKey('done'),
                        child: BitikSays(
                          mood: BitikMood.cheer,
                          text: all.isEmpty
                              ? 'Bu filtrda savol yo\'q.'
                              : 'Bu bo\'limdagi **barcha** savollarni bilasiz! Pastdagi ro\'yxatdan istalganini qayta ko\'rib chiqishingiz mumkin.',
                        ),
                      )
                    : _Flashcard(
                        key: ValueKey('${current.id}-$_revealed'),
                        q: current,
                        revealed: _revealed,
                        mood: _revealed ? BitikMood.idle : _mood,
                        onReveal: () => setState(() => _revealed = true),
                        onRate: (k) => _rate(current, k),
                      ),
              ),
              const SizedBox(height: KSpace.xxl),
              SectionHeader('Barcha savollar', subtitle: 'Bosib, namunaviy javobni oching', icon: Icons.list_alt_rounded),
              for (final (i, q) in all.indexed)
                Reveal(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _QuestionTile(q: q, known: known.contains(q.id)),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label.uz),
    selected: selected,
    onSelected: (_) => setState(() {
      onTap();
      _cursor = 0;
      _revealed = false;
    }),
  );
}

class _Flashcard extends StatelessWidget {
  const _Flashcard({super.key, required this.q, required this.revealed, required this.mood, required this.onReveal, required this.onRate});
  final InterviewQuestion q;
  final bool revealed;
  final BitikMood mood;
  final VoidCallback onReveal;
  final ValueChanged<bool> onRate;

  @override
  Widget build(BuildContext context) {
    final color = q.track == InterviewTrack.dart ? KColors.primary : KColors.cyan;
    return KCard(
      elevated: true,
      borderColor: color.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(KSpace.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          KBadge(q.track.title, color: color),
          const SizedBox(width: 6),
          KBadge(q.level.title, color: KColors.violet),
          const Spacer(),
          Bitik(mood: mood, size: 48),
        ]),
        const SizedBox(height: 10),
        UzText(q.question, style: context.text.titleLarge),
        const SizedBox(height: 14),
        if (!revealed) ...[
          RichUz('Javobni **ovoz chiqarib** ayting yoki xayolan tuzing — xuddi intervyudagidek. Keyin solishtiring.', style: context.text.bodySmall),
          const SizedBox(height: 12),
          KButton(label: 'Javobni ko\'rsatish', icon: Icons.visibility_rounded, onPressed: onReveal, expand: true),
        ] else ...[
          _Answer(q: q),
          const SizedBox(height: 14),
          Text('Javobingiz shunga yaqinmidi?'.uz, style: context.text.labelLarge),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: KButton(label: 'Qayta ko\'raman', icon: Icons.replay_rounded, variant: KButtonVariant.secondary, onPressed: () => onRate(false))),
            const SizedBox(width: 10),
            Expanded(child: KButton(label: 'Bilaman', icon: Icons.check_rounded, variant: KButtonVariant.success, onPressed: () => onRate(true))),
          ]),
        ],
      ]),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.q});
  final InterviewQuestion q;

  @override
  Widget build(BuildContext context) {
    final lesson = q.lessonId == null ? null : lessonById[q.lessonId];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FeedbackBanner(kind: FeedbackKind.info, title: 'Qisqa javob', message: q.answer),
      const SizedBox(height: 10),
      RichUz(q.details, style: context.text.bodyMedium),
      if (q.code != null) ...[
        const SizedBox(height: 12),
        CodeFrame(title: 'misol.dart', code: q.code, child: CodeView(code: q.code!)),
      ],
      if (lesson != null) ...[
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.go('/learn/lesson/${lesson.id}'),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text('Darsda o\'rganish: ${lesson.title}'.uz),
          ),
        ),
      ],
    ]);
  }
}

class _QuestionTile extends StatefulWidget {
  const _QuestionTile({required this.q, required this.known});
  final InterviewQuestion q;
  final bool known;

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    return KCard(
      onTap: () => setState(() => _open = !_open),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(widget.known ? Icons.check_circle_rounded : Icons.help_outline_rounded, color: widget.known ? KColors.success : context.k.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UzText(q.question, style: context.text.titleSmall),
              const SizedBox(height: 2),
              Text('${q.track.title} · ${q.level.title}', style: context.text.labelSmall),
            ]),
          ),
          AnimatedRotation(turns: _open ? 0.5 : 0, duration: KDurations.medium, child: const Icon(Icons.expand_more_rounded)),
        ]),
        AnimatedSize(
          duration: KDurations.medium,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _open ? Padding(padding: const EdgeInsets.only(top: 12), child: _Answer(q: q)) : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}
