import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../controllers/main_navigation_controller.dart';
import '../../pages/home/home_page.dart';
import '../../pages/community/community_page.dart';
import '../../pages/chart/chart_page.dart';
import '../../pages/stock/stock_page.dart';

class MainNavigation extends GetView<MainNavigationController> {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomePage(),
          StockPage(),
          CommunityPage(),
          ChartPage(),
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
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: '차트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      )),
    );
  }
}