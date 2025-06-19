import 'package:get/get.dart';

import '../../../features/auth/controllers/auth_controller.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Put AuthController as lazy - it will be created when first used
    Get.lazyPut<AuthController>(() => AuthController());
  }
}