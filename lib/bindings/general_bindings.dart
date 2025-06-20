import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../features/authentication/controllers/auth_controller.dart';
import '../features/authentication/repositories/auth_repository.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    // GetStorage 초기화
    await GetStorage.init();

    // 네트워크 매니저
    Get.put(NetworkManager());

    // 인증 관련
    Get.put(AuthenticationRepository());
    Get.put(AuthenticationController());

    // 다른 컨트롤러들...
  }
}