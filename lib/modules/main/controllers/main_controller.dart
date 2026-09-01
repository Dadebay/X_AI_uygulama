import 'package:get/get.dart';
import 'package:atlas/core/services/analytics_service.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  static const _tabNames = ['home', 'explore', 'saved', 'profile'];

  @override
  void onReady() {
    super.onReady();
    AnalyticsService.logScreenView(_tabNames[currentIndex.value]);
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    if (index >= 0 && index < _tabNames.length) {
      AnalyticsService.logScreenView(_tabNames[index]);
    }
  }
}
