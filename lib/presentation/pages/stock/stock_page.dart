import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/sort_dropdown.dart';
import '../../widgets/stock/antsoup_stock_card.dart';
import '../../widgets/stock/stock_list_item.dart';
import 'stock_controller.dart';

class StockPage extends GetView<StockController> {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.unfocusSearch();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        // AppBar 완전 제거
        body: SafeArea(
          bottom: true,
          child: Column(
            children: [
              // 검색바와 정렬을 한 줄로 배치
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: Row(
                  children: [
                    // 검색바 (확장) - margin 없이 사용
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 40.h, // 높이 명시적 지정
                        child: CustomSearchBar(
                          hintText: '종목명, 종목코드 검색',
                          onChanged: controller.onSearchChanged,
                          controller: controller.searchController,
                          focusNode: controller.searchFocusNode,
                          onSubmitted: (value) => controller.onSearchSubmitted(value),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // 검색 결과가 있을 때 클리어 버튼
                    Obx(() => controller.hasSearched.value
                        ? GestureDetector(
                      onTap: controller.clearSearch,
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.clear,
                          size: 18.sp,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    )
                        : const SizedBox.shrink()),

                    // 검색 결과가 없을 때만 정렬 옵션 표시
                    Obx(() => !controller.hasSearched.value
                        ? Container(
                      margin: EdgeInsets.only(left: 12.w),
                      height: 40.h,
                      child: SortDropdown(
                        selectedSort: controller.currentSort.value,
                        onSortChanged: controller.changeSortType,
                      ),
                    )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),


              // 구분선
              Container(
                height: 1,
                color: isDark ? AppColors.grey700 : AppColors.grey200,
              ),

              // 나머지 콘텐츠는 기존과 동일
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.hasSearched.value) {
                    return _buildSearchResults(isDark);
                  }

                  return _buildAllStocksList(isDark);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 결과 위젯
  // _buildSearchResults 메서드 수정
  Widget _buildSearchResults(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.searchResults.isEmpty) {
        return EmptyWidget(
          message: controller.currentKeyword.value.isEmpty
              ? '검색어를 입력해주세요'
              : '"${controller.currentKeyword.value}" 검색 결과가 없습니다',
          icon: Icons.search_off,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 결과 헤더
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              '검색 결과 (${controller.searchResults.length}개)',
              style: AppTextStyles.headline6.copyWith(
                color: isDark ? Colors.white : AppColors.grey900,
              ),
            ),
          ),

          // 검색 결과 리스트 (AntSoupStockCard 사용)
          Expanded(
            child: ListView.builder(
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final stock = controller.searchResults[index];
                return AntSoupStockCard(
                  stockName: stock.name,
                  stockCode: stock.code,
                  currentPrice: stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
                  priceChangeAmount: stock.formattedDisplayChangeAmount,
                  priceChangePercent: stock.formattedDisplayChangePercent,
                  asi5Avg: stock.formattedCurrentAsi,
                  asiWithChange1: stock.formattedAsiWithChange1,
                  asiWithChange3: stock.formattedAsiWithChange3,
                  asiWithChange7: stock.formattedAsiWithChange7,
                  isUp: stock.hasNaverData ? stock.isDisplayUp : stock.isUp,
                  isAsiUp1: stock.isAsiUp1,
                  isAsiUp3: stock.isAsiUp3,
                  isAsiUp7: stock.isAsiUp7,
                  hasLiveData: stock.hasNaverData,
                  statusLabel: stock.heatStatus ?? stock.coldStatus, // 상태 라벨 추가
                  statusColor: _getStatusColor(stock.heatStatus, stock.coldStatus), // 상태 색상 추가
                  onTap: () => controller.goToStockDetail(stock.code),
                );
              },
            ),
          ),
        ],
      );
    });
  }

// _buildAllStocksList 메서드 수정
  Widget _buildAllStocksList(bool isDark) {
    return Obx(() {
      if (controller.allStocks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 64.sp,
                color: AppColors.grey400,
              ),
              SizedBox(height: 16.h),
              Text(
                '종목 데이터가 없습니다',
                style: AppTextStyles.bodyText1.copyWith(
                  color: isDark ? Colors.white70 : AppColors.grey600,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: controller.loadAllStocks,
                child: const Text('다시 불러오기'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAllStocks,
        child: ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: controller.allStocks.length +
              (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.allStocks.length) {
              // 로딩 인디케이터
              if (controller.isLoadingMore.value) {
                return Container(
                  padding: EdgeInsets.all(16.h),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(16.h),
                  alignment: Alignment.center,
                  child: Text(
                    '모든 종목을 불러왔습니다',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                );
              }
            }

            final stock = controller.allStocks[index];
            return AntSoupStockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
              priceChangeAmount: stock.formattedDisplayChangeAmount,
              priceChangePercent: stock.formattedDisplayChangePercent,
              asi5Avg: stock.formattedCurrentAsi,
              asiWithChange1: stock.formattedAsiWithChange1,
              asiWithChange3: stock.formattedAsiWithChange3,
              asiWithChange7: stock.formattedAsiWithChange7,
              isUp: stock.hasNaverData ? stock.isDisplayUp : stock.isUp,
              isAsiUp1: stock.isAsiUp1,
              isAsiUp3: stock.isAsiUp3,
              isAsiUp7: stock.isAsiUp7,
              hasLiveData: stock.hasNaverData,
              statusLabel: stock.heatStatus ?? stock.coldStatus, // 상태 라벨 추가
              statusColor: _getStatusColor(stock.heatStatus, stock.coldStatus), // 상태 색상 추가
              onTap: () => controller.goToStockDetail(stock.code),
            );
          },
        ),
      );
    });
  }

  // 초기 상태 위젯
  Widget _buildInitialState() {
    return Obx(() {
      // 최근 검색어가 있으면 표시
      if (controller.recentSearches.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최근 검색어 헤더
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근 검색어',
                    style: AppTextStyles.headline6,
                  ),
                  TextButton(
                    onPressed: controller.clearRecentSearches,
                    child: Text(
                      '전체 삭제',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 최근 검색어 리스트
            Expanded(
              child: ListView.builder(
                itemCount: controller.recentSearches.length,
                itemBuilder: (context, index) {
                  final keyword = controller.recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: AppColors.grey500),
                    title: Text(keyword),
                    onTap: () => controller.searchFromRecent(keyword),
                  );
                },
              ),
            ),

            // 하단에 전체 종목 보기 버튼
            Container(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.loadAllStocks,
                  child: const Text('전체 종목 보기'),
                ),
              ),
            ),
          ],
        );
      }

      // 최근 검색어도 없으면 전체 종목 로드 유도
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              '종목을 검색하거나\n전체 종목을 확인해보세요',
              style: AppTextStyles.bodyText1.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.loadAllStocks,
              child: const Text('전체 종목 보기'),
            ),
          ],
        ),
      );
    });
  }

  // 상태에 따른 색상 반환 (가열/냉각 상태)
  Color? _getStatusColor(String? heatStatus, String? coldStatus) {
    if (heatStatus != null) {
      switch (heatStatus) {
        case '사골육수':
          return Colors.red[700];
        case '가열중':
          return Colors.orange[700];
        default:
          return null;
      }
    }

    if (coldStatus != null) {
      switch (coldStatus) {
        case '냉동보관':
          return Colors.blue[700];
        case '냉각중':
          return Colors.cyan[700];
        default:
          return null;
      }
    }

    return null;
  }
}