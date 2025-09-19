import 'package:get/get.dart';
import '../../core/constants/enums.dart';
import '../../data/models/stock_model.dart';
import '../../data/providers/api_provider.dart';

class StockListController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // 기존 변수들
  final RxList<StockModel> stocks = <StockModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 20;

  // 정렬 관련 변수 추가
  final Rx<StockSortType> currentSort = StockSortType.asiHighToLow.obs;

  @override
  void onInit() {
    super.onInit();
    loadStocks();
  }

  // 특별한 개미탕 필터인지 확인하는 헬퍼 메서드 추가
  bool _isSpecialAntSoupFilter(StockSortType sortType) {
    return sortType == StockSortType.coldAntSoup ||
        sortType == StockSortType.mixedAntSoup ||
        sortType == StockSortType.hotAntSoup;
  }

// 정렬 변경 메서드 수정
  void changeSortType(StockSortType sortType) {
    if (currentSort.value != sortType) {
      currentSort.value = sortType;

      // 특별한 개미탕 필터의 경우 무한 스크롤 비활성화
      if (_isSpecialAntSoupFilter(sortType)) {
        hasMore.value = false;
      } else {
        hasMore.value = true;
      }

      refreshStocks();
    }
  }

// 종목 로드 메서드 수정
  Future<void> loadStocks() async {
    if (isLoading.value || (!hasMore.value && currentPage.value > 1)) return;

    // 특별한 개미탕 필터의 경우 추가 로드 방지
    if (_isSpecialAntSoupFilter(currentSort.value) && currentPage.value > 1) {
      print('특별한 개미탕 필터이므로 추가 로드하지 않음');
      return;
    }

    try {
      isLoading.value = true;

      final newStocks = await _apiProvider.getAllStocks(
        page: currentPage.value,
        limit: pageSize,
        sortBy: currentSort.value.sortKey,
      );

      if (newStocks.isEmpty) {
        hasMore.value = false;
      } else {
        stocks.addAll(newStocks);
        currentPage.value++;

        // 특별한 개미탕 필터의 경우 항상 더 이상 로드하지 않음
        if (_isSpecialAntSoupFilter(currentSort.value)) {
          hasMore.value = false;
        } else if (newStocks.length < pageSize) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      print('종목 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

// 새로고침 메서드 수정
  Future<void> refreshStocks() async {
    currentPage.value = 1;

    // 특별한 개미탕 필터가 아닌 경우에만 hasMore를 true로 설정
    if (_isSpecialAntSoupFilter(currentSort.value)) {
      hasMore.value = false;
    } else {
      hasMore.value = true;
    }

    stocks.clear();
    await loadStocks();
  }

  // 종목 상세 페이지로 이동
  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock_detail', arguments: {
      'stockCode': stockCode,
    });
  }


}