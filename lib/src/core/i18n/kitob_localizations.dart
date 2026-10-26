import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../state/settings.dart';

/// App chrome translations. Course explanations stay in Uzbek until their
/// localized lesson editions are complete.
class KitobLocalizations {
  const KitobLocalizations(this.locale);

  final Locale locale;

  static AppLanguage activeLanguage = AppLanguage.uz;
  static const supportedLocales = [Locale('uz'), Locale('en'), Locale('ru')];
  static const LocalizationsDelegate<KitobLocalizations> delegate =
      _KitobDelegate();

  static String text(String source) {
    final table = switch (activeLanguage) {
      AppLanguage.uz => const <String, String>{},
      AppLanguage.en => _english,
      AppLanguage.ru => _russian,
    };
    return table[source] ?? source;
  }

  static const _english = <String, String>{
    'Bosh sahifa': 'Home',
    'Darslar': 'Learn',
    'Amaliyot': 'Practice',
    'Testlar': 'Tests',
    'Profil': 'Profile',
    'O\'rganish': 'Learning',
    'Dashboard': 'Dashboard',
    'Mening ta\'lim yo\'lim': 'My learning path',
    'Dart akademiyasi': 'Dart academy',
    'Flutter akademiyasi': 'Flutter academy',
    'Widget laboratoriyasi': 'Widget lab',
    'Code Playground': 'Code playground',
    'Terminal laboratoriyasi': 'Terminal lab',
    'Kod vizualizatori': 'Code visualizer',
    'Amaliy loyihalar': 'Projects',
    'Intervyuga tayyorgarlik': 'Interview prep',
    'Natijalar': 'Progress',
    'Test va imtihonlar': 'Tests and exams',
    'Yutuqlar': 'Achievements',
    'Sozlamalar': 'Settings',
    'Qidirish...': 'Search...',
    'O\'quvchi': 'Learner',
    'O\'rgan. Kod yoz. Yarat.': 'Learn. Code. Build.',
    'Xayrli tun': 'Good night',
    'Xayrli tong': 'Good morning',
    'Xayrli kun': 'Hello',
    'Xayrli kech': 'Good evening',
    'Keling, boshlaymiz!': 'Let’s get started!',
    'Bugun nimani o\'rganamiz?': 'What will you learn today?',
    'Takrorlash vaqti keldi': 'Time to review',
    'Eslab qolish uchun 2 daqiqalik qisqa test':
        'A quick two-minute recall exercise',
    'Mashq qilish': 'Practice',
    'Darsdan tashqari o\'zingiz sinab ko\'ring':
        'Try it yourself beyond the lesson',
    'Davom ettirish': 'Continue learning',
    'Bugungi maqsad': 'Today’s goal',
    'Haftalik natija': 'This week',
    'O\'tkazib yuborish': 'Skip',
    'Keyingi': 'Next',
    'O\'qishni boshlash': 'Start learning',
    'O\'rgan': 'Learn',
    'Noldan, sodda o\'zbek tilida': 'Start from the basics',
    'Har bir mavzu hayotiy misol, animatsiya va qadam-baqadam tushuntirish bilan. Hech qanday atama izohsiz qolmaydi.':
        'Learn each idea through real examples, animation, and clear steps.',
    'Kod yoz': 'Code',
    'Haqiqiy kod — haqiqiy natija': 'Write code. See real results.',
    'Telefoningizda Dart kodini yozasiz, ishga tushirasiz va natijani darhol ko\'rasiz. Xatolar o\'zbekcha tushuntiriladi.':
        'Write and run Dart code, then see the result right away.',
    'Yarat': 'Build',
    'Bilimingizni isbotlang': 'Put your skills to the test',
    'Testlar, debugging mashqlari va loyihalar orqali haqiqiy dastur yaratish ko\'nikmasini egallaysiz.':
        'Build real skills with quizzes, debugging exercises, and projects.',
    'Ilova tili': 'App language',
    'Hali baholanmagan': 'Not assessed yet',
    'Tarjima bosqichma-bosqich qo\'shilmoqda; kurs darslari hozircha o\'zbekcha.': 'Translations are being added gradually; course lessons are currently in Uzbek.',
    'Kuniga qancha vaqt ajratasiz?': 'How much time can you study each day?',
    'Kunlik o\'qish vaqti': 'Daily study time',
    'daqiqa': 'min',
    'Ko\'rinish': 'Appearance',
    'Mavzu': 'Theme',
    'Tizim': 'System',
    'Yorug\'': 'Light',
    'Qorong\'i': 'Dark',
    'Interfeys uslubi': 'Interface style',
    'Avtomatik': 'Automatic',
    'Ovozli effektlar': 'Sound effects',
    'To\'g\'ri/xato javob va yutuqlar. Telefon jim rejimda bo\'lsa, ovoz chiqmaydi.':
        'Sounds for answers and achievements. Respects silent mode.',
    'Harakatni kamaytirish': 'Reduce motion',
    'Animatsiyalar avtomatik ijro etilmaydi (Reduce Motion)':
        'Reduce automatic animations',
    'Kod muharriri': 'Code editor',
    'Qorong\'i editor mavzusi': 'Dark editor theme',
    'Eslatmalar': 'Reminders',
    'O\'qish': 'Learning',
    'Kunlik maqsad': 'Daily goal',
    'Ism': 'Name',
    'Kiritilmagan': 'Not set',
    'Ismingiz': 'Your name',
    'Bekor': 'Cancel',
    'Saqlash': 'Save',
    'Boshlang\'ich daraja': 'Starting level',
    'Ma\'lumotlar va maxfiylik': 'Data and privacy',
    'Ma\'lumotlarimni eksport qilish': 'Export my data',
    'Progress va sozlamalar JSON ko\'rinishida nusxalanadi':
        'Copy progress and settings as JSON',
    'Barcha ma\'lumotlarni o\'chirish': 'Delete all data',
    'Progress, kodlar va sozlamalar butunlay o\'chiriladi':
        'Permanently delete progress, code, and settings',
    'Hammasini o\'chirasizmi?': 'Delete everything?',
    'Bu amalni ortga qaytarib bo\'lmaydi.': 'This action cannot be undone.',
    'O\'chirish': 'Delete',
    'Ma\'lumotlaringiz faqat shu qurilmada saqlanadi. Kodlaringiz serverga yuborilmaydi — Dart kodi qurilmaning o\'zida, xavfsiz izolyatsiyalangan interpretatorda bajariladi.': 'Your data stays on this device. Code is not sent to a server; Dart exercises run locally in the interpreter.',
    'Sizni tanib olaylik': 'Let’s get to know you',
    'Darajangizga mos shaxsiy o\'quv yo\'li tuziladi. Keyin sozlamalarda o\'zgartirish mumkin.': 'We’ll tailor a learning path to your level. You can change it later in settings.',
    'Ismingiz (ixtiyoriy)': 'Your name (optional)',
    'Dasturlash darajangiz qanday?': 'What is your coding experience?',
    'Men mutlaqo yangiman': 'I’m completely new',
    'Dasturlash nimaligidan boshlaymiz': 'Start with what programming is',
    'Ozgina dasturlashni bilaman': 'I know a little programming',
    'Dart asoslaridan boshlaymiz': 'Start with Dart basics',
    'Dart asoslarini bilaman': 'I know Dart basics',
    'OOP va asinxron Dart\'dan boshlaymiz':
        'Start with OOP and asynchronous Dart',
    'Flutter bilan ishlaganman': 'I have used Flutter',
    'Flutter asoslariga o\'tamiz': 'Continue with Flutter foundations',
    'Professional bilimimni kuchaytirmoqchiman': 'I want to advance my skills',
    'Barcha tayyor darslar ochiq — murakkab mavzular va loyihalar':
        'Open the prepared lessons, advanced topics, and projects',
    'Quti yaratiladi': 'Create a box',
    'Unga nom beriladi: yosh': 'Name it: age',
    'Qiymat solinadi: 18': 'Put in a value: 18',
    'Tayyor!': 'Done!',
    'Keyingi qadam': 'Next step',
    'Qaytadan': 'Replay',
    'O\'zgaruvchilar': 'Variables',
    'Bosishlar:': 'Taps:',
    'Ajoyib natija!': 'Great work!',
    'Imtihonlar va loyihalar bilan bilimingizni mustahkamlang.':
        'Strengthen your skills with exams and projects.',
    'Hech narsa bilish shart emas — noldan boshlaymiz.':
        'No experience needed. Start from the beginning.',
    'Qisqa takrorlash testi · 2 daqiqa': 'Quick review · 2 minutes',
    'Bilim darajasi': 'Skill mastery',
    'Tugatilgan darslar, test natijalari va amaliyotdan hisoblanadi':
        'Based on completed lessons, test results, and practice',
    'Haftalik faollik': 'Weekly activity',
    'Birinchi kodingizni ishga tushirib, birinchi yutuqni oling!':
        'Run your first code and earn your first achievement!',
    'Kuchaytirish kerak bo\'lgan mavzular': 'Topics to strengthen',
    'Testlarda ko\'proq xato qilingan mavzular':
        'Topics missed most often in tests',
    'Barchasi': 'View all',
    'Qanday o\'rganamiz?': 'How learning works',
    'Xato qilish — o\'rganishning bir qismi. Hech narsa buzilmaydi, istagancha qayta urinish mumkin.':
        'Mistakes are part of learning. Nothing breaks, and you can try again.',
  };

  static const _russian = <String, String>{
    'Bosh sahifa': 'Главная',
    'Darslar': 'Обучение',
    'Amaliyot': 'Практика',
    'Testlar': 'Тесты',
    'Profil': 'Профиль',
    'O\'rganish': 'Обучение',
    'Dashboard': 'Обзор',
    'Mening ta\'lim yo\'lim': 'Мой путь обучения',
    'Dart akademiyasi': 'Академия Dart',
    'Flutter akademiyasi': 'Академия Flutter',
    'Widget laboratoriyasi': 'Лаборатория виджетов',
    'Code Playground': 'Песочница кода',
    'Terminal laboratoriyasi': 'Лаборатория терминала',
    'Kod vizualizatori': 'Визуализатор кода',
    'Amaliy loyihalar': 'Проекты',
    'Intervyuga tayyorgarlik': 'Подготовка к собеседованию',
    'Natijalar': 'Результаты',
    'Test va imtihonlar': 'Тесты и экзамены',
    'Yutuqlar': 'Достижения',
    'Sozlamalar': 'Настройки',
    'Qidirish...': 'Поиск...',
    'O\'quvchi': 'Ученик',
    'O\'rgan. Kod yoz. Yarat.': 'Учись. Пиши код. Создавай.',
    'Xayrli tun': 'Доброй ночи',
    'Xayrli tong': 'Доброе утро',
    'Xayrli kun': 'Здравствуйте',
    'Xayrli kech': 'Добрый вечер',
    'Keling, boshlaymiz!': 'Начнём!',
    'Bugun nimani o\'rganamiz?': 'Что изучим сегодня?',
    'Takrorlash vaqti keldi': 'Время повторить',
    'Eslab qolish uchun 2 daqiqalik qisqa test':
        'Короткое двухминутное упражнение на память',
    'Mashq qilish': 'Практика',
    'Darsdan tashqari o\'zingiz sinab ko\'ring': 'Попробуйте сами после урока',
    'Davom ettirish': 'Продолжить обучение',
    'Bugungi maqsad': 'Цель на сегодня',
    'Haftalik natija': 'За эту неделю',
    'O\'tkazib yuborish': 'Пропустить',
    'Keyingi': 'Далее',
    'O\'qishni boshlash': 'Начать обучение',
    'O\'rgan': 'Учись',
    'Noldan, sodda o\'zbek tilida': 'Начните с основ',
    'Har bir mavzu hayotiy misol, animatsiya va qadam-baqadam tushuntirish bilan. Hech qanday atama izohsiz qolmaydi.': 'Изучайте каждую тему на примерах, с анимацией и пошаговыми объяснениями.',
    'Kod yoz': 'Пиши код',
    'Haqiqiy kod — haqiqiy natija': 'Настоящий код — реальный результат',
    'Telefoningizda Dart kodini yozasiz, ishga tushirasiz va natijani darhol ko\'rasiz. Xatolar o\'zbekcha tushuntiriladi.':
        'Пишите и запускайте код Dart, сразу видя результат.',
    'Yarat': 'Создавай',
    'Bilimingizni isbotlang': 'Проверьте свои знания',
    'Testlar, debugging mashqlari va loyihalar orqali haqiqiy dastur yaratish ko\'nikmasini egallaysiz.':
        'Развивайте навыки на тестах, упражнениях по отладке и проектах.',
    'Ilova tili': 'Язык приложения',
    'Hali baholanmagan': 'Пока не оценено',
    'Tarjima bosqichma-bosqich qo\'shilmoqda; kurs darslari hozircha o\'zbekcha.': 'Перевод добавляется постепенно; уроки курса пока доступны на узбекском.',
    'Kuniga qancha vaqt ajratasiz?':
        'Сколько времени вы готовы учиться каждый день?',
    'Kunlik o\'qish vaqti': 'Время обучения в день',
    'daqiqa': 'мин',
    'Ko\'rinish': 'Внешний вид',
    'Mavzu': 'Тема',
    'Tizim': 'Системная',
    'Yorug\'': 'Светлая',
    'Qorong\'i': 'Тёмная',
    'Interfeys uslubi': 'Стиль интерфейса',
    'Avtomatik': 'Автоматически',
    'Ovozli effektlar': 'Звуковые эффекты',
    'To\'g\'ri/xato javob va yutuqlar. Telefon jim rejimda bo\'lsa, ovoz chiqmaydi.':
        'Звуки ответов и достижений. Учитывается беззвучный режим.',
    'Harakatni kamaytirish': 'Уменьшить анимацию',
    'Animatsiyalar avtomatik ijro etilmaydi (Reduce Motion)':
        'Отключить автоматическое воспроизведение анимаций',
    'Kod muharriri': 'Редактор кода',
    'Qorong\'i editor mavzusi': 'Тёмная тема редактора',
    'Eslatmalar': 'Напоминания',
    'O\'qish': 'Обучение',
    'Kunlik maqsad': 'Цель на день',
    'Ism': 'Имя',
    'Kiritilmagan': 'Не указано',
    'Ismingiz': 'Ваше имя',
    'Bekor': 'Отмена',
    'Saqlash': 'Сохранить',
    'Boshlang\'ich daraja': 'Начальный уровень',
    'Ma\'lumotlar va maxfiylik': 'Данные и конфиденциальность',
    'Ma\'lumotlarimni eksport qilish': 'Экспортировать мои данные',
    'Progress va sozlamalar JSON ko\'rinishida nusxalanadi':
        'Скопировать прогресс и настройки в формате JSON',
    'Barcha ma\'lumotlarni o\'chirish': 'Удалить все данные',
    'Progress, kodlar va sozlamalar butunlay o\'chiriladi':
        'Прогресс, код и настройки будут удалены безвозвратно',
    'Hammasini o\'chirasizmi?': 'Удалить всё?',
    'Bu amalni ortga qaytarib bo\'lmaydi.': 'Это действие нельзя отменить.',
    'O\'chirish': 'Удалить',
    'Ma\'lumotlaringiz faqat shu qurilmada saqlanadi. Kodlaringiz serverga yuborilmaydi — Dart kodi qurilmaning o\'zida, xavfsiz izolyatsiyalangan interpretatorda bajariladi.': 'Данные хранятся только на этом устройстве. Код не отправляется на сервер и выполняется локально.',
    'Sizni tanib olaylik': 'Давайте познакомимся',
    'Darajangizga mos shaxsiy o\'quv yo\'li tuziladi. Keyin sozlamalarda o\'zgartirish mumkin.': 'Мы подберём программу обучения под ваш уровень. Её можно изменить в настройках.',
    'Ismingiz (ixtiyoriy)': 'Ваше имя (необязательно)',
    'Dasturlash darajangiz qanday?': 'Какой у вас опыт программирования?',
    'Men mutlaqo yangiman': 'Я совсем новичок',
    'Dasturlash nimaligidan boshlaymiz': 'Начнём с основ программирования',
    'Ozgina dasturlashni bilaman': 'Я немного знаком с программированием',
    'Dart asoslaridan boshlaymiz': 'Начнём с основ Dart',
    'Dart asoslarini bilaman': 'Я знаю основы Dart',
    'OOP va asinxron Dart\'dan boshlaymiz': 'Начнём с ООП и асинхронного Dart',
    'Flutter bilan ishlaganman': 'Я уже работал с Flutter',
    'Flutter asoslariga o\'tamiz': 'Перейдём к основам Flutter',
    'Professional bilimimni kuchaytirmoqchiman':
        'Хочу углубить профессиональные знания',
    'Barcha tayyor darslar ochiq — murakkab mavzular va loyihalar':
        'Открыть готовые уроки, сложные темы и проекты',
    'Quti yaratiladi': 'Создаём коробку',
    'Unga nom beriladi: yosh': 'Назовём её: возраст',
    'Qiymat solinadi: 18': 'Запишем значение: 18',
    'Tayyor!': 'Готово!',
    'Keyingi qadam': 'Следующий шаг',
    'Qaytadan': 'Повторить',
    'O\'zgaruvchilar': 'Переменные',
    'Bosishlar:': 'Нажатия:',
    'Ajoyib natija!': 'Отличная работа!',
    'Imtihonlar va loyihalar bilan bilimingizni mustahkamlang.':
        'Закрепляйте знания с помощью экзаменов и проектов.',
    'Hech narsa bilish shart emas — noldan boshlaymiz.':
        'Опыт не нужен. Начнём с самого начала.',
    'Qisqa takrorlash testi · 2 daqiqa': 'Короткое повторение · 2 минуты',
    'Bilim darajasi': 'Уровень знаний',
    'Tugatilgan darslar, test natijalari va amaliyotdan hisoblanadi':
        'Рассчитывается по урокам, тестам и практике',
    'Haftalik faollik': 'Активность за неделю',
    'Birinchi kodingizni ishga tushirib, birinchi yutuqni oling!':
        'Запустите первый код и получите первое достижение!',
    'Kuchaytirish kerak bo\'lgan mavzular': 'Темы для повторения',
    'Testlarda ko\'proq xato qilingan mavzular':
        'Темы, в которых чаще ошибались',
    'Barchasi': 'Все',
    'Qanday o\'rganamiz?': 'Как проходит обучение',
    'Xato qilish — o\'rganishning bir qismi. Hech narsa buzilmaydi, istagancha qayta urinish mumkin.':
        'Ошибки — часть обучения. Ничего не сломается, можно пробовать снова.',
  };
}

class _KitobDelegate extends LocalizationsDelegate<KitobLocalizations> {
  const _KitobDelegate();

  @override
  bool isSupported(Locale locale) =>
      const {'uz', 'en', 'ru'}.contains(locale.languageCode);

  @override
  Future<KitobLocalizations> load(Locale locale) =>
      SynchronousFuture(KitobLocalizations(locale));

  @override
  bool shouldReload(_KitobDelegate old) => false;
}
