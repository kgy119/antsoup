import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/market_index_model.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();

  final isLoading = false.obs;
  final isDarkMode = false.obs;
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
    try {
      await Future.wait([
        loadPopularStocks(),
        loadAntInterestStocks(),
        loadMarketIndexes(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> loadPopularStocks() async {
    // TODO: API 연동 후 실제 데이터로 교체
    await Future.delayed(const Duration(milliseconds: 500));
    popularStocks.value = [
      StockModel(
        code: '005930',
        name: '삼성전자',
        currentPrice: 75000,
        changeAmount: 1000,
        changePercent: 1.35,
      ),
      StockModel(
        code: '000660',
        name: 'SK하이닉스',
        currentPrice: 125000,
        changeAmount: -2500,
        changePercent: -1.96,
      ),
      StockModel(
        code: '035420',
        name: 'NAVER',
        currentPrice: 185000,
        changeAmount: 3500,
        changePercent: 1.93,
      ),
    ];
  }

  Future<void> loadAntInterestStocks() async {
    // TODO: API 연동 후 실제 데이터로 교체
    await Future.delayed(const Duration(milliseconds: 500));
    antInterestStocks.value = [
      StockModel(
        code: '096770',
        name: 'SK이노베이션',
        currentPrice: 95000,
        changeAmount: -1500,
        changePercent: -1.55,
      ),
      StockModel(
        code: '068270',
        name: '셀트리온',
        currentPrice: 165000,
        changeAmount: 2000,
        changePercent: 1.23,
      ),
      StockModel(
        code: '207940',
        name: '삼성바이오로직스',
        currentPrice: 750000,
        changeAmount: -15000,
        changePercent: -1.96,
      ),
    ];
  }

  Future<void> loadMarketIndexes() async {
    // TODO: API 연동 후 실제 데이터로 교체
    await Future.delayed(const Duration(milliseconds: 300));
    marketIndexes.value = [
      MarketIndexModel(
        name: '코스피',
        value: 2645.85,
        changeAmount: 12.45,
        changePercent: 0.47,
      ),
      MarketIndexModel(
        name: '코스닥',
        value: 845.23,
        changeAmount: -5.67,
        changePercent: -0.67,
      ),
      MarketIndexModel(
        name: '원달러',
        value: 1285.50,
        changeAmount: 3.20,
        changePercent: 0.25,
      ),
    ];
  }

  void onSearchChanged(String query) {
    // TODO: 검색 기능 구현
    if (query.length >= 2) {
      // 검색 API 호출
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