import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'tr': _tr,
        'en': _en,
        'ru': _ru,
        'tk': _tr,
      };

  static const Map<String, String> _tr = {
    // Bottom nav
    'nav_home': 'Ana Sayfa',
    'nav_explore': 'Keşfet',
    'nav_notifications': 'Bildirimler',
    'nav_saved': 'Kaydedilenler',
    'nav_profile': 'Profil',

    // Home tabs
    'app_name': 'Pulse',
    'for_you': 'Sana Özel',
    'trending': 'Gündem',
    'teams': 'Takımlar',
    'transfer': 'Transfer',
    'leagues': 'Ligler',
    'agenda': 'Gündemde',
    'see_all': 'Tümünü Gör',
    'follow': 'Takip Et',
    'following': 'Takiptesin',
    'ai_summary': 'AI Özet',
    'ai_daily_digest': 'AI Günlük Özet',
    'ai_daily_digest_badge': '🤖 AI GÜNLÜK ÖZET',
    'show_more': 'Daha Fazla Göster',
    'open_in_x': 'X\'te Aç',
    'share_post': 'Gönderiyi Paylaş',

    // Home section headers
    'trending_header': 'Gündemde',
    'popular_agendas': 'Popüler Gündemler',
    'transfer_agenda': 'Transfer Gündemi',
    'teams_communities': 'Takımlar ve Topluluklar',
    'league_standings': 'Lig Sıralamaları & Detayları',

    // Explore
    'explore_title': 'Keşfet',
    'search_hint': 'Ara (takım, oyuncu, konu...)',
    'trend_topics': 'Trend Konular',
    'popular_tweets': 'Popüler Tweetler',
    'no_results': 'Sonuç bulunamadı',

    // Team screen
    'team_title': 'Takımlar',
    'followers': 'Takipçi',
    'agenda_tab': 'Gündem',
    'tweets_tab': 'Tweetler',
    'transfer_tab': 'Transfer',
    'matches_tab': 'Maçlar',
    'players_tab': 'Oyuncular',
    'team_agenda': 'Gündemi',
    'no_agenda': 'Gündem yok',
    'matches_coming_soon': 'Maç bilgileri yakında...',
    'players_coming_soon': 'Oyuncu bilgileri yakında...',

    // Transfer statuses
    'transfer_status_talks': 'Görüşmeler devam ediyor',
    'transfer_status_expiring': 'Kontrakt sona eriyor',
    'transfer_status_done': 'Anlaşma sağlandı',
    'transfer_free': 'Serbest',

    // AI Digest
    'daily_digest': 'Günlük Özet',
    'yesterday': 'Dün',
    'today': 'Bugün',
    'top_tweets': 'En Çok Konuşulan Tweetler',
    'all_summaries': 'Tüm Özetleri Gör',

    // Notifications
    'notifications_title': 'Bildirimler',
    'notif_detail_title': 'Bildirim Detayı',

    // Saved
    'saved_title': 'Kaydedilenler',
    'saved_empty': 'Henüz kaydedilen tweet yok',

    // Profile
    'profile_title': 'Profil',
    'settings_section': 'Ayarlar',
    'general_section': 'Genel',
    'premium': 'Premium',
    'premium_title': 'Pulse Premium',
    'premium_sub1': 'Reklamsız kullanım',
    'premium_sub2': 'Gelişmiş AI özellikleri',
    'premium_sub3': 'Anlık bildirimler',
    'premium_sub4': 'Özel filtreler',
    'premium_sub5': 'Kaydedilenler sınırsız',
    'monthly': 'Aylık',
    'yearly': 'Yıllık (%33 indirim)',
    'start_premium': 'Premium\'u Başlat',
    'terms_note': 'Tüm abonelik koşulları ve gizlilik politikası',
    'settings': 'Ayarlar',
    'about_app': 'Uygulama Hakkında',
    'privacy_policy': 'Gizlilik Politikası',
    'terms_of_use': 'Kullanım Şartları',
    'notifications_settings': 'Bildirimler',
    'language': 'Dil',
    'appearance': 'Görünüm',
    'theme_dark': 'Koyu',
    'theme_light': 'Açık',

    // Notifications sheet
    'notif_push': 'Anlık Bildirimler',
    'notif_breaking': 'Son Dakika Haberleri',
    'notif_saved': 'Kaydedilen Güncellemeleri',

    // Language sheet
    'lang_select': 'Dil Seçimi',

    // Theme sheet
    'theme_select': 'Görünüm',
    'theme_select_sub': 'Uygulama temasını seçin',
    'theme_dark_label': 'Koyu Tema',
    'theme_dark_desc': 'Gözleri yormayan karanlık görünüm',
    'theme_light_label': 'Açık Tema',
    'theme_light_desc': 'Gün içi kullanım için aydınlık görünüm',

    // About / splash
    'app_tagline': 'AI Destekli X Feed',
    'app_version': 'Sürüm 1.0.0',
    'app_description': 'Pulse, yapay zeka destekli haber ve içerik platformudur.',
    'last_updated': 'Son güncelleme',

    // Common
    'cancel': 'İptal',
    'ok': 'Tamam',
    'save': 'Kaydet',
    'error': 'Hata',
    'retry': 'Tekrar Dene',
    'loading': 'Yükleniyor...',
    'content_load_error': 'İçerik yüklenemedi',
    'no_internet': 'İnternet bağlantısı yok',
    'no_internet_desc': 'Lütfen bağlantınızı kontrol edin.',
    'check_connection': 'Bağlantıyı Kontrol Et',
    'days_ago': 'gün önce',
    'hours_ago': 'sa',
    'minutes_ago': 'dk',
    'now': 'şimdi',
    'mark_all_read': 'Tümünü okundu işaretle',
    'notif_empty_title': 'Bildirim yok',
    'notif_empty_sub': 'Yeni bildirimler burada görünecek.',
    'saved_login_title': 'Tweetleri kaydet,\nnerede olursan ol ulaş',
    'saved_login_sub': 'Kaydedilen tweetlerine tüm cihazlarından ulaşmak için giriş yap.',
    'saved_login_cta_title': 'Henüz kaydedilen tweet yok',
    'saved_login_cta_sub': 'Beğendiğin tweetleri kaydetmek için giriş yap.',
    'saved_feature_1': 'Tweetleri tek tıkla kaydet',
    'saved_feature_2': 'Tüm cihazlarında senkronize',
    'saved_feature_3': 'İstediğin zaman eriş',
    'saved_empty_title': 'Henüz kaydedilen tweet yok',
    'saved_empty_sub': 'Bir tweet\'in üzerindeki 🔖 ikonuna bas\nve burada görünsün.',
    'sign_in': 'Giriş Yap',
    'sign_in_google': 'Google ile devam et',
    'sign_in_apple': 'Apple ile devam et',
    'sign_out': 'Çıkış Yap',
    'sign_out_confirm': 'Hesabından çıkmak istediğine emin misin?',
    // 'cancel': 'İptal',
    'profile_login_title': 'Hesabına giriş yap',
    'profile_login_sub': 'Tweetleri kaydet ve tüm cihazlarında eriş.',
    'login_privacy_note': 'Giriş yaparak Kullanım Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.',
    'post_detail': 'Gönderi',
    'about_us': 'Hakkımızda',
    'about': 'Hakkında',
    'error_occurred': 'Bir hata oluştu',
  };

  static const Map<String, String> _en = {
    // Bottom nav
    'nav_home': 'Home',
    'nav_explore': 'Explore',
    'nav_notifications': 'Notifications',
    'nav_saved': 'Saved',
    'nav_profile': 'Profile',

    // Home tabs
    'app_name': 'Pulse',
    'for_you': 'For You',
    'trending': 'Trending',
    'teams': 'Teams',
    'transfer': 'Transfer',
    'leagues': 'Leagues',
    'agenda': 'Trending',
    'see_all': 'See All',
    'follow': 'Follow',
    'following': 'Following',
    'ai_summary': 'AI Summary',
    'ai_daily_digest': 'AI Daily Digest',
    'ai_daily_digest_badge': '🤖 AI DAILY DIGEST',
    'show_more': 'Show More',
    'open_in_x': 'Open in X',
    'share_post': 'Share Post',

    // Home section headers
    'trending_header': 'Trending',
    'popular_agendas': 'Popular Topics',
    'transfer_agenda': 'Transfer News',
    'teams_communities': 'Teams & Communities',
    'league_standings': 'League Standings & Details',

    // Explore
    'explore_title': 'Explore',
    'search_hint': 'Search (team, player, topic...)',
    'trend_topics': 'Trending Topics',
    'popular_tweets': 'Popular Tweets',
    'no_results': 'No results found',

    // Team screen
    'team_title': 'Teams',
    'followers': 'Followers',
    'agenda_tab': 'News',
    'tweets_tab': 'Tweets',
    'transfer_tab': 'Transfer',
    'matches_tab': 'Matches',
    'players_tab': 'Players',
    'team_agenda': 'News',
    'no_agenda': 'No news yet',
    'matches_coming_soon': 'Match info coming soon...',
    'players_coming_soon': 'Player info coming soon...',

    // Transfer statuses
    'transfer_status_talks': 'Talks ongoing',
    'transfer_status_expiring': 'Contract expiring',
    'transfer_status_done': 'Deal done',
    'transfer_free': 'Free agent',

    // AI Digest
    'daily_digest': 'Daily Digest',
    'yesterday': 'Yesterday',
    'today': 'Today',
    'top_tweets': 'Most Discussed Tweets',
    'all_summaries': 'See All Summaries',

    // Notifications
    'notifications_title': 'Notifications',
    'notif_detail_title': 'Notification Detail',

    // Saved
    'saved_title': 'Saved',
    'saved_empty': 'No saved tweets yet',

    // Profile
    'profile_title': 'Profile',
    'settings_section': 'Settings',
    'general_section': 'General',
    'premium': 'Premium',
    'premium_title': 'Pulse Premium',
    'premium_sub1': 'Ad-free experience',
    'premium_sub2': 'Advanced AI features',
    'premium_sub3': 'Instant notifications',
    'premium_sub4': 'Custom filters',
    'premium_sub5': 'Unlimited saves',
    'monthly': 'Monthly',
    'yearly': 'Yearly (33% off)',
    'start_premium': 'Start Premium',
    'terms_note': 'All subscription terms and privacy policy',
    'settings': 'Settings',
    'about_app': 'About App',
    'privacy_policy': 'Privacy Policy',
    'terms_of_use': 'Terms of Use',
    'notifications_settings': 'Notifications',
    'language': 'Language',
    'appearance': 'Appearance',
    'theme_dark': 'Dark',
    'theme_light': 'Light',

    // Notifications sheet
    'notif_push': 'Push Notifications',
    'notif_breaking': 'Breaking News',
    'notif_saved': 'Saved Updates',

    // Language sheet
    'lang_select': 'Select Language',

    // Theme sheet
    'theme_select': 'Appearance',
    'theme_select_sub': 'Choose app theme',
    'theme_dark_label': 'Dark Theme',
    'theme_dark_desc': 'Easy on the eyes dark mode',
    'theme_light_label': 'Light Theme',
    'theme_light_desc': 'Bright mode for daytime use',

    // About / splash
    'app_tagline': 'AI-Powered X Feed',
    'app_version': 'Version 1.0.0',
    'app_description': 'Pulse is an AI-powered news and content platform.',
    'last_updated': 'Last updated',

    // Common
    'cancel': 'Cancel',
    'ok': 'OK',
    'save': 'Save',
    'error': 'Error',
    'retry': 'Retry',
    'loading': 'Loading...',
    'content_load_error': 'Could not load content',
    'no_internet': 'No internet connection',
    'no_internet_desc': 'Please check your connection.',
    'check_connection': 'Check Connection',
    'days_ago': 'd ago',
    'hours_ago': 'h',
    'minutes_ago': 'm',
    'now': 'now',
    'mark_all_read': 'Mark all read',
    'notif_empty_title': 'No notifications',
    'notif_empty_sub': 'New notifications will appear here.',
    'saved_login_title': 'Save tweets,\naccess them anywhere',
    'saved_login_sub': 'Sign in to access your saved tweets across all devices.',
    'saved_login_cta_title': 'No saved tweets yet',
    'saved_login_cta_sub': 'Sign in to start saving tweets.',
    'saved_feature_1': 'Save tweets with one tap',
    'saved_feature_2': 'Synced across all your devices',
    'saved_feature_3': 'Access anytime, anywhere',
    'saved_empty_title': 'No saved tweets yet',
    'saved_empty_sub': 'Tap the 🔖 icon on any tweet\nto save it here.',
    'sign_in': 'Sign In',
    'sign_in_google': 'Continue with Google',
    'sign_in_apple': 'Continue with Apple',
    'sign_out': 'Sign Out',
    'sign_out_confirm': 'Are you sure you want to sign out?',
    // 'cancel': 'Cancel',
    'profile_login_title': 'Sign in to your account',
    'profile_login_sub': 'Save tweets and access them on all your devices.',
    'login_privacy_note': 'By signing in, you agree to our Terms of Service and Privacy Policy.',
    'post_detail': 'Post',
    'about_us': 'About Us',
    'about': 'About',
    'error_occurred': 'An error occurred',
  };

  static const Map<String, String> _ru = {
    // Bottom nav
    'nav_home': 'Главная',
    'nav_explore': 'Поиск',
    'nav_notifications': 'Уведомления',
    'nav_saved': 'Сохранённое',
    'nav_profile': 'Профиль',

    // Home tabs
    'app_name': 'Pulse',
    'for_you': 'Для вас',
    'trending': 'Тренды',
    'teams': 'Команды',
    'transfer': 'Трансферы',
    'leagues': 'Лиги',
    'agenda': 'В тренде',
    'see_all': 'Смотреть все',
    'follow': 'Подписаться',
    'following': 'Вы подписаны',
    'ai_summary': 'AI Сводка',
    'ai_daily_digest': 'AI Ежедневный дайджест',
    'ai_daily_digest_badge': '🤖 AI ДАЙДЖЕСТ',
    'show_more': 'Показать больше',
    'open_in_x': 'Открыть в X',
    'share_post': 'Поделиться',

    // Home section headers
    'trending_header': 'В тренде',
    'popular_agendas': 'Популярные темы',
    'transfer_agenda': 'Новости трансферов',
    'teams_communities': 'Команды и сообщества',
    'league_standings': 'Турнирная таблица',

    // Explore
    'explore_title': 'Поиск',
    'search_hint': 'Поиск (команда, игрок, тема...)',
    'trend_topics': 'Трендовые темы',
    'popular_tweets': 'Популярные твиты',
    'no_results': 'Результаты не найдены',

    // Team screen
    'team_title': 'Команды',
    'followers': 'Подписчики',
    'agenda_tab': 'Новости',
    'tweets_tab': 'Твиты',
    'transfer_tab': 'Трансфер',
    'matches_tab': 'Матчи',
    'players_tab': 'Игроки',
    'team_agenda': 'Новости',
    'no_agenda': 'Новостей нет',
    'matches_coming_soon': 'Информация о матчах скоро...',
    'players_coming_soon': 'Информация об игроках скоро...',

    // Transfer statuses
    'transfer_status_talks': 'Переговоры продолжаются',
    'transfer_status_expiring': 'Контракт истекает',
    'transfer_status_done': 'Договорённость достигнута',
    'transfer_free': 'Свободный агент',

    // AI Digest
    'daily_digest': 'Дайджест',
    'yesterday': 'Вчера',
    'today': 'Сегодня',
    'top_tweets': 'Самые обсуждаемые твиты',
    'all_summaries': 'Посмотреть все сводки',

    // Notifications
    'notifications_title': 'Уведомления',
    'notif_detail_title': 'Детали уведомления',

    // Saved
    'saved_title': 'Сохранённое',
    'saved_empty': 'Нет сохранённых твитов',

    // Profile
    'profile_title': 'Профиль',
    'settings_section': 'Настройки',
    'general_section': 'Общее',
    'premium': 'Премиум',
    'premium_title': 'Pulse Премиум',
    'premium_sub1': 'Без рекламы',
    'premium_sub2': 'Расширенные функции AI',
    'premium_sub3': 'Мгновенные уведомления',
    'premium_sub4': 'Пользовательские фильтры',
    'premium_sub5': 'Неограниченные сохранения',
    'monthly': 'В месяц',
    'yearly': 'В год (скидка 33%)',
    'start_premium': 'Начать Премиум',
    'terms_note': 'Все условия подписки и политика конфиденциальности',
    'settings': 'Настройки',
    'about_app': 'О приложении',
    'privacy_policy': 'Политика конфиденциальности',
    'terms_of_use': 'Условия использования',
    'notifications_settings': 'Уведомления',
    'language': 'Язык',
    'appearance': 'Внешний вид',
    'theme_dark': 'Тёмная',
    'theme_light': 'Светлая',

    // Notifications sheet
    'notif_push': 'Push-уведомления',
    'notif_breaking': 'Срочные новости',
    'notif_saved': 'Обновления сохранённого',

    // Language sheet
    'lang_select': 'Выбор языка',

    // Theme sheet
    'theme_select': 'Внешний вид',
    'theme_select_sub': 'Выберите тему приложения',
    'theme_dark_label': 'Тёмная тема',
    'theme_dark_desc': 'Тёмный режим, не раздражающий глаза',
    'theme_light_label': 'Светлая тема',
    'theme_light_desc': 'Светлый режим для использования днём',

    // About / splash
    'app_tagline': 'X-лента на базе AI',
    'app_version': 'Версия 1.0.0',
    'app_description': 'Pulse — новостная платформа на базе искусственного интеллекта.',
    'last_updated': 'Последнее обновление',

    // Common
    'cancel': 'Отмена',
    'ok': 'ОК',
    'save': 'Сохранить',
    'error': 'Ошибка',
    'retry': 'Повторить',
    'loading': 'Загрузка...',
    'content_load_error': 'Не удалось загрузить контент',
    'no_internet': 'Нет подключения к интернету',
    'no_internet_desc': 'Пожалуйста, проверьте подключение.',
    'check_connection': 'Проверить подключение',
    'days_ago': 'дн. назад',
    'hours_ago': 'ч',
    'minutes_ago': 'мин',
    'now': 'сейчас',
    'mark_all_read': 'Прочитать все',
    'notif_empty_title': 'Нет уведомлений',
    'notif_empty_sub': 'Новые уведомления появятся здесь.',
    'saved_login_title': 'Сохраняй твиты,\nоткрывай где угодно',
    'saved_login_sub': 'Войдите, чтобы получить доступ к сохранённым твитам на всех устройствах.',
    'saved_login_cta_title': 'Нет сохранённых твитов',
    'saved_login_cta_sub': 'Войдите, чтобы начать сохранять твиты.',
    'saved_feature_1': 'Сохраняй твиты одним нажатием',
    'saved_feature_2': 'Синхронизация на всех устройствах',
    'saved_feature_3': 'Доступ в любое время',
    'saved_empty_title': 'Нет сохранённых твитов',
    'saved_empty_sub': 'Нажми 🔖 на любом твите\nи он появится здесь.',
    'sign_in': 'Войти',
    'sign_in_google': 'Продолжить с Google',
    'sign_in_apple': 'Продолжить с Apple',
    'sign_out': 'Выйти',
    'sign_out_confirm': 'Вы уверены, что хотите выйти?',
    'profile_login_title': 'Войдите в аккаунт',
    'profile_login_sub': 'Сохраняйте твиты и получайте доступ на всех устройствах.',
    'login_privacy_note': 'Входя в систему, вы принимаете Условия использования и Политику конфиденциальности.',
    'post_detail': 'Пост',
    'about_us': 'О нас',
    'about': 'О приложении',
    'error_occurred': 'Произошла ошибка',
  };
}
