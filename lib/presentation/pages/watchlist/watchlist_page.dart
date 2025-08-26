import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/common/common_widgets.dart';
import 'watchlist_controller.dart';

class WatchlistPage extends GetView<WatchlistController> {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '관심종목'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '관심종목을 불러오는 중...');
        }

        if (controller.watchlistStocks.isEmpty) {
          return const EmptyWidget(
            message: '관심종목이 없습니다.\n종목 상세페이지에서 ⭐를 눌러 추가해보세요.',
            icon: Icons.star_border,
          );
        }

        return ListView.builder(
          itemCount: controller.watchlistStocks.length,
          itemBuilder: (context, index) {
            final stock = controller.watchlistStocks[index];
            return StockCard(
              stockName: stock.name,
              stockCode: stock.code,
              currentPrice: stock.formattedPrice,
              changeAmount: stock.formattedChangeAmount,
              changePercent: stock.formattedChangePercent,
              isUp: stock.isUp,
              onTap: () => controller.goToStockDetail(stock.code),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refreshWatchlist,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}