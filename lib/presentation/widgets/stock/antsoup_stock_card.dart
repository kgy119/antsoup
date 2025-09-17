// lib/presentation/widgets/stock/antsoup_stock_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';

class AntSoupStockCard extends StatelessWidget {
  final String stockName;
  final String stockCode;
  final String currentPrice;
  final String priceChangeAmount;
  final String priceChangePercent;
  final String asi5Avg;
  final String asiWithChange1;
  final String asiWithChange3;
  final String asiWithChange7;
  final bool isUp; // 이 값에 따라 색상이 결정됩니다.
  final bool isAsiUp1;
  final bool isAsiUp3;
  final bool isAsiUp7;
  final String? statusLabel;
  final Color? statusColor;
  final VoidCallback? onTap;

  final bool hasLiveData;
  final String? liveUpdateTime;

  const AntSoupStockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChangeAmount,
    required this.priceChangePercent,
    required this.asi5Avg,
    required this.asiWithChange1,
    required this.asiWithChange3,
    required this.asiWithChange7,
    required this.isUp,
    required this.isAsiUp1,
    required this.isAsiUp3,
    required this.isAsiUp7,
    this.statusLabel,
    this.statusColor,
    this.onTap,
    this.hasLiveData = false,
    this.liveUpdateTime,
  });

  @override
  Widget build(BuildContext context) {
    // isUp 값에 따라 색상 결정
    Color priceColor;
    if (priceChangePercent.contains('0.00')) {
      priceColor = Colors.grey; // 보합
    } else {
      priceColor = isUp ? Colors.red : Colors.blue; // 상승 또는 하락
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasLiveData
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: hasLiveData ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stockName,
                              style: AppTextStyles.bodyText1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasLiveData) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            stockCode,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          if (statusLabel != null) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: statusColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                statusLabel!,
                                style: AppTextStyles.caption.copyWith(
                                  color: statusColor ?? Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentPrice,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: priceColor,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // 변동금액과 변동률을 함께 표시
                      Text(
                        '$priceChangeAmount ($priceChangePercent)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: priceColor,
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASI 평균',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        asi5Avg,
                        style: AppTextStyles.bodyText2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAsiChangeItem('직전', asiWithChange1, isAsiUp1),
                      _buildAsiChangeItem('3전', asiWithChange3, isAsiUp3),
                      _buildAsiChangeItem('7전', asiWithChange7, isAsiUp7),
                    ],
                  ),
                ),
              ],
            ),
            if (hasLiveData && liveUpdateTime != null) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 10.w,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '업데이트: $liveUpdateTime',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAsiChangeItem(String label, String value, bool isUp) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey,
            fontSize: 9.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: isUp ? Colors.red : Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}