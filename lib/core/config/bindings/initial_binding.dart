import 'package:get/get.dart';

import '../../../features/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put AuthController globally since it's needed throughout the app
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}