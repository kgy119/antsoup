import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/constants/enums.dart';
import '../../controllers/stock_list_controller.dart';
import '../../widgets/common/sort_dropdown.dart';
import '../../widgets/stock/stock_list_item.dart';

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
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: controller.stocks.length +
                      (controller.hasMore.value ? 1 : 0),
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    color: isDark ? AppColors.grey700 : AppColors.grey200,
                  ),
                  itemBuilder: (context, index) {
                    if (index == controller.stocks.length) {
                      // 로딩 인디케이터
                      controller.loadStocks();
                      return Container(
                        padding: EdgeInsets.all(16.h),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }

                    final stock = controller.stocks[index];
                    return  StockListItem(stock: stock);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}