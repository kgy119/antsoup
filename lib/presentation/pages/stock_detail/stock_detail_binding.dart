import 'package:get/get.dart';
import 'stock_detail_controller.dart';

class StockDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockDetailController>(() => StockDetailController());
  }
}