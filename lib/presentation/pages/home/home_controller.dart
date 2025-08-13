// lib/presentation/pages/home/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/market_index_model.dart';
import '../../../data/providers/api_provider.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final popularStocks = <StockModel>[].obs;
  final antInterestStocks = <StockModel>[].obs;
  final marketIndexes = <MarketIndexModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    // 다크모드 상태 초기화
    isDarkMode.value = Get.isDarkMode;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
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
      // 실패시 빈 리스트 유지하고 에러 표시하지 않음
      popularStocks.value = [];
    }
  }

  Future<void> loadAntInterestStocks() async {
    try {
      final stocks = await _apiProvider.getAntInterestStocks();
      antInterestStocks.value = stocks;
    } catch (e) {
      print('개미 관심 종목 로딩 실패: $e');
      // 실패시 빈 리스트 유지하고 에러 표시하지 않음
      antInterestStocks.value = [];
    }
  }

  Future<void> loadMarketIndexes() async {
    try {
      final indexes = await _apiProvider.getMarketIndexes();
      marketIndexes.value = indexes;
    } catch (e) {
      print('시장 지수 로딩 실패: $e');
      // 실패시 빈 리스트 유지하고 에러 표시하지 않음
      marketIndexes.value = [];
    }
  }

  void onSearchChanged(String query) {
    // TODO: 검색 기능 구현
    if (query.length >= 2) {
      // 검색 API 호출
      searchStocks(query);
    }
  }

  Future<void> searchStocks(String keyword) async {
    try {
      final results = await _apiProvider.searchStocks(keyword);
      // TODO: 검색 결과 처리
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

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    // TODO: 테마 설정을 로컬 저장소에 저장
  }
}