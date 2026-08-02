import 'package:atlas/models/tweet_model.dart';

/// X'in Türkiye trend listesi genel gündemi (siyaset, magazin, hava durumu…)
/// döndürüyor. Uygulama futbol odaklı olduğu için trendleri burada süzüyoruz.

// Trend adında geçtiğinde konuyu futbol sayan anahtar kelimeler.
const List<String> _footballKeywords = [
  // Süper Lig kulüpleri ve yaygın kısaltmaları
  'galatasaray', 'gsray', 'cimbom', 'aslan',
  'fenerbahce', 'fener', 'fbahce', 'kanarya',
  'besiktas', 'bjk', 'kartal',
  'trabzonspor', 'trabzon', 'bordomavi',
  'basaksehir', 'samsunspor', 'konyaspor', 'sivasspor', 'antalyaspor',
  'alanyaspor', 'kayserispor', 'gaziantep', 'rizespor', 'goztepe',
  'kasimpasa', 'eyupspor', 'bodrumspor', 'hatayspor', 'adanaspor',
  'ankaragucu', 'genclerbirligi', 'karagumruk', 'pendikspor', 'umraniyespor',
  'bandirmaspor', 'sakaryaspor', 'erzurumspor', 'boluspor', 'manisaspor',
  'altay', 'denizlispor', 'malatyaspor', 'giresunspor', 'kocaelispor',
  'amedspor', 'esenlerspor', 'sariyer', 'vanspor',
  // Ligler ve turnuvalar
  'superlig', 'super lig', 'trendyolsuperlig', 'trendyol1lig', 'ptt1lig',
  'ziraatturkiyekupasi', 'turkiyekupasi', 'sampiyonluk', 'sampiyonlar',
  'sampiyonlarligi', 'championsleague', 'ucl', 'uel', 'europaleague',
  'konferansligi', 'conferenceleague', 'uefa', 'fifa', 'tff', 'millimac',
  'amilli', 'amillitakim', 'millitakim', 'eleme', 'euro2028', 'dunyakupasi',
  'laliga', 'premierleague', 'seriea', 'bundesliga', 'derbi', 'derby',
  // Futbol terimleri — kısa/genel kelimeler (var, mac, lig, gol…) bilerek
  // listede yok; "Alvarez", "Macron" gibi alakasız trendlere takılıyorlardı.
  'futbol', 'football', 'soccer', 'transfer', 'bonservis', 'sezonu',
  'teknikdirektor', 'kadrosu', 'ilk11', 'ilkonbir', 'penalti', 'ofsayt',
  'hakem', 'kirmizikart', 'sarikart', 'golu', 'asist', 'hattrick',
  'macisonucu', 'macinda', 'maclari', 'stadyum', 'tribun', 'taraftar',
  'formasi', 'kupasi', 'ligi', 'devrearasi', 'sakatlik', 'kampi',
  'sampiyon', 'puandurumu', 'fikstur', 'teknikheyet',
];

/// Türkçe karakterleri sadeleştirip küçük harfe indirger — "Fenerbahçe" ile
/// "fenerbahce" aynı şekilde eşleşsin diye.
String normalizeTrendName(String value) {
  const map = {
    'ç': 'c', 'ğ': 'g', 'ı': 'i', 'İ': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
    'Ç': 'c', 'Ğ': 'g', 'I': 'i', 'Ö': 'o', 'Ş': 's', 'Ü': 'u',
  };
  var result = value;
  map.forEach((from, to) => result = result.replaceAll(from, to));
  return result.toLowerCase();
}

/// Trend başlığı futbolla ilgili mi?
bool isFootballTrend(String name) {
  final normalized = normalizeTrendName(name).replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (normalized.isEmpty) return false;
  return _footballKeywords.any((k) => normalized.contains(k.replaceAll(' ', '')));
}

/// Trend listesini futbolla ilgili olanlarla sınırlar ve sıralamayı 1'den
/// başlatarak yeniden numaralandırır.
List<TrendTopic> filterFootballTrends(List<TrendTopic> trends) {
  final filtered = trends.where((t) => isFootballTrend(t.name)).toList();
  return [
    for (var i = 0; i < filtered.length; i++)
      TrendTopic(rank: i + 1, name: filtered[i].name, postCount: filtered[i].postCount),
  ];
}
