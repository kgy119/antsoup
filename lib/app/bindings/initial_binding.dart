import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/device_utils.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/local_storage_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 서비스 의존성 주입
    Get.putAsync<ApiService>(() async => ApiService(), permanent: true);
    Get.putAsync<NotificationService>(() async => NotificationService(), permanent: true);

    // 프로바이더 의존성 주입
    Get.putAsync<LocalStorageProvider>(() async => LocalStorageProvider(), permanent: true);
    Get.putAsync<ApiProvider>(() async => ApiProvider(), permanent: true);

    // 디바이스 ID 초기화 (회원가입 없는 서비스를 위한 익명 식별자)
    _initializeDeviceId();
  }

  Future<void> _initializeDeviceId() async {
    try {
      await DeviceUtils.getOrCreateDeviceId();
      print('디바이스 ID 초기화 완료');
    } catch (e) {
      print('디바이스 ID 초기화 실패: $e');
    }
  }
}