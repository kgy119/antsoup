import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';

class StockController extends GetxController {
  final searchController = TextEditingController();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final searchFocusNode = FocusNode();

  final isLoading = false.obs;
  final searchResults = <StockModel>[].obs;
  final recentSearches = <String>[].obs;
  final hasSearched = false.obs;
  final currentKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('StockController onInit 호출됨');
    loadRecentSearches();

    // 홈에서 검색어와 함께 왔는지 확인
    final args = Get.arguments as Map<String, dynamic>?;
    print('StockController arguments: $args');

    if (args != null && args['searchKeyword'] != null) {
      final keyword = args['searchKeyword'] as String;
      print('검색어로 초기화: $keyword');
      searchController.text = keyword;
      currentKeyword.value = keyword;
      // 약간의 지연 후 검색 실행
      Future.delayed(const Duration(milliseconds: 100), () {
        searchStocks(keyword);
      });
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

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
    isLoading.value = true;
    hasSearched.value = true;
    currentKeyword.value = keyword;

    try {
      final results = await _apiProvider.searchStocks(keyword);
      searchResults.value = results;

      print('검색 결과: ${results.length}개');
      for (var result in results) {
        print('- ${result.code}: ${result.name}');
      }

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

  void clearSearch() {
    print('검색 클리어');
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    currentKeyword.value = '';
  }

  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock/detail', arguments: {'stockCode': stockCode});
  }

  void unfocusSearch() {
    searchFocusNode.unfocus();
  }
}