import 'package:get/get.dart';

import '../pages/stock/stock_controller.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;

    // 종목 탭(인덱스 1)으로 이동할 때 전체 종목 로드
    if (index == 1 && previousIndex != 1) {
      _loadStockScreenData();
    }
  }

  void _loadStockScreenData() {
    // StockController가 등록되어 있다면 전체 종목 로드
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<StockController>()) {
        final stockController = Get.find<StockController>();
        stockController.loadAllStocks();
      }
    });
  }
}