import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class NaverStockPrice {
  final String stockCode;
  final String stockName;
  final int currentPrice;
  final int priceChange;
  final double changePercent;
  final String status; // '상승', '하락', '보합'

  NaverStockPrice({
    required this.stockCode,
    required this.stockName,
    required this.currentPrice,
    required this.priceChange,
    required this.changePercent,
    required this.status,
  });

  @override
  String toString() {
    return 'NaverStockPrice{code: $stockCode, name: $stockName, price: $currentPrice, change: $priceChange, percent: $changePercent%, status: $status}';
  }
}

class NaverStockService {
  static const String _baseUrl = 'https://finance.naver.com/item/main.naver';
  static const Duration _timeout = Duration(seconds: 10);

  // 단일 종목 실시간 데이터 조회
  static Future<NaverStockPrice?> getStockPrice(String stockCode) async {
    try {
      final url = '$_baseUrl?code=$stockCode';
      print('네이버 증권 데이터 조회 시작: $stockCode');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ko-KR,ko;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseStockData(response.body, stockCode);
      } else {
        print('네이버 증권 HTTP 에러: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('네이버 증권 데이터 조회 실패 ($stockCode): $e');
      return null;
    }
  }

  // 여러 종목 동시 조회 (병렬 처리)
  static Future<Map<String, NaverStockPrice>> getMultipleStockPrices(List<String> stockCodes) async {
    final Map<String, NaverStockPrice> results = {};

    // 최대 10개씩 배치로 처리하여 과도한 동시 요청 방지
    const int batchSize = 10;

    for (int i = 0; i < stockCodes.length; i += batchSize) {
      final batch = stockCodes.skip(i).take(batchSize).toList();

      final futures = batch.map((code) => getStockPrice(code));
      final batchResults = await Future.wait(futures);

      for (int j = 0; j < batch.length; j++) {
        final stockPrice = batchResults[j];
        if (stockPrice != null) {
          results[batch[j]] = stockPrice;
        }
      }

      // 배치 간 간격 (DOS 공격 방지)
      if (i + batchSize < stockCodes.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    print('네이버 증권 다중 조회 완료: ${results.length}/${stockCodes.length}');
    return results;
  }

  // HTML 파싱하여 주가 데이터 추출
  static NaverStockPrice? _parseStockData(String html, String stockCode) {
    try {
      final document = parser.parse(html);

      // 종목명
      final stockNameElement = document.querySelector('.wrap_company h2 a');
      final stockName = stockNameElement?.text?.trim() ?? '';

      // 현재가
      final priceElement = document.querySelector('.no_today .blind');
      if (priceElement == null) {
        print('❌ 현재가 요소를 찾을 수 없음: $stockCode');
        return null;
      }
      final priceText = priceElement.text.replaceAll(',', '').replaceAll('현재가', '').trim();
      final currentPrice = int.tryParse(priceText) ?? 0;

      // 변동 정보 파싱
      int priceChange = 0;
      double changePercent = 0.0;
      String status = '보합'; // 기본값은 보합

      // 네이버 증권 페이지에서 '전일대비' 섹션을 직접 찾기
      final exDayElement = document.querySelector('.no_exday');
      if (exDayElement != null) {
        final changeElements = exDayElement.querySelectorAll('.blind');

        // 변동금액 및 변동률 파싱
        if (changeElements.length >= 2) {
          // 변동금액 파싱
          final changeText = changeElements[0].text
              .replaceAll(',', '')
              .replaceAll('전일대비', '')
              .replaceAll('상승', '')
              .replaceAll('하락', '')
              .replaceAll('보합', '')
              .trim();
          priceChange = int.tryParse(changeText) ?? 0;

          // 변동률 파싱 (기호와 %를 제거)
          final percentText = changeElements[1].text
              .replaceAll('%', '')
              .replaceAll('상승', '')
              .replaceAll('하락', '')
              .replaceAll('보합', '')
              .trim();
          changePercent = double.tryParse(percentText) ?? 0.0;
        }

        // 등락 상태 판단 (HTML 클래스나 문자열 포함 여부로 판단)
        if (exDayElement.querySelector('.no_up') != null) {
          status = '상승';
        } else if (exDayElement.querySelector('.no_down') != null) {
          status = '하락';
        } else {
          status = '보합';
        }
      }

      // 최종 값 조정
      if (status == '하락') {
        priceChange = -priceChange.abs();
        changePercent = -changePercent.abs();
      } else if (status == '상승') {
        priceChange = priceChange.abs();
        changePercent = changePercent.abs();
      } else {
        priceChange = 0;
        changePercent = 0.0;
      }

      if (currentPrice <= 0) {
        print('❌ 유효하지 않은 현재가: $stockCode, $currentPrice');
        return null;
      }

      final result = NaverStockPrice(
        stockCode: stockCode,
        stockName: stockName,
        currentPrice: currentPrice,
        priceChange: priceChange,
        changePercent: changePercent,
        status: status,
      );

      print('✅ 네이버 파싱 완료: $stockCode - $status (${priceChange}, ${changePercent}%)');
      return result;

    } catch (e) {
      print('❌ HTML 파싱 실패 ($stockCode): $e');
      return null;
    }
  }



  // 캐시된 데이터 유효성 검사 (시장 시간 고려)
  static bool isMarketTime() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final hour = now.hour;
    final minute = now.minute;

    // 주말 제외 (토요일: 6, 일요일: 7)
    if (weekday == 6 || weekday == 7) {
      return false;
    }

    // 한국 증시 시간: 09:00 ~ 15:30
    if (hour < 9 || hour > 15) {
      return false;
    }

    if (hour == 15 && minute > 30) {
      return false;
    }

    return true;
  }

  // 시장 시간 외 캐시 유효 시간 계산
  static Duration getCacheValidDuration() {
    if (isMarketTime()) {
      return const Duration(seconds: 30); // 시장 시간 중: 30초
    } else {
      return const Duration(hours: 1); // 시장 시간 외: 1시간
    }
  }
}