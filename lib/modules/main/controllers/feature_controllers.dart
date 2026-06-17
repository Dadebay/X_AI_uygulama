import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  var userName = "Kullanıcı".obs;

  // Language state
  var currentLanguage = 'tr'.obs;

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<GetStorage>();
    currentLanguage.value = storage.read('langCode') ?? 'tr';
  }

  void changeLanguage(String langCode) {
    Get.updateLocale(Locale(langCode));
    currentLanguage.value = langCode;
    Get.find<GetStorage>().write('langCode', langCode);
  }
}
