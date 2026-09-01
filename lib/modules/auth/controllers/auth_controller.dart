import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:atlas/core/services/auth_service.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/core/services/analytics_service.dart';
import 'package:atlas/core/services/purchases_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _service = AuthService();
  final _firestore = FirestoreService();
  final user = Rx<User?>(null);
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final isPremium = false.obs;

  StreamSubscription<bool>? _premiumSub;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_service.authStateChanges);
    // Kullanıcı değiştikçe (login/logout) premium durumunu izleyen aboneliği
    // yeniden kur — aksi halde login öncesi kurulan abonelik hep "false" ile
    // takılı kalır (SavedController'da yaşanan sonsuz yükleme hatasının aynısı).
    ever(user, (u) {
      _listenPremium();
      AnalyticsService.setUserId(u?.uid);
      if (u != null) {
        // Önce RevenueCat kimliğini eşle, sonra aboneliğin gerçek durumunu
        // Firestore'a yansıt (süresi dolmuşsa premium burada geri alınır).
        PurchasesService.logIn(u.uid).then((_) => PurchasesService.syncWithFirestore(u.uid));
      } else {
        PurchasesService.logOut();
      }
    });
    ever(isPremium, (v) => AnalyticsService.setUserProperties(isPremium: v));
    _listenPremium();
  }

  void _listenPremium() {
    _premiumSub?.cancel();
    final id = user.value?.uid;
    if (id == null) {
      isPremium.value = false;
      return;
    }
    _premiumSub = _firestore.watchUserPremium(id).listen(
          (value) => isPremium.value = value,
          onError: (_) {},
        );
  }

  @override
  void onClose() {
    _premiumSub?.cancel();
    super.onClose();
  }

  bool get isLoggedIn => user.value != null;
  String? get uid => user.value?.uid;
  String get displayName => user.value?.displayName ?? '';
  String get email => user.value?.email ?? '';
  String get photoUrl => user.value?.photoURL ?? '';

  /// Kullanıcının giriş yaptığı sağlayıcı: "google.com", "apple.com" vb.
  /// providerData boşsa (ör. anonim) boş döner.
  String get providerId =>
      user.value?.providerData.isNotEmpty == true ? user.value!.providerData.first.providerId : '';

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      await _service.signInWithGoogle();
      AnalyticsService.logLogin('google');
      // Giriş başarılı: LoginScreen'i kapatıp kullanıcıyı geldiği ekrana döndür.
      if (Get.key.currentState?.canPop() ?? false) Get.back();
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      await _service.signInWithApple();
      AnalyticsService.logLogin('apple');
      if (Get.key.currentState?.canPop() ?? false) Get.back();
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    AnalyticsService.logLogout();
  }

  bool get isAppleAvailable => _service.isAppleAvailable;
}
