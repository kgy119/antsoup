import 'package:get/get.dart';
import '../../../data/models/stock_detail_model.dart';

class StockDetailController extends GetxController {
  final isLoading = true.obs;
  final stockDetail = Rx<StockDetailModel?>(null);
  final selectedPeriod = '1개월'.obs;
  final isWatchlisted = false.obs;

  String get stockCode => Get.arguments?['stockCode'] ?? '';

  final List<String> periods = ['1일', '1주', '1개월', '3개월', '6개월', '1년'];

  @override
  void onInit() {
    super.onInit();
    loadStockDetail();
  }

  Future<void> loadStockDetail() async {
    isLoading.value = true;
    try {
      // TODO: API 연동 후 실제 데이터로 교체
      await Future.delayed(const Duration(milliseconds: 800));

      stockDetail.value = _generateDummyStockDetail();
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // TODO: 기간에 따른 차트 데이터 다시 로드
    _updateChartData();
  }

  void toggleWatchlist() {
    isWatchlisted.value = !isWatchlisted.value;
    // TODO: 관심종목 추가/제거 API 호출
  }

  void _updateChartData() {
    // 기간별 차트 데이터 업데이트
    final current = stockDetail.value;
    if (current != null) {
      stockDetail.value = StockDetailModel(
        code: current.code,
        name: current.name,
        currentPrice: current.currentPrice,
        changeAmount: current.changeAmount,
        changePercent: current.changePercent,
        volume: current.volume,
        marketCap: current.marketCap,
        per: current.per,
        pbr: current.pbr,
        priceHistory: _generatePriceHistory(),
        antSoupIndex: _generateAntSoupIndex(),
      );
    }
  }

  StockDetailModel _generateDummyStockDetail() {
    final Map<String, Map<String, dynamic>> stockData = {
      '005930': {
        'name': '삼성전자',
        'currentPrice': 75000,
        'changeAmount': 1000,
        'changePercent': 1.35,
        'volume': 12500000,
        'marketCap': 4500000000000,
        'per': 12.5,
        'pbr': 1.2,
      },
      '000660': {
        'name': 'SK하이닉스',
        'currentPrice': 125000,
        'changeAmount': -2500,
        'changePercent': -1.96,
        'volume': 8500000,
        'marketCap': 9100000000000,
        'per': 15.2,
        'pbr': 1.8,
      },
      '035420': {
        'name': 'NAVER',
        'currentPrice': 185000,
        'changeAmount': 3500,
        'changePercent': 1.93,
        'volume': 950000,
        'marketCap': 3050000000000,
        'per': 22.1,
        'pbr': 2.1,
      },
    };

    final data = stockData[stockCode] ?? stockData['005930']!;

    return StockDetailModel(
      code: stockCode,
      name: data['name'],
      currentPrice: data['currentPrice'],
      changeAmount: data['changeAmount'],
      changePercent: data['changePercent'],
      volume: data['volume'],
      marketCap: data['marketCap'],
      per: data['per'],
      pbr: data['pbr'],
      priceHistory: _generatePriceHistory(),
      antSoupIndex: _generateAntSoupIndex(),
    );
  }

  List<ChartDataPoint> _generatePriceHistory() {
    final List<ChartDataPoint> data = [];
    final now = DateTime.now();
    final basePrice = stockDetail.value?.currentPrice ?? 75000;

    // 기간에 따른 데이터 포인트 수 결정
    int dataPoints;
    int dayInterval;

    switch (selectedPeriod.value) {
      case '1일':
        dataPoints = 24; // 시간별
        dayInterval = 0;
        break;
      case '1주':
        dataPoints = 7;
        dayInterval = 1;
        break;
      case '1개월':
        dataPoints = 30;
        dayInterval = 1;
        break;
      case '3개월':
        dataPoints = 90;
        dayInterval = 1;
        break;
      case '6개월':
        dataPoints = 180;
        dayInterval = 1;
        break;
      case '1년':
        dataPoints = 365;
        dayInterval = 1;
        break;
      default:
        dataPoints = 30;
        dayInterval = 1;
    }

    for (int i = dataPoints - 1; i >= 0; i--) {
      DateTime date;
      if (selectedPeriod.value == '1일') {
        date = now.subtract(Duration(hours: i));
      } else {
        date = now.subtract(Duration(days: i * dayInterval));
      }

      // 랜덤한 주가 변동 시뮬레이션
      final random = (i * 17) % 100;
      final variance = (random - 50) * 0.02; // -2% ~ +2% 변동
      final price = basePrice * (1 + variance);

      data.add(ChartDataPoint(date: date, value: price));
    }

    return data;
  }

  List<ChartDataPoint> _generateAntSoupIndex() {
    final List<ChartDataPoint> data = [];
    final now = DateTime.now();

    // 기간에 따른 데이터 포인트 수 결정
    int dataPoints;
    int dayInterval;

    switch (selectedPeriod.value) {
      case '1일':
        dataPoints = 24;
        dayInterval = 0;
        break;
      case '1주':
        dataPoints = 7;
        dayInterval = 1;
        break;
      case '1개월':
        dataPoints = 30;
        dayInterval = 1;
        break;
      case '3개월':
        dataPoints = 90;
        dayInterval = 1;
        break;
      case '6개월':
        dataPoints = 180;
        dayInterval = 1;
        break;
      case '1년':
        dataPoints = 365;
        dayInterval = 1;
        break;
      default:
        dataPoints = 30;
        dayInterval = 1;
    }

    // 개미탕 지수는 0-100 사이의 값
    for (int i = dataPoints - 1; i >= 0; i--) {
      DateTime date;
      if (selectedPeriod.value == '1일') {
        date = now.subtract(Duration(hours: i));
      } else {
        date = now.subtract(Duration(days: i * dayInterval));
      }

      // 개미탕 지수 시뮬레이션 (주가와 역상관 관계)
      final random = (i * 23) % 100;
      final baseIndex = 50.0;
      final variance = (random - 50) * 0.5; // -25 ~ +25 변동
      final index = (baseIndex + variance).clamp(0.0, 100.0);

      data.add(ChartDataPoint(date: date, value: index));
    }

    return data;
  }

  void goBack() {
    Get.back();
  }
}