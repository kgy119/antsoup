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
        if (stock == null) {
          return const Center(child: Text('데이터를 불러오는 중...'));
        }

        if (stock.priceHistory.isEmpty) {
          return const Center(child: Text('차트 데이터가 없습니다.'));
        }

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
              child: _buildSimpleChart(stock),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSimpleChart(stock) {
    try {
      return LineChart(
        _buildLineChartData(stock),
      );
    } catch (e) {
      print('차트 렌더링 오류: $e');
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64.sp, color: AppColors.grey400),
            SizedBox(height: 16.h),
            Text('차트를 표시할 수 없습니다.', style: AppTextStyles.bodyText2),
            SizedBox(height: 8.h),
            Text('데이터: ${stock.priceHistory.length}개', style: AppTextStyles.caption),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // 차트 다시 그리기 시도
                controller.loadStockDetail();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
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
    print('차트 데이터 생성 시작: ${stock.priceHistory.length}개 데이터');

    if (stock.priceHistory.isEmpty) {
      throw Exception('가격 데이터가 없습니다');
    }

    // 가격 데이터의 최소/최대값 계산
    final prices = stock.priceHistory.map((e) => e.value).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    print('가격 범위: $minPrice ~ $maxPrice');

    final priceSpots = <FlSpot>[];
    final antSoupSpots = <FlSpot>[];

    for (int i = 0; i < stock.priceHistory.length; i++) {
      final priceData = stock.priceHistory[i];
      priceSpots.add(FlSpot(i.toDouble(), priceData.value));

      // 개미탕 지수가 있는 경우에만 추가
      if (i < stock.antSoupIndex.length) {
        final antData = stock.antSoupIndex[i];
        // 개미탕 지수를 가격 범위에 맞게 스케일링
        final scaledValue = minPrice + (antData.value / 100) * (maxPrice - minPrice);
        antSoupSpots.add(FlSpot(i.toDouble(), scaledValue));
      }
    }

    print('FlSpot 생성 완료: 가격 ${priceSpots.length}개, 개미탕 ${antSoupSpots.length}개');

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.grey200.withOpacity(0.5),
            strokeWidth: 0.5,
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
            interval: (maxPrice - minPrice) / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toStringAsFixed(0)}K',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.grey600,
                  fontSize: 10.sp,
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
              final index = value.toInt();
              if (index >= 0 && index < stock.priceHistory.length) {
                final date = stock.priceHistory[index].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey600,
                    fontSize: 10.sp,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (priceSpots.length - 1).toDouble(),
      minY: minPrice * 0.95,
      maxY: maxPrice * 1.05,
      lineBarsData: [
        // 주가 라인
        LineChartBarData(
          spots: priceSpots,
          isCurved: true,
          color: AppColors.lightPrimary,
          barWidth: 2.w,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.lightPrimary.withOpacity(0.1),
          ),
        ),
        // 개미탕 지수 라인 (데이터가 있는 경우에만)
        if (antSoupSpots.isNotEmpty)
          LineChartBarData(
            spots: antSoupSpots,
            isCurved: true,
            color: AppColors.stockUp,
            barWidth: 1.5.w,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
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