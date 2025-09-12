import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/enums.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/sort_dropdown.dart';
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
        appBar: AppBar(
          title: Text(
            '종목',
            style: AppTextStyles.headline6.copyWith(
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            Obx(() => controller.hasSearched.value
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearSearch,
            )
                : const SizedBox.shrink()),
          ],
        ),
        body: SafeArea(
          bottom: true, // 하단 보호 활성화
          child: Column(
            children: [
              // 검색바 (기존과 동일)
              Container(
                padding: EdgeInsets.all(16.w),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: CustomSearchBar(
                  hintText: '종목명, 종목코드를 검색하세요',
                  onChanged: controller.onSearchChanged,
                  controller: controller.searchController,
                  focusNode: controller.searchFocusNode,
                  onSubmitted: (value) => controller.onSearchSubmitted(value),
                ),
              ),

              // 정렬 옵션 (기존과 동일)
              Obx(() => !controller.hasSearched.value
                  ? Container(
                padding: EdgeInsets.all(16.w),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '정렬',
                      style: AppTextStyles.bodyText1.copyWith(
                        color: isDark ? Colors.white70 : AppColors.grey700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SortDropdown(
                      selectedSort: controller.currentSort.value,
                      onSortChanged: controller.changeSortType,
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink()),

              // 구분선
              Container(
                height: 1,
                color: isDark ? AppColors.grey700 : AppColors.grey200,
              ),

              // 컨텐츠 영역 - 하단 여백 추가
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h), // 하단 여백 추가
                  child: Obx(() {
                    // 로딩 상태
                    if (controller.isLoading.value) {
                      return const LoadingWidget(message: '검색 중...');
                    }

                    if (controller.isLoadingAll.value && controller.allStocks.isEmpty) {
                      return const LoadingWidget(message: '종목 목록을 불러오는 중...');
                    }

                    // 검색 결과 표시
                    if (controller.hasSearched.value) {
                      return _buildSearchResults(isDark);
                    }

                    // 전체 종목 표시
                    if (controller.showAllStocks.value || controller.allStocks.isNotEmpty) {
                      return _buildAllStocksList(isDark);
                    }

                    // 초기 상태
                    return _buildInitialState();
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 결과 위젯
  Widget _buildSearchResults(bool isDark) {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return EmptyWidget(
          message: '"${controller.currentKeyword.value}"에 대한 검색 결과가 없습니다.',
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

          // 검색 결과 리스트
          Expanded(
            child: ListView.separated(
              itemCount: controller.searchResults.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: isDark ? AppColors.grey700 : AppColors.grey200,
              ),
              itemBuilder: (context, index) {
                final stock = controller.searchResults[index];
                return StockListItem(
                  stock: stock,
                  onTap: () => controller.goToStockDetail(stock.code),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // 전체 종목 리스트 위젯
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
        child: ListView.separated(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: controller.allStocks.length +
              (controller.hasMoreData.value ? 1 : 0),
          separatorBuilder: (context, index) => Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            color: isDark ? AppColors.grey700 : AppColors.grey200,
          ),
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
            return StockListItem(
              stock: stock,
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
}