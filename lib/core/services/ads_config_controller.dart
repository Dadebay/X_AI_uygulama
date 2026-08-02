import 'package:get/get.dart';
import 'package:atlas/core/services/ad_service.dart';
import 'package:atlas/core/services/firestore_service.dart';

/// Watches the global "ads enabled" flag from Firestore in real time so ads
/// can be turned off app-wide from the admin panel without an app restart.
class AdsConfigController extends GetxController {
  final _firestore = FirestoreService();
  final adsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _firestore.watchAdsEnabled().listen((value) {
      AdService.log('Firestore adsEnabled = $value');
      adsEnabled.value = value;
    });
  }
}
