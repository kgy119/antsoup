import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/local_storage_provider.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find<ThemeController>();

  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    try {
      final savedTheme = _localStorage.getThemeMode();
      isDarkMode.value = savedTheme;
      print('전역 테마 설정 로드: ${savedTheme ? "다크모드" : "라이트모드"}');
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      isDarkMode.value = false;
    }
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;

    // GetX 테마 변경
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // 로컬 저장소에 저장
    await _localStorage.saveThemeMode(isDarkMode.value);

    print('테마 변경 완료: ${isDarkMode.value ? "다크모드" : "라이트모드"}');

    // Get.snackbar(
    //   '테마 변경',
    //   '${isDarkMode.value ? "다크" : "라이트"} 모드로 변경되었습니다.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 1),
    // );
  }

  void applyInitialTheme() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentTheme = Get.isDarkMode;
      if (currentTheme != isDarkMode.value) {
        Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
        print('초기 테마 적용: ${isDarkMode.value ? "다크모드" : "라이트모드"}');
      }
    });
  }
}