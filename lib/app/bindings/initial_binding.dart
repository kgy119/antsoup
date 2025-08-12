import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/device_utils.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/local_storage_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 순서 중요: 서비스 먼저 초기화
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);

    // 프로바이더 초기화 (서비스에 의존)
    Get.put<LocalStorageProvider>(LocalStorageProvider(), permanent: true);
    Get.put<ApiProvider>(ApiProvider(), permanent: true);

    // 디바이스 ID 초기화
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