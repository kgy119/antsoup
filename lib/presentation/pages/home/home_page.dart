import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
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
                        IconButton(
                          icon: Obx(() => Icon(
                            controller.isDarkMode.value
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          )),
                          onPressed: controller.toggleTheme,
                        ),
                      ],
                    ),
                  ),
                ),

                // 검색바
                SliverToBoxAdapter(
                  child: CustomSearchBar(
                    hintText: '종목명, 종목코드를 검색하세요',
                    onChanged: controller.onSearchChanged,
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    onSubmitted: controller.onSearchSubmitted, // 검색 제출 시 콜백 변경
                  ),
                ),

                // 인기 종목 섹션
                SliverToBoxAdapter(
                  child: _buildSectionHeader('🔥 인기 종목', '더보기'),
                ),

                // 인기 종목 리스트
                Obx(() {
                  if (controller.isLoading.value) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.h,
                        child: const LoadingWidget(message: '인기 종목을 불러오는 중...'),
                      ),
                    );
                  }

                  if (controller.popularStocks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.h,
                        child: const EmptyWidget(
                          message: '인기 종목 데이터가 없습니다.',
                          icon: Icons.trending_up_outlined,
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final stock = controller.popularStocks[index];
                        return StockCard(
                          stockName: stock.name,
                          stockCode: stock.code,
                          currentPrice: stock.formattedPrice,
                          priceChangePercent: stock.formattedChangePercent,
                          currentAsi: stock.formattedCurrentAsi,        // 현재 ASI 추가
                          asiWithChange1: stock.formattedAsiWithChange1,
                          asiWithChange3: stock.formattedAsiWithChange3,
                          asiWithChange7: stock.formattedAsiWithChange7,
                          isUp: stock.isUp,
                          isAsiUp1: stock.isAsiUp1,
                          isAsiUp3: stock.isAsiUp3,
                          isAsiUp7: stock.isAsiUp7,
                          onTap: () => controller.goToStockDetail(stock.code),
                        );
                      },
                      childCount: controller.popularStocks.length,
                    ),
                  );
                }),


                // 개미 관심 종목 섹션
                SliverToBoxAdapter(
                  child: _buildSectionHeader('🐜 개미들의 관심종목', '더보기'),
                ),

                // 개미 관심 종목 리스트
                Obx(() {
                  if (controller.antInterestStocks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.h,
                        child: const EmptyWidget(
                          message: '개미 관심 종목 데이터가 없습니다.',
                          icon: Icons.interests_outlined,
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final stock = controller.antInterestStocks[index];
                        return StockCard(
                          stockName: stock.name,
                          stockCode: stock.code,
                          currentPrice: stock.formattedPrice,
                          priceChangePercent: stock.formattedChangePercent,
                          currentAsi: stock.formattedCurrentAsi,        // 현재 ASI 추가
                          asiWithChange1: stock.formattedAsiWithChange1,
                          asiWithChange3: stock.formattedAsiWithChange3,
                          asiWithChange7: stock.formattedAsiWithChange7,
                          isUp: stock.isUp,
                          isAsiUp1: stock.isAsiUp1,
                          isAsiUp3: stock.isAsiUp3,
                          isAsiUp7: stock.isAsiUp7,
                          onTap: () => controller.goToStockDetail(stock.code),
                        );
                      },
                      childCount: controller.antInterestStocks.length,
                    ),
                  );
                }),

                // 시장 지수 섹션
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.marketIndexes.isEmpty) {
                      return Container(
                        height: 120.h,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const Center(
                          child: Text(
                            '시장 지수 데이터가 없습니다.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return _buildMarketIndexes();
                  }),
                ),

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

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headline6,
          ),
          if (actionText.isNotEmpty)
            GestureDetector(
              onTap: () {
                // 더보기 액션
              },
              child: Text(
                actionText,
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarketIndexes() {
    return Container(
      height: 120.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() => Row(
        children: controller.marketIndexes.map((index) {
          return Expanded(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      index.name,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      index.formattedValue,
                      style: AppTextStyles.bodyText2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index.isUp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: index.isUp ? AppColors.stockUp : AppColors.stockDown,
                          size: 12.sp,
                        ),
                        Text(
                          '${index.formattedChangePercent}%',
                          style: AppTextStyles.caption.copyWith(
                            color: index.isUp ? AppColors.stockUp : AppColors.stockDown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}