// lib/presentation/pages/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/market_index_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final searchFocusNode = FocusNode();

  final isLoading = false.obs;
  final isDarkMode = false.obs; // 이 변수를 유지하고 동기화
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final popularStocks = <StockModel>[].obs;
  final antInterestStocks = <StockModel>[].obs;
  final marketIndexes = <MarketIndexModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 저장된 테마 설정을 즉시 로드
    _initializeThemeSettings();

    // 빌드 완료 후에 테마 적용
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

  // 검색창 포커스 해제 메서드 추가
  void unfocusSearch() {
    searchFocusNode.unfocus();
  }

  // 저장된 테마 설정 즉시 로드 (UI 반영용)
  void _initializeThemeSettings() {
    try {
      final savedThemeMode = _localStorage.getThemeMode();
      isDarkMode.value = savedThemeMode;
      print('HomeController 테마 설정 로드: ${savedThemeMode ? "다크모드" : "라이트모드"}');
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      isDarkMode.value = false; // 기본값으로 설정
    }
  }

  // 저장된 테마 설정을 GetX에 적용
  void _applyThemeSettings() {
    try {
      // 현재 테마와 다른 경우에만 변경
      final currentThemeMode = Get.isDarkMode;
      if (currentThemeMode != isDarkMode.value) {
        Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
        print('테마 적용 완료: ${isDarkMode.value ? "다크모드" : "라이트모드"}');
      }
    } catch (e) {
      print('테마 적용 실패: $e');
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      await Future.wait([
        loadPopularStocks(),
        loadAntInterestStocks(),
        loadMarketIndexes(),
      ]);
    } catch (e) {
      print('데이터 로딩 오류: $e');
      hasError.value = true;
      errorMessage.value = '데이터를 불러오는 중 오류가 발생했습니다.';

      Get.snackbar(
        '오류',
        '데이터를 불러오는 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    hasError.value = false;
    errorMessage.value = '';
    await loadInitialData();
  }

  Future<void> loadPopularStocks() async {
    try {
      final stocks = await _apiProvider.getPopularStocks();
      popularStocks.value = stocks;
    } catch (e) {
      print('인기 종목 로딩 실패: $e');
      popularStocks.value = [];
    }
  }

  Future<void> loadAntInterestStocks() async {
    try {
      final stocks = await _apiProvider.getAntInterestStocks();
      antInterestStocks.value = stocks;
    } catch (e) {
      print('개미 관심 종목 로딩 실패: $e');
      antInterestStocks.value = [];
    }
  }

  Future<void> loadMarketIndexes() async {
    try {
      final indexes = await _apiProvider.getMarketIndexes();
      marketIndexes.value = indexes;
    } catch (e) {
      print('시장 지수 로딩 실패: $e');
      marketIndexes.value = [];
    }
  }

  void onSearchChanged(String query) {
    if (query.length >= 2) {
      searchStocks(query);
    }
  }

  Future<void> searchStocks(String keyword) async {
    try {
      final results = await _apiProvider.searchStocks(keyword);
      print('검색 결과: ${results.length}개');
    } catch (e) {
      print('검색 실패: $e');
    }
  }

  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock/detail', arguments: {'stockCode': stockCode});
  }

  void goToNotifications() {
    Get.toNamed('/notification');
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;

    // 테마 변경 적용
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // 로컬 저장소에 테마 설정 저장
    await _localStorage.saveThemeMode(isDarkMode.value);

    print('테마 설정 저장 완료: ${isDarkMode.value ? "다크모드" : "라이트모드"}');

    // Get.snackbar(
    //   '테마 변경',
    //   '${isDarkMode.value ? "다크" : "라이트"} 모드로 변경되었습니다.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 1),
    // );
  }
}