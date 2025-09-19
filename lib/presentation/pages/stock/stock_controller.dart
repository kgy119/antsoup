import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
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

  // 정렬 관련 변수 추가
  final Rx<StockSortType> currentSort = StockSortType.asiHighToLow.obs;

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

  // 정렬 변경 메서드
  void changeSortType(StockSortType sortType) {
    if (currentSort.value != sortType) {
      currentSort.value = sortType;

      // 특별한 개미탕 필터의 경우 전체 데이터를 다시 로드
      if (_isSpecialAntSoupFilter(sortType)) {
        refreshAllStocks();
      } else {
        refreshAllStocks();
      }
    }
  }

// 특별한 개미탕 필터인지 확인하는 헬퍼 메서드 추가
  bool _isSpecialAntSoupFilter(StockSortType sortType) {
    return sortType == StockSortType.coldAntSoup ||
        sortType == StockSortType.mixedAntSoup ||
        sortType == StockSortType.hotAntSoup;
  }


// 전체 종목 로드 메서드 수정
  Future<void> loadAllStocks() async {
    print('전체 종목 로드 시작 - 정렬: ${currentSort.value.displayName}');

    // 상태 초기화
    showAllStocks.value = true;
    hasSearched.value = false;
    isLoadingAll.value = true;
    currentPage.value = 1;

    // 특별한 개미탕 필터의 경우 무한 스크롤 비활성화
    if (_isSpecialAntSoupFilter(currentSort.value)) {
      hasMoreData.value = false;
    } else {
      hasMoreData.value = true;
    }

    // 검색창과 검색 결과 클리어
    searchController.clear();
    currentKeyword.value = '';
    searchResults.clear();

    try {
      final stocks = await _apiProvider.getAllStocks(
        page: currentPage.value,
        limit: pageSize,
        sortBy: currentSort.value.sortKey,
      );

      if (stocks.isNotEmpty) {
        allStocks.value = stocks;

        // 특별한 개미탕 필터가 아닌 경우에만 페이징 체크
        if (!_isSpecialAntSoupFilter(currentSort.value)) {
          if (stocks.length < pageSize) {
            hasMoreData.value = false;
            print('첫 페이지에서 모든 데이터 로드 완료');
          } else {
            hasMoreData.value = true;
            print('더 많은 데이터가 있을 것으로 예상');
          }
        }

        print('전체 종목 로드 완료: ${stocks.length}개');
      } else {
        // 데이터가 없는 경우
        allStocks.value = [];
        hasMoreData.value = false;

        Get.snackbar(
          '알림',
          '조회된 종목이 없습니다',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('전체 종목 로드 실패: $e');
      Get.snackbar(
        '오류',
        '종목 데이터 로드에 실패했습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

// 무한 스크롤 로드 메서드 수정
  Future<void> loadMoreAllStocks() async {
    // 특별한 개미탕 필터의 경우 추가 로드 방지
    if (_isSpecialAntSoupFilter(currentSort.value)) {
      print('특별한 개미탕 필터이므로 추가 로드하지 않음');
      return;
    }

    if (isLoadingMore.value || !hasMoreData.value) return;

    print('추가 종목 로드 시작 - 페이지: ${currentPage.value + 1}');

    try {
      isLoadingMore.value = true;

      final stocks = await _apiProvider.getAllStocks(
        page: currentPage.value + 1,
        limit: pageSize,
        sortBy: currentSort.value.sortKey,
      );

      if (stocks.isNotEmpty) {
        allStocks.addAll(stocks);
        currentPage.value++;

        if (stocks.length < pageSize) {
          hasMoreData.value = false;
          print('모든 데이터 로드 완료');
        }

        print('추가 종목 로드 완료: ${stocks.length}개');
      } else {
        hasMoreData.value = false;
        print('더 이상 로드할 데이터 없음');
      }
    } catch (e) {
      print('추가 종목 로드 실패: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }


  // 검색 클리어 메서드
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    currentKeyword.value = '';
    searchFocusNode.unfocus();

    // 전체 종목이 로드되지 않았다면 로드
    if (allStocks.isEmpty) {
      loadAllStocks();
    }
  }

  // 추가 종목 로드 (무한 스크롤)
  Future<void> loadMoreStocks() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    print('추가 종목 로드: ${currentPage.value + 1}페이지');
    isLoadingMore.value = true;

    try {
      final stocks = await _apiProvider.getAllStocks(
        page: currentPage.value + 1,
        limit: pageSize,
        sortBy: currentSort.value.sortKey, // 정렬 옵션 추가
      );

      if (stocks.isNotEmpty) {
        allStocks.addAll(stocks);
        currentPage.value++;

        // 받은 데이터가 pageSize보다 적으면 더 이상 데이터가 없음
        if (stocks.length < pageSize) {
          hasMoreData.value = false;
          print('모든 데이터 로드 완료');
        }

        print('추가 종목 로드 완료: ${stocks.length}개');
      } else {
        hasMoreData.value = false;
        print('더 이상 로드할 종목이 없음');
      }
    } catch (e) {
      print('추가 종목 로드 실패: $e');

      Get.snackbar(
        '오류',
        '추가 종목을 불러오는데 실패했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // 새로고침 (정렬 변경시 사용)
  Future<void> refreshAllStocks() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    allStocks.clear();
    await loadAllStocks();
  }

  // 기존 검색 관련 메서드들...
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

  void onSearchSubmitted(String value) {
    print('검색 제출: $value');
    if (value.isNotEmpty) {
      searchStocks(value);
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