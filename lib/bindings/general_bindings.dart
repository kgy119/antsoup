import 'package:get/get.dart';

import '../features/authentication/services/auth_storage_service.dart';
import '../features/authentication/services/firestore_user_service.dart';
import '../features/authentication/services/google_auth_service.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {

  @override
  void dependencies() {
    // 네트워크 매니저
    Get.put(NetworkManager());

    // Firestore 사용자 서비스 (가장 먼저 초기화)
    Get.put(FirestoreUserService());

    // 인증 저장소 서비스
    Get.put(AuthStorageService());

    // Google 인증 서비스
    Get.put(GoogleAuthService());
  }
}