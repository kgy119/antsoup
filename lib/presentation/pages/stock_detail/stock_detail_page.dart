import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../widgets/common/common_widgets.dart';
import 'stock_detail_controller.dart';

class StockDetailPage extends GetView<StockDetailController> {
  const StockDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.stockDetail.value?.name ?? '종목 상세',
          style: AppTextStyles.headline6,
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isWatchlisted.value
                  ? Icons.star
                  : Icons.star_border,
              color: controller.isWatchlisted.value
                  ? AppColors.warning
                  : null,
            ),
            onPressed: controller.toggleWatchlist,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '종목 정보를 불러오는 중...');
        }

        final stock = controller.stockDetail.value;
        if (stock == null) {
          return const Center(child: Text('종목 정보를 찾을 수 없습니다.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // 주가 정보
              _buildPriceSection(stock),

              // 기간 선택
              _buildPeriodSelector(),

              // 차트
              _buildChart(),

              // 종목 정보
              _buildStockInfo(stock),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPriceSection(stock) {
    final changeColor = stock.isUp ? AppColors.stockUp : AppColors.stockDown;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      color: Theme.of(Get.context!).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.code,
            style: AppTextStyles.caption,
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.formattedPrice,
                style: AppTextStyles.headline3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        stock.isUp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: changeColor,
                        size: 16.sp,
                      ),
                      Text(
                        '${stock.changeAmount > 0 ? '+' : ''}${stock.changeAmount}',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${stock.changePercent > 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.periods.length,
        itemBuilder: (context, index) {
          final period = controller.periods[index];
          return Obx(() => Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(period),
              selected: controller.selectedPeriod.value == period,
              onSelected: (selected) {
                if (selected) controller.changePeriod(period);
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              labelStyle: AppTextStyles.bodyText2.copyWith(
                color: controller.selectedPeriod.value == period
                    ? Theme.of(context).colorScheme.primary
                    : null,
                fontWeight: controller.selectedPeriod.value == period
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ));
        },
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 400.h,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final stock = controller.stockDetail.value;
        if (stock == null) return const SizedBox.shrink();

        return Column(
          children: [
            // 범례
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('주가', AppColors.lightPrimary),
                SizedBox(width: 20.w),
                _buildLegendItem('개미탕 지수', AppColors.stockUp),
              ],
            ),
            SizedBox(height: 16.h),
            // 차트
            Expanded(
              child: LineChart(
                _buildLineChartData(stock),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 3.h,
          color: color,
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(stock) {
    final priceSpots = stock.priceHistory.asMap().entries.map<FlSpot>((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final antSoupSpots = stock.antSoupIndex.asMap().entries.map<FlSpot>((entry) {
      // 개미탕 지수를 주가 범위에 맞게 스케일링
      final minPrice = stock.priceHistory.map((e) => e.value).reduce((a, b) => a < b ? a : b);
      final maxPrice = stock.priceHistory.map((e) => e.value).reduce((a, b) => a > b ? a : b);
      final scaledValue = minPrice + (entry.value.value / 100) * (maxPrice - minPrice);
      return FlSpot(entry.key.toDouble(), scaledValue);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: null,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.grey200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60.w,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toStringAsFixed(0)}K',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey600,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.h,
            interval: (priceSpots.length / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= stock.priceHistory.length) return const SizedBox.shrink();

              final date = stock.priceHistory[value.toInt()].date;
              return Text(
                '${date.month}/${date.day}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey600,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // 주가 라인
        LineChartBarData(
          spots: priceSpots,
          isCurved: true,
          gradient: LinearGradient(colors: [
            AppColors.lightPrimary,
            AppColors.lightPrimary.withOpacity(0.8),
          ]),
          barWidth: 3.w,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lightPrimary.withOpacity(0.1),
                AppColors.lightPrimary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        // 개미탕 지수 라인
        LineChartBarData(
          spots: antSoupSpots,
          isCurved: true,
          gradient: LinearGradient(colors: [
            AppColors.stockUp,
            AppColors.stockUp.withOpacity(0.8),
          ]),
          barWidth: 2.w,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5], // 점선 스타일
        ),
      ],
    );
  }

  Widget _buildStockInfo(stock) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '종목 정보',
            style: AppTextStyles.headline6,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('거래량', stock.formattedVolume),
          _buildInfoRow('시가총액', stock.formattedMarketCap),
          _buildInfoRow('PER', '${stock.per}배'),
          _buildInfoRow('PBR', '${stock.pbr}배'),
          SizedBox(height: 20.h),
          Text(
            '개미탕 지수란?',
            style: AppTextStyles.bodyText2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '개미탕 지수는 해당 종목에 대한 개인투자자들의 관심도와 시장 심리를 나타내는 지표입니다. 0에 가까울수록 매수 심리가 강하고, 100에 가까울수록 매도 심리가 강함을 의미합니다.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyText2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}