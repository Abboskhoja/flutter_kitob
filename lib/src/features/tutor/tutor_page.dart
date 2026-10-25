import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/curriculum.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/progress.dart';
import '../code/code_view.dart';
import 'tutor_engine.dart';
import 'tutor_gateway.dart';

class _Msg {
  _Msg(this.fromUser, this.text, {this.lessonId, this.suggestions = const [], this.online = false});
  final bool fromUser;
  final String text;
  final String? lessonId;
  final List<String> suggestions;
  final bool online;
}

class TutorPage extends ConsumerStatefulWidget {
  const TutorPage({super.key, this.context});

  /// Dars ID si yoki `code:...` — qaysi kontekstdan ochilgani.
  final String? context;

  @override
  ConsumerState<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends ConsumerState<TutorPage> {
  final _engine = TutorEngine();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  TutorMode _mode = TutorMode.explain;
  Object? _pending;
  String? _lessonId;
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    final ctx = widget.context;
    if (ctx != null && ctx.startsWith('code:')) {
      _mode = TutorMode.debug;
      WidgetsBinding.instance.addPostFrameCallback((_) => _send('```dart\n${ctx.substring(5)}\n```'));
    } else if (ctx != null && lessonById.containsKey(ctx)) {
      _lessonId = ctx;
    }
    final lesson = lessonById[_lessonId];
    _msgs.add(_Msg(
      false,
      'Assalomu alaykum! Men FLUTTER_KITOB ustoziman. 👋\n\n'
      '${lesson != null ? 'Hozir **"${lesson.title}"** darsidasiz — shu mavzu bo\'yicha so\'rang.\n\n' : ''}'
      'Men mavzuni sodda tushuntiraman, misol ko\'rsataman, kodingizni **haqiqatan bajarib** tahlil qilaman va xatoni birga topamiz. '
      'Avval o\'zingiz o\'ylab ko\'rishingiz uchun javobni darhol emas, ishoralar bilan beraman.',
      suggestions: lesson != null
          ? ['${lesson.title} nima?', 'Misol ko\'rsat', 'Meni sinab ko\'r']
          : const ['O\'zgaruvchi nima?', 'for sikli qanday ishlaydi?', 'null safety nima?', 'Widget nima?'],
    ));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty && _mode != TutorMode.quiz && _mode != TutorMode.interview) return;
    var mode = _mode;
    if (t == 'Misol ko\'rsat') mode = TutorMode.example;
    if (t == 'Qadam-baqadam tushuntir') mode = TutorMode.steps;
    if (t == 'Meni sinab ko\'r' || t == 'Yana savol') mode = TutorMode.quiz;
    if (t == 'Keyingi intervyu savoli') mode = TutorMode.interview;
    if (t == 'Sodda tushuntir') mode = TutorMode.explain;
    setState(() {
      if (t.isNotEmpty) _msgs.add(_Msg(true, t));
      _thinking = true;
    });
    _input.clear();
    ref.read(progressProvider.notifier).recordTutorQuestion();
    _scrollDown();

    String? online;
    final isCommand = const {'Misol ko\'rsat', 'Qadam-baqadam tushuntir', 'Meni sinab ko\'r', 'Yana savol', 'Keyingi intervyu savoli', 'Sodda tushuntir'}.contains(t);
    if (onlineTutorConfigured && _pending == null && !isCommand && mode != TutorMode.quiz && mode != TutorMode.interview) {
      online = await askGateway(
        [for (final m in _msgs.skip(1)) GatewayMessage(m.fromUser ? 'user' : 'assistant', m.text)],
        mode: mode.name,
        lessonTitle: lessonById[_lessonId]?.title,
      );
    }
    final query = isCommand ? (_lastUserQuestion() ?? '') : t;
    final reply = online != null
        ? TutorReply(online)
        : _engine.respond(query, mode, lessonId: _lessonId, pending: _pending);
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _pending = reply.pending;
      if (reply.lessonId != null) _lessonId = reply.lessonId;
      _msgs.add(_Msg(false, reply.text, lessonId: reply.lessonId, suggestions: reply.suggestions, online: online != null));
    });
    _scrollDown();
  }

  String? _lastUserQuestion() {
    for (final m in _msgs.reversed) {
      if (m.fromUser && !const {'Misol ko\'rsat', 'Qadam-baqadam tushuntir', 'Meni sinab ko\'r', 'Yana savol', 'Sodda tushuntir'}.contains(m.text)) return m.text;
    }
    return lessonById[_lessonId]?.title;
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: KDurations.medium, curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) {
    final lesson = lessonById[_lessonId];
    return Scaffold(
      appBar: AppBar(
        leading: context.isExpanded ? null : IconButton(onPressed: () => context.canPop() ? context.pop() : context.go('/home'), icon: const Icon(Icons.arrow_back_rounded)),
        title: Row(children: [
          const KIconBox(Icons.auto_awesome_rounded, size: 34, filled: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI ustoz'.uz, style: context.text.titleMedium),
              Text((onlineTutorConfigured ? 'Onlayn + oflayn bilim bazasi' : 'Oflayn rejim · dars va dvigatel asosida').uz, style: context.text.bodySmall),
            ]),
          ),
        ]),
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                for (final m in TutorMode.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Tooltip(
                      message: m.subtitle.uz,
                      child: ChoiceChip(
                        label: Text(m.title.uz),
                        selected: _mode == m,
                        onSelected: (_) {
                          setState(() {
                            _mode = m;
                            _pending = null;
                          });
                          if (m == TutorMode.quiz || m == TutorMode.interview) _send('');
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (lesson != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Icon(Icons.menu_book_rounded, size: 16, color: context.k.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text('Kontekst: ${lesson.title}'.uz, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                TextButton(onPressed: () => setState(() => _lessonId = null), child: Text('Tozalash'.uz)),
              ]),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: _msgs.length + (_thinking ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _msgs.length) return const _Typing();
                final m = _msgs[i];
                return _Bubble(msg: m, onSuggestion: _send, onOpenLesson: (id) => context.go('/learn/lesson/$id'));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(color: context.k.surface, border: Border(top: BorderSide(color: context.k.border))),
            child: ContentWidth(
              maxWidth: 900,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 6,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: (_pending != null ? 'Javobingizni yozing...' : 'Savol yozing yoki kod joylashtiring...').uz,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(tooltip: 'Yuborish', onPressed: _thinking ? null : () => _send(_input.text), icon: const Icon(Icons.send_rounded)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, required this.onSuggestion, required this.onOpenLesson});
  final _Msg msg;
  final ValueChanged<String> onSuggestion;
  final ValueChanged<String> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final user = msg.fromUser;
    final parts = <Widget>[];
    final fence = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    var last = 0;
    for (final m in fence.allMatches(msg.text)) {
      final before = msg.text.substring(last, m.start).trim();
      if (before.isNotEmpty) parts.add(_text(context, before, user));
      final lang = m.group(1)!;
      final code = m.group(2)!.trimRight();
      parts.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: lang == 'dart'
            ? CodeFrame(code: code, child: CodeView(code: code, showLineNumbers: false))
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: context.k.console, borderRadius: BorderRadius.circular(10)),
                child: SelectableText(code, style: codeStyle(size: 13, color: const Color(0xFFA5E38B))),
              ),
      ));
      last = m.end;
    }
    final tail = msg.text.substring(last).trim();
    if (tail.isNotEmpty) parts.add(_text(context, tail, user));

    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.screenWidth >= 900 ? 720 : context.screenWidth * 0.9),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: user ? KColors.primary : context.k.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(user ? 16 : 4),
              bottomRight: Radius.circular(user ? 4 : 16),
            ),
            border: user ? null : Border.all(color: context.k.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...parts,
            if (msg.online) ...[const SizedBox(height: 6), const KBadge('Onlayn AI', color: KColors.violet)],
            if (!user && msg.lessonId != null) ...[
              const SizedBox(height: 8),
              ActionChip(avatar: const Icon(Icons.menu_book_rounded, size: 16), label: Text('Darsni ochish'.uz), onPressed: () => onOpenLesson(msg.lessonId!)),
            ],
            if (!user && msg.suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final s in msg.suggestions) ActionChip(label: Text(s.uz), onPressed: () => onSuggestion(s)),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _text(BuildContext context, String t, bool user) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: RichUz(t, style: context.text.bodyLarge!.copyWith(color: user ? Colors.white : context.k.text)),
  );
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: context.k.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.k.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 8),
        Text('O\'ylayapman...'.uz, style: context.text.bodySmall),
      ]),
    ),
  );
}
