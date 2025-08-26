import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../../../data/providers/api_provider.dart';

class WatchlistController extends GetxController {
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final isLoading = false.obs;
  final watchlistStocks = <StockModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    isLoading.value = true;

    try {
      final stockCodes = _localStorage.getWatchlist();

      if (stockCodes.isEmpty) {
        watchlistStocks.clear();
        return;
      }

      // 각 종목 코드로 상세 정보 조회
      List<StockModel> stocks = [];
      for (String code in stockCodes) {
        try {
          // 간단한 종목 정보만 필요하므로 더미 데이터나 캐시된 데이터 사용
          stocks.add(_generateDummyStock(code));
        } catch (e) {
          print('종목 $code 정보 로드 실패: $e');
        }
      }

      watchlistStocks.value = stocks;
    } catch (e) {
      print('관심종목 로드 실패: $e');
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
    Get.snackbar(
      '완료',
      '관심종목이 새로고침되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToStockDetail(String stockCode) {
    Get.toNamed('/stock/detail', arguments: {'stockCode': stockCode});
  }

  // 더미 데이터 생성 (실제로는 캐시나 API 호출)
  StockModel _generateDummyStock(String code) {
    final Map<String, Map<String, dynamic>> stockData = {
      '005930': {
        'name': '삼성전자',
        'currentPrice': 75000,
        'changeAmount': 1000,
        'changePercent': 1.35,
      },
      '000660': {
        'name': 'SK하이닉스',
        'currentPrice': 125000,
        'changeAmount': -2500,
        'changePercent': -1.96,
      },
      // ... 더 많은 더미 데이터
    };

    final data = stockData[code] ?? {
      'name': '알수없음($code)',
      'currentPrice': 10000,
      'changeAmount': 0,
      'changePercent': 0.0,
    };

    return StockModel(
      code: code,
      name: data['name'],
      currentPrice: data['currentPrice'],
      changeAmount: data['changeAmount'],
      changePercent: data['changePercent'],
    );
  }
}