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
          title: '종목 검색',
          actions: [
            Obx(() => controller.hasSearched.value
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
              onSubmitted: controller.onSearchSubmitted,
            ),

            // 검색 결과 또는 최근 검색어
            Expanded(
              child: Obx(() {
                print('Obx 리빌드 - isLoading: ${controller.isLoading.value}, hasSearched: ${controller.hasSearched.value}');
                print('searchResults 길이: ${controller.searchResults.length}');
                print('recentSearches 길이: ${controller.recentSearches.length}');

                if (controller.isLoading.value) {
                  return const LoadingWidget(message: '검색 중...');
                }

                if (controller.hasSearched.value) {
                  return _buildSearchResults();
                } else {
                  return _buildRecentSearches();
                }
              }),
            ),
          ],
        ),
      ),
    );
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