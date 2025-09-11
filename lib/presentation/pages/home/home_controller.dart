import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../controllers/main_navigation_controller.dart';
import '../stock/stock_controller.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final searchFocusNode = FocusNode();

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // 새로운 리스트들
  final hotAntSoupStocks = <StockModel>[].obs;     // 펄펄끓는 개미탕
  final coldAntSoupStocks = <StockModel>[].obs;    // 식어가는 개미탕
  final mixedAntSoupStocks = <StockModel>[].obs;   // 냉탕온탕 개미탕

  @override
  void onInit() {
    super.onInit();
    _initializeThemeSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyThemeSettings();
    });

    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }

  void _initializeThemeSettings() {
    try {
      final savedThemeMode = _localStorage.getThemeMode();
      isDarkMode.value = savedThemeMode;
      print('HomeController 테마 설정 로드: ${savedThemeMode ? "다크모드" : "라이트모드"}');
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      isDarkMode.value = false;
    }
  }

  void _applyThemeSettings() {
    try {
      final currentThemeMode = Get.isDarkMode;
      if (currentThemeMode != isDarkMode.value) {
        Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
        print('테마 적용 완료: ${isDarkMode.value ? "다크모드" : "라이트모드"}');
      }
    } catch (e) {
      print('테마 적용 실패: $e');
    }
  }

  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await Future.wait([
        loadHotAntSoupStocks(),
        loadColdAntSoupStocks(),
        loadMixedAntSoupStocks(),
      ]);
    } catch (e) {
      print('초기 데이터 로딩 실패: $e');
      hasError.value = true;
      errorMessage.value = '데이터를 불러오는데 실패했습니다.';
    } finally {
      isLoading.value = false;
    }
  }

  // 펄펄끓는 개미탕 로드
  Future<void> loadHotAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getHotAntSoupStocks();
      hotAntSoupStocks.value = stocks;

      if (stocks.isEmpty) {
        print('펄펄끓는 개미탕 데이터가 없습니다.');
      }
    } catch (e) {
      print('펄펄끓는 개미탕 로딩 실패: $e');
      hotAntSoupStocks.value = [];
    }
  }

  // 식어가는 개미탕 로드
  Future<void> loadColdAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getColdAntSoupStocks();
      coldAntSoupStocks.value = stocks;

      if (stocks.isEmpty) {
        print('식어가는 개미탕 데이터가 없습니다.');
      }
    } catch (e) {
      print('식어가는 개미탕 로딩 실패: $e');
      coldAntSoupStocks.value = [];
    }
  }

  // 냉탕온탕 개미탕 로드
  Future<void> loadMixedAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getMixedAntSoupStocks();
      mixedAntSoupStocks.value = stocks;

      if (stocks.isEmpty) {
        print('냉탕온탕 개미탕 데이터가 없습니다.');
      }
    } catch (e) {
      print('냉탕온탕 개미탕 로딩 실패: $e');
      mixedAntSoupStocks.value = [];
    }
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // 검색 기능 - 매개변수 없는 버전으로 변경
  void onSearchSubmitted() {
    final value = searchController.text.trim();
    if (value.isEmpty) return;

    // 검색어로 종목 페이지로 이동
    final navController = Get.find<MainNavigationController>();
    navController.changePage(1); // 종목 탭으로 이동

    if (Get.isRegistered<StockController>()) {
      final stockController = Get.find<StockController>();
      stockController.searchController.text = value;
      stockController.searchStocks(value); // onSearchSubmitted 대신 searchStocks 직접 호출
    }
  }

  // 종목 상세 페이지로 이동
  void goToStockDetail(String code) {
    Get.toNamed('/stock-detail', arguments: {'code': code});
  }

  // 알림 페이지로 이동
  void goToNotifications() {
    Get.toNamed('/notifications');
  }

  // 테마 모드 토글
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _localStorage.saveThemeMode(isDarkMode.value);
  }
}