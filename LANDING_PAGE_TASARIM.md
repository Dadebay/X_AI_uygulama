# Pulse Sports — Web Landing Page Tasarım Spesifikasyonu

> **Bu dosya bir uygulama talimatıdır.** Baştan sona oku, sonra sırayla uygula.
> Hedef: `https://xaiuygulama.web.app` adresine girildiğinde admin login yerine
> **uygulama tanıtım (landing) sayfası** açılsın; admin panel `/admin` altına taşınsın.

---

## 0. Neden bu iş yapılıyor (bağlam)

Şu an web kökü doğrudan Flutter admin panelinin PIN ekranını açıyor. Bu sayfa aynı zamanda:

- **App Store "Developer Website" / Play Store "Website"** alanına yazılacak adres,
- **AdMob app-ads.txt doğrulaması**nın taradığı domain,
- Uygulamanın tek public yüzü.

Bu yüzden kökte hızlı, taranabilir, SEO uyumlu bir tanıtım sayfası olmalı.

**Canlı linkler (kodda birebir bunlar kullanılacak):**

| Ne | Link |
|---|---|
| App Store | `https://apps.apple.com/us/app/pulse-sports/id6790100133` |
| Google Play | `https://play.google.com/store/apps/details?id=com.gurbanov.xai` |
| Gizlilik Politikası | `https://www.freeprivacypolicy.com/live/52b95741-507c-42c1-81e9-3fa760fca7f6` |
| Admin panel | `/admin` (aynı domain, alt yol) |
| İletişim e-posta | `PLACEHOLDER_EMAIL` — **kullanıcı dolduracak**, kodda tek yerde tanımla |

---

## 1. MİMARİ KARARI (bu karar tartışmaya kapalı, sebebi aşağıda)

**Landing page Flutter ile YAPILMAYACAK. Saf HTML + CSS + vanilla JS olacak.**

Sebepler:

1. Mevcut Flutter web bundle'ı `main.dart.js` **2.98 MB** + `canvaskit.wasm` **7.15 MB**.
   Bir tanıtım sayfası 1 saniyenin altında açılmalı, bu mümkün değil.
2. Flutter web CanvasKit ile `<canvas>`'a çizim yapar. Google/Apple crawler'ları ve
   AdMob doğrulayıcısı sayfayı **boş** görür. SEO sıfırlanır.
3. Admin paneline hiç dokunulmaz — sadece alt yola taşınır, **çalışan kod riske girmez**.

Sonuç yapı:

```
xaiuygulama.web.app/            → statik landing (HTML/CSS/JS, ~60 KB)
xaiuygulama.web.app/admin/      → mevcut Flutter admin paneli (PIN ekranı, olduğu gibi)
xaiuygulama.web.app/app-ads.txt → mevcut haliyle kökte kalır (DEĞİŞTİRME)
```

---

## 2. DOSYA YAPISI

Yeni klasör oluştur: **`web_landing/`** (repo köküne, git'e commit edilecek kaynak klasör)

```
web_landing/
├── index.html              # tek sayfa, tüm section'lar
├── styles.css              # tüm stiller (tek dosya, framework yok)
├── main.js                 # nav, accordion, i18n, scroll-reveal
├── app-ads.txt             # web/app-ads.txt ile BİREBİR AYNI içerik
├── favicon.png             # web/favicon.png'den kopyala
├── robots.txt
├── sitemap.xml
├── fonts/
│   ├── Gilroy-Regular.woff2
│   ├── Gilroy-Medium.woff2
│   ├── Gilroy-SemiBold.woff2
│   └── Gilroy-Bold.woff2   # assets/fonts/*.ttf dosyalarını woff2'ye çevir
└── assets/
    ├── logo.svg            # veya web/icons/Icon-512.png
    ├── og-image.png        # 1200x630 sosyal medya önizleme
    ├── badge-appstore.svg
    ├── badge-googleplay.svg
    └── screens/
        ├── home.png
        ├── trends.png
        ├── teams.png
        ├── transfer.png
        └── detail.png
```

> **`web/` klasörüne DOKUNMA.** O klasör Flutter admin build'inin girdisi, olduğu gibi kalacak.

---

## 3. BUILD & DEPLOY DEĞİŞİKLİKLERİ

### 3.1 `firebase.json` — yeni hali

`public` alanı `build/web` → `public` olarak değişiyor ve global `**` rewrite'ı kaldırılıyor
(aksi halde landing sayfası admin'i ezer).

```json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "/admin/**", "destination": "/admin/index.html" }
    ],
    "cleanUrls": true,
    "headers": [
      {
        "source": "/index.html",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/app-ads.txt",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      },
      {
        "source": "/styles.css",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      },
      {
        "source": "/main.js",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      },
      {
        "source": "/fonts/**",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
      },
      {
        "source": "/assets/**",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=604800" }]
      },
      {
        "source": "/admin/index.html",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/admin/flutter_bootstrap.js",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/admin/main.dart.js",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      },
      {
        "source": "/admin/canvaskit/**",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
      },
      {
        "source": "**/*.@(png|jpg|jpeg|svg|webp|ico|ttf|otf|woff2)",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=2592000" }]
      }
    ]
  }
}
```

### 3.2 `deploy_web.sh` — repo köküne oluştur, `chmod +x`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> public/ temizleniyor"
rm -rf public
mkdir -p public

echo "==> landing kopyalanıyor"
cp -R web_landing/. public/

echo "==> admin paneli derleniyor (base-href=/admin/)"
flutter build web -t lib/main_admin.dart --release --base-href /admin/

echo "==> admin public/admin/ altına kopyalanıyor"
mkdir -p public/admin
cp -R build/web/. public/admin/

echo "==> app-ads.txt kök kontrolü"
test -f public/app-ads.txt || cp web/app-ads.txt public/app-ads.txt

echo "==> deploy"
firebase deploy --only hosting

echo "==> bitti: https://xaiuygulama.web.app"
```

`.gitignore`'a ekle:

```
/public/
```

> **Kritik:** `--base-href /admin/` olmadan Flutter alt yolda asset'lerini bulamaz, panel beyaz ekran verir.

### 3.3 Admin login butonu davranışı

Landing'deki "Admin Giriş" butonu sadece `<a href="/admin/">` olacak.
**Mevcut PIN ekranı (`lib/modules/admin/views/web/admin_web_app.dart`) hiç değişmeyecek.**
Kullanıcı `/admin/` adresine gidince zaten PIN ekranını görür.

---

## 4. TASARIM SİSTEMİ

### 4.1 Renkler (CSS custom properties — `:root` içinde tanımla)

Uygulamanın `lib/themes/colors.dart` paletiyle birebir uyumlu:

```css
:root {
  /* Marka */
  --green:        #22B241;
  --green-dark:   #1E9E3A;
  --green-glow:   rgba(34, 178, 65, 0.18);

  /* Yüzeyler (koyu tema varsayılan) */
  --bg:           #0A0A0A;
  --bg-elevated:  #0F0F0F;
  --surface:      #141414;
  --surface-2:    #1A1A1A;
  --border:       rgba(255,255,255,0.08);
  --border-hover: rgba(255,255,255,0.16);

  /* Metin */
  --text:         #FFFFFF;
  --text-2:       rgba(255,255,255,0.62);
  --text-3:       rgba(255,255,255,0.38);

  /* Vurgular */
  --blue:         #1D9BF0;   /* X/Twitter mavisi — sosyal akış vurgusu */
  --orange:       #FF9500;
  --red:          #E53935;

  /* Efekt */
  --radius-sm:  10px;
  --radius:     16px;
  --radius-lg:  24px;
  --radius-xl:  32px;
  --shadow:     0 8px 40px rgba(0,0,0,0.5);
  --shadow-lg:  0 24px 80px rgba(0,0,0,0.7);
  --ease:       cubic-bezier(0.22, 1, 0.36, 1);
}
```

**Renk kullanım kuralı:** Yeşil SADECE aksiyon ve vurgu için. Arka planları yeşile boyama.
Sayfanın %90'ı siyah/gri, %10'u yeşil olmalı. Yeşil "nefes alan" bir vurgu rengi.

### 4.2 Tipografi

Gilroy self-host. Fallback zinciri:

```css
--font: 'Gilroy', -apple-system, BlinkMacSystemFont, 'Segoe UI', Inter, sans-serif;
```

Akışkan ölçek (`clamp` — media query gerekmez):

| Rol | Boyut | Ağırlık | Letter-spacing | Line-height |
|---|---|---|---|---|
| Hero başlık | `clamp(2.5rem, 6vw, 4.5rem)` | 800 | `-0.03em` | `1.05` |
| Section başlık | `clamp(1.9rem, 4vw, 3rem)` | 800 | `-0.02em` | `1.15` |
| Kart başlık | `1.15rem` | 700 | `-0.01em` | `1.35` |
| Gövde büyük | `clamp(1rem, 1.6vw, 1.2rem)` | 400 | `0` | `1.65` |
| Gövde | `0.95rem` | 400 | `0` | `1.7` |
| Etiket / eyebrow | `0.78rem` | 600 | `0.12em` + `uppercase` | `1` |

### 4.3 Boşluk & Layout

```css
--container: 1180px;          /* max genişlik */
--gutter: clamp(20px, 5vw, 48px);
--section-y: clamp(72px, 12vw, 140px);   /* section dikey padding */
```

Grid: 12 kolon, `gap: 24px`. Mobilde tek kolon.

### 4.4 Hareket (motion)

- Tüm geçişler `.35s var(--ease)`.
- Scroll ile görünüme giren section'lar: `opacity 0 → 1`, `translateY(24px) → 0`,
  `IntersectionObserver` ile, `threshold: 0.15`, bir kez tetiklenir (`unobserve`).
- Kart hover: `translateY(-4px)` + border rengi `--border-hover` + hafif yeşil glow.
- **Zorunlu:** `@media (prefers-reduced-motion: reduce)` içinde tüm animasyonları
  `animation: none; transition: none; transform: none;` ile kapat.

---

## 5. SAYFA YAPISI — Section Section

### 5.1 Navbar (sticky)

```
┌────────────────────────────────────────────────────────────────────┐
│  [◉] Pulse Sports    Özellikler  Ekranlar  SSS  İletişim   TR|EN  [Admin Giriş] │
└────────────────────────────────────────────────────────────────────┘
```

- `position: sticky; top: 0; z-index: 100;`
- Başlangıçta arka plan **şeffaf**. Sayfa `> 20px` kaydırılınca JS `.scrolled` class'ı ekler:
  `background: rgba(10,10,10,0.72); backdrop-filter: blur(20px); border-bottom: 1px solid var(--border);`
- Logo: 32px yuvarlak ikon + "Pulse Sports" metni (600).
- Orta linkler: `--text-2`, hover'da `--text`. Smooth scroll (`scroll-behavior: smooth` + `scroll-margin-top: 90px` section'larda).
- **"Admin Giriş" butonu:** ghost stil — `border: 1px solid var(--border)`, şeffaf arka plan,
  `--text-2` metin. Hover'da `border-color: var(--green)` ve metin yeşile döner.
  **Dolu yeşil buton YAPMA** — store CTA'ları ile yarışmamalı. `href="/admin/"`.
- Mobilde (`< 860px`): orta linkler hamburger menüye girer. Admin butonu görünür kalır ama
  sadece kilit ikonu (🔒 yerine inline SVG shield) olur.

### 5.2 Hero

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   ● CANLI FUTBOL AKIŞI                    ╭─────────────╮   │
│                                           │             │   │
│   Futbolun nabzı,                         │   [telefon  │   │
│   tek ekranda.                            │   mockup +  │   │
│                                           │   home.png] │   │
│   Transferler, gündem, takım haberleri    │             │   │
│   ve sosyal medya akışı — hepsi           │             │   │
│   gerçek zamanlı, tek uygulamada.         ╰─────────────╯   │
│                                                              │
│   [ App Store ]  [ Google Play ]                            │
│                                                              │
│   ★ 4+ yaş  ·  Ücretsiz  ·  3 dil                           │
└──────────────────────────────────────────────────────────────┘
```

- Grid `1.05fr 0.95fr`, `align-items: center`, `min-height: 88vh`.
- **Eyebrow rozeti:** yeşil noktalı pill — `background: var(--green-glow)`, `border: 1px solid rgba(34,178,65,0.3)`,
  `border-radius: 999px`, içinde 6px yeşil daire + `CANLI FUTBOL AKIŞI` metni.
  Yeşil daireye `pulse` keyframe animasyonu (2s, scale + opacity ile halka yayılması).
- **Başlık:** "Futbolun nabzı," normal beyaz; "tek ekranda." satırı yeşil→açık yeşil
  `linear-gradient` + `background-clip: text`.
- **Arka plan efekti:** hero'nun arkasında iki adet `radial-gradient` blob —
  biri sol üstte yeşil (`--green-glow`, 600px, `filter: blur(120px)`), biri sağ altta mavi
  (`rgba(29,155,240,0.10)`). `position: absolute; pointer-events: none; z-index: -1;`
  Üstüne ince grid çizgisi deseni (`repeating-linear-gradient`, `opacity: 0.025`).
- **Telefon mockup'ı:** CSS ile çiz, dış görsel indirme.
  `width: 300px; aspect-ratio: 9/19.5; border-radius: 44px;`
  `border: 10px solid #1c1c1e; box-shadow: var(--shadow-lg);`
  içinde `screens/home.png` `object-fit: cover`.
  Üstte notch: `48px × 24px`, `#000`, `border-radius: 0 0 14px 14px`, ortalanmış.
  Hafif `transform: perspective(1200px) rotateY(-8deg) rotateX(2deg);`
  ve `float` keyframe (6s ease-in-out infinite alternate, `translateY(-12px)`).
- **Store rozetleri:** yükseklik 54px, `gap: 14px`, hover'da `translateY(-2px)` + parlaklık.
  Apple ve Google'ın **resmî rozet görsellerini** kullan
  (Apple: developer.apple.com/app-store/marketing/guidelines — Google: play.google.com/intl/en_us/badges).
  Rozet bulunamazsa muadili inline SVG çiz: siyah zemin, 1px beyaz kenarlık,
  sol tarafta platform logosu, sağda iki satır ("Download on the" / "App Store").
- Rozetlerin `<a>` etiketlerine `target="_blank" rel="noopener"` ve açıklayıcı `aria-label` ekle.

### 5.3 İstatistik şeridi

Hero'nun hemen altında, tek satır, 4 kolon, üstünde ve altında `1px solid var(--border)`:

```
   5+            3            7/24           0 ₺
 Takım        Dil        Canlı akış     Ücretsiz
```

Sayılar `2rem/800` yeşil değil beyaz; alt etiket `--text-3`, uppercase, `0.75rem`.
Aralarında dikey `1px` ayraç. Mobilde 2x2 grid.

### 5.4 Özellikler — Bento Grid

Başlık bloğu: eyebrow `ÖZELLİKLER` (yeşil) + başlık "Bir taraftarın ihtiyacı olan her şey"
+ alt metin. Ortalanmış, `max-width: 620px`.

Bento düzeni (desktop 3 kolon, ilk kart 2 kolon geniş):

```
┌───────────────────────┬───────────┐
│  Sana Özel Akış (2x)  │  Gündem   │
├───────────┬───────────┼───────────┤
│  Takımlar │ Transfer  │ Kaydet    │
├───────────┴───────────┴───────────┤
│  Bildirimler (3x, yatay)          │
└───────────────────────────────────┘
```

Kart stili:
```css
background: linear-gradient(180deg, var(--surface) 0%, var(--bg-elevated) 100%);
border: 1px solid var(--border);
border-radius: var(--radius-lg);
padding: 32px;
transition: .35s var(--ease);
```
Hover: `transform: translateY(-4px); border-color: var(--border-hover);`
+ `box-shadow: 0 12px 40px rgba(0,0,0,.4), 0 0 0 1px var(--green-glow);`

Her kartta: 48px yuvarlak ikon kutusu (`background: var(--green-glow)`, `border-radius: 14px`,
içinde 22px stroke SVG ikon, `stroke: var(--green)`) → başlık → 2 satır açıklama.

**İkonlar inline SVG olacak** (ikon kütüphanesi yükleme). 24x24 viewBox, `stroke-width: 1.8`,
`stroke-linecap: round`, `fill: none`.

İçerik (TR):

| Kart | Başlık | Açıklama |
|---|---|---|
| 1 | Sana Özel Akış | Takip ettiğin takımlara göre kişiselleşen, saniyesi saniyesine güncellenen futbol akışı. |
| 2 | Gündem | Türkiye'de futbol dünyasının o an en çok konuşulan başlıkları ve trend etiketleri. |
| 3 | Takımlar | Galatasaray, Fenerbahçe, Beşiktaş, Trabzonspor ve Milli Takım için ayrı beslemeler. |
| 4 | Transfer | Transfer haberleri, söylentiler ve resmî açıklamalar tek bir sekmede. |
| 5 | Kaydet | Beğendiğin gönderileri kaydet, internet olmadan da geri dön. |
| 6 | Anlık Bildirimler | Önemli gelişme olduğunda anında haberdar ol — spam yok, sadece önemli olan. |

### 5.5 Ekran Görüntüleri Galerisi

Tam genişlik, yatay kayan şerit (`overflow-x: auto`, `scroll-snap-type: x mandatory`).
5 telefon mockup'ı yan yana, her biri `240px` genişlik, `scroll-snap-align: center`.
Kenarlarda `mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent)`
ile yumuşak solma.
Scrollbar gizle (`scrollbar-width: none; &::-webkit-scrollbar { display: none; }`).
Desktop'ta ortadaki büyük (`scale(1.06)`), kenardakiler `opacity: .55`.

### 5.6 Nasıl Çalışır — 3 Adım

Yatay 3 kolon, aralarında kesik çizgi bağlantı (desktop'ta `::after` ile).

```
   ①  İndir              ②  Takımını seç          ③  Takipte kal
   App Store veya       Favori takımlarını       Akış senin için
   Google Play'den      işaretle, akışın         çalışır — gündem,
   ücretsiz indir.      anında şekillensin.      transfer, her şey.
```

Numaralar: 44px daire, `border: 1.5px solid var(--green)`, şeffaf zemin, yeşil rakam (700).

### 5.7 SSS — Accordion

`<details>`/`<summary>` **kullanma** (stil kontrolü zor). Buton + `aria-expanded` + `max-height`
geçişli kendi accordion'unu yaz. Tek seferde bir tane açık kalsın.

Satır stili: `border-bottom: 1px solid var(--border)`, `padding: 22px 0`.
Sağda `+` ikonu, açıkken `rotate(45deg)` ile `×` olur.

Sorular:
1. **Pulse Sports ücretsiz mi?** — Evet, uygulama tamamen ücretsiz. İçerikler reklam destekli sunulur.
2. **Hangi cihazlarda çalışıyor?** — iOS 15.6 ve üzeri iPhone'lar ile Android cihazlarda.
3. **Hangi dilleri destekliyor?** — Türkçe, İngilizce ve Rusça.
4. **İçerikler nereden geliyor?** — Futbol gündemine ait halka açık sosyal medya gönderileri ve haber akışları gerçek zamanlı derlenir.
5. **Hesap açmam gerekiyor mu?** — Hayır. Uygulamayı indirip doğrudan kullanmaya başlayabilirsin.
6. **Verilerim nasıl kullanılıyor?** — Gizlilik politikamızda ayrıntılı açıklanmıştır. *(link ver)*

### 5.8 İndirme CTA Bandı

Tam genişlik, dikkat çekici blok:

```css
background: linear-gradient(135deg, #12351E 0%, #0A0A0A 55%);
border: 1px solid rgba(34,178,65,0.22);
border-radius: var(--radius-xl);
padding: clamp(48px, 8vw, 80px);
text-align: center;
position: relative; overflow: hidden;
```
İçine dekoratif yeşil radial blob (`::before`, blur 100px, üst ortada, `opacity: .5`).

Metin: **"Maçı kaçırma, gündemi kaçırma."**
Alt: "Pulse Sports'u ücretsiz indir, futbolun nabzını cebinde taşı."
Altına iki store rozeti yan yana, ortalanmış.

### 5.9 İletişim

İki kolon: solda metin + iletişim kanalları, sağda form.

**Sol:**
- Başlık: "Bize ulaşın"
- Metin: "Soru, öneri, hata bildirimi veya iş birliği — hepsini okuyoruz. Genellikle 1–2 iş günü içinde dönüş yapıyoruz."
- Kanal satırları (ikon + etiket + değer):
  - ✉ E-posta → `mailto:PLACEHOLDER_EMAIL`
  - 🛡 Gizlilik Politikası → dış link
  - 📱 Uygulama Desteği → App Store sayfası

**Sağ — form.**
Firebase Hosting statik olduğu için **backend yok**. İki seçenek, **A'yı uygula**:

**A) `mailto:` yöntemi (varsayılan — sıfır bağımlılık):**
Form `submit`'te JS ile `mailto:` linki oluştur:
```js
location.href = `mailto:${EMAIL}?subject=${encodeURIComponent('[Pulse] ' + konu)}&body=${encodeURIComponent(mesaj + '\n\n— ' + isim + ' <' + eposta + '>')}`;
```

**B) Firestore'a yazma (opsiyonel, sadece kullanıcı isterse):**
Firebase Web SDK modüler import ile `contact_messages` koleksiyonuna `addDoc`.
Gerekli kural (`firestore.rules`):
```
match /contact_messages/{id} {
  allow create: if request.resource.data.keys().hasOnly(['name','email','subject','message','createdAt'])
                && request.resource.data.message is string
                && request.resource.data.message.size() < 2000;
  allow read, update, delete: if false;
}
```
> B seçilirse admin panele bu mesajları listeleyen bir sayfa da eklenmeli — ayrı iş, bu spec kapsamında değil.

Form alanları: Ad Soyad, E-posta, Konu (select: Genel / Hata Bildirimi / İş Birliği / Diğer), Mesaj (textarea 5 satır).
Input stili:
```css
background: var(--surface); border: 1px solid var(--border);
border-radius: var(--radius-sm); padding: 14px 16px; color: var(--text);
```
`:focus` → `border-color: var(--green); box-shadow: 0 0 0 3px var(--green-glow); outline: none;`
Gönder butonu: dolu yeşil, tam genişlik, `border-radius: var(--radius-sm)`, `height: 52px`.
Başarı durumunda formun yerine yeşil tikli "Mesajın iletildi" kartı göster.

### 5.10 Footer

```
┌──────────────────────────────────────────────────────────────┐
│  [◉] Pulse Sports          Ürün        Şirket      Yasal     │
│  Futbolun nabzı,           Özellikler  İletişim    Gizlilik  │
│  tek ekranda.              Ekranlar    Admin       Şartlar   │
│                            SSS                                │
│  [App Store] [Google Play]                                   │
├──────────────────────────────────────────────────────────────┤
│  © 2026 Bilermen Nesil HK. Tüm hakları saklıdır.             │
└──────────────────────────────────────────────────────────────┘
```

- Üst kısım 4 kolon (`2fr 1fr 1fr 1fr`), mobilde 2x2.
- Alt bar `border-top: 1px solid var(--border)`, `--text-3`, `0.85rem`.
- Yıl JS ile dinamik: `new Date().getFullYear()`.
- "Admin" linki footer'da da olsun (`/admin/`), `--text-3` renginde, dikkat çekmesin.

---

## 6. ÇOK DİLLİLİK (TR / EN)

Basit `data-i18n` yaklaşımı — kütüphane yok:

```html
<h1 data-i18n="hero.title">Futbolun nabzı, tek ekranda.</h1>
```

`main.js` içinde iki sözlük nesnesi (`TR`, `EN`). Dil değişince
`document.querySelectorAll('[data-i18n]')` üzerinde dön, `textContent` güncelle,
`localStorage.setItem('lang', ...)` ile sakla, `<html lang>` özniteliğini güncelle.
İlk yüklemede: `localStorage` → yoksa `navigator.language.startsWith('tr') ? 'TR' : 'EN'`.

Varsayılan dil **TR**. Tüm İngilizce metinleri de sen yaz, kullanıcıya bırakma.

---

## 7. SEO & META (kritik — sayfanın asıl işlerinden biri)

`<head>` içeriği:

```html
<title>Pulse Sports — Futbolun nabzı, tek ekranda</title>
<meta name="description" content="Transferler, gündem, takım haberleri ve sosyal medya akışı tek uygulamada. Pulse Sports'u iOS ve Android için ücretsiz indir.">
<link rel="canonical" href="https://xaiuygulama.web.app/">
<meta name="theme-color" content="#0A0A0A">

<meta property="og:type" content="website">
<meta property="og:title" content="Pulse Sports — Futbolun nabzı, tek ekranda">
<meta property="og:description" content="Transferler, gündem, takım haberleri ve sosyal medya akışı tek uygulamada.">
<meta property="og:image" content="https://xaiuygulama.web.app/assets/og-image.png">
<meta property="og:url" content="https://xaiuygulama.web.app/">
<meta name="twitter:card" content="summary_large_image">

<!-- Akıllı uygulama banner'ı: iOS Safari'de otomatik indirme şeridi çıkarır -->
<meta name="apple-itunes-app" content="app-id=6790100133">
```

JSON-LD (App Store/Play zenginleştirmesi için — `</body>` öncesi):

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "MobileApplication",
  "name": "Pulse Sports",
  "operatingSystem": "iOS 15.6+, Android",
  "applicationCategory": "SportsApplication",
  "description": "Canlı futbol haberleri, transferler, gündem ve sosyal medya akışı.",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "USD" },
  "author": { "@type": "Organization", "name": "Bilermen Nesil HK" },
  "downloadUrl": [
    "https://apps.apple.com/us/app/pulse-sports/id6790100133",
    "https://play.google.com/store/apps/details?id=com.gurbanov.xai"
  ]
}
</script>
```

`robots.txt`:
```
User-agent: *
Allow: /
Disallow: /admin/
Sitemap: https://xaiuygulama.web.app/sitemap.xml
```

> `/admin/` mutlaka `Disallow` olmalı — admin paneli arama sonuçlarında çıkmasın.

---

## 8. ERİŞİLEBİLİRLİK (atlanmayacak)

- Semantik HTML: `<header> <nav> <main> <section> <footer>`, her section'da `<h2>`, sayfada tek `<h1>`.
- Tüm `<img>` etiketlerinde anlamlı `alt`. Dekoratif olanlarda `alt=""` + `aria-hidden="true"`.
- Görünür focus halkası: `:focus-visible { outline: 2px solid var(--green); outline-offset: 3px; }`
- Accordion: `<button aria-expanded="true|false" aria-controls="panel-id">`, panelde `role="region"`.
- Mobil menü butonunda `aria-label="Menüyü aç"` + `aria-expanded`.
- Kontrast: `--text-3` (`opacity .38`) sadece **büyük metin veya dekoratif** kullanılabilir,
  gövde metninde kullanma — WCAG AA'dan düşer.
- `<a>` etiketlerinde `target="_blank"` varsa `rel="noopener noreferrer"` zorunlu.

---

## 9. PERFORMANS BÜTÇESİ

| Kalem | Limit |
|---|---|
| HTML | < 25 KB |
| CSS | < 22 KB |
| JS | < 10 KB |
| Fontlar (4 woff2, subset latin+latin-ext) | < 90 KB |
| Görseller (toplam, ilk ekran) | < 250 KB |
| **Toplam ilk yükleme** | **< 400 KB** |
| Lighthouse Performance | ≥ 95 |

Kurallar:
- **Sıfır dış bağımlılık.** CDN yok, framework yok, jQuery yok, Google Fonts yok, analytics yok.
- Ekran görüntülerini **WebP**'ye çevir, `<img loading="lazy" decoding="async" width height>` ile ver
  (boyut öznitelikleri CLS'i sıfırlar).
- Hero görselinde `loading="eager" fetchpriority="high"`.
- Fontlarda `font-display: swap` + `<link rel="preload" as="font" type="font/woff2" crossorigin>`
  sadece Regular ve Bold için.
- CSS tek dosya, `<link>` ile; kritik CSS'i satır içine almaya gerek yok (dosya zaten küçük).
- JS `<script defer>` ile en altta.

---

## 10. RESPONSIVE KIRILMA NOKTALARI

| Breakpoint | Davranış |
|---|---|
| `≥ 1180px` | Tam düzen, hero 2 kolon, bento 3 kolon |
| `1024–1179px` | Container `%92` genişlik, hero 2 kolon korunur |
| `860–1023px` | Bento 2 kolon, hero telefon küçülür (`260px`) |
| `< 860px` | **Tek kolon.** Hero metni ortalanır, telefon metnin ALTINA iner. Nav hamburger. Bento tek kolon. İletişim tek kolon. |
| `< 480px` | Store rozetleri alt alta, tam genişlik. Stat şeridi 2x2. Padding `20px`. |

Mobilde hero telefonunun `rotateY` transform'unu **kaldır** (düz göster) — dar ekranda kötü duruyor.

---

## 11. KULLANICIDAN İSTENECEK VARLIKLAR

Bu dosyaları kullanıcı sağlamalı. **Yoksa placeholder ile devam et, sonra değiştirilir:**

1. **5 adet uygulama ekran görüntüsü** (1170×2532 veya benzeri, PNG) →
   `web_landing/assets/screens/` altına `home.png, trends.png, teams.png, transfer.png, detail.png`
   *(App Store listeleme görsellerinden veya simulator'dan alınabilir)*
2. **İletişim e-posta adresi** → `PLACEHOLDER_EMAIL` yerine yazılacak
3. **OG görseli** (1200×630) → yoksa sen üret: siyah zemin, logo + "Pulse Sports" + slogan
4. **Resmî store rozetleri** → indirilmezse spec 5.2'deki inline SVG muadilini çiz

Ekran görüntüsü yoksa: telefon mockup'ının içini `--surface` zeminde ortalanmış logo +
"Ekran görüntüsü" yazısıyla doldur, kod çalışsın.

---

## 12. UYGULAMA SIRASI

1. `web_landing/` klasörünü ve iskelet dosyaları oluştur
2. Gilroy `.ttf` → `.woff2` dönüşümü (`fonttools` veya online), `fonts/` altına koy
3. `styles.css` — önce tokenlar ve reset, sonra section section
4. `index.html` — tüm section'lar, semantik yapı, TR metinler
5. `main.js` — navbar scroll, hamburger, accordion, i18n, scroll-reveal, form, footer yılı
6. `app-ads.txt`, `robots.txt`, `sitemap.xml`, `favicon.png` kopyala
7. `firebase.json`'ı bölüm 3.1'deki haliyle değiştir
8. `deploy_web.sh` oluştur + `chmod +x` + `.gitignore`'a `/public/`
9. Yerelde doğrula: `python3 -m http.server 8080 --directory web_landing`
10. `./deploy_web.sh` ile deploy et
11. Doğrula (bölüm 13)

---

## 13. KABUL KRİTERLERİ (bitince tek tek kontrol et)

- [ ] `https://xaiuygulama.web.app/` → landing page açılıyor, admin PIN ekranı **görünmüyor**
- [ ] `https://xaiuygulama.web.app/admin/` → mevcut Flutter PIN ekranı sorunsuz açılıyor
- [ ] `https://xaiuygulama.web.app/app-ads.txt` → `google.com, pub-3012262156319967, DIRECT, f08c47fec0942fa0` dönüyor
- [ ] Navbar'daki "Admin Giriş" butonu `/admin/`'e gidiyor
- [ ] İki store rozeti de doğru linke, yeni sekmede açılıyor
- [ ] 375px genişlikte yatay scroll **yok**
- [ ] TR ↔ EN dil değişimi tüm metinleri çeviriyor, yenilemede seçim korunuyor
- [ ] Accordion klavyeyle (Tab + Enter) çalışıyor
- [ ] Lighthouse: Performance ≥ 95, Accessibility ≥ 95, SEO = 100
- [ ] `prefers-reduced-motion: reduce` ile animasyonlar duruyor
- [ ] Konsolda hata yok, 404 isteği yok

---

## 14. TASARIM REFERANSI — hedeflenen kalite çıtası

Görsel dil olarak şu sayfaların yalınlığını hedefle: **Linear.app**, **Raycast.com**, **Arc.net**.
Ortak noktaları:

- Çok koyu, neredeyse siyah zemin; tek bir doygun vurgu rengi
- Cömert beyaz alan — section'lar arası nefes payı bol
- İnce (`1px`, düşük opaklık) kenarlıklarla tanımlanan yüzeyler, ağır gölge yok
- Sıkı harf aralıklı (`-0.02em`), kalın (800) başlıklar
- Hareket var ama **abartısız** — 300–400ms, yumuşak easing, sayfa zıplamıyor
- Ürünün kendisi (telefon mockup'ı) sayfanın kahramanı

**Kaçınılacaklar:** gradient patlaması, birden fazla vurgu rengi, gereksiz emoji,
stok fotoğraf, karusel otomatik oynatma, pop-up, cookie banner (analytics yok, gerek de yok).
