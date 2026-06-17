import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:atlas/core/services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _service = AuthService();
  final user = Rx<User?>(null);
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_service.authStateChanges);
  }

  bool get isLoggedIn => user.value != null;
  String? get uid => user.value?.uid;
  String get displayName => user.value?.displayName ?? '';
  String get email => user.value?.email ?? '';
  String get photoUrl => user.value?.photoURL ?? '';

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      await _service.signInWithGoogle();
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
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  bool get isAppleAvailable => _service.isAppleAvailable;
}
