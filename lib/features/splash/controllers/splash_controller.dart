import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is already logged in
    final authController = Get.find<AuthController>();
    await authController.checkLoginStatus();

    // Navigate based on login status
    if (authController.isLoggedIn.value) {
      Get.offAllNamed('/home'); // Navigate to home if logged in
    } else {
      Get.offAllNamed('/login'); // Navigate to login if not logged in
    }
  }
}