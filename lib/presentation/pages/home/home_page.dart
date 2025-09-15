import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/stock/antsoup_stock_card.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.unfocusSearch();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // 앱바
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          '개미탕',
                          style: AppTextStyles.headline4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: controller.goToNotifications,
                        ),
                        // 테마 토글 버튼을 GetBuilder로 변경
                        GetBuilder<HomeController>(
                          id: 'themeMode',
                          builder: (controller) => IconButton(
                            icon: Icon(
                              controller.isDarkMode.value
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            onPressed: controller.toggleTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 검색바
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CustomSearchBar(
                      hintText: '종목명, 종목코드를 검색하세요',
                      onSubmitted: (value) => controller.onSearchSubmitted(),
                      controller: controller.searchController,
                      focusNode: controller.searchFocusNode,
                    ),
                  ),
                ),

                // 로딩 상태 표시
                GetBuilder<HomeController>(
                  id: 'loading',
                  builder: (controller) {
                    if (controller.isLoading.value) {
                      return SliverToBoxAdapter(
                        child: Container(
                          height: 200.h,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // 에러 상태 표시
                GetBuilder<HomeController>(
                  id: 'error',
                  builder: (controller) {
                    if (controller.hasError.value) {
                      return SliverToBoxAdapter(
                        child: Container(
                          height: 200.h,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: AppColors.error,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.bodyText1,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: controller.refreshData,
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // 식어가는 개미탕 섹션
                _buildSectionHeader(
                  '식어가는 개미탕 🧊',
                  '더보기',
                      () {
                    // 더보기 액션
                  },
                ),
                _buildColdAntSoupList(),

                // 냉탕온탕 개미탕 섹션
                _buildSectionHeader(
                  '냉탕온탕 개미탕 🌊',
                  '더보기',
                      () {
                    // 더보기 액션
                  },
                ),
                _buildMixedAntSoupList(),

                // 펄펄끓는 개미탕 섹션
                _buildSectionHeader(
                  '펄펄끓는 개미탕 🔥',
                  '더보기',
                      () {
                    // 더보기 액션
                  },
                ),
                _buildHotAntSoupList(),

                // 하단 여백
                SliverToBoxAdapter(
                  child: SizedBox(height: 20.h),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback? onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (actionText.isNotEmpty && onTap != null)
              GestureDetector(
                onTap: onTap,
                child: Text(
                  actionText,
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 펄펄끓는 개미탕 리스트 - GetBuilder로 변경
  Widget _buildHotAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'hotAntSoupStocks',
      builder: (controller) {
        if (controller.hotAntSoupStocks.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 100.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final stock = controller.hotAntSoupStocks[index];
              return AntSoupStockCard(
                stockName: stock.name,
                stockCode: stock.code,
                currentPrice: stock.formattedPrice,
                priceChangePercent: stock.formattedChangePercent,
                asi5Avg: stock.formattedAsi5Avg,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                statusLabel: stock.heatStatus,
                statusColor: _getHeatStatusColor(stock.heatStatus),
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.hotAntSoupStocks.length,
          ),
        );
      },
    );
  }

  // 식어가는 개미탕 리스트 - GetBuilder로 변경
  Widget _buildColdAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'coldAntSoupStocks',
      builder: (controller) {
        if (controller.coldAntSoupStocks.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 100.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final stock = controller.coldAntSoupStocks[index];
              return AntSoupStockCard(
                stockName: stock.name,
                stockCode: stock.code,
                currentPrice: stock.formattedPrice,
                priceChangePercent: stock.formattedChangePercent,
                asi5Avg: stock.formattedAsi5Avg,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                statusLabel: stock.coldStatus,
                statusColor: _getColdStatusColor(stock.coldStatus),
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.coldAntSoupStocks.length,
          ),
        );
      },
    );
  }

  // 냉탕온탕 개미탕 리스트 - GetBuilder로 변경
  Widget _buildMixedAntSoupList() {
    return GetBuilder<HomeController>(
      id: 'mixedAntSoupStocks',
      builder: (controller) {
        if (controller.mixedAntSoupStocks.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 100.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: Text(
                  '데이터가 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final stock = controller.mixedAntSoupStocks[index];
              return AntSoupStockCard(
                stockName: stock.name,
                stockCode: stock.code,
                currentPrice: stock.formattedPrice,
                priceChangePercent: stock.formattedChangePercent,
                asi5Avg: stock.formattedAsi5Avg,
                asiWithChange1: stock.formattedAsiWithChange1,
                asiWithChange3: stock.formattedAsiWithChange3,
                asiWithChange7: stock.formattedAsiWithChange7,
                isUp: stock.isUp,
                isAsiUp1: stock.isAsiUp1,
                isAsiUp3: stock.isAsiUp3,
                isAsiUp7: stock.isAsiUp7,
                statusLabel: null, // 냉탕온탕은 특별한 상태 라벨이 없음
                statusColor: null,
                onTap: () => controller.goToStockDetail(stock.code),
              );
            },
            childCount: controller.mixedAntSoupStocks.length,
          ),
        );
      },
    );
  }

  // 가열 상태 색상
  Color? _getHeatStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '사골육수':
        return Colors.red[700];
      case '가열중':
        return Colors.orange[700];
      default:
        return null;
    }
  }

  // 냉각 상태 색상
  Color? _getColdStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '냉동보관':
        return Colors.blue[700];
      case '냉각중':
        return Colors.cyan[700];
      default:
        return null;
    }
  }
}