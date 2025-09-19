import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/stock_model.dart';
import '../models/market_index_model.dart';
import '../models/stock_detail_model.dart';
import '../models/wordcloud_model.dart';

class ApiProvider extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<StockModel>> getPopularStocks() async {
    try {
      final response = await _apiService.get('/stocks/popular.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '인기 종목 조회 실패');
      }
    } catch (e) {
      print('인기 종목 조회 실패: $e');
      return [];
    }
  }

  Future<List<StockModel>> getAntInterestStocks() async {
    try {
      final response = await _apiService.get('/stocks/ant-interest.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '개미 관심 종목 조회 실패');
      }
    } catch (e) {
      print('개미 관심 종목 조회 실패: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getWatchlistStocks(List<String> stockCodes) async {
    try {
      final response = await _apiService.post(
        '/stocks/watchlist.php',
        data: {'stock_codes': stockCodes},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<StockModel> stocks = (data['stocks'] as List)
            .map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
        }))
            .toList();

        return {
          'stocks': stocks,
          'not_found': data['not_found'] ?? [],
          'total_requested': data['total_requested'] ?? 0,
          'total_found': data['total_found'] ?? 0,
        };
      } else {
        throw Exception(response.data['message'] ?? '관심종목 조회 실패');
      }
    } catch (e) {
      print('관심종목 조회 실패: $e');
      return {
        'stocks': <StockModel>[],
        'not_found': stockCodes,
        'total_requested': stockCodes.length,
        'total_found': 0,
      };
    }
  }

  Future<List<StockModel>> searchStocks(String keyword) async {
    try {
      final response = await _apiService.get(
        '/stocks/search.php',
        queryParameters: {'keyword': keyword},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
          // 상태 계산용 필드 추가
          'asi_5_avg': json['asi_5_avg'],
          'asi_plus_days': json['asi_plus_days'],
          'asi_minus_days': json['asi_minus_days'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '종목 검색 실패');
      }
    } catch (e) {
      print('종목 검색 실패: $e');
      return [];
    }
  }

// 시장 지수 조회
  Future<List<MarketIndexModel>> getMarketIndexes() async {
    try {
      final response = await _apiService.get('/market/indexes.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MarketIndexModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? '시장 지수 조회 실패');
      }
    } catch (e) {
      print('시장 지수 조회 실패: $e');
      return []; // 빈 리스트 반환
    }
  }

// 종목 상세 정보 조회
  Future<StockDetailModel?> getStockDetail(String stockCode, {String period = '1개월'}) async {
    try {
      print('종목 상세 조회 시작: $stockCode, 기간: $period');

      final response = await _apiService.get(
        '/stocks/detail.php',
        queryParameters: {
          'code': stockCode,
          'period': period,
        },
      );

      print('종목 상세 응답: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return StockDetailModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? '종목 상세 정보 조회 실패');
      }
    } catch (e) {
      print('종목 상세 정보 조회 실패: $e');
      throw e;  // 에러를 다시 던져서 컨트롤러에서 처리하도록
    }
  }



  // FCM 토큰 등록 (디바이스 식별용)
  Future<void> registerFcmToken(String token, {String? deviceId}) async {
    try {
      await _apiService.post(
        '/notification/register-token.php',
        data: {
          'fcm_token': token,
          'device_id': deviceId,
        },
      );
    } catch (e) {
      throw Exception('FCM 토큰 등록 실패: $e');
    }
  }

  // 관심 종목 추가 (디바이스 ID 기반)
  Future<void> addToWatchlist(String stockCode, {String? deviceId}) async {
    try {
      await _apiService.post(
        '/watchlist/add.php',
        data: {
          'stock_code': stockCode,
          'device_id': deviceId,
        },
      );
    } catch (e) {
      throw Exception('관심 종목 추가 실패: $e');
    }
  }

  // 관심 종목 제거 (디바이스 ID 기반)
  Future<void> removeFromWatchlist(String stockCode, {String? deviceId}) async {
    try {
      await _apiService.delete(
        '/watchlist/remove.php',
        queryParameters: {'stock_code': stockCode, 'device_id': deviceId},
      );
    } catch (e) {
      throw Exception('관심 종목 제거 실패: $e');
    }
  }

  // getAllStocks 메서드 수정
  Future<List<StockModel>> getAllStocks({
    int page = 1,
    int limit = 20,
    String? sortBy = 'asi_desc',
  }) async {
    try {
      print('getAllStocks 호출: page=$page, limit=$limit, sortBy=$sortBy');

      final response = await _apiService.get(
        '/stocks/all.php',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort_by': sortBy,
        },
      );

      print('API 응답 상태: ${response.statusCode}');
      print('API 응답 성공 여부: ${response.data['success']}');

      if (response.data['success'] == true) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final List<dynamic> stocksData = responseData['stocks'] as List<dynamic>;

        print('받은 종목 데이터 개수: ${stocksData.length}');

        if (stocksData.isNotEmpty) {
          print('첫 번째 종목: ${stocksData[0]['code']} - ${stocksData[0]['name']}');
        }

        final stocks = stocksData.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
          // 상태 계산용 필드 추가
          'asi_5_avg': json['asi_5_avg'],
          'asi_plus_days': json['asi_plus_days'],
          'asi_minus_days': json['asi_minus_days'],
        })).toList();

        print('변환된 StockModel 개수: ${stocks.length}');
        return stocks;

      } else {
        throw Exception(response.data['message'] ?? '전체 종목 조회 실패');
      }
    } catch (e) {
      print('전체 종목 조회 실패: $e');
      return [];
    }
  }


  // 펄펄끓는 개미탕 조회
  Future<List<StockModel>> getHotAntSoupStocks() async {
    try {
      final response = await _apiService.get('/stocks/hot-antsoup.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
          // 개미탕 평균 및 연속일
          'asi_5_avg': json['asi_5_avg'],
          'asi_plus_days': json['asi_plus_days'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '펄펄끓는 개미탕 조회 실패');
      }
    } catch (e) {
      print('펄펄끓는 개미탕 조회 실패: $e');
      return [];
    }
  }

// 식어가는 개미탕 조회
  Future<List<StockModel>> getColdAntSoupStocks() async {
    try {
      final response = await _apiService.get('/stocks/cold-antsoup.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
          // 개미탕 평균 및 연속일
          'asi_5_avg': json['asi_5_avg'],
          'asi_minus_days': json['asi_minus_days'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '식어가는 개미탕 조회 실패');
      }
    } catch (e) {
      print('식어가는 개미탕 조회 실패: $e');
      return [];
    }
  }

// 냉탕온탕 개미탕 조회
  Future<List<StockModel>> getMixedAntSoupStocks() async {
    try {
      final response = await _apiService.get('/stocks/mixed-antsoup.php');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StockModel.fromJson({
          'code': json['code'],
          'name': json['name'],
          'close_price': json['close_price'],
          'price_change': json['price_change'],
          'price_change_percent': json['price_change_percent'],
          'current_asi': json['current_asi'],
          // 기간별 ASI 지수값 추가
          'prev_asi_1': json['prev_asi_1'],
          'prev_asi_3': json['prev_asi_3'],
          'prev_asi_7': json['prev_asi_7'],
          // 개미탕 지수 비교 데이터 (변화량/변화율)
          'asi_change_1': json['asi_change_1'],
          'asi_change_percent_1': json['asi_change_percent_1'],
          'asi_change_3': json['asi_change_3'],
          'asi_change_percent_3': json['asi_change_percent_3'],
          'asi_change_7': json['asi_change_7'],
          'asi_change_percent_7': json['asi_change_percent_7'],
          // 개미탕 평균 및 편차
          'asi_5_avg': json['asi_5_avg'],
          'asi_5_diff': json['asi_5_diff'],
        })).toList();
      } else {
        throw Exception(response.data['message'] ?? '냉탕온탕 개미탕 조회 실패');
      }
    } catch (e) {
      print('냉탕온탕 개미탕 조회 실패: $e');
      return [];
    }
  }

  // 단어 클라우드 조회
  Future<WordCloudModel?> getWordCloud(String stockCode) async {
    try {
      print('단어 클라우드 조회 시작: $stockCode');

      final response = await _apiService.get(
        '/wordcloud/get.php',
        queryParameters: {'code': stockCode},
      );

      print('단어 클라우드 응답: ${response.data}');

      if (response.data != null &&
          response.data['success'] == true) {

        if (response.data['data'] != null) {
          return WordCloudModel.fromJson(response.data['data']);
        } else {
          print('단어 클라우드 데이터가 null입니다');
          return null;
        }
      } else {
        print('단어 클라우드 조회 실패: ${response.data['message']}');
        return null;
      }
    } catch (e) {
      print('단어 클라우드 조회 실패: $e');
      return null;
    }
  }
}