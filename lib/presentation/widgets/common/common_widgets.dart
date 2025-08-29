import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/text_styles.dart';

// 공통 앱바
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headline6,
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

// lib/presentation/widgets/common/common_widgets.dart의 StockCard 부분만 수정

class StockCard extends StatelessWidget {
  final String stockName;
  final String stockCode;
  final String currentPrice;
  final String priceChangePercent;
  final String asiWithChange1;   // 직전 대비
  final String asiWithChange3;   // 3번째전 대비
  final String asiWithChange7;   // 7번째전 대비
  final bool isUp;
  final bool isAsiUp1;           // 직전 대비 증감
  final bool isAsiUp3;           // 3번째전 대비 증감
  final bool isAsiUp7;           // 7번째전 대비 증감
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChangePercent,
    required this.asiWithChange1,
    required this.asiWithChange3,
    required this.asiWithChange7,
    required this.isUp,
    required this.isAsiUp1,
    required this.isAsiUp3,
    required this.isAsiUp7,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 가격 변화에 따른 색상 결정
    final priceColor = _getPriceChangeColor(priceChangePercent, isUp);

    // 각 기간별 ASI 변화에 따른 색상 결정
    final asiColor1 = _getAsiChangeColor(asiWithChange1, isAsiUp1);
    final asiColor3 = _getAsiChangeColor(asiWithChange3, isAsiUp3);
    final asiColor7 = _getAsiChangeColor(asiWithChange7, isAsiUp7);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // 왼쪽: 종목명과 코드
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
                    Text(
                      stockCode,
                      style: AppTextStyles.stockCode,
                    ),
                  ],
                ),
              ),

              // 오른쪽: 가격 정보와 개미탕 지수들
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 현재가
                      Text(
                        currentPrice,
                        style: AppTextStyles.stockPrice.copyWith(
                          color: priceColor,
                        ),
                      ),
                      SizedBox(width: 6.w), // 간격

                      // 가격 변화율
                      Text(
                        priceChangePercent,
                        style: AppTextStyles.stockChange.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // 개미탕 지수 3개 기간 표시
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 직전 대비
                      _buildAsiItem('직전', asiWithChange1, asiColor1),
                      SizedBox(width: 8.w),

                      // 3번째전 대비
                      _buildAsiItem('3전', asiWithChange3, asiColor3),
                      SizedBox(width: 8.w),

                      // 7번째전 대비
                      _buildAsiItem('7전', asiWithChange7, asiColor7),
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

  // 개별 ASI 항목을 표시하는 위젯
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
}

// 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: AppTextStyles.bodyText2,
            ),
          ],
        ],
      ),
    );
  }
}

// 에러 위젯
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.bodyText1,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
}

// 빈 상태 위젯
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;

  const EmptyWidget({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64.sp,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.bodyText1.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            SizedBox(height: 16.h),
            action!,
          ],
        ],
      ),
    );
  }
}

// 검색바 위젯은 별도 파일로 분리됨 (search_bar.dart)