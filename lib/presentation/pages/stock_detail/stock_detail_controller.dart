// lib/presentation/pages/stock_detail/stock_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/stock_detail_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/local_storage_provider.dart';
import '../watchlist/watchlist_controller.dart';

class StockDetailController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorageProvider _localStorage = Get.find<LocalStorageProvider>();

  final isLoading = true.obs;
  final stockDetail = Rx<StockDetailModel?>(null);
  final selectedPeriod = '1개월'.obs;
  final isWatchlisted = false.obs;

  String get stockCode {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['code'] ?? args?['stockCode'] ?? '005930';
  }

  final List<String> periods = ['1일', '1주', '1개월', '3개월', '6개월', '1년'];

  @override
  void onInit() {
    super.onInit();
    loadStockDetail();
    _checkWatchlistStatus();
  }

  void _checkWatchlistStatus() {
    final localStorage = Get.find<LocalStorageProvider>();
    isWatchlisted.value = localStorage.isInWatchlist(stockCode);
  }

  Future<void> loadStockDetail() async {
    isLoading.value = true;
    try {
      print('종목 상세 정보 로드 시작: $stockCode, 기간: ${selectedPeriod.value}');

      final detail = await _apiProvider.getStockDetail(
        stockCode,
        period: selectedPeriod.value,
      );

      if (detail != null) {
        stockDetail.value = detail;
        print('종목 상세 정보 로드 성공: ${detail.name}');
        print('가격 히스토리: ${detail.priceHistory.length}개');
        print('ASI 히스토리: ${detail.antSoupIndex.length}개');
      } else {
        throw Exception('서버에서 데이터를 받지 못했습니다.');
      }

    } catch (e) {
      print('종목 상세 정보 로딩 실패: $e');
      stockDetail.value = null;

      Get.snackbar(
        '오류',
        '종목 정보를 불러오는데 실패했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[700],
        icon: const Icon(Icons.error, color: Colors.red),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePeriod(String period) async {
    if (selectedPeriod.value == period) return;

    selectedPeriod.value = period;
    print('기간 변경: $period');

    // 새로운 기간으로 데이터 다시 로드
    await loadStockDetail();
  }

  void toggleWatchlist() {
    final newState = !isWatchlisted.value;
    isWatchlisted.value = newState;

    if (newState) {
      _addToWatchlist();
    } else {
      _removeFromWatchlist();
    }
  }

  Future<void> _addToWatchlist() async {
    try {
      final localStorage = Get.find<LocalStorageProvider>();
      await localStorage.addToWatchlist(stockCode);

      if (Get.isRegistered<WatchlistController>()) {
        await Get.find<WatchlistController>().loadWatchlist();
      }

      Get.snackbar(
        '완료',
        '관심종목에 추가되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[700],
        icon: const Icon(Icons.star, color: Colors.green),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('관심종목 추가 실패: $e');
      isWatchlisted.value = false;
      Get.snackbar(
        '오류',
        '관심종목 추가에 실패했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[700],
        icon: const Icon(Icons.error, color: Colors.red),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _removeFromWatchlist() async {
    try {
      final localStorage = Get.find<LocalStorageProvider>();
      await localStorage.removeFromWatchlist(stockCode);

      if (Get.isRegistered<WatchlistController>()) {
        await Get.find<WatchlistController>().loadWatchlist();
      }

      Get.snackbar(
        '완료',
        '관심종목에서 제거되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[700],
        icon: const Icon(Icons.star_border, color: Colors.orange),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('관심종목 제거 실패: $e');
      isWatchlisted.value = true;
      Get.snackbar(
        '오류',
        '관심종목 제거에 실패했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[700],
        icon: const Icon(Icons.error, color: Colors.red),
        margin: EdgeInsets.all(16.w),
        borderRadius: 8.r,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void goBack() {
    Get.back();
  }
}