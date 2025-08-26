import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../controllers/main_navigation_controller.dart';
import '../../pages/community/community_controller.dart';
import '../../pages/home/home_controller.dart';
import '../../pages/home/home_page.dart';
import '../../pages/home/home_binding.dart';
import '../../pages/community/community_page.dart';
import '../../pages/community/community_binding.dart';
import '../../pages/stock/stock_controller.dart';
import '../../pages/stock/stock_page.dart';
import '../../pages/stock/stock_binding.dart';
import '../../pages/watchlist/watchlist_binding.dart';
import '../../pages/watchlist/watchlist_controller.dart';
import '../../pages/watchlist/watchlist_page.dart';
import '../../../data/providers/local_storage_provider.dart';

class MainNavigation extends GetView<MainNavigationController> {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // 각 페이지의 바인딩을 미리 등록
    _setupBindings();

    // 앱 시작시 저장된 테마 적용
    _applyStoredTheme();

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomePage(),
          StockPage(),
          WatchlistPage(),  // 차트 대신 관심종목
          CommunityPage(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: AppColors.grey500,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: '종목',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: '관심종목',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
        ],
      )),
    );
  }

  void _setupBindings() {
    // 이미 등록되어 있는지 확인 후 등록
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
    if (!Get.isRegistered<StockController>()) {
      StockBinding().dependencies();
    }
    if (!Get.isRegistered<WatchlistController>()) {
      WatchlistBinding().dependencies();
    }
    if (!Get.isRegistered<CommunityController>()) {
      CommunityBinding().dependencies();
    }
  }

  void _applyStoredTheme() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final localStorage = Get.find<LocalStorageProvider>();
        final savedTheme = localStorage.getThemeMode();

        // HomeController가 있다면 동기화
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.isDarkMode.value = savedTheme;
        }

        print('MainNavigation - 저장된 테마 적용: ${savedTheme ? "다크모드" : "라이트모드"}');
      } catch (e) {
        print('MainNavigation - 테마 적용 실패: $e');
      }
    });
  }
}