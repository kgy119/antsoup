import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/device_utils.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/local_storage_provider.dart';
import '../../presentation/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 순서 중요: 서비스 먼저 초기화
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);

    // 프로바이더 초기화 (서비스에 의존)
    Get.put<LocalStorageProvider>(LocalStorageProvider(), permanent: true);
    Get.put<ApiProvider>(ApiProvider(), permanent: true);

    // 테마 컨트롤러 초기화
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // 초기 설정들 비동기 처리
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      // 디바이스 ID 초기화
      await DeviceUtils.getOrCreateDeviceId();
      print('디바이스 ID 초기화 완료');

      // 테마 설정 적용
      final themeController = Get.find<ThemeController>();
      themeController.applyInitialTheme();

    } catch (e) {
      print('초기 설정 실패: $e');
    }
  }
}