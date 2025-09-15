import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../controllers/main_navigation_controller.dart';
import '../stock/stock_controller.dart';
import '../../../core/services/naver_stock_service.dart';
import 'dart:async';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final searchFocusNode = FocusNode();

  final isLoading = false.obs;
  final isDarkMode = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // 기존 리스트들
  final hotAntSoupStocks = <StockModel>[].obs;     // 펄펄끓는 개미탕
  final coldAntSoupStocks = <StockModel>[].obs;    // 식어가는 개미탕
  final mixedAntSoupStocks = <StockModel>[].obs;   // 냉탕온탕 개미탕

  // 네이버 실시간 데이터 관련
  final naverStockCache = <String, NaverStockPrice>{}.obs;
  final naverCacheTime = <String, DateTime>{}.obs;
  final isNaverDataLoading = false.obs;
  Timer? _realTimeUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeThemeSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyThemeSettings();
    });

    // 컨트롤러 초기화 시 로딩 상태를 true로 설정
    isLoading.value = true;
    loadInitialData();

    // 실시간 데이터 자동 갱신 시작
    _startRealTimeUpdate();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _realTimeUpdateTimer?.cancel();
    super.onClose();
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }

  void _initializeThemeSettings() {
    try {
      final savedThemeMode = _localStorage.getThemeMode();
      isDarkMode.value = savedThemeMode;
      update(['themeMode']);
      print('HomeController 테마 설정 로드: ${savedThemeMode ? "다크모드" : "라이트모드"}');
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      isDarkMode.value = false;
      update(['themeMode']);
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
    update(['loading', 'error']);

    try {
      // 서버 데이터 먼저 로드
      await Future.wait([
        loadHotAntSoupStocks(),
        loadColdAntSoupStocks(),
        loadMixedAntSoupStocks(),
      ]);

      // 네이버 실시간 데이터 로드
      await _loadNaverDataForAllStocks();

      hasError.value = false;
      update(['error']);
    } catch (e) {
      print('초기 데이터 로딩 실패: $e');
      hasError.value = true;
      errorMessage.value = '데이터를 불러오는데 실패했습니다.';
      update(['error']);
    } finally {
      isLoading.value = false;
      update(['loading']);
    }
  }

  // 펄펄끓는 개미탕 로드
  Future<void> loadHotAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getHotAntSoupStocks();
      hotAntSoupStocks.value = stocks;
      update(['hotAntSoupStocks']);

      if (stocks.isEmpty) {
        print('펄펄끓는 개미탕 데이터가 없습니다.');
      } else {
        print('펄펄끓는 개미탕 데이터 로드 완료: ${stocks.length}개');
      }
    } catch (e) {
      print('펄펄끓는 개미탕 로딩 실패: $e');
      hotAntSoupStocks.value = [];
      update(['hotAntSoupStocks']);
    }
  }

  // 식어가는 개미탕 로드
  Future<void> loadColdAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getColdAntSoupStocks();
      coldAntSoupStocks.value = stocks;
      update(['coldAntSoupStocks']);

      if (stocks.isEmpty) {
        print('식어가는 개미탕 데이터가 없습니다.');
      } else {
        print('식어가는 개미탕 데이터 로드 완료: ${stocks.length}개');
      }
    } catch (e) {
      print('식어가는 개미탕 로딩 실패: $e');
      coldAntSoupStocks.value = [];
      update(['coldAntSoupStocks']);
    }
  }

  // 냉탕온탕 개미탕 로드
  Future<void> loadMixedAntSoupStocks() async {
    try {
      final stocks = await _apiProvider.getMixedAntSoupStocks();
      mixedAntSoupStocks.value = stocks;
      update(['mixedAntSoupStocks']);

      if (stocks.isEmpty) {
        print('냉탕온탕 개미탕 데이터가 없습니다.');
      } else {
        print('냉탕온탕 개미탕 데이터 로드 완료: ${stocks.length}개');
      }
    } catch (e) {
      print('냉탕온탕 개미탕 로딩 실패: $e');
      mixedAntSoupStocks.value = [];
      update(['mixedAntSoupStocks']);
    }
  }

  // 모든 종목의 네이버 실시간 데이터 로드
  Future<void> _loadNaverDataForAllStocks() async {
    final allStocks = [
      ...hotAntSoupStocks,
      ...coldAntSoupStocks,
      ...mixedAntSoupStocks,
    ];

    if (allStocks.isEmpty) return;

    isNaverDataLoading.value = true;
    update(['naverLoading']);

    try {
      // 종목 코드 추출
      final stockCodes = allStocks.map((stock) => stock.code).toSet().toList();

      // 캐시된 데이터 확인
      final needUpdateCodes = <String>[];
      for (final code in stockCodes) {
        if (!_isNaverDataCached(code)) {
          needUpdateCodes.add(code);
        }
      }

      if (needUpdateCodes.isNotEmpty) {
        print('네이버 실시간 데이터 조회 시작: ${needUpdateCodes.length}개 종목');

        // 네이버에서 실시간 데이터 조회
        final naverData = await NaverStockService.getMultipleStockPrices(needUpdateCodes);

        // 캐시 업데이트
        naverData.forEach((code, price) {
          naverStockCache[code] = price;
          naverCacheTime[code] = DateTime.now();
        });

        print('네이버 실시간 데이터 조회 완료: ${naverData.length}개 성공');
      }

      // 기존 StockModel 리스트를 네이버 데이터로 업데이트
      _updateAllStockModelsWithNaverData();

    } catch (e) {
      print('네이버 실시간 데이터 로드 실패: $e');
    } finally {
      isNaverDataLoading.value = false;
      update(['naverLoading']);
    }
  }

  // 모든 StockModel 리스트를 네이버 데이터로 업데이트
  void _updateAllStockModelsWithNaverData() {
    // 펄펄끓는 개미탕 업데이트
    for (int i = 0; i < hotAntSoupStocks.length; i++) {
      hotAntSoupStocks[i] = _updateStockWithNaverData(hotAntSoupStocks[i]);
    }

    // 식어가는 개미탕 업데이트
    for (int i = 0; i < coldAntSoupStocks.length; i++) {
      coldAntSoupStocks[i] = _updateStockWithNaverData(coldAntSoupStocks[i]);
    }

    // 냉탕온탕 개미탕 업데이트
    for (int i = 0; i < mixedAntSoupStocks.length; i++) {
      mixedAntSoupStocks[i] = _updateStockWithNaverData(mixedAntSoupStocks[i]);
    }

    // UI 업데이트
    update(['hotAntSoupStocks', 'coldAntSoupStocks', 'mixedAntSoupStocks']);
  }

  // 개별 StockModel을 네이버 데이터로 업데이트
  StockModel _updateStockWithNaverData(StockModel stock) {
    final naverData = naverStockCache[stock.code];

    if (naverData != null) {
      return stock.updateWithNaverData(
        naverCurrentPrice: naverData.currentPrice,
        naverChangeAmount: naverData.priceChange,
        naverChangePercent: naverData.changePercent,
        naverStatus: naverData.status,
      );
    }

    return stock;
  }

  // 네이버 데이터 캐시 유효성 확인
  bool _isNaverDataCached(String stockCode) {
    final cachedTime = naverCacheTime[stockCode];
    if (cachedTime == null) return false;

    final duration = NaverStockService.getCacheValidDuration();
    final diff = DateTime.now().difference(cachedTime);
    return diff < duration;
  }

  // 실시간 데이터 자동 갱신 시작
  void _startRealTimeUpdate() {
    // 시장 시간 중에만 주기적 갱신 (30초마다)
    _realTimeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (NaverStockService.isMarketTime()) {
        _refreshNaverDataInBackground();
      }
    });
  }

  // 백그라운드에서 네이버 데이터 새로고침
  Future<void> _refreshNaverDataInBackground() async {
    try {
      await _loadNaverDataForAllStocks();
    } catch (e) {
      print('백그라운드 네이버 데이터 갱신 실패: $e');
    }
  }

  // 데이터 새로고침 (기존 메서드 확장)
  Future<void> refreshData() async {
    print('홈 데이터 새로고침 시작');

    // 네이버 캐시 클리어
    naverStockCache.clear();
    naverCacheTime.clear();

    // 모든 데이터 다시 로드
    await loadInitialData();

    print('홈 데이터 새로고침 완료');
  }

  // 특정 섹션만 새로고침
  Future<void> refreshSection(String section) async {
    switch (section) {
      case 'hot':
        await loadHotAntSoupStocks();
        break;
      case 'cold':
        await loadColdAntSoupStocks();
        break;
      case 'mixed':
        await loadMixedAntSoupStocks();
        break;
    }

    // 해당 섹션의 네이버 데이터도 갱신
    await _loadNaverDataForAllStocks();
  }

  // 네이버 실시간 데이터만 강제 새로고침
  Future<void> refreshNaverData() async {
    // 캐시 클리어
    naverStockCache.clear();
    naverCacheTime.clear();

    // 네이버 데이터 다시 로드
    await _loadNaverDataForAllStocks();

    Get.snackbar(
      '실시간 데이터 새로고침',
      '최신 주가 정보를 불러왔습니다',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // 네이버 데이터 연결 상태 확인
  bool get hasNaverData {
    return naverStockCache.isNotEmpty;
  }

  // 실시간 데이터 연결된 종목 수
  int get naverDataCount {
    return naverStockCache.length;
  }

  // 검색 기능
  void onSearchSubmitted() {
    final value = searchController.text.trim();
    if (value.isEmpty) return;

    final navController = Get.find<MainNavigationController>();
    navController.changePage(1);

    if (Get.isRegistered<StockController>()) {
      final stockController = Get.find<StockController>();
      stockController.searchController.text = value;
      stockController.searchStocks(value);
    }
  }

  // 종목 상세 페이지로 이동
  void goToStockDetail(String code) {
    print('종목 상세 페이지로 이동: $code');
    Get.toNamed('/stock/detail', arguments: {'code': code});
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
    update(['themeMode']);
  }
}