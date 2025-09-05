import 'package:get/get.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/home_binding.dart';
import '../../presentation/pages/community/community_page.dart';
import '../../presentation/pages/community/community_binding.dart';
import '../../presentation/pages/chart/chart_page.dart';
import '../../presentation/pages/chart/chart_binding.dart';
import '../../presentation/pages/stock/stock_binding.dart';
import '../../presentation/pages/stock/stock_page.dart';
import '../../presentation/pages/stock_detail/stock_detail_page.dart';
import '../../presentation/pages/stock_detail/stock_detail_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.stock,
      page: () => const StockPage(),
      binding: StockBinding(),
    ),
    GetPage(
      name: Routes.stockDetail,
      page: () => const StockDetailPage(),
      binding: StockDetailBinding(),
    ),
    GetPage(
      name: Routes.community,
      page: () => const CommunityPage(),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: Routes.chart,
      page: () => const ChartPage(),
      binding: ChartBinding(),
    ),
  ];
}