import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/explore/controllers/explore_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    GetStorage.init();
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<ExploreController>(() => ExploreController());
  }
}
