import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/enums.dart';
import '../../controllers/stock_list_controller.dart';
import '../../widgets/common/sort_dropdown.dart';
import '../../widgets/stock/antsoup_stock_card.dart'; // 수정된 import

class StockListPage extends GetView<StockListController> {
  const StockListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          '전체 종목',
          style: AppTextStyles.headline6.copyWith(
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 정렬 옵션 헤더
          Container(
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
                Obx(() => SortDropdown(
                  selectedSort: controller.currentSort.value,
                  onSortChanged: controller.changeSortType,
                )),
              ],
            ),
          ),

          // 구분선
          Container(
            height: 1,
            color: isDark ? AppColors.grey700 : AppColors.grey200,
          ),

          // 종목 리스트
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.stocks.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.stocks.isEmpty) {
                return Center(
                  child: Text(
                    '종목 데이터가 없습니다',
                    style: AppTextStyles.bodyText1.copyWith(
                      color: isDark ? Colors.white70 : AppColors.grey600,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshStocks,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: controller.stocks.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.stocks.length) {
                      // 로딩 인디케이터 또는 완료 메시지
                      if (controller.isLoading.value) {
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

                    final stock = controller.stocks[index];
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
            }),
          ),
        ],
      ),
    );
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