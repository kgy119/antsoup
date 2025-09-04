import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/stock_model.dart';
import '../models/market_index_model.dart';
import '../models/stock_detail_model.dart';

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
      final response = await _apiService.get(
        '/stocks/detail.php',
        queryParameters: {
          'code': stockCode,
          'period': period,
        },
      );

      if (response.data['success'] == true) {
        return StockDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '종목 상세 정보 조회 실패');
      }
    } catch (e) {
      print('종목 상세 정보 조회 실패: $e');
      return null; // null 반환
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
}