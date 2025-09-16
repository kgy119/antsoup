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
            // 종목 정보 (좌측)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // 추가
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stock.code,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),

            // 가격 정보 (중앙)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.formattedPrice,
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                    overflow: TextOverflow.ellipsis, // 추가
                    maxLines: 1, // 추가
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stock.formattedChangePercent,
                    style: AppTextStyles.caption.copyWith(
                      color: _getPriceChangeColor(),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // 추가
                    maxLines: 1, // 추가
                  ),
                ],
              ),
            ),

            // 간격 축소
            SizedBox(width: 8.w), // 12.w에서 8.w로 축소

            // ASI 정보 (우측) - flex 값 조정
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 현재 ASI
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), // 패딩 축소
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey700 : AppColors.grey100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'ASI ${stock.formattedCurrentAsi}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.grey700,
                        fontSize: 9.sp, // 폰트 크기 축소
                      ),
                      overflow: TextOverflow.ellipsis, // 추가
                      maxLines: 1, // 추가
                    ),
                  ),

                  SizedBox(height: 6.h), // 간격 축소

                  // ASI 변화율 (3개 기간)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: _buildAsiItem('직전', stock.formattedAsiChangePercent1, _getAsiChangeColor1()),
                      ),
                      Flexible(
                        child: _buildAsiItem('3전', stock.formattedAsiChangePercent3, _getAsiChangeColor3()),
                      ),
                      Flexible(
                        child: _buildAsiItem('7전', stock.formattedAsiChangePercent7, _getAsiChangeColor7()),
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


  Color _getPriceChangeColor() {
    if (stock.changePercent == 0) return AppColors.grey600;
    return stock.changePercent > 0 ? AppColors.stockUp : AppColors.stockDown;
  }

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

  void _goToStockDetail() {
    Get.toNamed('/stock_detail', arguments: {
      'stockCode': stock.code,
      'stockName': stock.name,
    });
  }
}