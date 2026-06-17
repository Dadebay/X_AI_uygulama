# Pulse ⚡

**Pulse**, Türk futbol taraftarları için geliştirilmiş bir sosyal medya agregator uygulamasıdır. X (Twitter) üzerindeki Türk futboluna ait tweetleri, trendleri ve transfer haberlerini gerçek zamanlı olarak tek bir yerde sunar.

---

## Özellikler

- **Sana Özel** — Türk futboluna ait güncel tweetler, takım filtresiyle (GS, FB, BJK, Süper Lig, UCL)
- **Gündem** — Türkiye'nin anlık trend konuları ve her trende ait tweet akışı
- **Takımlar** — Galatasaray, Fenerbahçe, Beşiktaş, Trabzonspor ve Milli Takım için ayrı tweet beslemeleri
- **Transfer** — Güncel transfer haberleri
- **Keşfet** — Trend konular, popüler tweetler ve arama
- **Tweet Detay** — İçerik, medya (fotoğraf/video), istatistikler ve X'te açma
- **Kaydet** — Beğenilen tweetleri offline olarak kaydetme
- **Bildirimler** — Firebase Push Notification entegrasyonu
- **Çoklu dil** — Türkçe, İngilizce, Rusça

---

## Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| Framework | Flutter 3.x |
| State Management | GetX |
| Tweet Verisi | [Xquik API](https://xquik.com) |
| Auth & Push | Firebase Auth, Firebase Messaging |
| Veritabanı | Cloud Firestore |
| Local Storage | GetStorage |
| Görsel | CachedNetworkImage, Lottie |
| İkonlar | HugeIcons, Iconly |

---

## Kurulum

### Gereksinimler

- Flutter `>=3.6.0`
- Dart `>=3.0.0`
- Firebase projesi (iOS & Android yapılandırılmış)
- Xquik API anahtarı

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/Dadebay/X_AI_uygulama.git
cd X_AI_uygulama

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

> **Not:** `lib/core/api/xquik_service.dart` dosyasındaki API anahtarını kendi Xquik anahtarınızla değiştirin.  
> Firebase yapılandırması için `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını kendi Firebase projenizden alın.

---

## Proje Yapısı

```
lib/
├── core/
│   ├── api/            # Xquik API servisi
│   ├── lang/           # Çeviri dosyaları (TR, EN, RU)
│   └── theme/          # Tema & renkler
├── models/             # Tweet, Trend vb. modeller
├── modules/
│   ├── auth/           # Giriş / kayıt ekranları
│   ├── explore/        # Keşfet sayfası
│   ├── home/           # Ana sayfa (4 sekme)
│   ├── notifications/  # Bildirimler
│   ├── post_detail/    # Tweet detay
│   ├── profile/        # Profil
│   └── saved/          # Kaydedilen tweetler
└── widgets/            # Paylaşılan widget'lar (TweetCard vb.)
```

---

## Lisans

MIT License — © 2025 [Dadebay](https://github.com/Dadebay)
