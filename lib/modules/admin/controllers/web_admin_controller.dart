import 'dart:async';

import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class WebAdminController extends GetxController {
  final _firestore = FirestoreService();

  final isPinVerified = false.obs;
  final isLoadingStats = false.obs;
  final isLoadingTeams = false.obs;
  final isLoadingUsers = false.obs;
  final isLoadingMoreUsers = false.obs;
  final isLoadingPriorityAccounts = false.obs;

  final selectedPage = 0.obs;
  final isDarkMode = true.obs;

  final usersCount = 0.obs;
  final teamsCount = 0.obs;
  final teams = <TeamModel>[].obs;
  final users = <Map<String, dynamic>>[].obs;
  DocumentSnapshot? _usersCursor;
  final hasMoreUsers = true.obs;

  // Ana sayfada tüm günlük tweetleri filtresiz gösterilecek öncelikli hesaplar
  final priorityAccounts = <String>[].obs;

  // Xquik `/x/tweets/search` API'sinin gerçek etkileşim filtresi parametreleri
  final minFaves = 500.obs;
  final minRetweets = 0.obs;
  final minReplies = 0.obs;
  final minQuotes = 0.obs;
  final minViews = 0.obs;

  // Uygulama genelinde reklamların açık/kapalı olduğu bayrak
  final adsEnabled = true.obs;
  final isLoadingAdsEnabled = false.obs;

  // Premium abonelik fiyatlandırması (prices/premium) — uygulamadaki
  // PremiumScreen bu değerleri canlı okur.
  final premiumMonthlyPrice = 49.99.obs;
  final premiumYearlyPrice = 399.99.obs;
  final premiumYearlyDiscountLabel = '%33 indirim!'.obs;
  final premiumCurrency = '₺'.obs;
  final isLoadingPremiumPricing = false.obs;

  // Panel açıldıktan sonra sayfa başına tek seferlik veri yüklemesi yapmak için
  final _loadedPages = <int>{};

  StreamSubscription<PremiumPricing>? _premiumPricingSub;

  @override
  void onClose() {
    _premiumPricingSub?.cancel();
    super.onClose();
  }

  int get totalTwitterAccounts => teams.fold(0, (sum, t) => sum + t.twitterAccounts.length);

  Future<bool> verifyPin(String pin) async {
    final settings = await _firestore.getSettings();
    final adminPin = settings['adminPin']?.toString() ?? '2024';
    if (pin != adminPin) return false;

    isPinVerified.value = true;

    // Ayarlar zaten elimizde, tekrar okumaya gerek yok
    _applySettings(settings);

    // Panel hemen açılsın; kalan veriler arka planda ve sadece görüntülenen
    // sayfa için yüklenir (bkz. ensurePageData)
    unawaited(loadStats());
    ensurePageData(selectedPage.value);
    return true;
  }

  void _applySettings(Map<String, dynamic> settings) {
    final rawAccounts = (settings['priorityAccounts'] as List<dynamic>?) ?? [];
    priorityAccounts.assignAll(rawAccounts.map((a) => a.toString()));
    minFaves.value = (settings['minFaves'] as num?)?.toInt() ?? 500;
    minRetweets.value = (settings['minRetweets'] as num?)?.toInt() ?? 0;
    minReplies.value = (settings['minReplies'] as num?)?.toInt() ?? 0;
    minQuotes.value = (settings['minQuotes'] as num?)?.toInt() ?? 0;
    minViews.value = (settings['minViews'] as num?)?.toInt() ?? 0;
    adsEnabled.value = settings['adsEnabled'] as bool? ?? true;
  }

  /// Seçilen sayfayı işaretler ve o sayfanın verisi daha önce yüklenmediyse yükler.
  void selectPage(int index) {
    selectedPage.value = index;
    ensurePageData(index);
  }

  void ensurePageData(int index) {
    if (_loadedPages.contains(index)) return;
    _loadedPages.add(index);
    switch (index) {
      case 0:
        loadTeams();
        break;
      case 1:
        loadTeams();
        break;
      case 2:
        loadUsers();
        break;
      case 3:
        // Ayarlar verifyPin sırasında zaten yüklendi; burada tekrar çekmeye gerek yok
        break;
      case 4:
        loadTeams();
        break;
      case 5:
        // Ayarlar verifyPin sırasında zaten yüklendi
        break;
      case 6:
        _listenPremiumPricing();
        break;
    }
  }

  /// Bir sayfayı yeniden yüklemeye zorlar (ör. "Yenile" butonu).
  void refreshPage(int index) {
    _loadedPages.remove(index);
    ensurePageData(index);
  }

  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadTeams(), loadUsers(), loadPriorityAccounts(), loadAdsEnabled()]);
  }

  Future<void> loadStats() async {
    isLoadingStats.value = true;
    try {
      final results = await Future.wait([
        _firestore.getUsersCount(),
        _firestore.getTeamsCount(),
      ]);
      usersCount.value = results[0];
      teamsCount.value = results[1];
    } catch (_) {} finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadTeams() async {
    isLoadingTeams.value = true;
    try {
      final result = await _firestore.getTeams();
      teams.assignAll(result);
    } catch (_) {} finally {
      isLoadingTeams.value = false;
    }
  }

  Future<void> loadUsers() async {
    isLoadingUsers.value = true;
    try {
      final page = await _firestore.getUsersPage();
      users.assignAll(page.users);
      _usersCursor = page.lastDoc;
      hasMoreUsers.value = page.hasMore;
    } catch (_) {} finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> loadMoreUsers() async {
    if (isLoadingMoreUsers.value || !hasMoreUsers.value || _usersCursor == null) return;
    isLoadingMoreUsers.value = true;
    try {
      final page = await _firestore.getUsersPage(startAfter: _usersCursor);
      users.addAll(page.users);
      _usersCursor = page.lastDoc;
      hasMoreUsers.value = page.hasMore;
    } catch (_) {} finally {
      isLoadingMoreUsers.value = false;
    }
  }

  Future<bool> addTeam(Map<String, dynamic> data) async {
    try {
      await _firestore.addTeam(data);
      await loadTeams();
      await loadStats();
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Takım eklenemedi: $e');
      return false;
    }
  }

  Future<bool> updateTeam(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.updateTeam(id, data);
      await loadTeams();
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Takım güncellenemedi: $e');
      return false;
    }
  }

  Future<bool> deleteTeam(String id) async {
    try {
      await _firestore.deleteTeam(id);
      await loadTeams();
      await loadStats();
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Takım silinemedi: $e');
      return false;
    }
  }

  Future<void> loadPriorityAccounts() async {
    isLoadingPriorityAccounts.value = true;
    try {
      final results = await Future.wait([
        _firestore.getPriorityAccounts(),
        _firestore.getEngagementThresholds(),
      ]);
      priorityAccounts.assignAll(results[0] as List<String>);
      final t = results[1] as EngagementThresholds;
      minFaves.value = t.minFaves;
      minRetweets.value = t.minRetweets;
      minReplies.value = t.minReplies;
      minQuotes.value = t.minQuotes;
      minViews.value = t.minViews;
    } catch (_) {} finally {
      isLoadingPriorityAccounts.value = false;
    }
  }

  Future<bool> addPriorityAccount(String handle) async {
    final h = handle.trim().replaceAll('@', '');
    if (h.isEmpty) return false;
    if (priorityAccounts.contains(h)) {
      Get.snackbar('Zaten eklendi', '@$h zaten listede');
      return false;
    }
    try {
      final updated = [...priorityAccounts, h];
      await _firestore.setPriorityAccounts(updated);
      priorityAccounts.assignAll(updated);
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Hesap eklenemedi: $e');
      return false;
    }
  }

  Future<void> removePriorityAccount(String handle) async {
    try {
      final updated = priorityAccounts.where((a) => a != handle).toList();
      await _firestore.setPriorityAccounts(updated);
      priorityAccounts.assignAll(updated);
    } catch (e) {
      Get.snackbar('Hata', 'Hesap silinemedi: $e');
    }
  }

  Future<bool> updateEngagementThresholds({
    required int minFaves,
    required int minRetweets,
    required int minReplies,
    required int minQuotes,
    required int minViews,
  }) async {
    try {
      final thresholds = EngagementThresholds(
        minFaves: minFaves,
        minRetweets: minRetweets,
        minReplies: minReplies,
        minQuotes: minQuotes,
        minViews: minViews,
      );
      await _firestore.setEngagementThresholds(thresholds);
      this.minFaves.value = minFaves;
      this.minRetweets.value = minRetweets;
      this.minReplies.value = minReplies;
      this.minQuotes.value = minQuotes;
      this.minViews.value = minViews;
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Eşikler güncellenemedi: $e');
      return false;
    }
  }

  Future<void> loadAdsEnabled() async {
    isLoadingAdsEnabled.value = true;
    try {
      adsEnabled.value = await _firestore.getAdsEnabled();
    } catch (_) {} finally {
      isLoadingAdsEnabled.value = false;
    }
  }

  Future<bool> setAdsEnabled(bool value) async {
    try {
      await _firestore.setAdsEnabled(value);
      adsEnabled.value = value;
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Reklam ayarı güncellenemedi: $e');
      return false;
    }
  }

  /// Firestore'daki `prices/premium` dokümanını canlı dinler — panel üstünde
  /// başka bir sekme/oturum fiyatı değiştirse bile, yenile tuşuna basmaya
  /// gerek kalmadan formda anında güncel değer görünür.
  void _listenPremiumPricing() {
    if (_premiumPricingSub != null) return;
    isLoadingPremiumPricing.value = true;
    _premiumPricingSub = _firestore.watchPremiumPricing().listen((p) {
      premiumMonthlyPrice.value = p.monthlyPrice;
      premiumYearlyPrice.value = p.yearlyPrice;
      premiumYearlyDiscountLabel.value = p.yearlyDiscountLabel;
      premiumCurrency.value = p.currency;
      isLoadingPremiumPricing.value = false;
    });
  }

  Future<bool> updatePremiumPricing({
    required double monthlyPrice,
    required double yearlyPrice,
    required String yearlyDiscountLabel,
    required String currency,
  }) async {
    try {
      final pricing = PremiumPricing(
        monthlyPrice: monthlyPrice,
        yearlyPrice: yearlyPrice,
        yearlyDiscountLabel: yearlyDiscountLabel,
        currency: currency,
      );
      await _firestore.setPremiumPricing(pricing);
      premiumMonthlyPrice.value = monthlyPrice;
      premiumYearlyPrice.value = yearlyPrice;
      premiumYearlyDiscountLabel.value = yearlyDiscountLabel;
      premiumCurrency.value = currency;
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Fiyatlar güncellenemedi: $e');
      return false;
    }
  }

  /// Admin panelden bir kullanıcıya bedava premium verir/kaldırır — gerçek
  /// bir ödeme olmadan doğrudan Firestore'daki isPremium bayrağını değiştirir.
  Future<bool> setUserPremiumStatus(String uid, bool isPremium) async {
    try {
      await _firestore.setUserPremium(uid, isPremium);
      final index = users.indexWhere((u) => u['id'] == uid);
      if (index != -1) {
        users[index] = {...users[index], 'isPremium': isPremium};
        users.refresh();
      }
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Kullanıcı premium durumu güncellenemedi: $e');
      return false;
    }
  }
}
