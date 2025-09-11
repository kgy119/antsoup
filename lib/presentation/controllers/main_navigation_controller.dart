import 'package:get/get.dart';

import '../pages/stock/stock_controller.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;

    // 종목 탭(인덱스 1)으로 이동할 때
    if (index == 1 && previousIndex != 1) {
      _loadStockScreenData();
    }
  }

  void _loadStockScreenData() {
    // StockController가 등록되어 있다면 전체 종목 로드
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<StockController>()) {
        final stockController = Get.find<StockController>();

        // arguments가 있는지 확인 (홈에서 검색어와 함께 온 경우)
        final args = Get.arguments as Map<String, dynamic>?;
        if (args != null && args['searchKeyword'] != null) {
          final keyword = args['searchKeyword'] as String;
          print('MainNavigation - 검색어와 함께 이동: $keyword');
          // arguments는 StockController의 onInit에서 처리됨
        } else {
          // 일반적인 탭 전환인 경우
          if (!stockController.hasSearched.value &&
              !stockController.showAllStocks.value &&
              stockController.allStocks.isEmpty) {
            stockController.loadAllStocks();
          }
        }
      }
    });
  }
}