import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';

class AntSoupStockCard extends StatelessWidget {
  final String stockName;
  final String stockCode;
  final String currentPrice;
  final String priceChangePercent;
  final String asi5Avg;
  final String? asiWithChange1;      // 직전 대비 ASI
  final String? asiWithChange3;      // 3전 대비 ASI
  final String? asiWithChange7;      // 7전 대비 ASI
  final bool isUp;
  final bool? isAsiUp1;              // 직전 대비 증감
  final bool? isAsiUp3;              // 3전 대비 증감
  final bool? isAsiUp7;              // 7전 대비 증감
  final String? statusLabel;         // 상태 라벨 (가열중, 냉각중 등)
  final Color? statusColor;
  final VoidCallback? onTap;

  const AntSoupStockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChangePercent,
    required this.asi5Avg,
    this.asiWithChange1,
    this.asiWithChange3,
    this.asiWithChange7,
    required this.isUp,
    this.isAsiUp1,
    this.isAsiUp3,
    this.isAsiUp7,
    this.statusLabel,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 가격 변화에 따른 색상 결정
    final priceColor = _getPriceChangeColor(priceChangePercent, isUp);

    // 각 기간별 ASI 변화에 따른 색상 결정
    final asiColor1 = asiWithChange1 != null ? _getAsiChangeColor(asiWithChange1!, isAsiUp1 ?? false) : AppColors.grey600;
    final asiColor3 = asiWithChange3 != null ? _getAsiChangeColor(asiWithChange3!, isAsiUp3 ?? false) : AppColors.grey600;
    final asiColor7 = asiWithChange7 != null ? _getAsiChangeColor(asiWithChange7!, isAsiUp7 ?? false) : AppColors.grey600;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: () {
          print('AntSoupStockCard 클릭됨: $stockCode - $stockName');
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // 왼쪽: 종목명과 상태라벨
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stockName,
                      style: AppTextStyles.headline6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // 종목코드 대신 상태라벨 표시
                    if (statusLabel != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: statusColor ?? Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor ?? Colors.grey,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        stockCode,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                  ],
                ),
              ),

              // 오른쪽: 가격 정보와 개미탕 지수들 (StockCard와 동일한 구조)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 첫 번째 줄: 현재가 + 변동률 + 현재 ASI
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 현재가
                      Text(
                        currentPrice,
                        style: AppTextStyles.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 변동률
                      Text(
                        priceChangePercent,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 현재 ASI (일반 텍스트로, 색상 없음)
                      Text(
                        'ASI $asi5Avg',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // 두 번째 줄: 개미탕 지수 3개 기간 표시 (StockCard와 동일)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 직전 대비
                      _buildAsiItem('직전', asiWithChange1 ?? '-', asiColor1),
                      SizedBox(width: 8.w),

                      // 3번째전 대비
                      _buildAsiItem('3전', asiWithChange3 ?? '-', asiColor3),
                      SizedBox(width: 8.w),

                      // 7번째전 대비
                      _buildAsiItem('7전', asiWithChange7 ?? '-', asiColor7),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 개별 ASI 항목을 표시하는 위젯 (StockCard와 동일)
  Widget _buildAsiItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.grey600,
            fontSize: 9.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPriceChangeColor(String changePercent, bool isUp) {
    // 0.00%인지 확인
    if (changePercent == '0.00%' || changePercent == '+0.00%' || changePercent == '-0.00%') {
      return Colors.black;
    }

    // +나 -가 포함되어 있는지 확인
    if (changePercent.startsWith('+')) {
      return AppColors.stockUp; // 빨간색
    } else if (changePercent.startsWith('-')) {
      return AppColors.stockDown; // 파란색
    }

    // 백업: isUp 플래그 사용
    return isUp ? AppColors.stockUp : AppColors.stockDown;
  }

  // ASI 변화율 색상 결정
  Color _getAsiChangeColor(String asiString, bool isAsiUp) {
    // 데이터가 없는 경우
    if (asiString == '-') {
      return AppColors.grey600;
    }

    // 0.0%가 포함되어 있는지 확인
    if (asiString.contains('0.0%') || asiString.contains('+0.0%') || asiString.contains('-0.0%')) {
      return AppColors.grey600;
    }

    // +나 -가 포함되어 있는지 확인
    if (asiString.contains('+')) {
      return AppColors.stockUp; // 빨간색
    } else if (asiString.contains('-')) {
      return AppColors.stockDown; // 파란색
    }

    // 백업: isAsiUp 플래그 사용
    return isAsiUp ? AppColors.stockUp : AppColors.stockDown;
  }

  // 개미탕 지수 색상 결정
  Color _getAsiColor(String asiValue) {
    final numValue = double.tryParse(asiValue) ?? 50.0;

    if (numValue >= 80) {
      return AppColors.stockDown; // 파란색 - 높은 지수 (매도 심리)
    } else if (numValue >= 60) {
      return AppColors.warning; // 주황색 - 중간 지수
    } else if (numValue >= 40) {
      return AppColors.grey600; // 회색 - 중립
    } else if (numValue >= 20) {
      return AppColors.success; // 초록색 - 낮은 지수
    } else {
      return AppColors.stockUp; // 빨간색 - 매우 낮은 지수 (매수 심리)
    }
  }
}