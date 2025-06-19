import 'package:get/get.dart';

import '../../../features/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Put SplashController as a one-time instance since it's only needed during splash
    Get.put<SplashController>(SplashController());
  }
}