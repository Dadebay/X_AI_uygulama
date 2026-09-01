(function () {
  'use strict';

  // Tek yerden tanımlı iletişim e-postası. Değiştirmek için sadece burayı düzenle.
  var CONTACT_EMAIL = 'onesocialtest960@gmail.com';

  var TR = {
    'nav.features': 'Özellikler', 'nav.screens': 'Ekranlar', 'nav.faq': 'SSS',
    'nav.contact': 'İletişim', 'nav.admin': 'Admin Giriş',
    'hero.eyebrow': 'CANLI FUTBOL AKIŞI',
    'hero.title1': 'Futbolun nabzı,', 'hero.title2': 'tek ekranda.',
    'hero.sub': 'Transferler, gündem, takım haberleri ve sosyal medya akışı — hepsi gerçek zamanlı, tek uygulamada.',
    'hero.meta1': '4+ yaş', 'hero.meta2': 'Ücretsiz', 'hero.meta3': '3 dil',
    'stats.teams': 'Takım', 'stats.langs': 'Dil', 'stats.live': 'Canlı Akış', 'stats.free': 'Ücretsiz', 'stats.freeNum': '0 ₺',
    'features.eyebrow': 'ÖZELLİKLER',
    'features.title': 'Bir taraftarın ihtiyacı olan her şey',
    'features.sub': 'Pulse Sports, futbolla ilgili her şeyi tek bir akışta, kişiselleştirilmiş şekilde önüne getirir.',
    'features.card1.title': 'Sana Özel Akış',
    'features.card1.desc': 'Takip ettiğin takımlara göre kişiselleşen, saniyesi saniyesine güncellenen futbol akışı.',
    'features.card2.title': 'Gündem',
    'features.card2.desc': "Türkiye'de futbol dünyasının o an en çok konuşulan başlıkları ve trend etiketleri.",
    'features.card3.title': 'Takımlar',
    'features.card3.desc': 'Galatasaray, Fenerbahçe, Beşiktaş, Trabzonspor ve Milli Takım için ayrı beslemeler.',
    'features.card4.title': 'Transfer',
    'features.card4.desc': 'Transfer haberleri, söylentiler ve resmî açıklamalar tek bir sekmede.',
    'features.card5.title': 'Kaydet',
    'features.card5.desc': 'Beğendiğin gönderileri kaydet, internet olmadan da geri dön.',
    'features.card6.title': 'Anlık Bildirimler',
    'features.card6.desc': 'Önemli gelişme olduğunda anında haberdar ol — spam yok, sadece önemli olan.',
    'gallery.eyebrow': 'EKRANLAR', 'gallery.title': 'Uygulamanın içinden',
    'gallery.sub': 'Modern, hızlı ve koyu temalı arayüz — futbol gündemine odaklanman için tasarlandı.',
    'how.eyebrow': 'NASIL ÇALIŞIR', 'how.title': 'Üç adımda başla',
    'how.step1.title': 'İndir', 'how.step1.desc': "App Store veya Google Play'den ücretsiz indir.",
    'how.step2.title': 'Takımını seç', 'how.step2.desc': 'Favori takımlarını işaretle, akışın anında şekillensin.',
    'how.step3.title': 'Takipte kal', 'how.step3.desc': 'Akış senin için çalışır — gündem, transfer, her şey.',
    'faq.eyebrow': 'SIKÇA SORULANLAR', 'faq.title': 'Merak ettiklerin',
    'faq.q1': 'Pulse Sports ücretsiz mi?', 'faq.a1': 'Evet, uygulama tamamen ücretsiz. İçerikler reklam destekli sunulur.',
    'faq.q2': 'Hangi cihazlarda çalışıyor?', 'faq.a2': "iOS 15.6 ve üzeri iPhone'lar ile Android cihazlarda.",
    'faq.q3': 'Hangi dilleri destekliyor?', 'faq.a3': 'Türkçe, İngilizce ve Rusça.',
    'faq.q4': 'İçerikler nereden geliyor?', 'faq.a4': 'Futbol gündemine ait halka açık sosyal medya gönderileri ve haber akışları gerçek zamanlı derlenir.',
    'faq.q5': 'Hesap açmam gerekiyor mu?', 'faq.a5': 'Hayır. Uygulamayı indirip doğrudan kullanmaya başlayabilirsin.',
    'faq.q6': 'Verilerim nasıl kullanılıyor?', 'faq.a6': 'Gizlilik politikamızda ayrıntılı açıklanmıştır:',
    'cta.title': 'Maçı kaçırma, gündemi kaçırma.',
    'cta.sub': "Pulse Sports'u ücretsiz indir, futbolun nabzını cebinde taşı.",
    'contact.eyebrow': 'İLETİŞİM', 'contact.title': 'Bize ulaşın',
    'contact.sub': 'Soru, öneri, hata bildirimi veya iş birliği — hepsini okuyoruz. Genellikle 1–2 iş günü içinde dönüş yapıyoruz.',
    'contact.email': 'E-posta', 'contact.privacy': 'Gizlilik Politikası', 'contact.privacyLink': 'Politikayı görüntüle',
    'contact.support': 'Uygulama Desteği', 'contact.supportLink': 'App Store sayfası',
    'form.name': 'Ad Soyad', 'form.email': 'E-posta', 'form.subject': 'Konu',
    'form.subjectGeneral': 'Genel', 'form.subjectBug': 'Hata Bildirimi', 'form.subjectPartnership': 'İş Birliği', 'form.subjectOther': 'Diğer',
    'form.message': 'Mesaj', 'form.submit': 'Gönder', 'form.success': 'Mesajın iletildi.',
    'footer.tagline': 'Futbolun nabzı, tek ekranda.',
    'footer.product': 'Ürün', 'footer.company': 'Şirket', 'footer.legal': 'Yasal',
    'footer.rights': 'Tüm hakları saklıdır.'
  };

  var EN = {
    'nav.features': 'Features', 'nav.screens': 'Screens', 'nav.faq': 'FAQ',
    'nav.contact': 'Contact', 'nav.admin': 'Admin Login',
    'hero.eyebrow': 'LIVE FOOTBALL FEED',
    'hero.title1': 'The pulse of football,', 'hero.title2': 'on one screen.',
    'hero.sub': 'Transfers, trends, team news and social updates — all real-time, in one app.',
    'hero.meta1': '4+ age', 'hero.meta2': 'Free', 'hero.meta3': '3 languages',
    'stats.teams': 'Teams', 'stats.langs': 'Languages', 'stats.live': 'Live Feed', 'stats.free': 'Free', 'stats.freeNum': '$0',
    'features.eyebrow': 'FEATURES',
    'features.title': 'Everything a fan needs',
    'features.sub': 'Pulse Sports brings everything about football into one personalized feed.',
    'features.card1.title': 'Personalized Feed',
    'features.card1.desc': 'A football feed that adapts to the teams you follow, updated in real time.',
    'features.card2.title': 'Trending',
    'features.card2.desc': "The most talked-about topics and trending hashtags in Turkish football right now.",
    'features.card3.title': 'Teams',
    'features.card3.desc': 'Separate feeds for Galatasaray, Fenerbahçe, Beşiktaş, Trabzonspor and the National Team.',
    'features.card4.title': 'Transfers',
    'features.card4.desc': 'Transfer news, rumors and official announcements in one tab.',
    'features.card5.title': 'Bookmarks',
    'features.card5.desc': 'Save posts you like and revisit them even offline.',
    'features.card6.title': 'Push Notifications',
    'features.card6.desc': 'Get notified instantly on important updates — no spam, only what matters.',
    'gallery.eyebrow': 'SCREENS', 'gallery.title': 'Inside the app',
    'gallery.sub': 'A modern, fast, dark-themed interface designed to keep you focused on the game.',
    'how.eyebrow': 'HOW IT WORKS', 'how.title': 'Get started in three steps',
    'how.step1.title': 'Download', 'how.step1.desc': 'Get it free on the App Store or Google Play.',
    'how.step2.title': 'Pick your team', 'how.step2.desc': 'Follow your favorite teams and your feed adapts instantly.',
    'how.step3.title': 'Stay in the loop', 'how.step3.desc': 'The feed works for you — trends, transfers, everything.',
    'faq.eyebrow': 'FAQ', 'faq.title': 'Frequently asked questions',
    'faq.q1': 'Is Pulse Sports free?', 'faq.a1': 'Yes, the app is completely free. Content is supported by ads.',
    'faq.q2': 'Which devices does it support?', 'faq.a2': 'iPhones running iOS 15.6+ and Android devices.',
    'faq.q3': 'Which languages are supported?', 'faq.a3': 'Turkish, English and Russian.',
    'faq.q4': 'Where does the content come from?', 'faq.a4': 'Publicly available social media posts and news about Turkish football, aggregated in real time.',
    'faq.q5': 'Do I need to create an account?', 'faq.a5': 'No. You can download the app and start using it right away.',
    'faq.q6': 'How is my data used?', 'faq.a6': 'This is explained in detail in our privacy policy:',
    'cta.title': "Don't miss the match, don't miss the buzz.",
    'cta.sub': 'Download Pulse Sports for free and carry the pulse of football in your pocket.',
    'contact.eyebrow': 'CONTACT', 'contact.title': 'Get in touch',
    'contact.sub': "Questions, suggestions, bug reports or partnerships — we read all of it. We usually reply within 1–2 business days.",
    'contact.email': 'Email', 'contact.privacy': 'Privacy Policy', 'contact.privacyLink': 'View policy',
    'contact.support': 'App Support', 'contact.supportLink': 'App Store page',
    'form.name': 'Full name', 'form.email': 'Email', 'form.subject': 'Subject',
    'form.subjectGeneral': 'General', 'form.subjectBug': 'Bug report', 'form.subjectPartnership': 'Partnership', 'form.subjectOther': 'Other',
    'form.message': 'Message', 'form.submit': 'Send', 'form.success': 'Your message has been sent.',
    'footer.tagline': 'The pulse of football, on one screen.',
    'footer.product': 'Product', 'footer.company': 'Company', 'footer.legal': 'Legal',
    'footer.rights': 'All rights reserved.'
  };

  var DICTS = { tr: TR, en: EN };

  function applyLang(lang) {
    var dict = DICTS[lang] || DICTS.tr;
    document.documentElement.setAttribute('lang', lang);
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (dict[key]) el.textContent = dict[key];
    });
    document.querySelectorAll('.lang-switch button').forEach(function (btn) {
      btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });
    try { localStorage.setItem('pulse_lang', lang); } catch (e) {}
  }

  function initLang() {
    var saved = null;
    try { saved = localStorage.getItem('pulse_lang'); } catch (e) {}
    var initial = saved || (navigator.language && navigator.language.toLowerCase().indexOf('tr') === 0 ? 'tr' : 'en');
    applyLang(initial);
    document.querySelectorAll('.lang-switch button').forEach(function (btn) {
      btn.addEventListener('click', function () { applyLang(btn.getAttribute('data-lang')); });
    });
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.querySelectorAll('.theme-switch button').forEach(function (btn) {
      btn.classList.toggle('active', btn.getAttribute('data-theme-btn') === theme);
    });
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', theme === 'light' ? '#FFFFFF' : '#0A0A0A');
    try { localStorage.setItem('pulse_theme', theme); } catch (e) {}
  }

  function initTheme() {
    var saved = null;
    try { saved = localStorage.getItem('pulse_theme'); } catch (e) {}
    var prefersLight = window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches;
    var initial = saved || (prefersLight ? 'light' : 'dark');
    applyTheme(initial);
    document.querySelectorAll('.theme-switch button').forEach(function (btn) {
      btn.addEventListener('click', function () { applyTheme(btn.getAttribute('data-theme-btn')); });
    });
  }

  function initNavbarScroll() {
    var nav = document.getElementById('navbar');
    function onScroll() { nav.classList.toggle('scrolled', window.scrollY > 20); }
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  function initMobileNav() {
    var toggle = document.getElementById('navToggle');
    var mobile = document.getElementById('navMobile');
    if (!toggle || !mobile) return;
    toggle.addEventListener('click', function () {
      var open = mobile.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(open));
    });
    mobile.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        mobile.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  function initReveal() {
    var items = document.querySelectorAll('.reveal');
    if (!('IntersectionObserver' in window)) {
      items.forEach(function (el) { el.classList.add('in-view'); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15 });
    items.forEach(function (el) { io.observe(el); });
  }

  function initFaq() {
    document.querySelectorAll('.faq-item').forEach(function (item) {
      var btn = item.querySelector('.faq-q');
      var panel = item.querySelector('.faq-a');
      btn.addEventListener('click', function () {
        var isOpen = item.classList.contains('open');
        document.querySelectorAll('.faq-item.open').forEach(function (open) {
          if (open !== item) {
            open.classList.remove('open');
            open.querySelector('.faq-q').setAttribute('aria-expanded', 'false');
            open.querySelector('.faq-a').style.maxHeight = null;
          }
        });
        item.classList.toggle('open', !isOpen);
        btn.setAttribute('aria-expanded', String(!isOpen));
        panel.style.maxHeight = !isOpen ? panel.scrollHeight + 'px' : null;
      });
    });
  }

  function initGallery() {
    var track = document.getElementById('galleryTrack');
    if (!track) return;
    var items = track.querySelectorAll('.gallery-item');
    function updateCenter() {
      var trackRect = track.getBoundingClientRect();
      var trackCenter = trackRect.left + trackRect.width / 2;
      var closest = null, closestDist = Infinity;
      items.forEach(function (item) {
        var r = item.getBoundingClientRect();
        var itemCenter = r.left + r.width / 2;
        var dist = Math.abs(itemCenter - trackCenter);
        if (dist < closestDist) { closestDist = dist; closest = item; }
      });
      items.forEach(function (item) { item.classList.toggle('is-center', item === closest); });
    }
    track.addEventListener('scroll', updateCenter, { passive: true });
    window.addEventListener('resize', updateCenter);
    updateCenter();
  }

  function initContactEmail() {
    var link = document.getElementById('contactEmailLink');
    if (!link) return;
    link.textContent = CONTACT_EMAIL;
    link.href = 'mailto:' + CONTACT_EMAIL;
  }

  function initForm() {
    var form = document.getElementById('contactForm');
    var success = document.getElementById('formSuccess');
    if (!form) return;
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var name = form.querySelector('#cf-name').value.trim();
      var email = form.querySelector('#cf-email').value.trim();
      var subject = form.querySelector('#cf-subject').value;
      var message = form.querySelector('#cf-message').value.trim();

      var mailSubject = '[Pulse Sports] ' + subject;
      var mailBody = message + '\n\n— ' + name + ' <' + email + '>';
      var href = 'mailto:' + CONTACT_EMAIL +
        '?subject=' + encodeURIComponent(mailSubject) +
        '&body=' + encodeURIComponent(mailBody);
      window.location.href = href;

      form.classList.add('hidden');
      success.classList.add('show');
    });
  }

  function initFooterYear() {
    var el = document.getElementById('footerYear');
    if (el) el.textContent = String(new Date().getFullYear());
  }

  document.addEventListener('DOMContentLoaded', function () {
    initTheme();
    initLang();
    initNavbarScroll();
    initMobileNav();
    initReveal();
    initFaq();
    initGallery();
    initContactEmail();
    initForm();
    initFooterYear();
  });
})();
