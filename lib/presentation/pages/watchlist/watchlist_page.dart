import 'package:antsoup/presentation/pages/watchlist/watchlist_controller.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../widgets/common/common_widgets.dart';

class WatchlistPage extends GetView<WatchlistController> {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '관심종목',
        actions: [
          Obx(() => controller.totalStocks > 0
              ? IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshWatchlist,
          )
              : const SizedBox.shrink()),
          Obx(() => controller.totalStocks > 0
              ? PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('전체 삭제'),
              ),
            ],
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '관심종목을 불러오는 중...');
        }

        if (controller.hasError.value) {
          return ErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadWatchlist,
          );
        }

        if (controller.isEmpty) {
          return const EmptyWidget(
            message: '등록된 관심종목이 없습니다.',
            icon: Icons.star_border,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshWatchlist,
          child: CustomScrollView(
            slivers: [
              // 발견된 종목들
              if (controller.watchlistStocks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      '관심종목 (${controller.watchlistStocks.length}개)',
                      style: AppTextStyles.headline6,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final stock = controller.watchlistStocks[index];
                      return Dismissible(
                        key: Key(stock.code),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          controller.removeStock(stock.code);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.w),
                          color: AppColors.error,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        child: StockCard(
                          stockName: stock.name,
                          stockCode: stock.code,
                          currentPrice: stock.formattedPrice,
                          priceChangePercent: stock.formattedChangePercent,
                          asiWithChange1: stock.formattedAsiWithChange1,  // 직전 대비
                          asiWithChange3: stock.formattedAsiWithChange3,  // 3번째전 대비
                          asiWithChange7: stock.formattedAsiWithChange7,  // 7번째전 대비
                          isUp: stock.isUp,
                          isAsiUp1: stock.isAsiUp1,  // 직전 대비 증감
                          isAsiUp3: stock.isAsiUp3,  // 3번째전 대비 증감
                          isAsiUp7: stock.isAsiUp7,  // 7번째전 대비 증감
                          onTap: () => controller.goToStockDetail(stock.code),
                        ),
                      );
                    },
                    childCount: controller.watchlistStocks.length,

                  ),
                ),
              ],

              // 찾지 못한 종목들
              if (controller.notFoundStocks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      '데이터 없음 (${controller.notFoundStocks.length}개)',
                      style: AppTextStyles.headline6.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final code = controller.notFoundStocks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_outlined,
                            color: AppColors.warning,
                          ),
                          title: Text(
                            code,
                            style: AppTextStyles.bodyText1,
                          ),
                          subtitle: Text(
                            '데이터를 찾을 수 없습니다',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.grey600,
                            ),
                            onPressed: () => controller.removeStock(code),
                          ),
                        ),
                      );
                    },
                    childCount: controller.notFoundStocks.length,
                  ),
                ),
              ],

              // 하단 여백
              SliverToBoxAdapter(
                child: SizedBox(height: 20.h),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showClearDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 관심종목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearAllWatchlist();
            },
            child: Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}