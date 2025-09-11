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
  final String? asi5Diff;
  final bool isUp;
  final String? statusLabel;
  final Color? statusColor;
  final VoidCallback? onTap;
  final bool showDiff;

  const AntSoupStockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChangePercent,
    required this.asi5Avg,
    this.asi5Diff,
    required this.isUp,
    this.statusLabel,
    this.statusColor,
    this.onTap,
    this.showDiff = false,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isUp ? AppColors.stockUp : AppColors.stockDown;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 종목 정보
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 라벨 (있을 경우)
                  if (statusLabel != null) ...[
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
                    ),
                    SizedBox(height: 4.h),
                  ],

                  // 종목명
                  Text(
                    stockName,
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),

                  // 종목코드
                  Text(
                    stockCode,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),

            // 개미탕 지수 정보
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '개미탕',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    asi5Avg,
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getAsiColor(asi5Avg),
                    ),
                  ),
                  if (showDiff && asi5Diff != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '편차 $asi5Diff',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey500,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 가격 정보
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentPrice,
                    style: AppTextStyles.bodyText2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '$priceChangePercent%',
                      style: AppTextStyles.caption.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 개미탕 지수에 따른 색상
  Color _getAsiColor(String asiValue) {
    try {
      final value = int.parse(asiValue);
      if (value >= 120) {
        return Colors.red[700]!;
      } else if (value >= 100) {
        return Colors.orange[700]!;
      } else if (value >= 80) {
        return AppColors.grey700;
      } else if (value >= 60) {
        return Colors.cyan[700]!;
      } else {
        return Colors.blue[700]!;
      }
    } catch (e) {
      return AppColors.grey700;
    }
  }
}