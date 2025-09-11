import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/search_bar.dart';
import 'stock_controller.dart';

class StockPage extends GetView<StockController> {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('StockPage build 호출됨');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.unfocusSearch();
      },
      child: Scaffold(
        appBar: CommonAppBar(
          title: '종목',
          actions: [
            Obx(() => (controller.hasSearched.value || controller.showAllStocks.value)
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearSearch,
            )
                : const SizedBox.shrink()),
          ],
        ),
        body: Column(
          children: [
            // 검색바
            CustomSearchBar(
              hintText: '종목명, 종목코드를 검색하세요',
              onChanged: controller.onSearchChanged,
              controller: controller.searchController,
              focusNode: controller.searchFocusNode,
              onSubmitted: (value) => controller.onSearchSubmitted(value), // 람다 함수로 감싸기
            ),

            // 컨텐츠 영역
            Expanded(
              child: Obx(() {
                print('Obx 리빌드 - showAllStocks: ${controller.showAllStocks.value}');
                print('hasSearched: ${controller.hasSearched.value}');
                print('isLoadingAll: ${controller.isLoadingAll.value}');
                print('allStocks 개수: ${controller.allStocks.length}');

                // 전체 종목 로딩 중
                if (controller.isLoadingAll.value) {
                  return const LoadingWidget(message: '종목 목록을 불러오는 중...');
                }

                // 검색 로딩 중
                if (controller.isLoading.value) {
                  return const LoadingWidget(message: '검색 중...');
                }

                // 전체 종목 표시
                if (controller.showAllStocks.value) {
                  return _buildAllStocksList();
                }

                // 검색 결과 표시
                if (controller.hasSearched.value) {
                  return _buildSearchResults();
                }

                // 기본 상태 - 전체 종목 로드 유도
                return _buildInitialState();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // 초기 상태 위젯 추가
  Widget _buildInitialState() {
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
  }

  Widget _buildAllStocksList() {
    return Obx(() {
      if (controller.allStocks.isEmpty) {
        return const EmptyWidget(
          message: '종목 데이터가 없습니다.',
          icon: Icons.list_alt,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAllStocks,
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.allStocks.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            // 마지막 항목인 경우 로딩 인디케이터 표시
            if (index == controller.allStocks.length) {
              if (controller.isLoadingMore.value) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Text(
                      '모든 종목을 불러왔습니다.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                );
              }
            }

            final stock = controller.allStocks[index];
            return StockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.formattedPrice,
              priceChangePercent: stock.formattedChangePercent,
              currentAsi: stock.formattedCurrentAsi,
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
        ),
      );
    });
  }


  Widget _buildSearchResults() {
    print('_buildSearchResults 호출됨');
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
              style: AppTextStyles.headline6,
            ),
          ),

          // 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final stock = controller.searchResults[index];
                return StockCard(
                  stockName: stock.name,
                  stockCode: stock.code,
                  currentPrice: stock.formattedPrice,
                  priceChangePercent: stock.formattedChangePercent,
                  currentAsi: stock.formattedCurrentAsi,            // 현재 ASI 추가
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
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecentSearches() {
    print('_buildRecentSearches 호출됨');
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return const EmptyWidget(
          message: '최근 검색어가 없습니다.\n종목명이나 종목코드를 검색해보세요.',
          icon: Icons.history,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최근 검색어 헤더
          Padding(
            padding: EdgeInsets.all(16.w),
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
                    style: AppTextStyles.bodyText2.copyWith(
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
                  leading: const Icon(Icons.history),
                  title: Text(keyword),
                  trailing: const Icon(Icons.north_west),
                  onTap: () => controller.searchFromRecent(keyword),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}