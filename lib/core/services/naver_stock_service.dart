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

  // 현재 페이지에 표시된 데이터 파싱 (대폭 개선)
  static Map<String, dynamic>? _parseCurrentDisplayedData(Document document) {
    try {
      print('🔍 현재 표시된 데이터 파싱');

      // 네이버 증권의 실제 구조에 맞는 셀렉터들
      const List<String> priceSelectors = [
        '.no_today .blind',                    // 기본 현재가
        '.wrap_company .no_today .blind',      // 회사 정보 섹션의 현재가
        '.today .blind',                       // 대체 현재가
        '.section_price .no_today .blind',     // 가격 섹션의 현재가
        '.rate_info .blind',                   // 시세 정보의 현재가
      ];

      int? currentPrice;
      String? selectedText;

      for (final selector in priceSelectors) {
        final elements = document.querySelectorAll(selector);
        for (final element in elements) {
          final text = element.text.trim();
          print('🔍 검사 중인 텍스트: "$text" (셀렉터: $selector)');

          // 가격으로 보이는 패턴 확인
          if (_isLikelyPrice(text)) {
            final cleanText = text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
            final price = int.tryParse(cleanText);

            if (price != null && price >= 100 && price <= 1000000) {
              currentPrice = price;
              selectedText = text;
              print('✅ $selector 에서 현재가 발견: $price (원본: $text)');
              break;
            }
          }
        }
        if (currentPrice != null) break;
      }

      // 현재가를 찾지 못했다면 더 넓은 범위에서 검색
      if (currentPrice == null) {
        print('🔍 넓은 범위에서 현재가 검색');
        final allElements = document.querySelectorAll('.blind');

        for (final element in allElements) {
          final text = element.text.trim();

          // "현재가", "종가", 금액 패턴 등으로 현재가 추정
          if (text.contains('현재가') ||
              text.contains('종가') ||
              _isLikelyCurrentPrice(text)) {

            final cleanText = text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
            final price = int.tryParse(cleanText);

            if (price != null && price >= 100 && price <= 1000000) {
              currentPrice = price;
              selectedText = text;
              print('✅ 넓은 검색에서 현재가 발견: $price (원본: $text)');
              break;
            }
          }
        }
      }

      if (currentPrice == null || currentPrice <= 0) {
        print('❌ 현재 표시된 데이터에서 유효한 가격을 찾을 수 없음');
        return null;
      }

      // 변동 정보 파싱
      final changeInfo = _parseChangeInfo(document);

      print('✅ 현재가 파싱 완료: $currentPrice원 (${changeInfo['status']})');
      return {
        'currentPrice': currentPrice,
        'priceChange': changeInfo['priceChange'],
        'changePercent': changeInfo['changePercent'],
        'status': changeInfo['status'],
      };

    } catch (e) {
      print('❌ 현재 표시 데이터 파싱 실패: $e');
      return null;
    }
  }

// 가격으로 보이는 텍스트인지 판단
  static bool _isLikelyPrice(String text) {
    // 숫자와 콤마만 포함하거나, 원 단위 표시가 있는 경우
    final cleanText = text.replaceAll(',', '').trim();

    // 순수 숫자인지 확인
    if (RegExp(r'^\d+$').hasMatch(cleanText)) {
      final number = int.tryParse(cleanText);
      return number != null && number >= 100 && number <= 1000000;
    }

    // "원" 또는 가격 단위가 포함된 경우
    if (text.contains('원') || text.contains('₩')) {
      return true;
    }

    return false;
  }

// 현재가로 추정되는 텍스트인지 판단
  static bool _isLikelyCurrentPrice(String text) {
    final keywords = ['현재가', '종가', '시가', '고가', '저가'];
    final lowerText = text.toLowerCase();

    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    // 숫자 + 원 패턴
    if (RegExp(r'\d{3,}원').hasMatch(text)) {
      return true;
    }

    return false;
  }

// 변동 정보 파싱 (분리된 메서드)
  static Map<String, dynamic> _parseChangeInfo(Document document) {
    int priceChange = 0;
    double changePercent = 0.0;
    String status = '보합';

    try {
      // 변동 정보를 찾기 위한 셀렉터들
      const changeSelectors = [
        '.no_exday',
        '.wrap_company .no_exday',
        '.section_price .no_exday',
        '.rate_info .no_exday',
      ];

      for (final selector in changeSelectors) {
        final changeElement = document.querySelector(selector);
        if (changeElement != null) {
          final blinds = changeElement.querySelectorAll('.blind');

          if (blinds.length >= 2) {
            try {
              // 변동금액 파싱
              final changeText = blinds[0].text.replaceAll(RegExp(r'[^0-9\-]'), '');
              priceChange = int.tryParse(changeText) ?? 0;

              // 변동률 파싱
              final percentText = blinds[1].text.replaceAll(RegExp(r'[^0-9\.\-]'), '');
              changePercent = double.tryParse(percentText) ?? 0.0;

              // 상태 판단 (CSS 클래스로)
              if (changeElement.querySelector('.no_up') != null ||
                  changeElement.classes.contains('up')) {
                status = '상승';
                priceChange = priceChange.abs();
                changePercent = changePercent.abs();
              } else if (changeElement.querySelector('.no_down') != null ||
                  changeElement.classes.contains('down')) {
                status = '하락';
                priceChange = -priceChange.abs();
                changePercent = -changePercent.abs();
              }

              print('✅ 변동 정보 파싱: $status ${priceChange}원 (${changePercent}%)');
              break;
            } catch (e) {
              print('⚠️ 변동 정보 파싱 중 오류: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ 변동 정보 파싱 실패: $e');
    }

    return {
      'priceChange': priceChange,
      'changePercent': changePercent,
      'status': status,
    };
  }

// blind 요소 검사 로직도 개선
  static Map<String, dynamic>? _tryParseFromAllBlindElements(Document document) {
    try {
      print('🔍 모든 .blind 요소 검사 시작');
      final blindElements = document.querySelectorAll('.blind');

      List<int> priceCandidate = [];
      Map<int, int> priceFrequency = {};

      // blind 요소들을 검사하여 주가로 보이는 값들 수집
      for (final element in blindElements) {
        final text = element.text.trim();

        if (_isLikelyPrice(text)) {
          final cleanText = text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9]'), '');
          final price = int.tryParse(cleanText);

          if (price != null && price >= 1000 && price <= 500000) { // 범위를 더 현실적으로
            priceCandidate.add(price);
            priceFrequency[price] = (priceFrequency[price] ?? 0) + 1;
            print('💡 주가 후보: $price (빈도: ${priceFrequency[price]}, 원본: $text)');
          }
        }
      }

      if (priceCandidate.isEmpty) {
        print('❌ 적절한 주가 후보를 찾을 수 없음');
        return null;
      }

      // 가장 빈도가 높은 가격 선택
      int? selectedPrice;
      int maxFrequency = 0;

      for (final entry in priceFrequency.entries) {
        if (entry.value > maxFrequency) {
          maxFrequency = entry.value;
          selectedPrice = entry.key;
        }
      }

      if (selectedPrice == null) {
        print('❌ 최종 가격 선택 실패');
        return null;
      }

      print('✅ blind 요소에서 현재가 확정: $selectedPrice (빈도: $maxFrequency)');
      return {
        'currentPrice': selectedPrice,
        'priceChange': 0,
        'changePercent': 0.0,
        'status': '보합',
      };

    } catch (e) {
      print('❌ blind 요소 검사 실패: $e');
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

  // HTML 파싱하여 주가 데이터 추출 (항상 NXT 데이터 우선)
  static NaverStockPrice? _parseStockData(String html, String stockCode) {
    try {
      final document = parser.parse(html);

      // 종목명
      final stockNameElement = document.querySelector('.wrap_company h2 a');
      final stockName = stockNameElement?.text?.trim() ?? '';

      int currentPrice = 0;
      int priceChange = 0;
      double changePercent = 0.0;
      String status = '보합';

      // 항상 NXT 데이터를 먼저 시도
      final nxtData = _parseNxtData(document);
      if (nxtData != null) {
        currentPrice = nxtData['currentPrice'];
        priceChange = nxtData['priceChange'];
        changePercent = nxtData['changePercent'];
        status = nxtData['status'];
        print('✅ NXT 데이터 사용: $stockCode - $status (${priceChange}, ${changePercent}%)');
      } else {
        // NXT 파싱 실패시에만 KRX 데이터 사용
        final krxData = _parseKrxData(document);
        if (krxData != null) {
          currentPrice = krxData['currentPrice'];
          priceChange = krxData['priceChange'];
          changePercent = krxData['changePercent'];
          status = krxData['status'];
          print('⚠️ NXT 파싱 실패, KRX 데이터 사용: $stockCode - $status (${priceChange}, ${changePercent}%)');
        }
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

// NXT 데이터 파싱 (모든 가능한 방법으로 시도)
  // NXT 데이터 파싱 (순서 개선)
  static Map<String, dynamic>? _parseNxtData(Document document) {
    try {
      print('🔍 NXT 데이터 파싱 시작...');

      Map<String, dynamic>? result;

      // 1순위: 기본 현재가 정보부터 시도 (가장 신뢰할 만함)
      result = _parseCurrentDisplayedData(document);
      if (result != null) {
        print('✅ 기본 현재가 정보를 NXT로 사용');
        return result;
      }

      // 2순위: tab_con1 (NXT 전용 컨테이너)
      result = _tryParseFromSelector(document, '.tab_con1', 'tab_con1');
      if (result != null) return result;

      // 3순위: section_time_off (시간외 거래 전용)
      result = _tryParseFromSelector(document, '.section_time_off', 'section_time_off');
      if (result != null) return result;

      // 4순위: wrap_company 내부의 NXT 정보
      result = _tryParseFromSelector(document, '.wrap_company .tab_con1', 'wrap_company_nxt');
      if (result != null) return result;

      // 5순위: JavaScript 변수에서 추출
      result = _tryParseNxtFromScript(document);
      if (result != null) return result;

      // 최후 순위: 모든 blind 요소 검사 (가장 부정확할 수 있음)
      result = _tryParseFromAllBlindElements(document);
      if (result != null) return result;

      print('❌ 모든 NXT 파싱 방법 실패');
      return null;
    } catch (e) {
      print('❌ NXT 데이터 파싱 전체 실패: $e');
      return null;
    }
  }

// 특정 셀렉터에서 데이터 파싱 시도
  static Map<String, dynamic>? _tryParseFromSelector(Document document, String selector, String method) {
    try {
      final container = document.querySelector(selector);
      if (container == null) {
        print('❌ $method: $selector 요소 없음');
        return null;
      }

      // 숨겨져 있는지 확인
      final style = container.attributes['style'] ?? '';
      if (style.contains('display: none') || style.contains('display:none')) {
        print('❌ $method: $selector 숨겨진 상태');
        return null;
      }

      print('🔍 $method: $selector 에서 데이터 파싱 시도');
      return _parseDataFromContainer(container, method);
    } catch (e) {
      print('❌ $method 파싱 실패: $e');
      return null;
    }
  }

  // KRX(정규 시장) 데이터 파싱
  static Map<String, dynamic>? _parseKrxData(Document document) {
    try {
      print('🔍 KRX 데이터 파싱 시작');

      // 현재가 찾기
      final priceElement = document.querySelector('.no_today .blind');
      if (priceElement == null) {
        print('❌ KRX 현재가 요소를 찾을 수 없음');
        return null;
      }

      final priceText = priceElement.text.replaceAll(',', '').replaceAll('현재가', '').trim();
      final currentPrice = int.tryParse(priceText) ?? 0;

      if (currentPrice <= 0) {
        print('❌ KRX 유효하지 않은 가격: $currentPrice');
        return null;
      }

      // 변동 정보 파싱
      int priceChange = 0;
      double changePercent = 0.0;
      String status = '보합';

      final exDayElement = document.querySelector('.no_exday');
      if (exDayElement != null) {
        final changeElements = exDayElement.querySelectorAll('.blind');

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

          // 변동률 파싱
          final percentText = changeElements[1].text
              .replaceAll('%', '')
              .replaceAll('상승', '')
              .replaceAll('하락', '')
              .replaceAll('보합', '')
              .trim();
          changePercent = double.tryParse(percentText) ?? 0.0;
        }

        // 등락 상태 판단
        if (exDayElement.querySelector('.no_up') != null) {
          status = '상승';
          priceChange = priceChange.abs();
          changePercent = changePercent.abs();
        } else if (exDayElement.querySelector('.no_down') != null) {
          status = '하락';
          priceChange = -priceChange.abs();
          changePercent = -changePercent.abs();
        } else {
          status = '보합';
          priceChange = 0;
          changePercent = 0.0;
        }
      }

      print('✅ KRX 데이터 파싱 성공: $currentPrice ($status)');
      return {
        'currentPrice': currentPrice,
        'priceChange': priceChange,
        'changePercent': changePercent,
        'status': status,
      };
    } catch (e) {
      print('❌ KRX 데이터 파싱 실패: $e');
      return null;
    }
  }

// 공통 컨테이너 파싱 로직 (기존 메서드 개선)
  static Map<String, dynamic>? _parseDataFromContainer(Element container, String containerName) {
    try {
      // 현재가 찾기 - 다양한 셀렉터 시도
      final priceSelectors = [
        '.no_today .blind',
        '.today .blind',
        '.price .blind',
        '.current_price .blind',
        '[class*="price"] .blind'
      ];

      int? currentPrice;
      Element? priceElement;

      for (final selector in priceSelectors) {
        priceElement = container.querySelector(selector);
        if (priceElement != null) {
          final priceText = priceElement.text.replaceAll(',', '').replaceAll('현재가', '').trim();
          currentPrice = int.tryParse(priceText);
          if (currentPrice != null && currentPrice > 0) {
            print('✅ $containerName: $selector에서 가격 발견: $currentPrice');
            break;
          }
        }
      }

      if (currentPrice == null || currentPrice <= 0) {
        print('❌ $containerName에서 유효한 가격을 찾을 수 없음');
        return null;
      }

      // 변동 정보 찾기
      int priceChange = 0;
      double changePercent = 0.0;
      String status = '보합';

      final changeSelectors = [
        '.no_exday',
        '.exday',
        '.change_info',
        '[class*="exday"]'
      ];

      for (final selector in changeSelectors) {
        final exDayElement = container.querySelector(selector);
        if (exDayElement != null) {
          final changeElements = exDayElement.querySelectorAll('.blind');

          if (changeElements.length >= 2) {
            // 변동금액
            final changeText = changeElements[0].text
                .replaceAll(RegExp(r'[^0-9\-]'), '');
            priceChange = int.tryParse(changeText) ?? 0;

            // 변동률
            final percentText = changeElements[1].text
                .replaceAll(RegExp(r'[^0-9\.\-]'), '');
            changePercent = double.tryParse(percentText) ?? 0.0;

            // 상태 판단
            if (exDayElement.querySelector('.no_up, .up') != null) {
              status = '상승';
              priceChange = priceChange.abs();
              changePercent = changePercent.abs();
            } else if (exDayElement.querySelector('.no_down, .down') != null) {
              status = '하락';
              priceChange = -priceChange.abs();
              changePercent = -changePercent.abs();
            }

            break;
          }
        }
      }

      print('✅ $containerName에서 데이터 파싱 완료: $currentPrice ($status, ${priceChange}, ${changePercent}%)');
      return {
        'currentPrice': currentPrice,
        'priceChange': priceChange,
        'changePercent': changePercent,
        'status': status,
      };
    } catch (e) {
      print('❌ $containerName 파싱 실패: $e');
      return null;
    }
  }

  // JavaScript에서 NXT 데이터 추출 (안전한 버전)
  static Map<String, dynamic>? _tryParseNxtFromScript(Document document) {
    try {
      print('🔍 JavaScript에서 NXT 데이터 추출 시도');
      final scripts = document.querySelectorAll('script');

      for (final script in scripts) {
        final content = script.text;

        // NXT 관련 키워드가 포함된 스크립트 찾기
        if (content.contains('nxtPrice') ||
            content.contains('timeOffPrice') ||
            content.contains('timeOff')) {

          // 숫자 패턴들을 순서대로 시도
          final numberPatterns = [
            '(\\d{4,})', // 4자리 이상
            '(\\d{3,})', // 3자리 이상
          ];

          for (final pattern in numberPatterns) {
            try {
              final matches = RegExp(pattern).allMatches(content);
              for (final match in matches) {
                final priceStr = match.group(1);
                if (priceStr != null) {
                  final price = int.tryParse(priceStr) ?? 0;
                  // 주가 범위로 보이는 숫자만 선택 (1000원 ~ 1000000원)
                  if (price >= 1000 && price <= 1000000) {
                    print('✅ JavaScript에서 가격 후보 발견: $price');
                    return {
                      'currentPrice': price,
                      'priceChange': 0,
                      'changePercent': 0.0,
                      'status': '보합',
                    };
                  }
                }
              }
            } catch (regexError) {
              continue;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ JavaScript 파싱 실패: $e');
      return null;
    }
  }

// 시장 시간을 확장하여 NXT 포함
  static bool isMarketTime() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // 주말 제외
    if (weekday == 6 || weekday == 7) return false;

    // 평일 8:00 ~ 20:00 (NXT 데이터 추적을 위해 확장)
    final hour = now.hour;
    return hour >= 8 && hour < 20;
  }

// 캐시 정책도 NXT 우선에 맞게 조정
  static Duration getCacheValidDuration() {
    final now = DateTime.now();
    final hour = now.hour;

    // 정규 시장 시간 (9:00-15:30): 30초 캐시
    if (hour >= 9 && hour < 16) {
      return const Duration(seconds: 30);
    }

    // NXT 시간대나 기타 시간: 1분 캐시
    if (hour >= 8 && hour < 20) {
      return const Duration(minutes: 1);
    }

    // 완전 장외 시간: 1시간 캐시
    return const Duration(hours: 1);
  }
}