# Admin Panel (Flutter Web) — Performans Optimizasyon Planı

> Bu dosya, `build/web` çıktısı ve `lib/modules/admin/**` kaynak kodu üzerinde yapılan
> ölçümlere dayanır. Uygulaması için hazırlanmıştır — her madde bağımsız uygulanabilir,
> sıralama etki/efor oranına göredir.

**Hedef:** İlk açılış (cold load) süresini ve PIN sonrası bekleme süresini belirgin şekilde düşürmek.

---

## 0. Mevcut Durum — Ölçülen Veriler

Bunlar tahmin değil, `build/web` klasöründen okunan gerçek boyutlar:

| Dosya | Boyut | Not |
|---|---|---|
| `build/web/main.dart.js` | **2.98 MB** | Tüm mobil uygulama ağacı da içinde derleniyor |
| `build/web/assets/packages/hugeicons/lib/fonts/hugeicons-stroke-rounded.ttf` | **1.9 MB** | Tam ikon fontu, tree-shake edilmemiş |
| `build/web/favicon.png` | **398 KB** | Favicon için absürt boyut |
| `build/web/canvaskit/canvaskit.wasm` | 7.15 MB | Tarayıcı bunlardan yalnızca birini indirir |
| `build/web/canvaskit/skwasm.wasm` | 3.55 MB | (renderer seçimine göre) |
| `build/web/assets/NOTICES` | 1.4 MB | Lazy, ilk yüklemeyi doğrudan etkilemez |
| `build/web/assets/assets` (images+lottie) | 3.3 MB | Admin panelde kullanılmıyor |
| **Toplam deploy** | **45 MB** | Firebase Hosting'e her seferinde yükleniyor |

**Kod tarafındaki darboğazlar:**

1. `lib/modules/admin/views/web/admin_web_app.dart:36` → `_submit()` içinde `verifyPin` çağrılıyor,
   o da `lib/modules/admin/controllers/web_admin_controller.dart:36`'da `await loadAll()` yapıyor.
   **Sonuç:** PIN doğru girildikten sonra 5 Firestore isteği bitene kadar kullanıcı spinner'a bakıyor,
   panel hiç açılmıyor.
2. `config/settings` dokümanı **4 ayrı kez** okunuyor: `getAdminPin()`, `getPriorityAccounts()`,
   `getMinEngagementThreshold()`, `getAdsEnabled()` (`lib/core/services/firestore_service.dart:53-113`).
   Aynı doküman, 4 ayrı network round-trip.
3. `lib/main.dart:30-36` → Web'de de `GetStorage`, `LanguageController`, `ThemeController`,
   `AuthController`, `SavedController` kuruluyor. Admin panelin hiçbirine ihtiyacı yok, ama bu
   controller'lar mobil kod ağacını canlı tutuyor → dart2js tree-shaking yapamıyor.
4. `lib/modules/admin/views/web/admin_web_shell.dart:31-40` → Sayfa geçişi `switch` ile,
   her geçişte sayfa sıfırdan `build` ediliyor, scroll pozisyonu ve state kayboluyor.
5. `firebase.json` içinde **hiç cache header yok** → dönen kullanıcı her seferinde
   `main.dart.js` + `canvaskit.wasm` + fontları yeniden doğruluyor.
6. `web/index.html` boş `<body>` ile başlıyor → Flutter yüklenene kadar **beyaz ekran**.
   Kullanıcının "çok ağır" algısının büyük kısmı burada.

---

## FAZ 1 — Hızlı Kazanımlar (kod değişikliği minimal, etki yüksek)

### 1.1 Cache header'ları ekle — `firebase.json`

Şu an dönen her ziyaretçi tüm payload'ı yeniden doğruluyor. Flutter'ın çıktı dosyaları
hash'siz olduğu için stratejiyi dosya tipine göre ayırmak gerekir:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }],
    "headers": [
      {
        "source": "/index.html",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/flutter_bootstrap.js",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/flutter_service_worker.js",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, must-revalidate" }]
      },
      {
        "source": "/main.dart.js",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=3600" }]
      },
      {
        "source": "/canvaskit/**",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
      },
      {
        "source": "/assets/**",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=604800" }]
      },
      {
        "source": "**/*.@(png|jpg|jpeg|svg|webp|ico|ttf|otf|woff2)",
        "headers": [{ "key": "Cache-Control", "value": "public, max-age=2592000" }]
      }
    ]
  }
}
```

> `index.html` ve `flutter_bootstrap.js` asla uzun cache'lenmemeli — yoksa deploy sonrası
> kullanıcılar eski sürümde takılı kalır. Geri kalan her şey uzun cache'lenebilir.

**Beklenen etki:** İlk yükleme aynı, **ikinci ve sonraki yüklemeler dramatik hızlanır**
(canvaskit + fontlar tamamen diskten gelir).

---

### 1.2 Favicon'u küçült — 398 KB → ~5 KB

`web/favicon.png` şu an 398 KB. Bu dosya her sayfa açılışında indirilir.

```bash
sips -Z 64 web/favicon.png --out web/favicon.png
```

veya daha iyisi 32×32 üret. Aynı şekilde `web/icons/` altındaki PWA ikonlarını da kontrol et.

---

### 1.3 Beyaz ekran yerine loading splash — `web/index.html`

Kullanıcının "ağır" algısının en büyük kaynağı, Flutter motoru yüklenene kadar geçen
tamamen boş beyaz ekran. `<body>` içine inline (harici istek gerektirmeyen) bir splash koy:

```html
<body>
  <style>
    body { margin: 0; background: #0D0D0D; }
    #loading {
      position: fixed; inset: 0; display: flex; flex-direction: column;
      align-items: center; justify-content: center; gap: 18px;
      background: #0D0D0D; font-family: system-ui, -apple-system, sans-serif;
      transition: opacity .35s ease;
    }
    #loading .ring {
      width: 42px; height: 42px; border-radius: 50%;
      border: 3px solid rgba(255,255,255,.12); border-top-color: #00C853;
      animation: spin .9s linear infinite;
    }
    #loading .label { color: rgba(255,255,255,.45); font-size: 13px; letter-spacing: .3px; }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>

  <div id="loading">
    <div class="ring"></div>
    <div class="label">Pulse Admin yükleniyor…</div>
  </div>

  <script>
    window.addEventListener('flutter-first-frame', function () {
      var el = document.getElementById('loading');
      if (!el) return;
      el.style.opacity = '0';
      setTimeout(function () { el.remove(); }, 350);
    });
  </script>

  <script src="flutter_bootstrap.js" async></script>
</body>
```

> `flutter-first-frame` event'i Flutter tarafından ilk kare çizildiğinde tetiklenir —
> manuel timeout'a gerek yok.

**Beklenen etki:** Ölçülen süre değişmez, **algılanan süre belirgin şekilde düşer.**
Bu en ucuz kazanç.

---

### 1.4 PIN sonrası bloklamayı kaldır — `web_admin_controller.dart`

Şu anki akış: PIN doğru → 5 Firestore isteği paralel başlar → **hepsi bitene kadar panel açılmaz.**

`lib/modules/admin/controllers/web_admin_controller.dart:32-44`:

```dart
Future<bool> verifyPin(String pin) async {
  final settings = await _firestore.getSettings();   // bkz. 1.5
  if (pin != (settings['adminPin']?.toString() ?? '2024')) return false;

  // Ayarlar zaten elimizde — tekrar okumaya gerek yok
  _applySettings(settings);

  isPinVerified.value = true;   // Panel HEMEN açılsın

  // Veri yüklemesi arka planda; her sayfa kendi loading state'ini gösterir
  unawaited(loadStats());
  return true;
}
```

`import 'dart:async';` eklemeyi unutma (`unawaited` için).

`loadTeams()`, `loadUsers()`, `loadPriorityAccounts()` artık burada çağrılmasın — bkz. 2.1.

**Beklenen etki:** PIN sonrası bekleme ~1-2 saniyeden **anlık** hale gelir.

---

### 1.5 `config/settings` dokümanını tek seferde oku — `firestore_service.dart`

Şu an aynı doküman 4 kez ayrı ayrı çekiliyor. `lib/core/services/firestore_service.dart` içine:

```dart
Map<String, dynamic>? _settingsCache;

/// config/settings dokümanını tek seferde okur ve cache'ler.
Future<Map<String, dynamic>> getSettings({bool forceRefresh = false}) async {
  if (!forceRefresh && _settingsCache != null) return _settingsCache!;
  try {
    final snap = await _db.collection('config').doc('settings').get();
    _settingsCache = snap.data() ?? {};
  } catch (_) {
    _settingsCache = {};
  }
  return _settingsCache!;
}

/// Yazma işlemlerinden sonra cache'i güncel tut.
void _patchSettingsCache(Map<String, dynamic> patch) {
  _settingsCache = {...?_settingsCache, ...patch};
}
```

Ardından `getAdminPin()`, `getPriorityAccounts()`, `getMinEngagementThreshold()`,
`getAdsEnabled()` bu tek okumadan beslensin. `setPriorityAccounts()`,
`setMinEngagementThreshold()`, `setAdsEnabled()` yazdıktan sonra `_patchSettingsCache(...)` çağırsın.

**Beklenen etki:** 4 network round-trip → 1.

---

### 1.6 Firestore offline persistence aç (web)

Web'de Firestore'un IndexedDB cache'i **varsayılan olarak kapalıdır**. Açılınca dönen
kullanıcıda takımlar/kullanıcılar listesi anında cache'ten gelir, arkadan sunucu tazeler.

`lib/main.dart` içinde, `Firebase.initializeApp` sonrasında:

```dart
if (kIsWeb) {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

> Not: Bu ayar mutlaka **ilk Firestore işleminden önce** yapılmalı, yoksa hata fırlatır.

---

## FAZ 2 — Payload Küçültme (asıl büyük kazanç)

### 2.1 Ayrı web entrypoint: `lib/main_admin.dart`

Şu an `lib/main.dart`, `SplashScreen`, `AuthController`, `SavedController`,
`LanguageController`, `ThemeController`, `AppTranslations`, `google_mobile_ads` gibi tüm mobil
ağacı import ediyor. `kIsWeb` kontrolü bazı dalları elese de, `main()` içinde **koşulsuz**
çağrılan `Get.put(AuthController())` / `Get.put(SavedController())` satırları bu ağacı canlı
tutuyor ve tree-shaking'i engelliyor.

Yeni dosya — `lib/main_admin.dart`:

```dart
import 'package:atlas/firebase_options.dart';
import 'package:atlas/modules/admin/views/web/admin_web_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pulse Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ThemeData.dark().colorScheme.copyWith(primary: const Color(0xFF00C853)),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Gilroy'),
        primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(fontFamily: 'Gilroy'),
      ),
      home: const AdminWebApp(),
    );
  }
}
```

`lib/main.dart` sadeleşir — `kIsWeb ? AdminPanelApp() : AtlasApp()` dallanması ve
`AdminPanelApp` sınıfı oradan kaldırılır, mobil için saf `runApp(const AtlasApp())` kalır.

Build komutu:

```bash
flutter build web --release -t lib/main_admin.dart
```

> **Doğrulama:** Değişiklik öncesi/sonrası `ls -la build/web/main.dart.js` çıktısını
> karşılaştır. Kazanç bu projede ölçülmeli — tree-shaking'in ne kadarını zaten yaptığı
> ancak iki build karşılaştırılarak görülür.

---

### 2.2 hugeicons fontunu admin panelden çıkar — **1.9 MB**

Bu tek başına en büyük tekil asset. `build/web/assets/packages/hugeicons/lib/fonts/hugeicons-stroke-rounded.ttf`
tam **1.9 MB** ve tree-shake edilmemiş halde deploy ediliyor. Admin panel bu fonttan yalnızca
bir avuç ikon kullanıyor, üstelik login ekranında kullanıldığı için **ilk ekranda indiriliyor.**

Admin panelde `HugeIcons.*` kullanan yerler:

- `lib/modules/admin/views/web/admin_web_app.dart` (`strokeRoundedShield01`)
- `lib/modules/admin/views/web/admin_web_shell.dart` (sidebar ikonları)
- `lib/modules/admin/views/web/pages/*.dart`

**Yapılacak:** Bu dosyalardaki `HugeIcons.*` kullanımlarını Material `Icons.*` karşılıklarıyla
değiştir (`Icons.shield_outlined`, `Icons.dashboard_outlined`, `Icons.groups_outlined`,
`Icons.people_outline`, `Icons.star_outline`, `Icons.analytics_outlined`,
`Icons.campaign_outlined` vb.). MaterialIcons fontu `--tree-shake-icons` ile birkaç KB'a iner.

> Mobil taraf `hugeicons`'ı kullanmaya devam edebilir — `pubspec.yaml`'dan paketi kaldırmaya
> gerek yok. Sadece admin panel dosyalarındaki import ve kullanımlar temizlenmeli. Web
> build'i ayrı entrypoint'ten (2.1) alındığı için font ağaca hiç girmez.

Build'de tree-shaking'i açıkça zorla:

```bash
flutter build web --release -t lib/main_admin.dart --tree-shake-icons
```

**Beklenen etki:** ~1.9 MB'lık font indirmesi tamamen ortadan kalkar.

---

### 2.3 Admin build'ine gereksiz asset'leri sokma — 3.3 MB

`assets/images` (2.2 MB — `banner.png` tek başına 1.1 MB) ve `assets/lottie` (580 KB)
admin panelde kullanılmıyor ama `pubspec.yaml`'daki `assets:` bloğu yüzünden `build/web`'e
kopyalanıyor ve `AssetManifest`'e giriyor.

Bunlar **lazy** yüklendiği için ilk açılışı doğrudan yavaşlatmaz, ancak:
- Deploy boyutunu ve süresini şişiriyor (45 MB),
- `AssetManifest.bin` gereksiz büyüyor.

**Pratik çözüm** — deploy öncesi web çıktısından temizle:

```bash
rm -rf build/web/assets/assets/images build/web/assets/assets/lottie
```

Ayrıca `banner.png` (1.1 MB), `kartal.png` (424 KB), `logo.png` (392 KB) mobil için de
gereğinden büyük — WebP'ye çevirmek mobil APK boyutunu da düşürür (ayrı iş kalemi).

---

### 2.4 Web'de gereksiz servis dosyası

`web/firebase-messaging-sw.js` mevcut, ancak `lib/main.dart:38` içindeki `if (!kIsWeb)`
guard'ı nedeniyle web'de FCM zaten başlatılmıyor. Admin panelde push bildirim
kullanılmayacaksa bu dosya kaldırılabilir (küçük ama gereksiz bir istek).

---

## FAZ 3 — Runtime / UX İyileştirmeleri

### 3.1 Sayfa başına tembel (lazy) veri yükleme

Şu an `loadAll()` panel açılırken **teams + users + priorityAccounts + adsEnabled + stats**
hepsini birden çekiyor. Kullanıcı Dashboard'da duruyorsa users listesine hiç bakmayabilir.

Controller'a yükleme durumu bayrakları ekle:

```dart
final _loadedPages = <int>{};

void ensurePageData(int index) {
  if (_loadedPages.contains(index)) return;
  _loadedPages.add(index);
  switch (index) {
    case 0: loadStats(); loadTeams(); break;   // dashboard
    case 1: loadTeams(); break;
    case 2: loadUsers(); break;
    case 3: loadPriorityAccounts(); break;
    case 4: loadTeams(); break;                // analytics teams'e bağlı
    case 5: loadAdsEnabled(); break;
  }
}

void selectPage(int index) {
  selectedPage.value = index;
  ensurePageData(index);
}
```

Sidebar'daki `onTap` handler'ları `ctrl.selectedPage.value = i` yerine `ctrl.selectPage(i)` çağırsın.
`verifyPin` içinde de `ensurePageData(0)` çağrılsın.

Manuel yenileme için sayfalara "Yenile" butonu ekle (`_loadedPages.remove(index)` + tekrar yükle).

---

### 3.2 `IndexedStack` ile sayfa state'ini koru

`lib/modules/admin/views/web/admin_web_shell.dart:31-40` içindeki `switch` her sayfa
geçişinde widget ağacını sıfırdan kuruyor — scroll pozisyonu, form içerikleri kayboluyor.

```dart
Expanded(
  child: Obx(() => IndexedStack(
        index: ctrl.selectedPage.value,
        children: const [
          WebDashboardPage(),
          WebTeamsPage(),
          WebUsersPage(),
          WebPriorityAccountsPage(),
          WebAnalyticsPage(),
          WebAdsSettingsPage(),
        ],
      )),
),
```

> Ödünleşim: `IndexedStack` altı sayfayı da bellekte tutar. Bu boyuttaki bir panel için
> sorun değil, karşılığında sayfa geçişleri anlık olur.

---

### 3.3 Kullanıcı listesinde sayfalama

`lib/core/services/firestore_service.dart:122` → `getUsers({int limit = 100})` tek seferde
100 kullanıcı çekiyor ve hepsi `Column` içinde render ediliyor
(`lib/modules/admin/views/web/pages/web_users_page.dart:59` — `SingleChildScrollView` + `Column`).
Kullanıcı sayısı büyüdükçe bu hem network hem render maliyeti demek.

**İki değişiklik:**

1. Firestore tarafında cursor ile sayfalama:

```dart
Future<List<Map<String, dynamic>>> getUsers({
  int limit = 25,
  DocumentSnapshot? startAfter,
}) async {
  var q = _db.collection('users').orderBy('createdAt', descending: true).limit(limit);
  if (startAfter != null) q = q.startAfterDocument(startAfter);
  final snap = await q.get();
  return snap.docs.map((doc) => {'id': doc.id, '_snap': doc, ...doc.data()}).toList();
}
```

2. Render tarafında `SingleChildScrollView` + `Column` yerine `ListView.builder`
   (sadece görünen satırları çizer) + altta "Daha fazla yükle" butonu.

Aynı düzeltme `web_teams_page.dart` ve `web_priority_accounts_page.dart` için de geçerli —
liste uzadıkça `Column` tüm elemanları birden inşa eder.

---

### 3.4 `Obx` kapsamını daralt

`admin_web_shell.dart:20` → en dıştaki `Obx`, `isDarkMode` değiştiğinde **sidebar + aktif
sayfanın tamamını** yeniden çiziyor. Tema nadiren değiştiği için kritik değil, ancak
`AdminThemeScope`'u bir `InheritedWidget` olarak dışarıda tutup yalnızca tema değişiminde
güncellemek daha temiz olur. Düşük öncelik.

---

## Build & Deploy Komutları

> **Durum: Bu belgedeki tüm maddeler uygulandı (2026-07-27).** Aşağıdaki komutlar
> artık `scripts/build_admin_web.sh` içinde otomatikleştirildi.

```bash
flutter clean && flutter pub get
```

```bash
bash scripts/build_admin_web.sh
```

```bash
firebase deploy --only hosting
```

`scripts/build_admin_web.sh` şunları yapar:
1. `flutter build web --release -t lib/main_admin.dart --tree-shake-icons --no-source-maps`
2. `hugeicons`, `iconly`, `feather_icons` paket fontlarını build çıktısından siler
   ve `FontManifest.json`'dan bu ailelerin kaydını temizler (bkz. aşağıdaki bulgu)
3. Mobil-only `assets/images` ve `assets/lottie` klasörlerini build çıktısından siler

### Önemli bulgu: paket fontları tree-shaking'den muaf

Faz 2.2'yi uygularken (tüm `HugeIcons.*` kullanımları admin panelden ve paylaşılan
`AppNetworkImage` widget'ından kaldırıldıktan sonra) build'i doğrularken şu ortaya
çıktı: **`--tree-shake-icons` yalnızca Flutter'ın kendi `MaterialIcons` ve
`CupertinoIcons` fontlarını kullanım analizine göre küçültüyor.** Üçüncü parti paket
fontları (`hugeicons`, `iconly`, `feather_icons`) `pubspec.yaml`'da bağımlılık olarak
durduğu sürece — admin kodu onları hiç import etmese bile, ayrı `main_admin.dart`
entrypoint'i kullanılsa bile — **tam boyutlarıyla** `build/web/assets/packages/`
altına kopyalanıyor. Bu, dart2js'in kod tarafındaki tree-shaking'inden tamamen
bağımsız bir davranış; Flutter'ın web asset bundler'ı font dosyalarını paketin kendi
`pubspec.yaml`'ındaki `flutter: fonts:` bildirimine göre kopyalıyor, kullanım
analizine göre değil.

Bu yüzden 2.1 (ayrı entrypoint) + 2.2 (icon değişimi) tek başına **yeterli
olmadı** — hugeicons fontu build çıktısında hâlâ ~2 MB olarak duruyordu. Çözüm,
`scripts/build_admin_web.sh` içindeki build-sonrası temizlik adımı: fiziksel font
dosyalarını sil ve `FontManifest.json`'dan ilgili kayıtları çıkar. Bu üç paket admin
panelde (ve `AppNetworkImage`'daki tek `HugeIcon` kullanımı Material `Icon`'a
çevrildikten sonra) hiçbir yerde kullanılmadığı için bu silme tamamen güvenli.

**Gerçek ölçülen sonuç** (`flutter clean` sonrası temiz build, `du -sh build/web`):

| Metrik | Öncesi | Sonrası |
|---|---|---|
| `main.dart.js` | 2.98 MB | 2.78 MB |
| `favicon.png` | 398 KB | 473 B |
| hugeicons fontu | 1.9 MB (tüm build'lerde) | **0** (admin build'inde tamamen yok) |
| iconly + feather_icons fontları | ~172 KB | **0** |
| `assets/assets` (mobil images+lottie) | 3.3 MB | **0** |
| `build/web` toplam | 45 MB | **37 MB** |

Mobil build (`flutter build apk --debug`) değişikliklerden sonra da başarıyla
derlendi — `AppNetworkImage` düzeltmesi (tek bir "resim bulunamadı" ikonu,
`HugeIcon` → `Icons.image_not_supported_outlined`) hem mobil hem web tarafında
ortak kullanıldığı için oradan da temizlendi, görsel etkisi yalnızca o tek
placeholder ikonuyla sınırlı.

---

## Doğrulama Kontrol Listesi

Deploy sonrası şunları ölç ve öncesiyle karşılaştır:

- [ ] `ls -la build/web/main.dart.js` → 2.98 MB'tan ne kadar düştü?
- [ ] `du -sh build/web` → 45 MB'tan ne kadar düştü?
- [ ] `find build/web -name "hugeicons*"` → hiçbir sonuç dönmemeli
- [ ] `ls -la build/web/favicon.png` → 398 KB değil, ~5 KB olmalı
- [ ] Chrome DevTools → Network → "Disable cache" **kapalı**, sayfayı iki kez yükle:
      ikinci yüklemede transfer edilen toplam boyut çok düşük olmalı (cache header'ları çalışıyor mu?)
- [ ] Chrome DevTools → Network → Response Headers'ta `canvaskit.wasm` için
      `Cache-Control: public, max-age=31536000, immutable` görünüyor mu?
- [ ] Lighthouse (Incognito, Mobile) → FCP ve LCP değerlerini öncesi/sonrası kaydet
- [ ] PIN girildikten sonra panel **anında** açılıyor mu? (veriler arkadan gelmeli)
- [ ] Firestore Console → Usage → aynı işlem için okuma sayısı düştü mü?
      (`config/settings` artık 4 değil 1 okuma)

---

## Özet — Etki/Efor Sıralaması

| # | İş | Efor | Beklenen Etki |
|---|---|---|---|
| 1.3 | index.html loading splash | 10 dk | Algılanan hızda en büyük sıçrama |
| 1.1 | firebase.json cache header'ları | 10 dk | Dönen ziyaretçide çok büyük |
| 1.2 | Favicon küçültme | 2 dk | −393 KB, her yüklemede |
| 2.2 | hugeicons → Material Icons | 45 dk | **−1.9 MB**, ilk ekranda |
| 1.4 | PIN sonrası bloklamayı kaldır | 15 dk | Panel anında açılır |
| 1.5 | `config/settings` tek okuma | 20 dk | 4 round-trip → 1 |
| 2.1 | Ayrı `main_admin.dart` entrypoint | 30 dk | JS bundle küçülür (ölçülmeli) |
| 1.6 | Firestore persistence (web) | 5 dk | İkinci ziyarette anlık veri |
| 3.1 | Sayfa başına lazy yükleme | 40 dk | Açılışta 5 istek → 2 |
| 2.3 | Gereksiz asset temizliği | 5 dk | Deploy boyutu −3.3 MB |
| 3.2 | IndexedStack | 15 dk | Sayfa geçişleri anlık |
| 3.3 | Kullanıcı listesi sayfalama | 60 dk | Büyük veri setinde kritik |
| 2.4 | Kullanılmayan FCM SW | 2 dk | Küçük |
| 3.4 | Obx kapsamı daraltma | 20 dk | Küçük |

**Önerilen sıra:** 1.3 → 1.2 → 1.1 → 1.4 → 1.5 → 1.6 → 2.2 → 2.1 → 2.3 → 3.1 → 3.2 → 3.3

İlk altı madde (Faz 1 + 2.2) yaklaşık 1.5 saatlik iş ve kazancın büyük kısmını verir.

---

## Notlar ve Uyarılar

- **canvaskit boyutu:** `build/web/canvaskit` klasörü 31 MB görünüyor ama bu tüm renderer
  varyantlarının (`canvaskit.wasm`, `skwasm.wasm`, `skwasm_heavy.wasm`, `wimp.wasm`) ve
  `.symbols` dosyalarının toplamı. Tarayıcı bunlardan **yalnızca birini** indirir ve
  Firebase Hosting brotli ile sıkıştırarak sunar. Yani gerçek indirme maliyeti listelenen
  boyuttan çok daha düşük — buraya efor harcamaya değmez, cache header'ı (1.1) yeterli.
- **Tahmin vs ölçüm:** Tablodaki dosya boyutları gerçek ölçümdür. `main.dart.js` için
  beklenen kazanç ise tahmindir — dart2js `kIsWeb`'i sabit katlayarak bir kısmını zaten
  elemiş olabilir. 2.1'i uygulayıp iki build'i karşılaştırmadan kesin rakam verilemez.
- **Mobil uygulamayı bozmama:** 2.1 ve 2.2'deki değişiklikler yalnızca web entrypoint'ini
  ve `lib/modules/admin/views/web/**` dosyalarını etkilemeli. `lib/main.dart` sadeleştirilirken
  `AtlasApp` ve mobil başlatma mantığı **aynen korunmalı**. Değişiklik sonrası mobil build
  mutlaka doğrulanmalı:

```bash
flutter build apk --debug
```
