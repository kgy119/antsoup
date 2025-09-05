import 'package:get/get.dart';
import 'watchlist_controller.dart';

class WatchlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchlistController>(() => WatchlistController());
  }
}