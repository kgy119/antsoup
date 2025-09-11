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

  // 정렬 변경 메서드
  void changeSortType(StockSortType sortType) {
    if (currentSort.value != sortType) {
      currentSort.value = sortType;
      refreshStocks();
    }
  }

  // 새로고침 (정렬 변경시 사용)
  Future<void> refreshStocks() async {
    currentPage.value = 1;
    hasMore.value = true;
    stocks.clear();
    await loadStocks();
  }

  // 종목 로드 (기존 메서드 수정)
  Future<void> loadStocks() async {
    if (isLoading.value || !hasMore.value) return;

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

        // 페이지당 종목 수가 pageSize보다 적으면 더 이상 로드할 데이터가 없음
        if (newStocks.length < pageSize) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      print('종목 로드 실패: $e');
      // 에러 처리 로직 추가 가능
    } finally {
      isLoading.value = false;
    }
  }
}