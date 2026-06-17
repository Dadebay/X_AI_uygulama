import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final storage = Get.find<GetStorage>();
  var selectedLanguage = 'tr'.obs;

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = storage.read('langCode') ?? 'tr';
  }

  void changeLanguage(String languageCode) {
    Get.updateLocale(Locale(languageCode));
    storage.write('langCode', languageCode);
    selectedLanguage.value = languageCode;
  }
}
