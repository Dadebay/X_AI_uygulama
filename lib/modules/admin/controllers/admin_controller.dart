import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  final _firestore = FirestoreService();

  final teams = <TeamModel>[].obs;
  final isLoading = false.obs;
  final isPinVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTeams();
  }

  Future<bool> verifyPin(String pin) async {
    final adminPin = await _firestore.getAdminPin();
    if (pin == adminPin) {
      isPinVerified.value = true;
      return true;
    }
    return false;
  }

  Future<void> loadTeams() async {
    isLoading.value = true;
    try {
      final result = await _firestore.getTeams();
      teams.assignAll(result);
    } catch (e) {
      Get.snackbar('Hata', 'Takımlar yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTeam(Map<String, dynamic> data) async {
    try {
      await _firestore.addTeam(data);
      await loadTeams();
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
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Takım silinemedi: $e');
      return false;
    }
  }
}
