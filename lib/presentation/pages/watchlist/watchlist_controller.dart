import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../../data/providers/api_provider.dart';

class WatchlistController extends GetxController {
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final isLoading = false.obs;
  final watchlistStocks = <StockModel>[].obs;
  final notFoundStocks = <String>[].obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final stockCodes = _localStorage.getWatchlist();

      if (stockCodes.isEmpty) {
        watchlistStocks.clear();
        notFoundStocks.clear();
        return;
      }

      print('관심종목 조회 시작: ${stockCodes.length}개 종목');

      // API를 통해 실제 데이터 조회
      final result = await _apiProvider.getWatchlistStocks(stockCodes);

      watchlistStocks.value = result['stocks'];
      notFoundStocks.value = List<String>.from(result['not_found']);

      print('조회 완료: ${result['total_found']}개 발견, ${result['not_found'].length}개 없음');

      // 찾지 못한 종목이 있으면 알림
      if (notFoundStocks.isNotEmpty) {
        Get.snackbar(
          '알림',
          '${notFoundStocks.length}개 종목의 데이터를 찾을 수 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('관심종목 로드 실패: $e');
      hasError.value = true;
      errorMessage.value = '관심종목을 불러오는데 실패했습니다.';

      Get.snackbar(
        '오류',
        '관심종목을 불러오는데 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWatchlist() async {
    await loadWatchlist();

    if (!hasError.value) {
      Get.snackbar(
        '완료',
        '관심종목이 새로고침되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeStock(String stockCode) async {
    try {
      // 로컬 저장소에서 제거
      await _localStorage.removeFromWatchlist(stockCode);

      // UI에서 제거
      watchlistStocks.removeWhere((stock) => stock.code == stockCode);
      notFoundStocks.remove(stockCode);

      Get.snackbar(
        '완료',
        '관심종목에서 제거되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      print('관심종목 제거 실패: $e');
      Get.snackbar(
        '오류',
        '관심종목 제거에 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAllWatchlist() async {
    try {
      await _localStorage.clearWatchlist();
      watchlistStocks.clear();
      notFoundStocks.clear();

      Get.snackbar(
        '완료',
        '모든 관심종목이 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      print('관심종목 전체 삭제 실패: $e');
      Get.snackbar(
        '오류',
        '관심종목 삭제에 실패했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock/detail', arguments: {'stockCode': stockCode});
  }

  // 빈 상태인지 확인
  bool get isEmpty => watchlistStocks.isEmpty && notFoundStocks.isEmpty;

  // 전체 종목 수 (발견된 것 + 찾지 못한 것)
  int get totalStocks => watchlistStocks.length + notFoundStocks.length;
}