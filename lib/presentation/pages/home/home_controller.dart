import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/market_index_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final _apiProvider = Get.find<ApiProvider>();
  final _localStorage = Get.find<LocalStorageProvider>();

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final popularStocks = <StockModel>[].obs;
  final antInterestStocks = <StockModel>[].obs;
  final marketIndexes = <MarketIndexModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    // 다크모드 상태 초기화
    isDarkMode.value = _localStorage.getThemeMode();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        loadPopularStocks(),
        loadAntInterestStocks(),
        loadMarketIndexes(),
      ]);
    } catch (e) {
      errorMessage.value = '데이터를 불러오는 중 오류가 발생했습니다: $e';
      print('데이터 로딩 오류: $e');
      // 오류 발생 시 더미 데이터로 폴백
      _loadDummyData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadInitialData();
    Get.snackbar(
      '새로고침 완료',
      '최신 데이터를 불러왔습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> loadPopularStocks() async {
    try {
      final stocks = await _apiProvider.getPopularStocks();
      popularStocks.value = stocks;
    } catch (e) {
      print('인기 종목 로딩 실패: $e');
      // API 실패 시 더미 데이터 사용
      popularStocks.value = _getDummyPopularStocks();
      rethrow;
    }
  }

  Future<void> loadAntInterestStocks() async {
    try {
      final stocks = await _apiProvider.getAntInterestStocks();
      antInterestStocks.value = stocks;
    } catch (e) {
      print('개미 관심 종목 로딩 실패: $e');
      // API 실패 시 더미 데이터 사용
      antInterestStocks.value = _getDummyAntInterestStocks();
      rethrow;
    }
  }

  Future<void> loadMarketIndexes() async {
    try {
      final indexes = await _apiProvider.getMarketIndexes();
      marketIndexes.value = indexes;
    } catch (e) {
      print('시장 지수 로딩 실패: $e');
      // API 실패 시 더미 데이터 사용
      marketIndexes.value = _getDummyMarketIndexes();
      rethrow;
    }
  }

  // 더미 데이터 생성 메서드들 (API 연동 전까지 사용)
  void _loadDummyData() {
    popularStocks.value = _getDummyPopularStocks();
    antInterestStocks.value = _getDummyAntInterestStocks();
    marketIndexes.value = _getDummyMarketIndexes();
  }

  List<StockModel> _getDummyPopularStocks() {
    return [
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

  List<StockModel> _getDummyAntInterestStocks() {
    return [
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

  List<MarketIndexModel> _getDummyMarketIndexes() {
    return [
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
    // 최근 검색어에 추가
    if (query.length >= 2) {
      _localStorage.addRecentSearch(query);
      // TODO: 실제 검색 API 호출
      // searchStocks(query);
    }
  }

  Future<void> searchStocks(String keyword) async {
    try {
      // TODO: API Provider에 검색 메서드 추가 후 구현
      // final results = await _apiProvider.searchStocks(keyword);
      // 검색 결과 처리
    } catch (e) {
      Get.snackbar(
        '검색 오류',
        '검색 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.TOP,
      );
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
    _localStorage.saveThemeMode(isDarkMode.value);
  }
}