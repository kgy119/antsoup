// lib/presentation/pages/stock/stock_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../controllers/main_navigation_controller.dart';

class StockController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final searchFocusNode = FocusNode();
  final scrollController = ScrollController();

  // 검색 관련
  final isLoading = false.obs;
  final searchResults = <StockModel>[].obs;
  final recentSearches = <String>[].obs;
  final hasSearched = false.obs;
  final currentKeyword = ''.obs;

  // 전체 종목 관련 (무한 스크롤)
  final allStocks = <StockModel>[].obs;
  final isLoadingAll = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final showAllStocks = false.obs;
  final currentPage = 1.obs;
  final pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    print('StockController onInit 호출됨');
    loadRecentSearches();
    _setupScrollController();

    // 홈에서 검색어와 함께 왔는지 확인
    final args = Get.arguments as Map<String, dynamic>?;
    print('StockController arguments: $args');

    if (args != null && args['searchKeyword'] != null) {
      final keyword = args['searchKeyword'] as String;
      print('검색어로 초기화: $keyword');
      searchController.text = keyword;
      currentKeyword.value = keyword;
      Future.delayed(const Duration(milliseconds: 100), () {
        searchStocks(keyword);
      });
    } else {
      // 인자가 없으면 전체 종목 로드
      print('기본 상태: 전체 종목 로드');
      Future.delayed(const Duration(milliseconds: 100), () {
        loadAllStocks();
      });
    }
  }

  @override
  void onReady() {
    super.onReady();

    // MainNavigationController의 currentIndex 변화 감지
    if (Get.isRegistered<MainNavigationController>()) {
      final mainNavController = Get.find<MainNavigationController>();
      ever(mainNavController.currentIndex, (index) {
        if (index == 1) { // 종목 탭이 선택되었을 때
          // 현재 아무 데이터도 없고 검색 상태도 아니라면 전체 종목 로드
          if (!hasSearched.value && !showAllStocks.value && allStocks.isEmpty) {
            print('탭 전환으로 인한 전체 종목 로드');
            loadAllStocks();
          }
        }
      });
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      // 스크롤이 하단에 가까워지면 다음 페이지 로드
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (showAllStocks.value && hasMoreData.value && !isLoadingMore.value) {
          loadMoreStocks();
        }
      }
    });
  }

  // 전체 종목 로드 (첫 페이지)
  Future<void> loadAllStocks() async {
    print('전체 종목 로드 시작');

    // 상태 초기화
    showAllStocks.value = true;
    hasSearched.value = false;
    isLoadingAll.value = true;
    currentPage.value = 1;
    hasMoreData.value = true;

    // 검색창과 검색 결과 클리어
    searchController.clear();
    currentKeyword.value = '';
    searchResults.clear();

    try {
      final stocks = await _apiProvider.getAllStocks(
        page: currentPage.value,
        limit: pageSize,
      );

      if (stocks.isNotEmpty) {
        allStocks.value = stocks;

        // 받은 데이터가 pageSize보다 적으면 더 이상 데이터가 없음
        if (stocks.length < pageSize) {
          hasMoreData.value = false;
          print('첫 페이지에서 모든 데이터 로드 완료');
        } else {
          hasMoreData.value = true;
          print('더 많은 데이터가 있을 것으로 예상');
        }

        print('전체 종목 로드 완료: ${stocks.length}개');
      } else {
        // 데이터가 없는 경우
        allStocks.value = [];
        hasMoreData.value = false;

        Get.snackbar(
          '알림',
          '표시할 종목이 없습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber.withOpacity(0.1),
          colorText: Colors.amber[700],
          icon: const Icon(Icons.info, color: Colors.amber),
          margin: EdgeInsets.all(16.w),
          borderRadius: 8.r,
          duration: const Duration(seconds: 2),
        );
      }

    } catch (e) {
      print('전체 종목 로드 실패: $e');

      allStocks.value = [];
      hasMoreData.value = false;

      Get.snackbar(
        '오류',
        '종목 목록을 불러오는데 실패했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[700],
        icon: const Icon(Icons.error, color: Colors.red),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

// clearSearch 메서드 수정 (전체 종목으로 돌아가기)
  void clearSearch() {
    print('검색 클리어 - 전체 종목으로 복귀');
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    currentKeyword.value = '';

    // 전체 종목 모드로 전환
    if (!showAllStocks.value || allStocks.isEmpty) {
      loadAllStocks();
    } else {
      showAllStocks.value = true;
    }
  }


// 더 많은 종목 로드 (다음 페이지)
  Future<void> loadMoreStocks() async {
    if (!hasMoreData.value || isLoadingMore.value) return;

    print('다음 페이지 로드 시작: ${currentPage.value + 1}');

    isLoadingMore.value = true;

    try {
      final stocks = await _apiProvider.getAllStocks(
        page: currentPage.value + 1,
        limit: pageSize,
      );

      if (stocks.isNotEmpty) {
        allStocks.addAll(stocks);
        currentPage.value++;

        // 받은 데이터가 pageSize보다 적으면 더 이상 데이터가 없음
        if (stocks.length < pageSize) {
          hasMoreData.value = false;
          print('마지막 페이지 도달');
        }

        print('다음 페이지 로드 완료: ${stocks.length}개 추가, 총 ${allStocks.length}개');
      } else {
        hasMoreData.value = false;
        print('더 이상 로드할 데이터가 없음');
      }

    } catch (e) {
      print('다음 페이지 로드 실패: $e');

      Get.snackbar(
        '오류',
        '추가 데이터를 불러오는데 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // 새로고침
  Future<void> refreshAllStocks() async {
    allStocks.clear();
    await loadAllStocks();
  }

  // 기존 메서드들...
  void loadRecentSearches() {
    try {
      recentSearches.value = _localStorage.getRecentSearches();
      print('최근 검색어 로드됨: ${recentSearches.length}개');
    } catch (e) {
      print('최근 검색어 로드 실패: $e');
      recentSearches.value = [];
    }
  }

  void onSearchChanged(String query) {
    currentKeyword.value = query;
  }

  void onSearchSubmitted() {
    final query = searchController.text.trim();
    print('검색 제출: $query');
    if (query.isNotEmpty) {
      searchStocks(query);
    }
  }

  Future<void> searchStocks(String keyword) async {
    if (keyword.trim().isEmpty) return;

    print('검색 시작: $keyword');

    // 전체 종목 모드 해제
    showAllStocks.value = false;

    isLoading.value = true;
    hasSearched.value = true;
    currentKeyword.value = keyword;

    try {
      final results = await _apiProvider.searchStocks(keyword);
      searchResults.value = results;

      print('검색 결과: ${results.length}개');

      // 최근 검색어에 추가
      await _localStorage.addRecentSearch(keyword);
      loadRecentSearches();

    } catch (e) {
      print('검색 실패: $e');
      searchResults.clear();

      Get.snackbar(
        '검색 실패',
        '종목 검색 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchFromRecent(String keyword) {
    print('최근 검색어에서 검색: $keyword');
    searchController.text = keyword;
    searchStocks(keyword);
    searchFocusNode.unfocus();
  }

  void clearRecentSearches() async {
    try {
      await _localStorage.clearRecentSearches();
      recentSearches.clear();

      Get.snackbar(
        '완료',
        '최근 검색어가 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('최근 검색어 삭제 실패: $e');
    }
  }

  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock/detail', arguments: {'stockCode': stockCode});
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }
}