import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../data/models/stock_model.dart';

class StockListItem extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;

  const StockListItem({
    Key? key,
    required this.stock,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap ?? () => _goToStockDetail(),
      child: Container(
        padding: EdgeInsets.all(16.w),
        color: isDark ? AppColors.darkCard : Colors.white,
        child: Row(
          children: [
            // 좌측: 종목 정보
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 종목명과 상태 라벨
                  Row(
                    children: [
                      // 기존 종목명
                      Flexible(
                        child: Text(
                          stock.name,
                          style: AppTextStyles.bodyText1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.grey900,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      // 가열 상태 라벨 추가
                      if (stock.heatStatus != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: _getHeatStatusColor(stock.heatStatus),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Text(
                            stock.heatStatus!,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      // 냉각 상태 라벨 추가
                      if (stock.coldStatus != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: _getColdStatusColor(stock.coldStatus),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Text(
                            stock.coldStatus!,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // 종목코드
                  Text(
                    stock.code,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // 현재 ASI
                  Row(
                    children: [
                      Text(
                        'ASI ',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey600,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        stock.currentAsi.toString(),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? Colors.white : AppColors.grey900,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // 우측: 가격 및 ASI 정보
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 첫 번째 줄: 종목가 변동금액(변동율)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 종목가 (가격 색상 적용)
                      Text(
                        stock.hasNaverData ? stock.formattedDisplayPrice : stock.formattedPrice,
                        style: AppTextStyles.bodyText1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getPriceChangeColor(), // 가격 색상 적용
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 변동금액(변동율)
                      Flexible(
                        child: Text(
                          stock.formattedChangeWithPercent,
                          style: AppTextStyles.caption.copyWith(
                            color: _getPriceChangeColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // 두 번째 줄: 직전  3전  7전 (헤더)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildAsiHeader('직전'),
                      SizedBox(width: 16.w),
                      _buildAsiHeader('3전'),
                      SizedBox(width: 16.w),
                      _buildAsiHeader('7전'),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // 세 번째 줄: ASI 값과 변동율
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildAsiValueWithChange(
                        stock.prevAsi1.toString(),
                        stock.formattedAsiChangePercent1,
                        _getAsiChangeColor1(),
                      ),
                      SizedBox(width: 16.w),
                      _buildAsiValueWithChange(
                        stock.prevAsi3.toString(),
                        stock.formattedAsiChangePercent3,
                        _getAsiChangeColor3(),
                      ),
                      SizedBox(width: 16.w),
                      _buildAsiValueWithChange(
                        stock.prevAsi7.toString(),
                        stock.formattedAsiChangePercent7,
                        _getAsiChangeColor7(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ASI 헤더 위젯
  Widget _buildAsiHeader(String label) {
    return Container(
      width: 40.w, // 폭을 늘려서 변동율까지 표시 가능하게
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.grey600,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

// ASI 값과 변동율을 함께 표시하는 위젯
  Widget _buildAsiValueWithChange(String asiValue, String changePercent, Color color) {
    return Container(
      width: 40.w,
      alignment: Alignment.center,
      child: Column(
        children: [
          // ASI 값
          Text(
            asiValue,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(Get.context!).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.grey900,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: 2.h),

          // 변동율
          Text(
            changePercent,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

// ASI 색상 헬퍼 메서드들
  Color _getAsiChangeColor1() {
    final change = stock.asiChangePercent1;
    if (change == 0) return AppColors.grey600;
    return change > 0 ? AppColors.stockUp : AppColors.stockDown;
  }

  Color _getAsiChangeColor3() {
    final change = stock.asiChangePercent3;
    if (change == 0) return AppColors.grey600;
    return change > 0 ? AppColors.stockUp : AppColors.stockDown;
  }

  Color _getAsiChangeColor7() {
    final change = stock.asiChangePercent7;
    if (change == 0) return AppColors.grey600;
    return change > 0 ? AppColors.stockUp : AppColors.stockDown;
  }

// 가격 변동 색상 (수정됨)
  Color _getPriceChangeColor() {
    if (stock.hasNaverData) {
      // 네이버 데이터가 있는 경우
      final changeAmount = stock.displayChangeAmount;
      if (changeAmount > 0) return AppColors.stockUp;      // 상승: 빨간색
      if (changeAmount < 0) return AppColors.stockDown;    // 하락: 파란색
      return AppColors.grey600;                            // 보합: 회색
    } else {
      // 서버 데이터만 있는 경우
      if (stock.changeAmount > 0) return AppColors.stockUp;
      if (stock.changeAmount < 0) return AppColors.stockDown;
      return AppColors.grey600;
    }
  }

  // 가열 상태 색상
  Color? _getHeatStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '사골육수':
        return Colors.red[700];
      case '가열중':
        return Colors.orange[700];
      default:
        return Colors.grey[600];
    }
  }

  // 냉각 상태 색상
  Color? _getColdStatusColor(String? status) {
    if (status == null) return null;
    switch (status) {
      case '냉동보관':
        return Colors.blue[700];
      case '냉각중':
        return Colors.cyan[700];
      default:
        return Colors.grey[600];
    }
  }

  void _goToStockDetail() {
    Get.toNamed('/stock_detail', arguments: {
      'stockCode': stock.code,
      'stockName': stock.name,
    });
  }

// ASI 값 위젯
  Widget _buildAsiValue(String value, Color color) {
    return Container(
      width: 32.w,
      alignment: Alignment.center,
      child: Text(
        value,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
            fontSize: 9.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, // 추가
          maxLines: 1, // 추가
        ),
      ],
    );
  }
}