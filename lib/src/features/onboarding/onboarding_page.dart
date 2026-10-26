import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../shared/bitik.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/state/settings.dart';
import '../../shared/logo.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _Slide {
  const _Slide(this.word, this.title, this.text, this.icon, this.color);
  final String word;
  final String title;
  final String text;
  final IconData icon;
  final Color color;
}

const _slides = [
  _Slide(
    'O\'rgan',
    'Noldan, sodda o\'zbek tilida',
    'Har bir mavzu hayotiy misol, animatsiya va qadam-baqadam tushuntirish bilan. Hech qanday atama izohsiz qolmaydi.',
    Icons.menu_book_rounded,
    KColors.primary,
  ),
  _Slide(
    'Kod yoz',
    'Haqiqiy kod — haqiqiy natija',
    'Telefoningizda Dart kodini yozasiz, ishga tushirasiz va natijani darhol ko\'rasiz. Xatolar o\'zbekcha tushuntiriladi.',
    Icons.code_rounded,
    KColors.cyan,
  ),
  _Slide(
    'Yarat',
    'Bilimingizni isbotlang',
    'Testlar, debugging mashqlari va loyihalar orqali haqiqiy dastur yaratish ko\'nikmasini egallaysiz.',
    Icons.rocket_launch_rounded,
    KColors.violet,
  ),
];

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _page = PageController();
  int _index = 0;
  StartLevel _level = StartLevel.beginner;
  int _dailyMinutes = 10;
  final _name = TextEditingController();

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length) {
      _page.nextPage(duration: KDurations.slow, curve: Curves.easeOutCubic);
    } else {
      ref
          .read(settingsProvider.notifier)
          .completeOnboarding(
            name: _name.text,
            level: _level,
            dailyMinutes: _dailyMinutes,
          );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider).language;
    final wide = context.screenWidth >= KBreakpoints.medium;
    final isLast = _index == _slides.length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  const KitobLogo(size: 32),
                  const SizedBox(width: 10),
                  Text(
                    'FLUTTER_KITOB',
                    style: context.text.titleSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: () => _page.animateToPage(
                        _slides.length,
                        duration: KDurations.slow,
                        curve: Curves.easeOutCubic,
                      ),
                      child: Text('O\'tkazib yuborish'.uz),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    _SlideView(slide: _slides[i], index: i, wide: wide),
                  _LevelPicker(
                    level: _level,
                    onLevel: (l) => setState(() => _level = l),
                    name: _name,
                    language: language,
                    onLanguage: ref.read(settingsProvider.notifier).setLanguage,
                    dailyMinutes: _dailyMinutes,
                    onDailyMinutes: (minutes) =>
                        setState(() => _dailyMinutes = minutes),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ContentWidth(
                maxWidth: 560,
                child: Row(
                  children: [
                    for (var i = 0; i <= _slides.length; i++)
                      AnimatedContainer(
                        duration: KDurations.medium,
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? KColors.primary
                              : context.k.borderStrong,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    const Spacer(),
                    KButton(
                      label: isLast ? 'O\'qishni boshlash' : 'Keyingi',
                      trailingIcon: isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.wide,
  });
  final _Slide slide;
  final int index;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        KBadge('${index + 1} / 3', color: slide.color),
        const SizedBox(height: 14),
        Text(
          slide.word.uz,
          style: context.text.displaySmall!.copyWith(color: slide.color),
        ),
        const SizedBox(height: 6),
        UzText(
          slide.title,
          style: context.text.headlineSmall,
          textAlign: wide ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: 12),
        RichUz(
          slide.text,
          style: context.text.bodyLarge,
          textAlign: wide ? TextAlign.start : TextAlign.center,
        ),
      ],
    );
    final phone = _PhoneMockup(index: index);
    return ContentWidth(
      maxWidth: 980,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: wide
            ? Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 40),
                  phone,
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    phone,
                    const SizedBox(height: 24),
                    text,
                  ],
                ),
              ),
      ),
    );
  }
}

/// Interaktiv telefon ko'rinishi: tugmani bossangiz ekran o'zgaradi.
class _PhoneMockup extends StatefulWidget {
  const _PhoneMockup({required this.index});
  final int index;

  @override
  State<_PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<_PhoneMockup> {
  int _lessonStep = 1;
  String? _output;
  int _counter = 0;
  static const _code = "void main() {\n  print('Salom, FLUTTER_KITOB!');\n}";

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final h = (MediaQuery.sizeOf(context).height * 0.46).clamp(340.0, 460.0);
    return Container(
      width: h * 0.56,
      height: h,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: KColors.navy,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: KColors.primary.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Container(
          color: k.background,
          child: AnimatedSwitcher(
            duration: KDurations.medium,
            child: switch (widget.index) {
              0 => _lesson(context),
              1 => _codeScreen(context),
              _ => _app(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _lesson(BuildContext context) => Padding(
    key: const ValueKey('lesson'),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('O\'zgaruvchilar'.uz, style: context.text.titleMedium),
        const SizedBox(height: 8),
        KProgressBar(value: _lessonStep / 4),
        const SizedBox(height: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: KDurations.medium,
            child: Container(
              key: ValueKey(_lessonStep),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.k.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    const [
                      Icons.inventory_2_outlined,
                      Icons.label_outline,
                      Icons.input_rounded,
                      Icons.check_circle_outline,
                    ][_lessonStep - 1],
                    size: 42,
                    color: KColors.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    const [
                      'Quti yaratiladi',
                      'Unga nom beriladi: yosh',
                      'Qiymat solinadi: 18',
                      'Tayyor!',
                    ][_lessonStep - 1].uz,
                    textAlign: TextAlign.center,
                    style: context.text.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        KButton(
          label: _lessonStep < 4 ? 'Keyingi qadam' : 'Qaytadan',
          compact: true,
          expand: true,
          onPressed: () => setState(
            () => _lessonStep = _lessonStep < 4 ? _lessonStep + 1 : 1,
          ),
        ),
      ],
    ),
  );

  Widget _codeScreen(BuildContext context) => Padding(
    key: const ValueKey('code'),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CodePalette.dark.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _code,
            style: codeStyle(size: 10.5, color: CodePalette.dark.text),
          ),
        ),
        const SizedBox(height: 10),
        KButton(
          label: 'Ishga tushirish',
          icon: Icons.play_arrow_rounded,
          compact: true,
          variant: KButtonVariant.success,
          onPressed: () =>
              setState(() => _output = KitobDart.run(_code).stdout),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.k.console,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _output ?? '\$ _',
              style: codeStyle(
                size: 11,
                color: _output == null
                    ? Colors.white38
                    : const Color(0xFFA5E38B),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _app(BuildContext context) => Column(
    key: const ValueKey('app'),
    children: [
      Container(
        width: double.infinity,
        color: KColors.primary,
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
        child: const Text(
          'Mening ilovam',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bosishlar:'.uz, style: context.text.bodyMedium),
            TweenAnimationBuilder<double>(
              key: ValueKey(_counter),
              tween: Tween(begin: 1.3, end: 1),
              duration: KDurations.medium,
              builder: (c, v, child) => Transform.scale(scale: v, child: child),
              child: Text('$_counter', style: context.text.displaySmall),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.small(
            heroTag: 'onb-fab',
            onPressed: () => setState(() => _counter++),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    ],
  );
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({
    required this.level,
    required this.onLevel,
    required this.name,
    required this.language,
    required this.onLanguage,
    required this.dailyMinutes,
    required this.onDailyMinutes,
  });
  final StartLevel level;
  final ValueChanged<StartLevel> onLevel;
  final TextEditingController name;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguage;
  final int dailyMinutes;
  final ValueChanged<int> onDailyMinutes;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: ContentWidth(
      maxWidth: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BitikSays(
            mood: BitikMood.happy,
            size: 72,
            text: 'Salom! Men **Bitik** — FLUTTER_KITOB\'ning yordamchisiman. Darajangizni ayting, sizga mos yo\'l tuzaman.',
          ),
          const SizedBox(height: 16),
          Text('Sizni tanib olaylik'.uz, style: context.text.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Darajangizga mos shaxsiy o\'quv yo\'li tuziladi. Keyin sozlamalarda o\'zgartirish mumkin.'
                .uz,
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: 18),
          Text('Ilova tili'.uz, style: context.text.titleMedium),
          const SizedBox(height: 6),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
            child: DropdownButton<AppLanguage>(
              value: language,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final item in AppLanguage.values)
                  DropdownMenuItem(value: item, child: Text(item.nativeName)),
              ],
              onChanged: (value) {
                if (value != null) onLanguage(value);
              },
            ),
          ),
          if (language != AppLanguage.uz) ...[
            const SizedBox(height: 4),
            Text(
              'Tarjima bosqichma-bosqich qo\'shilmoqda; kurs darslari hozircha o\'zbekcha.'
                  .uz,
              style: context.text.bodySmall,
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Kuniga qancha vaqt ajratasiz?'.uz,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in const [5, 10, 15, 20])
                ChoiceChip(
                  label: Text('$minutes ${'daqiqa'.uz}'),
                  selected: dailyMinutes == minutes,
                  onSelected: (_) => onDailyMinutes(minutes),
                ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Ismingiz (ixtiyoriy)'.uz,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Dasturlash darajangiz qanday?'.uz,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: 10),
          RadioGroup<StartLevel>(
            groupValue: level,
            onChanged: (v) => onLevel(v ?? level),
            child: Column(
              children: [
                for (final l in StartLevel.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: KCard(
                      onTap: () => onLevel(l),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      borderColor: l == level ? KColors.primary : null,
                      color: l == level ? context.k.primarySoft : null,
                      child: Row(
                        children: [
                          Radio<StartLevel>(value: l),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UzText(l.title, style: context.text.titleSmall),
                                UzText(
                                  l.subtitle,
                                  style: context.text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
