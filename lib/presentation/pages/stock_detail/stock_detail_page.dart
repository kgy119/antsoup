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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '종목 정보가 없습니다.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPriceSection(stock),
              _buildPeriodSelector(),
              _buildChart(),
              _buildStockInfo(stock),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPriceSection(stock) {
    final changeColor = stock.isUp ? AppColors.stockUp : stock.isDown ? AppColors.stockDown : Colors.black;

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
                  color: changeColor, // 가격에도 색상 적용
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

          // 개미탕 지수 3단계 추가
          SizedBox(height: 16.h),
          _buildAntSoupIndexSection(stock),
        ],
      ),
    );
  }

  Widget _buildAntSoupIndexSection(stock) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAsiItem('직전', _getAsiWithChange1(stock), _getAsiChangeColor1(stock)),
              Container(
                width: 1,
                height: 40.h,
                color: AppColors.grey300,
              ),
              _buildAsiItem('3전', _getAsiWithChange3(stock), _getAsiChangeColor3(stock)),
              Container(
                width: 1,
                height: 40.h,
                color: AppColors.grey300,
              ),
              _buildAsiItem('7전', _getAsiWithChange7(stock), _getAsiChangeColor7(stock)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAsiItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grey600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyles.bodyText2.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// ASI 관련 헬퍼 메서드들 추가
  String _getAsiWithChange1(stock) {
    final asiChange = _getAsiChange1(stock);
    final asiChangePercent = _getAsiChangePercent1(stock);
    final symbol = asiChange > 0 ? '+' : (asiChange == 0 ? '' : '');
    return '${stock.currentAsi ?? 0}\n$symbol${asiChangePercent.toStringAsFixed(1)}%';
  }

  String _getAsiWithChange3(stock) {
    final asiChange = _getAsiChange3(stock);
    final asiChangePercent = _getAsiChangePercent3(stock);
    final symbol = asiChange > 0 ? '+' : (asiChange == 0 ? '' : '');
    return '${stock.currentAsi ?? 0}\n$symbol${asiChangePercent.toStringAsFixed(1)}%';
  }

  String _getAsiWithChange7(stock) {
    final asiChange = _getAsiChange7(stock);
    final asiChangePercent = _getAsiChangePercent7(stock);
    final symbol = asiChange > 0 ? '+' : (asiChange == 0 ? '' : '');
    return '${stock.currentAsi ?? 0}\n$symbol${asiChangePercent.toStringAsFixed(1)}%';
  }

// ASI 변화량 계산
  int _getAsiChange1(stock) {
    // 더미 데이터이므로 랜덤한 변화량 생성 (실제로는 stock.asiChange1 등을 사용)
    return -5;
  }

  int _getAsiChange3(stock) {
    return -12;
  }

  int _getAsiChange7(stock) {
    return 8;
  }

// ASI 변화율 계산
  double _getAsiChangePercent1(stock) {
    return -5.6;
  }

  double _getAsiChangePercent3(stock) {
    return -12.4;
  }

  double _getAsiChangePercent7(stock) {
    return 10.4;
  }

// ASI 변화에 따른 색상 결정
  Color _getAsiChangeColor1(stock) {
    final change = _getAsiChange1(stock);
    if (change > 0) return AppColors.stockUp;
    if (change < 0) return AppColors.stockDown;
    return AppColors.grey600;
  }

  Color _getAsiChangeColor3(stock) {
    final change = _getAsiChange3(stock);
    if (change > 0) return AppColors.stockUp;
    if (change < 0) return AppColors.stockDown;
    return AppColors.grey600;
  }

  Color _getAsiChangeColor7(stock) {
    final change = _getAsiChange7(stock);
    if (change > 0) return AppColors.stockUp;
    if (change < 0) return AppColors.stockDown;
    return AppColors.grey600;
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

    // 차트의 실제 Y축 범위
    final chartMinY = minPrice * 0.95;
    final chartMaxY = maxPrice * 1.05;
    final chartMidY = (chartMinY + chartMaxY) / 2; // 중간값 계산

    for (int i = 0; i < stock.priceHistory.length; i++) {
      final priceData = stock.priceHistory[i];
      priceSpots.add(FlSpot(i.toDouble(), priceData.value));

      // 개미탕 지수가 있는 경우에만 추가
      if (i < stock.antSoupIndex.length) {
        final antData = stock.antSoupIndex[i];

        // 개미탕 지수를 고정 범위 -40 ~ 240에서 차트 Y축 범위로 매핑
        const antSoupMin = -40.0;
        const antSoupMax = 240.0;

        // 개미탕 지수 값을 차트 Y축 범위에 매핑
        final normalizedAntValue = (antData.value - antSoupMin) / (antSoupMax - antSoupMin);
        final mappedValue = chartMinY + normalizedAntValue * (chartMaxY - chartMinY);

        antSoupSpots.add(FlSpot(i.toDouble(), mappedValue));
      }
    }

    print('FlSpot 생성 완료: 가격 ${priceSpots.length}개, 개미탕 ${antSoupSpots.length}개');

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBorder: const BorderSide(color: Colors.black87),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            List<LineTooltipItem> items = [];
            final index = touchedSpots.isNotEmpty ? touchedSpots.first.x.toInt() : 0;

            // 항상 주가를 먼저 추가 (파란색)
            if (index < stock.priceHistory.length) {
              final priceData = stock.priceHistory[index];
              items.add(LineTooltipItem(
                '${priceData.value.toStringAsFixed(0)}원',
                const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ));
            }

            // 그 다음 개미탕 지수 추가 (빨간색)
            if (index < stock.antSoupIndex.length) {
              final antData = stock.antSoupIndex[index];
              items.add(LineTooltipItem(
                '${antData.value.toStringAsFixed(1)}',
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ));
            }

            return items;
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // 터치 이벤트 처리 (필요시 추가 로직)
        },
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.grey200.withOpacity(0.5),
            strokeWidth: 0.5,
          );
        },
        // 중간선 추가
        drawHorizontalLine: true,
        horizontalInterval: (chartMaxY - chartMinY) / 4,
      ),
      // Y축 중간선 추가를 위한 ExtraLinesData 추가
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: chartMidY,
            color: AppColors.grey400.withOpacity(0.7),
            strokeWidth: 1.5,
            dashArray: [5, 5], // 점선 효과
            label: HorizontalLineLabel(
              show: false, // 라벨은 숨김
            ),
          ),
        ],
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
      minY: chartMinY,
      maxY: chartMaxY,
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
        // 개미탕 지수 라인 (실선으로 변경, 점선 제거)
        if (antSoupSpots.isNotEmpty)
          LineChartBarData(
            spots: antSoupSpots,
            isCurved: true,
            color: AppColors.stockUp,
            barWidth: 2.w, // 선 두께를 주가와 동일하게
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            // dashArray 제거하여 실선으로 만들기
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