import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/stock_model.dart';
import '../models/market_index_model.dart';

class ApiProvider extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // 인기 종목 조회
  // Future<List<StockModel>> getPopularStocks() async {
  //   try {
  //     final response = await _apiService.get('/stocks/popular');
  //     final List<dynamic> data = response.data['data'];
  //     return data.map((json) => StockModel.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('인기 종목 조회 실패: $e');
  //   }
  // }
  //
  // // 개미 관심 종목 조회
  // Future<List<StockModel>> getAntInterestStocks() async {
  //   try {
  //     final response = await _apiService.get('/stocks/ant-interest');
  //     final List<dynamic> data = response.data['data'];
  //     return data.map((json) => StockModel.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('개미 관심 종목 조회 실패: $e');
  //   }
  // }
  //
  // // 시장 지수 조회
  // Future<List<MarketIndexModel>> getMarketIndexes() async {
  //   try {
  //     final response = await _apiService.get('/market/indexes');
  //     final List<dynamic> data = response.data['data'];
  //     return data.map((json) => MarketIndexModel.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('시장 지수 조회 실패: $e');
  //   }
  // }
  //
  // // 종목 검색
  // Future<List<StockModel>> searchStocks(String keyword) async {
  //   try {
  //     final response = await _apiService.get(
  //       '/stocks/search',
  //       queryParameters: {'keyword': keyword},
  //     );
  //     final List<dynamic> data = response.data['data'];
  //     return data.map((json) => StockModel.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('종목 검색 실패: $e');
  //   }
  // }
  //
  // // 종목 상세 정보 조회
  // Future<StockModel> getStockDetail(String stockCode) async {
  //   try {
  //     final response = await _apiService.get('/stocks/$stockCode');
  //     return StockModel.fromJson(response.data['data']);
  //   } catch (e) {
  //     throw Exception('종목 상세 정보 조회 실패: $e');
  //   }
  // }
  //
  // // FCM 토큰 등록 (디바이스 식별용)
  // Future<void> registerFcmToken(String token, {String? deviceId}) async {
  //   try {
  //     await _apiService.post(
  //       '/notification/register-token',
  //       data: {
  //         'fcm_token': token,
  //         'device_id': deviceId, // 회원가입 없으므로 디바이스 ID로 구분
  //       },
  //     );
  //   } catch (e) {
  //     throw Exception('FCM 토큰 등록 실패: $e');
  //   }
  // }
  //
  // // 관심 종목 추가 (디바이스 ID 기반)
  // Future<void> addToWatchlist(String stockCode, {String? deviceId}) async {
  //   try {
  //     await _apiService.post(
  //       '/watchlist/add',
  //       data: {
  //         'stock_code': stockCode,
  //         'device_id': deviceId,
  //       },
  //     );
  //   } catch (e) {
  //     throw Exception('관심 종목 추가 실패: $e');
  //   }
  // }
  //
  // // 관심 종목 제거 (디바이스 ID 기반)
  // Future<void> removeFromWatchlist(String stockCode, {String? deviceId}) async {
  //   try {
  //     await _apiService.delete(
  //       '/watchlist/$stockCode',
  //       queryParameters: {'device_id': deviceId},
  //     );
  //   } catch (e) {
  //     throw Exception('관심 종목 제거 실패: $e');
  //   }
  // }
}